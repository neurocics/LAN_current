function LAN = del_epo(LAN, epocas)
% Only for simple LAN structur
% Delete epoch number [epocas]
%
% v.0.2
% Pablo Billeke

% 24.05.2021 fix compatibility 
% 23.01.2013
% 16.11.2010
% 16.6.2009



if iscell(LAN)
    error(' Only for simple LAN structur')
end

%%%%-------
%%%% data
epocas = sort(epocas); %,'descend');
LAN.delete.epoch_epoch = epocas;
cont = 1;
cont2 =1;
if ~iscell(LAN.data)
    arregla=1;
    LAN = mat2cell_lan(LAN);
else
   arregla=0; 
end


for i  = 1:length(LAN.data)
    if i ~= epocas(cont2)
    data{cont} = LAN.data{i};
    selected{cont} = LAN.selected{i};
    correct(cont) = LAN.correct(i);
    accept(cont) = LAN.accept(i);
    if isfield(LAN,'ica_del_comp')
    ica_del_comp{cont}=LAN.ica_del_comp{cont};
    end
    cont = cont + 1;
    else
        data_del{cont2} = LAN.data{i};
        if cont2 < length(epocas)
           cont2 = cont2 +1  ;
        end
    end
end



LAN.data = data;
LAN.selected = selected;
LAN.correct = correct;
LAN.accept = accept;
LAN.delete.data_epoch = data_del;
if isfield(LAN,'ica_del_comp')
LAN.ica_del_comp = ica_del_comp;    
end
%%%%-------
%%%% times

epocas = sort(epocas,'descend');%); %,
times = LAN.time;
cont = length(epocas);
for i =1:length(epocas)
times_del(cont,:) = times(epocas(i),:);    
times(epocas(i),:) = [];
cont = cont -1;
end
[fil col ] = size(times);
if iscell(times)
    error('LAN.time must be matrix [trials x initial time , final time, points "0" ]')
else
    zero = times(:,3)';
    inicio = times(:,1)' .*LAN.srate;
    inicio = fix(inicio) + zero ;
    final = times(:,2)' .*LAN.srate;
    final = fix(final) + zero;
end
LAN.time = times;
LAN.delete.time_epoch = times_del;
%LAN.delete.event_epoch = LAN.event; 

%%%%-------
%%%% eventos

if isfield(LAN,'RT')
    
    LAN.RT = rt_del(LAN.RT,epocas);
    
else
    try
        LAN = arreglaeventos(LAN,inicio,final);
    catch
        disp('NO se puedieron leer los eventos')
    end

end



%LAN = rmfield(LAN,'trials');
LAN = lan_check(LAN);



end
  


function LAN = arreglaeventos(LAN,inicio,final)
% inicio
% final, en segundos

currcode = cell2mat({LAN.event.type});

if isfield(LAN.event,'latency_aux')
    currlate = cell2mat({LAN.event.latency_aux});
else
    currlate = cell2mat({LAN.event.latency});
end


if isfield(LAN.event, 'duration' )
    currdura = cell2mat({LAN.event.duration});
else currdura = ones(1,length(currcode))
end

count = 0;

for ii = 1:length(inicio)
    if   ii == 1
              tiempo = 1;
            else 
               tiempo = tiempo + (final(ii-1) - inicio(ii-1)) +1;
    end
  
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



