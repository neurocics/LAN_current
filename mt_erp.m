function LAN =  mt_erp(LAN,cgf)
%          v.0.0.0
%         <*LAN)<|           version
%                                   based on Chronux 2.0
% 
%
%     Pablo Billeke
% 
%
LAN = lan_check(LAN);
Fs = LAN.srate;                % Sampling frequency
% tapers = cfg.tapers;
% pad =
% T = 1/Fs;                     % Sample time
% fpass
%  err 
%  trialave






try
    L = LAN.pnts;   
catch
    L = length(LAN.data{1});
end
% Length of signal
%t = (0:L-1)*T;                % Time vector
ntrial = LAN.trials;
NFFT = 2^nextpow2(L); % Next power of 2 from length of y
f = Fs/2*linspace(0,1,NFFT/2);
%ffterp =[5 20];

if iscell(LAN.data)
    for i=1:ntrial
    y = LAN.data{i}(ch,:);
    Y = fft(y,NFFT)/L;
    ffterp(i,:) = 2*abs(Y(1:NFFT/2));
    end
else
    for i=1:ntrial
    y = LAN.data(ch,:,i);
    Y = fft(y,NFFT)/L;
    ffterp(i,:) = 2*abs(Y(1:NFFT/2));
    end
end

avgfft = mean(ffterp,1);

% Plot single-sided amplitude spectrum.
figure
plot(f(2:128),avgfft(1,2:128)) 
title('Single-Sided Amplitude Spectrum of y(t)')
xlabel('Frequency (Hz)')
ylabel('|Y(f)|')