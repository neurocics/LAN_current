function LAN = fourierp_lan(LAN,cfg)
%            v.0.0.2
%           <*LAN)<|    version
%  cfg.
%       chn = numero del canal
%       method = 'mt' (multitaper, otherway fourier)
%           tapers =  [TW K] where TW is the
%                        time-bandwidth product and K is the number of
%                        tapers to be used (less than or equal to  2TW-1).
%       ifplot = ploteor
%
%  Javier Lopez Calderon
%  Pablo Billeke

% 09.04.2012 (PB) change name for compatibilty LAN ~ ERPLAN
% 24.07.2011 (PB)

if nargin==1
    cfg.chn = 'all';
    cfg.ifplot = 0;
end

if iscell(LAN)
    for lan = 1:length(LAN)
        LAN{lan} = fourierp_lan(LAN{lan},cfg);
    end
else
    
    if isnumeric(cfg)
        chn = cfg;
        ifplot = 1;
    elseif isstruct(cfg)
        %%% channel
        try
            chn = cfg.chn;
        catch
            chn = 'all';
        end
        %%% ifplot
        try
            ifplot = cfg.ifplot;
        catch
            ifplot = 0;
        end
    else
        erro('Incorrec CFG. format ')
    end
    
    %%% only plot
    if nargout == 0
        ifplot = 1;
    end
    
    LAN = lan_check(LAN);
    
    Fs = LAN.srate;                % Sampling frequency
    %T = 1/Fs;                       % Sample time
    
    try
        L = max(LAN.pnts);
    catch
        for t = 1:length(LAN.data)
            L(t) = length(LAN.data{t});
        end
        L = max(L);                              % in case of variable durations,
        % take into account the longest one
    end
    % Length of signal
    %t = (0:L-1)*T;                             % Time vector
    ntrial = LAN.trials;
    NFFT = 2^nextpow2(L);               % Next power of 2 from length of y
    f = Fs/2*linspace(0,1,NFFT/2);
    %ffterp =[5 20];
    
    if ischar(chn)&&strcmp(chn,'all')
        chn = 1:LAN.nbchan;
    end
    
    %%%%
    if isfield(cfg, 'method') && strcmp(cfg.method,'mt')
        mt = 1;
        cfg.Fs = Fs;
        if ~isfield(cfg,'tapers')
            cfg.tapers= [3 5];
        end
    else
        mt = 0;
        cfg.method='f';
    end
    fprintf(['Fourierp (' cfg.method ') Channels:\n'])
    c=0;
    for ch = chn
        fprintf(['[' num2str(ch) ']']);
        c=c+1;
        if mod(c,10)==0
            fprintf('\n')
        end
        for i=1:ntrial
            if iscell(LAN.data)
                y = LAN.data{i}(ch,:);
            else
                y = LAN.data(ch,:,i);
            end
            if mt
                [Y f]=mtspectrumc_lan(y',cfg);
            else
                Y = fft(y,NFFT)/L;
                Y = Y(1:NFFT/2);
            end
            ffterp(i,:) = 2*conj(Y).*(Y);
        end
        
        
        data(ch,:,:) = permute(ffterp,[2,1]) ;
        avgfft(ch,:) = mean(ffterp,1);
        stdfft(ch,:) = std(ffterp,1);
        lslog(ch,:) = log10(avgfft(ch,:)+stdfft(ch,:));
        %lilog(ch,:)  = log10(avgfft(ch,:)) - (lslog(ch,:) - log10(avgfft(ch,:)));
        paso = avgfft(ch,:)-stdfft(ch,:);
        paso(paso<0)=0;
        lilog(ch,:) =log10(paso) ;
        if ifplot
            % Plot single-sided amplitude spectrum.
            figure
            plot(f(2+mt:150),log10(avgfft(ch,2+mt:150)),'LineWidth',2), hold on;
            plot(f(2+mt:150),lslog(ch,2+mt:150) ,'Color',[0.5 0.5 0.5])
            plot(f(2+mt:150),lilog(ch,2+mt:150) ,'Color',[0.5 0.5 0.5])
            xlim([f(2+mt),f(150)]);
            ylim([min(log(avgfft(ch,2+mt:150)))-1 , max(log(avgfft(ch,2+mt:150)))+1])
            title('Single-Sided Amplitude Spectrum of y(t)')
            xlabel('Frequency (Hz)')
            ylabel('log|Y(f)|')
        end
    end
    
    LAN.freq.fourierp.data = data;
    LAN.freq.fourierp.mean = avgfft;
    LAN.freq.fourierp.std = stdfft;
    LAN.freq.fourierp.freq=f;
    LAN.freq.fourierp.lslog=lslog;
    LAN.freq.fourierp.lilog=lilog;
    LAN.freq.fourierp.cfg=cfg;
end
end