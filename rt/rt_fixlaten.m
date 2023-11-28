function RT = rt_fixlaten(RT,cfg)
% v.1 
% <*LAN)<] toolbox
% RT_fixlaten  
%
% cfg.f         : firts laten 
% cfg.laten     : reference laten (estimulation program)
% RT            : rt structur of laten of the recording programs
% dw_delta      : [200] % bajo este desta lo considera delay del sofware
% up_delta      : [200] % sobre este lo considera estimulo perdido 

% 06.12.2022  add compatibility for good field 
% 11.07.2022  add information to report, and save latency diferences in
%             RT.OTHER
% 25.06.2013

getcfg(cfg,'ifplot',1)
getcfg(cfg,'f',1)
getcfg(cfg,'RTfix')
if exist('RTfix','var')
laten = RTfix.laten;
est = RTfix.est;
resp = RTfix.resp;
rt = RTfix.rt;
good = RTfix.good;
else
getcfg(cfg,'bi')     
getcfg(cfg,'laten') 
getcfg(cfg,'rt') 
getcfg(cfg,'est') 
getcfg(cfg,'resp') 
getcfg(cfg,'good') 
getcfg(cfg,'force',0) 
end

getcfg(cfg,'dw_delta', 150)
getcfg(cfg,'up_delta', 150)
% firt firts point
laten = laten - laten(1);
laten = laten + RT.laten(f); 

c_delta = 0;
p_delta=0;
cc = 0;
fixed = 1;
cambio=0;
i=0;
ic=0;
while i<(length(laten) -ic-1)%for i = 1:length(laten)-1  
    i=i+1;
    cc = cc +1;
    if length(RT.laten)==(f+i-1) % the case of the last event is missed;
    delta = dw_delta+1;    
    else
    delta = RT.laten(f+i) - laten(1+i+ic) - c_delta ;
    end
    
    if (abs(delta) <= dw_delta)  && RT.est(f+i)==est(1+i+ic)   || (any(i==force))
        p_delta(cc) = delta;
        add_delta(cc) = c_delta;  
        
        
       c_delta = c_delta + delta;
       paso_laten(cc) = RT.laten(f+i);
       paso_est(cc) = RT.est(f+i);
       paso_rt(cc) = RT.rt(f+i);
       paso_good(cc) = RT.good(f+i);
       paso_resp(cc) = RT.resp(f+i);
       paso_delta(cc) = delta;
       paso_fixed(cc) = 0;

    elseif delta < (-1*dw_delta) && 0 %%%% 
       ic =ic-1;
       %cc=cc-1;
        p_delta(cc) = NaN;
        add_delta(cc) = NaN;  
%         
%       %c_delta = c_delta + delta;
        paso_laten(cc) = RT.laten(f+i);
        paso_est(cc) = RT.est(f+i);
        paso_rt(cc) = RT.rt(f+i);
        paso_good(cc) = RT.good(f+i);
        paso_resp(cc) = RT.resp(f+i);
        paso_delta(cc) = delta;
        paso_fixed(cc) = -1;

        disp([ 'missed event .. ' num2str(i) ' to' num2str(f+i)  ' delat ' num2str(delta)  ' estim  '  num2str(RT.est(f+i)) ' --> ' num2str(est(1+i+ic))])
      
    %end






    else%if delta > -1*dw_delta% ||
        cambio(end+1) = cc;
        p_delta(cc) = NaN;%delta;
        add_delta(cc) = NaN;%c_delta;
        
       paso_laten(cc) = laten(1+i+ic) - c_delta;
       paso_est(cc) = est(i+1+ic);
       paso_rt(cc) = rt(i+1+ic);
       paso_resp(cc) = resp(i+1+ic);
       paso_good(cc) = good(i+1+ic);
       paso_delta(cc) = delta;
       paso_fixed(cc) = 1;
       fixed(end+1) = cc;
       f = f -1;

       disp([ 'add event .. ' num2str(i) ' to' num2str(f+i)  ' delat ' num2str(delta)  ' estim  '  num2str(RT.est(f+i)) ' <-- ' num2str(est(1+i+ic))])
      
    %else
     %   warning('xxx')
    end
end

% new RT
e=getcfg(cfg,'f',1);
fend = (f+i+e-1)+1;
getcfg(cfg,'f',1)
if isempty(RT.laten(fend:end))
RT.laten = cat(2, RT.laten(1:f), paso_laten);
RT.est = cat(2, RT.est(1:f), paso_est);
RT.rt = cat(2, RT.rt(1:f), paso_rt);
RT.resp = cat(2, RT.resp(1:f), paso_resp);
RT.good = cat(2, RT.good(1:f), paso_good);
RT.OTHER.delta = cat(2, zeros(size(RT.resp(1:f))), paso_delta);
RT.OTHER.fixed = cat(2, zeros(size(RT.resp(1:f))), paso_fixed);
else
RT.laten = cat(2, RT.laten(1:f), paso_laten,RT.laten(fend:end));
RT.rt = cat(2, RT.rt(1:f), paso_rt,RT.rt(fend:end));
RT.good = cat(2, RT.good(1:f), paso_good,RT.good(fend:end));
RT.resp = cat(2, RT.resp(1:f), paso_resp,RT.resp(fend:end));  
RT.OTHER.delta = cat(2, zeros(size(RT.est(1:f))), paso_delta,zeros(size(RT.est(fend:end))));
RT.OTHER.fixed = cat(2, zeros(size(RT.est(1:f))), paso_fixed,zeros(size(RT.est(fend:end))));
RT.est = cat(2, RT.est(1:f), paso_est,RT.est(fend:end));
end

if ifplot
plot((0:cc-1)+f, add_delta,'r'), hold on
plot((1:cc)+f, p_delta)
plot(cambio+f,zeros(size(cambio)),'o'), hold off
end

for eve = unique(RT.est)
    try
    paso = p_delta((RT.est(2:end)==eve));
    paso(isnan(paso)) = [];
    paso = sort(paso);
    npaso =length(paso);
    HDI =[ paso(fix(npaso*0.1)) paso(fix(npaso*0.9))];
    
    disp([ 'Lag for estim '  num2str(eve) '  mean : '  num2str( mean(paso))  '  median : '  num2str( median(paso))    '  80%HDI:' num2str(HDI) ])
    end
end


RT.latency = RT.laten;

% fix me
% RT = rmfield(RT,'good');
RT = rt_check(RT);

end