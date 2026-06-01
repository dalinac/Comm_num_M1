function grid = my_ofdmdemod(rx, Nfft, Ncp)
% MY_OFDMDEMOD  demodulateur OFDM: retirer le "cyclic prefix" puis FFT.
%   tx = my_ofdmmod(grid, Nfft, Ncp)
%   grille complexe [Nfft x Nsym]
%   Nfft : nombre de sous-cannaux
%   Ncp  : longueur en samples du "cyclic prefix"
%   tx   : forme d'onde temporelle [(Nfft+Ncp)*Nsym]

    frame = Nfft + Ncp;
    Nsym  = floor(length(rx) / frame);
    grid  = zeros(Nfft, Nsym);
    for k = 1:Nsym
        block     = rx((k-1)*frame+1 : k*frame);
        grid(:,k) = fft(block(Ncp+1:end), Nfft) / sqrt(Nfft); % normalisation
    end
end
