function Xtf_mn = myISFFT(x)
    [M,N] = size(x);
    Xtf_mn = sqrt(N/M)*fft(ifft(x,[],2),[],1);% ifft est donnée en 1/N
end