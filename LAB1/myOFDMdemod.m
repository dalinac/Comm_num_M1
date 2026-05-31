function Ytf_mn = myOFDMdemod(y,M,Fs,Tu,Tg)
    Mg = Fs*Tg;
    Mu = Fs*Tu;
    N = length(y)/(Mu+Mg);
    uy = reshape(y,Mu+Mg,N);
    Ytf_mn = zeros(M,N);
    for n=1:N
        y_m = uy(Mg+1:Mg+Mu,n);
        tmp = fft(y_m);
        Ytf_mn(1:M,n) = tmp(2:M+1);
    end
end
