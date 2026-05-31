function message = myValMat2Mess(ValMat,L)
    v       = reshape(ValMat',8/L,size(ValMat,1)*L/8)';
    message = char(bin2dec([dec2bin(v(:,1),L),dec2bin(v(:,2),L)]))';    
end