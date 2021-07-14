%  eval_time_epoch.m
%  v.0.1
%
%   LAN = eval_time_epoch(LAN,comp,cut)
%
%  comp = tiempo en segundo de latencia minima
%  cut : cortar, 0 = no, 1 = desde el fin, 2=desde el inicio
%
%  OJO: eventos quedan desfazados
%
%  Pablo Billeke
%  24.11.2009
%
function LAN = eval_time_epoch(LAN,comp,cut)


if nargin == 0
    edit eval_time_epoch
    help eval_time_epoch
    return
end




LAN = lan_check(LAN);
if isstruct(LAN)
    LAN = eval_time_epoch_struct(LAN,comp,cut);
elseif iscell(LAN)
    for lan = 1:length(LAN)
    LAN{lan} = eval_time_epoch_struct(LAN{lan},comp,cut);
    end
end
end



%----------------------------------------------------
function LAN = eval_time_epoch_struct(LAN,comp,cut)
try ref = LAN.cfg.time.ref;
catch
    ref = 'c';
    disp('Referencia de ''time'' CONTINUA por defecto')
end

if ref == 'c'
   if iscell(LAN.data)
      if length(LAN.data) == size(LAN.time,1)
         for i = 1:size(LAN.time,1)
           %  LAN.time_c(i) =LAN.time(i,3) ;
             LAN.time(i,3) =fix(abs(LAN.time(i,1))*LAN.srate);
             LAN.trials_latency(i,1) = LAN.time(i,2) -LAN.time(i,1);
         end
         LAN.cfg.time.ref = 's';
      end
   end
elseif ref == 's'
    if iscell(LAN.data)
      if length(LAN.data) == size(LAN.time,1)
         for i = 1:size(LAN.time,1)
             %LAN.time(i,3) =fix(abs(LAN.time(i,1))*LAN.srate);
             LAN.trials_latency(i,1) = LAN.time(i,2) -LAN.time(i,1);
         end
         %LAN.cfg.time.ref = 's';
      end
   end
    
end


if nargin >= 2
for i = 1:size(LAN.trials_latency)
    eval(i,1) = LAN.trials_latency(i,1) >= comp;
end
   LAN.cfg.time.par_eval = comp;
   LAN.cfg.time.eval = eval;
end


if nargin == 3
    if cut ==1
                cont = 0;
               cont2= 0;
        for i = 1:LAN.trials
         
            if LAN.cfg.time.eval(i,1) == 1
               Largo = length(LAN.data{i});
               Corte = Largo - fix(comp*LAN.srate);
               cont = cont + 1;
               data{cont}(:,:) = LAN.data{i}(:,Corte:Largo);
             %  inicio(i) = LAN.time_c(i) - fix(LAN.time(i,1)*LAN.srate);
              % final(i) = LAN.time_c(i) + fix(LAN.time(i,2)*LAN.srate);
              time(cont,:) = LAN.time(i,:);

            else
               cont2 = cont2 +1;
               LAN.delete.data{cont2} = LAN.data{i};
               LAN.delete.trail(cont2,1) = i; 
               LAN.delete.time(cont2,:) = LAN.time(i,:);
            end
             
        end
        LAN.time = time;
        %
        LAN.data = data;
        %LAN = arreglaeventos(LAN,inicio,final);
        LAN = lan_check(LAN);
        % fija tiempo
        %for t = 1:size(LAN.time,1)
            LAN.time(:,1) = ( LAN.time(:,2) - comp);
        %end
    
    elseif cut > 1
        error('aun no habilitado.... CUAK');
    end
end


end




