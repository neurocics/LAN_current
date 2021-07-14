function [LAN latency ]= search_lat(LAN)
% 14.4.2009 prueba
%
%
%
if iscell(LAN)
    for lan = 1:length(LAN)
    [LAN{lan} latency{lan} ]= search_lat_st(LAN{lan});
    end
else
    [LAN latency ]= search_lat_st(LAN)
end
end


function [LAN latency ]= search_lat_st(LAN)
mn = 0
my = 0
minor = [];
mayor = [];
for i = 1:length(LAN.data)
   laten_s(i) = ( LAN.time(i,2)  - LAN.time(i,1) );
   laten_r(i) = length(LAN.data{i}) / LAN.srate;
   if laten_s(i) > laten_r(i)
       mn = mn +1;
       minor(mn) = i;
   elseif laten_s(i) < laten_r(i)
       my = my +1;
       mayor(my) = i;
   end
end

latency.minor = minor';
latency.mayor = mayor';
latency.latency = laten_r';

end




   
    
