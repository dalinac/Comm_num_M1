function x = myQAMdemod(y, L)
    M  = 2^L;
    x=zeros(size(y));
    y0 = myQAMmod(0:M-1,L);
    g = median(abs(y))/median(abs(y0));
    y=y./g;
    for it=1:size(y,1)
        qDelta = abs(y(it)-y0);
        [~,idx] = min(qDelta);
        x(it) = idx-1;
    end
end
