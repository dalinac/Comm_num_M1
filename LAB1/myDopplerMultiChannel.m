function y=myDopplerMultiChannel(x,pathDelays,pathDopplers,pathGains)
x=x(:)';
t=(0:length(x)-1)/(length(x)-1);
num_paths = length(pathDelays);  % Nombre de trajets
mx = ceil(max(pathDelays));
y = zeros(1,length(x)+mx); 

for k = 1:num_paths
    doppler_shift = exp(-1j*2*pi*pathDopplers(k)*t);
    Doppler_x = x .* doppler_shift;
    delayed_signal = [zeros(1, round(pathDelays(k))), Doppler_x];
    len = length(delayed_signal);
    delayed_signal = [delayed_signal,zeros(1,length(x)+mx-len)];
    y = y + pathGains(k) * delayed_signal ; % Somme des contributions
end
y=y(1:length(x))';
