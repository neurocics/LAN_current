function RT =  rt_merge(RT1,RT2,varargin)
%     v.0.0.4
%     <*LAN)<|
%  
% Description
%   Take two RT struct and merge them horizontally.
%
% Parameters
%   (RT) R1:     First RT
%   (RT) R2:     Second RT
%   (RT) varargin(:end-1):  A variable amount of RT structs
%   (bool) varargin(end):   Boolean. Indicates if sorts the output
%
% Returns
%   (RT) RT:    The merged RT's
%   
% Examples
%   >> RT1
%   RT1 = 
%        ...
%        good: [1x964 logical]
%        ...
%
%   >> RT2
%   RT2 = 
%        ...
%        good: [1x1160 logical]
%        ...
%   >> rt_merge(RT1, RT2)
%   ans = 
%         good: [1x2124 logical]
%         ...
%
%   >> rt_merge(RT1, RT2, 1) %% Returns the same but sorted
%   ans = 
%         good: [1x2124 logical]
%         ...
%
%   >> rt_merge(RT1, RT2, RT1, RT2, 1)
%   ans = 
%         good: [1x4248 logical]
%         ... 
%
% Author(s) 
%   Pablo Billeke
%
% Changes
%   15.01.2013
%   04.12.2012 (PB) fix merge empty RT
%   06.07.2012 (PB) add OTHER field
%   18.11.2011 (PB) add correct field
%   ??

if nargin>2
    if ~isstruct(varargin{end})
        ifsort = varargin{end};
        varargin(end) = [];
    else
        ifsort = 0;
    end
    
    if numel(varargin)>0
        RT2 = rt_merge(RT2,varargin{:},ifsort);
    end
else
    ifsort = 0;
end


if isempty(RT1.est)
    RT =RT2;
    return
elseif isempty(RT2.est)
    RT=RT1;
    return
end


RT1 = rt_check(RT1);
RT2 = rt_check(RT2);

if ~iscell(RT1.rt)
    l1 = length(RT1.rt);
    ml1 = length(RT1.misslaten);
end

if ~iscell(RT2.rt)
    l2 = length(RT2.rt);
    ml2 = length(RT2.misslaten);
end

%%laten
TODO = cat(2,RT1.laten,RT2.laten);
if ifsort
    [to indx ]= sort(TODO,'ascend');
    paso = 1:length(indx);
    [to indx ]= sort(paso(indx),'ascend');
else
    indx = 1:length(TODO);
end
l1dx = indx(1:l1);
l2dx = indx([(1+l1):(l2+l1)]);

%%misslaten
TODO = cat(2,RT1.misslaten,RT2.misslaten);
if ifsort
    [to indx ]= sort(TODO,'ascend');
    paso = 1:length(indx);
    [to indx ]= sort(paso(indx),'ascend');
else
    indx = 1:length(TODO);
end
ml1dx = indx(1:ml1);
ml2dx = indx([(1+ml1):(ml2+ml1)]);


if isfield(RT1, 'correct') && isfield(RT1, 'correct')
    ifc = true;
else
    ifc = false;
end

RT.good(l1dx) = RT1.good;
RT.good(l2dx) = RT2.good;

%%%
if ~iscell(RT1.rt)
    RT.rt(l1dx) = RT1.rt;
    RT.laten(l1dx) = RT1.laten;
    RT.resp(l1dx) = RT1.resp;
    RT.est(l1dx) = RT1.est;
    
    if ifc, RT.correct(l1dx) = RT1.correct;end
    
    try
        RT.misslaten(ml1dx) = RT1.misslaten;
        RT.missest(ml1dx) = RT1.missest;
    catch
        RT.misslaten{ml1dx} = [];
    end
    
    if ~iscell(RT2.rt)
        RT.rt(l2dx) = RT2.rt;
        RT.laten(l2dx) = RT2.laten;
        RT.resp(l2dx) = RT2.resp;
        RT.est(l2dx) = RT2.est;
        
        if ifc, RT.correct(l2dx) = RT2.correct;end
        
        try
            RT.misslaten(ml2dx) = RT2.misslaten;
            RT.missest(ml2dx) = RT2.missest;
        catch
            RT.misslaten{ml2dx} = [];
        end
        
    else
        RT.rt{l1+1} = RT2.rt;
        RT.laten{l1+1} = RT2.laten;
        try
            RT.misslaten{l1+1} = RT2.misslaten;
        catch
            RT.misslaten{l1+1} = [];
        end
    end
    
else
    RT.rt{1} = RT1.rt;
    RT.laten{1} = RT1.laten;
    
    if ifc, RT.correct{1} = RT1.correct;end
    
    try
        RT.misslaten{1} = RT1.misslaten;
    catch
        RT.misslaten{1} = [];
    end
    
    if iscell(RT2.rt)
        RT.rt(2:2+l2) = RT2.rt;
        RT.laten(2:2+l2) = RT2.laten;
        try
            RT.misslaten(2:2+l2) = RT2.misslaten;
        catch
            RT.misslaten{2:2+l2} = [];
        end
        
    else
        RT.rt{2} = RT2.rt;
        RT.laten{2} = RT2.laten;
        if ifc, RT.correct{2} = RT2.correct;end
        try
            RT.misslaten(2) = RT2.misslaten;
        catch
            RT.misslaten{2} = [];
        end
    end
end

%%% OTHER
if isfield(RT1,'OTHER')
    %%% mas comprobaciones
    c1fo = sort(fields(RT1.OTHER));
    c2fo = sort(fields(RT2.OTHER));
    if size(c1fo,1)~=size(c2fo,1)
        error('structur RT.OTHER must have the same fields')
    else
        for i = 1:size(c1fo,1)
            if ~strcmp(c1fo{i},c2fo{i})
                error('structur RT.OTHER must have the same fields')
            end
        end
    end
    %%% UNION
    for fo = 1:size(c1fo,1)
        %if iscell(eval(['RT1.OTHER.' c1fo{fo}  ' ' ]));
        %
        %else
        %end
        eval(['RT.OTHER.' c1fo{fo}  '(l1dx) = RT1.OTHER.' c1fo{fo}  ';  '   ])   ;
        eval(['RT.OTHER.' c1fo{fo}  '(l2dx) = RT2.OTHER.' c1fo{fo}  ';  '   ])   ;
        %eval(['RT.OTHER.' c1fo{fo}  ' = cat(2, RT1.OTHER.' c1fo{fo}  ' , RT2.OTHER.' c2fo{fo}  ');  '   ])   ;
    end
    
    
    
end % OTHER
%%%


RT.nblock = max(RT1.nblock,RT2.nblock);
RT = rt_check(RT);
end