% =========================================================================
%  myGetFIC_complet.m  -  Pipeline Global de Synchronisation DAB Mode I
%  -----------------------------------------------------------------------
%  Fusion intégrale des analyses de performances, corrections et graphiques
% =========================================================================
clc; clear all; close all;

%% --- 1) Chargement du signal IQ et paramètres du Mode I -----------------
fprintf('--- Section 1 : Chargement et Initialisation ---\n');
filename = 'ELISE_16s_Ncomp.iq';
Signal_clean = myLoadIQ(filename)';

% Application de la convention de phase inversée
Signal_clean = -real(Signal_clean) + 1i*imag(Signal_clean);
Signal_clean = Signal_clean(1:3200000);

startFrame = myGetFrameSart(Signal_clean);
sf1 = startFrame(1);

Fs    = 2048000;       Rsym  = 76;     K     = 1536;
Tu    = 2048/Fs;       Tsym  = 2552/Fs;
N_fft = 2048;          N_cp  = 504;    N_sym = N_fft + N_cp;
Fu    = Fs/N_fft;      % Espacement inter-porteuses = 1000 Hz
intLmode1_fn = 'freqInterleavingMode1.mat';

t  = (0:length(Signal_clean)-1) / Fs;
Ps = mean(abs(Signal_clean).^2);

active_left  = N_fft/2 - K/2 + 1 : N_fft/2;
active_right = N_fft/2 + 2       : N_fft/2 + K/2 + 1;

%% --- 2) Évaluation de référence (Baseline sans perturbation) -----------
fprintf('\n--- Section 2 : Baseline (Signal d''origine) ---\n');
N_frames = 16;
crc_baseline = zeros(1, N_frames);

for it = 1:N_frames
    sf_it = sf1 + (it-1)*196608;
    if sf_it + Rsym*N_sym > length(Signal_clean); break; end
    ff = SymbolFFT(Signal_clean, 1, [sf_it], Rsym, K, Tsym*Fs, 0, Tu*Fs);
    Dt = myFreqDeInterleave(intLmode1_fn, ff);
    crc_baseline(it) = getFICscore(Rsym, K, Dt);
end
fprintf('Bilan Baseline : %d/%d FIB valides\n', sum(crc_baseline), 12*N_frames);

%% --- 3) Modélisation du canal & Suivi de Phase FFS ----------------------
fprintf('\n--- Section 3 : Analyse Temporelle FFS ---\n');
df_sub_test = 350; % Exemple de dérive fine (Hz)
Sd_ffs = Signal_clean .* exp(1j*2*pi*df_sub_test*t);

phi_raw = zeros(Rsym, 1);
for j = 1:Rsym
    idx = sf1 + (j-1)*N_sym;
    cp   = Sd_ffs(idx         : idx + N_cp - 1);
    tail = Sd_ffs(idx + N_fft : idx + N_fft + N_cp - 1);
    phi_raw(j) = angle(sum(conj(cp) .* tail));
end

% Tracé du suivi de phase pour expliquer le mécanisme d'unwrap
fig1 = figure('Name', 'Suivi de la phase FFS', 'Position', [100 100 800 400]);
plot(1:Rsym, phi_raw, 'b-x', 'LineWidth', 1.2); hold on;
plot(1:Rsym, unwrap(phi_raw), 'r--o', 'LineWidth', 1.2);
xlabel('Index du symbole OFDM'); ylabel('Phase (rad)');
title(sprintf('Évolution de la phase du préfixe cyclique (\\Delta f = %d Hz)', df_sub_test));
legend('Phase brute (repliée)', 'Phase corrigée (unwrapped)'); grid on;

%% --- 4) Balayage 1D de la dérive fine (FFS vs CRC) ---------------------
fprintf('\n--- Section 4 : Balayage Dérive Fine ---\n');
df_sweep_FFS = -600:50:600;
crc_raw_ffs = zeros(size(df_sweep_FFS));
crc_cor_ffs = zeros(size(df_sweep_FFS));

