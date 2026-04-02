clc; 
clear; 
% rectangulaire, triangulaire, Hann, Hamming, Blackman, 
% Gaussian, Welch, puissance de sinus, Flap-top, Tukey, 
% Lanczos, Kaiser, Blackman–Harris, 
% Blackman–Nuttall

N=101;
NB=10240;

ff=[rectwin(N),triang(N),hann(N),hamming(N)];
ff=[ff,blackman(N),gausswin(N),welchwin(N),sinepow(N,4)];
ff=[ff,flattopwin(N),tukeywin(N),lanczoswin(N),kaiser(N)];
ff=[ff,blackmanharris(N),nuttallwin(N)];

winNames={'rectwin','triang','hann','hamming','blackman','gausswin','welchwin','sinepow','flattopwin','tukeywin','lanczoswin','kaiser','blackmanharris','nuttallwin'};

figure(1);clf;hold on;
for it=1:7
    w=ff(:,it);
    [f,W]= myResp(w,NB);

    subplot(2,7,it);hold on;
        plot([0:N-1],w);
        title({'Réponse inpulsionnelle de ',['<',winNames{it},'>']});
    
    subplot(2,7,7+it);hold on;
        plot(f,20*log10(abs(W)));    
        title({'Fonction de transfert de ',['<',winNames{it},'>']});
        xlim([0,0.1]);
    
end
figure(2);clf;hold on;
for it=1:7
    w=ff(:,it+7);
    [f,W]= myResp(w,NB);

    subplot(2,7,it);hold on;
        plot([0:N-1],w);
        title({'Réponse inpulsionnelle de ',['<',winNames{it+7},'>']});
    
    subplot(2,7,7+it);hold on;
        plot(f,20*log10(abs(W)));    
        title({'Fonction de transfert de ',['<',winNames{it+7},'>']});
        xlim([0,0.1]);
    
end
%%
function w = welchwin(n)
  m = floor(n/2); k = (0:m-1)';
  w = 1 - (2*k/n - 1).^2;
  if(mod(n, 2) ~= 0), w = [w; 1]; end
  w = [w; flipud(w(1:m, 1))];
end

function w = lanczoswin(n)
  w = sinc(2*[0:n-1]/(n-1)-1);
  w=w';
end


function w = sinepow(n,alpha)
  w = sin(pi*[0:n-1]/(n-1)).^alpha;
  w = w';
end