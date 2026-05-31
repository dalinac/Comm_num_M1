%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Masterthesis
% Zürcher Hochschule für Angewandte Wissenschaften
% Zentrum für Signalverarbeitung und Nachrichtentechnik
% © Michael Höin
% 12.4.2011 ZSN
% info.zsn@zhaw.ch
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% -----------------------------------------------------------------------------------------
% CRC16 Check
% -----------------------------------------------------------------------------------------

function [Check] = CRC16(Data)

Data(end-15:end)=xor(Data(end-15:end),[1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1]);           % Das Zweierkomplement des CRC wird den Daten angehängt

CRC = [1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1];            % Initialization word
Polynomial = [0 0 0 1 0 0 0 0 0 0 1 0 0 0 0];       % [MSB ... LSB]

for i=1:length(Data)                                % CRC berechnen
    
    if 1 == xor(CRC(1),Data(i))
        CRC = [xor(Polynomial,CRC(2:end)) 1];
    else
        CRC = [CRC(2:end) 0];
    end
        
end

if sum(CRC) == 0                                    % CRC überprüfuen
    Check = 1;
else
    Check = 0;
end