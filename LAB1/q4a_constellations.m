%% Q4A - Constellation QAM-16
% Afficher la constellation et toutes les N(N-1) transitions possibles

clear; close all;

L = 4;   % bits par symbole => QAM-16
M = 2^L; % 16 points

%% Génération de toutes les transitions possibles
% Pour voir les N(N-1) transitions : séquence de tous les passages possibles entre les M symboles
vals_all = [];
for i = 0:M-1
    for j = 0:M-1
        if i ~= j
            vals_all = [vals_all, i, j];
        end
    end
end

constellation_all = myQAMmod(vals_all, L);

% Points de la constellation seuls
pts = myQAMmod(0:M-1, L);

%% Figure
figure('Name','Q4A - Constellation QAM-16','Position',[100 100 600 600]);

% Tracer les transitions
for k = 1:2:length(constellation_all)-1
    x = [real(constellation_all(k)), real(constellation_all(k+1))];
    y = [imag(constellation_all(k)), imag(constellation_all(k+1))];
    plot(x, y, 'b-', 'LineWidth', 0.3, 'Color', [0.6 0.6 1]); hold on;
end

% Tracer les points de la constellation
plot(real(pts), imag(pts), 'ko', 'MarkerFaceColor','r', 'MarkerSize', 10);

% Labels des symboles
for k = 0:M-1
    text(real(pts(k+1))+0.05, imag(pts(k+1))+0.05, num2str(k), 'FontSize', 8);
end

grid on; axis equal;
xlabel('I (In-phase)'); ylabel('Q (Quadrature)');
title(sprintf('Constellation QAM-%d — %d transitions possibles', M, M*(M-1)));
xlim([-1.2*max(abs(real(pts)))-0.3, 1.2*max(abs(real(pts)))+0.3]);
ylim([-1.2*max(abs(imag(pts)))-0.3, 1.2*max(abs(imag(pts)))+0.3]);

saveas(gcf, 'figures/q4a_constellation.png');

fprintf('Q4A terminé. Constellation QAM-%d avec %d transitions affichée.\n', M, M*(M-1));