function plot_fourierp(LAN,nch,t)
%  <*LAN)<]  
%  PLOT_FOURIERP do a plot of FT of the channel 'nch' and the trials 't'
%  plot_fourierp(LAN,'Cz') Do the mean od the electrode Cz
%  plot_fourierp(LAN,[ 10 11],5) Do  plots of the 5th trial for the
%                               electrodes number 10 and 11
%
% v.0.0.1
% 05.08.2011
% Pablo Billeke

if nargin < 3 || t==0
    ift=false;
else
    ift=true;
end
%
if ischar(nch)
    nch = label2idx_elec(LAN.chanlocs,nch);
end
%
data = LAN.freq.fourierp.data ;
avgfft=LAN.freq.fourierp.mean  ;
stdfft = LAN.freq.fourierp.std  ;
f = LAN.freq.fourierp.freq;
lslog = LAN.freq.fourierp.lslog;
lilog = LAN.freq.fourierp.lilog;
chanlocs = LAN.chanlocs;
try 
    mt = strcmp(LAN.freq.fourierp.cfg.method,'mt');
catch
    mt=0;
end
clear LAN

for ch = nch
%if ifplot
% Plot single-sided amplitude spectrum.
lim = find_approx(f,100);
figure('Name',[ chanlocs(ch).labels  ' Channel ' ],'NumberTitle','off','MenuBar', 'none')
plot(f(2+mt:lim),log10(avgfft(ch,2+mt:lim)),'LineWidth',2), hold on;
plot(f(2+mt:lim),lslog(ch,2+mt:lim) ,'Color',[0.5 0.5 0.5])
plot(f(2+mt:lim),lilog(ch,2+mt:lim) ,'Color',[0.5 0.5 0.5])
if ift
    plot(f(2+mt:lim),log10(data(ch,2+mt:lim,t)),'Color','red','LineWidth',2)
end
xlim([f(2+mt),f(lim)]);
%min(log(avgfft(ch,2+mt:lim)))-1
ylim([-10 , max(log(avgfft(ch,2+mt:lim)))+1])
title('Single-Sided Amplitude Spectrum of y(t)')
xlabel('Frequency (Hz)')
ylabel('log|Y(f)|')
end
end
