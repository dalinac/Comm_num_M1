function sig = myLoadIQ(filename)
    precision = 'float32';         
    fid = fopen(filename, 'rb');
    if fid == -1
        error('Impossible d''ouvrir le fichier : %s', filename);
    end
    myData = fread(fid, inf, precision);
    fclose(fid);
    
    IQ = reshape(myData,2,length(myData) / 2)';
    sig = complex(IQ(:, 1),IQ(:, 2));
end