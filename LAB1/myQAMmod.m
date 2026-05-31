function y = myQAMmod(vals, L)
    M = 2^L; % Taille de la modulation QAM
    k = sqrt(M); % Nombre de niveaux par axe (supposé carré)
    
    if mod(log2(M),2) ~= 0
        error('Le nombre de bits par symbole doit être pair pour une QAM carrée.');
    end
    
    % Générer la constellation QAM (M-QAM)
    tab = (-k+1:2:k-1);
    idx = mydec2gray(0:k-1,log(k)/log(2));

    re = repmat(tab(idx+1), k, 1);
    im = repmat(-tab(idx+1)', 1, k);
    
    % Normalisation pour une puissance moyenne de 1
    constellation = (re(:) + 1j * im(:)) / sqrt(mean(abs(re(:) + 1j * im(:)).^2));
    
    % Mapper les indices sur la constellation
    y = constellation( vals + 1);
end

