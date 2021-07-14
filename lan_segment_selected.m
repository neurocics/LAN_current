function LAN = lan_segment_selected(LAN,seg_time)
% <??LAN)<] toolbox
% v.0.2
%
% Segment a continuos recording of previous segemnted recording in
% selected araes.
%     seg_time = []  for segmented by exact time of each selected areas
%                [s] for s second windows in the selected areas,
%                    with overlaping
%
% Pablo Billeke

% 28.04.2020 fixed multiples trials segmentation 
% 17.01.2013

%getcfg(cfg,'seg_time',[]);
if nargin < 2
    seg_time = [];
end

ns = 0;

% al finalizar esta iteraci??n, todos los segmentos no rechazados se
% conservan separadamente en {segment}
for nt = 1:LAN.trials
    % FIXED!!!
    % % NOTA AL DESARROLLADOR : esto no est?? realmente funcionando para
    % % m??ltiples trials. Quiz?? sea mejor restringir su aplicaci??n a LANs de
    % % un solo trial.
    
    if ~LAN.accept(nt), continue, end,
    % nt  = 1
    sel = [ 0 LAN.selected{nt} ];
    sel = find(abs(diff(sel)));
    %   if (numel(sel)/2)>fix(numel(sel)/2) % OVERRIDED
    if rem(numel(sel),2)==1
        sel = [ sel LAN.pnts(nt) ];
    end
    
    %ptime = sel(1:2:numel(sel));
    ptime{nt} = sel(1:2:numel(sel));
    for s = 1:2:numel(sel);
        ns = ns +1;
        segment{ns} = LAN.data{nt}(:,sel(s):sel(s+1));
    end
    % ACLARACION: ns (numero de segmentos: {selected}) = numel(sel) / 2
end

ptime = cat(2,ptime{:});


if ns == 0
    return;
end

% segmentaci??n en tramos del mismo tama??o
if ~isempty(seg_time)
    np = ceil(seg_time * LAN.srate); %seg_time en puntos
    %rng = 0;
    % resegment in seg_time fragment
    nsegment = {};
    ptimefinal = [];
    for s = 1:ns
        if size(segment{s},2)>= np;
            [paso, pt] = resegment(segment{s},np, ptime(s));
            nsegment = { nsegment{:} , paso{:} };
            ptimefinal = [ptimefinal pt];
        end
    end
    
    segment = nsegment;
    clear nsegment;
else
    ptimefinal = ptime;
end


LAN.data = segment;
LAN = rmfield(LAN,'selected');
LAN = rmfield(LAN,'accept');
LAN = rmfield(LAN,'correct');
LAN = rmfield(LAN,'tag');
LAN = lan_check(LAN);
LAN.time(:,3) = ptimefinal;
end


function [nsegment, ptime] = resegment(segment,np, ptime)

baseptime = (1:np:length(segment)-np) - 1;
ptime = baseptime+ptime;
nsegment = cell(size(ptime));
for c = 1:length(ptime)
    ind = (1:np)+baseptime(c);
    nsegment{c} = segment(:,ind);
end

end

