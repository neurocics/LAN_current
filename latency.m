% latencia.m
%
% v.0.5.2   fix 26.11.2009
%
% Genera LAN.time
% para luego poder epoquira LAN.data continuo
% res =                 % code of event mark of epoch
% parametres =   [1 2 ; 4 8] % eventos
%                         % si es 'no' solo bustca los res.
% names = 	       % nombre de tipos de vento [ {control} {task} ]
%
% Pablo Billeke - Rodrigo Henriquez



function [LAN, latency ] = latency(LAN, res,parametres, names  )

disp('revisar script por cambio de version a v.0.5')

if nargin < 4, 
    for i = 1:length(res)
    name{i} = num2str(i);
    end
end
if nargin < 3, parametres = 'no';end

if ~isstr(parametres)% ~= 'no'

inicio = parametres(1,:);
final = parametres(2,:);


if length(inicio) ~= length(final)
    error('"inicio" and "final" vector must have the same dimention ')
end

if iscell(LAN)
    error('Solo para LAN simples, no en celdas')
end

types = length(inicio);
currcode = cell2mat({LAN.event.type});

ui = figure;
Position = [50 450 400 50];

if ~strcmp(res , 'no') %#ok<STCMP>

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
    if  LAN.event(i+1).type == final(a) && LAN.event(i-1).type == inicio(a) % & LAN.event(i-2).type == final(a)
        latency{a}.cuantos = latency{a}.cuantos + 1;
        latency{a}.latency(latency{a}.cuantos) = LAN.event(i).latency - LAN.event(i-1).latency;
        latency{a}.inicio(latency{a}.cuantos) = LAN.event(i-1).latency;
        latency{a}.final(latency{a}.cuantos) = LAN.event(i+1).latency;
        latency{a}.zero(latency{a}.cuantos) = LAN.event(i).latency;
        currcode(i) = 100;
        
    elseif LAN.event(i+1).type == final(a) && LAN.event(i-2).type == inicio(a) &&  LAN.event(i-1).type ~= res 
        latency{a}.cuantos = latency{a}.cuantos + 1;
        latency{a}.latency(latency{a}.cuantos) = LAN.event(i).latency - LAN.event(i-2).latency;
        latency{a}.inicio(latency{a}.cuantos) = LAN.event(i-2).latency;
        latency{a}.final(latency{a}.cuantos) = LAN.event(i+1).latency;
        latency{a}.zero(latency{a}.cuantos) = LAN.event(i).latency;
        currcode(i) = 100;
    elseif i < length(LAN.event)-1
        if LAN.event(i+1).type ~= final(a) && LAN.event(i+1).type ~= res && LAN.event(i+2).type == final(a) && LAN.event(i-1).type == inicio(a) %& LAN.event(i-2).type == final(a)
        latency{a}.cuantos = latency{a}.cuantos + 1;
        latency{a}.latency(latency{a}.cuantos) = LAN.event(i).latency - LAN.event(i-1).latency;
        latency{a}.inicio(latency{a}.cuantos) = LAN.event(i-1).latency;
        latency{a}.final(latency{a}.cuantos) = LAN.event(i+2).latency;
        latency{a}.zero(latency{a}.cuantos) = LAN.event(i).latency;
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
 arreglo = find(loc==length(LAN.event));
 loc(arreglo) = [];
 
 for i = loc
    % latencia primeros
    for ite = 1:100
       if  LAN.event(i+ite).type == final(a)%& LAN.event(i-2).type == final(a)
	   ik = i+ite;edit
       break,end
    end

        latency{a}.cuantos = latency{a}.cuantos + 1;
        latency{a}.latency(latency{a}.cuantos) = LAN.event(ik).latency - LAN.event(i).latency;
        latency{a}.inicio(latency{a}.cuantos) = LAN.event(i).latency;
        latency{a}.final(latency{a}.cuantos) = LAN.event(ik).latency;
        latency{a}.zero(latency{a}.cuantos) = LAN.event(i).latency;
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
if res~='no'
    [loc] = find(currcode==res);
    for l = 1:length(loc)
        lat(l) = LAN.event(loc(l)).latency / LAN.srate;
    end
    if isempty(loc)
     lat = [];
    end
else
    
    for i=1:length(inicio)
            [loc_aux] = find(currcode==inicio(i));
            llat=length(lat);
        for l = llat+1:llat+length(loc_aux)
            lat(l) = LAN.event(loc_aux(l-llat)).latency / LAN.srate;
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
currcode = cell2mat({LAN.event.type});

for a = 1:types
    [loc] = find(currcode==res(a));
    eventos = length(loc); 
    
 latency{a}.cuantos = 0;
 arreglo = find(loc==1);
 loc(arreglo) = [];
 arreglo = find(loc==length(LAN.event));
 loc(arreglo) = [];
 
 for i = loc
          latency{a}.cuantos = latency{a}.cuantos + 1;
          latency{a}.zero(latency{a}.cuantos) = LAN.event(i).latency;
          currcode(i) = 100;
end
end
 
 
if length(res) == 1
    lzero = latency{1}.zero';
    if ~isempty(lzero)
        for i = 1:length(lzero)
        LAN.time(i,3) = lzero(i);
        end
    end
     LAN.cond = names{1};
     
elseif length(res) > 1
    LANaux = LAN;
    clear LAN;
    
    for i = 1:length(res)
    LAN{i}=LANaux;
    lzero = latency{i}.zero';
        if ~isempty(lzero)
            for ii = 1:length(lzero)
                LAN{i}.time(ii,3) = lzero(ii);
            end    
        LAN{i}.cond = names{i} ;
        end
    end    
    
end
end
end




