function [f, cxy] = lan_coherence(LAN, cfg, nomean)
%***************DEPENDENCIES***************
% - hann (Signal Processing Toolbox)
% - hamming (Signal Processing Toolbox)
% - lan_cspd (LAN toolbox)
% - lan_cspd_mt (LAN toolbox) # See Dependencies (Chronux)

if nargin < 3
    nomean = false;
end

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

f = [];
if isequal( cfg.method, 'fourier' )
    [~, AB] = lan_cspd(LAN, cfg.chn1, cfg.chn2, win, nomean);
    [~, AA] = lan_cspd(LAN, cfg.chn1, cfg.chn1, win, nomean);
    [f, BB] = lan_cspd(LAN, cfg.chn2, cfg.chn2, win, nomean);
elseif isequal( cfg.method, 'multitapers' )
    [~, AB] = lan_cspd_mt(LAN, cfg.chn1, cfg.chn2, cfg.tapers, nomean);
    [~, AA] = lan_cspd_mt(LAN, cfg.chn1, cfg.chn1, cfg.tapers, nomean);
    [f, BB] = lan_cspd_mt(LAN, cfg.chn2, cfg.chn2, cfg.tapers, nomean);
end
AB = AB(:, 1:length(f));
AA = AA(:, 1:length(f));
BB = BB(:, 1:length(f));

% cxy = AB.^2 ./ (AA.*BB);
cxy = AB ./ sqrt(AA.*BB);
cxy = abs(cxy);