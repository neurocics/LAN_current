function [LAN] = lan_check(LAN,op,place)
%               v.1.1.9
%             <*LAN)<|   
%
% if op= 1 delete incorrected and no-accepted trials
% if op is a string that can contain
%   ~V  : no muestran ningun aviso (default: V muestra los avisos)
%   ~D  : no borra incorrecto ni no aceptados (default)
%    D  : borra incorrectos y no aceptados
%    A  : solo ensayos aceptado
%    C  : clean deleted field  and row data (~C default)
%    
%
% Pablo Billeke

% 25.07.2018     fix bag with tag
% 07.01.2015     fix empty end row in electrodemat matrix
% 04.06.2014     revisar compatimbilidad para la tercera columna del .time
% 02.04.2014     check single for row_data in iEEG recording, and add C
%                clean option 
% 19.12.2012     add check channel labes (delete spaces), and selected
% field
% 06.11.2012     fix chanlocs structure when there are not position speciphication 
% 25.09.2012     fix tag
% 13.09.2012     fix time when the number of electrodes/sensors/sources is
%                              grater than that of time bins. Transforms data to "single" 
% 26.06.2012     fix bug with deleted not accept trials
% 22.06.2012      tring fix tag and accept options!!!!
% 01.04.2012      improve memory
% 7.03.2012       add version info
% 10.01.2012      add gruop
% 27.11.2011      add op for options
% 25.11.2011      fix empty LAN
% 16.09.2011      fix empty LAN
% 12.07.2011      add delr
% 18.01.2011      fix time
% 17.01.2011      add pnts comprobation
% 05.08.2010      fix time
% 19.04.2010
% 04.02.2010
% ...
if (nargin == 1)||(ischar(op)&&(strcmp(op,'no')))
   ifv = 1;
   delr = 0;
   op='no';
   clean=0;
else
   if ischar(op)
       %%%
       if ~isempty(strfind(op,'~V'))
           ifv = 0;
       else
           ifv = 1;
       end
       %%%
       if ~isempty(strfind(op,'~D'))
           delr = 0;
       elseif ~isempty(strfind(op,'D'))
           delr = 1;
       else
           delr = 0; 
       end
       %%%
       if ~isempty(strfind(op,'~C'))
           clean = 0;
       elseif ~isempty(strfind(op,'C'))
           clean = 1;
       else
           clean = 0; 
       end
       %%%
   else
       delr = op;
       ifv = 1;
       clean=0;
   end
end



if iscell(LAN)
    for lan = 1:length(LAN)
        if ~isempty(LAN{lan})
       
            LAN{lan} = lan_check(LAN{lan},op,lan);
            
   
        end
    end   
elseif isstruct(LAN) || isempty(LAN)
if nargin < 3
    place=1;
end
if isempty(LAN)
    LAN = create_lan;
end

%LAN = LAN; %%%% revisar
if ~iscell(LAN.data)
    LAN = mat2cell_lan(LAN);
else
    for t = 1:length(LAN.data)
        LAN.data{t} = single(LAN.data{t});
    end
end


%%% accept
if isfield(LAN,'accept') 
    old_accept =LAN.accept; 
    LAN.accept = get_accept(LAN);
    if delr    
    LAN.data(logical(~LAN.accept)) = {[]};
    if ifv,    disp('delete rejected epoch'), end
    end
elseif ~isfield(LAN,'accept') && iscell(LAN.data)
    LAN.accept = true(1,length(LAN.data));
elseif ~isfield(LAN,'accept') && isnumeric(LAN.data)
    LAN.accept = true(1,size(LAN.data,3));   
end
emptyT = ifcellis(LAN.data,'isempty(@)');
LAN.accept(logical(emptyT)) = false; 

%%% correct
if isfield(LAN,'correct') && delr
   try
    LAN.data = LAN.data(logical(LAN.correct));
     if ifv,    disp('delete incorrect epoch'); end
   end
elseif ~isfield(LAN,'correct') && iscell(LAN.data)
    LAN.correct = true(1,length(LAN.data));
elseif ~isfield(LAN,'correct') && isnumeric(LAN.data)
    LAN.correct = true(1,size(LAN.data,3));   
end


%%% eventos
LAN.srate = LAN.srate;
LAN.data = LAN.data;
if isfield(LAN,'event')
LAN.event = LAN.event;
% else
%    if ifv,  display('No hay eventos'); end,
end


%%% TIME
%%%

%if %isfield(LAN,'time')
   %LAN.time = LAN.time;
%elseif 

if iscell(LAN.data)  && isfield(LAN,'time')
   if (length(LAN.data) ~= size(LAN.time,1)) && size(LAN.time,1)>1
       LAN = rmfield(LAN,'time');
       %LAN = rmfield(LAN,'time');
       if ifv, disp('bad asigned line of time'); end;
   elseif (length(LAN.data) ~= size(LAN.time,1)) && size(LAN.time,1)==1
       
       LAN.time = repmat(LAN.time,[length(LAN.data),1]);
       
       LAN.time = LAN.time; %rmfield(LAN,'time');
       
   end