for d = 1:length(df_sweep_FFS)
    df = df_sweep_FFS(d);
    Sd = Signal_clean .* exp(1j*2*pi*df*t);

    % Sans correction
    ff = SymbolFFT(Sd, 1, [sf1], Rsym, K, Tsym*Fs, 0, Tu*Fs);
    Dt = myFreqDeInterleave(intLmode1_fn, ff);
    crc_raw_ffs(d) = getFICscore(Rsym, K, Dt);

    % Avec correction
    phi_est = zeros(Rsym, 1);
    for j = 1:Rsym
        idx = sf1 + (j-1)*N_sym;
        cp   = Sd(idx         : idx + N_cp - 1);
        tail = Sd(idx + N_fft : idx + N_fft + N_cp - 1);
        phi_est(j) = angle(sum(conj(cp) .* tail));
    end
    df_est = mean(unwrap(phi_est)) * Fs / (2*pi*N_fft);
    Sc = Sd .* exp(-1j*2*pi*df_est*t);

    ff_c = SymbolFFT(Sc, 1, [sf1], Rsym, K, Tsym*Fs, 0, Tu*Fs);
    Dt_c = myFreqDeInterleave(intLmode1_fn, ff_c);
    crc_cor_ffs(d) = getFICscore(Rsym, K, Dt_c);
end

fig2 = figure('Name', 'Robustesse FFS 1D', 'Position', [150 150 800 400]);
plot(df_sweep_FFS, crc_raw_ffs, 'r-o', 'LineWidth', 1.5); hold on;
plot(df_sweep_FFS, crc_cor_ffs, 'b--s', 'LineWidth', 1.5);
xlabel('Dérive fréquentielle injectée \Delta f (Hz)'); ylabel('Score CRC du FIB');
title('Limites de décodage de la FFS (Sans Bruit)');
legend('Sans correction', 'Avec correction FFS'); grid on; ylim([-0.5 12.5]);

%% --- 5) Modélisation du canal & Recherche d'Énergie CFO ----------------
fprintf('\n--- Section 5 : Analyse du Spectre CFO ---\n');
k_multi_test = 8; % Décalage de 8 porteuses (8000 Hz)
Sd_cfo = Signal_clean .* exp(1j*2*pi*k_multi_test*Fu*t);

sym = Sd_cfo(sf1 + N_cp : sf1 + N_cp + N_fft - 1);
Y = fftshift(fft(sym));
k_search = -20:20;
energies_test = zeros(size(k_search));

for q = 1:length(k_search)
    kk = k_search(q);
    idx_l = active_left + kk; idx_r = active_right + kk;
    energies_test(q) = sum(abs(Y(idx_l)).^2) + sum(abs(Y(idx_r)).^2);
end

fig3 = figure('Name', 'Spectre d''Énergie CFO', 'Position', [200 200 800 400]);
plot(k_search, energies_test, '-o', 'LineWidth', 1.5); hold on;
[~, idx_max] = max(energies_test);
plot(k_search(idx_max), energies_test(idx_max), 'ro', 'MarkerSize', 10, 'LineWidth', 2);
xlabel('Décalage de porteuses (k)'); ylabel('Énergie mesurée sur les porteuses actives');
title(sprintf('Profil de recherche CFO (Décalage injecté = %d)', k_multi_test));
legend('Énergie calculée', 'Maximum détecté'); grid on;

%% --- 6) Balayage 1D de la dérive grossière (CFO vs CRC) ----------------
fprintf('\n--- Section 6 : Balayage Dérive Grossière ---\n');
k_sweep_CFO = -15:15;
crc_raw_cfo = zeros(size(k_sweep_CFO));
crc_cor_cfo = zeros(size(k_sweep_CFO));

for d = 1:length(k_sweep_CFO)
    k_val = k_sweep_CFO(d);
    Sd = Signal_clean .* exp(1j*2*pi*(k_val*Fu)*t);

    % Sans correction
    ff = SymbolFFT(Sd, 1, [sf1], Rsym, K, Tsym*Fs, 0, Tu*Fs);
    Dt = myFreqDeInterleave(intLmode1_fn, ff);
    crc_raw_cfo(d) = getFICscore(Rsym, K, Dt);

    % Avec correction
    sym = Sd(sf1 + N_cp : sf1 + N_cp + N_fft - 1);
    Y_block = fftshift(fft(sym));
    energies = zeros(size(k_search));
    for q = 1:length(k_search)
        kk = k_search(q);
        idx_l = active_left + kk; idx_r = active_right + kk;
        energies(q) = sum(abs(Y_block(idx_l)).^2) + sum(abs(Y_block(idx_r)).^2);
    end
    [~, q_max] = max(energies);
    k_est = k_search(q_max);
    Sc = Sd .* exp(-1j*2*pi*(k_est*Fu)*t);

    ff_c = SymbolFFT(Sc, 1, [sf1], Rsym, K, Tsym*Fs, 0, Tu*Fs);
    Dt_c = myFreqDeInterleave(intLmode1_fn, ff_c);
    crc_cor_cfo(d) = getFICscore(Rsym, K, Dt_c);
