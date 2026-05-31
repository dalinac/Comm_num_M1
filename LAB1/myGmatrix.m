function G = myGmatrix(Mreel,N,pathDelays,pathDopplers,pathGains)
    MN = Mreel*N;
    len = length(pathDelays);  % number of paths
    mx = ceil(max(pathDelays));
    g = zeros(mx+1,MN);
    for it = 1:len
        phi = ((0:MN-1)-pathDelays(it));
        gnext = pathGains(it) * exp(1i*2*pi* pathDopplers(it) * phi/MN);
        g(pathDelays(it)+1,:) = g(pathDelays(it)+1,:) + gnext;
    end    

    G = zeros(MN,MN);
    shortListDelay = unique(pathDelays);
    for it = shortListDelay
        G = G + diag(g(it+1,it+1:end),-it);
    end
end