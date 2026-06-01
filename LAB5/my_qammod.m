function syms = my_qammod(data, M)
% MY_QAMMOD  Gray-coded square QAM modulator, unit average power.
%   syms = my_qammod(data, M)
%   data : integer matrix with values in [0 .. M-1]
%   M    : constellation order (must be a perfect square: 4,16,64,256,...)
%   syms : complex IQ symbols, same size as data

    K     = sqrt(M);          % points per axis
    nbits = log2(K);          % bits per axis
    norm  = sqrt(2*(M-1)/3);  % RMS normalisation

    sym_flat = data(:).';

    % Split symbol index into high (Q axis) and low (I axis) Gray-coded parts
    hi = bitshift(sym_flat, -nbits);   % upper nbits
    lo = bitand(sym_flat, K-1);        % lower nbits

    % Gray -> binary (natural) for each axis
    I_idx = gray2bin_int(lo, nbits);
    Q_idx = gray2bin_int(hi, nbits);

    % Map [0..K-1] -> {-(K-1), -(K-3), ..., K-1}
    I_val = 2*I_idx - (K-1);
    Q_val = 2*Q_idx - (K-1);

    syms = reshape((I_val + 1j*Q_val) / norm, size(data));
end

function b = gray2bin_int(g, nbits)
% Iterative Gray-to-binary conversion for integers.
    b  = g;
    sh = 1;
    while sh < nbits
        b  = bitxor(b, bitshift(b, -sh));
        sh = sh * 2;
    end
end
