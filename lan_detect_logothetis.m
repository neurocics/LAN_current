function RT = lan_detect_logothetis(LAN, cfg)

% Logothetis et al., 2012, Hippocampal-cortical interaction during
% periods of subcortical silence, Nature.
% 
% label : tag all events with a label. Use * for channel tags.


% WARNING : this script assumes LAN is unsegmented
% UNIMPLEMENTED : RT.OTHER.Amp

RT = [];
if nargin == 0
    edit lan_detect_logothetis
    help lan_detect_logothetis
    return
elseif nargin == 1
    cfg = [];
end

% default settings
freq = [];
chan = [];
label = '*';
norbin = 0;
lowpass_cut = 20; % hz
thr = [1 3.5];
mindur = 20; % ms
twin = 'hann';
ifcspec = false;

if isfield(cfg, 'freq'); freq = cfg.freq;
else cfg.freq = freq; end

if isfield(cfg, 'chan'); chan = cfg.chan;
else cfg.chan = chan; end

if isfield(cfg, 'thr'); thr = cfg.thr;
else cfg.thr = thr; end

if isfield(cfg, 'mindur'); mindur = cfg.mindur;
else cfg.mindur = mindur; end

if isfield(cfg, 'label'); label = cfg.label;
else cfg.label = label; end

if isfield(cfg, 'norbin'); norbin = cfg.norbin;
else cfg.norbin = norbin; end

if isfield(cfg, 'lowcut'); lowpass_cut = cfg.lowcut;
else cfg.lowcut = lowpass_cut; end

if isfield(cfg, 'twin'); twin = cfg.twin;
else cfg.twin = twin; end

if isfield(cfg, 'ifcspec'); ifcspec = cfg.ifcspec;
else cfg.ifcspec = ifcspec; end

f_low = min(freq);
f_high = max(freq);

nrt = 0;

for e = chan
    fprintf('o');
    
    % load cspec
    if ifcspec
        cspec = lan_cspec_load(LAN, e);
        ifcspec = ~isempty(cspec);
        disp('lan_detect_logothetis: Warning, no spectral data found')
    end
    
    % labels
    label_ = strrep(label,'*', num2str(e));
        
    % STEP 1: Band pass
    sign = ones(1,LAN.pnts(1));
    nborde = ceil( LAN.srate / f_low );
    switch twin
        case {'HANN','Hann','hann'}
            win = hann(4*nborde+1);
            sign(1:2*nborde) = win(1:2*nborde);
            sign(end-2*nborde-1:end) = win(end-2*nborde-1:end);
        case {'HAMMING','Hamming','hamming'}
            win = hamming(4*nborde+1);
            sign(1:2*nborde) = win(1:2*nborde);
            sign(end-2*nborde-1:end) = win(end-2*nborde-1:end);
    end
    
    signal = LAN.data{1}(e,:);
    signal = signal.*sign;
    signal = filter_hilbert(signal',LAN.srate,f_low,f_high,norbin)';
    
    % STEP 2: rectified the signal
    signal = abs(real(signal));
    
    % STEP 3: low pass filter
    [b,a] = butter( 2, lowpass_cut/(LAN.srate/2) );
    signal = filtfilt(b,a,double(signal));
    
    % STEP 4: normalize
    signal = normal_z(signal,signal(LAN.selected{1}));
    
    % STEP 5: find superthreshold events
    evl = bwlabel( signal>=thr(1) ); % superthreshold events, low
    evh = bwlabel( signal>=thr(2) ); % superthreshold events, high
    evh_val = unique(evh);
    evl_skip = [];
    
    
    ripple = zeros(size(signal));
    c = 0;
    for evh_ = evh_val
        evl_ = evl( evh==evh_ );
        evl_ = evl_(1);
        evl_span = evl==evl_;
        if all( evl_~=evl_skip ) % evitar eventos repetidos
            if sum(evl_span)/LAN.srate >= mindur/1000
                c = c + 1;
                nrt = nrt + 1;
                ripple(evl_span) = c;
                evl_skip = cat(1,evl_skip,evl_);
                evl_signal = signal(:,evl_span);
            
                RT.good(nrt) = all(LAN.selected{1}(evl_span));
                RT.OTHER.npts{nrt} = sum(evl_span); % points
                RT.OTHER.duration(nrt) = 1000*(sum(evl_span)/LAN.srate);% ms
                RT.rt(nrt) = 1000*(sum(evl_span)/LAN.srate);
                % eventos
                RT.est(nrt) = e;
                RT.resp(nrt) = e;
                onset = find(evl_span,1,'first');
                RT.latency(nrt) = 1000*onset/LAN.srate;
                
                RT.OTHER.names{nrt} = label_;
                overHalfMax = evl_signal>=max(evl_signal)/2;
                RT.OTHER.FWHM(nrt) = 1000*(sum(overHalfMax)/LAN.srate);
                
                if ifcspec
                    cspec_ = cspec(:,evl_span);
                    
                    % en F
                    meanF = smooth(nanmean(cspec_,2));
                    meanF = detrend(meanF);
                    meanF(LAN.freq.freq<f_low) = NaN;
                    meanF(LAN.freq.freq>f_high) = NaN;
                    [~, ind] = max(meanF);
                    RT.OTHER.Hz(nrt) = LAN.freq.freq(ind);
                    RT.OTHER.spctrm{nrt} = meanF;%meanHz; check this !
                    
                    % en T
                    meanT = smooth(nanmean(cspec_,1));
                    [val, ind] = max(meanT);
                    dur_m = find(meanT(1:ind)<val/2,1,'last');
                    if isempty(dur_m); dur_m = 1;end
                    dur_M = find(meanT(ind:end)<val/2,1,'first');
                    if isempty(dur_M); dur_M =  numel(meanT)-ind+1; end
                    RT.OTHER.FWHM_wavelet(nrt) = ind - dur_m + dur_M;
                    RT.OTHER.Amp_z_wavelet(nrt) = val;
                    RT.OTHER.time_max(nrt) = ind;
                    
                else
                    RT.OTHER.Hz(nrt) = NaN;
                    RT.OTHER.spctrm{nrt} = [];
                    RT.OTHER.FWHM_wavelet(nrt) = NaN;
                    RT.OTHER.Amp_z_wavelet(nrt) = NaN;
                    RT.OTHER.time_max(nrt) = 0;
                end
            end
        end
    end
    
end

RT = rt_check(RT);

end % function



