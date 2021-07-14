function LAN = lan_interp(LAN, cfg)
%   <*LAN)<] 
%   v.0.0.3
%
%   Realiza interpolación de canales en ensayos, que estan etiquedados con
%   la etiqueta señalada en cfg.type 
%      
%     cfg.type         % tag of channnel/trials to interpolate
%     cfg.iftypec=0    %
%     cfg.bad_elec
%     cfg.bad_trial
%     cfg.method 
%     cfg.ref = [] , '1ll'
%
%   Pablo Billeke

%  27.01.2012 fix
%  26.07.2011 fix
%  16.06.2011

% METHOD
if nargin==1
   cfg.method='v4' ;
   cfg.type='bad'
   cfg.ref=[];
end

ref = getcfg(cfg,'ref',[]);

if isfield(cfg, 'method')
    method = cfg.method;
else
    method = 'v4'; 
end

% No type
if ~isfield(cfg, 'type')&&isfield(cfg, 'bad_elec')&&(isstruct(LAN))
if ~isfield(cfg, 'bad_trial') || strcmp(cfg.bad_trial,'all')
    cfg.bad_trial = 1:LAN.trials;
end
end





if isfield(cfg, 'type') && iscell(LAN)
    
    
    for lan =1:length(LAN)
        
        % find ntipo
        
        ntipon=[];
        c=0;
        for i = 1:length(LAN{lan}.tag.labels)
            if any(strfind(LAN{lan}.tag.labels{i},cfg.type))
                c = c+1;
                ntipo(c)=i;
            elseif strcmp(LAN{lan}.tag.labels{i},'interpolated')
                ntipon=i; 
            end
        end
        if isempty(ntipon); 
            ntipon = i+1;
            LAN{lan}.tag.labels{ntipon}='interpolated';
        end
        % interpolation per channel and per trial
         tt = 1:LAN{lan}.trials;
         tt(~LAN{lan}.accept)=[];% no interpolar trial no aceptados
          for nt = tt
              pasoif = (LAN{lan}.tag.mat(:,nt)==ntipo(1));
              for ni = 2:length(ntipo)
              pasoif = pasoif + (LAN{lan}.tag.mat(:,nt)==ntipo(ni));    
              end
              if any(pasoif)
              LAN{lan} = lan_interp_str(LAN{lan},find(pasoif>0),nt, method,ntipon);       
              end
          end
    end
elseif isfield(cfg, 'type') && isstruct(LAN)  
        
    
 
         % find ntipo
        ntipon=[];
        c=0;
        for i = 1:length(LAN.tag.labels)
            if any(findstr(LAN.tag.labels{i},cfg.type))
                c =c+1;
                ntipo(c)=i;
            elseif strcmp(LAN.tag.labels{i},'interpolated')
                ntipon=i; 
            end
        end
        if isempty(ntipon); 
            ntipon = i+1;
            LAN.tag.labels{ntipon}='interpolated';
        end
        
        % interpolation per channel and per trial
                tt = 1:LAN.trials;
                tt(~LAN.accept)=[];% no interpolar trial no aceptados
          for nt = tt
              pasoif = (LAN.tag.mat(:,nt)==ntipo(1));
              for ni = 2:length(ntipo)
              pasoif = pasoif + (LAN.tag.mat(:,nt)==ntipo(ni));    
              end
              if any(pasoif)
                  if isstr(ref) && strcmp(ref, 'all')
                     LAN.data{nt} =  LAN.data{nt} - repmat( mean(LAN.data{nt}(pasoif==0 ,:),1) , [LAN.nbchan 1] );
                  end
                  
              LAN = lan_interp_str(LAN,find(pasoif>0),nt, method,ntipon); 
                  
                  if isstr(ref) && strcmp(ref, 'all')
                     LAN.data{nt} =  LAN.data{nt} - repmat( mean(LAN.data{nt},1) , [LAN.nbchan 1] );
                  end
              end
          end

elseif isstruct(LAN)  
    % find ntipo
        ntipon=[];
        for i = 1:length(LAN.tag.labels)
            if strcmp(LAN.tag.labels{i},'interpolated')
                ntipon=i; 
            end
        end
        if isempty(i), i = 0; end
        if isempty(ntipon); 
            ntipon = 1+i;
            LAN.tag.labels{ntipon}='interpolated';
        end    
    LAN = lan_interp_str(LAN, cfg.bad_elec,cfg.bad_trial, method,ntipon); 
elseif iscell(LAN)
    for lan = 1:length(LAN)
      LAN{lan}  = lan_interp(LAN{lan}, cfg);
    end
