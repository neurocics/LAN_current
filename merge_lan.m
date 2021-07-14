function LAN = merge_lan(LAN1,varargin)%LAN2,
% merge two LAN 
%   form:      LAN = merge_lan(LAN1,LAN2,LAN3,...)
%              LAN = merge_lan(LAN) 
%              LAN = merge_lan(cfg)  
%  cfg.lan1 = estructura lan o 'srt' con nombre de variable en workspace 
%     .lan2 = idem
%     .sort = vector del orden de epocas con 0= sin data, 1= del lan1  2=
%             del lan2, eg:
%             [0 1 1 2 1 1 1 2 2 2 2 ]
%
% V 1.1.6 
%
% Pablo Billeke

% 12.11.2015 add merge refrences 
% 14.08.2014 Add merge LAN.conditions
% 22.10.2014 fix merge powspctrm
% 06.07.2012 Add RT!
% 23.09.2011 fix .accept and and .group
% 26.07.2011 fix .tag structure
% 25.07.2011
% 04.05.2011 Agraagr posibilidad de cfg.
%            y sort
% 10.08.2010 Agregando uni?n de .freq
% 03.05.2010
% 26.11.2009

if nargin <2
   if iscell(LAN1)
       LAN = LAN1{1};
       for x = 2:length(LAN1)
           LAN = merge_lan_struct(LAN,LAN1{x},0,0);
       end
   elseif isstruct(LAN1) && ~isfield(LAN1,'data')
       cfg = LAN1;
       %
       if ischar(cfg.lan1)
          LAN1 = evalin('caller',cfg.lan1);
          LAN2 = evalin('caller',cfg.lan2);
       else
          LAN1 = cfg.lan1;
          LAN2 = cfg.lan2;           
       end
       %
       if isfield(cfg,'sort')
          ifsort = 1;
          indsort = cfg.sort;
       else
           ifsort = 0;
       end
       
       LAN = merge_lan_struct(LAN1,LAN2,ifsort,indsort);
       
   else
       error('must to be two LAN or cell LAN or cfg. structur')
   end
   
elseif nargin >=2
    for il = 1:length(varargin)
    if ~iscell(LAN1)
    LAN1 = merge_lan_struct(LAN1,varargin{il},0,0);
    else
        for lan = 1:length(LAN1)
        LAN1{lan} = merge_lan_struct(LAN1{lan},varargin{il}{lan},0,0);
        end
    end
    end
    LAN = LAN1;
end
%%%%%%
end

function LAN = merge_lan_struct(LAN1,LAN2,ifsort,indsort)


LAN1 = lan_check(LAN1);
LAN2 = lan_check(LAN2);
LAN = [];

% time

    if (isempty(LAN2.time) )&&( ~isempty(LAN1.time))
        disp('lack times argumente or LAN.time fields')
        LAN = LAN1;

    elseif isempty(LAN1.time) && ~isempty(LAN2.time)
        disp('lack times argumente or LAN.time fields')
        LAN = LAN2;

    elseif isempty(LAN1.time) && isempty(LAN2.time)
        disp('lack times argumente or LAN.time fields')
        LAN = LAN1;

    else
        disp('todo bien')
        
    end
    
%%% srate
if isempty(LAN1.srate)
    LAN1.srate = LAN2.srate;
elseif LAN1.srate ~= LAN2.srate
    error('sample rate must be same');
else
    LAN.srate = LAN1.srate;
end



%%% data
if iscell(LAN1.data)
    if ifsort
    LAN.data = cell(size(indsort));
    LAN.data(indsort==1) = LAN1.data;
    LAN.data(indsort==2) = LAN2.data;
        try
            LAN.accept = zeros(size(indsort));
            LAN.accept(indsort==1) = LAN1.accept;
            LAN.accept(indsort==2) = LAN2.accept;
        catch
        disp('without accept')   
        end
        
    else
    LAN.data = cat(2,LAN1.data,LAN2.data);
    %LAN.accept = cat(2,LAN1.accept,LAN2.accept);
    end
else
    LAN.data = cat(3,LAN1.data,LAN2.data);    
