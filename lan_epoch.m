function LAN = lan_epoch(LAN, cfg)
% v.0.5
%

% 13.08.2014 fix Bug in the segmegtation of contiuos data for new zero
%           format
% 06.08.2014 fix new time thridt columns and tf segmentations
% 01.04.2014
% 07.01.2013
if nargin == 1, cfg= []; end
condition = getcfg(cfg,'condition',2);
tf = getcfg(cfg,'freq',false);
times = getcfg(cfg,'times');
getcfg(cfg,'deltem',true);


%    LAN = epoch_lan_struct(LAN, condition);
if iscell(LAN)
    for lan = 1:length(LAN)
    LAN{lan} =  lan_epoch(LAN{lan}, condition);
    end
    
    
elseif isstruct(LAN)   
%end
%function LAN = epoch_lan_struct(LAN, condition)



%if nargin ==1 ;
    if isempty(LAN.time)
        disp('lack times argumente or LAN.time fields')
        LAN.data = [];
        try LAN = rmfield(LAN,'trials');end
        LAN = lan_check(LAN);
        %LAN.event =[];
    elseif size(LAN.time,1) == 1 && sum(LAN.time == [0 0 0])==3
        if sum(LAN.time == [0 0 0])==3
        disp('LAN.time = [0,0,0]')
        LAN.data = [];
        try LAN = rmfield(LAN,'trials');end
        LAN = lan_check(LAN);
        %LAN.event =[];
        end
    else
    
     %if ~iscell(LAN.data)
      [fil col] = size(LAN.time);


   

%times = LAN.time;
if (size(times,1)==1)&&(size(LAN.data,2)>1)
    times =repmat(times,[size(LAN.data,2),1]);
end


[fil col ] = size(times);

if iscell(times)
    error('LAN.time must be matrix [trials x initial time , final time, points "0" ]')

