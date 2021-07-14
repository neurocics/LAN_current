function LAN = lan_add_rt(LAN,RT)
% v.0.0.0
%     <*LAN)<|
% add reaction time (RT) structure to LAN structure
%
% 
% 30.3.2012
% Pablo Billeke

if iscell(LAN)
   error('function only for single LAN structure!!')
end
switch RT.cfg.unit
    case 'ms'
        unit = 1000;
    case 's'
        unit = 1;
    case 'point'
        unit = LAN.srate;
        
end
RT.point_e = fix(RT.laten .* LAN.srate/unit);
RT.point_r = fix(RT.laten .* LAN.srate/unit) + fix(RT.rt .* LAN.srate/unit);
RT.point_r(RT.rt==-99)=-99;
LAN.RT = RT;

end