end

if isempty(LAN.data)
    LAN.time = [];
elseif ~iscell(LAN.data) && ~isfield(LAN,'time')   
   LAN.time(1) = 0;
   LAN.time(2) = size(LAN.data,2) ./ LAN.srate;
   LAN.time(3) = 1;

elseif iscell(LAN.data)  && ~isfield(LAN,'time')
    b = size(LAN.data,2); 
    for i = 1:b
        LAN.time(i,1) = 0;
        LAN.time(i,2) = size(LAN.data{i},2) / LAN.srate;
        if i ==1
            LAN.time(i,3) = 1;
        elseif i > 1
        LAN.time(i,3) = LAN.time(i-1,3) + size(LAN.data{1,i-1},2);
        end
    end
elseif iscell(LAN.data)  && isfield(LAN,'time')
    nt = size(LAN.data,2);
    nc = size(LAN.time,2);
    if ~isempty(LAN.data{find(LAN.accept==1,1)})
        if size(LAN.time,1) == 1
           for ic = 1:nt
               % LAN.time(i,1) = 0;
               if ic >1
                   LAN.time(ic,1) = LAN.time(1,1);
               end
                LAN.time(ic,2) = (size(LAN.data{1,ic},2) / LAN.srate ) + LAN.time(1,1);
                if ic ==1
                    LAN.time(1,3) = 1 - (LAN.time(1,1) * LAN.srate );
                elseif ic > 1
                LAN.time(ic,3) = LAN.time(ic-1,3) + size(LAN.data{1,ic-1},2);
                end
            end 
         
        else
            for i = 1:nt
               % LAN.time(i,1) = 0;
                LAN.time(i,2) = (size(LAN.data{1,i},2) / LAN.srate ) + LAN.time(i,1);
                
% %% Comentado para dejar la tercera columana del punto de extracion desde el continuo
% %% Solo se activa si noe xite la tercera columna        
                if nc==2
                 if i ==1
                     LAN.time(i,3) = 1 - (LAN.time(i,1) * LAN.srate );
                 elseif i > 1
                     LAN.time(i,3) = LAN.time(i-1,3) + size(LAN.data{1,i-1},2);
                 end
                end
            end 
        end
    end
    
end



%%%% CONDITION
%%%%

if isfield(LAN,'cond')
   LAN.cond = LAN.cond;
else
    LAN.cond = ['cond ' num2str(place) ];
end

if isfield(LAN,'name')
   LAN.name = LAN.name;
else
    LAN.name = [ ' ' ];
end

if isfield(LAN,'group')
   LAN.group = LAN.group;
else
    LAN.group = ['G' ];
end


%%% TRIALS
%%%

if isfield(LAN,'trials')
   LAN.trials = LAN.trials;
   if iscell(LAN.data)
       [a b] = size(LAN.data);
       if b ~= LAN.trials
       LAN.trials = b;
       if ifv , disp('fixed number of trials'); end,
       end
   elseif ~iscell(LAN.data) 
    [a b c] = size(LAN.data);
    LAN.trials = c;
       if c ~= LAN.trials
       LAN.trials = c;
       if ifv , disp('fixed number of trials');end
       end
   end
   
elseif iscell(LAN.data)
    [a b] = size(LAN.data);
    LAN.trials = b;
    
elseif ~iscell(LAN.data) 
    [a b c] = size(LAN.data);
    LAN.trials = c;
end
%%%%
 if (size(LAN.time,1) == 1)&&(LAN.trials>1)
        for i = 1:LAN.trials
            w(i,:) = LAN.time;
        end
        LAN.time = w; 
        clear w i 
end





%%%% LAN.nbchan
%%%%

    if iscell(LAN.data)
        nbchan = size(LAN.data{find(LAN.accept==1,1)},1);
    else
        nbchan = size(LAN.data,1);
    end

if isfield(LAN,'nbchan')
   if nbchan == LAN.nbchan;
   LAN.nbchan = LAN.nbchan;
   else
   LAN.nbchan = nbchan;
   if ifv , disp(['se areglo el numero de electrodos activos a ' num2str(nbchan) ]);end
   end
else
   LAN.nbchan = nbchan; 
end


%%%% LAN.xmax

 if ~iscell(LAN.data)
%             if isfield(LAN,'xmax') & LAN.trials > 1
%             LAN.xmax = LAN.xmax;
            %else
                if LAN.trials > 1
                LAN.xmax = (size(LAN.data,2) * LAN.trials)/LAN.srate;
                else
                LAN.xmax_c = size(LAN.data,2)/LAN.srate * LAN.trials;
                LAN.xmax = LAN.xmax_c;
                end
            %end
        else
