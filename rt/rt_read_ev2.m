function RT = rt_read_ev2(cfg)
%     v.0.0.1.1
%     <*LAN)<|
%   
%
%
% cfg.filename =       'nombredearchivo.ev2'
% cfg.ref   =[]
% cfg.refl  = 
% cfg.delim =      [est, resp,resp,resp;
%                         est, resp,resp,-99]  %% matriz con estimulos
%                                         y respuestas  para cada estimulo
%                                         -99 se ocupa para cuadrar las
%                                         matricez
% cfg.dist =       %distarctor, termian el tiempo de respestaas
% cfg.rw = []           (ventada de rerspuestas)
% cfg.iflbc =        partir las latencia del priemr estimulo contado como cero.
% cfg.unit = 'ms'      %% unidades 's'
% cfg.miss=0;          % no separa los miss
%
%     5.07.2011  
%     2.05.2011
%
% Pablo Billeke
% Francisco Zamorano

if isfield(cfg,'iflbc') 
    iflbc = cfg.iflbc;
else
    iflbc = 0;
    cfg.iflbc = 0;
end


if isfield(cfg,'delim') 
    ifrt=1;
    ifdelim=1;
    delim = cfg.delim;
else
    ifrt=0;
    ifdelim=0;
end


if isfield(cfg,'stop') 
    ifstop = 1;
    stop = cfg.stop;
else
    ifstop = 0;
end



if isfield(cfg, 'unit')
   if strcmp(cfg.unit, 'ms'), unit = 1; 
   elseif strcmp(cfg.unit, 's'), unit = 0.001; 
   end
else
    cfg.unit = 'ms';
    unit = 1;
end

if isfield(cfg,'rw') 
    ifrw = 1;
    rw = cfg.rw/unit;
else
    ifrw = 0;
end

if isfield(cfg,'miss')
    ifmiss=cfg.miss;
else
    ifmiss=1;
end




raw = readtext(cfg.filename,' ','','','textual');%
[f c] = size(raw);
%
data = cell(f,6);
for ci = 1:f
    %paso = 
    data(ci,:) = raw(ci,~isemptycell(raw(ci,:)));
end
%



%header = raw(1:5,:);
%data = raw(1:f,:);
%if strcmp(header{4,1}, 'Subject')
%suject = data{1,1};
%data = data(:,2:c);
%end

if ifrt && ifdelim
    odel = str2double(data(:,2)); % estimulos
    rdel = str2double(data(:,3)); % respuestas
    del = zeros(size(odel));
    tt  = str2double(data(:,6));% columna del tiempo

    for i = 1:size(delim,1)
            del= del + (odel==delim(i,1)); % estimulo
            for ii = 2:size(delim,2)
                if delim(i,ii)==-99, break,end % termina el loop al encontrat un -99
                del = del + (2*(rdel==delim(i,ii)));    
            end
    end
if ifstop
del = del + (3*(odel==stop(1))); % stop entendido como estimulo   
end

delind = find(del==1);
%%%
c=1;
cmis=1;
misslaten = 0;
%laten = tt(r);
for r = delind'  
    rp=1;
    while rp > 0
    if ( r+rp > length(del) ) || ( del(r+rp) == 1) || ( del(r+rp) == 3)
        misslaten(cmis) = tt(r);
        missest(cmis) = odel(r);
        rp = -1;  % end, miss 
        cmis = cmis+1;
    elseif del(r+rp) == 2
        laten(c) = tt(r);
        rt(c)    = tt(r+rp) - tt(r);
        resp(c)  = rdel(r+rp);
        est(c)   = odel(r);
        if logical(ifrw) && (rt(c) > rw)
            misslaten(cmis) = tt(r);
            missest(cmis) = odel(r);
            rp = -1;  % end, miss 
            cmis = cmis+1;
                laten(c) = [];
                rt(c)    = [];
                resp(c)  = [];
                est(c)   = [];
        else
            rp = 0;
            c = c+1;
        end
    else
        rp = rp +1;
    end
    end
    %%%
    
end

if sum(misslaten) >0
    ifml=1;
else
    ifml=0;
end

if iflbc
    if sum(misslaten) >0
    lb = min(laten(1),misslaten(1));
    else
    lb = min(laten);
    end
else

    lb=0;
end
RT.rt    = (rt) * unit;
RT.laten = (laten-lb) * unit;
if ifml
    RT.misslaten = (misslaten-lb) * unit;
    RT.missest = missest;
else
     RT.misslaten = [];
     RT.missest   = [];
end

RT.est = est;
RT.resp = resp;
RT.cfg = cfg; 
RT.nblock = 1;

if ~ifmiss
    RT = miss2rt(RT);
end

end