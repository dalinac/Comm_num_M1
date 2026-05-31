function binMat = myMess2binMat(message,L)
    len_mess = length(message);
    binMat = [];
    if round(8*len_mess/L)~=8*len_mess/L
        error("round(8*len_mess/L) != 8*len_mess/L....!");
    else
        binMat = message+0;
        binMat = dec2bin(binMat,8)-48;
        binMat = reshape(binMat',L,8*len_mess/L)';
    end
end