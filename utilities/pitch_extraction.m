function [pitch_contour_ip t1]= pitch_extraction(sig,Fs,MF,fig)

%  This function gives pitch contour for a input speech signal 'sig'
%  This code uses an epoch estimation algorithm using function 'Get_epochs' and
%                    a voice unvoiced decision using function U_UV_decision from GLOAT toolbox (http://tcts.fpms.ac.be/~drugman/Toolbox/)

% Written by Pramod Bachhav, March 2016
% Contact : bachhavpramod[at]gmail[dot]com
% 
%   Input parameters:
%         sig        :  input speech signal as row vector
%         Fs         :  sampling frequency
%         MF         :  MF flag, 'male' for male speech, 'female' for female speech
%           
%   Output parameters:
%         Epochs     :  a vector with length same as speech signal with 1s at epoch locations
%         Epoch_loc  :  a vector consisting of epoch locations
% 
%   References:
% 
%     N. Shah, P.Bachhav, H. Patil, "A Novel Filtering-based F0 Estimation Algorithm
%     with an Application to Voice Conversion", in Proceedings of APSIPA-ASC 2017, Malasia.
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

%%

[Epochs Epoch_loc] = Get_Epochs(sig,Fs,MF); 
% Epochs - a vector with length same as speech signal with 1 at epoch _loc
% Epoch_loc - a vector consisting of epoch locations

orig=sig;

%% voiced unvoiced decision
[sig mask] = U_UV_decision(sig',Fs); sig=sig';                                          
                                          
ind = find(mask == 0);   % ind contains the locations where mask is 0
ind1 =(diff(ind));
 
ind2=find(ind1>1);
check=[1 ind2(1)];

for i=1:length(ind2)-1
    start=ind(ind2(i)+1); % start of seq of zeros in lx
    stop=ind(ind2(i+1));      % stop of seq of zeros in lx
    check=[check; start stop];
end
check = [check; ind(ind2(end)+1) ind(end)]; % to include seq of zeros at the end of the segment

%% Remove epochs in unvoiced region if any 

temp = Epoch_loc;
for j=1:size(check,1)
    temp(find( temp > check(j,1) & temp < check(j,2)))=[];  
end
Epoch_loc_aftr_vuv=temp;
Epochs_aftr_vuv=zeros(1,length(sig));
Epochs_aftr_vuv(temp)=1;
clear temp;

pitch_contour=[];
for i=1:length(Epoch_loc_aftr_vuv)-1
   pitch_contour(i)=Epoch_loc_aftr_vuv(i+1)-Epoch_loc_aftr_vuv(i);
end
pitch_contour=[pitch_contour,pitch_contour(end)];

%% Make pitch values at the end of voiced portion == to avg pitch value

xyz = [];
xyz = (find(pitch_contour > 20*0.001*Fs)); % locations where pitch values are greater than 1/(20ms)=500Hz

pitch_contour(xyz) = 0;
Avg_pitch = mean(pitch_contour);
pitch_contour(xyz) = Avg_pitch;
 
%% 
t=(0:length(sig)-1)/(Fs);  % time in msec;
 
pc_time=pitch_contour ; % pc_time = gives time difference between two epochs in terms of number of samples

pitch_contour=Fs./pitch_contour; % get F0_contour 
Avg_pitch = Fs./Avg_pitch; % avg pitch in Hz

%% Insert zeros at the start and end of each voiced region for intepolation
% This part is hard coded to perform interpolation. 

tmp=0; tmp1=[];

Epoch_loc_aftr_vuv_for_ip=[1 Epoch_loc_aftr_vuv(1)-1 Epoch_loc_aftr_vuv]; 
% to create an array [1 x1 x2 x3 x4 .....] where xi's are epoch locations
pitch_contour_to_ip=[0 0 pitch_contour];    
% it is pitch contour to be interpolated 

for j=2:size(check,1)
if check(j,2)-check(j,1)>300  % to exclude few cases if very small unvoicing comes inside voiced region and no epochs get detected by the epoch estimation algo
    temp=find( Epoch_loc_aftr_vuv_for_ip < check(j,2) );  
    
    if temp(end)-tmp>2 
        tmp=temp(end);
        tmp1=[tmp1 tmp];

        if Epoch_loc_aftr_vuv(end)>check(j,1) % 
            A=zeros(1,length(Epoch_loc_aftr_vuv_for_ip)); A(tmp)=1;
            Epoch_loc_aftr_vuv_for_ip=add_element(Epoch_loc_aftr_vuv_for_ip,A,Epoch_loc_aftr_vuv_for_ip(tmp)+1);
            pitch_contour_to_ip=add_element(pitch_contour_to_ip,A,0);   

            A=zeros(1,length(Epoch_loc_aftr_vuv_for_ip)); A(tmp+1)=1;  
            Epoch_loc_aftr_vuv_for_ip=add_element(Epoch_loc_aftr_vuv_for_ip,A,Epoch_loc_aftr_vuv_for_ip(tmp+2)-1);
            pitch_contour_to_ip=add_element(pitch_contour_to_ip,A,0);
        else
            % do nothing
        end
    end
end
end
pitch_contour_to_ip=[ pitch_contour_to_ip 0 0];
Epoch_loc_aftr_vuv_for_ip=[Epoch_loc_aftr_vuv_for_ip Epoch_loc_aftr_vuv_for_ip(end)+1 length(sig)]; % for last epoch entry we keep pitch value 0 for ip

xyz=pitch_contour_to_ip;

%% Remove pitch halving
temp1=(find(pitch_contour_to_ip < 0.6*Avg_pitch & pitch_contour_to_ip > 0)); 
% second condn to avoid zeros which are inserted manually during hard coding above
pitch_contour_to_ip(temp1) = Avg_pitch;  % done on 09/05/15   

%% Remove pitch doubling
pitch_contour_to_ip(find(pitch_contour_to_ip > 1.5*Avg_pitch))=Avg_pitch;

%% %% Inerpolate the F0 contour to get pitch values at required time intervals
% Here interpolation is performed at every 5ms 

t1 = [1:10*0.001*Fs:length(sig)];
pitch_contour_ip = interp1(Epoch_loc_aftr_vuv_for_ip,pitch_contour_to_ip,t1); % pitch contour after interpolation
