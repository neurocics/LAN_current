function RT2 = miss2rt(RT)
%     v.0.0.1
%     <*LAN)<|
%   
%  Combierte miss en rt -99

RT2 = RT;
RT2.rt = ones(1,length(RT.misslaten))*-99;
RT2.laten = RT.misslaten;
RT2.est = RT.missest;
RT2.resp = ones(1,length(RT.misslaten))*-99;
RT2 =rt_merge(RT,RT2,1);

RT2.misslaten=[];
RT2.missest=[];


end