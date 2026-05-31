clear all;
clc;

%% Partie 1
N = 32;     
Fe = 1000;     
Te = 1/Fe;    
sampPbit = 6;
Fb = Fe/sampPbit;
t = [0:N*sampPbit-1]/Fb;
bits = randi([0 1], 1, N);
NRZ = repmat(bits(:),1,sampPbit)';
NRZ = NRZ(:)';

figure(1);clf;
subplot(1,2,1);
stairs(t,NRZ, 'LineWidth', 1.5);
ylim([-0.2 1.2]);
grid on;

signal = 2*NRZ - 1; % Conversion en ±1 pour enlever la raie centrale
Fsig = fft(signal);
freq = linspace(-Fe/2, Fe/2, sampPbit*N);
DSP = fftshift(abs(Fsig)).^2 / (sampPbit*N);

subplot(1,2,2);
plot(freq, 10*log10(DSP), 'b');
title('Spectre de puissance (dB)');
grid on;
ylim([-60,20]);

%% Partie 2
N = 320;     
Fe = 1000;     
Te = 1/Fe;    
sampPbit = 6;
Fb = Fe/sampPbit;
t = [0:N*sampPbit-1]/Fb;
bits = randi([0 1], 1, N);
NRZ = repmat(bits(:),1,sampPbit)';
NRZ = NRZ(:)';

fn1 = Fe/sampPbit;

figure(2);clf;
subplot(3,2,1);
stairs(t,NRZ, 'LineWidth', 1.5);
ylim([-0.2 1.2]);
xlim([1,4.5]);
grid on;

signal = 2*NRZ - 1; % Conversion en ±1 pour enlever la raie centrale
Fsig = fft(signal);
freq = linspace(-Fe/2, Fe/2, sampPbit*N);
DSP = fftshift(abs(Fsig)).^2 / (sampPbit*N);

subplot(3,2,2);hold on;
plot(freq, 10*log10(DSP), 'b');
yl=ylim();
plot([fn1,fn1],yl,'k-..','linewidth',2);
plot(2*[fn1,fn1],yl,'k-..','linewidth',2);
title('Spectre de puissance (dB)');
grid on;
ylim([-60,20]);
%% Partie 3
largeur_alteration = 20/100; % Largeur relative a f_n1
position_alteration = 20/100; % Largeur relative a f_n1

idxInf = round(position_alteration*N);
idxSup = round((position_alteration+position_alteration)*N);
spectre_altere = Fsig;
spectre_altere(idxInf:idxSup) = spectre_altere(idxInf:idxSup) / 100;
spectre_altere(N*sampPbit+1-idxInf:-1:N*sampPbit+1-idxSup) = spectre_altere(N*sampPbit+1-idxInf:-1:N*sampPbit+1-idxSup) / 100;
DSP_altere = fftshift(abs(spectre_altere).^2 / (sampPbit*N));

figure(2);
subplot(3,2,4);
plot(freq, 10*log10(DSP_altere), 'r');
title('Spectre altéré (dB)');
xlabel('Fréquence (Hz)');
ylabel('Puissance (dB)');
ylim([-60,20]);
% xlim([-fn1,fn1]);
grid on;

signal_altere = real(ifft(spectre_altere));
subplot(3,2,3);
plot(t,signal_altere, 'r','LineWidth', 1.5);
xlim([1,4.5]);
title('Signal temporel reconstruit après altération spectrale');
xlabel('Échantillons');
ylabel('Amplitude');
grid on;

idxInf = N+round(position_alteration*N);
idxSup = N+round((position_alteration+position_alteration)*N);
spectre_altere = Fsig;
spectre_altere(idxInf:idxSup) = spectre_altere(idxInf:idxSup) / 10;
spectre_altere(N*sampPbit+1-idxInf:-1:N*sampPbit+1-idxSup) = spectre_altere(N*sampPbit+1-idxInf:-1:N*sampPbit+1-idxSup) / 100;
DSP_altere = fftshift(abs(spectre_altere).^2 / (sampPbit*N));

figure(2);
subplot(3,2,6);
plot(freq, 10*log10(DSP_altere), 'r');
title('Spectre altéré (dB)');
xlabel('Fréquence (Hz)');
ylabel('Puissance (dB)');
ylim([-60,20]);
xlim([-2*fn1,2*fn1]);
grid on;

