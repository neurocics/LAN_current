% only_field_lan.m
%
% v1.0
% 20.11.2009
% Pablo Billeke

function LAN = only_field_lan(LAN, string)

if isstruct(LAN)
    LAN = only_field_lan_struct(LAN,string);
elseif iscell(LAN)
    for lan = 1:length(LAN)
    LAN{lan} = only_field_lan_struct(LAN{lan},string);
    end
end
end


function LAN = only_field_lan_struct(NAL, string)

uno = ['LAN.' string ' = NAL. ' string];
eval(uno);



end