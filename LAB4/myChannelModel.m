function Signal_out = myChannelModel(Signal, delta_f, SNR_dB, Fs)
    % Dérive de fréquence : multiplie par exp(j*2π*Δf*t)
    t = (0:length(Signal)-1)' / Fs;
    Signal_out = Signal(:) .* exp(1j * 2*pi * delta_f * t);

    % Bruit AWGN
    if SNR_dB < inf
        P_signal = mean(abs(Signal_out).^2);
        P_bruit  = P_signal / 10^(SNR_dB/10);
        bruit    = sqrt(P_bruit/2) * (randn(size(Signal_out)) + 1j*randn(size(Signal_out)));
        Signal_out = Signal_out + bruit;
    end

    Signal_out = Signal_out(:)';
end
