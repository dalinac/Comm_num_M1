function ser = ser_shift_tp5(dqam, dref, K, Rsym, Ncp, Mp, Md, step, M, SNR, att, delay, fd, Fs)
    nt    = numel(1:step:Rsym);
    t_pil = 1:step:Rsym;
    t_all = 1:Rsym;
    H_re  = zeros(K, nt);
    H_im  = zeros(K, nt);
    cnt   = zeros(K, 1);
    tx_last = []; dl_last = [];

    for trial = 1:M
        foff   = mod(trial-1, step);
        pl_t   = false(K, Rsym);
        pl_t(1+foff:step:end, 1:step:end) = true;
        dl_t   = ~pl_t;
        nf_t   = numel(1+foff:step:K);
        praw_t = randi(Mp, nf_t*nt, 1) - 1;
        pq_t   = my_qammod(praw_t, Mp);
        grid_t = zeros(K, Rsym);
        grid_t(dl_t) = dqam(dl_t);
        grid_t(pl_t) = pq_t;
        tx_t   = my_ofdmmod(grid_t, K, Ncp);
        t_t    = (0:numel(tx_t)-1)' / Fs;
        rx_n   = addNoise(mp_channel_tp5(tx_t, att, delay, fd, t_t), SNR);
        g_t    = my_ofdmdemod(rx_n, K, Ncp);
        H_t    = reshape(g_t(pl_t), nf_t, nt) ./ reshape(pq_t, nf_t, nt);
        rows   = 1+foff:step:K;
        H_re(rows,:) = H_re(rows,:) + real(H_t);
        H_im(rows,:) = H_im(rows,:) + imag(H_t);
        cnt(rows)    = cnt(rows) + 1;
        if trial == M; tx_last = tx_t; dl_last = dl_t; end
    end

    H_est = zeros(K, nt);
    for fi = 1:K
        if cnt(fi) > 0
            H_est(fi,:) = (H_re(fi,:) + 1j*H_im(fi,:)) / cnt(fi);
        else
            H_est(fi,:) = 1;
        end
    end

    H_full = zeros(K, Rsym);
    for fi = 1:K
        H_full(fi,:) = interp1(t_pil, H_est(fi,:), t_all, 'spline', 'extrap');
    end

    t_last = (0:numel(tx_last)-1)' / Fs;
    rx_n   = addNoise(mp_channel_tp5(tx_last, att, delay, fd, t_last), SNR);
    g_last = my_ofdmdemod(rx_n, K, Ncp);
    ge     = g_last ./ H_full;
    dec    = my_qamdemod(ge(dl_last), Md);
    ser    = sum(dec ~= dref(dl_last)) / numel(dec);
end
