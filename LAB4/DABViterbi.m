function [BitDef] = DABViterbi(yIn)
    % --- Initialisation fixe ---
    Generator = [1 0 1 1 0 1 1; 1 1 1 1 0 0 1; 1 1 0 0 1 0 1; 1 0 1 1 0 1 1];
    [nGen, K_plus_1] = size(Generator);
    SpeicherTabs = K_plus_1 - 1;
    numStates = 2^SpeicherTabs;

    % Mise en forme du signal
    y = reshape(yIn, nGen, [])';
    MemDeep = 5 * SpeicherTabs;
    y = [y; zeros(MemDeep, nGen)];
    nSymbols = size(y, 1);

    % --- PRÉ-CALCUL DE LA TREILLIS (VITAL) ---
    % On calcule les sorties (références) pour chaque transition possible
    % OutTable(état, 1) = sortie pour bit 0, OutTable(état, 2) = sortie pour bit 1
    OutTable = zeros(numStates, 2, nGen);
    PrevStates = zeros(numStates, 2); % États parents

    for state = 0:numStates-1
        % Pour chaque état, on regarde les deux origines possibles (Viterbi inversé)
        % Dans votre code : Pfad définit les états précédents
        p1 = mod(state * 2, numStates);
        p2 = mod(state * 2 + 1, numStates);
        PrevStates(state+1, :) = [p1, p2];

        % Pré-calcul des sorties BPSK attendues
        bits1 = [floor(state/(numStates/2)), dec2bin(p1, SpeicherTabs)-'0'];
        bits2 = [floor(state/(numStates/2)), dec2bin(p2, SpeicherTabs)-'0'];

        OutTable(state+1, 1, :) = 1 - 2 * mod(bits1 * Generator', 2);
        OutTable(state+1, 2, :) = 1 - 2 * mod(bits2 * Generator', 2);
    end

    % --- Initialisation des mémoires ---
    Pfadspeicher = zeros(numStates, nSymbols); % On stocke tout, on ne shift plus
    Metrik = -1000 * ones(numStates, 2);
    Metrik(1, 1) = 0;

    BitDef = zeros(1, nSymbols - MemDeep);

    % --- BOUCLE PRINCIPALE OPTIMISÉE ---
    for i = 1:nSymbols
        current_y = y(i, :);

        % Calcul des métriques de branche pour tous les états d'un coup
        % On compare le chemin venant de p1 et p2
        m1 = squeeze(OutTable(:, 1, :)) * current_y' + Metrik(PrevStates(:,1)+1, 1);
        m2 = squeeze(OutTable(:, 2, :)) * current_y' + Metrik(PrevStates(:,2)+1, 1);

        % Choix du survivant (Vectorisé)
        idx1 = m1 > m2;
        Metrik(idx1, 2) = m1(idx1);
        Metrik(~idx1, 2) = m2(~idx1);

        % Stockage du survivant (sans circshift)
        Pfadspeicher(idx1, i) = PrevStates(idx1, 1);
        Pfadspeicher(~idx1, i) = PrevStates(~idx1, 2);

        % Traceback (Rétropropagation)
        if i > MemDeep
            [~, Pos] = max(Metrik(:, 2));
            currPos = Pos - 1;
            for p = 0:MemDeep-1
                currPos = Pfadspeicher(currPos + 1, i - p);
            end

            % Le bit est déterminé par l'état à l'instant (i - MemDeep)
            BitDef(i - MemDeep) = currPos >= (numStates / 2);
        end

        % Mise à jour des métriques (simple copie au lieu de circshift)
        Metrik(:, 1) = Metrik(:, 2);
    end
end
