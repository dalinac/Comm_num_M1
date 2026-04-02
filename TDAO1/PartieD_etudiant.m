clear; clc; close all;

%% 1. Paramètres de synthèse du filtre RIF
NB = 512;        % Nombre de points pour la FFT
Fs = 48000;      % Fréquence d'échantillonnage (Hz)
N = 30;          % Ordre du filtre (générera N+1 coefficients)

% Définition des bandes de fréquences (Hz)
Fstop1 = 4000;   % Fin de la première bande coupée
Fpass1 = 6000;   % Début de la bande passante
Fpass2 = 14000;  % Fin de la bande passante
Fstop2 = 16000;  % Début de la deuxième bande coupée

% Poids d'erreur (Tolérance d'ondulations : un poids élevé = petite tolérance)
Wstop1 = 60;     % Forte contrainte d'atténuation en basse fréquence
Wpass  = 1;      % Faible contrainte dans la bande passante
Wstop2 = 60;     % Forte contrainte d'atténuation en haute fréquence
dens   = 20;     % Densité de la grille de fréquences pour l'algorithme

%% 2. Synthèse avec l'algorithme de Parks-McClellan (firpm)
% firpm prend en arguments : (Ordre du filtre, [Fréquences normalisées], [Amplitudes cibles], [Poids], {Densité})
b = firpm(N, [0 Fstop1 Fpass1 Fpass2 Fstop2 Fs/2]/(Fs/2), [0 0 1 1 0 0], [Wstop1 Wpass Wstop2], {dens});

Hd = dfilt.dffir(b); % Création de l'objet filtre pour analyse

%% 3. Génération de la figure D.1 : Module et Phase
[H, w] = freqz(b, 1, NB);
freq = w ./ (2 * pi) .* Fs ./ 1000; % Conversion de la pulsation en fréquence (kHz)

figure(12); clf;
ax = plotyy(freq, 20*log10(abs(H)), freq, unwrap(angle(H)));
ylim(ax(1), [-80, 5]); % Application de la limite sur l'axe du module (dB)
xlabel('Fréquence [kHz]');
ylabel(ax(1), 'Magnitude (dB)');
ylabel(ax(2), 'Phase (rad)');
title('Module et Phase de la réponse fréquentielle');
grid on;

%% 4. Génération des figures D.2 : Coefficients et Temps de propagation de groupe

% Affichage de la réponse impulsionnelle (Coefficients du filtre)
Ns = N + 1;
figure(11); clf;
stem(0:N, b, '--o', "filled", "LineWidth", 2);
xlabel('Échantillon (n)');
ylabel('Amplitude');
title('Coefficients du filtre RIF d''ordre 30');
xlim([0, 30]);
grid on;

% Calcul et affichage du temps de propagation de groupe (Group Delay)
figure(13); clf;
gd = -diff(unwrap(angle(H))) / (2 * pi); % Dérivée de la phase
plot(freq(1:end - 1), gd, 'b', 'LineWidth', 1.5);
xlabel('Fréquence [kHz]');
ylabel('Temps de propagation de groupe (s)');
title('Temps de propagation de groupe');
grid on;

%% 5. Génération de la figure D.3 : Validation pratique par filtrage audio
figure(14); clf;
[music, fs] = audioread('funky.wav'); % Chargement du signal audio source
N_samples = length(music);

% Application du filtre sur le signal audio
tic;
musicF = filter(b, 1, music);
toc;

% Comparaison temporelle et fréquentielle (Spectrogrammes)
subplot(2, 2, 1); 
plot(music);
title('Signal original (Temporel)');

subplot(2, 2, 2); 
specgram(music, 512, Fs/1000); 
ylabel('Fréquence [kHz]'); 
set(gca, 'XTick', []);
title('Spectrogramme original');

subplot(2, 2, 3); 
plot(musicF);
title('Signal filtré (Temporel)');

subplot(2, 2, 4); 
specgram(musicF, 512, Fs/1000); 
ylabel('Fréquence [kHz]'); 
set(gca, 'XTick', []);
title('Spectrogramme filtré');

% Lecture du résultat audio (Normalisé pour éviter la saturation à l'écoute)
sound(musicF / max(abs(musicF)) / 2, Fs);