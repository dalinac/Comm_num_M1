%% Q5 - OFDM vs COFDM en canal multitrajet + effet Doppler
% SNR de 0 a 40 dB

clear; close all;

%% Parametres OFDM (coherents avec Q4B/Q4C)
L  = 4; Fs = 8000; Tu = 8e-3; Tg = 2e-3;
% specN = round(8000*0.008) = 64 -> M=36 ok

%% Canal multitrajet + Doppler
pathDelays   = [0 2 2];
pathGains    = [1 0.1 0.15];
pathDopplers = [0 -3 3];

%% Messages
message_ofdm  = 'Master ELISE sem2§';
M_ofdm        = length(message_ofdm)*8/L;   % 36

message_cofdm = 'Master1 ELISE';
k = 26; n_ham = 31; m = 5;

%% Hamming(31,26) sans Communications Toolbox
de2bi_c = @(d,nb) fliplr(rem(floor(d(:)*2.^(-(nb-1):0)),2));
H = de2bi_c(1:n_ham, m)';
parity_pos = [];
for i=1:n_ham
    if sum(H(:,i))==1, parity_pos(end+1)=i; end
end
data_pos = setdiff(1:n_ham, parity_pos);
G = zeros(k,n_ham);
G(:,data_pos) = eye(k);
for j=1:length(parity_pos)
    p=parity_pos(j);
    G(:,p)=mod(H(:,data_pos)'*H(:,p),2);
end
ham_enc = @(b) mod(b*G,2);

    function dec = hdec(rx,H,dp,nh)
        syn=mod(H*rx',2); pos=0;
        for i=1:size(syn,1), pos=pos+syn(i)*2^(size(syn,1)-i); end
        if pos>0&&pos<=nh, rx(pos)=1-rx(pos); end
        dec=rx(dp);
    end

bits_msg = reshape(dec2bin(double(message_cofdm),8)'-'0',1,[]);
n_blocks = 4;
bits_msg = bits_msg(1:n_blocks*k);

%% Simulation
SNR_dB_vec = linspace(0, 40, 15);
N_trials   = 20;

taux_ofdm  = zeros(1,length(SNR_dB_vec));
taux_cofdm = zeros(1,length(SNR_dB_vec));

for idx = 1:length(SNR_dB_vec)
    snr = SNR_dB_vec(idx);
    nf_o=0; nf_c=0;

    for trial = 1:N_trials
        %% --- OFDM seul ---
        valMat = myMess2ValMat(message_ofdm,L);
        syms   = myQAMmod(valMat,L);
        Xtf    = reshape(syms,M_ofdm,1);
        x      = myOFDMmod(Xtf,Fs,Tu,Tg);
        y      = myDopplerMultiChannel(x,pathDelays,pathDopplers,pathGains);
        y      = myAwgn(y,snr);
        Ytf    = myOFDMdemod(y,M_ofdm,Fs,Tu,Tg);
        vr     = myQAMdemod(Ytf(:),L);
        mr     = myValMat2Mess(vr,L);
        if ~strcmp(message_ofdm,mr), nf_o=nf_o+1; end

        %% --- COFDM ---
        enc=[];
        for b=1:n_blocks
            bl=bits_msg((b-1)*k+1:b*k);
            enc=[enc,ham_enc(bl)];
        end
        pad=mod(L-mod(length(enc),L),L);
        ep=[enc,zeros(1,pad)];
        vals=zeros(1,length(ep)/L);
        for s=1:length(vals)
            vals(s)=bin2dec(num2str(ep((s-1)*L+1:s*L)));
        end
        M_c=length(vals);
        syms_c=myQAMmod(vals,L);
        Xtf_c =reshape(syms_c,M_c,1);
        xc    =myOFDMmod(Xtf_c,Fs,Tu,Tg);
        yc    =myDopplerMultiChannel(xc,pathDelays,pathDopplers,pathGains);
        yc    =myAwgn(yc,snr);
        Ytf_c =myOFDMdemod(yc,M_c,Fs,Tu,Tg);
        vrc   =myQAMdemod(Ytf_c(:),L);
        rxb=[];
        for s=1:length(vrc)
            rxb=[rxb, dec2bin(vrc(s),L)-'0'];
        end
        rxb=rxb(1:n_blocks*n_ham);
        dec=[];
        for b=1:n_blocks
            blr=rxb((b-1)*n_ham+1:b*n_ham);
            dec=[dec,hdec(blr,H,data_pos,n_ham)];
        end
        chars=zeros(1,length(dec)/8);
        for c=1:length(chars)
            chars(c)=bin2dec(num2str(dec((c-1)*8+1:c*8)));
        end
        mrc=char(chars);
        if ~strcmp(message_cofdm,mrc), nf_c=nf_c+1; end
    end

    taux_ofdm(idx) =nf_o/N_trials*100;
    taux_cofdm(idx)=nf_c/N_trials*100;
    fprintf('SNR=%5.1f dB  OFDM:%3.0f%%  COFDM:%3.0f%%\n',...
             snr,taux_ofdm(idx),taux_cofdm(idx));
end

%% Figure
figure('Name','Q5 - Canal Doppler','Position',[100 100 750 500]);
plot(SNR_dB_vec,taux_ofdm, 'b-o','LineWidth',2,'MarkerSize',7,'DisplayName','OFDM');
hold on;
plot(SNR_dB_vec,taux_cofdm,'r-s','LineWidth',2,'MarkerSize',7,'DisplayName','COFDM Hamming(31,26)');
xlabel('SNR (dB)'); ylabel('Taux d''echec (%)');
title('Canal multitrajet + Doppler — OFDM vs COFDM');
ylim([0 105]); grid on; legend('Location','northeast');

 saveas(gcf,'figures/q5_doppler.png');
save('q5_results.mat','SNR_dB_vec','taux_ofdm','taux_cofdm');
fprintf('Q5 termine.\n');