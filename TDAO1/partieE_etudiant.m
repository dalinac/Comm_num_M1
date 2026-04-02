clear; clc; close all;

%% 1. Paramètres de synthèse du filtre RII (Chebyshev type 2)
NB = 512;
Fs = 48000;      % Fréquence d'échantillonnage (Hz)
N  = 10;         % Ordre du filtre
Fstop1 = 4200;   % Fréquence de coupure basse (Hz)
Fstop2 = 16600;  % Fréquence de coupure haute (Hz)
Astop  = 48;     % Atténuation en bande coupée (dB)

% Synthèse du filtre 
h  = fdesign.bandpass('N,Fst1,Fst2,Ast', N, Fstop1, Fstop2, Astop, Fs);
Hd = design(h, 'cheby2');

%% 2. Génération des figures E.1 : Réponses temporelle et fréquentielle
[hn, idx] = impz(Hd);
[H, w_Hz] = freqz(Hd, [], Fs);
freq = w_Hz / 1000; % Conversion en kHz

% Réponse impulsionnelle
figure(1); clf;
stem(idx, hn, '--o', "filled", "LineWidth", 2);
xlabel('Échantillon (n)');
ylabel('Amplitude');
title('Réponse impulsionnelle');
grid on;

% Module et Phase
figure(2); clf;
ax = plotyy(freq, 20*log10(abs(H)), freq, unwrap(angle(H)));
xlabel('Fréquence [kHz]');
ylabel(ax(1), 'Magnitude (dB)');
ylabel(ax(2), 'Phase (rad)');
title('Module et Phase de la réponse fréquentielle');
grid on;

% Temps de propagation de groupe
figure(3); clf;
gd = -diff(unwrap(angle(H)) / (2 * pi)) * 1000;
plot(freq(1:end - 1), gd, 'LineWidth', 1.5);
ylim([0, 20]);
xlabel('Fréquence [kHz]');
ylabel('Temps de propagation de groupe [ms]');
title('Temps de propagation de groupe');
grid on;

%% 3. Génération de la figure E.2 : Diagramme Pôles-Zéros
% Conversion en forme SOS (Second-Order Sections) pour garantir la stabilité
[num, den] = tf(Hd);
sos = tf2sos(num, den);
[z, p, k] = sos2zp(sos, 1);

figure(4); clf; hold on;
plot(cos(pi*(0:0.01:2)), sin(pi*(0:0.01:2)), 'r', 'DisplayName', 'Cercle unité');
hZ = plot(real(z), imag(z), 'ok', 'linewidth', 2, 'DisplayName', 'Zéros');
hP = plot(real(p), imag(p), 'xk', 'linewidth', 3, 'DisplayName', 'Pôles');
axis equal; 
grid on;
title('Diagramme des pôles et zéros');
legend([hZ hP], 'Location', 'best');

%% 4. Génération de la figure E.3 : Validation pratique par filtrage audio
figure(5); clf;
[music, fs] = audioread('funky.wav');

% Filtrage avec la structure SOS
tic;
musicF = sosfilt(sos, music);
toc;

% Comparaison temporelle et fréquentielle
subplot(2, 2, 1); 
plot(music); 
title('Signal original');

subplot(2, 2, 2); 
specgram(music, 512, Fs/1000); 
ylabel('Fréquence [kHz]'); 
set(gca, 'XTick', []);

subplot(2, 2, 3); 
plot(musicF); 
title('Signal filtré');

subplot(2, 2, 4); 
specgram(musicF, 512, Fs/1000); 
ylabel('Fréquence [kHz]'); 
set(gca, 'XTick', []);

% Lecture audio (Normalisée pour éviter la saturation)
sound(musicF / max(abs(musicF)) / 2, Fs);