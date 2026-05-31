clc;
clear all;

filename = 'ELISE_16s_Ncomp.iq';
Signal = myLoadIQ(filename)';

filename = 'test.wav';
[I,Q,info] = myLoadWavAsIQ(filename);
Signal = complex(I,Q);

Signal=Signal(1:3200000);
startFrame = myGetFrameSart(Signal);
%%
Fs = 2048000;   % fréquence d'échantillonage standard d'un signal DAB après
                % démodulation (plus de porteuse)
% caractéristiques du mode 1
Rsym    = 76;        % 76 symboles par trame (sans inclure le symbole NULL)
Tf      = 196608/Fs; % Duréede toute une trame (96 ms)
Tnull   = 2656/Fs;   % durée du symbole null en fin de trame
Tu      = 2048/Fs;   % Durée d'un symbole sans le temps intercalaire contre le ICI
Tg      = 504/Fs;    % durée du temps intercalaire contre le ICI
Tsym    = 2552/Fs;   % Durée effective d'un symbole Tu+Tg
Fu      = Fs/2048;   % espacement fréquentiel inter-porteuses
Fs      = 2048000;   % Fs maxi du R820T = 28 800 000Hz
K       = 1536;      % nobre de sous-porteuses
interL1 = 2048;      % Taille des permutation dans le cas du Mode I
intLmode1_fn = 'freqInterleavingMode1.mat'; % i_PIi_dn_n_k = Frequency interleaving for transmission mode I

Offset = 0;
delta_f = 150;

N_total = Tsym*Fs * Rsym;
t = (0:N_total-1)' / Fs;
% Si le récepteur échantillonne avec Fs + delta_f
% → revient à multiplier le signal par exp(j*2π*delta_f*t)

%%
clc
for  it=2 %:length(startFrame)-1
    fft_Frame         = SymbolFFT(Signal,it,startFrame,Rsym,K,Tsym*Fs,Offset,Tu*Fs);
    [DeintFFTtab]     = myFreqDeInterleave(intLmode1_fn, fft_Frame);  % Désentrelacement pp110-111

    dispFICinfo(it,Rsym,K,DeintFFTtab);
end



