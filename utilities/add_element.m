% clc;clear all;close all;
% A = [  1     4     2     6     2];
% ans=add_element(A, [0,0,0,1,0],100)
% ans = [1     4     2     6   100     2]


% function [N]=add_element(A,insertion_loc_aftr,num_to_ins)
function [N]=add_element(A,i,num_to_ins)
% i = (A == insertion_loc_aftr);  % Test for number you want insert after
t = cumsum(i);              
idx = [1 (2:numel(A)) + t(1:end-1)];

newSize = numel(A) + sum(i);
N = ones(newSize,1)*num_to_ins;             % Make this number you want to insert

N(idx) = A;
N=N';