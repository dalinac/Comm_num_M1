function [I,Q,info] = myLoadWavAsIQ(filename)
    info = audioinfo(filename);
    info.Filename = filename;
    y = audioread(filename, 'double');    I = double(y(:,1)');
    Q = double(y(:,2)');
end