function RT = rt_fourier(RT,cfg)
%            v.0.0.1
%           <*LAN)<|    version
%
%  
%  Pablo Billeke
% 
% 
if nargin > 1 &&  isstruct(cfg)
    
    %%% ifplot
    try  
        ifplot = cfg.ifplot;
    catch
         ifplot = 0;
    end
    %%%%
    try
        NFFT = cfg.nfft;
        ifnfft = 1;
    catch
        ifnfft = 0;
    end
    
elseif nargin == 1
    ifplot = 0;
    ifnfft = 0;
else
    erro('Incorrec CFG. format ')
end




Fs = 1 / (RT.rs.cfg.newfs / 1000);   % Sampling frequency
T = 1/Fs;                             % Sample time

if ~iscell(RT.rs.rt)
    L = length(RT.rs.rt);   
else
    for b = 1:RT.nblock
        L(b) = length(RT.rs.rt{b}); 
    end
      L = max(L);
end
% Length of signal
%t = (0:L-1)*T;                             % Time vector
%ntrial = LAN.trials;}
if ~ifnfft
NFFT = 2^nextpow2(L);% Next power of 2 from length of y
end
f = Fs/2*linspace(0,1,NFFT/2);
%ffterp =[5 20];


if ~iscell(RT.rt)

    y = RT.rs.rt;
    Y = fft(y,NFFT)/L;
    fft_rt =conj(Y(1:floor(NFFT/2))).*(Y(1:floor(NFFT/2))); 
    
    cfg.tapers = [3 5];
    cfg.pad = 2;%NFFT;
    cfg.Fs = Fs;
    [mt mtf]= mtspectrumc_lan (y,cfg);
    
    
    fmax = 0.5/(min(diff(RT.laten))/1000);
    f_i = ~((f==0) + (f >=fmax));
    mtf_i = ~((mtf==0) + (mtf >=fmax));
else
    for b = 1:RT.nblock
    y = RT.rs.rt{b};
    Y = fft(y,NFFT)/L;
     fft_rt(b,:) = conj(Y(1:NFFT/2)).*(Y(1:NFFT/2));
    fmax(b) = 0.5/(min(diff(RT.laten{b}))/1000);
    
    cfg.tapers = [3 5];
    cfg.pad = 2;%NFFT;
    cfg.Fs = Fs;
    %[mt mtf]= mtspectrumc_lan (y,cfg);
    
    end
    fmax=(min(fmax));
    f_i = ~((f==0) + (f >=fmax));
    %mtf_i = ~((mtf==0) + (mtf >=fmax));
end
%avgfft(ch,:) = mean(ffterp,1);
fft_rt = mean(fft_rt,1);
mt = mean(mt',1);

RT.freq.fourier = fft_rt;
RT.freq.fourierf=f;
RT.freq.fourierf_i=f_i;
%RT.freq.mt = mt;
%RT.freq.mtf=mtf;
if ifplot
% Plot single-sided amplitude spectrum.
figure
plot(mtf(mtf_i),mt(mtf_i)/1000) , hold on
plot(f(f_i),fft_rt(f_i),'r') ,
title('Single-Sided Amplitude Spectrum of y(t)')
xlabel('Frequency (Hz)')
ylabel('|Y(f)|')
end