end



LAN = lan_check(LAN);
end

function LAN = lan_interp_str(LAN, bad_elec,bad_trial, method,ntipon)


  %  LAN = ORILAN;
    if nargin < 2
        help LAN_interp;
        return;
    end;
    
    if nargin < 4
        method = 'invdist';
    end;
    
    if nargin < 3
        bad_trial = 1:LAN.nbchan;
    end;   
    
    if isstruct(bad_elec)
    
        %no aplica LAN
%         
%         % find missing channels
%         % ---------------------
%         if length(bad_elec) < length(LAN.chanlocs)
%             bad_elec = [ LAN.chanlocs bad_elec ];
%         end;
%         if length(LAN.chanlocs) == length(bad_elec), return; end;
%         
%         lab1 = { bad_elec.labels };
%         lab2 = { LAN.chanlocs.labels };
%         [tmp badchans] = setdiff( lab1, lab2);
%         fprintf('Found %d channels to interpolate\n');
%         goodchans      = setdiff(1:length(bad_elec), badchans);
%        
%         % re-order good channels
%         % ----------------------
%         [tmp tmp2 neworder] = intersect( lab1, lab2 );
%         [tmp2 ordertmp2] = sort(tmp2);
%         neworder = neworder(ordertmp2);
%         LAN.data = LAN.data(neworder, :, :);
%         LAN.chanlocs = LAN.chanlocs(neworder); % not necessary
%         if ~isempty(LAN.icasphere)
%             LAN.icasphere = LAN.icasphere(:,neworder);
%             LAN.icawinv   = pinv(LAN.icaweights*LAN.icasphere);
%         end;
%         
%         % update LAN dataset (add blank channels)
%         % ---------------------------------------
%         if ~isempty(LAN.icasphere)
%             if isempty(LAN.icachansind) || (length(LAN.icachansind) == LAN.nbchan)
%                 LAN.icachansind = goodchans; % this suppose that this is empty
%             else
%                 error('Function not supported: cannot recompute ICA channel indices'); % just has to be programmed
%             end;
%         end;
%         LAN.chanlocs             = bad_elec;
%         tmpdata                  = zeros(length(bad_elec), size(LAN.data,2), size(LAN.data,3));
%         tmpdata(goodchans, :, :) = LAN.data;
%         LAN.data = tmpdata;
%         LAN.nbchan = length(LAN.chanlocs);

    else
        badchans  = bad_elec;
        goodchans = setdiff(1:LAN.nbchan, badchans);
    end;

    if length(bad_elec) > (LAN.nbchan/2)
        LAN.accept(bad_trial) = false ;
        fprintf('%s', ['not enough good channels for interpolating trial:' num2str(bad_trial) '.'])
        fprintf('\n')
        return
    end
    
    
    % find non-empty good channels
    % ----------------------------
    nonemptychans = find(~cellfun('isempty', { LAN.chanlocs.theta }));
    [tmp indgood ] = intersect(goodchans, nonemptychans);
    goodchans = goodchans( sort(indgood) );
    
    % get theta, rad of electrodes
    % ----------------------------
    [xbad ,ybad]  = pol2cart([LAN.chanlocs( badchans).theta],[LAN.chanlocs( badchans).radius]);
    [xgood,ygood] = pol2cart([LAN.chanlocs(goodchans).theta],[LAN.chanlocs(goodchans).radius]);

    % scan data points
    % ----------------
    fprintf('trial:');
    c = 0;
    for nt = bad_trial;
     c=c+1;    
    fprintf('%d', nt) ;
    fprintf('(%d)', c) ;
    for t=1:(size(LAN.data{nt},2)*size(LAN.data{nt},3)) % solo prosiacaso hay matricez de tres dimenciones
        %if mod(t,100) == 0, fprintf('%d ', t); end;
        %if mod(t,1000) == 0, fprintf('\n'); end;
        %for c = 1:length(badchans)
        %   [h LAN.data(badchans(c),t)]= topoplot(LAN.data(goodchans,t),LAN.chanlocs(goodchans),'noplot', ...
        %        [LAN.chanlocs( badchans(c)).radius LAN.chanlocs( badchans(c)).theta]);
        %end;
        [Xi,Yi,LAN.data{nt}(badchans,t)] = griddata(ygood, xgood , double(LAN.data{nt}(goodchans,t)'),...
                                                ybad, xbad, method); % interpolate data 
        
        % add tag
        LAN.tag.mat(badchans,nt)=ntipon;
    end
    if mod(c,10) == 0, fprintf('\n'); end;
    end
    fprintf('\n');

 
end