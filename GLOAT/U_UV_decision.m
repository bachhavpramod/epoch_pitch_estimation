function [voiced VUVDecisions2] = U_UV_decision(wave,Fs)

F0min=80;
F0max=240;

%% Pitch tracking using a method based on the Summation of the Residual Harmonics
framesize=round(100/1000*Fs);
    shift=round(10/1000*Fs);
[f0,VUVDecisions,SRHVal] = SRH_PitchTracking(wave,framesize,shift,Fs,F0min,F0max);

VUVDecisions2=zeros(1,length(wave));
HopSize=round(10/1000*Fs);
for k=1:length(VUVDecisions)
    VUVDecisions2((k-1)*HopSize+1:k*HopSize)=VUVDecisions(k);    
end
%%
VUVDecisions2=VUVDecisions2(1:length(wave));
%%

wave=wave/max(abs(wave));
voiced=wave'.*VUVDecisions2(1:length(wave));
voiced=voiced';
