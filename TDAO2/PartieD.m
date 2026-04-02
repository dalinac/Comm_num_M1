clc; clear; close all;

% Paramètres de simulation
N = 100000; % Longueur de la source (bits)
segment_size = 1000; % Taille du segment pour le BER local
num_segments = N / segment_size;
window_size = 10; % Taille de la fenêtre glissante

% Source d'information (variables i.i.d.)
tx_bits = randi([0 1], 1, N);

% Modélisation du canal non stationnaire (50 états de 0 à 10%)
% Fading par blocs : chaque état est maintenu sur 2 segments consécutifs
taux_uniques = rand(1, 50) * 0.1;
ber_cible = repelem(taux_uniques, 2);

rx_bits = tx_bits;
inst_ber = zeros(1, num_segments);

% Simulation du canal binaire symétrique (BSC)
for i = 1:num_segments
    idx_start = (i - 1) * segment_size + 1;
    idx_end = i * segment_size;
    
    % Application des erreurs (Loi de Bernoulli paramétrée par l'état du canal)
    masque_erreurs = rand(1, segment_size) < ber_cible(i);
    rx_bits(idx_start:idx_end) = xor(tx_bits(idx_start:idx_end), masque_erreurs);
    
    % BER empirique instantané
    inst_ber(i) = sum(masque_erreurs) / segment_size;
end

% Extraction des moments statistiques locaux
mean_ber = movmean(inst_ber, window_size);
var_ber = movvar(inst_ber, window_size);
std_ber = sqrt(var_ber); % Enveloppe de dispersion (1 écart-type)

% Affichage Graphique
figure('Name', 'Partie D : Variance du BER', 'Position', [100 100 900 600]);

% Subplot 1 : Dynamiques d'erreurs
subplot(2, 1, 1);
stairs(1:num_segments, inst_ber, 'r', 'LineWidth', 1.2); hold on;
plot(1:num_segments, mean_ber, 'b', 'LineWidth', 2);

% Enveloppe de dispersion (+/- 1 écart-type)
plot(1:num_segments, mean_ber + std_ber, 'k', 'LineWidth', 1.2);
plot(1:num_segments, mean_ber - std_ber, 'k', 'LineWidth', 1.2);
hold off;

title('Instantaneous BER Variation and Moving Average', 'FontWeight', 'bold');
xlabel('Segment Index');
ylabel('Bit Error Rate (BER)');
legend('Instantaneous BER', 'Moving Average', 'Location', 'northeast');
grid on;
xlim([0 100]);
ylim([-0.01 0.12]);

% Subplot 2 : Inspection temporelle fine
subplot(2, 1, 2);
idx_plot = 41560:41680;

plot(idx_plot, tx_bits(idx_plot), 'k', 'LineWidth', 1.5); hold on;
plot(idx_plot, rx_bits(idx_plot), 'r', 'LineWidth', 1.2);
hold off;

title('Binary Source vs Received Sequence', 'FontWeight', 'bold');
xlabel('Bit Index');
ylabel('Bit Value');
legend('Original Sequence', 'Received Sequence (With Errors)', 'Location', 'northeast');
grid on;
ylim([-0.2 1.5]);