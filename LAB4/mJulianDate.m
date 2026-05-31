function [Y, M, D] = mJulianDate(mjd)
    % mJulianDate : Convertit une Date Julienne Modifiée en Année, Mois, Jour.
    % 
    % Entrée :
    %   mjd - Valeur de la Modified Julian Date (ex: 61164)
    %
    % Sorties :
    %   Y - Année
    %   M - Mois
    %   D - Jour (incluant la fraction de jour si mjd est un flottant)

    % Conversion MJD vers Julian Date (JD)
    jd = mjd + 2400000.5;

    % Algorithme de conversion JD -> Calendrier Grégorien
    I = floor(jd + 0.5);
    F = jd + 0.5 - I;
    
    L = I + 68569;
    N = floor(4 * L / 146097);
    L = L - floor((146097 * N + 3) / 4);
    I = floor(4000 * (L + 1) / 1461001);
    L = L - floor(1461 * I / 4) + 31;
    J = floor(80 * L / 2447);
    
    % Calcul des composants
    D = L - floor(2447 * J / 80) + F;
    L = floor(J / 11);
    M = J + 2 - 12 * L;
    Y = 100 * (N - 49) + I + L;
end