end


%%% time
last_time = [];
if ~isempty(LAN1.time) && ~isempty(LAN2.time) 
[epocas time] = size(LAN1.time);
LAN.time(:,1:2) = cat(1,LAN1.time(:,1:2),LAN2.time(:,1:2));
if time ==3  % for zeros
    last_time = (fix(LAN1.time(epocas,3) + LAN1.time(epocas,2)*LAN1.srate))+1;
    z_1 = LAN1.time(:,3);
    z_2 = LAN2.time(:,3) + last_time;
    LAN.time(:,3) = cat(1,z_1,z_2); clear z_1 z_2;
end
elseif ~isempty(LAN1.time) && isempty(LAN2.time)
   LAN.time = LAN1.time;
elseif isempty(LAN1.time) && ~isempty(LAN2.time)
    LAN.time = LAN2.time;
end

%%%% event
if isfield(LAN1,'event') && isfield(LAN2,'event')
    %type
    
    if isfield(LAN1.event,'type')
        for tt = 1:length(LAN1.event)
            type_1{tt} = LAN1.event(tt).type ;
        end
        for tt = 1:length(LAN2.event)
            type_2{tt} = LAN2.event(tt).type ;
        end
        type = cat(2,type_1,type_2); clear type_1 type_2;
        % = cat(2,)%cell2mat({LAN1.event.type});
        %type_2 = cell2mat({LAN2.event.type});
        
        for tt = 1:length(type)
            LAN.event(tt).type = type{tt};
        end
    end
    
    %latency
    if isfield(LAN1.event,'latency')
        %la_1 = cell2mat({LAN1.event.latency});
        la_1 = cat(2,LAN1.event(:).latency);
        la_2 = cat(2,LAN2.event(:).latency);%cell2mat({LAN2.event.latency});
        % latencia plana de LAN1
        if ~iscell(LAN1.data)
            if isfield(LAN1,'xmax')
                last_time_plan = fix(LAN1.xmax * LAN1.srate);
            else
                last_time_plan = length(LAN1.data) * LAN1.trials;
            end
        else
            if isfield(LAN1,'xmax')
                last_time_plan = fix(LAN1.xmax * LAN1.srate);
            else
                last_time_plan = 0;
                for tr = 1:length(LAN1.data)
                    last_time_plan = last_time_plan + length(LAN1.data{tr});
                end
            end
        end
        la_2 = la_2 + last_time_plan;
        la = cat(2,la_1,la_2); clear type_1 type_2;
        for ll = 1:length(type)
            LAN.event(ll).latency = la(ll);
        end
        
    end
    
    
    % lantecy_aux
    if isfield(LAN1.event,'latency_aux')
        la_1 = cell2mat({LAN1.event.latency_aux});
        if isfield(LAN2.event,'latency_aux')
            la_2 = cell2mat({LAN2.event.latency_aux});
            la_2 = la_2 + last_time;
        end
        la = cat(2,la_1,la_2); clear type_1 type_2;
        for ll = 1:length(type)
            LAN.event(ll).latency_aux = la(ll);
        end
    end
    
    %event.duration
    %duration
    if isfield(LAN1.event,'duration') && isfield(LAN2.event,'duration')
        du_1 = cell2mat({LAN1.event.duration});
        du_2 = cell2mat({LAN2.event.duration});
        du = cat(2,du_1,du_2); clear du_1 du_2;
        for dd = 1:length(du)
            LAN.event(dd).duration = du(dd);
        end
    end
    %%%
end % event


%condici??n
%%% LAN.cond
if size(LAN1.cond) == size(LAN2.cond)
    if LAN1.cond == LAN2.cond
        LAN.cond = LAN1.cond;
    end
else
LAN.cond = [ LAN1.cond ':' num2str(LAN1.trials) ' + ' LAN2.cond ':' num2str(LAN2.trials)   ];
end

%%% LAN.conditions
if isfield(LAN1,'conditions') && isfield(LAN2,'conditions')
    LAN.conditions.name = LAN1.conditions.name;
    for c=1:length(LAN1.conditions.ind)
    LAN.conditions.ind{c} = [LAN1.conditions.ind{c} LAN2.conditions.ind{c}];
    end
