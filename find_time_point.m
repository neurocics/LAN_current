function P = find_time_point(LAN,T)
%
% LAN function
% v.0.1
% 12.06.2017

times=timelan(LAN);
P=nan(size(T));
for ti = 1:numel(T)
    P(ti) = find_approx(times,T(ti));
end




