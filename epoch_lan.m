%%%     epoch_lan.m
%%% v.1.0.1 (migrating to lan_epoch)
%%%	V.1 (for epochs.m v2.)
%%%
%%% 04.04.2012
%%%	14.04.2009  %%% en proceso
%%%	Pablo Billeke
%%%
%%%    create epochs for continuos data (2D matrix)
%%%    for EEGLAB, condition is 1, the output is a 3D matrix. default
%%%    for LAN, condition is 2, the output is a cells.
%%%    LAN = epoch_lan(LAN, condition)
%%%    times in LAN.time  in matrix (s,s,point)
%%%		%  [trials x initial time , final time, points "0" ]
%%%	    % points "0" in references to continius data
%%%
%%%
%%%    condition
%%%         1 == 3d matrix
%%%         2 == {[2cd matrix]} x trials


function LAN = epoch_lan(LAN, condition)

if nargin == 1; condition = 2; end
warning('you must migrate to lan_epoch')

LAN = lan_epoch(LAN, condition);

end
% if isstruct(LAN)
%     LAN = epoch_lan_struct(LAN, condition);
% elseif iscell(LAN)
%     for lan = 1:length(LAN)
%     LAN{lan} =  epoch_lan_struct(LAN{lan}, condition);
%     end
% end
% end
% 
% 
% function LAN = epoch_lan_struct(LAN, condition)
% 
% 
% 
% %if nargin ==1 ;
%     if isempty(LAN.time)
%         disp('lack times argumente or LAN.time fields')
%         LAN.data = [];
%         try LAN = rmfield(LAN,'trials');end
%         LAN = lan_check(LAN);
%         %LAN.event =[];
%     elseif size(LAN.time,1) == 1
%         if LAN.time == [0 0 0]
%         disp('LAN.time = [0,0,0]')
%         LAN.data = [];
%         try LAN = rmfield(LAN,'trials');end
%         LAN = lan_check(LAN);
%         %LAN.event =[];
%         end
%     else
%     
%      %if ~iscell(LAN.data)
%       [fil col] = size(LAN.time);
% 
% 
%    
%     %else
% %     if fil > 1
% %         condition = 2;
% %     else
% %         condition = 1;
% %     end
%     %end
%     
%     
% %end
% times = LAN.time;
% 
% [fil col ] = size(times);
% 
% if iscell(times)
%     error('LAN.time must be matrix [trials x initial time , final time, points "0" ]')
% 
% else
%     zero = fix(times(:,3)');
%     inicio = times(:,1)' .*LAN.srate;
%     inicio = fix(inicio) + zero ;
%     final = times(:,2)' .*LAN.srate;
%     final = fix(final) + zero;
%    
%    
%     
% end
% 
% 
% if size(inicio) ~= size(final)
%   error('Matrix INICIO and FINAL must be same size')
% end
% 
% 
% 
% %%%%% for data matrix
% 
% if ~iscell(LAN.data)
%         %%% for EEGLAB struct
%     xx = length(inicio);
%     [electr largo] = size(LAN.data) ;
% 
%     if condition==1
%       EEGout=[];
%       for i = 1:xx
%           EEGout(:,:,i) = LAN.data(:,(inicio(i):final(i)));
%           %for ii = 1:electr
%           %EEGout(ii,:,i) = EEGin.data(ii,(inicio(i):final(i)));
%           %end
%       end
%       LAN.data = [];
%       LAN.data = EEGout;
%     end
% 
%         %%% for LAN struct
%     if condition==2
%       EEGout=[];
%       for i = 1:xx
%           EEGout{i}(:,:) = LAN.data(:,(inicio(i):final(i)));
%       end
%       LAN.data = [];
%       LAN.data = EEGout;
%     end
% 
% 
%     if ~isempty(zero)
%         for i = 1:length(zero)
%         LAN.time(i,1) = (inicio(i) - zero(i))/LAN.srate;
%         LAN.time(i,2) = (final(i) - zero(i))/LAN.srate;
%         LAN.time(i,3) = zero(i);
%         end
%         end
% 
% try
%     LAN = arreglaeventos(LAN,inicio,final);
% catch
%     warning('evento no se pudieron arreglar');
% end
%     LAN = rmfield(LAN,'trials');
% 
%     LAN = lan_check(LAN);
% 
% %%%%% for data cell    
% else   
%    
%     %% para time 
%     if length(LAN.data) == size(LAN.time,1);
% 
%         inicio_c    = zero(1) - inicio(1);
%         final_c     = final(1) - zero(1);
%   
%           if condition == 1
%                       EEGout =[];
%                   for tr = 1:length(LAN.data)
%                       EEGout(:,:,tr) = LAN.data{tr}(:,inicio:final);
%                   end
%                   elseif condition ==2
%                    EEGout =[];   
%                   for tr = 1:length(LAN.data)
%                       EEGout{tr}(:,:) = LAN.data{tr}(:,inicio:final);
%                   end    
%           end
%           LAN.data =[];
%           LAN.data = EEGout; clear EEGout;
% 
% 
%           LAN = arreglaeventos(LAN,inicio,final);
%   
%           if isfield(LAN,'trials')
%             LAN = rmfield(LAN,'trials');
%           end
%             LAN = lan_check(LAN);
%   
%   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     elseif length(LAN.data) == 1
%         
%           xx = length(inicio);
%          [electr largo] = size(LAN.data{1}) ;
% 
%         if condition==1
%                   EEGout=[];
%                   for i = 1:xx
%                       EEGout(:,:,i) = LAN.data{1}(:,(inicio(i):final(i)));
%                       %for ii = 1:electr
%                       %EEGout(ii,:,i) = EEGin.data(ii,(inicio(i):final(i)));
%                       %end
%                   end
%                   LAN.data = [];
%                   LAN.data = EEGout;
%         end
% 
%     %%% for LAN struct
%         if condition==2
%               EEGout=[];
%               for i = 1:xx
%                   EEGout{i} = LAN.data{1}(:,(inicio(i):final(i)));
%               end
%               LAN.data = [];
%               LAN.data = EEGout;
%             end
% 
% 
%         if ~isempty(zero)
%             for i = 1:length(zero)
%             LAN.time(i,1) = (inicio(i) - zero(i))/LAN.srate;
%             LAN.time(i,2) = (final(i) - zero(i))/LAN.srate;
%             LAN.time(i,3) = zero(i);
%             end
%         end
% 
%         LAN = arreglaeventos(LAN,inicio,final);
% 
%         LAN = rmfield(LAN,'trials');
%         LAN = rmfield(LAN,'accept');
%         LAN = rmfield(LAN,'correct');
%         LAN = rmfield(LAN,'tag');
%         LAN = lan_check(LAN);
% 
% 
%     
%     
%     end
% end
%     end
% end
% 
% 
% %-------------------------------------------------
% 
% 
% function LAN = arreglaeventos(LAN,inicio,final)
% 
% currcode = cell2mat({LAN.event.type});
% 
% if isfield(LAN.event,'latency_aux')
%     currlate = cell2mat({LAN.event.latency_aux});
% else
%     currlate = cell2mat({LAN.event.latency});
% end
% 
% 
% if isfield(LAN.event, 'duration' )
%     currdura = cell2mat({LAN.event.duration});
% else currdura = ones(1,length(currcode));
% end
% 
% count = 0;
% 
% for ii = 1:length(inicio)
%     if   ii == 1
%               tiempo = 1;
%             else 
%                tiempo = tiempo + (final(ii-1) - inicio(ii-1)) +1;
%     end
%   
%    
%     length(currlate)
%     for i = 1:length(currlate)
%        
%         if currlate(i) >= inicio(ii) &  currlate(i) <= final(ii)
%            count = count + 1;
%            currlate_c(count) = currlate(i);
%            currcode_c(count) = currcode(i);
%            currdura_c(count) = currdura(i);
%            
%            latenciaplana(count) = tiempo + (currlate(i) - inicio(ii));
%         end
%     end
% end
% 
% 
% 
% levent = length(currcode_c);
% LAN.event = [];
% 
% for i=1:levent
%    LAN.event(i).type    = currcode_c(i);
%    LAN.event(i).latency_aux = currlate_c(i);
%    LAN.event(i).duration = currdura_c(i);
%    LAN.event(i).latency = latenciaplana(i);
% end
% 
% end


