%% Q4B - Signal temporel OFDM du message "Master ELISE sem2§"
% Pipeline : message -> myMess2ValMat -> myQAMmod -> myOFDMmod -> x(t)

clear; close all;

%% Paramètres
L    = 4;        % bits/symbole (QAM-16)
Fs   = 8000;     % fréquence d'échantillonnage (Hz) - augmentée pour M=36
Tu   = 8e-3;     % durée utile d'un symbole OFDM (s)
Tg   = 2e-3;     % durée du préfixe cyclique (s)
% specN = round(Fs*Tu) = round(8000*0.008) = 64 bins -> M=36 ok (36 < 63)

message = 'Master ELISE sem2§';
fprintf('Message : "%s"  (longueur = %d caractères)\n', message, length(message));

%% Dimensions
M = length(message) * 8 / L;   % 18*8/4 = 36 sous-porteuses
fprintf('M = %d sous-porteuses, specN = %d\n', M, round(Fs*Tu));
assert(M < round(Fs*Tu)-1, 'M trop grand pour specN : augmenter Fs ou Tu');

%% Modulation
valMat  = myMess2ValMat(message, L);
symbols = myQAMmod(valMat, L);
Xtf_mn  = reshape(symbols, M, 1);      % M x 1 (un seul symbole OFDM)
x       = myOFDMmod(Xtf_mn, Fs, Tu, Tg);

%% Affichage
t_ax = (0:length(x)-1) / Fs;

figure('Name','Q4B - Signal OFDM temporel','Position',[100 100 900 400]);
plot(t_ax*1000, real(x), 'b', 'LineWidth', 1.2);
xlabel('Temps (ms)'); ylabel('Amplitude');
title('Signal temporel OFDM — "Master ELISE sem2§" en QAM-16');
grid on;
xlim([0 max(t_ax)*1000]);

saveas(gcf, 'figures/q4b_ofdm.png');

%% Vérification reconstruction sans bruit
Ytf_mn  = myOFDMdemod(x, M, Fs, Tu, Tg);
vals_rx = myQAMdemod(Ytf_mn(:), L);
msg_rx  = myValMat2Mess(vals_rx, L);
fprintf('Message reçu  : "%s"\n', msg_rx);
fprintf('Reconstruction parfaite : %d\n', strcmp(message, msg_rx));

% Sauvegarder les paramètres pour Q4C
save('ofdm_params.mat', 'L', 'Fs', 'Tu', 'Tg', 'message', 'M');