function [LAN] = eeglab2lan(EEG,nonQ)
% transform EEGLAB format to LAN
% 
% v.0.0.7
% 
% 17.10.2012
% 16.4.2010
% 20.4.2010
% 
% 24.4.2010
%    
% Pablo Billeke

if nargin <2
    nonQ=0;
end



if iscell(EEG)
    for lan = 1:length(EEG)
    LAN{lan} = eeglab2lan_str(EEG{lan},nonQ)
    end
elseif length(EEG) > 1
    for lan = 1:length(EEG)
    LAN{lan} = eeglab2lan_str(EEG(lan),nonQ)
    end
else
    LAN = eeglab2lan_str(EEG,nonQ)
end

end


function [LAN] = eeglab2lan_str(EEG,nonQ)
LAN = [];
LAN.srate = EEG.srate;
LAN.data = EEG.data;


    
% LAN.time = input('Tiempo inicial y final  (e.g [-500 1000]) / 0=auto : ');
% if LAN.time == 0;
%    LAN.time = [];
%    LAN.time(1) = 0;
%    LAN.time(2) = length(LAN.data) / LAN.srate;
% end
if ~isfield(LAN,'time')
   try
       LAN.time(1) = EEG.xmin;
       LAN.time(2) = EEG.xmax;
   end
    
end


if isfield(EEG,'cond')
    LAN.cond = EEG.cond;
elseif nonQ == 1
    LAN.cond = ' ';
else
    LAN.cond = input('Condition (e.g. [''OpenEye'']) = ');
end

if isfield(EEG,'name')
    LAN.name = EEG.name;
elseif nonQ == 1
    LAN.name = ' ';
else
    LAN.name = input('Subject''s name (e.g. [''Pedro'']) = ');
end


if isfield(EEG,'group')
   LAN.group = EEG.group;
elseif nonQ == 1
   LAN.group = ' ';
else
LAN.group = input('Group''s subject (e.g. [''Control'']) = ');
end





LAN.event = EEG.event;
LAN.trials = EEG.trials;
try
   LAN.accept = EEG.accept; 
end


if size(EEG.data,3)>1
    LAN = mat2cell_lan(LAN);
elseif size(EEG.data,3)==1

%%%% ---- Divide como epocas segmentos cortados en EEGLAB
%%%% ---- maracados con event.type = 'boundary'
%%%%

ne = length(EEG.event);
current_p = 1;
fixl = 0;
cont = 1;
boundary = 0;
for p = 1:ne;
    if strcmp(EEG.event(p).type, 'boundary');
        fixlatency = EEG.event(p).latency ;
        last_p = floor(fixlatency);
        % evitar primera epoca vacia si se inicia con evento boundary el
        % data
        if fixlatency > 1 
        data{cont} = EEG.data(:,current_p:last_p);
        cont = cont +1;
        end
        
        current_p = last_p +1;
        boundary = 1;

    end
end

if boundary ==1
  disp('LAN: se cortaron epocas segun eventos ''boundary'' ')  ; 
  data{cont} = EEG.data(:,current_p:(length(EEG.data)));
  LAN.data = data;
end

end
%%%% -----
%%%% -----
%%%% -----

% chanclos
if isfield(EEG,'chanlocs')
    LAN.chanlocs = EEG.chanlocs;
end



LAN = lan_check(LAN);
if ~isempty(EEG.event)
LAN.RT = event2RT(EEG.event,LAN.srate,LAN.time);
end

if isfield(EEG,'reject')
    if isstruct(EEG.reject)
    LAN.accept = true(size(LAN.data));
    if ~isempty(EEG.reject.rejjp)
        LAN.accept(logical(EEG.reject.rejjp))=false;
    end
    if ~isempty(EEG.reject.rejkurt)
        LAN.accept(logical(EEG.reject.rejkurt))=false;
    end    
    if ~isempty(EEG.reject.rejmanual)
        LAN.accept(logical(EEG.reject.rejmanual))=false;
    end
    if isfield(EEG.reject, 'rejthresh') &  isempty(EEG.reject.rejthresh)
        LAN.accept(logical(EEG.reject.rejthresh))=false;
    end    
    if isfield(EEG.reject, 'rejconst') & ~isempty(EEG.reject.rejconst)
        LAN.accept(logical(EEG.reject.rejconst))=false;
    end    
    if isfield(EEG.reject, 'rejfreq') & ~isempty(EEG.reject.rejfreq)
        LAN.accept(logical(EEG.reject.rejfreq))=false;
    end      
    end
end

end





