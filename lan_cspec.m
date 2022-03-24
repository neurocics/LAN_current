function LAN = lan_cspec(LAN,cfg)

% NOT TESTED OR RECOMMENDED TO WORK WITH MULTIPLE TRIALS
% IMPORTANT: adaptation in progress of freq_lan.m. So far, only method
% thoroughly tested is Morlet Wavelets.

if nargin == 0
    edit lan_cspec
    help lan_cspec
    return
end

wfile = false;
wfile4chan = false;
if isfield(cfg, 'output') && ischar(cfg.output)
    if strcmpi(cfg.output, 'file')
        wfile = true;
    elseif strcmpi(cfg.output, 'file4chan')
        wfile = true;
        wfile4chan = true;
    end
end

root = pwd;
chan = [];
freqoi = [];
timeoi = 'all';
verbose = true;
method = 'logothetis';

if isfield(cfg, 'method'); method = cfg.method;
else cfg.method = method; end

if isfield(cfg, 'outdir') && ~isempty(cfg.outdir); root = cfg.outdir;
else cfg.outdir = root; end

if isfield(cfg, 'chan'); chan = cfg.chan;
else cfg.chan = chan; end

if isfield(cfg, 'freqoi'); freqoi = cfg.freqoi;
else cfg.freqoi = freqoi; end

if isfield(cfg, 'timeoi'); timeoi = cfg.timeoi;
else cfg.timeoi = timeoi; end

if isfield(cfg, 'verbose'); verbose = cfg.verbose;
else cfg.verbose = verbose; end

wvcfg.freqoi = freqoi;
wvcfg.timeoi = timeoi;
% wvcfg.width = ;
% wvcfg.gwidth = ;
wvcfg.polyorder = 0;
% wvcfg.pad = LAN.time(1,2) + rem(1 - rem(LAN.time(1,2),1), 1);
wvcfg.pad = ceil(LAN.time(1,2));
wvcfg.verbose = verbose;

time = (1:LAN.pnts(1)) / LAN.srate;

LAN.freq.powspctrm = struct('filename', [],...
    'path', [], 'type', []);
if wfile4chan && wfile
    LAN.freq.powspctrm = repmat(LAN.freq.powspctrm, numel(chan), 1);
    for c = 1:numel(chan)
        filename = [LAN.name '_' LAN.cond '_' LAN.group];
        filename = [filename '_ch' num2str(chan(c)) '.mat'];
        LAN.freq.powspctrm(c).filename = filename;
        LAN.freq.powspctrm(c).path = root;
        LAN.freq.powspctrm(c).type = 'w_cspec';
        
        dat = LAN.data{1}(chan(c),:);
        switch method
            case {'case1a','case1b'}
                cspec = [];
            otherwise
                [cspec, freqoi, timeoi] = lan_specest_wavelet(dat, time, wvcfg);
        end
        cspec = squeeze(cspec);
        save([root filesep filename], 'cspec', '-v7.3')
    end
else
    cspec = nan(numel(chan), numel(freqoi), numel(timeoi));
    for c = 1:numel(chan)
        dat = LAN.data{1}(chan(c),:);
        switch method
            case {'case1a','case1b'}
                cspec = [];
            otherwise
                [cspec(c,:,:), freqoi, timeoi] = lan_specest_wavelet(dat, time, wvcfg);
        end
    end
    if wfile
        filename = [LAN.name '_' LAN.cond '_' LAN.group];
        filename = [filename '.mat'];
        save([root filesep filename], 'cspec', '-v7.3')
        LAN.freq.powspctrm.filename = filename;
        LAN.freq.powspctrm.path = root;
        LAN.freq.powspctrm.type = 'w_cspec';
    else
        LAN.freq.powspctrm = cspec;
    end
end

LAN.freq.freq = freqoi;
LAN.freq.time = timeoi;
LAN.freq.chan = chan;
LAN.freq.cfg = wvcfg;

end
