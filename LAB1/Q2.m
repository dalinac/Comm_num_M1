
clear; close all;

N        = 32;
Fe       = 1000;
Te       = 1/Fe;
sampPbit = 6;
Fb       = Fe / sampPbit;
t        = (0:N*sampPbit-1) / Fe;   % axe temps en secondes

rng(42);  %  reproductibilité
bits     = randi([0 1], 1, N);

% Construction du signal NRZ (suréchantillonné)
NRZ      = repmat(bits(:), 1, sampPbit)';
NRZ      = NRZ(:)';

figure('Name','NRZ','Position',[100 100 900 500]);

subplot(2,1,1);
stairs(t, NRZ, 'LineWidth', 1.5);
ylim([-0.2 1.2]);
xlabel('Temps (s)'); ylabel('Amplitude');
title(sprintf('Signal NRZ (N=%d bits, Fb=%.0f Hz)', N, Fb));
grid on;

% DSP via FFT
signal = 2*NRZ - 1;   % ±1 pour supprimer la raie DC
Nfft   = 2^nextpow2(length(signal));
freq   = linspace(-Fe/2, Fe/2, Nfft);
spectre = fftshift(abs(fft(signal, Nfft)).^2 / Nfft);

subplot(2,1,2);
plot(freq, 10*log10(spectre), 'b', 'LineWidth', 1.2);
xlabel('Fréquence (Hz)'); ylabel('DSP (dB)');
title(sprintf('Densité Spectrale de Puissance  |  f_{n1} = Fe/Spb = %.1f Hz', Fe/sampPbit));
ylim([-60 20]);
xline(Fe/sampPbit,  '--r', 'LineWidth',1.2, 'Label','f_{n1}');
xline(-Fe/sampPbit, '--r', 'LineWidth',1.2);
grid on;
mkdir('figures');
saveas(gcf, 'figures/q1_nrz.png');

fprintf('Q1 terminé.\n');
fprintf('Premier nœud spectral : f_n1 = %.2f Hz\n', Fe/sampPbit);