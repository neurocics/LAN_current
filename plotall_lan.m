function plotall_lan(data,chanlocs,ltime,y_lim)
%          v.0.0.1
%          <*LAN)<]
%     
% Pablo Billeke
%
LAN_DEF
color =[{'blue'},{'red'},{'yellow'},{'green'},{'cyan'},...
            {'magenta'},{'yellow'},{'black'}];...
nbchan = length(chanlocs);
if isfield( chanlocs(1), 'electrodemat')
    electrodemat=chanlocs(1).electrodemat;
    [y x] = size(electrodemat);
    %figure('Position', [0,0,1000,800])
    
    for elec = 1:nbchan
      if true %~isempty(chanlocs(elec).X)
            in = find(electrodemat'==elec);
            subplot(y,x,in);
       if     iscell(data)
           for  c = 1:length(data)
                if islogical(data{c})
                     plot(ltime(any(data{c}(elec,:),1)==1),(y_lim(1) + sum(abs(y_lim))/20 )*ones(1,length(find(any(data{c}(elec,:),1)==1))),...
                    '--s','LineStyle','none',...%'LineWidth',5,...
                    'MarkerFaceColor',[0.5 0.5 0.5],...'g',...
                    'MarkerSize',3);
                hold on
                d =diff(any(data{c}(elec,:),1));

%                 for pp = find(d==1)
%                 text(ltime(pp),-2,['pval=' num2str(pvalc(elec(1),pp+1)) ]);
%                 end 
                %hold on;
                else  
                 plot(ltime,data{c}(elec,:),'Color',color{c},'LineWidth',1......
                 );%,'Interruptible','off'); 
                hold on;
                end
                title( [ ...'ERP of electrode ' 
                    chanlocs(elec).labels  '(' num2str(elec) ')'
                    ]);
                %xlabel('Seconds');
                %ylabel('\mu V');
                 xlim([ltime(1)  ltime(length(ltime))]);  
                 if exist('y_lim')
                     ylim(y_lim)
                 end
           end
       else %% ismat(data)
           
       end
       
%        if strcmp(cfg.nor,'z')
%        data = normal_z(LAN.freq.powspctrm(:,elec,:),LAN.freq.powspctrm(:,elec,bl1:bl2),'z');
%        data = squeeze(data);
%        elseif strcmp(cfg.nor,'m')
%        data = normal_z(LAN.freq.powspctrm(:,elec,:),LAN.freq.powspctrm(:,elec,bl1:bl2),'m');
%        data = squeeze(data);    
% 	  elseif strcmp(cfg.nor,'mdb')
%        data = normal_z(10*log(LAN.freq.powspctrm(:,elec,:)),10*log(LAN.freq.powspctrm(:,elec,bl1:bl2)),'m');
%        data = squeeze(data);    
%        else
%        data = squeeze(LAN.freq.powspctrm(:,elec,:));  
%        end
       
%        pcolor(LAN.freq.time,LAN.freq.freq,data); 
%        shading interp 
%        clear data
%        if strcmp(cfg.nor,'z')
%            caxis([-10,10]);
%        elseif strcmp(cfg.nor,'mdb')
%            caxis([-10,10]);
%        else
%           % caxis([0,10]);
%        end
%        
       
      end
      
    end
    else
%     for elec = 1:LAN.nbchan
%       if ~isempty(LAN.chanlocs(elec).X)
%        in = find(electrodemat'==elec); 
%        
%        subplot('Position',[ (LAN.chanlocs(elec).Y+90)/220,(LAN.chanlocs(elec).X+90)/220 , 0.04,0.04]);
%        pcolor(LAN.freq.time,LAN.freq.freq,squeeze(LAN.freq.powspctrm(:,elec,:)));
% 
%        shading interp 
%       end
%    end

end% if isfield


axcopy_lan
end
