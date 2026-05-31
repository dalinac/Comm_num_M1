function [fft_Array] = SymbolFFT(Signal, it, startFrame, Rsym, K, TsymFS, Offset, TuFs)
    TsymFS = round(TsymFS);
    TuFs   = round(TuFs);
    center = TuFs/2 + 1;

    raw_fft = zeros(Rsym, K);
    for l = 0:Rsym-1
        idxStart = startFrame(it) + l*TsymFS + Offset;
        segment  = Signal(idxStart : idxStart + TuFs - 1);
        Y = fftshift(fft(segment));
        raw_fft(l+1,:) = [Y(center-K/2:center-1), Y(center+1:center+K/2)];
    end

    % Démodulation DQPSK : phase différentielle entre symboles consécutifs
    for l = 1:Rsym-1
        fft_Array(l,:) = raw_fft(l+1,:) .* conj(raw_fft(l,:));
    end
end
