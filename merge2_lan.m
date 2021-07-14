function LAN = merge2_lan(varargin)
% acopla LAN
%
 
lan = length(varargin);
con = length(varargin{1});
for l = 1:lan
    for c = 1:con
        LAN{l,c} = varargin{l}{c};
    end
end

