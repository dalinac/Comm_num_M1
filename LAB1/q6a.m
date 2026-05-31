%% Q6A - OTFS sans canal (SNR = 40 dB)
clear; close all;

L  = 4;
Fs = 8000;
Tu = 8e-3;
Tg = 2e-3;
SNR = 40;

%% Message : 33 verbes de exactement 15 caracteres

message = { ...
    'aerotransporte!', ...  % 15
    'communautariser', ...  % 15
    'contractualiser', ...  % 15
    'contre-attaquer', ...  % 15
    'contre-echarner', ...  % 15
    'contre-indiquer', ...  % 15
    'contre-profiler', ...  % 15
    'court-circuiter', ...  % 15
    'dactylographier', ...  % 15
    'dechristianiser', ...  % 15
    'decollectiviser', ...  % 15
    'decongestionner', ...  % 15
    'deconventionner', ...  % 15
    'depersonnaliser', ...  % 15
    'depsychiatriser', ...  % 15
    'desaisonnaliser', ...  % 15
    'desembouteiller', ...  % 15 
    'fonctionnaliser', ...  % 15
    'fonctionnariser', ...  % 15 
    'fransquillonner', ...  % 15
    'grammaticaliser', ...  % 15
    'helitransporter', ...  % 15
    'impermeabiliser', ...  % 15
    'microprogrammer', ...  % 15
    'patrimonialiser', ...  % 15
    'perquisitionner', ...  % 15
    'preselectionner', ...  % 15
    'rechristianiser', ...  % 15
    'respectabiliser', ...  % 15
    'responsabiliser', ...  % 15
    'syncristalliser', ...  % 15
    'teletransmettre', ...  % 15
    'tire-bouchonner'  ...  % 15
};

%% Verifier les longueurs
fprintf('Verification des longueurs :\n');
ok = true;
for i = 1:length(message)
    n = length(message{i});
    if n ~= 15
        fprintf('  ERREUR verbe %d : "%s" -> %d chars\n', i, message{i}, n);
        ok = false;
    end
end
if ok, fprintf('  Tous les verbes font 15 caracteres. OK.\n'); end

N_words = length(message);
M = 15*8/L;   % = 30 sous-porteuses
fprintf('M=%d, N=%d, specN=%d\n', M, N_words, round(Fs*Tu));

%% Canal trivial (pas de diffuseur)
pathDelays   = 0;
pathDopplers = 0;
pathGains    = 1;

%% Appel myOTFScomm
[symbols_rx, Ydd_kl, Xdd_kl, x, y] = myOTFScomm( ...
    message, L, 'QAM', Fs, Tu, Tg, SNR, ...
    pathDelays, pathDopplers, pathGains);

%% Verification
n_errors = 0;
for i = 1:N_words
    if ~strcmp(message{i}, symbols_rx{i})
        n_errors = n_errors + 1;
        fprintf('  Erreur verbe %2d : "%s" -> "%s"\n', i, message{i}, symbols_rx{i});
    end
end
fprintf('Erreurs : %d/%d  (SNR=%d dB)\n', n_errors, N_words, SNR);

%% Constellation
figure('Name','Q6A - Constellation OTFS','Position',[100 100 600 550]);
scatter(real(Ydd_kl(:)), imag(Ydd_kl(:)), 20, 'b', 'filled', 'MarkerFaceAlpha', 0.4);
hold on;
ref = myQAMmod(0:15, L);
plot(real(ref), imag(ref), 'r+', 'MarkerSize', 12, 'LineWidth', 2);
xlabel('I'); ylabel('Q');
title(sprintf('OTFS — constellation reçue (SNR=%d dB, sans diffuseur)', SNR));
grid on; axis equal;
legend('Symboles reçus','Référence QAM-16','Location','best');
saveas(gcf,'figures1/q6a_otfs_clean.png');
save('q6a_data.mat','M','N_words','Xdd_kl','Ydd_kl','message','L','Fs','Tu','Tg');
fprintf('Q6A terminé.\n');