end

fig4 = figure('Name', 'Robustesse CFO 1D', 'Position', [250 250 800 400]);
plot(k_sweep_CFO, crc_raw_cfo, 'r-o', 'LineWidth', 1.5); hold on;
plot(k_sweep_CFO, crc_cor_cfo, 'b--s', 'LineWidth', 1.5);
xlabel('Dérive grossière injectée (Nombre de porteuses)'); ylabel('Score CRC du FIB');
title('Limites de décodage de la CFO (Sans Bruit)');
legend('Sans correction', 'Avec correction CFO'); grid on; ylim([-0.5 12.5]);

%% --- 7) Caractéristiques 2D avec bruit AWGN (Analyse de Seuil) ----------
fprintf('\n--- Section 7 : Simulations de robustesse sous Bruit (2D) ---\n');
SNR_list = [inf, 10, 5, 2, 0];
df_range_FFS = -600:50:600;
k_range_CFO = -15:15;

crc_FFS_2D = zeros(length(SNR_list), length(df_range_FFS));
crc_CFO_2D = zeros(length(SNR_list), length(k_range_CFO));

for s = 1:length(SNR_list)
    SNR = SNR_list(s); rng(42);
    if isinf(SNR)
        Sn = Signal_clean;
    else
        Pn = Ps / 10^(SNR/10);
        Sn = Signal_clean + sqrt(Pn/2) * (randn(size(Signal_clean)) + 1j*randn(size(Signal_clean)));
    end

    % Évaluation FFS vs SNR
    for d = 1:length(df_range_FFS)
        df = df_range_FFS(d);
        Sd = Sn .* exp(1j*2*pi*df*t);
        phi_est = zeros(Rsym, 1);
        for j = 1:Rsym
            idx = sf1 + (j-1)*N_sym;
            cp   = Sd(idx         : idx + N_cp - 1);
            tail = Sd(idx + N_fft : idx + N_fft + N_cp - 1);
            phi_est(j) = angle(sum(conj(cp) .* tail));
        end
        df_est = mean(unwrap(phi_est)) * Fs / (2*pi*N_fft);
        Sc = Sd .* exp(-1j*2*pi*df_est*t);
        ff = SymbolFFT(Sc, 1, [sf1], Rsym, K, Tsym*Fs, 0, Tu*Fs);
        Dt = myFreqDeInterleave(intLmode1_fn, ff);
        crc_FFS_2D(s, d) = getFICscore(Rsym, K, Dt);
    end

    % Évaluation CFO vs SNR
    for d = 1:length(k_range_CFO)
        k_val = k_range_CFO(d);
        Sd = Sn .* exp(1j*2*pi*(k_val*Fu)*t);
        sym = Sd(sf1 + N_cp : sf1 + N_cp + N_fft - 1);
        Y_block = fftshift(fft(sym));
        energies = zeros(size(k_search));
        for q = 1:length(k_search)
            kk = k_search(q);
            idx_l = active_left + kk; idx_r = active_right + kk;
            energies(q) = sum(abs(Y_block(idx_l)).^2) + sum(abs(Y_block(idx_r)).^2);
        end
        [~, q_max] = max(energies);
        k_est = k_search(q_max);
        Sc = Sd .* exp(-1j*2*pi*(k_est*Fu)*t);
        ff = SymbolFFT(Sc, 1, [sf1], Rsym, K, Tsym*Fs, 0, Tu*Fs);
        Dt = myFreqDeInterleave(intLmode1_fn, ff);
        crc_CFO_2D(s, d) = getFICscore(Rsym, K, Dt);
    end
end

% Tracés 2D
fig5 = figure('Name', 'Seuils FFS vs SNR', 'Position', [300 300 800 450]);
colors = lines(length(SNR_list)); hold on;
for s = 1:length(SNR_list)
    if isinf(SNR_list(s))
        lbl = 'Sans Bruit';
    else
        lbl = sprintf('SNR = %d dB', SNR_list(s));
    end
    plot(df_range_FFS, crc_FFS_2D(s,:), '-o', 'Color', colors(s,:), 'LineWidth', 1.5, 'DisplayName', lbl);
end
xlabel('Dérive sub-symbole \Delta f (Hz)'); ylabel('Score CRC');
title('Caractéristique limite de la FFS sous bruit'); legend('Location', 'south'); grid on; ylim([-0.5 12.5]);

