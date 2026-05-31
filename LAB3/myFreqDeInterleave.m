function [deInt_fftTab] = myFreqDeInterleave(fname, fftTab)
    load(fname);
    valid    = i_PIi_dn_n_k(:,4) ~= -1;
    n_idx    = i_PIi_dn_n_k(valid, 4);
    k_idx    = i_PIi_dn_n_k(valid, 5);
    k_matlab = zeros(size(k_idx));
    k_matlab(k_idx < 0) = k_idx(k_idx < 0) + 769;
    k_matlab(k_idx > 0) = k_idx(k_idx > 0) + 768;
    valid2   = k_matlab > 0;
    n_idx    = n_idx(valid2);
    k_matlab = k_matlab(valid2);
    deInt_fftTab = zeros(size(fftTab));
    for i = 1:length(n_idx)
        deInt_fftTab(:, n_idx(i)+1) = fftTab(:, k_matlab(i));
    end
end
