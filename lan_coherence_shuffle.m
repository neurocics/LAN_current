function [f, cxy, scxy95] = lan_coherence_shuffle(LAN, cfg, samples)
%***************DEPENDENCIES***************
% - hann (Signal Processing Toolbox)
% - hamming (Signal Processing Toolbox)
% - lan_cspd (LAN toolbox)
% - lan_cspd_mt (LAN toolbox) # See Dependencies (Chronux)

if ~isfield(cfg, 'twin')
    disp('Setting default time window');
    cfg.twin = 'hann';
end
if ~isfield(cfg, 'chn1')
    disp('Default channel: 1');
    cfg.chn1 = 1;
end
if ~isfield(cfg, 'chn2')
    disp('Default channel: 2');
    cfg.chn2 = 2;
end
if ~isfield(cfg, 'method')
    disp('Default method: Fourier')
    cfg.method = 'fourier';
elseif isequal( cfg.method, 'multitapers' )
    if ~isfield(cfg, 'tapers')
        disp('Default tapers: [3 5]')
        cfg.tapers = [3 5];
    end
end

switch cfg.twin
    case {'HANN','Hann','hann'}
        win = hann(LAN.pnts(1));
    case {'HAMMING','Hamming','hamming'}
        win = hamming(LAN.pnts(1));
end

[f, cxy] = lan_coherence(LAN, cfg);

chan1 = cfg.chn1;
chan2 = cfg.chn2;
cfg.chn1 = 1;
cfg.chn2 = 2;
sLAN = LAN;
sLAN.nbchan = 2;

scxy = zeros(samples, length(f));
for c = 1:samples
    disp(['Sample #' num2str(c)])
    permA = randperm(LAN.trials);
    permB = randperm(LAN.trials);
    sLAN.data = cell(LAN.trials,1);
    for d = 1:LAN.trials
        sLAN.data{d} = [LAN.data{permA(d)}(chan1,:); LAN.data{permB(d)}(chan2,:)];
    end
    [f, scxy(c,:)] = lan_coherence(sLAN, cfg);
end
clear sLAN;

p95 = [ceil(samples*0.95) ceil(samples*0.95)];
if mod(samples, 2) == 0; p95(2) = p95(2)+1; end
scxy95 = zeros(1, length(f));
for c = 1:length(f)
    scxy(:,c) = sort(scxy(:,c));
    scxy95(c) = ( scxy(p95(1),c) + scxy(p95(2),c) ) / 2;
end