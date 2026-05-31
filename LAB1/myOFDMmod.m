function x = myOFDMmod(Xtf_mn,Fs,Tu,Tg)
    [M,N] = size(Xtf_mn);   % M est le nombre de sous porteuses
                            % N le nombre de symboles

    specN  = round(Fs*Tu); % Le spectre des sous-porteuse a plus d'échantillons 
                    % que le nombre de sous-porteuses pour peu qu Fs> nbre
                    % porteuses !!!!
    x = [];
    for n=1:N
        X_m = zeros(specN,1);
        X_m(2:M+1) = Xtf_mn(:,n); % pour ne pas utiliser la fréquence zéro
                                  % comme première sous-porteuse (celle
                                  % tout à fait à gauche
        ux_m        = ifft(X_m); %expression temporelle du vecteur s[1..M,n]

        gN = Fs*Tg; % on rajoutera gN échantillons au début de chaque segment
                    % x_m du signal temporel x(t) -début de chaque symbole

        x_m = zeros(gN+specN,1);
        x_m(gN+1:gN+specN) = ux_m(1:specN);
        x_m(1:gN) = ux_m(specN-gN+1:specN);

        x = [x;x_m];
    end
end
