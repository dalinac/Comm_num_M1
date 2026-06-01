function tx = my_ofdmmod(grid, Nfft, Ncp)
% MY_OFDMMOD  OFDM modulateur : IFFT + insertion du "cyclic prefix"
%   tx = my_ofdmmod(grid, Nfft, Ncp)
%   grille complexe [Nfft x Nsym]
%   Nfft : nombre de sous-cannaux
%   Ncp  : longueur en samples du "cyclic prefix"
%   tx   : forme d'onde temporelle [(Nfft+Ncp)*Nsym]

    [~, Nsym] = size(grid);
    tx = zeros((Nfft + Ncp) * Nsym, 1);
    for k = 1:Nsym
        sym = ifft(grid(:,k), Nfft) * sqrt(Nfft);   % IFFT + normalisation de la puissance 
        cp  = sym(end-Ncp+1 : end);                  % cyclic prefix
        tx((k-1)*(Nfft+Ncp)+1 : k*(Nfft+Ncp)) = [cp; sym];
    end
end
