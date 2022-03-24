function RT = lan_tfdetect_logothetis(LAN, cfg )

% for cell-array LAN structure
if iscell(LAN)
   for lan = 1:length(LAN)
       RT{lan} = lan_detect_freq_event(LAN{lan}, cfg );
   end
   return
end


time = getcfg(cfg,'time');
freq = getcfg(cfg,'freq');
chan = getcfg(cfg,'chan');
thr = getcfg(cfg,'thr');
ns = getcfg(cfg,'smooth',2);
twin = getcfg(cfg,'twin','hann');  % windows to reduce the edge effect, in hilbert filter
norbin = getcfg(cfg,'norbin',0);   % Normalization per bin smooth, in hilbert filter
span = getcfg(cfg,'span',0);
label = getcfg(cfg,'label','%C');

% initialize output
RT = [];
RT.latency = [];
RT.est = [];
RT.good= [];
RT.OTHER.spctrm = [];
RT.OTHER.Amp = [];
RT.OTHER.FWHM = [];
RT.OTHER.Amp_z_wavelet = [];
RT.OTHER.FWHM_wavelet = [];
RT.OTHER.Hz = [];
RT.OTHER.names = [];
RT.OTHER.npts = [];
RT.OTHER.duration = [];
RT.OTHER.time_max = [];

[~, f1_ind] = min( abs(LAN.freq.freq - min(freq)) );
[~, f2_ind] = min( abs(LAN.freq.freq - max(freq)) );
f1 = LAN.freq.freq(f1_ind);
f2 = LAN.freq.freq(f2_ind);



