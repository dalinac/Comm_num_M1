%% TP5 : Égalisation du canal de transmission OFDM
clearvars; close all;
rng(42);

Fs=2048000; K=1536; Rsym=76; Ncp=504;
Md=256; Mp=4; att=0.25;
fc=194.4e6; c0=3e8;
v_def=100; d_def=100;
fd_def = v_def/3.6 * fc/c0;
SNR4=25; M4=6;

rng(1);
data_raw = randi(Md, K, Rsym) - 1;
data_qam = my_qammod(data_raw, Md);

v_arr = [0, 10, 50, 100, 200, 300, 500, 800, 1200];
d_arr = [0, 50, 100, 200, 300, 400, 504, 600, 800, 1000];
nv = numel(v_arr); nd = numel(d_arr);

steps = [2, 3, 4, 6, 8];
lbls  = {'4x plus (pas=2)', '~2x plus (pas=3)', 'Reference (pas=4)', '~2x moins (pas=6)', '4x moins (pas=8)'};
cols  = {[0 0.6 0], [0 0.9 0.3], [0 0 1], [1 0.5 0], [1 0 0]};

SER_sv = zeros(5,nv); SER_sd = zeros(5,nd);

for si = 1:5
    s = steps(si);
    [pl, dl, pq, tx_s] = make_grid_tp5(data_qam, K, Rsym, Ncp, Mp, s);
    t_s = (0:numel(tx_s)-1)'/Fs;
    for vi = 1:nv
        fd = v_arr(vi)/3.6*fc/c0;
        rx = mp_channel_tp5(tx_s, att, d_def, fd, t_s);
        SER_sv(si,vi) = equalize_ser_tp5(rx, K, Ncp, Rsym, pl, dl, pq, data_raw, Md, s);
    end
    for di = 1:nd
        rx = mp_channel_tp5(tx_s, att, d_arr(di), fd_def, t_s);
        SER_sd(si,di) = equalize_ser_tp5(rx, K, Ncp, Rsym, pl, dl, pq, data_raw, Md, s);
    end
    fprintf('pas=%d ok\n', s);
end

[pl4,dl4,pq4,tx4] = make_grid_tp5(data_qam, K, Rsym, Ncp, Mp, 4);
t4 = (0:numel(tx4)-1)'/Fs;
SER_q4v = zeros(1,nv); SER_q4d = zeros(1,nd);
for vi=1:nv
    fd = v_arr(vi)/3.6*fc/c0;
    rx_c = mp_channel_tp5(tx4, att, d_def, fd, t4);
    SER_q4v(vi) = ser_fixed_tp5(rx_c, K, Ncp, Rsym, pl4, dl4, pq4, data_raw, Md, 4, M4, SNR4);
end
for di=1:nd
    rx_c = mp_channel_tp5(tx4, att, d_arr(di), fd_def, t4);
    SER_q4d(di) = ser_fixed_tp5(rx_c, K, Ncp, Rsym, pl4, dl4, pq4, data_raw, Md, 4, M4, SNR4);
end
fprintf('Q4 ok\n');

SER_q5v = zeros(1,nv); SER_q5d = zeros(1,nd);
for vi=1:nv
    fd = v_arr(vi)/3.6*fc/c0;
    SER_q5v(vi) = ser_shift_tp5(data_qam, data_raw, K, Rsym, Ncp, Mp, Md, 4, M4, SNR4, att, d_def, fd, Fs);
end
for di=1:nd
    SER_q5d(di) = ser_shift_tp5(data_qam, data_raw, K, Rsym, Ncp, Mp, Md, 4, M4, SNR4, att, d_arr(di), fd_def, Fs);
end
fprintf('Q5 ok\n');

flr = @(x) max(x, 1e-6);

figure(1); clf; hold on; grid on;
for si=1:3
    semilogy(v_arr, flr(SER_sv(si,:)), '-o', 'Color', cols{si}, 'LineWidth',1.8, ...
             'MarkerFaceColor', cols{si}, 'DisplayName', lbls{si});
end
xlabel('Vitesse (km/h)'); ylabel('SER');
title('Q1+Q3 : SER vs vitesse vehicule'); legend('Location','northwest'); ylim([1e-5 1]);

figure(2); clf; hold on; grid on;
for si=1:3
    semilogy(d_arr, flr(SER_sd(si,:)), '-o', 'Color', cols{si}, 'LineWidth',1.8, ...
             'MarkerFaceColor', cols{si}, 'DisplayName', lbls{si});
end
xline(Ncp, 'k--', sprintf('CP=%d', Ncp));
xlabel('Delai (samples)'); ylabel('SER');
title('Q2+Q3 : SER vs delai multi-trajet'); legend('Location','northwest'); ylim([1e-5 1]);

figure(3); clf; hold on; grid on;
semilogy(v_arr, flr(SER_sv(2,:)), 'b-o', 'LineWidth',1.8, 'DisplayName','Q1 sans bruit');
semilogy(v_arr, flr(SER_q4v),     'g-s', 'LineWidth',1.8, 'DisplayName',sprintf('Q4 SNR=%ddB m=%d fixes',SNR4,M4));
semilogy(v_arr, flr(SER_q5v),     'r-^', 'LineWidth',1.8, 'DisplayName',sprintf('Q5 SNR=%ddB m=%d variables',SNR4,M4));
xlabel('Vitesse (km/h)'); ylabel('SER');
title('Q4-Q5 : SER vs vitesse - estimation H multi-trames'); legend('Location','northwest'); ylim([1e-5 1]);

figure(4); clf; hold on; grid on;
semilogy(d_arr, flr(SER_sd(2,:)), 'b-o', 'LineWidth',1.8, 'DisplayName','Q2 sans bruit');
semilogy(d_arr, flr(SER_q4d),     'g-s', 'LineWidth',1.8, 'DisplayName',sprintf('Q4 SNR=%ddB m=%d fixes',SNR4,M4));
semilogy(d_arr, flr(SER_q5d),     'r-^', 'LineWidth',1.8, 'DisplayName',sprintf('Q5 SNR=%ddB m=%d variables',SNR4,M4));
xline(Ncp, 'k--', sprintf('CP=%d',Ncp));
xlabel('Delai (samples)'); ylabel('SER');
title('Q4-Q5 : SER vs delai - estimation H multi-trames'); legend('Location','northwest'); ylim([1e-5 1]);

fprintf('TP5 termine - 4 figures.\n');
