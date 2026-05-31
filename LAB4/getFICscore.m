function score = getFICscore(Rsym, K, DeintFFTtab)
% Renvoie le nombre de FIB dont le CRC est valide (0..12) pour une trame DAB.
% Version "silencieuse" et programmable de la verification CRC realisee
% dans dispFICinfo.m : utile pour balayages parametriques.
%
% Entrees
%   Rsym         : nombre de symboles OFDM par trame (76 en mode I)
%   K            : nombre de sous-porteuses (1536)
%   DeintFFTtab  : matrice (Rsym-1) x K des symboles D-QPSK desentrelaces
%
% Sortie
%   score        : entier dans [0..12], nombre de FIB valides

    Data = zeros(1, (Rsym-1)*K*2);
    for f = 1:Rsym-2
        Data(1+(f-1)*K*2:(f)*K*2) = [real(DeintFFTtab(f,:)) imag(DeintFFTtab(f,:))];
    end

    FIC = zeros(4, 2*K*3/4);
    for r = 0:3
        FIC(r+1,:) = Data(r*2304+1:(r+1)*2304);
    end

    DataDep = [depuncturing(FIC(:,1:2016),16) ...
               depuncturing(FIC(:,2017:2292),15) ...
               depuncturing(FIC(:,2293:2304),8)];

    DataVit = zeros(4, 768+6);
    for f = 1:4
        DataVit(f,:) = DABViterbi(DataDep(f,:));
    end
    DataVit = DataVit(:,1:end-6);

    DataEne = zeros(size(DataVit));
    for m = 1:4
        DataEne(m,:) = xor(DataVit(m,:), EnergyDispGen(768));
    end

    FIB = reshape(DataEne', 256, 12)';
    score = 0;
    for k = 1:12
        score = score + CRC16(FIB(k,:));
    end
end
