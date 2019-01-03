% Script for pitch estimation.

% Written by Pramod Bachhav, June 2018
% Contact : bachhav[at]eurecom[dot]fr, bachhavpramod[at]gmail[dot]com

%   References:
% 
%     1) N. Shah, P.Bachhav, H. Patil, "A Novel Filtering-based F0 Estimation Algorithm
%        with an Application to Voice Conversion", in Proceedings of APSIPA-ASC 2017, Malasia.
%     2) P.Bachhav, H. Patil and T. Patel, "A novel filtering based approach for epoch extraction", 
%        in Proceedings of ICASSP 2015, Brisbane, Australia.
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Copyright (C) DAIICT, Gandhinagar.
%
% This work is licensed under the Creative Commons
% Attribution-NonCommercial-ShareAlike 4.0 International
% License. To view a copy of this license, visit
% http://creativecommons.org/licenses/by-nc-sa/4.0/
% or send a letter to
% Creative Commons, 444 Castro Street, Suite 900,
% Mountain View, California, 94041, USA.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clc; clear all; close all;
addpath('./yaapt');
addpath('./GLOAT')
addpath('./utilities')

[y,Fs]=audioread('./speech_files/rms_arctic_a0001.wav');
MF = 'male';
y=y(:,1);

%% Proposed pitch extraction algorithm
[pitch_contour_FBA t] = pitch_extraction(y',Fs,MF);

%% YAAPT
[pitch_contour_YAAPT, nf, frmrate] = yaapt(y, Fs, 1, [], 0);

%% FFT specs for plots
fft_length = 8192;
frame_size = 25*Fs/1000;    
frame_jump = 5*Fs/1000;

startf     =  0;                  % starting frequency for spectral plots
finalf     =  300;
startt = 1/Fs;
finalt = length(y)/Fs;

N_startf = round((startf/Fs) * fft_length+1);
N_finalf = round((finalf/Fs) * fft_length+1); % add +1 6/3/13

Spec_mag = abs(specgram(y,fft_length,Fs,frame_size,frame_size-frame_jump));
Spec_log = log(Spec_mag + eps);
Spec_log = Spec_log(N_startf:N_finalf,:);
[nrow,ncol] =  size(Spec_log);
tt_spec     =  linspace(startt, finalt, ncol); % X axis
ff_spec     =  linspace(startf, finalf, nrow);  % Y axis

%%
figure
k=3;
ax(1)=subplot(k,1,1);
plot((0:length(y)-1),y/max(abs(y)))
text(1.01,0.6,'(a)','Units', 'Normalized', 'VerticalAlignment', 'Top')

ax(2)=subplot(k,1,2);
imagesc(tt_spec,ff_spec,Spec_log);
colormap(jet);
axis([startt finalt startf finalf]);
axis xy;
hold on;
plot(t/Fs, pitch_contour_FBA,'.k');hold off;
xlabel('Proposed')
text(1.01,0.6,'(b)','Units', 'Normalized', 'VerticalAlignment', 'Top')
ylabel('Hz')

ax(3)=subplot(k,1,3);
imagesc(tt_spec,ff_spec,Spec_log);
colormap(jet);
axis([startt finalt startf finalf]);
axis xy;
hold on;
plot(t(1:length(pitch_contour_YAAPT))/Fs,pitch_contour_YAAPT,'.k')
xlabel('YAAPT')
text(1.01,0.6,'(c)','Units', 'Normalized', 'VerticalAlignment', 'Top')

rmpath('./yaapt');
rmpath('./GLOAT')
rmpath('./utilities')