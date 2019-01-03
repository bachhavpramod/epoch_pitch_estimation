% Script for epoch estimation.

% Written by Pramod Bachhav, June 2018
% Contact : bachhav[at]eurecom[dot]fr, bachhavpramod[at]gmail[dot]com

%   References:
% 
%     P.Bachhav, H. Patil and T. Patel, "A novel filtering based approach for epoch extraction", 
%     in Proceedings of ICASSP 2015, Brisbane, Australia.
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
addpath('./utilities')

[speech,Fs]=audioread('./speech_files/bdl_arctic_a0012.wav');
MF = 'male';
EGG = speech(:,2);
speech = speech(:,1);

%% Proposed epoch estimation algorithm
[Epochs epoch_locations] = Get_Epochs(speech',Fs,MF);

[DEGG] =  Get_DEGG(EGG,Fs);

figure;
ax(1)=subplot(311);
plot(speech)
title('Speech signal')
ax(2)=subplot(312)
stem(0.5*Epochs)
ylim([0,1])
title('Estimated epochs/GCIs')
ax(3)=subplot(313)
stem(0.5*DEGG)
ylim([0,1])
title('Ground truth DEGG')
linkaxes(ax,'x')

rmpath('./utilities')