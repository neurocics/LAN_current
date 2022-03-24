function LAN = lan_add_elec(LAN,elec_ind,chanloncs ,interp)
if nargin <3
    interp=true;
end
LAN = lan_check(LAN);

labels = LAN.tag.labels;
labels{end+1} = 'PHANTOM'; 
mat = LAN.tag.mat;
i_l = length(labels);

elec_ind = sort(elec_ind);

for e =elec_ind
    
    r = 0;
    for t = 1:LAN.trials
        e = e+r;
        paso =   LAN.data{t};
        paso = cat(1, paso(1:e-1,:) , zeros(1,LAN.pnts(t)), paso(e:size(paso,1),:)); 
        LAN.data{t} = paso;
    end
    
    
    mat = cat(1, mat(1:e-1,:) , zeros(1,LAN.trials)+i_l, mat(e:size(mat,1),:)); 
    
    
    r = r +1;
end

LAN.chanlocs = chanloncs;
LAN.tag.labels=labels;
LAN.tag.mat=mat;

LAN = lan_check(LAN);

if interp
    cfg=[];
    cfg.type='PHANTOM';
    LAN = lan_interp(LAN,cfg);
end

end