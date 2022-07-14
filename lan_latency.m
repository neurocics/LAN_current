
function [LAN, latency ] = lan_latency(LAN, cfg )
% <*LAN)<] 
% v.0.0.6
% from latencia.m
% Genera LAN.time para luego poder epoquira LAN.data continuo
% cfg. source  % 'RT'
               % 'event'
% cfg. ref     % code of event mark of epoch (references)
% cfg.zero = 'stim' or 'resp' % take the stimuli or the response as the
%                             % zero time to segment
% cfg.parametres =   [1 2 ; 4 8] % eventos
%                         % si es 'no' solo bustca los res.
% cfg.names = 	       % nombre de tipos de vento [ {control} {task} ]
% cfg.divide = false; 
% cfg.epoch = false;
% cfg.times = [-x y];   % time for segmentation, if cfg.epoch==true

% Pablo Billeke - Rodrigo Henriquez

% 24.10.2013  add ZERO option in cfg.
% 18.10.2013  fix zero points  
% 22.04.2013
% 06.07.2012

% disp('revisar script por cambio de version a v.0.5')

if iscell(LAN)
    error('Solo para LAN simples, no en celdas')
end

getcfg(cfg, 'source','RT')
% for compatibility, now use only parameter REF
res = getcfg(cfg,'ref',[]);
if isempty(res)
    getcfg(cfg, 'res','no')
end
getcfg(cfg,'zero','est')
getcfg(cfg, 'parametres','no')
getcfg(cfg, 'names','no')%arreglar
getcfg(cfg, 'divide',false)
getcfg(cfg,'deltemp',true)
ifepoch = getcfg(cfg, 'epoch',true);
delnoR = 0;
if ischar(names) && strcmp(names,'no')% && divide, 
    names=[];
    for i = 1:length(res)
    names{i} = num2str(i);
    end
end



if ~ischar(parametres)% ~= 'no'

inicio = parametres(1,:);
final = parametres(2,:);


if length(inicio) ~= length(final)
    error('"inicio" and "final" vector must have the same dimention ')
end



types = length(inicio);

switch source
    case 'event' 
    currcode = cell2mat({LAN.event.type});
    
    c_latency = cell2mat({LAN.event.latency});
    case 'RT'
        LAN.RT = rt_check(LAN.RT);
        currcode = LAN.RT.est;
        currcode_resp  = LAN.RT.resp;
        c_latency_rt = LAN.RT.rt; 
        c_latency = LAN.RT.latency; 
end    
type = currcode;

ui = figure;
Position = [50 450 400 50];

if ~ischar(res)% , 'no') 

[loc] = find(currcode==res);
eventos = length(loc);

for a = 1:types
 latency{a}.cuantos = 0;
 arreglo = find(loc==1);
 loc(arreglo) = [];
 arreglo = find(loc==length(LAN.event));
 loc(arreglo) = [];
 
 for i = loc
    % latencia primeros
    if type(i+1) == final(a) && type(i-1) == inicio(a) % & LAN.event(i-2).type == final(a)
        latency{a}.cuantos = latency{a}.cuantos + 1;
        latency{a}.latency(latency{a}.cuantos) = c_latency(i) - c_latency(i-1);
        latency{a}.inicio(latency{a}.cuantos) = c_latency(i-1);
        latency{a}.final(latency{a}.cuantos) = c_latency(i+1);
        latency{a}.zero(latency{a}.cuantos) = c_latency(i);
        currcode(i) = 100;
        
    elseif type(i+1) == final(a) && type(i-2) == inicio(a) &&  type(i-1) ~= res 
        latency{a}.cuantos = latency{a}.cuantos + 1;
        latency{a}.latency(latency{a}.cuantos) = c_latency(i) - c_latency(i-2);%LAN.event(i).latency - LAN.event(i-2).latency;
        latency{a}.inicio(latency{a}.cuantos) = c_latency(i-2);%LAN.event(i-2).latency;
        latency{a}.final(latency{a}.cuantos) = c_latency(i+1);%LAN.event(i+1).latency;
        latency{a}.zero(latency{a}.cuantos) = c_latency(i);%LAN.event(i).latency;
        currcode(i) = 100;
    elseif i < length(c_latency)-1
        if type(i+1) ~= final(a) && type(i+1) ~= res && type(i+2) == final(a) && type(i-1) == inicio(a) %& LAN.event(i-2).type == final(a)
        latency{a}.cuantos = latency{a}.cuantos + 1;
        latency{a}.latency(latency{a}.cuantos) = c_latency(i) - c_latency(i-1);%LAN.event(i).latency - LAN.event(i-1).latency;
        latency{a}.inicio(latency{a}.cuantos) = c_latency(i-1);%LAN.event(i-1).latency;
        latency{a}.final(latency{a}.cuantos) = c_latency(i+2);%LAN.event(i+2).latency;
        latency{a}.zero(latency{a}.cuantos) = c_latency(i);%LAN.event(i).latency;
        currcode(i) = 100;
        end
    end
 end
 Position = Position - [0 100 0 0];
