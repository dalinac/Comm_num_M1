clc; clear; 
% Paramètres du filtre
Fc = 250; % Fréquence de coupure en Hz
Fe = 2000; % Fréquence d'échantillonnage en Hz
wc = 2*pi*Fc/Fe; % Fréquence normalisée


% Différentes valeurs de N
N_values = [16, 51, 101,1001];
% N_values = [50];
colors = ['r', 'g', 'b', 'k']; % Couleurs pour chaque courbe

figure(1); clf;hold on;
for i = 1:length(N_values)
    N = N_values(i);
    n=-N/2:N/2-1;
    h=2*Fc/Fe*sinc(2*n*Fc/Fe);
    stem(n, h);
end

legend
grid on;
hold off;

figure(2); clf;
for i = 1:length(N_values)
    N = N_values(i);
    NB = N*20;
    if mod(N,2)==0
        n=-N/2:N/2-1;
    else
        n=-(N-1)/2:(N-1)/2-1;
    end
    h=2*Fc/Fe*sinc(2*n*Fc/Fe);
    H = fft(h, NB);
        wc = linspace(0, 1, NB);
        f=wc*Fe;
    subplot(2,length(N_values),i);hold on;
        plot(f, abs(H),'linewidth',2);
        xlim([0,Fe/2]);
    subplot(2,length(N_values),i+length(N_values));hold on;
        % plot(f, unwrap(angle(H)));xlim([0,Fe/2]);
        plot(f(2:end), -diff(unwrap(angle(H)))/(2*pi*Fe),'linewidth',2);ylim([-3,3]*1e-4);
        xlim([0,Fe/2]);
end

legend
grid on;
hold off;