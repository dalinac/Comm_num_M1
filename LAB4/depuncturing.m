%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Masterthesis
% Zürcher Hochschule für Angewandte Wissenschaften
% Zentrum für Signalverarbeitung und Nachrichtentechnik
% © Michael Höin
% 12.4.2011 ZSN
% info.zsn@zhaw.ch
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% -----------------------------------------------------------------------------------------
% (De)puncturing (FIC)
% -----------------------------------------------------------------------------------------

function [punctured] = depuncturing(data,PI)
    
v=PIDet(PI);                                                        % Puncturing vector abfragen

FinalAnzBits = length(data(1,:))/sum(v)*32;                         % Ausgabearray vorbereiten
punctured = zeros(length(data(:,1)),FinalAnzBits);                  % Puncturing Stellen mit Nullen füllen

dataSourceZeiger = 1;
dataTargetZeiger = 1;
vZeiger = 1;

for h = 1:length(punctured(1,:))                                    % Daten Puncturieren
    
    if v(vZeiger) == 1                                              % Ausgabevektor bilden (Puncturing Vektor = 1 = Daten einfüllen)
        punctured(:,dataTargetZeiger) = data(:,dataSourceZeiger);
        dataSourceZeiger = dataSourceZeiger + 1;
    end
    
    dataTargetZeiger = dataTargetZeiger +1;
    vZeiger = vZeiger + 1;
    
    if vZeiger == 33                                                % Position im Puncturingsvektor zurücksetzen
        vZeiger = 1;
    end
end

