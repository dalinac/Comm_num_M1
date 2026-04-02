function z = zscore(x)
    % Remplace la fonction zscore de la toolbox statistique manquante
    % Centre et réduit la variable x
    z = (x - mean(x)) ./ std(x);
end