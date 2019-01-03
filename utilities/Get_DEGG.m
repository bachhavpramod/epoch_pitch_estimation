function Final_DEGG = Get_DEGG(EGG,Fs)

% Written by Pramod Bachhav, Sept. 2015
% Inputs  : 	EGG         :  Electro-glottograph signal
%               Fs          :  Sampling frequency
% Outputs : 	Final_DEGG  :  Reference epoch locations i.e., ground truth

EGG=EGG';

DEGG=EGG;

DEGG=-DEGG;
DEGG=(DEGG./norm(DEGG));
% disp(['size of degg ',num2str(size(DEGG))])

[peaks loc_peaks]=findpeaks(DEGG); 
PP=max(DEGG);
Epoch_loc=loc_peaks(find(peaks>PP/9)); % to remove spurious negative peaks
Epoch=zeros(1,length(DEGG));
Epoch(Epoch_loc)=1;
X=Epoch_loc;
count=0;
index=[];
k=1;
Th=2*Fs*0.001; % number of samples corresponding to 2 ms
for i=2:length(Epoch_loc)
     if (Epoch_loc(i)-Epoch_loc(i-1))<Th
             index=[index k];
     else
          index=[index k];
          k=k+1;
     end
end
PPP=diff(index);
ppp=find(PPP~=0);
k=1;
temp=[];
for i=1:length(ppp)
    [a b]=max(DEGG(Epoch_loc(k:ppp(i))));
    temp(i)=(Epoch_loc(k+b-1));
    k=ppp(i)+1;
end
% size(Epoch_loc)
if (Epoch_loc(end-1)-temp(end))<Th
    [a b]=max([DEGG(Epoch_loc(end-1)) DEGG(temp(end))]);
    if b==1
        temp(end)=Epoch_loc(end-1);
    else
        temp(end)=temp(end);
    end
else temp=[temp Epoch_loc(end-1)];
end
if  (Epoch_loc(end)-temp(end))<Th
    [a b]=max([DEGG(Epoch_loc(end)) DEGG(temp(end))]);    
    if b==1
        temp(end)=Epoch_loc(end);
    else
        temp(end)=temp(end);
    end
else temp=[temp Epoch_loc(end)];  
end
Final_DEGG=zeros(1,length(DEGG));
Final_DEGG(temp)=1;

% figure;
% ax(1)=subplot(211)
% plot(DEGG)
% ax(2)=subplot(212)
% plot(Final1)
% linkaxes(ax,'x')
% figure