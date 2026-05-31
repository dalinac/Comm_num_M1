%% ── Paramètres DAB-like ──────────────────────────────────
fs          = 2.048e6;   % fréquence d'échantillonnage (Hz)
N_fft       = 2048;      % longueur FFT (sans préfixe cyclique)
N_cp        = 504;       % longueur préfixe cyclique
N_sym       = N_fft + N_cp;  % longueur d'un symbole OFDM complet
num_symbols = 10;        % symboles par trame à utiliser
fc          = 230e6;     % MODIF Q1: Fréquence de l'oscillateur (230 MHz)
alpha       = 0.3;       % facteur IIR (comme dans le bloc GNU Radio)

% --- MODIF Q1 : PARAMÈTRES DU CANAL ---
delta_f_sub   = 150;                % 1. Dérive sub-symbole (doit être < 500 Hz)
delta_f_multi = 50e-6 * fc;         % 2. Dérive multi-symbole (50 ppm de 230 MHz = 11500 Hz)
delta_f_total = delta_f_sub + delta_f_multi; % Dérive totale appliquée au signal
SNR_dB        = 20;                 % 3. Rapport signal sur bruit (AWGN)
% --------------------------------------

%% ── 1. Génération du signal ──────────────────────────────
N_total = N_sym * num_symbols;
t = (0:N_total-1)' / fs;

% Signal OFDM simplifié : bruit complexe (simule les sous-porteuses)
rng(42);
s_tx = (randn(N_total,1) + 1j*randn(N_total,1)) / sqrt(2);

% --- MODIF Q1 : APPLICATION DU CANAL ---
% Le récepteur échantillonne avec la dérive TOTALE
s_rx = s_tx .* exp(1j * 2*pi * delta_f_total * t);

% Ajout du Bruit Blanc Gaussien Additif (AWGN)
s_rx = awgn(s_rx, SNR_dB, 'measured');
% ---------------------------------------
