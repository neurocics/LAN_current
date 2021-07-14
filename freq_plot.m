function freq_plot(LAN,cfg)
% v.0.0.1
%
% cfg.
%  bl  = [s1 s2] ; baseline in seconds
%  nor = 'z' , 'm' or 'mdb'; Normalizacion por z-score or mean-subtraction 
% 
% Pablo Billeke
% 
% 27.04.2010


if nargin == 0
    edit freq_plot.m
    help freq_plot.m
    return
end
%
if nargin == 1
    cfg.bl = [];
    cfg.nor = 'mdB';
end
%
if nargin == 2
    if ~isfield(cfg,'bl')
    cfg.bl = [];
    end
    if ~isfield(cfg,'nor')
    cfg.nor = 'mdB';
    end
end


if iscell(LAN)
    for lan = 1:length(LAN)
        freq_plot_st(LAN{lan},cfg)
    end
else
    freq_plot_st(LAN,cfg)
end
end

function freq_plot_st(LAN,cfg)


%%% baseline
if  ~isempty(cfg.bl)
 bl1 = find(LAN.freq.time>=cfg.bl(1),1,'first');
 bl2 = find(LAN.freq.time>=cfg.bl(2),1,'first');
 %%%
end

if isfield( LAN.chanlocs(1), 'electrodemat')
    electrodemat=LAN.chanlocs(1).electrodemat;
    [y x] = size(electrodemat);
    figure('Position', [0,0,1000,800])
    
    for elec = 1:LAN.nbchan
      if ~isempty(LAN.chanlocs(elec).X)
       in = find(electrodemat'==elec);
       
       subplot(y,x,in);
       if strcmp(cfg.nor,'z')
       data = normal_z(LAN.freq.powspctrm(:,elec,:),LAN.freq.powspctrm(:,elec,bl1:bl2),'z');
       data = squeeze(data);
       elseif strcmp(cfg.nor,'m')
       data = normal_z(LAN.freq.powspctrm(:,elec,:),LAN.freq.powspctrm(:,elec,bl1:bl2),'m');
       data = squeeze(data);    
	elseif strcmp(cfg.nor,'mdB')
       data = normal_z(10*log(LAN.freq.powspctrm(:,elec,:)),10*log(LAN.freq.powspctrm(:,elec,bl1:bl2)),'m');
       data = squeeze(data);    


       else
       data = squeeze(LAN.freq.powspctrm(:,elec,:));  
       end
       
       pcolor(LAN.freq.time,LAN.freq.freq,data); 
       shading interp 
       clear data
       if strcmp(cfg.nor,'z')
           caxis([-10,10]);
       elseif strcmp(cfg.nor,'mdB')
           caxis([-10,10]);
       else
          % caxis([0,10]);
       end
       
       
      end
      
    end
    else
    for elec = 1:LAN.nbchan
      if ~isempty(LAN.chanlocs(elec).X)
       in = find(electrodemat'==elec); 
       
       subplot('Position',[ (LAN.chanlocs(elec).Y+90)/220,(LAN.chanlocs(elec).X+90)/220 , 0.04,0.04]);
       pcolor(LAN.freq.time,LAN.freq.freq,squeeze(LAN.freq.powspctrm(:,elec,:)));

       shading interp 
      end
    end
end% if isfield


axcopy(gcf);
end