signal_altere = real(ifft(spectre_altere));
subplot(3,2,5);
plot(t,signal_altere, 'r','LineWidth', 1.5);
xlim([1,4.5]);
title('Signal temporel reconstruit après altération spectrale');
xlabel('Échantillons');
ylabel('Amplitude');
grid on;

%% Partie 4.A
N = 100;% N caractaires ASCII     
bitPword = 4;
message = randi([0,255],[1,N]);% texte au hasard
    s_m   = myMess2binMat(message,bitPword);
    [M,L] = size(s_m);  % M est le nombre de sous porteuses
                        % L est le nombre de bits par mot
                        % 2^L indique la taille de la constellation
                        % réalisée ici en QAM
    vals   = bin2dec(char(s_m+48));
    x_QAM  = myQAMmod(vals,L);

figure(3);clf;hold on;
    plot(x_QAM,"-");
    plot(x_QAM,"r*");

%% Partie 4.B
message = '[Master ELISE sem2§]'
s_m   = myMess2binMat(message,L);
    [M,L] = size(s_m);  % M est le nombre de sous porteuses
                        % L est le nombre de bits par mot
                        % L indique la taille de la constellation
                        % réalisée ici en QAM
    vals   = bin2dec(char(s_m+48));
    X_m  = myQAMmod(vals,L);
    x_m  = ifft(X_m);
    Isignal = real(x_m);
    Qsignal = imag(x_m);
    

figure(4);clf;
subplot(2,1,1);
    stem(Isignal);
    ylim([-0.5,0.5]);
subplot(2,1,2);
    stem(Qsignal);
    ylim([-0.5,0.5]);
xlim([0,M+1]);

