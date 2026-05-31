function [I,Q,info] = myLoadWavAsIQ(filename)
    info = audioinfo(filename);
    info.Filename = filename;
    
    % Chargement du fichier audio
    % [y, fs] = audioread(filename,'native');
    y = audioread(filename,'double');
    I = double(y(:,1)');
    Q = double(y(:,2)');
end