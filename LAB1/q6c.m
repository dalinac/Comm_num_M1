%% Q6C - OTFS avec egalisation
% Approche : egalisation simple par inversion du canal dans le domaine DD
% en utilisant la reponse impulsionnelle connue

clear; close all;

L=4; Fs=8000; Tu=8e-3; Tg=2e-3; SNR=40;
pathDelays=[0 2 2]; pathGains=[1 0.1 0.15]; pathDopplers=[0 -3 3];

message = { ...
    'aerotransporte!','communautariser','contractualiser', ...
    'contre-attaquer','contre-echarner','contre-indiquer', ...
    'contre-profiler','court-circuiter','dactylographier', ...
    'dechristianiser','decollectiviser','decongestionner', ...
    'deconventionner','depersonnaliser','depsychiatriser', ...
    'desaisonnaliser','desembouteiller','fonctionnaliser', ...
    'fonctionnariser','fransquillonner','grammaticaliser', ...
    'helitransporter','impermeabiliser','microprogrammer', ...
    'patrimonialiser','perquisitionner','preselectionner', ...
    'rechristianiser','respectabiliser','responsabiliser', ...
    'syncristalliser','teletransmettre','tire-bouchonner'};

N_words=length(message); M=length(message{1})*8/L;
MN=M*N_words;
fprintf('OTFS : M=%d, N=%d, MN=%d\n',M,N_words,MN);

%% Emission
Xdd_kl=zeros(M,N_words);
for l=1:N_words
    vals=myMess2ValMat(message{l},L);
    Xdd_kl(:,l)=myQAMmod(vals,L);
end
Xtf_mn=myISFFT(Xdd_kl);
x=myOFDMmod(Xtf_mn,Fs,Tu,Tg);

%% Canal
y_ch=myDopplerMultiChannel(x,pathDelays,pathDopplers,pathGains);
y_rx=myAwgn(y_ch,SNR);

%% Reception SANS egalisation
Ytf_no=myOFDMdemod(y_rx,M,Fs,Tu,Tg);
Ydd_no=mySFFT(Ytf_no);

%% AVEC egalisation : approche par reponse pilote simulee
% Simuler la reponse du canal a une impulsion DD unitaire
% pour obtenir la PSF (point spread function) du canal

fprintf('Calcul PSF du canal...\n');
M_p=M; N_p=N_words;

% Impulsion pilote en (0,0)
Xdd_imp=zeros(M_p,N_p); Xdd_imp(1,1)=1;
Xtf_imp=myISFFT(Xdd_imp);
x_imp=myOFDMmod(Xtf_imp,Fs,Tu,Tg);
y_imp=myDopplerMultiChannel(x_imp,pathDelays,pathDopplers,pathGains);
% Pas de bruit pour la PSF
Ytf_imp=myOFDMdemod(y_imp,M_p,Fs,Tu,Tg);
Ydd_imp=mySFFT(Ytf_imp);   % PSF du canal dans le domaine DD

fprintf('PSF calculee. Max=%.4f\n',max(abs(Ydd_imp(:))));

%% Egalisation par deconvolution dans le domaine DD
% Le canal agit comme une convolution 2D circulaire dans le domaine DD
% On egalise en divisant les spectres 2D (filtre inverse regularise)

% FFT 2D du signal recu et de la PSF
Ydd_no_fft = fft2(Ydd_no);
PSF_fft     = fft2(Ydd_imp);

% Filtre inverse de Wiener 2D
n_level = 10^(-SNR/10);
H_wiener = conj(PSF_fft) ./ (abs(PSF_fft).^2 + n_level);

Ydd_eq = ifft2(Ydd_no_fft .* H_wiener);

%% Comptage erreurs
n_no=0; n_eq=0;
for l=1:N_words
    v_no=myQAMdemod(Ydd_no(:,l),L);
    if ~strcmp(message{l},myValMat2Mess(v_no,L)), n_no=n_no+1; end
    v_eq=myQAMdemod(Ydd_eq(:,l),L);
    if ~strcmp(message{l},myValMat2Mess(v_eq,L)), n_eq=n_eq+1; end
end
fprintf('Sans egalisation : %d/%d erreurs\n',n_no,N_words);
fprintf('Avec egalisation : %d/%d erreurs\n',n_eq,N_words);

%% Figure
ref=myQAMmod(0:15,L);
figure('Name','Q6C - Constellations','Position',[100 100 1000 480]);

subplot(1,2,1);
scatter(real(Ydd_no(:)),imag(Ydd_no(:)),15,'b','filled','MarkerFaceAlpha',0.3);
hold on; plot(real(ref),imag(ref),'r+','MarkerSize',10,'LineWidth',2);
xlabel('I'); ylabel('Q');
title(sprintf('Sans egalisation (%d/%d erreurs)',n_no,N_words));
grid on; axis equal; legend('Recu','Ref QAM-16');

subplot(1,2,2);
scatter(real(Ydd_eq(:)),imag(Ydd_eq(:)),15,[0 0.6 0],'filled','MarkerFaceAlpha',0.3);
hold on; plot(real(ref),imag(ref),'r+','MarkerSize',10,'LineWidth',2);
xlabel('I'); ylabel('Q');
title(sprintf('Avec egalisation (%d/%d erreurs)',n_eq,N_words));
grid on; axis equal; legend('Recu egal.','Ref QAM-16');

sgtitle(sprintf('Canal multitrajet+Doppler | SNR=%d dB',SNR));

saveas(gcf,'figures/q6c_equalisation.png');
fprintf('Q6C terminé.\n');