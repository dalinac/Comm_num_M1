function idx = my_qamdemod(syms, M)
% MY_QAMDEMOD  Gray-coded square QAM demodulator (minimum Euclidean distance).
%   idx = my_qamdemod(syms, M)
%   syms : complex IQ symbols with unit average power
%   M    : constellation order (must be a perfect square: 4,16,64,256,...)
%   idx  : integer matrix in [0 .. M-1], same size as syms

    K     = sqrt(M);
    nbits = log2(K);
    norm  = sqrt(2*(M-1)/3);

    % Undo power normalisation
    syms_sc = syms * norm;

    % Hard decision on each axis: map to nearest level in {-(K-1),...,K-1}
    I_dec = round((real(syms_sc(:).') + (K-1)) / 2);
    Q_dec = round((imag(syms_sc(:).') + (K-1)) / 2);

    % Clamp to valid range [0 .. K-1]
    I_dec = max(0, min(K-1, I_dec));
    Q_dec = max(0, min(K-1, Q_dec));

    % Binary -> Gray re-encoding
    I_gray = bin2gray_int(I_dec);
    Q_gray = bin2gray_int(Q_dec);

    % Recombine into symbol index
    idx = reshape(bitor(bitshift(Q_gray, nbits), I_gray), size(syms));
end

function g = bin2gray_int(b)
% Binary to Gray code conversion for non-negative integers.
    g = bitxor(b, bitshift(b, -1));
end
