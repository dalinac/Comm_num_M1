clc;
clear all;

filename = 'test.wav';
[I,Q,info] = myLoadWavAsIQ(filename);
Signal = complex(I,Q);
Signal = Signal(1:3200000);

startFrame = myGetFrameSart(Signal);

%%
Fs      = 2048000;
Rsym    = 76;
Tf      = 196608/Fs;
Tnull   = 2656/Fs;
Tu      = 2048/Fs;
Tg      = 504/Fs;
Tsym    = 2552/Fs;
Fu      = Fs/2048;
K       = 1536;
intLmode1_fn = 'freqInterleavingMode1.mat';

% Paramètres du modèle de canal
delta_f = 0;    % dérive de fréquence en Hz (0 = sans dérive)
SNR_dB  = inf;  % niveau de bruit (inf = sans bruit)
Offset  = 0;

% Application du modèle de canal
Signal_canal = myChannelModel(Signal, delta_f, SNR_dB, Fs);


clc
for it = 2 %:length(startFrame)-1
    fft_Frame     = SymbolFFT(Signal_canal, it, startFrame, Rsym, K, Tsym*Fs, Offset, Tu*Fs);
    [DeintFFTtab] = myFreqDeInterleave(intLmode1_fn, fft_Frame);
    dispFICinfo(it, Rsym, K, DeintFFTtab);
end
