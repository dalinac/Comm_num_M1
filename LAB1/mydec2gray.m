function g = mydec2gray(d,n)
    p=dec2bin(d,n);
    len = size(p,1);
    g=p;
    for it=1:len
        b=p(it,:);
        g(it,1) = b(1);
        for i = 2 : length(b);
            x = xor(str2num(b(i-1)), str2num(b(i)));
            g(it,i) = num2str(x);
        end
    end
    g=bin2dec(g);
end