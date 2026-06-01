function ser = ser_fixed_tp5(rx_c, K, Ncp, Rsym, pl, dl, pq_vec, dref, Md, step, M, SNR)
    nf = numel(1:step:K);
    nt = numel(1:step:Rsym);
    H_acc = zeros(nf, nt);
    for i = 1:M
        g     = my_ofdmdemod(addNoise(rx_c, SNR), K, Ncp);
        H_acc = H_acc + reshape(g(pl), nf, nt) ./ reshape(pq_vec, nf, nt);
    end
    H_avg = H_acc / M;
    [X,Y]   = meshgrid(1:step:Rsym, 1:step:K);
    [Xq,Yq] = meshgrid(1:Rsym,      1:K);
    Hf  = interp2(X, Y, H_avg, Xq, Yq, 'spline');
    g   = my_ofdmdemod(addNoise(rx_c, SNR), K, Ncp);
    ge  = g ./ Hf;
    dec = my_qamdemod(ge(dl), Md);
    ser = sum(dec ~= dref(dl)) / numel(dec);
end
