function [deInt_fftTab] = myFreqDeInterleave(fname, fftTab)
    % Désentrelacement fréquentiel mode I (table EN 300 401 / polycopié).
    % Tri selon l’indice « physique » (col. 5 → col. 2 de nTab), troncature du
    % quart central : pour chaque ligne r, déplace fftTab(:, r) vers la colonne
    % logique nTab(r,1)+1 (col. 4 du .mat = indice 0-based).
    load(fname); % i_PIi_dn_n_k, interL1

    nTab = sortrows(i_PIi_dn_n_k(:, 4:5), 2);
    nTab = nTab(interL1 / 4 + 1 : end, :);

    nRows = size(nTab, 1);
    nCols = size(fftTab, 2);

    idx = double(nTab(:, 1)) + 1;

    deInt_fftTab = zeros(size(fftTab));
    for r = 1:nRows
        deInt_fftTab(:, idx(r)) = fftTab(:, r);
    end
end