uicontrol(ui, 'Style','text','String', [ num2str(a) 'Eventos' num2str(inicio(a)) ' a '  num2str(final(a))] ,'Position',Position,'Callback', 'setmap');
Position2 = Position - [0 50 0 0];
uicontrol(ui, 'Style','text','String', [ ' # '  num2str(latency{a}.cuantos)] ,'Position',Position2,'Callback', 'setmap');
end
%%%%%%%%%%%%%%%%%%%%%
else
ress = inicio;


for a = 1:types
mark = ress(a);
[loc] = find(currcode==mark);
eventos = length(loc);
 latency{a}.cuantos = 0;
 arreglo = find(loc==1);
 loc(arreglo) = [];
 %arreglo = find(loc==length(LAN.));
 %loc(arreglo) = [];
 
 for i = loc
    % latencia primeros
    for ite = 1:100
       if type(i+ite) == final(a)%& LAN.event(i-2).type == final(a)
	   ik = i+ite;% edit ????????????????????????
       break,end
    end

        latency{a}.cuantos = latency{a}.cuantos + 1;
        latency{a}.latency(latency{a}.cuantos) = c_latency(ik) - c_latency(i);%LAN.event(i).latency;
        latency{a}.inicio(latency{a}.cuantos) = c_latency(i);
        latency{a}.final(latency{a}.cuantos) = c_latency(ik);
        latency{a}.zero(latency{a}.cuantos) = c_latency(i);
        currcode(i) = 100;
           
 end

Position = Position - [0 100 0 0];
uicontrol(ui, 'Style','text','String', [ num2str(a) 'Eventos' num2str(inicio(a)) ' a '  num2str(final(a))] ,'Position',Position,'Callback', 'setmap');
Position2 = Position - [0 50 0 0];
uicontrol(ui, 'Style','text','String', [ ' # '  num2str(latency{a}.cuantos)] ,'Position',Position2,'Callback', 'setmap');

end

end

 


loc = [];
loc_aux =[];
lat =[];
if ~ischar(res) %='no'
    [loc] = find(currcode==res);
    for l = 1:length(loc)
        lat(l) = c_latency(loc(l)) / LAN.srate;
    end
    if isempty(loc)
     lat = [];
    end
else
    
    for i=1:length(inicio)
            [loc_aux] = find(currcode==inicio(i));
            llat=length(lat);
        for l = llat+1:llat+length(loc_aux)
            lat(l) = c_latency(loc_aux(l-llat)) / LAN.srate;
            loc(l) = loc_aux(l-llat);
        end
        if isempty(loc)
         lat = [];
        end
    end
end



Position = Position - [0 100 0 0];
uicontrol(ui, 'Style','text','String', [  'Total Eventos = _' num2str(eventos)] ,'Position',Position,'Callback', 'setmap');
Position = Position - [0 50 0 0];
uicontrol(ui, 'Style','text','String', [  'no contados_.#_' num2str(loc)] ,'Position',Position,'Callback', 'setmap');
Position = Position - [0 50 0 0];
uicontrol(ui, 'Style','text','String', [  'no contados_.lat_' num2str(lat)] ,'Position',Position,'Callback', 'setmap');




if length(inicio) == 1
    
    linicio = latency{1}.inicio';
    lfinal =  latency{1}.final';
    lzero = latency{1}.zero';
    if ~isempty(zero)
    for i = 1:length(zero)
    LAN.time(i,1) = (linicio(i) - lzero(i))/LAN.srate;
    LAN.time(i,2) = (lfinal(i) - lzero(i))/LAN.srate;
    LAN.time(i,3) = lzero(i);
    end
    end
     LAN.cond = names{1};
     