for e = chan
    %%% frequency of the event
    % try if thar is a precalculates powspctrm
    if isfield(LAN,'freq') && isfield(LAN.freq,'powspctrm')
        if isstruct(LAN.freq.powspctrm)
            tfrep_aux = lan_getdatafile(...
                LAN.freq.powspctrm(e).filename,...
                LAN.freq.powspctrm(e).path,...
                LAN.freq.powspctrm(e).trials );
            tfrep_aux = cat(3,tfrep_aux{:});
            tfrep = lan_smooth2d(squeeze(tfrep_aux(:,:,:)),4,0.4,ns);
        else
            tfrep_aux = cat(3,LAN.freq.powspctrm{:});
            tfrep =  tfrep_aux(:,e,:);
            tfrep = lan_smooth2d(squeeze(tfrep),4,0.4,ns);
            
        end
        
        
        N = tfrep; % remove unselected areas
        N(:,~cat(2,LAN.selected{:})) = NaN;
        tfrep = squeeze(normal_z(tfrep,N));
        clear tfrep_aux N
        
        
        has_tfrep = true;
    else
        has_tfrep = false;
    end
    
    
    
    signal = LAN.data{1}(e,:);
    
    % STEP 1: Band pass
    sign = ones(1,length(signal));
    nborde = ceil(( 1/(min(f1,f2)-0.5) ) * LAN.srate );
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
    
    
    signal = signal.*sign;
    signal = filter_hilbert(signal',LAN.srate,f1,f2,norbin)';
    
    % STEP 2: rectified the signal
    power = abs(real(signal));
    
    % STEP 3: low pass filter
    if span==0, span=20;end, % in this case span represen the low pass fielter od the rectified signal
    [b,a] = butter(2,span/(LAN.srate/2));
    power_low = filtfilt(b,a,double(power));
    
    % STEP 4: normalize
    N = power_low;
    N(:,~cat(2,LAN.selected{:})) = NaN;
    power = squeeze(normal_z(power_low,N));
    clear power_low N;
    
    
    % (high) superthreshold clusters: ripple candidats
    seq = 1:numel(power);
    aux = [0 diff(power>=thr(2))];
    if     sum(aux) == -1; aux(1)   = 1;
    elseif sum(aux) ==  1; aux(end) = -1;
    end
    candidates = [seq(aux==1);seq(aux==-1)];
    
    % (low) superthreshold clusters: actual ripples
    aux = [0 diff(power>=thr(1))];
    if     sum(aux) == -1; aux(1)   = 1;
    elseif sum(aux) ==  1; aux(end) = -1;
    end
    ripples = [seq(aux==1);seq(aux==-1)];

    % assign candidates to an actual ripple
    % initial assignation: 1. Iterate until finding correct assignation
    assign = ones( 1,size(candidates,2) );
    for c = 2:size(ripples,2)
        assign( ripples(1,c) <= candidates(1,:) ) = c;
    end
    
    % discard redundant assignations
    aux = [assign(1) diff(assign)];
    assign = assign(aux~=0);
    
    % reduce ripples list according to candidates list
    ripples = ripples(:,assign);
    
    % Ripple duration. Discard ripples too short
    npts = (ripples(2,:)-ripples(1,:)+1);
    duration = npts * 1000 / LAN.srate; % ms
    ripples = ripples(:,duration>=time);
    
    % OTHER PARAMETERS
    latency = ripples(1,:)*1000/LAN.srate;
    est = e*ones(size(latency));
    good = true(size(latency));
    
    Amp = nan(size(latency));
    FWHM = nan(size(latency));
    Amp_z_wavelet = nan(size(latency));
    FWHM_wavelet = nan(size(latency));
    Hz = nan(size(latency));
    time_max = nan(size(latency));
    spctrm = nan(size(tfrep,1), numel(latency));
    for c = 1:size(ripples,2)
        power_aux = power(ripples(1,c):ripples(2,c));
        FWHM(c) = sum( power_aux>=max(power_aux)/2 );
        FWHM(c) = FWHM(c) * 1000 / LAN.srate;
        Amp(c) = nanmean( power_aux );
        if has_tfrep
            tfrep_aux = tfrep( :,ripples(1,c):ripples(2,c) );
            spctrm(:,c)= nanmean(tfrep_aux,2);
            
            spctrm_dif = [NaN; diff( smooth( spctrm(f1_ind:f2_ind,c)) )];
            spctrm_dif2 = [NaN; diff( spctrm_dif )];
            spctrm_dif_prod = [NaN; spctrm_dif(1:end-1).*spctrm_dif(2:end)];
            search = spctrm_dif_prod<=0;
            search = search & spctrm_dif2<0;
            if any(search)
                seq = LAN.freq.freq(f1_ind:f2_ind);
                seq = seq(search);
                aux = spctrm(search,c);
                [~,aux] = max(aux);
                Hz(c) = seq(aux);
            else
                Hz(c) = NaN;
            end
            
            antispctrm = nanmean(tfrep_aux,1);
            [peak,peak_ind] = max(antispctrm);
            hpeak = peak/2;
            time_max(c) = peak_ind;
            FWHMw_left  = find(antispctrm(1:peak_ind)  <hpeak,1,'last');
            FWHMw_right = peak_ind + find(antispctrm(peak_ind+1:end)<hpeak,1,'first');
            if isempty(FWHMw_left); FWHMw_left = 1;end
            if isempty(FWHMw_right); FWHMw_right = numel(antispctrm); end
            FWHM_wavelet(c) = FWHMw_right - FWHMw_left + 1;
            Amp_z_wavelet(c) = peak;
        end
    end
    
    % pack
    RT.latency = [RT.latency latency];
    RT.est = [RT.est est];
    RT.good= [RT.good good];
    RT.OTHER.npts = [RT.OTHER.npts npts];
    RT.OTHER.duration = [RT.OTHER.duration duration];
    RT.OTHER.spctrm = [RT.OTHER.spctrm spctrm];
    RT.OTHER.Amp = [RT.OTHER.Amp Amp];
    RT.OTHER.FWHM = [RT.OTHER.FWHM FWHM];
    RT.OTHER.Hz = [RT.OTHER.Hz Hz];
    RT.OTHER.Amp_z_wavelet = [RT.OTHER.Amp_z_wavelet Amp_z_wavelet];
    RT.OTHER.FWHM_wavelet = [RT.OTHER.FWHM_wavelet FWHM_wavelet];
    RT.OTHER.time_max = [RT.OTHER.time_max time_max];
end
RT.laten = RT.latency;
RT.resp = RT.est;
RT.OTHER.names = repmat({label},size(RT.laten));