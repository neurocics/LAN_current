%
% filtro segun script EEGLAB
%
%

function LAN = filt_eeglab(LAN,low,hi)

if isstruct(LAN)
    LAN = filt_eeglab_struct(LAN,low,hi);
elseif iscell(LAN)
    for lan = 1:length(LAN)
    LAN{lan} =filt_eeglab_struct(LAN{lan},low,hi);
    end
end
end







function LAN = filt_eeglab_struct(LAN,low,hi)


if iscell(LAN.data)
   try
   data = cat(3,LAN.data{:}) ;
   disp('Regitro epoquiado');
   LAN.pnts = size(data,2);
   LAN.xmin = LAN.time(1,1);
   LAN.xmax = LAN.time(1,2);
   LAN.time = linspace(LAN.xmin, LAN.xmax, LAN.pnts );
   epo = 1;
   catch
   data = cell2mat(LAN.data);
   disp('Registro continuo');
   LAN.pnts = length(data);
   end
   LAN.data = data;
   clear data
   
end
LAN = pop_eegfilt( LAN, low, hi, [], [0]); 
if epo == 1
LAN.data = reshape(LAN.data, LAN.nbchan,LAN.pnts,LAN.trials);
end
end