elseif length(inicio) > 1
    LANaux = LAN;
    clear LAN;
    
    for i = 1:length(inicio)
    LAN{i}=LANaux;
    
    linicio = latency{i}.inicio';
    lfinal =  latency{i}.final';
    lzero = latency{i}.zero';
    if ~isempty(lzero)
    for ii = 1:length(lzero)
    LAN{i}.time(ii,1) = (linicio(ii) - lzero(ii))/LAN{i}.srate;
    LAN{i}.time(ii,2) = (lfinal(ii) - lzero(ii))/LAN{i}.srate;
    LAN{i}.time(ii,3) = lzero(ii);
    end    
    LAN{i}.cond = names{i} ;
    end
    end
    clear LANaux;
    

    
end
    


if ~isempty(names)
     if size(names) == size(inicio)
         for i = 1:length(names)
             num = names{i};
             aux = strrep('Latency.X  = latency{W}','X', num);
             aux_b = strrep(aux,'W', num2str(i));
             eval(aux_b)
             clear aux*
         end
     end
end
if exist('Latency', 'var')
     latency = Latency;
end

elseif  strcmp(parametres, 'no') 

types = length(res);
switch source
    case 'event' 
    currcode = cell2mat({LAN.event.type});
    
    c_latency = cell2mat({LAN.event.latency});
    case 'RT'
    LAN.RT = rt_check(LAN.RT);
    currcode = LAN.RT.est;  
    c_latency = LAN.RT.laten; 
    currcode_resp  = LAN.RT.resp;
    c_latency_rt = LAN.RT.rt; 
    c_latency = LAN.RT.latency; 
end  
%currcode = cell2mat({LAN.event.type});

for a = 1:types
    [loc] = find(currcode==res(a));
    eventos = length(loc);

    idxRT{a} =loc; 

 latency{a}.cuantos = 0;
 %arreglo = find(loc==1);
 %loc(arreglo) = [];
 %arreglo = find(loc==length(LAN.event));
 %loc(arreglo) = [];
 
 for i = loc
          switch zero 
              case {'est','Est','EST', 'STIM','stim'}
                latency{a}.cuantos = latency{a}.cuantos + 1;
                latency{a}.zero(latency{a}.cuantos) = c_latency(i);
                currcode(i) = 100;
              case {'resp','Resp','RESP'}
                  if currcode_resp(i) ~= -99;
                    latency{a}.cuantos = latency{a}.cuantos + 1;
                    latency{a}.zero(latency{a}.cuantos) = c_latency(i)+c_latency_rt(i);
                    currcode(i) = 100; 
                  else
                      delnoR=1;
                  end
          end
end
end
 
 
if length(res) == 1
    lzero = latency{1}.zero';
    if ~isempty(lzero)
        %for i = 1:length(lzero)
        LAN.time = [];
        LAN.time(:,3) = (lzero(:)./(1000./LAN.srate)); % de milisegundos a puntos!!!
        %end
    end
     LAN.cond = names{1};
     LAN.RT = rt_del(LAN.RT,cat(2,idxRT{:}),-1);
     
elseif length(res) > 1
    
    if divide
    LANaux = LAN;
    clear LAN;
    for i = 1:length(res)
    LAN{i}=LANaux;
    lzero = latency{i}.zero';
        if ~isempty(lzero)
            for ii = 1:length(lzero)
                LAN{i}.time(ii,3) = (lzero(ii)./(1000./LAN.srate)); % de milisegundos a puntos!!!
            end    
        LAN{i}.cond = names{i} ;
        end
    LAN{i}.RT = rt_del(LANaux.RT,idxRT{i},-1);    
    end    
    %
   
    else
        zeros = latency{1}.zero;
        for  i = 2:length(latency)
            if latency{i}.cuantos == 0, continue, end,
            zeros = cat(2,zeros,latency{i}.zero);
        end
        zeros = sort(zeros);
        %for i = 1:length(lzero)
        LAN.time = [];
        LAN.time(:,3) =  (zeros(:)./(1000./LAN.srate));
        %end %LAN.time
        LAN.RT = rt_del(LAN.RT,cat(2,idxRT{:}),-1);  
    end
end


end

if ~ischar(res) && (ischar(parametres) && strcmp(parametres,'no'))
  times = getcfg(cfg,'times',[0 0])  ;
  disp(['times set :' num2str(times) ])
  LAN = mod_time(LAN,times,[1 2],1);
end

if ifepoch
    cfg.times = LAN.time;
    % delete repeated  event !!!
    cfg.times( [diff(cfg.times(:,3))==0 ; false ],:) = [];
    LAN = lan_epoch(LAN,cfg);
end

if delnoR   
    latency = LAN.RT.resp==-99;
    LAN.RT = rt_del(LAN.RT,latency);
    
end


LAN = lan_check(LAN);




