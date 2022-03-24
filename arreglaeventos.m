function LAN = arreglaeventos(LAN,inicio,final)

currcode = cell2mat({LAN.event.type});

if isfield(LAN.event,'latency_aux')
    currlate = cell2mat({LAN.event.latency_aux})
else
    currlate = cell2mat({LAN.event.latency})
end


if isfield(LAN.event, 'duration' )
    currdura = cell2mat({LAN.event.duration});
else currdura = ones(1,length(currcode))
end

count = 0

for ii = 1:length(inicio)
    if   ii == 1
              tiempo = 1;
            else 
               tiempo = tiempo + (final(ii-1) - inicio(ii-1)) +1;
    end
  
   
    length(currlate);
    for i = 1:length(currlate)
       
        if currlate(i) >= inicio(ii) &  currlate(i) <= final(ii)
           count = count + 1
           currlate_c(count) = currlate(i)
           currcode_c(count) = currcode(i)
           currdura_c(count) = currdura(i)
           
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
