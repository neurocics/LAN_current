function LAN = lan_rm_chan(LAN, ind,ica)
%
%

if nargin < 3
    ica = 0;
end

if ischar(ica)
    ica  = strcmp(ica,'ica');
end

if abs(ica)
    if iscell(LAN)
       for lan=1:length(LAN)
           LAN{lan} = lan_rm_chan(LAN{lan}, ind, ica);
       end 
    else
        W = (LAN.ica_weights*LAN.ica_sphere);
        for t = 1:LAN.trials;
            data = W*LAN.data{t};
            data(ind,:) = 0;
            LAN.data{t} = pinv(W)*data;
        end
    
    end
    if isfield(LAN,'ica_del')
    LAN.ica_del = unique([ ind LAN.ica_del ]);    
    else
    LAN.ica_del = ind;
    end
else

    LAN = electrode_lan(LAN,ind);
    
end

 % save index of deleted componetes 

   
end