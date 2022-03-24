function LAN = mod_time(LAN, time, mod, fix)
% 13.4.2009
% time = [-0.5 0.5]
% mod = [1 2 ]  % 1 for initial time and
%               % 2 for end time
% fix = 1 % fix time for all epoch
% LAN = mod_time(LAN, time, mod, fix)
%
%

if nargin < 4; fix = 1;end
%
if ~iscell(LAN)
    LAN = mod_time_st(LAN, time, mod, fix);
elseif iscell(LAN)
    for lan = 1:length(LAN)
        LAN{lan} = mod_time_st(LAN{lan}, time, mod, fix);
    end
end
%
%
%
end

function LAN = mod_time_st(LAN, time, mod, fix)
%
%
if isempty(LAN)
    return
end
[fil2 col2] = size(LAN.time);
[fil col] = size(time);
%
%
if fix == 1
    
    if fil == 1
        for i = 1:fil2; time_c(i,:) = time; end
        count = 0;
        for i = mod
            count = count + 1;
            LAN.time(:,i) = time_c(:,count);
        end
    end
elseif fix == 0
    if fil ~=fil2
        error('files in time must be the same of LAN.time');
    end
    for i = mod
            count = count + 1;
            LAN.time(:,i) = time(:,count);
    end
end
end

  
