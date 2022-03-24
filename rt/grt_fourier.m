function GRT = grt_fourier(grt,cfg) 
%
%
%
subject = cfg.subject;
cond = cfg.cond;
if isfield(cfg,'file') && isfield(cfg.file, 'path');
   path = cfg.subject; 
end

try
fsu = cfg.file.su; 
catch
fsu = '';    
end

for s = 1:length(subject)
   eval(['load '   path{s} '/'  subject{s} fsu '   ' subject{s} fsu   ])
   eval([ 'RT = ' subject{s} fsu ', clear ' subject{s} fsu ])
   for c = cond
   GRT{c}.fourier(s,:) = RT{c}.freq.fourier
   GRT{c}.fourierf(s,:) = RT{c}.freq.fourierf
   GRT{c}.mt(s,:) = RT{c}.freq.mt
   GRT{c}.mtf(s,:) = RT{c}.freq.mtf
   
   end

end
color = {'b','r','k'};
f_i = [2:400];
figure
subplot(2,1,1)
for c = cond

plot(GRT{c}.fourierf(1,f_i),mean(GRT{c}.fourier(f_i),1),color{c}) , hold on
title('Single-Sided Amplitude Spectrum of y(t)')
xlabel('Frequency (Hz)')
ylabel('|Y(f)|')
end
subplot(2,1,2)
for c = cond

plot(GRT{c}.mtf(1,f_i),mean(GRT{c}.mt(f_i),1),color{c}) , hold on
title('Single-Sided Amplitude Spectrum of y(t)')
xlabel('Frequency (Hz)')
ylabel('|Y(f)|')
end

end