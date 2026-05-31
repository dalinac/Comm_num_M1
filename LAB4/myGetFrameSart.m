function [FrameStartpoints] = myGetFrameSart(Signal)

width = 8;

Signal_Pegel = zeros(1,length(Signal));
FrameStartpoints = zeros(1,1000);
Delay = 2^6;
Pause = 2^13;

a = [1, -(1 - 1/width)];
b = [0, 1];

ABS_Signal = abs(Signal);

Signal_Pegel = filter(b, a, ABS_Signal, Signal_Pegel(1));
%
%for i=1:length(Signal)-1
%     Signal_Pegel(i+1) = Signal_Pegel(i) - Signal_Pegel(i)/width + ABS_Signal(i);
%end
indices_candidats = find(Signal_Pegel(1:end-Delay-1) < ABS_Signal(1+Delay:end-1)) + Delay;

if isempty(indices_candidats)
    FrameStartpoints = [];
else
    resultats = [];
    dernier_index = -inf;

    for idx = indices_candidats
        if idx >= dernier_index
            resultats=[resultats,idx];
            dernier_index = idx + Pause;
        end
    end
    FrameStartpoints = resultats;
end

%
%index = 0;
%for i=1+Delay:1:length(Signal)-1
%    if (index < i)
%         if (Signal_Pegel(i-Delay) < ABS_Signal(i))
%             FrameStartpoints(1) = i;
%             FrameStartpoints = circshift(FrameStartpoints,[0 -1]);
%             index=i+Pause;
%         end
%    end
%end



y= find(FrameStartpoints>1000);
FrameStartpoints = FrameStartpoints(min(y):length(FrameStartpoints));

