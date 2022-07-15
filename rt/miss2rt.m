function RT2 = miss2rt(RT)
%     v.1
%     <*LAN)<|
%   
%  Combierte miss en rt -99
%  
% 14.07.2022   fix Merge OTHER structure
  

RT2 = RT;
RT2.rt = ones(1,length(RT.misslaten))*-99;
RT2.laten = RT.misslaten;
RT2.est = RT.missest;
RT2.resp = ones(1,length(RT.misslaten))*-99;
if isfield(RT,'OTHERmiss')
RT2.OTHER = RT.OTHERmiss;
end
RT2 =rt_merge(RT,RT2,1);
RT2.misslaten=[];
RT2.missest=[];


end