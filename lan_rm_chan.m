function LAN = lan_rm_chan(LAN, ind,ica)
%  v.0.3
%
%  Pablo Billeke 
%  18.04.2022
%  27 08 2021
%  add save deleted comp 

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
        if ~isfield(LAN, 'ica_select')
            LAN.ica_selet = 1:LAN.nbchan;
        end
        W = (LAN.ica_weights*LAN.ica_sphere);
        
        if isfield(LAN,'ica_del_comp')
            added=0; % fix  me!!!
        else
            added=0;
        end
        
        
        for t = 1:LAN.trials;
            if ~isempty(LAN.data{t})
            data= LAN.data{t}(LAN.ica_select,:);
            data = W*data;
            comp=data(ind,:);
            data(ind,:) = 0;
            data = pinv(W)*data;
            LAN.data{t}(LAN.ica_select,:) = data;
            if added
            LAN.ica_del_comp{t}= [LAN.ica_del_comp{t} ; comp] ;
            else
            LAN.ica_del_comp{t}=comp;   
            end
            end
        end
    
    end
    if isfield(LAN,'ica_del')
    LAN.ica_del = ([ LAN.ica_del  ind ]);    
    else
    LAN.ica_del = ind;
    end
else

    LAN = electrode_lan(LAN,ind);
    
end

 % save index of deleted componetes 

   
end