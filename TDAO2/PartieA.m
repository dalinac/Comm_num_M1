clc; clear close all;

N = 10000; % Nombre d'échantillons
mu = 1.5; % Moyenne du bruit
sigma = 1; % Écart type du bruit

% Génération du signal de bruit gaussien
noise = sigma * randn(1, N) + mu;

figure('Name', 'Bruit gaussien');
plot(noise);
title('Bruit gaussien');
xlabel('N Echantillons');
ylabel('Amplitude');
grid on;

% Histogramme et comparaison théorique
figure('Name', 'Histogramme du bruit gaussien');
histogram(noise, 'Normalization', 'pdf', 'FaceColor', '#5B9BD5', 'EdgeColor', 'k');
hold on;

% Distribution normale théorique
x_theo = linspace(min(noise), max(noise), 100);
pdf_theo = (1/(sigma*sqrt(2*pi))) * exp(-(x_theo - mu).^2 / (2*sigma^2));
plot(x_theo, pdf_theo, 'r', 'LineWidth', 2);

% Ajout de la ligne pointillée pour la moyenne
xline(mu, 'k--', 'LineWidth', 2);

title('Histogramme du bruit gaussien');
xlabel('Values');
ylabel('Frequency'); % densité de probabilité grâce à la normalisation
grid on;

hold off;