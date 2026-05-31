function Xtf_mn = mySFFT(x)
    [M,N] = size(x);
    Xtf_mn = sqrt(N/M)*ifft(fft(x,[],2),[],1);% ifft est donnée en 1/N
end