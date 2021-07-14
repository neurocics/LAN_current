function mean_d = erp_lan(LAN,roi,bl,ifplot,hh,st)
%
%
% erp_lan.m
% plotea erp por electrodo o grupos de electrodos (roi)
% roi = vector de electrodos
% bl = tiempos de linea de base [s s]
%
%
% v.0.0.3
% Pablo Billeke - Rodrigo Henriquez
% 2009
%
% 08.08.2010
% 16.04.2010

color =[{'blue'},{'red'},{'green'},{'yellow'},{'cyan'},...
       {'magenta'},{'yellow'},{'black'}];...



if nargin <6
  st=0;
end


if nargin <5
  hh=0;
end

if nargin<4
    ifplot=1;
end

if ifplot ==2
    figure
end

if nargin<3
    bl=[];
end

if nargin<2
    roi=1;
end


if isstruct(LAN)
    for cond=1:length(hh)
    mean_t{cond} = erp_lan_struct(LAN,roi,bl,ifplot,hh(cond),color{cond},cond);
    end
elseif iscell(LAN)
    for lan = 1:length(LAN)
    mean_t{lan} = erp_lan_struct(LAN{lan},roi,bl,ifplot,hh,color{lan},lan);
    end
end

if st
    
   [p sta] = lan_nonparametric(mean_t) ;
   R = linspace(LAN.time(1,1), LAN.time(1,2),length(p));
   hold on
   R1 = R(p<=0.05);
   R2 = R(p<=0.01);
   R3 = R(p<=0.001);
   plot(R1,zeros(size(R1)),'bo')
   plot(R2,zeros(size(R2)),'ko')
   plot(R3,zeros(size(R3)),'ro')
end

end



function mean_t = erp_lan_struct(LAN,roi,bl,ifplot,hh,color,primergrafico)


if nargin >= 3 && ~isempty(bl)
    ini = bl(1) - LAN.time(1,1);
    ini = fix(ini * LAN.srate);
 
        if ini < 1, ini =1; end
    fini = bl(2) - LAN.time(1,1);
    fini = fix(fini * LAN.srate);
    %if ini < 1, ini =1; end
    bll = 1;
else
    bll =0;
end

if hh>0
   idxTT = LAN.conditions.ind{hh}; 
   if min((idxTT))==0 
      idxTT =find(idxTT); 
   end
else
   idxTT =  1:LAN.trials;
end

if iscell(LAN.data)
    mean_t = cat(3,LAN.data{idxTT});
else
    mean_t = LAN.data;
end

mean_t = mean(mean_t(roi,:,:),1);
mean_d = mean(mean_t,3);
%
%
%mean_d = mean(mean_d(roi,:),1);
if bll ==1
   mean_bl = mean(mean_d(ini:fini));
   mean_d = mean_d - mean_bl;
end
%
%timetotal = LAN.time(1,2) - LAN.time(1,1);
%pasos = timetotal/length(LAN.data{1});
%ejetiempo = LAN.time(1,1):pasos:LAN.time(1,2);
%ejetiempo = linspace(LAN.time(1,1), LAN.time(1,2),length(mean_d));
%
%ejetiempo=resample(double(ejetiempo),1,10);
%mean_d=resample(double(mean_d),1,20);
ejetiempo = linspace(LAN.time(1,1), LAN.time(1,2),length(mean_d));

%
if ifplot ==1
data = plot(ejetiempo,mean_d,'Color',color,...
    'Interruptible','off'),hold on;
if bll ==1
xlim([bl(1,1)  LAN.time(1,2)]);  
else
xlim([LAN.time(1,1)  LAN.time(1,2)]);
end
end

if bll ==1 && primergrafico == 1 && ifplot==1
    linne = line([bl(1) bl(2)],[-0 -0],'LineWidth',50,'Color',[.5 .5 .5]);
    set(gca,'Children',[data linne])
    
end

try
    title(LAN.chanlocs(roi).labels)
end

end