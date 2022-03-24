% reduce_field_lan.m
%
% v1.0
% 20.11.2009
% Pablo Billeke

function LAN = reduce_field_lan(LAN, string)

if isstruct(LAN)
    LAN = reduce_field_lan_struct(LAN,string);
elseif iscell(LAN)
    for lan = 1:length(LAN)
    LAN{lan} = reduce_field_lan_struct(LAN{lan},string);
    end
end
end


function LAN = reduce_field_lan_struct(LAN, string)

uno = ['LAN.' string ' = [] '];
eval(uno);
try
LAN = rmfield(LAN,string);
end

end