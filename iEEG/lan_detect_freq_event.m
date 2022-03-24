function RT = lan_detect_freq_event(LAN, cfg )
% v.0.1.4
%
% detect frequiency events in some 
%  channels              :  cfg.chan = [ch1 ,...]   ; e.g. [3 4 5 ]
%  frequency band        :  cfg.freq = [f1 f2]      ; e.g. [80 200]
%  minimun time duration :  cfg.time = [ms]         ; e.g  [20]
%  power threshould      :  cfg.thr = [sd]          ; e.g. [3]
%  using a 
%  method   
%  POWSPCTRM             : cfg.method= 'powspctrm'  / using a pre-calculated
%                                                   / time-power spectrum 
%         this method requiere
%                          bandwidth :   cfg.bandwidth = [ hz ] ; e.g. [10] ; default : (f2-f1)/2   
%                        
%
%  HILBERT                 : cfg.method= 'hilbert'  / using a band pass filter
%                                                /  and hibert transform
%         this method requiere
%                          windows funtion:  cfg.twin= 'Hann'; to reduce
%                                                              edge efect
%                          normalize bin:    cfg.norbin = [ hz ] ; e.g. [10] ; default : 0 
%                                                         to normalize
%                                                         amplitud per
%                                                         frequency.
%                          smooth span:    cfg.span = [ n ] ; e.g. [5] ; default : 0 
%
%
%  LOGOTHETIS              : cfg.method= 'logothetis'  / using rectification
%         this method requiere                      / and low-pass filster
%                        low-pass:    cfg.span  = [Hz] ; default = 20 hz                          
%         
%  LACHAUX               : cfg.method= 'lachaux' / using a pre-calculated
%                                                / time-power spectrum 
%                                                / modifications of
%                                                POWSPCTRUM but used the
%                                                mean of the power in the
%                                                band of frecuencies

% 19.07.2013 Implementado la detecion de entos cuyo maximo esta fuera de la
%            banda de interes
% 09.01.2012
% 04.01.2012 fix bug with unselected date
% 18.12.2012
% 21.11.2012 add norbin option to HILBERT method, see FILTER_HILBERT
% 14.11.2012 fix hilber



% add refractary time = 50;

% for cell-array LAN structure
if iscell(LAN)
   for lan = 1:length(LAN)
       RT{lan} = lan_detect_freq_event(LAN{lan}, cfg );
   end
   return
end


getcfg(cfg,'method','powspctrm');
time = getcfg(cfg,'time');
freq = getcfg(cfg,'freq');
chan = getcfg(cfg,'chan');
thr = getcfg(cfg,'thr');
ns = getcfg(cfg,'smooth',2);
twin = getcfg(cfg,'twin','hann');  % windows to reduce the edge effect, in hilbert filter
norbin = getcfg(cfg,'norbin',0);   % Normalization per bin smooth, in hilbert filter
bandwidth = getcfg(cfg,'bandwidth',ceil((max(freq)-min(freq))/2)); 
span = getcfg(cfg,'span',0);





ifps = false;
if isfield(LAN,'freq')&isfield(LAN.freq,'powspctrm')
    ifps = true;
    f1 = find_approx(LAN.freq.freq,min(freq));
    f2 = find_approx(LAN.freq.freq,max(freq));
else
    f1 = min(freq);
    f2 = max(freq);
end

