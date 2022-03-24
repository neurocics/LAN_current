function [LAN] = lan_ibw_ttl(LAN, threshold)
%% Load ibw
data = lan_from_ibw();
srate = data.srate;
data = data.data{1};
%% Set threshold
if(nargin >= 3)
    ths = std(data(1,:))*threshold;
else 
    ths = std(data(1,:))*4.5;
end

med = median(data(1,:));
up_idx = data > (med + ths);
down_idx = data < (med - ths);

%% Discretize data
data(up_idx) = 1;
data(down_idx) = -1;
data( ~(up_idx | down_idx) ) = 0;

%% Find first and last events
LAN.ttl_start = find(data ~= 0, 1, 'first') / srate;
LAN.ttl_end = find(data ~= 0, 1, 'last') / srate;

end