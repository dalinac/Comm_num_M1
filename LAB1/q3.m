%% Q3 - Altération spectrale et reconstruction du signal NRZ
% On altère le lobe principal (petite portion) puis le premier lobe secondaire

clear; close all;

%% Paramètres (identiques à Q1)
N        = 32;
Fe       = 1000;
sampPbit = 6;
Fb       = Fe / sampPbit;
t        = (0:N*sampPbit-1) / Fe;

rng(42);
bits = randi([0 1], 1, N);
NRZ  = repmat(bits(:), 1, sampPbit)'; NRZ = NRZ(:)';
signal = 2*NRZ - 1;

Nfft = 2^nextpow2(length(signal));
freq = linspace(-Fe/2, Fe/2, Nfft);

% FFT du signal
S       = fft(signal, Nfft);
S_shift = fftshift(S);

%% CAS A : altération d'une petite portion du lobe principal 
% Le lobe principal s'étend de 0 à f_n1 = Fe/sampPbit ~ 167 Hz
% On coupe environ 10% de ce lobe autour de 60-80 Hz (côté positif + négatif)

f_n1      = Fe / sampPbit;            % ~ 167 Hz
cut_start = 50;  cut_end = 80;        % plage à annuler (Hz)

S_altA = S_shift;
mask_A = (abs(freq) >= cut_start) & (abs(freq) <= cut_end);
S_altA(mask_A) = 0;

% IFFT de reconstruction
sig_recA = real(ifft(ifftshift(S_altA), Nfft));
sig_recA = sig_recA(1:length(signal));

%% --- CAS B : altération du premier lobe secondaire 
% Premier lobe secondaire : de f_n1 à 2*f_n1 ~ [167, 333] Hz

S_altB = S_shift;
mask_B = (abs(freq) >= f_n1) & (abs(freq) <= 2*f_n1);
S_altB(mask_B) = 0;

sig_recB = real(ifft(ifftshift(S_altB), Nfft));
sig_recB = sig_recB(1:length(signal));
figure('Name','Q3 - Altération lobe principal','Position',[100 100 1000 700]);

% Signal original
subplot(3,2,1);
stairs(t, signal, 'LineWidth',1.5); grid on;
title('Signal original NRZ ±1'); xlabel('t (s)'); ylabel('Amplitude');

% DSP originale
subplot(3,2,2);
plot(freq, 10*log10(fftshift(abs(S).^2/Nfft)+eps), 'b', 'LineWidth',1.2); grid on;
title('DSP originale'); xlabel('f (Hz)'); ylabel('dB');
ylim([-60 20]);

% DSP altérée A
dsp_altA = 10*log10(abs(S_altA).^2/Nfft + eps);
subplot(3,2,3);
plot(freq, dsp_altA, 'r', 'LineWidth',1.2); grid on;
title(sprintf('DSP après altération lobe principal [%d-%d Hz]', cut_start, cut_end));
xlabel('f (Hz)'); ylabel('dB'); ylim([-60 20]);

% Signal reconstruit A
subplot(3,2,4);
plot(t, sig_recA, 'r', 'LineWidth',1.2); hold on;
stairs(t, signal, 'b--', 'LineWidth',0.8);
grid on;
title('Signal reconstruit (lobe principal altéré)');
xlabel('t (s)'); ylabel('Amplitude');
legend('Reconstruit','Original');

% DSP altérée B
dsp_altB = 10*log10(abs(S_altB).^2/Nfft + eps);
subplot(3,2,5);
plot(freq, dsp_altB, 'm', 'LineWidth',1.2); grid on;
title(sprintf('DSP après altération 1er lobe secondaire [%.0f-%.0f Hz]', f_n1, 2*f_n1));
xlabel('f (Hz)'); ylabel('dB'); ylim([-60 20]);

% Signal reconstruit B
subplot(3,2,6);
plot(t, sig_recB, 'm', 'LineWidth',1.2); hold on;
stairs(t, signal, 'b--', 'LineWidth',0.8);
grid on;
title('Signal reconstruit (1er lobe secondaire altéré)');
xlabel('t (s)'); ylabel('Amplitude');
legend('Reconstruit','Original');

sgtitle('Q3 - Altérations spectrales et reconstruction');

saveas(gcf, 'figures/q3_alteration.png');

fprintf('Q3 terminé.\n');
fprintf('Lobe principal altéré : [%d, %d] Hz\n', cut_start, cut_end);
fprintf('1er lobe secondaire altéré : [%.0f, %.0f] Hz\n', f_n1, 2*f_n1);
