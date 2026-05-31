function [Check] = CRC16(Data)

Data(end-15:end)=xor(Data(end-15:end),[1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1]);        

CRC = [1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1];            
Polynomial = [0 0 0 1 0 0 0 0 0 0 1 0 0 0 0];       

for i=1:length(Data)                                
    
    if 1 == xor(CRC(1),Data(i))
        CRC = [xor(Polynomial,CRC(2:end)) 1];
    else
        CRC = [CRC(2:end) 0];
    end
        
end

if sum(CRC) == 0                                    
    Check = 1;
else
    Check = 0;
end