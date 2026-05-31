function [FrameStartpoints] = myGetFrameSart(Signal)

width = 8;                                              

Signal_Pegel = zeros(1,length(Signal));
FrameStartpoints = zeros(1,1000);
Delay = 2^6;
Pause = 2^13;

ABS_Signal = abs(Signal);
 
for i=1:length(Signal)-1
     Signal_Pegel(i+1) = Signal_Pegel(i) - Signal_Pegel(i)/width + ABS_Signal(i);       
end
 

index = 0;
for i=1+Delay:1:length(Signal)-1
    if (index < i)                                                         
         if (Signal_Pegel(i-Delay) < ABS_Signal(i))                      
             FrameStartpoints(1) = i;                                      
             FrameStartpoints = circshift(FrameStartpoints,[0 -1]);
             index=i+Pause;                                                 
         end
    end
end

y= find(FrameStartpoints>1000);
FrameStartpoints = FrameStartpoints(min(y):length(FrameStartpoints));     

