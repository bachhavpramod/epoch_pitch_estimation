function [Epochs Epoch_loc] = Get_Epochs(x,Fs,MF)

%  This function gives glottal closure instances/epochs for a speech signal

% Written by Pramod Bachhav, Sept. 2015
% Contact : bachhavpramod[at]gmail[dot]com
% 
%   Input parameters:
%         x          :  input speech signal as row vector
%         Fs         :  sampling frequency
%         MF         :  MF flag, 'male' for male speech, 'female' for female speech
%           
%   Output parameters:
%         Epochs     :  a vector with length same as speech signal with 1s at epoch locations
%         Epoch_loc  :  a vector consisting of epoch locations
% 
%   References:
% 
%     P.Bachhav, H. Patil and T. Patel, "A novel filtering based approach for epoch extraction", 
%     in Proceedings of ICASSP 2015, Brisbane, Australia.
%
%     Users are REQUESTED to cite the above paper if this function is used. 
%  
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Copyright (C).
%
% This work is licensed under the Creative Commons
% Attribution-NonCommercial-ShareAlike 4.0 International
% License. To view a copy of this license, visit
% http://creativecommons.org/licenses/by-nc-sa/4.0/
% or send a letter to
% Creative Commons, 444 Castro Street, Suite 900,
% Mountain View, California, 94041, USA.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

y=x;

%% positive clipping and inversion
x=-x;
x(find(x<0))=0;

%% negative clipping
%  x(find(x<0))=0;

if strcmp(MF,'male')
    Fc = 180;
elseif strcmp(MF,'female')
    Fc = 250;
end

d = fdesign.lowpass;
% set(d,'specification');  % gives the list of possible combinations of specifications for object 'd'
% d = fdesign.lowpass('Fp,Fst,Ap,Ast',120/(Fs/2),300/(Fs/2),10,200)   
% I chose a specification combination which allows to specify 'passband edge frequency','stop band freq','passband ripple' and 'stop band attenuation'

d = fdesign.lowpass('N,Fc',3,Fc/(Fs/2));
hd = design(d,'butter');  % to get details type 'help(fdesign.lowpass,'butter')' or 'help(d,'butter')' 
x_lp=filter(hd,x);    % if fdesign is used

%% Calulate group delay at cutoff frequency
[gd,w]=grpdelay(hd,2048);
wc=2*pi*Fc/Fs;
[a b]=min(abs(w-wc));
delay=round(gd(b));
f=w*Fs/(2*pi);

%% adjust LPF delay
x_lp=[x_lp(delay+1:end),zeros(1,delay)];

%%
[peaks loc_peaks]=findpeaks(x_lp);
[valleys loc_valleys]=findpeaks(-x_lp);


if loc_peaks(1)<loc_valleys(1)
      peaks(1)=[];
      loc_peaks(1)=[];
end

m=min(length(valleys),length(peaks));
peaks=peaks(1:m);
valleys=-valleys(1:m);

loc_peaks=loc_peaks(1:m); 
loc_valleys=loc_valleys(1:m);

Epochs=zeros(1,length(y));

%% apply thresholding
p_v_diff = peaks-valleys;
threshold1 = mean(abs(p_v_diff))/12;
p_v_diff(find(p_v_diff<threshold1))=0;
Epochs(loc_peaks) = p_v_diff;

%% Removing false alarms
Epochs(loc_peaks) = p_v_diff;  % loc_peaks contains location of all peaks
Epoch_loc = find(Epochs~=0);  % Epoch_loc conains location of those peaks which which are above threshold1.

count=0; 
False_alarms=[];
j=1;
threshold2=0.7;

for i=2:length(Epoch_loc)-1
    if Epochs(Epoch_loc(i))<Epochs(Epoch_loc(i-1)) && Epochs(Epoch_loc(i))<Epochs(Epoch_loc(i+1))
        if Epochs(Epoch_loc(i))<threshold2*Epochs(Epoch_loc(i-1)) || Epochs(Epoch_loc(i))<threshold2*Epochs(Epoch_loc(i+1))
            False_alarms(j)=Epoch_loc(i);
            count=count+1;
            j=j+1;
        end
    end
end
Epochs(False_alarms)=0;
Epochs(find(Epochs~=0))=1;
Epoch_loc=find(Epochs~=0);
