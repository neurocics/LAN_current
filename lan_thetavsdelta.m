function [coef] = lan_thetavsdelta(LAN, cfg, sample)
% cfg :
% chan : channel
% th_freq : theta frequency range
% de_freq : delta frequency range
% win_len : sliding window length (seconds)
% twin : time windowing function : hann|hamming
% step : sliding window step (points)

if ~isfield(cfg, 'chan')
    disp('Default channel: 1');
    cfg.chan = 1;
end
if ~isfield(cfg, 'win_len')
    disp('Default window length: 2 seconds');
    cfg.win_len = 2;
end
if ~isfield(cfg, 'twin')
    disp('Setting default time window');
    cfg.twin = 'hann';
end
if ~isfield(cfg, 'step')
    disp('Default step: 1');
    cfg.step = 1;
end
cfg.th_freq = sort(cfg.th_freq);
if ~isfield(cfg, 'de_freq') || isempty(cfg.de_freq)
    cfg.de_freq = [0 0];
else
    cfg.de_freq = sort(cfg.de_freq);
end
if nargin < 3
    sample = NaN;
end
if ~iscell(sample)
    sample = {sample};
end

lwin = floor(cfg.win_len * LAN.srate / 2); % ventana de win_len segundos
rwin = floor(cfg.win_len * LAN.srate / 2); % ventana de win_len segundos

L = lwin+rwin+1;
switch cfg.twin
    case {'HANN','Hann','hann'}
        twin = hann(L);
    case {'HAMMING','Hamming','hamming'}
        twin = hamming(L);
end

NFFT = 2^nextpow2(L);
f = LAN.srate/2 * linspace(0,1,NFFT/2);
ind_delta = 1:length(f);
ind_theta = 1:length(f);
ind_delta = ind_delta(f >= cfg.de_freq(1) & f <= cfg.de_freq(2));
ind_theta = ind_theta(f >= cfg.th_freq(1) & f <= cfg.th_freq(2));

coef = nan(LAN.trials, max(LAN.pnts));
for trial = 1:LAN.trials
    len = LAN.pnts(trial);
    start = lwin+1;
    finish = len - rwin;
    
    sig = LAN.data{trial}(cfg.chan,:)';
    iter = start:finish;
    if ~isnan( sample{trial} )
        iter = sample{trial};
        iter = iter(iter>=start & iter<=finish);
        cfg.step = 0;
    end
    for t = iter
        if mod(t,cfg.step) == 0 || cfg.step==0
            win = sig(t-lwin:t+rwin) .* twin;
            fwin = fft(win, NFFT) / L;
            fwin = fwin.*conj(fwin);
            
            theta = fwin(ind_theta);
            theta = mean(theta);
            if ind_delta(1) == 0
                coef(trial, t) = theta;
            else
                delta = fwin(ind_delta);
                delta = mean(delta);
                coef(trial, t) = log(sqrt(theta/delta));
            end
            
        else
            coef(trial, t) = coef(trial, t-1);
        end
    end
end
