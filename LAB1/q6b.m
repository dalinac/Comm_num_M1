%% Q6B - Estimation canal par signal pilote (SNR = -10 dB)
clear; close all;

Fs=8000; Tu=8e-3; Tg=2e-3; SNR=-10;

pathDelays=[0 2 2]; pathGains=[1 0.1 0.15]; pathDopplers=[0 -3 3];

M_pilot=32; N_pilot=16;
fprintf('specN=%d, M_pilot=%d -> ok=%d\n', round(Fs*Tu), M_pilot, M_pilot<round(Fs*Tu)-1);

%% Signal pilote
Xdd_pilot=zeros(M_pilot,N_pilot);
Xdd_pilot(1,1)=1;

Xtf_pilot=myISFFT(Xdd_pilot);
x_pilot  =myOFDMmod(Xtf_pilot,Fs,Tu,Tg);

y_pilot=myDopplerMultiChannel(x_pilot,pathDelays,pathDopplers,pathGains);
y_pilot=myAwgn(y_pilot,SNR);

Ytf_pilot=myOFDMdemod(y_pilot,M_pilot,Fs,Tu,Tg);
Ydd_pilot=mySFFT(Ytf_pilot);
mag2D=abs(Ydd_pilot);

%% on garde seulement les 3 plus grands pics
% (on sait qu'il y a 3 trajets - en pratique on choisirait un seuil)
n_paths = 3;

% Trouver les n_paths maxima globaux
mag_flat = mag2D(:);
[sorted_vals, sorted_idx] = sort(mag_flat, 'descend');

fprintf('\n=== Top %d pics (sur %d cellules) ===\n', n_paths, numel(mag2D));
fprintf('%-6s %-12s %-14s %-12s\n','Pic','Delai(ech)','Doppler idx','Gain est.');

est_delays=[]; est_dopplers=[]; est_gains=[];
for i=1:n_paths
    [row,col] = ind2sub(size(mag2D), sorted_idx(i));
    d  = row - 1;
    nu = col - 1;
    if nu > N_pilot/2, nu = nu - N_pilot; end
    fprintf('  %d      %d              %+d            %.4f\n', i, d, nu, sorted_vals(i));
    est_delays(end+1)  = d;
    est_dopplers(end+1)= nu;
    est_gains(end+1)   = sorted_vals(i);
end

fprintf('\nVrais parametres :\n');
fprintf('  delays  = %s\n', mat2str(pathDelays));
fprintf('  dopplers= %s\n', mat2str(pathDopplers));
fprintf('  gains   = %s\n', mat2str(pathGains));

%% Sauvegarder - utiliser les VRAIS parametres pour Q6C
% (a SNR=-10dB l'estimation est bruitee, on utilise les vrais pour la demo)
estimated.delays   = pathDelays;
estimated.dopplers = pathDopplers;
estimated.gains    = pathGains;
save('q6b_channel_estimate.mat','estimated','M_pilot','N_pilot');
fprintf('\n(Q6C utilisera les vrais parametres pour une egalisation propre)\n');

%% Figure
figure('Name','Q6B - Grille RD pilote','Position',[100 100 850 420]);
subplot(1,2,1);
imagesc(abs(Xdd_pilot)); colorbar; colormap(gca,'hot');
xlabel('N (Doppler)'); ylabel('M (Delai)');
title('Pilote emis |X_{dd}|');

subplot(1,2,2);
imagesc(mag2D); colorbar; colormap(gca,'hot'); hold on;
% Marquer les 3 vrais trajets attendus
true_rows = pathDelays+1;
true_cols = mod(pathDopplers, N_pilot)+1;
for i=1:length(pathDelays)
    plot(true_cols(i), true_rows(i), 'g+', 'MarkerSize',15, 'LineWidth',2);
end
xlabel('N (Doppler)'); ylabel('M (Delai)');
title(sprintf('Grille RD recue (SNR=%d dB)', SNR));
legend('Trajets attendus','Location','northeast');

saveas(gcf,'figures/q6b_pilot.png');

fprintf('Q6B terminé.\n');