switch method
    %%%-------------------
    %%%          powspctrm
    %%%-------------------
    case { 'powspctrm' , 'lachaux'}
        
        RT = [];
        nrt = 0;
        
        
        for e = chan
            fprintf('o');
            % labels
            label = getcfg(cfg,'label','%C');
            label = strrep(label,'%C', num2str(e));
            if isstruct(LAN.freq.powspctrm)
                power = lan_getdatafile(LAN.freq.powspctrm(e).filename,LAN.freq.powspctrm(e).path,LAN.freq.powspctrm(e).trials );
                power = cat(3,power{:});
                power = lan_smooth2d(squeeze(power(f1:f2,:,:)),4,0.4,ns);
            else
                power = cat(3,LAN.freq.powspctrm{:});
                power = power(f1:f2,e,:);
                power = lan_smooth2d(squeeze(power),4,0.4,ns);
            end
            
            
            % normalize
            power_row = power;
            N = power; % remove unselected areas
            N(:,~cat(2,LAN.selected{:})) = NaN;
            power = squeeze(normal_z(power,N));
            clear N
            
            if strcmp(method,'lachaux')
                power = nanmean(power,1);
                %N = power;
                %N(:,~cat(2,LAN.selected{:})) = NaN;
                %power = squeeze(normal_z(power,N));
            end
            
            %  find upper threshold events
            for nt = 1:length(thr)
                sd{nt} = (power>=thr(nt));
                ev{nt} = (bwlabel(sd{nt}));
            end
            
            ripple = zeros(size(power));
            c = 0;
            n = [];
            nn = unique(ev{end})';
            % check the event detected, and save them
            nn = (nn(:))';
            for evu = nn(2:end) % evitar primer evento 0
                %ev = 1
                s = ev{1}(find(ev{end}==evu,1,'first'));
                if ~any(n==s) % evitar eventos repetidos
                    
                    c = c+1;
                    ripple(ev{1}==s) = c;
                    
                    % long of the event
                    powR = power;
                    powR(ripple~=c) = 0;
                    largo = any(powR,1);
                    band = any(powR,2);
                    bin_band = length(f1:f2)/length(min(freq):max(freq));
                    powRr = power(:,largo);
                    Amp = mean(power_row(:,largo));
                    % only event longer than 'time'
                    if (sum(largo)/LAN.srate) >= (time/1000)
                        % only event grater than 'bandwidth'
                        if ( (sum(band)/bin_band) >= (bandwidth) ) || ( strcmp(method, 'lachaux') )
                            
                            nrt = nrt +1;
                            n(c) = s;
                            
                            RT.OTHER.npts{nrt} = sum(largo); % points
                            RT.OTHER.duration(nrt) = 1000*(sum(largo)/LAN.srate);% ms
                            
                            
                            % full width at half maximun
                            M = max(powRr);
                            M = M>=max(M)/2;
                            RT.OTHER.FWHM(nrt) = 1000*(sum(M)/LAN.srate);
                            
                            
                            % eventos
                            RT.est(nrt) = e;
                            RT.resp(nrt) = e;
                            %RT.chan(nrt) =e;
                            [y x] = find(ripple==c,1,'first');
                            RT.latency(nrt) = 1000*x/LAN.srate;
                            %[y x2] = find(ripple==c,1,'last');
                            RT.rt(nrt) = 1000*(sum(largo)/LAN.srate);% ms1000*(x2-x)/LAN.srate;
                            
                            % frequency of the event
                            spctrm = max(powRr');
                            % sup = max(max(powRr));
                            % en F
                            [sup paso] = max(smooth(nanmean(powRr,2)));
                            % en T
                            enT = smooth(nanmean(powRr,1));
                            [sup punto] = max(enT);
                            sup2 = max([1,sup/2]);
                            menos = find(enT(1:punto)<sup2,1,'last');
                            if isempty(menos); menos =0;end
                            mas = find(enT(punto:end)<sup2,1,'first');
                            if isempty(mas); mas =  numel(enT(punto:end)); end
                            dur = punto(1) - menos + mas;
                            %
                            RT.OTHER.FWHM_wavelet(nrt) = dur;
                            RT.OTHER.Amp_z_wavelet(nrt) = sup;
                            Hz = LAN.freq.freq(paso+f1-1 );
                            %     p10 = sort(powRr(:));
                            %     p10(p10<1) = [];
                            %     p10 = p10(fix(9*length(p10)/10));
                            %     lim = max([thr(end) p10]);
                            %     punta = powRr>lim;
                            %     paso = fix( mean(mean_nonan(find(any(punta,2)))+f1-1));
                            %     Hz = LAN.freq.freq(paso );
                            %     punto = fix(mean(find(any(punta,1))));
                            
                            
                            
                            
                            RT.OTHER.spctrm{nrt} = spctrm;
                            RT.OTHER.names{nrt} = label;
                            RT.OTHER.Hz(nrt) = Hz;
                            RT.OTHER.time_max(nrt) = punto;
                            RT.OTHER.FWHM(nrt) = 1000*(sum(M)/LAN.srate);
                            RT.OTHER.Amp(nrt) =mean(Amp);
                            
                            
                        end % greater than bandwidth
                    end % longer than time
                end
            end
        end



    %%%-------------------
    %%%          Hilbert
    %%%-------------------

    %%%-------------------
    case { 'hilbert'}
        % frequency band
        %       f1 = min(freq);
        %       f2 = max(freq);
        
        RT = [];
        nrt = 0;
        
        
        for e = chan
            %
            fprintf('o');
            %fprintf('\fx');
            %labels
            label = getcfg(cfg,'label','%C');
            label = strrep(label,'%C', num2str(e));
            
            %%% frequency of the event
            % try if thar is a precalculates powspctrm
            if ifps
                if isstruct(LAN.freq.powspctrm)
                    power2 = lan_getdatafile(LAN.freq.powspctrm(e).filename,LAN.freq.powspctrm(e).path,LAN.freq.powspctrm(e).trials );
                    power2 = cat(3,power2{:});
                    powerall = lan_smooth2d(squeeze(power2(:,:,:)),4,0.4,ns);
                    power2 = lan_smooth2d(squeeze(power2(f1:f2,:,:)),4,0.4,ns);
                else
                    power2 = cat(3,LAN.freq.powspctrm{:});
                    powerall =  power2(:,e,:);
                    power2 = power2(f1:f2,e,:);
                    power2 = lan_smooth2d(squeeze(power2),4,0.4,ns);
                    powerall = lan_smooth2d(squeeze(powerall),4,0.4,ns);
                end
                
                
                
                
                
                % normalize
                N = power2; % remove unselected areas
                N(:,~cat(2,LAN.selected{:})) = NaN;
                power2 = squeeze(normal_z(power2,N));
                
                N = powerall; % remove unselected areas
                N(:,~cat(2,LAN.selected{:})) = NaN;
                powerall = squeeze(normal_z(powerall,N));
                clear N
                
            end
            
            
            
            signal = LAN.data{1}(e,:);
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
            
            %power = signal.*conj(signal);
            % envelop
            power_row = abs(signal);%.*conj(signal);
            if span>0, power_row = smooth(power_row,span)';end,
            N = power_row;
            N(~LAN.selected{1}) = NaN;
            power = squeeze(normal_z(power_row, N));
            
            %  find upper threshold events
            for nt = 1:length(thr)
                sd{nt} = (power>=thr(nt));
                ev{nt} = (bwlabel(sd{nt}));
            end
            
            ripple = zeros(size(power));
            c = 0;
            n = [];
            nn = unique(ev{end});
            % check the event detected, and save them
            for evu = nn(2:end) % evitar priemr evento 0
                % ev = 1
                s = ev{1}(find(ev{end}==evu,1,'first'));
                if ~any(n==s) % evitar eventos repetidos
                    
                    c = c+1;
                    ripple(ev{1}==s) = c;
                    
                    % long of the event
                    powR = power;
                    powR(ripple~=c) = 0;
                    largo = any(powR,1);
                    powRr = power(:,largo);
                    Amp = mean(power_row(:,largo));
                    
                    % only event longer than 'time'
                    if (sum(largo)/LAN.srate) >= (time/1000)
                        nrt = nrt +1;
                        n(c) = s;
                        
                        RT.OTHER.npts{nrt} = sum(largo); % points
                        RT.OTHER.duration(nrt) = 1000*(sum(largo)/LAN.srate);% ms
                        
                        % full width at half maximun
                        M = powRr>=max(powRr)/2;
                        RT.OTHER.FWHM(nrt) = 1000*(sum(M)/LAN.srate);
                        
                        
                        % eventos
                        RT.est(nrt) = e;
                        RT.resp(nrt) = e;
                        %RT.chan(nrt) =e;
                        [y x] = find(ripple==c,1,'first');
                        RT.latency(nrt) = 1000*x/LAN.srate;
                        %[y x2] = find(ripple==c,1,'last');
                        RT.rt(nrt) = 1000*(sum(largo)/LAN.srate);% ms1000*(x2-x)/LAN.srate;
                        
                        %%% frequency of the event
                        % try if there is a precalculates powspctrm
                        
                        if ifps
                            %powR = power2;
                            %powR(ripple~=c) = 0;
                            %powRr = power2(:,largo);
                            powR = powerall;
                            powR(ripple~=c) = 0;
                            powRr = powerall(:,largo);
                            % en F
                            [sup paso] = max(smooth(nanmean(powRr,2)));
                            % en T
                            enT = smooth(nanmean(powRr,1));
                            [sup punto] = max(enT);
                            sup2 = max([1,sup/2]);
                            menos = find(enT(1:punto)<sup2,1,'last');
                            if isempty(menos); menos =0;end
                            mas = find(enT(punto:end)<sup2,1,'first');
                            if isempty(mas); mas =  numel(enT(punto:end)); end
                            dur = punto(1) - menos + mas;
                            %
                            RT.OTHER.FWHM_wavelet(nrt) = dur;
                            RT.OTHER.Amp_z_wavelet(nrt) = sup;
                            %     sup = max(max(powRr));
                            %     p10 = sort(powRr(:));
                            %     p10(p10<1) = [];
                            %     p10 = p10(fix(9*length(p10)/10));
                            %     lim = max([thr(end) p10]);
                            %     punta = powRr>lim;
                            %     paso = fix( mean(mean_nonan(find(any(punta,2)))+f1-1));
                            %         if isnan(paso),
                            %         disp(evu), nrt = nrt-1; continue;
                            %     end
                            %     Hz = LAN.freq.freq(paso );
                            %     punto = fix(mean(find(any(punta,1))));
                            spctrm = max(powRr');
                            
                            Hz = LAN.freq.freq(paso);
                            %Hz = LAN.freq.freq(paso+f1-1 );
                        else
                            
                            
                            sup = max(max(powRr));
                            p10 = sort(powRr(:));
                            p10(p10<1) = [];
                            p10 = p10(fix(9*length(p10)/10));
                            lim = max([thr(end) p10]);
                            punta = powRr>lim;
                            %paso = fix( mean(mean_nonan(find(any(punta,2)))+f1-1));
                            Hz = [0];% LAN.freq.freq(paso );%-------------------------- FixME
                            punto = fix(mean(find(any(punta,1))));
                            spctrm =[];
                        end
                        
                        RT.OTHER.npts{nrt} = sum(largo); % points
                        RT.OTHER.duration(nrt) = 1000*(sum(largo)/LAN.srate);% ms
                        
                        RT.OTHER.spctrm{nrt} = spctrm;
                        RT.OTHER.names{nrt} = label;
                        RT.OTHER.Hz(nrt) = Hz;
                        RT.OTHER.time_max(nrt) = punto;
                        RT.OTHER.FWHM(nrt) = 1000*(sum(M)/LAN.srate);
                        RT.OTHER.Amp(nrt) =Amp;
                    end
                end
            end
            
        end


    %%%-------------------
    %%%          Logothetis
    %%%-------------------
    % ---------------------------
    case {'logothetis'}
        %           Logothetis et al., 2012, Hippocampal-cortical interaction during
        %           periods of subcortical silence, Nature.
        
        % frequency band
        %       f1 = min(freq);%find_approx(LAN.freq.freq,);
        %       f2 = max(freq);%find_approx(LAN.freq.freq,);
        
        RT = [];
        nrt = 0;
        
        
        for e = chan
            fprintf('o');
            % labels
            label = getcfg(cfg,'label','%C');
            label = strrep(label,'%C', num2str(e));
            
            %%% frequency of the event
            % try if thar is a precalculates powspctrm
            if ifps
                if isstruct(LAN.freq.powspctrm)
                    power2 = lan_getdatafile(LAN.freq.powspctrm(e).filename,LAN.freq.powspctrm(e).path,LAN.freq.powspctrm(e).trials );
                    power2 = cat(3,power2{:});
                    powerall = lan_smooth2d(squeeze(power2(:,:,:)),4,0.4,ns);
%                     power2 = lan_smooth2d(squeeze(power2(f1:f2,:,:)),4,0.4,ns);
                else
                    power2 = cat(3,LAN.freq.powspctrm{:});
                    powerall =  power2(:,e,:);
%                     power2 = power2(f1:f2,e,:);
%                     power2 = lan_smooth2d(squeeze(power2),4,0.4,ns);
                    powerall = lan_smooth2d(squeeze(powerall),4,0.4,ns);
                    
                end
                % normalize
%                 N = power2; % remove unselected areas
%                 N(:,~cat(2,LAN.selected{:})) = NaN;
%                 power2 = squeeze(normal_z(power2,N));
%                 clear N
                
                
                N = powerall; % remove unselected areas
                N(:,~cat(2,LAN.selected{:})) = NaN;
                powerall = squeeze(normal_z(powerall,N));
                clear N
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
            power_row = filtfilt(b,a,double(power));
            
            % STEP 4: normalize
            N = power_row;
            N(:,~cat(2,LAN.selected{:})) = NaN;
            power = squeeze(normal_z(power_row,N));
            
            %  find upper threshold events
            for nt = 1:length(thr)
                sd{nt} = (power>=thr(nt));
                ev{nt} = (bwlabel(sd{nt}));
            end
            
            ripple = zeros(size(power));
            c = 0;
            n = [];
            nn = unique(ev{end});
            for evu = nn(2:end) % evitar primer evento 0
                % ev = 1
                s = ev{1}(find(ev{end}==evu,1,'first'));
                if ~any(n==s) % evitar eventos repetidos
                    
                    c = c+1;
                    ripple(ev{1}==s) = c;
                    
                    % long of the event
                    powR = power;
                    powR(ripple~=c) = 0;
                    largo = any(powR,1);
                    powRr = power(:,largo);
                    Amp = mean(power_row(:,largo));
                    
                    % only event longer than 'time'
                    if (sum(largo)/LAN.srate) >= (time/1000)
                        nrt = nrt +1;
                        n(c) = s;
                        
                        % full width at half maximun
                        M = powRr>=max(powRr)/2;
                        
                        %%% frequency of the event
                        % try if thar is a precalculates powspctrm
                        
                        if ifps
                            
                            powR = powerall;
                            powR(ripple~=c) = 0;
                            powRr = powerall(:,largo);
                            
                            
                            %powR = power2;
                            %powR(:,ripple~=c) = 0;
                            %powRr = power2(:,largo);
                            
                            % en F
                            auxhz = smooth(nanmean(powRr,2));
                            auxhz = detrend(auxhz);
                            auxhz(LAN.freq.freq<f1) = NaN;
                            auxhz(LAN.freq.freq>f2) = NaN;
                            [~, paso] = max(auxhz);
                            % en T
                            enT = smooth(nanmean(powRr,1));
                            [sup punto] = max(enT);
                            sup2 = max([1,sup/2]);
                            menos = find(enT(1:punto)<sup2,1,'last');
                            if isempty(menos); menos =0;end
                            mas = find(enT(punto:end)<sup2,1,'first');
                            if isempty(mas); mas =  numel(enT(punto:end)); end
                            dur = punto(1) - menos + mas;
                            
                            %     p10 = sort(powRr(:));
                            %     p10(p10<1) = [];
                            %     if numel(p10)>1
                            %      p10 = p10(fix(9*length(p10)/10));
                            %      lim = max([thr(1) p10]);
                            %     else
                            %      lim = thr(1);
                            %     end
                            %     punta = powRr>=lim;
                            %
                            %     paso = fix( mean(mean_nonan(find(any(punta,2)))+f1-1));
                            
                            if isnan(paso), %-------------------------- FixME
                                fprintf('x'),
                                nrt = nrt-1; continue;
                            end
                            Hz = LAN.freq.freq(paso );
                            %Hz = LAN.freq.freq(paso+f1-1 );
                            %  punto = fix(mean(find(any(punta,1))));
                            spctrm = mean(powRr');
                            
                            RT.OTHER.FWHM_wavelet(nrt) = dur;
                            RT.OTHER.Amp_z_wavelet(nrt) = sup;
                        else
                            
                            sup = max(max(powRr));
                            p10 = sort(powRr(:));
                            p10(p10<1) = [];
                            p10 = p10(fix(9*length(p10)/10));
                            lim = max([thr(end) p10]);
                            punta = powRr>lim;
                            %paso = fix( mean(mean_nonan(find(any(punta,2)))+f1-1));
                            Hz = [0];% LAN.freq.freq(paso );%-------------------------- FixME
                            punto = fix(mean(find(any(punta,1))));
                            spctrm = [];
                        end
                        
                        % good
                        sel = ~cat(2,LAN.selected{:});
                        if any(sel(1,largo))
                            RT.good(nrt) = false;
                        else
                            RT.good(nrt) = true;
                        end
                        
                        
                        
                        RT.OTHER.npts{nrt} = sum(largo); % points
                        RT.OTHER.duration(nrt) = 1000*(sum(largo)/LAN.srate);% ms
                        
                        % eventos
                        RT.est(nrt) = e;
                        RT.resp(nrt) = e;
                        %RT.chan(nrt) =e;
                        [y x] = find(ripple==c,1,'first');
                        RT.latency(nrt) = 1000*x/LAN.srate;
                        %[y x2] = find(ripple==c,1,'last');
                        %     if numel(dur)~=1
                        %        'cuak'
                        %     end
                        RT.rt(nrt) = 1000*(sum(largo)/LAN.srate);%1000*(x2-x)/LAN.srate;
                        
                        RT.OTHER.spctrm{nrt} = spctrm;
                        RT.OTHER.names{nrt} = label;
                        RT.OTHER.Hz(nrt) = Hz;
                        RT.OTHER.time_max(nrt) = punto;
                        RT.OTHER.FWHM(nrt) = 1000*(sum(M)/LAN.srate);
                        
                        RT.OTHER.Amp(nrt) =Amp;
                    end
                end
            end
            
        end
        
        % S = LAN.data{1}(34,:);
        % SS = filter_hilbert(S',512,80,180,0);
        %
        %
        % % Rec = abs(real(SS));
        % Rec = SS.*conj(SS);
        %
        %
        % [b,a] = butter(4,20/(512/2));
        % Recf = filtfilt(b,a,double(Rec));
        %
        %
        % plot((real(SS)-mean(real(SS)))./std(real(SS))), hold on
        % plot((Recf-mean(Recf))./std(Recf),'r')
        
        
        
        
end % switch

RT = rt_check(RT);

end % function



