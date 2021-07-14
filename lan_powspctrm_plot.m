function lan_powspctrm_plot(LAN,chan,normal)

if nargin<3
    normal = [''];
end

P = mean(cat(4,LAN.freq.powspctrm{:}),4);
switch normal
    case {'z','Z'}
    P = normal_z(P);
end
P = double(squeeze(P(:,chan,:)));
pcolor(LAN.freq.time,LAN.freq.freq,P), shading flat;




end