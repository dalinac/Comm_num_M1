%% Q4C - Taux d'échec OFDM en canal AWGN (SNR 10 à 20 dB)

clear; close all;

%% Paramètres (cohérents avec Q4B)
L       = 4;
Fs      = 8000;
Tu      = 8e-3;
Tg      = 2e-3;
message = 'Master ELISE sem2§';
M       = length(message) * 8 / L;   % 36

SNR_dB_vec = linspace(10, 20, 10);
N_trials   = 20;

taux_echec = zeros(1, length(SNR_dB_vec));

for idx = 1:length(SNR_dB_vec)
    snr    = SNR_dB_vec(idx);
    n_fail = 0;
    for trial = 1:N_trials
        valMat  = myMess2ValMat(message, L);
        symbols = myQAMmod(valMat, L);
        Xtf     = reshape(symbols, M, 1);
        x       = myOFDMmod(Xtf, Fs, Tu, Tg);

        y = myAwgn(x, snr);

        Ytf    = myOFDMdemod(y, M, Fs, Tu, Tg);
        vals_rx= myQAMdemod(Ytf(:), L);
        msg_rx = myValMat2Mess(vals_rx, L);

        if ~strcmp(message, msg_rx)
            n_fail = n_fail + 1;
        end
    end
    taux_echec(idx) = (n_fail / N_trials) * 100;
    fprintf('SNR = %5.1f dB  ->  echecs = %d/%d  (%.0f%%)\n', ...
             snr, n_fail, N_trials, taux_echec(idx));
end

figure('Name','Q4C - BER OFDM AWGN','Position',[100 100 700 450]);
plot(SNR_dB_vec, taux_echec, 'b-o', 'LineWidth', 2, 'MarkerSize', 7);
xlabel('SNR (dB)'); ylabel('Taux d''échec (%)');
title('OFDM QAM-16 — Taux d''échec vs SNR (canal AWGN)');
ylim([0 105]); grid on;
xticks(10:1:20);

saveas(gcf, 'figures/q4c_ber.png');
save('q4c_results.mat', 'SNR_dB_vec', 'taux_echec');
fprintf('Q4C terminé.\n');