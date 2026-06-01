function [pl, dl, pq_vec, tx] = make_grid_tp5(dqam, K, Rsym, Ncp, Mp, step)
    pl = false(K, Rsym);
    pl(1:step:end, 1:step:end) = true;
    dl = ~pl;
    nf = numel(1:step:K);
    nt = numel(1:step:Rsym);
    praw   = randi(Mp, nf*nt, 1) - 1;
    pq_vec = my_qammod(praw, Mp);
    grid   = zeros(K, Rsym);
    grid(dl) = dqam(dl);
    grid(pl) = pq_vec;
    tx = my_ofdmmod(grid, K, Ncp);
end