%% Partie 4.C
for SNR = 10:2:20
    disp(['SNRdB = ',num2str(SNR)]);
    Y_QAM = myAwgn(x_m,SNR);
    
    x_QAM = fft(Y_QAM);
    message_w = myQAMdemod(x_QAM,L);
    messageR = reshape(message_w',2,length(x_m)/2);
    messageR = char(messageR(1,:)*16+messageR(2,:));
    if strcmp(messageR,message)
        disp(messageR);
    else
        disp("le message reçu comporte des erreurs :");
        disp(messageR);
    end
end
%% Partie 4.D
Ntest = 100;% 1000 si vous avez le temps
SNRlist = 10:0.1:20;
echec = zeros(1,length(SNRlist));
for SNRit = 1:length(SNRlist)
    SNR = SNRlist(SNRit);
    for it=1:Ntest
        Y_QAM = myAwgn(x_m,SNR);
        x_QAM = fft(Y_QAM);
        message_w = myQAMdemod(x_QAM,bitPword);
        messageR = reshape(message_w',2,length(x_m)/2);
        messageR = char(messageR(1,:)*16+messageR(2,:));
        if ~strcmp(messageR,message)
            echec(SNRit)=echec(SNRit)+1;
        end
    end
end
echec=echec/Ntest;

figure(5);clf;hold on;
    plot(SNRlist,echec*100, 'b','linewidth',2);
    ylabel("echec (%)");
    xlabel('SNR (dB)');
    grid on
%% Partie A.E
message = 'Master1 ELISE';
bitPword = 4;
len_mess = length(message)*2;

M   = 5;
h   = hammgen(M);
N   = 2^M-1;
K   = N-M;

message_b = dec2bin(message+0,8)-48;
message_b = reshape(message_b',4,len_mess);

encMessage = encode(message_b,N,K,'hamming/binary')';

message_w = bin2dec(char(encMessage+48));
x_QAM = myQAMmod(message_w,bitPword);
y_QAM = ifft(x_QAM);
Signal = real(y_QAM);
figure(6);
    stem(Signal);
xlim([0,N+1]);


Y_QAM = myAwgn(y_QAM,40);
x_QAM = fft(Y_QAM);
message_w = myQAMdemod(x_QAM,bitPword);
message_b = dec2bin(message_w,bitPword)-48;
decMmessage = decode(message_b',N,K,'hamming/binary')';
messageR = reshape(decMmessage',8,len_mess/2)';
messageR = char(bin2dec(char(messageR+48)))';
if strcmp(messageR,message)
    disp(messageR);
    disp('reçu 5/5');
else
    disp("le message reçu comporte des erreurs :");
    disp(messageR);
end
% maintenant on fait varier le SNRdB pour voir si le décodage s'améliore
Ntest = 100;% 1000 si vous avez le temps
SNRlist = 10:0.1:20;
echec = zeros(1,length(SNRlist));
for SNRit = 1:length(SNRlist)
    SNR = SNRlist(SNRit);
    for it=1:Ntest
        Y_QAM = myAwgn(y_QAM,SNR);
        x_QAM = fft(Y_QAM);
        message_w = myQAMdemod(x_QAM,bitPword);
        message_b = dec2bin(message_w,bitPword)-48;
        decMmessage = decode(message_b',N,K,'hamming/binary')';
        messageR = reshape(decMmessage',8,len_mess/2)';
        messageR = char(bin2dec(char(messageR+48)))';
        if ~strcmp(messageR,message)
            echec(SNRit)=echec(SNRit)+1;
        end
    end
end
echec=echec/Ntest;
figure(5);hold on;
    plot(SNRlist,echec*100,'r','linewidth',2);
    ylabel("echec (%)");
    xlabel('SNR (dB)');
    legend({'OFDM','COFDM'});    
    grid on

%% Partie 5.

SNR = 40;% dB
message = 'Master1 ELISE';
bitPword = 4;
M = length(message)*2;

m   = 5;
h   = hammgen(m);
N   = 2^m-1;
K   = N-m;

message_b = dec2bin(message+0,8)-48;
message_b = reshape(message_b',4,M);

encMessage = encode(message_b,N,K,'hamming/binary')';

message_w = bin2dec(char(encMessage+48));
x_QAM = myQAMmod(message_w,bitPword);
clf
    % Configurer les trajets et les movements 
    pathDelays      = [0     2      2     ]; % délai causés par trajet en échantillon
    pathGains       = [1     0.2    0.15  ]; % gain complexe de chaque trajet
    pathDopplers    = [0    -3      3     ]; % df (Doppler shift) en échantillon
    % pathDelays      = [0]; % délai causés par trajet en échantillon
    % pathGains       = [1]; % gain complexe de chaque trajet
    % pathDopplers    = [0]; % df (Doppler shift) en échantillon
    
    % ici il semble que le premier effet DD correspond à un récépteur
    % immobile et synchronisé en gain et frequence. 
echec = 0;    
for it=1:100    
    Y_QAM = myAwgn(y_QAM,SNR);
    Y_QAMdd = myDopplerMultiChannel(Y_QAM,pathDelays,pathDopplers,pathGains);
    
    x_QAM = fft(Y_QAMdd);
    message_w = myQAMdemod(x_QAM,bitPword);
    message_b = dec2bin(message_w,bitPword)-48;
    decMmessage = decode(message_b',N,K,'hamming/binary')';
    messageR = reshape(decMmessage',8,M/2)';
    messageR = char(bin2dec(char(messageR+48)))';
    if ~strcmp(messageR,message)
        echec = echec +1;
    end
end
figure(5);hold on;
xl=xlim();
plot(xl,[echec,echec],'m-..', 'LineWidth',2,'DisplayName','COFDM canal effet DD');
% on remarque un planché d'erreur de transmission autour de 30% mais 
% ça devient catastrophique dès que le gain des diffuseurs dépasse 20%
% environ
%% Partie 6.

% On teste ici la modulation démodulation OTFS sans effet DD ni bruit additif

    clc;
    % Verbes de 15 caractères L:P)
    message = { 'aérotransporter','communautariser','contractualiser', ...
                'contre-attaquer','contre-écharner','contre-indiquer', ...
                'contre-profiler','court-circuiter','dactylographier', ...
                'déchristianiser','décollectiviser','décongestionner', ...
                'déconventionner','dépersonnaliser','dépsychiatriser', ...
                'désaisonnaliser','désembouteiller','fonctionnaliser', ...
                'fonctionnariser','fransquillonner','grammaticaliser', ...
                'hélitransporter','imperméabiliser','microprogrammer', ...
                'patrimonialiser','perquisitionner','présélectionner', ...
                'rechristianiser','respectabiliser','responsabiliser', ...
                'syncristalliser','télétransmettre','tire-bouchonner'};
    N = length(message);
    M = length(message{1})*2; % echantillon de 4bit -> utiliser qam16
    L = 4;% 4bits
    
    Fs      = 40e3;      % Fs maxi du R820T = 28 800 000Hz
    Tu      = 40/Fs;     % Durée d'un symbole sans le temps intercalaire contre le ICI
    Tg      = 10/Fs;     % durée du temps intercalaire contre le ICI
    
    SNR     = 40;% en dB
    
    Xdd_kl = zeros(M,N);
    for l=1:N
        symbole    = message{l};
        Xdd_kl(:,l)  = myQAMmod(myMess2ValMat(symbole,L),L);
    end
    
    Xtf_mn = myISFFT(Xdd_kl);
    x = myOFDMmod(Xtf_mn,Fs,Tu,Tg);
    Isignal = real(x);
    Qsignal = imag(x);
    
    figure(7);clf;
        subplot(2,1,1);hold on;
            len = length(x);
            t = [0:len-1]/Fs*1000;
            plot(t,Isignal,'b');
            plot(t,Qsignal,'r');
            xlabel("Temps (ms)");
        subplot(2,1,2);hold on;
            fftIQ = fft(Isignal+1i*Qsignal);
            plot(abs(fftIQ),'b');
    
    y = myAwgn(x,SNR);
    len_mess = N*Fs*(Tu+Tg);% longueur de x
        Ytf_mn = myOFDMdemod(y,M,Fs,Tu,Tg);
        Ydd_kl = mySFFT(Ytf_mn);
        for l=1:N
            ValMat  = myQAMdemod(Ydd_kl(:,l),L);
            symbole = myValMat2Mess(ValMat,L);
            Err = symbole; % Copie de str1
            symbole(symbole ~= message{l}) = '_';   % Remplace les caractères 
                                                    % différents par 'X'
            disp(symbole);
        end
%%
% On encapsule cette procédure mod/demod dans une fonction puis on analyse 
% les effets DD sur un signal pilote sans modulation du code: function myOTFScomm
% ici on considère un niveau SNR très faible

clc
sym                = char(zeros(1,70));
message            = repmat({sym},1,120);
message{60}(20/2) = 1;             % retard de trajet de 20 échantillons (un char = 2symboles de 4bits) et ecart doppler de 60 échantillons
    codeModulation = "none";
    L              = 4;            % 4bits
    M              = length(sym)*8/L;
    N              = length(message);
    Fs             = 100e3;        % Fs maxi du R820T = 28 800 000Hz
    bitRate        = 2;            % samples per bit
    Tu             = bitRate*M/Fs; % Durée d'un symbole sans le temps intercalaire contre le ICI.
    Tg             = 50/Fs;        % durée du temps intercalaire contre le ICI
    SNRdB          = -10;          % en dB

    pathDelays      = [0     2      2   ]*bitRate; % délai causés par trajet en échantillon
    pathGains       = [1     0.2    0.3 ];     % gain complexe de chaque trajet
    pathDopplers    = [0    -3      3   ];     % df (Doppler shift) en échantillon

[~,Ydd_kl,Xdd_kl] = myOTFScomm(message, L, codeModulation, Fs, Tu,...
                          Tg, SNRdB, pathDelays, pathDopplers, pathGains);
figure(8);clf;
    subplot(2,1,1);
        surf(abs(Xdd_kl'),'FaceColor','red','EdgeColor','none');camlight left; lighting phong;
        xlabel('Delai (sample)');
        ylabel('Ecart Doppler (sample)');
    subplot(2,1,2);
        surf(abs(Ydd_kl'),'FaceColor','red','EdgeColor','none');camlight left; lighting phong;
        xlabel('Delai (sample)');
        ylabel('Ecart Doppler (sample)');


% nous allons localiser les piques
sig = abs(Ydd_kl).^2;             % calcul (ou mesure) de la puissance instantanée
sigMean = mean(sig(:));           % calcul (ou mesure) du niveau moyen de puissance 
sigSigma = std(sig(:));           % écart type
sig(abs(sig)<(sigMean+2*sigSigma)) = 0; % araser tout ce qui dépasse P_moy + 2*P_sigma

[gk,xlocs,ylocs]=peaks2(sig);% détecter les piques (script écrit par Kristupas Tikuisis)
[~,idx] = max(gk);
DD_principal = [xlocs(idx),ylocs(idx)];
xlocs(idx)=[];ylocs(idx)=[];
DD_diffuseurs = [xlocs,ylocs];

figure(8);
    subplot(2,1,2);hold on;
    DelayM     = DD_principal(1);
    DopplerM   = DD_principal(2);
    plot3(DelayM,DopplerM,abs(Ydd_kl(DelayM,DopplerM)),'*k');
    DelayD     = DD_diffuseurs(:,1);
    DopplerD   = DD_diffuseurs(:,2);
    for it=1:length(DopplerD)
        plot3(DelayD(it),DopplerD(it),abs(Ydd_kl(DelayD(it),DopplerD(it))),'ok');
    end

% DelayD - DelayM
% DopplerD - DopplerM
disp([DelayM, DopplerM])
disp([DelayD-DelayM, DopplerD-DopplerM])

%%
% On teste ici la modulation démodulation OTFS AVEC effet DD mais toujours avec 
% bruit additif faible

clc
clear message;
for it=1:30
    message{it}= char(randi([0,255],[1,35]));
end
    % message = { 'aérotransporter','communautariser','contractualiser', ...
    %             'contre-attaquer','contre-écharner','contre-indiquer', ...
    %             'contre-profiler','court-circuiter','dactylographier', ...
    %             'déchristianiser','décollectiviser','décongestionner', ...
    %             'déconventionner','dépersonnaliser','dépsychiatriser', ...
    %             'désaisonnaliser','désembouteiller','fonctionnaliser', ...
    %             'fonctionnariser','fransquillonner','grammaticaliser', ...
    %             'hélitransporter','imperméabiliser','microprogrammer', ...
    %             'patrimonialiser','perquisitionner','présélectionner', ...
    %             'rechristianiser','respectabiliser','responsabiliser', ...
    %             'syncristalliser','télétransmettre','tire-bouchonner'};
    L              = 4;         % 4bits
    N = length(message);
    M = length(message{1})*8/L; % echantillon de 4bit -> utiliser qam16
    codeModulation = "QAM";
    Fs             = 100e3;        % Fs maxi du R820T = 28 800 000Hz
    bitRate        = 10;            % samples per bit
    Tu             = bitRate*M/Fs; % Durée d'un symbole sans le temps intercalaire contre le ICI.
    Tg             = 0/Fs;        % durée du temps intercalaire contre le ICI
    SNRdB          = 40;          % en dB

    pathDelays      = [0     4    ]*bitRate; % délai causés par trajet en échantillon
    pathGains       = [1     0.2  ];     % gain complexe de chaque trajet
    pathDopplers    = [0    -5    ];     % df (Doppler shift) en échantillon

[symbols,Ydd_kl,Xdd_kl,~,y] = myOTFScomm(message, L, codeModulation, Fs, Tu,...
                          Tg, SNRdB, pathDelays, pathDopplers, pathGains);
figure(9);clf;
    subplot(2,1,1);
        surf(abs(Xdd_kl),'FaceColor','cyan','EdgeColor','none');camlight left; lighting phong;
    subplot(2,1,2);
        surf(abs(Ydd_kl),'FaceColor','cyan','EdgeColor','none');camlight left; lighting phong;

figure(10);clf;
    subplot(1,2,1);
        plot(Ydd_kl,'*');
        axis equal
        xlim([-1.5,1.5]);
        ylim([-1.5,1.5]);

 % On suppose qu'aver la technique du pilote on ait estimer les effets DD
 % du canal
Mreel = (Tu+Tg)*Fs;
 G = myGmatrix(Mreel,N,pathDelays,pathDopplers,pathGains);
 noiseLevel = 10^(-SNRdB/10);
 y_tilde = ((G'*G)+eye(Mreel*N)*noiseLevel) \ (G'*y); 


    % Ytf_mn = myDopplerMultiChannel(y,-pathDelays,-pathDopplers,pathGains);

        Ytf_mn = myOFDMdemod(y_tilde,M,Fs,Tu,Tg);
        Ydd_kl_tilde = mySFFT(Ytf_mn);
    subplot(1,2,2);
        plot(Ydd_kl_tilde,'*');
        axis equal
        xlim([-1.5,1.5]);
        ylim([-1.5,1.5]);
