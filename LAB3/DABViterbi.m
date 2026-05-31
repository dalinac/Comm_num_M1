function [BitDef] = DABViterbi(yIn)

Generator = [1 0 1 1 0 1 1;...                                               
             1 1 1 1 0 0 1;...
             1 1 0 0 1 0 1;...
             1 0 1 1 0 1 1];
         
lange = length(Generator(:,1));

y=reshape(yIn,lange,length(yIn)/lange)';

SpeicherTabs = length(Generator(1,:)) - 1;
MemDeep= 5*SpeicherTabs;                                                                 
y=[y;zeros(MemDeep,lange)];                                                              
																						 
Pfad = mod ([(0:2^SpeicherTabs-1)'*2 (0:2^SpeicherTabs-1)'*2+1],2^SpeicherTabs);         
                                                                                         
																						 
Pfadspeicher = zeros(2^SpeicherTabs,MemDeep);                                            
Metrik = -1000*ones(2^SpeicherTabs,2);                                                   
Metrik(1) = 0;                                                                           
BitDef = zeros(1,length(y(:,1))-MemDeep);                                                
BitIndex = 1;                                                                            
																						 
for i=1:length(y(:,1))                                                                   
    for index=1:2^SpeicherTabs                                                           
																						 
        if index > 2^(SpeicherTabs-1)                                                    
            NewBit = 1;                                                                  
            StepOutGen1=[NewBit double(dec2bin(Pfad(index,1),SpeicherTabs)-'0')];        
            StepOutGen2=[NewBit double(dec2bin(Pfad(index,2),SpeicherTabs)-'0')];        
        else                                                                             
            NewBit = 0;                                                                  
            StepOutGen1=[NewBit double(dec2bin(Pfad(index,1),SpeicherTabs)-'0')];        
            StepOutGen2=[NewBit double(dec2bin(Pfad(index,2),SpeicherTabs)-'0')];        
        end
        Ref1 = 1-2.*mod(StepOutGen1*Generator',2);                     
        Value1 = Ref1 * y(i,:)'+Metrik(Pfad(index,1)+1,1);             
        Ref2 = 1-2.*mod(StepOutGen2*Generator',2);                     
        Value2 = Ref2 * y(i,:)'+Metrik(Pfad(index,2)+1,1);             
																	   
        if Value1 > Value2                                             
            Metrik(index,2) = Value1;                                  
            Pfadspeicher(index,end) = Pfad(index,1);                   
        else                                                           
            Metrik(index,2) = Value2;                                  
            Pfadspeicher(index,end) = Pfad(index,2);                   
        end                                                            
    end                                                                
    if i > MemDeep                                                     
        [Nothing, Pos] = max(Metrik(:,2));                             
        for p=0:MemDeep-1                                              
            Pos=Pfadspeicher(Pos,end-p)+1;                             
        end                                                            
        Pos = Pos - 1;                                                 
        if Pos >=2^(SpeicherTabs-1)                                    
            BitDef(BitIndex) = 1;                                      
        else                                                           
            BitDef(BitIndex) = 0;                                      
        end                                                            
        BitIndex = BitIndex +1;                                        
    end                                                                
    Pfadspeicher = circshift(Pfadspeicher,[0 -1]);                     
    Metrik = circshift(Metrik,[0 -1]);                                 
end                                                                    