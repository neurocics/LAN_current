function RT = rt_resample(RT,cfg)
%     v.0.0.2
%     <*LAN)<|
%
%
%
% cfg.newfs   = [n] or [n1 ..]
%
%
% Pablo Billeke
% Francisco Zamorano
if nargin == 1
 newfs =min(diff(RT.laten));
 cfg.newfs = newfs;
else
  if isnumeric(cfg)
    newfs = cfg;
    cfg = [];
    cfg.newfs = newfs;
elseif isstruct(cfg)
    if isfield(cfg,'newfs')
    newfs = cfg.newfs;
    else
    newfs =min(diff(RT.laten))/2;
    cfg.newfs = newfs;
    end
else
    erro('you must define the new frequecy of sampling');
end  
    
end



%
if ~iscell(RT.rt)


try
    ini  = min(RT.laten(1),RT.misslaten(1));
catch
    ini = RT.laten(1);
end

if isempty(    RT.misslaten)
    fin = max(RT.laten);
else
    fin  = max(max(RT.laten),max(RT.misslaten));
end

if length(newfs)==1
    fs = ini:newfs:fin;
    fs = cat(2,fs,newfs+fs(length(fs)));
end


rt = spline(RT.laten,RT.rt,fs);

RT.rs.rt = rt;
RT.rs.laten=fs;
RT.rs.cfg = cfg;


else
    for nrt = 1:length(RT.rt)
        
        
    try
    ini  = min(RT.laten{nrt}(1),RT.misslaten{nrt}(1));
    catch
    ini = RT.laten{nrt}(1);
    end
    try
        if isempty(max(RT.misslaten{nrt}))
        fin = max(RT.laten{nrt});
        else
        fin  = max(max(RT.laten{nrt}),max(RT.misslaten{nrt}));    
        end
    catch
    fin = max(RT.laten{nrt});
    end


if length(newfs)==1
    fs = ini:newfs:fin;
    fs = cat(2,fs,newfs+fs(length(fs)));
end


rt = spline(RT.laten{nrt},RT.rt{nrt},fs);

RT.rs.rt{nrt} = rt;
RT.rs.laten{nrt}=fs;

    
    
    
    end
end

RT.rs.cfg = cfg;