function [punctured] = depuncturing(data,PI)
    
v=PIDet(PI);                                                        

FinalAnzBits = length(data(1,:))/sum(v)*32;                        
punctured = zeros(length(data(:,1)),FinalAnzBits);                

dataSourceZeiger = 1;
dataTargetZeiger = 1;
vZeiger = 1;

for h = 1:length(punctured(1,:))                                        
    if v(vZeiger) == 1                                              
        punctured(:,dataTargetZeiger) = data(:,dataSourceZeiger);
        dataSourceZeiger = dataSourceZeiger + 1;
    end
    
    dataTargetZeiger = dataTargetZeiger +1;
    vZeiger = vZeiger + 1;
    
    if vZeiger == 33                                                
        vZeiger = 1;
    end
end

