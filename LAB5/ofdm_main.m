%--
clearvars; 

%% Exemple du DAB+ mode 1
% caractéristiques du mode 1
Fs = 2048000;   % fréquence d'échantillonage standard d'un signal DAB après
                % démodulation (plus de porteuse)
                % Fs maxi du R820T = 28 800 000Hz
Rsym        = 76;        % 76 symboles par trame (sans inclure le symbole NULL)
K           = 1536;      % nobre de sous-porteuses
Tg          = 504/Fs;    % durée du temps intercalaire contre le ICI (durée du cyclic prefix CP)
    % Fs          = 1920000;   % 
    % Rsym        = 20;        % 76 symboles par trame (sans inclure le symbole NULL)
    % K           = 128;      % nobre de sous-porteuses
    % Tg          = 12/Fs;    % durée du temps intercalaire contre le ICI (durée du cyclic prefix CP)
scs         = Fs/K;      % largeur fréquentielle d'un canal SCS (sub-carrier spacing)
data_order  = 256;       % QAM-256 pour les données
pilot_order = 4;         % QAM-4   pour le signal pilote
cp_length   = Tg*Fs;     % Nbre d'ech du cyclic prefix CP

doppler = 18; % en Hz (100km/h)
att     = 0.25;
delaySpr= 100;%samples (~50µs)
%% Génération de la grille OFDM et modulation QAM
    data_symbols     = randi(data_order,     K,   Rsym)   - 1;
    pilot_symbols    = randi(pilot_order,    K/4, Rsym/4) - 1;% 1 case sur 16 est un pilote

    % Constitution de la constellation 
    data_qam_states  = my_qammod(data_symbols,  data_order);
    pilot_qam_states = my_qammod(pilot_symbols, pilot_order);

    % Placer les données et les pilotes dans la grille OFDM
    pilot_locations  = false(K, Rsym);
    pilot_locations(1:4:end, 1:4:end) = true;
    data_locations   = ~pilot_locations;

    ofdm_grid = zeros(K, Rsym);
    ofdm_grid(data_locations)  = data_qam_states(data_locations);
    ofdm_grid(pilot_locations) = pilot_qam_states;

    % génération de la forme d'onde temporelle
    tx_waveform = my_ofdmmod(ofdm_grid, K, cp_length);

    figure(1);clf;hold on;
    time = (0:size(tx_waveform,1)-1)'/Fs;
    plot(time,real(tx_waveform),'r-');
    plot(time,imag(tx_waveform),'b-');

    figure(2);clf;
    plot(real(ofdm_grid(data_locations)), imag(ofdm_grid(data_locations)), ...
         'o', 'Color', [0.137 0.235 0.902]);
    axlim = max(abs(ofdm_grid(data_locations))) + 0.05;
    ylim([-axlim axlim]); xlim([-axlim axlim]); axis square;
    xlabel('In-phase'); ylabel('Quadrature'); title('Tx data constellation');

    figure(3);clf;
    plot(real(ofdm_grid(pilot_locations)), imag(ofdm_grid(pilot_locations)), ...
         'o', 'Color', [0.137 0.235 0.902]);
    axlim = max(abs(ofdm_grid(pilot_locations))) + 0.05;
    ylim([-axlim axlim]); xlim([-axlim axlim]); axis square;
    xlabel('In-phase'); ylabel('Quadrature'); title('Tx pilot constellation');

    figure(31);clf;hold on;
    [i1, j1] = find(data_locations);
    [i0, j0] = find(~data_locations);
    plot(i1, j1, 'r.', 'MarkerSize', 8); 
    plot(i0, j0, 'b*', 'MarkerSize', 8);
    axis equal;
    xlim([770,860]);

    %% Demodulation OFDM avec canal parfait et calcul de le taux d'erreur de symbols
    ofdm_grid_rec = my_ofdmdemod(tx_waveform, K, cp_length);
    data_symbols_rec = my_qamdemod(ofdm_grid_rec(data_locations), data_order);
    n_errors = sum(data_symbols_rec(:) ~= data_symbols(data_locations));
    SER      = n_errors / numel(data_symbols_rec);
    disp(['Symbol Error Rate: ' num2str(SER)]);

    %% Propagation multi trajets
    % deux trajets avec une attenuation du 2ème (0.25)
    % dispersion temporelle du canal (delay spread) = 100 samples = 100/FS ~ 50µs 
    % effet doppler de 18Hz (mobile en approche du récepteur 100km/h)
    rx_waveform = tx_waveform + att * circshift(tx_waveform, delaySpr) .* exp(2j*pi * doppler .* time);

    %% Demodulation OFDM avec canal imparfait et calcul de le taux d'erreur de symbols
    ofdm_grid_rec = my_ofdmdemod(rx_waveform, K, cp_length);
    data_symbols_rec = my_qamdemod(ofdm_grid_rec(data_locations), data_order);
    n_errors = sum(data_symbols_rec(:) ~= data_symbols(data_locations));
    SER      = n_errors / numel(data_symbols_rec);
    disp(['Symbol Error Rate: ' num2str(SER)]);

    figure(4);
    plot(real(ofdm_grid_rec(data_locations)), imag(ofdm_grid_rec(data_locations)), ...
         'o', 'Color', [0.137 0.235 0.902]);
    axlim = max(abs(ofdm_grid_rec(:))) + 0.05;
    ylim([-axlim axlim]); xlim([-axlim axlim]); axis square;
    xlabel('In-phase'); ylabel('Quadrature'); title('Rx constellation (before equalisation)');

    %% Estimation & Equalisation de canal
    pilot_rx = ofdm_grid_rec(pilot_locations);% grille reçue (Y)
    H_estime = reshape(pilot_rx, K/4, Rsym/4) ./ pilot_qam_states;% H=Y/X_pilote

    [X,  Y ] = meshgrid(1:4:Rsym,  1:4:K);% maillage des pilotes
    [Xq, Yq] = meshgrid(1:Rsym,    1:K);% maillage de tous les signaux
    % Lisser H_pilote sur toute la grille pour estimer H_data
    H_estime_interp   = interp2(X, Y, H_estime, Xq, Yq, 'spline');
    % corriger la grille reçu avec la fonction de transfert estimé de toute
    % la grile frequence_domaine
    ofdm_grid_rec = ofdm_grid_rec ./ H_estime_interp;

    figure(5);
    plot(real(ofdm_grid_rec(data_locations)), imag(ofdm_grid_rec(data_locations)), ...
         'o', 'Color', [0.137 0.235 0.902]);
    axlim = max(abs(ofdm_grid_rec(:))) + 0.05;
    ylim([-axlim axlim]); xlim([-axlim axlim]); axis square;
    xlabel('In-phase'); ylabel('Quadrature'); title('Rx constellation (after equalisation)');

    %% Symbol Error Rate
    data_symbols_rec = my_qamdemod(ofdm_grid_rec(data_locations), data_order);
    n_errors = sum(data_symbols_rec(:) ~= data_symbols(data_locations));
    SER      = n_errors / numel(data_symbols_rec);
    disp(['Symbol Error Rate: ' num2str(SER)]);


