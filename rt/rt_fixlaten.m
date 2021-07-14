function RT = rt_fixlaten(RT,cfg)
% v.0.0.2 
% <*LAN)<] toolbox
% RT_fixlaten  
%
% cfg.f         : firts laten 
% cfg.laten     : reference laten (estimulation program)
% RT            : rt structur of laten of the recording programs
% dw_delta      : [200] % bajo este desta lo considera delay del sofware
% up_delta      : [200] % sobre este lo considera estimulo perdido 

% 25.06.2013

getcfg(cfg,'ifplot',1)
getcfg(cfg,'f',1)
getcfg(cfg,'RTfix')
if exist('RTfix','var')
laten = RTfix.laten;
est = RTfix.est;
resp = RTfix.resp;
rt = RTfix.rt;
else
getcfg(cfg,'laten') 
getcfg(cfg,'rt') 
getcfg(cfg,'est') 
getcfg(cfg,'resp') 
getcfg(cfg,'force',0) 
end

getcfg(cfg,'dw_delta', 200)
getcfg(cfg,'up_delta', 200)
% firt firts point
laten = laten - laten(1);
laten = laten + RT.laten(f); 

c_delta = 0;
p_delta=0;
cc = 0;
fixed = 1;
cambio=0;
for i = 1:length(laten)-1  
    cc = cc +1;
    if length(RT.laten)==(f+i-1) % the case of the last event is missed;
    delta = dw_delta+1;    
    else
    delta = RT.laten(f+i) - laten(1+i) - c_delta ;
    end
    if (abs(delta) <= dw_delta) || (any(i==force))
        p_delta(cc) = delta;
        add_delta(cc) = c_delta;  
        
        
       c_delta = c_delta + delta;
       paso_laten(cc) = RT.laten(f+i);
       paso_est(cc) = RT.est(f+i);
       paso_rt(cc) = RT.rt(f+i);
       paso_resp(cc) = RT.resp(f+i);
    elseif abs(delta) >= up_delta
        cambio(end+1) = cc;
        p_delta(cc) = NaN;%delta;
        add_delta(cc) = NaN;%c_delta;
        
       disp('add event')
       paso_laten(cc) = laten(1+i) - c_delta;
       paso_est(cc) = est(i+1);
       paso_rt(cc) = rt(i+1);
       paso_resp(cc) = resp(i+1);
       fixed(end+1) = cc;
       f = f -1;
    else
        warning('xxx')
    end
end

% new RT
%getcfg(cfg,'f',1)
fend = (f+i+1);
getcfg(cfg,'f',1)
if isempty(RT.laten(fend:end))
RT.laten = cat(2, RT.laten(1:f), paso_laten);
RT.est = cat(2, RT.est(1:f), paso_est);
RT.rt = cat(2, RT.rt(1:f), paso_rt);
RT.resp = cat(2, RT.resp(1:f), paso_resp);
else
RT.laten = cat(2, RT.laten(1:f), paso_laten,RT.laten(fend:end));
RT.est = cat(2, RT.est(1:f), paso_est,RT.est(fend:end));
RT.rt = cat(2, RT.rt(1:f), paso_rt,RT.rt(fend:end));
RT.resp = cat(2, RT.resp(1:f), paso_resp,RT.resp(fend:end));    
end

if ifplot
plot((0:cc-1)+f, add_delta,'r'), hold on
plot((1:cc)+f, p_delta)
plot(cambio+f,zeros(size(cambio)),'o'), hold off
end

RT.latency = RT.laten;

% fix me
RT = rmfield(RT,'good');
RT = rt_check(RT);

end