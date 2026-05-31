function [symbols,Ydd_kl,Xdd_kl,x,y] = myOTFScomm(message, L, codeModulation, ...
                                              Fs, Tu, Tg, SNRdB, pathDelaysInSeconds,...
                                              pathDopplers,pathGains)
    N = length(message);
    M = length(message{1})*8/L; % 8 bits par char
    
    Xdd_kl = zeros(M,N);
    for l=1:N
        symbole    = message{l};
        if strcmpi(codeModulation,"QAM")
            Xdd_kl(:,l)  = myQAMmod(myMess2ValMat(symbole,L),L);
        else
            Xdd_kl(:,l)  = myMess2ValMat(symbole,L);% du coup pas de modulation
        end
    end
    
    Xtf_mn = myISFFT(Xdd_kl);
    x = myOFDMmod(Xtf_mn,Fs,Tu,Tg);
    
    y = myDopplerMultiChannel(x,pathDelaysInSeconds,pathDopplers,pathGains);
    y = myAwgn(y,SNRdB);
        
        Ytf_mn = myOFDMdemod(y,M,Fs,Tu,Tg);
        Ydd_kl = mySFFT(Ytf_mn);
        symbols = cell(1,N);
        for l=1:N
            if strcmpi(codeModulation,"QAM")
                ValMat  = myQAMdemod(Ydd_kl(:,l),L);
            else
                ValMat  = round(abs(Ydd_kl(:,l)));
            end
            symbole = myValMat2Mess(ValMat,L);
            symbols(1,l) = {symbole}; % Copie de str1
        end
end