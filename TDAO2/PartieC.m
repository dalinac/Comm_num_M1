clear; clc; close all;

fs = 1e5; T = 10; N = round(fs*T);

nm = {'Blue noise', 'Pink noise (flicker)', 'Red noise (Brownian noise)', 'Violet noise', 'White noise', 'total'};
clr = [0 0 1; 1 0.5 0.5; 1 0 0; 0.4940 0.1840 0.5560; 0.4 0.4 0.4; 0 0 0];

x_blue = bluenoise(N, 1);
x_blue = x_blue/std(x_blue);

x_pink = pinknoise(N,1);
x_pink = x_pink/std(x_pink);

x_red = rednoise(N,1);
x_red = x_red/std(x_red);

x_violet = violetnoise(N,1);
x_violet = x_violet/std(x_violet);

x_white = randn(N,1);
x_white = x_white/std(x_white);

x_total = x_blue + x_pink + x_red + x_violet + x_white;

all_sig = {x_blue, x_pink, x_red, x_violet, x_white, x_total};

window = hanning(2*fs, 'periodic');
noverlap = length(window)/2;
nfft = 2*fs;

figure('Name', 'DSP des bruits colores');
for k = 1:6
    [pxx, freq] = pwelch(all_sig{k}, window, noverlap, nfft, fs, 'onesided');
    semilogx(freq, 10*log10(pxx), 'Color', clr(k,:), 'LineWidth', 1.5); hold on;
end
xlabel('Frequence (Hz)'); ylabel('Magnitude (dBV^2/Hz)');
title('DSP des bruits colores (methode de Welch)');
legend(nm, 'Location', 'southwest'); grid on;

% Suite du code Q1
lag_max = 10;
% all_sig, clr et nm deja definis

figure('Name', 'Autocorrelation des bruits colores');
for k = 1:6
    subplot(3,2,k);
    [acf, lags] = xcorr(all_sig{k}, lag_max, 'coeff');
    plot(lags/fs, acf, 'Color', clr(k,:));
    yline(0, 'k', 'LineWidth', 0.8);
    xlabel('Lag (s)'); ylabel('Autocorrelation');
    title(nm{k});
    xlim([-lag_max/fs lag_max/fs]); grid on;
end
sgtitle('Autocorrelation des bruits colores');