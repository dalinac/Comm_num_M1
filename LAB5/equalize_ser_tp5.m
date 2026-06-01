function ser = equalize_ser_tp5(rx, K, Ncp, Rsym, pl, dl, pq_vec, dref, Md, step)
    nf = numel(1:step:K);
    nt = numel(1:step:Rsym);
    g  = my_ofdmdemod(rx, K, Ncp);
    H  = reshape(g(pl), nf, nt) ./ reshape(pq_vec, nf, nt);
    [X,Y]   = meshgrid(1:step:Rsym, 1:step:K);
    [Xq,Yq] = meshgrid(1:Rsym,      1:K);
    Hf  = interp2(X, Y, H, Xq, Yq, 'spline');
    ge  = g ./ Hf;
    dec = my_qamdemod(ge(dl), Md);
    ser = sum(dec ~= dref(dl)) / numel(dec);
end
