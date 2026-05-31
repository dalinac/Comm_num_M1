function [fft_Array] = SymbolFFT(Signal,it,startFrame,Rsym,K,TsymFS,Offset,TuFs) 
% Signal      signal complexe IQ échantillonné (après démodulation, sans porteuse)
% it          indice de la trame à traiter parmi les trames détectées
% startFrame  vecteur des indices d'échantillon (ou dates) du début de chaque trame DAB
% Rsym        nombre de symboles OFDM par trame (hors symbole NULL)
% K           nombre de sous-porteuses (canaux fréquentiels)
% TsymFS      nombre d'échantillons d'un symbole complet (partie utile + intervalle de garde)
% Offset      décalage supplémentaire en échantillons (marge / alignement après détection du début
%             de trame ; le début effectif vient de startFrame, pas de la puissance nulle)
% TuFs        nombre d'échantillons de la partie utile du symbole OFDM (sans intervalle de garde)
%
% fft_Array   matrice Rsym x K : une FFT par symbole (sorties fréquentielles avant désentrelacement)
fft_tmp = zeros ([ Rsym , K ]) ;
for jt = 0: Rsym -1
    i = jt * TsymFS ;
    Symbol = Signal ( startFrame ( it ) + i + Offset : startFrame ( it ) + TuFs- 1 + i + Offset ) ;
    Y = fft ( Symbol ) ;
    Y = fftshift ( Y ) ;
fft_tmp ( jt +1 , (1: K /2) ) = Y ( TuFs /2 - K /2+1: TuFs /2) ;
fft_tmp ( jt +1 , ( K /2+1: K ) ) = Y ( TuFs /2+2: TuFs /2+ K /2+1) ;
fft_Array = fft_tmp (2: Rsym ,:) .* conj ( fft_tmp (1: Rsym -1 ,:) ) ;

end