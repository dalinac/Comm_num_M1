function rx = mp_channel_tp5(tx, att, delay, fd, t)
    rx = tx + att * circshift(tx, delay) .* exp(2j*pi*fd*t);
end
