function [PRBS] = EnergyDispGen(size)
Vector = [1 1 1 1 1 1 1 1 1];               
PRBS= zeros(1,size);
ZeigerPRBS = 1;
for i=0:size-1
    NewBit =  xor(Vector(5),Vector(9));      
    Vector = [NewBit Vector(1:end-1)];       
    PRBS(ZeigerPRBS) = NewBit;               
    ZeigerPRBS = ZeigerPRBS + 1;
end