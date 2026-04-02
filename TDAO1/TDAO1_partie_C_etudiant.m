clc; clear; 
% Paramètres du filtre
Fc = 250; % Fréquence de coupure en Hz

N = 9;
NB = 10240;
Fe = 1000;
Te = 1/Fe;
fc1 = 200;
fc2 = 300;


figure(1); clf;hold on;
n = 0:N-1;
% j'ajoute : 
m = n - (N-1)/2; 
h = (sin(2*pi*fc2*m*Te) - sin(2*pi*fc1*m*Te)) ./ (pi * m);
h(m == 0) = 2*(fc2 - fc1)*Te;
%
stem(n, h,'--o',"filled","LineWidth",2);

legend off
grid on;
hold off;
%%
figure(2); clf;
f = linspace(0, 1, NB)*Fe;
H = fft(h, NB);
Hmax = max(abs(H));
groupDelay = -diff(unwrap(angle(H)))/(2*pi*Fe);

[mn,idx1]=min(abs(abs(H(1:floor(NB/4)))-Hmax/2));
    f1=f(idx1);
    hf1=abs(H(idx1));
[mn,idx2]=min(abs(abs(H(floor(NB/4):floor(NB/2)))-Hmax/2));
    idx2 = idx2+floor(NB/4)-1;
    f2=f(idx2);
    hf2=abs(H(idx2));

fLeftNodes  = max(f(groupDelay(1:idx1)<min(groupDelay)/2));
g=f(idx2:end);
fRightNodes = min(g(groupDelay(idx2:floor(NB/2))<min(groupDelay)/2));

lobLeft = find(f==fLeftNodes);
lobRight = find(f==fRightNodes);
lobMid = floor((lobLeft+lobRight)/2);

mx1 = max(abs(H(f<fLeftNodes)));
mx2 = max(abs(H(f(1:floor(NB/2))>fRightNodes)));
[mn,idx1]=min(abs(abs(H(lobLeft:lobMid))-mx1));
    fx1=f(idx1+lobLeft-1);
[mn,idx2]=min(abs(abs(H(lobMid:lobRight))-mx2));
    fx2=f(idx2+lobMid-1);

subplot(2,1,1);hold on;
plot(f, db(H),'linewidth',2);
plot([1,1].*f1,[-100,db(hf1)],'--k');
plot([1,1].*f2,[-100,db(hf2)],'--k');
plot([f1,f2],db([hf1,hf2]),'--k');

plot([1,fx1],[1,1].*db(mx1),'--k');
plot([fx1,fx1],db([mx1,Hmax]),'--k');

plot([fx2,Fe/2],[1,1].*db(mx2),'--k');
plot([fx2,fx2],db([mx2,Hmax]),'--k');

plot([fx1,fx2],db([Hmax,Hmax]),'--k');
xscale log
xlim([1,Fe/2]);
ylim([-50,0]);
xlabel("Frequency [Hz]");
title("|H(f)|")
subplot(2,1,2);hold on;
plot(f(2:end), groupDelay,'linewidth',2);ylim([-3,3]*1e-4);
xlim([0,Fe/2]);
ylim((1+[-1,1].*1e-11)*groupDelay(1));
xlabel("Frequency [Hz]")
title("\phi(f)")


legend
grid on;
hold off;



%%
clc
Lv1 = mx1 , Lvmax = Hmax , Lv2 = mx2 
fL1= fx1 , fR1 = f1
fL2= f2  , fR2 = fx2

p1 = (20*log10(Lvmax/2)-20*log10(Lv1))/log10(fR1/fL1)

p2 = (20*log10(Lv1)-20*log10(Lvmax/2))/log10(fR2/fL2)
