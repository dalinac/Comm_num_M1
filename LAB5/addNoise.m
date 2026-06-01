function y=addNoise(x,SNR_dB)
    Px = mean(abs(x).^2);     % Puissance moyenne du signal
    SNR = 10^(SNR_dB/10);     % SNR linéaire
    
    Pb = Px / SNR;            % Puissance du bruit
    bruit = sqrt(Pb/2) * (randn(size(x)) + 1j*randn(size(x)));
    y = x + bruit;
end