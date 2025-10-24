function LAN = lan_segment_selected(LAN,seg_time,overlap)
% <??LAN)<] toolbox
% v.0.4
%
% Segment a continuos recording of previous segemnted recording in
% selected araes.
%     seg_time = []  for segmented by exact time of each selected areas
%                [s] for s second windows in the selected areas,
%     overlap =  [s] overlaping with segment 
%
% Pablo Billeke

% 22.10.2025  addind RT for segmentations
% 20.03.2022 add overlaping 
% 28.04.2020 fixed multiples trials segmentation 
% 17.01.2013

%getcfg(cfg,'seg_time',[]);
if nargin < 2
    seg_time = [];
end
if nargin < 3    
    overlap = 0 ;
end

ns = 0;

% al finalizar esta iteraci??n, todos los segmentos no rechazados se
% conservan separadamente en {segment}
if isfield(LAN, "RT") && length(LAN.RT.est)==length(LAN.data)
    save_rt=true;
else
    save_rt=false;
end




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
        
        est(ns) = LAN.RT.est(nt);
        rt(ns) = LAN.RT.rt(nt);
        resp(ns) = LAN.RT.resp(nt);
        OTHER.seg_org(ns)=ns;
        OTHER.n_subseg(ns)=s;
        laten(ns)= (sel(s)*(1/LAN.srate)*1000 + LAN.RT.laten(nt));


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
    op = ceil(overlap * LAN.srate);
    %rng = 0;
    % resegment in seg_time fragment
    nsegment = {};
    ptimefinal = [];
    est_all=[];
    laten_all=[];
    rt_all=[];
    resp_all=[];
    OTHER.seg_org_all = [];
    OTHER.subseg_org_all = [];
    OTHER.subsubseg_org_all = [];
    for s = 1:ns
        if size(segment{s},2)>= np;
            [paso, pt] = resegment(segment{s},np, ptime(s),op);
            nsegment = [ nsegment(:)' , paso(:)' ];
            est_all = [est_all(:)' , repmat(est(s), [ 1 , length(paso)]) ];
            %est_all = [est_all(:)' , repmat(est(s), [ 1 , length(paso)]) ];
            times_ms = ((pt-np)/LAN.srate)*1000 + laten(ns) ; 
            laten_all = [laten_all(:)' , times_ms(:)' ];
            OTHER.seg_org_all = [OTHER.seg_org_all(:)' ,  repmat(OTHER.seg_org(ns), [ 1 , length(paso)]) ] ;
            OTHER.subseg_org_all = [OTHER.subseg_org_all(:)' ,  repmat(OTHER.n_subseg(ns), [ 1 , length(paso)]) ] ; % OTHER.n_subseg(ns);
            OTHER.subsubseg_org_all = [OTHER.subsubseg_org_all(:)' , 1:length(paso)];
            rt_all = [rt_all(:)' ,  repmat(rt(ns), [ 1 , length(paso)]) ] ;
            resp_all = [resp_all(:)' ,  repmat(resp(ns), [ 1 , length(paso)]) ] ;
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

LAN.RT.est =est_all;
LAN.RT.rt =rt_all;
LAN.RT.resp =resp_all;
LAN.RT.OTHER = OTHER;
LAN.RT.laten=laten_all;
LAN.RT.latency=laten_all;
LAN.RT =rt_check(LAN.RT);




LAN = lan_check(LAN);
LAN.time(:,3) = ptimefinal;
end


function [nsegment, ptime] = resegment(segment,np, ptime,op)

baseptime = (1:(np-op):length(segment)-np) - 1;
ptime = baseptime+ptime;
nsegment = cell(size(ptime));
for c = 1:length(ptime)
    ind = (1:np)+baseptime(c);
    nsegment{c} = segment(:,ind);
end

end