%             if isfield(LAN,'xmax') & LAN.trials > 1
%             LAN.xmax = LAN.xmax;
%             else
                last_time_plan = 0;
                for tr = 1:length(LAN.data)
                    last_time_plan = last_time_plan + size(LAN.data{tr},2);
                end
                LAN.xmax = last_time_plan/LAN.srate;
            %end
  end

            
%%%% pnts
if ~iscell(LAN.data)
    LAN.pnts = size(LAN.data,2);
else
    for t = 1:length(LAN.data)
    LAN.pnts(t) = size(LAN.data{t},2);
    end
    %L = max(t);                              
    % in case of variable durations, take into account the longest one       
end
%%%


%%%% LAN.unit
if ~isfield(LAN,'unit')
  LAN.unit ='uV'; 
end













%%%%------------------------------------
%---- Extras necesarios para ciertas funciones---
%%%%------------------------------------


if isfield(LAN, 'RT')
    LAN.RT = rt_check(LAN.RT);
end




%%%% chanlocs
if isfield(LAN, 'chanlocs')
    if length(LAN.chanlocs)==LAN.nbchan
      if ~isfield(LAN.chanlocs(1),'type')  
          for i = 1:LAN.nbchan;
          LAN.chanlocs(i).type = 'unkwon';
          end
      end
      
      % delete space in the channel name
      for i = 1:LAN.nbchan;
      LAN.chanlocs(i).labels(double(LAN.chanlocs(i).labels)<=32) = '';    
      end
      
      % check electrode_mat
      if isfield(LAN.chanlocs(1),'electrodemat')
         aux = sum(LAN.chanlocs(1).electrodemat,1);
         LAN.chanlocs(1).electrodemat = LAN.chanlocs(1).electrodemat(:,aux~=0);
      end
      
    end
else
    for i = 1:LAN.nbchan;
          LAN.chanlocs(i).labels = ['E' num2str(i)];
          LAN.chanlocs(i).type = 'unkwon';
          LAN.chanlocs(i).Y = [ ];
          LAN.chanlocs(i).X = [ ];
          LAN.chanlocs(i).Z = [ ]; 
     end 
end
%%%% tag
if ~isfield(LAN, 'tag')
      LAN.tag.mat = zeros(LAN.nbchan,LAN.trials);
      LAN.tag.labels = [];
else %
    
    if size(LAN.tag.mat,1) ~= LAN.nbchan
       warning('LAN: bad asigned tag matrix, Set all to zeros !!') 
       LAN.tag.mat = zeros(LAN.nbchan,LAN.trials);
       LAN.tag.labels = [];
    elseif (sum(LAN.accept)==length(LAN.data))
        if length(LAN.accept)==length(LAN.tag.mat)
            LAN.tag.mat(:,~LAN.accept) = [];
        else
            LAN.tag.mat(:,~old_accept) = [];
        end
    end
end


%%% info
%if ~isfield(LAN, 'infolan')
       try
      LAN.infolan.version = lanversion;
       end
      LAN.infolan.date=date;
      if ~isfield(LAN.infolan, 'creation_date')
      LAN.infolan.creation_date=date;    
      end
%end

%%% Selected recording
if ~isfield(LAN, 'selected')
    for t = 1:LAN.trials
    LAN.selected{t} = true(1,LAN.pnts(t));
    end
else
    if length(LAN.selected)~= length(LAN.data)
        LAN.selected = cell(size(LAN.data));
    end
    for t = 1:LAN.trials
        if size( LAN.selected{t},2)~=size( LAN.data{t},2)
           LAN.selected{t} = true(1,size( LAN.data{t},2));
        end
    end   
end

%%% row recording using in iEEG
if  isfield(LAN, 'row_data')
%   for t = 1:LAN.trials % OVERRIDED: as?? permito que coexistan se??ales
%       segmentadas y row_data intacto
    for t = 1:numel(LAN.row_data)
        LAN.row_data{t} = single(LAN.row_data{t});
    end  

end 

%%% clean deleted data iEEG
if  isfield(LAN, 'delete') && clean
    LAN = rmfield(LAN,'delete'); 
end 

%%% remove empty fields
if  isfield(LAN, 'freq') && isempty(LAN.freq)
    LAN = rmfield(LAN,'freq'); 
end

%%% clean row data iEEG
if  isfield(LAN, 'row_data') && clean
    LAN = rmfield(LAN,'row_data'); 
end 


%% LAN.condicitons
if  isfield(LAN, 'conditions');
    if isfield(LAN.conditions,'names') && ~isfield(LAN.conditions,'name') % fix old protocools
       LAN.conditions.name = LAN.conditions.names;
       LAN.conditions = rmfield(LAN.conditions,'names');
    end
    for c = 1:length(LAN.conditions.name)
    if ~islogical(LAN.conditions.ind{c}) & any(LAN.conditions.ind{c}>1)
       paso = false(1,length(LAN.data));
       paso(LAN.conditions.ind{c}) = true;
       LAN.conditions.ind{c} = logical(paso);
       
    end
    end
end 



else
    error('no LAN format')
end

end