end


%%% LAN.name
if ~isempty(LAN1.name) && ~isempty(LAN2.name)    
    if strcmp(LAN1.name,LAN2.name)
        LAN.name = LAN1.name;
    else
        LAN.name = [LAN1.name ' + ' LAN2.name];
    end
else
    LAN.name = [' ']   ;
end


%%% LAN.GROUP
if ~isempty(LAN1.group) && ~isempty(LAN2.group)    
    if strcmp(LAN1.group,LAN2.group)
        LAN.group = LAN1.group;
    else
        LAN.group = [LAN1.group ' + ' LAN2.group];
    end
else
    LAN.group = [' ']   ;
end



%%% accepted
if isfield(LAN1,'accept') && isfield(LAN2,'accept') && ifsort==0
LAN.accept = cat(2,LAN1.accept,LAN2.accept);

end
%%%%%%%%%%%%%
%%% xmax
LAN.xmax =LAN1.xmax + LAN2.xmax;

%%%%%%%%%%
% chanlocs
try
try 
    LAN.chanlocs = LAN1.chanlocs;
catch
    LAN.chanlocs = LAN2.chanlocs ;   
end
end

%%%%%%%%
% freq
if isfield(LAN1,'freq')  &&  isfield(LAN2,'freq') 
    
 if isfield(LAN1.freq,'freq')  %&&  isfield(LAN2,freq,'freq') 
     LAN.freq.freq = LAN1.freq.freq;
 end 
 %
 if isfield(LAN1.freq,'time')  %&&  isfield(LAN2,freq,'freq') 
     LAN.freq.time = LAN1.freq.time;
 end    
 %
  if isfield(LAN1.freq,'powspctrm')  %&&  isfield(LAN2,freq,'freq') 
      if iscell(LAN1.freq.powspctrm)
        LAN.freq.powspctrm = cat(2,LAN1.freq.powspctrm,LAN2.freq.powspctrm)  ;
      else
        LAN.freq.powspctrm = ( LAN1.freq.powspctrm .*( LAN1.trials/(LAN1.trials+LAN2.trials) )) + ( LAN2.freq.powspctrm.*( LAN2.trials/(LAN1.trials+LAN2.trials) )) ;
      end
  end
   if isfield(LAN1.freq,'fourierspctrm')  %&&  isfield(LAN2,freq,'freq') 
     LAN.freq.fourierspctrm = ( LAN1.freq.fourierspctrm .*( LAN1.trials/(LAN1.trials+LAN2.trials) )) + ( LAN2.freq.fouriersptrm.*( LAN2.trials/(LAN1.trials+LAN2.trials) )) ;
  end
  
 %
  if isfield(LAN1.freq,'cfg')  %&&  isfield(LAN2,freq,'freq') 
     LAN.freq.cfg = LAN1.freq.cfg;
  end
end   
 
%%%% TAG
if isfield(LAN1,'tag')    
LAN.tag.mat = cat(2,LAN1.tag.mat,LAN2.tag.mat);
LAN.tag.labels = LAN1.tag.labels;
end

%%%%%% solo de flojo
if ifsort
    LAN = rmfield(LAN,'time');
end
    
%%% RT
if isfield(LAN1,'RT')   
   LAN.RT = rt_merge(LAN1.RT,LAN2.RT,ifsort);
end

%%%% unselected
if isfield(LAN1,'selected')
    if ifsort
    LAN.selected = cell(size(indsort));
    LAN.selected(indsort==1) = LAN1.selected;
    LAN.selected(indsort==2) = LAN2.selected;
    else
        LAN.selected = cat(2,LAN1.selected, LAN2.selected);
    end
end

%%%% references
if isfield(LAN1,'references')
   if any(LAN1.references(:)~=LAN1.references(:))
       warning('References is not consisntent!!!')
   else
       LAN.references = LAN1.references;
   end
end

  LAN = lan_check(LAN);  
end





