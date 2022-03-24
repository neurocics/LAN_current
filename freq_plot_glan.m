function freq_plot_glan(GLAN,cfg)
%
% cfg.
%  bl  = [s1 s2] ; baseline in seconds
%  nor = 'z' or 'a'; Normalizacion por z-score o absoluta
%  comp=1Comparaci??n a graficar, anula par??metro cond.\\
%  cond=1 Condici??n a graficar si no existe comp.\\
%  hh=0;
%  
%  
% Pablo Billeke
% v.0.0.1
% 
% 02.06.2010
% 27.04.2010


if nargin == 0
    edit freq_plot_glan.m
    help freq_plot_glan.m
    return
end
%
if nargin == 1
    cfg.bl = [];
    cfg.nor = 'mdb';
    cfg.comp=1;
    cfg.hh=0;
end
%
%
% condiciones o comparaciones a graficar
try 
    comp = cfg.comp;
    cond = GLAN.timefreq.comp{comp};
    %comp=1;
catch
    try
    cond = cfg.cond;
    %comp=0;
    catch
    cond = 1;
    %comp=0;
    end
end
%
%
%
% estadistica
try 
    hh = cfg.hh;    
catch
    hh=0;
end
%
if hh==1
    try
        hhdata = GLAN.timefreq.hhc{comp};
    catch
        hhdata = GLAN.timefreq.hh{comp};   
    end
end


%
%
%
% baseline
% 
% 
if nargin == 2
    if ~isfield(cfg,'bl')
    cfg.bl = [];
    elseif ~isempty(cfg.bl)
    bl1 = find(GLAN.timefreq.time>=cfg.bl(1),1,'first');
    bl2 = find(GLAN.timefreq.time<=cfg.bl(2),1,'last') ;   
    end
    if ~isfield(cfg,'nor')
    cfg.nor = '';
    end
end





if isfield( GLAN.chanlocs(1), 'electrodemat')
    electrodemat=GLAN.chanlocs(1).electrodemat;
    [y x] = size(electrodemat);
    try 
        gr = cfg.gr;
    catch
     [gr l] = size(GLAN.timefreq.data);
     gr = 1:gr;
    end
    
    cont = 1;
    for gg = gr
        for cc = cond
            datarr{cont} = GLAN.timefreq.data{gg,cc};
    
    figure('Position', [0,0,1000,800])
    for elec = 1:GLAN.nbchan
      if ~isempty(GLAN.chanlocs(elec).X)
       in = find(electrodemat'==elec);
       
       subplot(y,x,in);
       %%%
       if strcmp(cfg.nor,'z')
           data = normal_z(GLAN.timefreq.data{gg,cc}(:,elec,:),GLAN.timefreq.data{gg,cc}(:,elec,bl1:bl2),'z');
       elseif strcmp(cfg.nor,'m')
           data = normal_z(GLAN.timefreq.data{gg,cc}(:,elec,:),GLAN.timefreq.data{gg,cc}(:,elec,bl1:bl2),'m');
       elseif strcmp(cfg.nor,'mdb')
             data = (10*(normal_z(log(GLAN.timefreq.data{gg,cc}(:,elec,:)),log(GLAN.timefreq.data{gg,cc}(:,elec,bl1:bl2)),'m')));
         elseif strcmp(cfg.nor,'db')
             data = (10*(log(GLAN.timefreq.data{gg,cc}(:,elec,:))));
       else
            data = GLAN.timefreq.data{gg,cc}(:,elec,:);
       end
       %%%
       if hh==1
           data = data .* hhdata(:,elec,:);
           data(data==0)=NaN;
       end
       
       
       pcolor(GLAN.timefreq.time, GLAN.timefreq.freq, squeeze(data)); 
       datat{cont}(:,elec,:) = data;
       shading flat
       if strcmp(cfg.nor,'mdb')
       caxis([-5 5])
       else
       caxis([-10 10]);
       end
       axcopy_lan(gcf);
       
      end
      
    end
        if cont ==2
            %data = datat{1}-datat{2};
            data =  (datarr{1})- (datarr{2} );
            if strcmp(cfg.nor,'z')
            data = normal_z(data,data(:,:,bl1:bl2),'z');
            elseif strcmp(cfg.nor,'m')
             data = normal_z(data,data(:,:,bl1:bl2),'m');
              elseif strcmp(cfg.nor,'mdb')
             data =  log(datarr{1})- log(datarr{2} );
             data = 10*(normal_z(data,data(:,:,bl1:bl2),'m'));
          %   elseif strcmp(cfg.nor,'db')
            % data =  log(GLAN.timefreq.data{cond(1)})- log(GLAN.timefreq.data{cond(2)} );
            % data = 10*(normal_z(data,data(:,:,bl1:bl2),'m'));
            end
             %data = 
            figure('Position', [0,0,1000,800])
      for elec = 1:GLAN.nbchan
      if ~isempty(GLAN.chanlocs(elec).X)
       in = find(electrodemat'==elec);
       
       subplot(y,x,in);
       %%%
          
      pcolor(GLAN.timefreq.time, GLAN.timefreq.freq, squeeze((data(:,elec,:)))); 
       
       shading flat
       caxis([-5 5]);
       axcopy_lan(gcf);
       
      end
      
    end
        end
        cont = cont + 1;
        end,
        end,
    else
      [gr cond] = size(GLAN.timefreq.data)
    for gg = 1:gr
        for cc = 1:cond    
        
    for elec = 1:LAN.nbchan
      if ~isempty(LAN.chanlocs(elec).X)
       subplot('Position',[ (LAN.chanlocs(elec).Y+90)/220,(LAN.chanlocs(elec).X+90)/220 , 0.04,0.04]);
       pcolor(LAN.freq.time,LAN.freq.freq,squeeze(LAN.freq.powspctrm(:,elec,:)));
       shading interp 
      end
    end
        end 
end% if isfield


axcopy_lan(gcf);
end
