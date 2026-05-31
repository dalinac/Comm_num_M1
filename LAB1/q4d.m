%% Q4D - COFDM avec codage de Hamming(31,26)

clear; close all;

%% Helper : de2bi sans Communications Toolbox
de2bi_custom = @(d, n) fliplr(rem(floor(d(:) * 2.^(-(n-1):0)), 2));
bi2de_custom = @(b) b * (2.^(size(b,2)-1:-1:0))';

%% Paramètres OFDM
L = 4; Fs = 8000; Tu = 8e-3; Tg = 2e-3;

%% Hamming(31,26)
m = 5; k = 26; n = 31;

H = de2bi_custom(1:n, m)';   % 5 x 31

parity_pos = [];
for i = 1:n
    if sum(H(:,i))==1, parity_pos(end+1) = i; end
end
data_pos = setdiff(1:n, parity_pos);

G = zeros(k, n);
G(:, data_pos) = eye(k);
for j = 1:length(parity_pos)
    p = parity_pos(j);
    G(:, p) = mod(H(:, data_pos)' * H(:, p), 2);
end

ham_encode = @(bits) mod(bits * G, 2);

    function dec = ham_decode(rx, H, data_pos, n)
        syn = mod(H * rx', 2);
        pos = 0;
        for bit = 1:size(syn,1)
            pos = pos + syn(bit) * 2^(size(syn,1)-bit);
        end
        if pos > 0 && pos <= n
            rx(pos) = 1 - rx(pos);
        end
        dec = rx(data_pos);
    end

%% Messages
message_ofdm  = 'Master ELISE sem2§';
message_cofdm = 'Master1 ELISE';
M_ofdm = length(message_ofdm)*8/L;

% Bits du message COFDM
bits_msg = reshape(dec2bin(double(message_cofdm),8)'-'0',1,[]);
n_blocks = floor(length(bits_msg)/k);   % 4
bits_msg = bits_msg(1:n_blocks*k);

%% Charger courbe OFDM
load('q4c_results.mat','taux_echec');
taux_ofdm = taux_echec;
SNR_dB_vec = linspace(10, 20, 10);
N_trials   = 20;

%% Boucle COFDM
taux_cofdm = zeros(1, length(SNR_dB_vec));

for idx = 1:length(SNR_dB_vec)
    snr = SNR_dB_vec(idx);
    n_fail = 0;

    for trial = 1:N_trials
        % Encodage
        enc = [];
        for b = 1:n_blocks
            bl  = bits_msg((b-1)*k+1 : b*k);
            enc = [enc, ham_encode(bl)];
        end

        % Bits -> symboles QAM
        pad     = mod(L - mod(length(enc),L), L);
        enc_pad = [enc, zeros(1,pad)];
        enc_mat = reshape(enc_pad, L, [])';
        vals    = bi2de_custom(enc_mat);
        M_c     = length(vals);
        syms    = myQAMmod(vals', L);
        Xtf     = reshape(syms, M_c, 1);
        x       = myOFDMmod(Xtf, Fs, Tu, Tg);

        % Canal AWGN
        y = myAwgn(x, snr);

        % Démodulation
        Ytf     = myOFDMdemod(y, M_c, Fs, Tu, Tg);
        vals_rx = myQAMdemod(Ytf(:), L);

        % Symboles -> bits
        rx_bits = [];
        for s = 1:length(vals_rx)
            b = dec2bin(vals_rx(s), L) - '0';
            rx_bits = [rx_bits, b];
        end
        rx_bits = rx_bits(1:n_blocks*n);

        % Décodage Hamming
        dec = [];
        for b = 1:n_blocks
            bl_rx = rx_bits((b-1)*n+1 : b*n);
            dec   = [dec, ham_decode(bl_rx, H, data_pos, n)];
        end

        % Bits -> caractères
        chars  = zeros(1, length(dec)/8);
        for c = 1:length(chars)
            chars(c) = bin2dec(num2str(dec((c-1)*8+1:c*8)));
        end
        msg_rx = char(chars);

        if ~strcmp(message_cofdm, msg_rx), n_fail = n_fail+1; end
    end

    taux_cofdm(idx) = n_fail/N_trials*100;
    fprintf('SNR=%5.1f dB  COFDM: %d/%d (%.0f%%)\n', ...
             snr, n_fail, N_trials, taux_cofdm(idx));
end

%% Figure
figure('Name','Q4D - OFDM vs COFDM','Position',[100 100 700 450]);
plot(SNR_dB_vec, taux_ofdm,  'b-o','LineWidth',2,'MarkerSize',7,'DisplayName','OFDM seul');
hold on;
plot(SNR_dB_vec, taux_cofdm, 'r-s','LineWidth',2,'MarkerSize',7,'DisplayName','COFDM Hamming(31,26)');
xlabel('SNR (dB)'); ylabel('Taux d''échec (%)');
title('OFDM vs COFDM — Canal AWGN');
ylim([0 105]); grid on; legend('Location','northeast');
xticks(10:1:20);
mkdir('figures')
saveas(gcf,'figures/q4d_cofdm.png');
save('q4d_results.mat','SNR_dB_vec','taux_ofdm','taux_cofdm');
fprintf('Q4D terminé.\n');