fig6 = figure('Name', 'Seuils CFO vs SNR', 'Position', [350 350 800 450]);
hold on;
for s = 1:length(SNR_list)
    if isinf(SNR_list(s))
        lbl = 'Sans Bruit';
    else
        lbl = sprintf('SNR = %d dB', SNR_list(s));
    end
    plot(k_range_CFO, crc_CFO_2D(s,:), '-s', 'Color', colors(s,:), 'LineWidth', 1.5, 'DisplayName', lbl);
end
xlabel('Dérive grossière (k sous-porteuses)'); ylabel('Score CRC');
title('Caractéristique limite de la CFO sous bruit'); legend('Location', 'south'); grid on; ylim([-0.5 12.5]);


%% --- 8) Pipeline Complet de Réception (CFO + FFS) -----------------------
fprintf('\n--- Section 8 : Pipeline Complet (Spécification 50 ppm) ---\n');
% Spécification de l'oscillateur local : 50 ppm à 230 MHz
df_max_spec = 50e-6 * 230e6; % 11500 Hz (11 kHz grossier + 500 Hz fin)
df_injectee_totale = 11500;

SNR_fine_sweep = 0:1:12;
crc_pipeline = zeros(size(SNR_fine_sweep));

fprintf('Simulation du récepteur complet (Dérive = %d Hz)\n', df_injectee_totale);
fprintf('SNR (dB) | k estimé | df fin (Hz) | Total estimé (Hz) | Score CRC\n');
fprintf('---------+----------+-------------+-------------------+----------\n');

for s = 1:length(SNR_fine_sweep)
    SNR = SNR_fine_sweep(s); rng(42);
    Pn = Ps / 10^(SNR/10);
    noise = sqrt(Pn/2) * (randn(size(Signal_clean)) + 1j*randn(size(Signal_clean)));

    % Application simultanée des perturbations
    Sd = (Signal_clean + noise) .* exp(1j*2*pi*df_injectee_totale*t);

    % Étape 1 : Synchronisation Grossière (CFO)
    sym = Sd(sf1 + N_cp : sf1 + N_cp + N_fft - 1);
    Y_block = fftshift(fft(sym));
    energies = zeros(size(k_search));
    for q = 1:length(k_search)
        kk = k_search(q);
        idx_l = active_left + kk; idx_r = active_right + kk;
        energies(q) = sum(abs(Y_block(idx_l)).^2) + sum(abs(Y_block(idx_r)).^2);
    end
    [~, q_max] = max(energies);
    k_est = k_search(q_max);
    df_cfo_est = k_est * Fu;

    % Correction CFO intermédiaire
    S_inter = Sd .* exp(-1j*2*pi*df_cfo_est*t);

    % Étape 2 : Synchronisation Fine (FFS)
    phi_est = zeros(Rsym, 1);
    for j = 1:Rsym
        idx = sf1 + (j-1)*N_sym;
        cp   = S_inter(idx         : idx + N_cp - 1);
        tail = S_inter(idx + N_fft : idx + N_fft + N_cp - 1);
        phi_est(j) = angle(sum(conj(cp) .* tail));
    end
    df_ffs_est = mean(unwrap(phi_est)) * Fs / (2*pi*N_fft);

    % Correction Finale
    df_total_est = df_cfo_est + df_ffs_est;
    Sc = Sd .* exp(-1j*2*pi*df_total_est*t);

    % Décodage
    ff = SymbolFFT(Sc, 1, [sf1], Rsym, K, Tsym*Fs, 0, Tu*Fs);
    Dt = myFreqDeInterleave(intLmode1_fn, ff);
    crc_pipeline(s) = getFICscore(Rsym, K, Dt);

    fprintf('   %2d    |    %2d    |   %7.1f   |      %6.1f       |  %2d/12\n', ...
            SNR, k_est, df_ffs_est, df_total_est, crc_pipeline(s));
end

fig7 = figure('Name', 'Pipeline Complet Récepteur', 'Position', [400 400 800 400]);
plot(SNR_fine_sweep, crc_pipeline, 'b-o', 'LineWidth', 2, 'MarkerFaceColor', 'b'); hold on;
plot(SNR_fine_sweep, 12*ones(size(SNR_fine_sweep)), 'g--', 'LineWidth', 1);
xlabel('Rapport Signal sur Bruit - SNR (dB)'); ylabel('Nombre de FIB valides (0..12)');
title('Performance du récepteur complet face aux spécifications constructeur (50 ppm @ 230 MHz)');
grid on; ylim([-0.5 12.5]); legend('Chaîne CFO + FFS', 'Objectif Décodage Parfait');

fprintf('\nExécution terminée ! Toutes les sections et figures sont prêtes.\n');