else
    %zero_r = fix(LAN.times(:,3)'); % in row data
    if LAN.trials>1 % no-continuos data
        for i = 1:size(times,1)
            if LAN.pnts(i)>0
            zero(i) = find_approx(linspace(LAN.time(i,1),LAN.time(i,2),LAN.pnts(i)),0);
            end
        end
    else
        zero = times(:,3)';
    end
    inicio = times(:,1)' .*LAN.srate;
    inicio = fix(inicio) + fix(zero); 
    final = times(:,2)' .*LAN.srate;
    final= fix(final) + fix(zero);   
   
   
    
end


if size(inicio) ~= size(final)
  error('Matrix INICIO and FINAL must be same size')
end



%%%%% for data matrix

if ~iscell(LAN.data)
        %%% for EEGLAB struct
    xx = length(inicio);
    [electr largo] = size(LAN.data) ;

    if condition==1
      EEGout=[];
      for i = 1:xx
          EEGout(:,:,i) = LAN.data(:,(inicio(i):final(i)));
          %for ii = 1:electr
          %EEGout(ii,:,i) = EEGin.data(ii,(inicio(i):final(i)));
          %end
          selected{i}(1,:) = LAN.selected(:,(inicio(i):final(i)));
          selected{i}(1,:) = selected{i}(1,:) - selected{i}(1) +1;
          if isfield(LAN,'row_data')
            rEEGout(:,:,i) = LAN.row_data(:,(inicio(i):final(i)));      
          end
      end
      LAN.data = [];
      LAN.data = EEGout;
      LAN.selected = selected;
      if isfield(LAN,'row_data')
        LAN.row_data = rEEGout;
      end
    end

        %%% for LAN struct
    if condition==2
      EEGout=[];
      for i = 1:xx
          EEGout{i}(:,:) = LAN.data(:,(inicio(i):final(i)));
          % for selected areas 
          selected{i}(1,:) = LAN.data(:,(inicio(i):final(i)));
          selected{i}(1,:) = selected{i}(1,:) - selected{i}(1) +1;
          
          if isfield(LAN,'row_data')
              rEEGout{i}(:,:) = LAN.row_data(:,(inicio(i):final(i)));
          end
      end
      LAN.data = [];
      LAN.data = EEGout;
      LAN.selected = selected;
          if isfield(LAN,'row_data')
              LAN.row_data = LAN.row_data;
          end
    end


    if ~isempty(zero)
        for i = 1:length(zero)
        LAN.time(i,1) = (inicio(i) - zero(i))/LAN.srate;
        LAN.time(i,2) = (final(i) - zero(i))/LAN.srate;
        LAN.time(i,3) = zero(i);
        end
        end

try
    LAN = arreglaeventos(LAN,inicio,final);
catch
    warning('evento no se pudieron arreglar');
end
    LAN = rmfield(LAN,'trials');

    LAN = lan_check(LAN);

%%%%% for data cell    
else   
   
    %% para time 
    if length(LAN.data) == size(LAN.time,1);

        inicio_c    = zero(1) - inicio(1);
        final_c     = final(1) - zero(1);
  
          if condition == 1
                      EEGout =[];
                  for tr = 1:length(LAN.data)
                      EEGout(:,:,tr) = LAN.data{tr}(:,inicio:final);
                      
                  end
          elseif condition ==2
                   EEGout =[];   
                  for tr = 1:length(LAN.data)
                      if isempty(LAN.data{tr}), continue, end
                      EEGout{tr}(:,:) = LAN.data{tr}(:,inicio(tr):final(tr));
                      selected{tr}(1,:) = LAN.selected{tr}(1,inicio(tr):final(tr));
                      selected{tr}(1,:) = selected{tr}(1,:) - selected{tr}(1) +1;
                        if isfield(LAN,'row_data')
                            rEEGout{tr}(:,:) = LAN.row_data{tr}(:,inicio(tr):final(tr));
                        end
                        
                        if tf
                           DATA{tr} = lan_get_timefreq(LAN,'all',tr);
                           DATA{tr} = DATA{tr}(:,:,find_approx(LAN.freq.time,time(1,1)):find_approx(LAN.freq.time,time(2,1)));
                           
                        end
                  end    
          end
          LAN.data =[];
          LAN.data = EEGout; clear EEGout;
          LAN.selected = selected;
          if tf
          LAN.freq.powspctrm=DATA;
          end
          if isfield(LAN,'row_data')
              LAN.row_data = rEEGout;
          end
          

          try LAN = arreglaeventos(LAN,inicio,final); end
  
          if isfield(LAN,'trials')
            LAN = rmfield(LAN,'trials');
          end
          
          if ~isempty(zero)
            for i = 1:length(zero)
            LAN.time(i,1) = times(i,1);%(inicio(i) - zero(i))/LAN.srate;
            LAN.time(i,2) = times(i,2);%(%(final(i) - zero(i))/LAN.srate;
            %LAN.time(i,3) = zero(i);
            end
          end
          
            LAN = lan_check(LAN);
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    elseif length(LAN.data) == 1
        
          xx = length(inicio);
         [electr largo] = size(LAN.data{1}) ;

        if condition==1
                  EEGout=[];
                  for i = 1:xx
                      EEGout(:,:,i) = LAN.data{1}(:,(inicio(i):final(i)));
                      selected{i}(1,:) = LAN.selected{i}(1,inicio:final);
                      selected{i}(1,:) = selected{i}(1,:) - selected{tr}(1) +1;
                      %for ii = 1:electr
                      %EEGout(ii,:,i) = EEGin.data(ii,(inicio(i):final(i)));
                      %end
                         if isfield(LAN,'row_data')
                            rEEGout(:,:,i) = LAN.row_data{1}(:,(inicio(i):final(i)));                           
                         end    
                         if tf
                           DATA{i} = lan_get_timefreq(LAN,'all',tr);
                           DATA{i} = DATA{i}(:,:,find_approx(LAN.freq.time,time(i,1)):find_approx(LAN.freq.time,time(i,2)));
                        end
                  end
                  LAN.data = [];
                  LAN.data = EEGout;
                  LAN.selected = selected;
                  if tf
                  LAN.freq.powspctrm=DATA;
                  end
                  if isfield(LAN,'row_data')
                    LAN.row_data = rEEGout;
                  end
        end

    %%% for LAN struct
        bad_epoch=[];
        if condition==2
              EEGout=[];
              for i = 1:xx
                  [inicio(i) final(i)];
                  if (inicio(i) > 0)&&(final(i)<=size(LAN.data{1},2))
                  EEGout{i} = LAN.data{1}(:,(inicio(i):final(i)));
                  selected{i}(1,:) = LAN.selected{1}(1,inicio(i):final(i));
                  selected{i}(1,:) = selected{i}(1,:) - selected{i}(1) +1;
                          if isfield(LAN,'row_data')
                              rEEGout{i} = LAN.data{1}(:,(inicio(i):final(i)));                       
                          end 
                          if tf
                           DATA{i} = lan_get_timefreq(LAN,'all',tr);
                           DATA{i} = DATA{i}(:,:,find_approx(LAN.freq.time,time(i,1)):find_approx(LAN.freq.time,time(i,2)));
                           
                           %% 
                           
                          end
                  else
                      bad_epoch = [bad_epoch , i];
                  end
              end
              LAN.data = [];
              LAN.data = EEGout;
              LAN.selected = selected;
              if isfield(LAN,'row_data')
                 LAN.row_data=rEEGout;
              end
              if tf
                  LAN.freq.powspctrm=DATA;
              end
              % segemntar frecuencias
              if isfield(LAN,'freq') && ~isempty(LAN.freq) && ~tf
                  % guardado en archivo
                  if isstruct(LAN.freq.powspctrm)
                      % guardado por electrodo
                      if size(LAN.freq.powspctrm,1) == LAN.nbchan
                          disp('Extracting FT per electrode:')
                      for e =1:LAN.nbchan
                      dataft = lan_getdatafile(LAN.freq.powspctrm(e,1).filename,...
                      LAN.freq.powspctrm(e,1).path,...
                      LAN.freq.powspctrm(e,1).trials);
                      dataft =dataft{1}; 
                      

                      
                      
                       for i = 1:xx  
                       
                          if ~any(bad_epoch==i)
                          paso = dataft(:, find_approx(LAN.freq.time,inicio(i)./LAN.srate):find_approx(LAN.freq.time,final(i)./LAN.srate)               )  ;  
                          FTout{i}(:,e,:) = paso;
                          %size(paso)
                          end
                       
                       end
                       %size(FTout{1})
                       fprintf([num2str(e) '-' ])
                      end
                      end
                  end
                  
              LAN.freq.powspctrm = FTout;
              LAN.freq.time = linspace(times(1,1),times(1,2),size(FTout{1},3));
              
              end
              %
              %
              
         end


        if ~isempty(zero)
            for i = 1:length(zero)
            LAN.time(i,1) = times(i,1);%(inicio(i) - zero(i))/LAN.srate;
            LAN.time(i,2) = times(i,2);%(%(final(i) - zero(i))/LAN.srate;
            LAN.time(i,3) = zero(i);
            end
        end
        try
        LAN = arreglaeventos(LAN,inicio,final);
        end 
        LAN = rmfield(LAN,'trials');
        LAN = rmfield(LAN,'accept');
        LAN = rmfield(LAN,'correct');
        LAN = rmfield(LAN,'tag');
        LAN = lan_check(LAN);


    
    
    end
    end
    end
    
    % cleare delete data
    LAN = lan_check(LAN,'C');
    
else
    error('not LAN format !!!')
end
end

%-------------------------------------------------


function LAN = arreglaeventos(LAN,inicio,final)

currcode = cell2mat({LAN.event.type});

if isfield(LAN.event,'latency_aux')
    currlate = cell2mat({LAN.event.latency_aux});
else
    currlate = cell2mat({LAN.event.latency});
end


if isfield(LAN.event, 'duration' )
    currdura = cell2mat({LAN.event.duration});
else currdura = ones(1,length(currcode));
end

count = 0;

for ii = 1:length(inicio)
    if   ii == 1
              tiempo = 1;
            else 
               tiempo = tiempo + (final(ii-1) - inicio(ii-1)) +1;
    end
  
   
    length(currlate)
    for i = 1:length(currlate)
       
        if currlate(i) >= inicio(ii) &  currlate(i) <= final(ii)
           count = count + 1;
           currlate_c(count) = currlate(i);
           currcode_c(count) = currcode(i);
           currdura_c(count) = currdura(i);
           
           latenciaplana(count) = tiempo + (currlate(i) - inicio(ii));
        end
    end
end



levent = length(currcode_c);
LAN.event = [];

for i=1:levent
   LAN.event(i).type    = currcode_c(i);
   LAN.event(i).latency_aux = currlate_c(i);
   LAN.event(i).duration = currdura_c(i);
   LAN.event(i).latency = latenciaplana(i);
end

end