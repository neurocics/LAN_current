function RT = rt_check(RT,cfg)
% <*LAN)<] toolbox
% v.1.1
%
% 22.03.2022 .good 
% 11.12.2014 .est .rt .resp MUST BE MATRIX 
% 01.04.2014 fix error
% 31.03.2014 agrege ifsort option 
% 20.12.2012

if nargin <2
    cfg=[];
end

getcfg(cfg,'ifsort',false);


% stimuli  
if ~isfield(RT,'est')
    RT.est = [];
elseif iscell(RT.est)% MUST BE MATRIX 
    RT.est = cell2mat(RT.est);
end

% RT
if ~isfield(RT,'rt')
    RT.rt = zeros(size(RT.est));
elseif iscell(RT.rt)% MUST BE MATRIX 
    RT.rt = cell2mat(RT.rt);
end

% RT
if ~isfield(RT,'resp')
    RT.resp = zeros(size(RT.est));
elseif iscell(RT.resp)% MUST BE MATRIX 
    RT.resp = cell2mat(RT.resp);
end



% latencias
if isfield(RT,'laten')
    if ~isfield(RT,'latency')    
    RT.latency = RT.laten; 
    end
elseif isfield(RT,'latency')       
    RT.laten = RT.latency; 
else
    RT.laten=[];
    RT.latency = [];
end



% miss
if isfield(RT,'misslaten')

else
RT.misslaten = [];    
end

if isfield(RT,'missest')

else
RT.missest= [];    
end


% nblock
if ~isfield(RT,'nblock')
RT.nblock=1;
end

% good event
if ~isfield(RT,'good')
    RT.good=true(size(RT.est));
elseif numel(RT.good)~=numel(RT.est)
    RT.good=true(size(RT.est));
    warning('RT.good re-write as true vector ')
end

% extra check
if nargin==2
   % ----- 
   % mark FALSE in the good parameter, if the event is in unselected areas
   SS = getcfg(cfg,'selected',[]);
   if ~isempty(SS)
     srate = getcfg(cfg,'srate');
     time = getcfg(cfg,'time');
     for t = 1:length(SS);
     selected = ~SS{t};
     selected = bwlabel(selected);
     ns = unique(selected);
     for is = 1:max(ns)
         pri = find(selected==is,1,'first');
         pri = (pri/srate) *1000 - (time(t,1)*1000) ;
         ult = find(selected==is,1,'last');
         ult = (ult/srate) *1000 - (time(t,1)*1000);
         RT.good((RT.laten>=pri)&(RT.laten<=ult)) = false;
     end
     end
   end
   
   
end


%sort
if ifsort
[paso inx] = sort(RT.laten);
RT = sort_struct(RT,inx);
end

if isfield(RT,'label') && ( ~isfield(RT,'OTHER') ||( isfield(RT,'OTHER') && ~isfield(RT.OTHER,'names') ) )
    RT.OTHER.names=RT.label;
end

%%%
end