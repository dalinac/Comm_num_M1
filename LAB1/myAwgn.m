function y = myAwgn(sig,reqSNR)
    reqSNR = 10.^(reqSNR./10);
    sigPower = sum(abs(sig(:)).^2)/numel(sig); 
    noisePower = sigPower./reqSNR;
    y = sig + sqrt(noisePower).*randn(size(sig),"like",sig);
    % y=awgn(sig,reqSNR,'measured');
end 