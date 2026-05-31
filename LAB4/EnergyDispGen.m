%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Masterthesis
% Zürcher Hochschule für Angewandte Wissenschaften
% Zentrum für Signalverarbeitung und Nachrichtentechnik
% © Michael Höin
% 12.4.2011 ZSN
% info.zsn@zhaw.ch
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% -----------------------------------------------------------------------------------------
% Energy dispersal Sequenzgenerator
% -----------------------------------------------------------------------------------------

function [PRBS] = EnergyDispGen(size)

Vector = [1 1 1 1 1 1 1 1 1];               % Initialization word

PRBS= zeros(1,size);
ZeigerPRBS = 1;
for i=0:size-1
    NewBit =  xor(Vector(5),Vector(9));     % Neues Bit berechnen
    Vector = [NewBit Vector(1:end-1)];      % Neues Bit in Schieberegister verwenden
    PRBS(ZeigerPRBS) = NewBit;              % Kette aus neuen Bits bilden
    ZeigerPRBS = ZeigerPRBS + 1;
end