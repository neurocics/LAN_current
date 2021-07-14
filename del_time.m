function [LAN LAN2] = del_time(LAN, pos, guardar)
%
% v.1.0.1  form eliminar.m 15.6.2009
if nargin < 3; guardar =1,end
if nargin < 2; pos = 0; end
if isempty(pos); pos = 0;end



if iscell(LAN)
    for lan = 1:length(LAN)
        [LAN{lan} LAN2{lan}] = del_time_st(LAN{lan}, pos, guardar);
    end
else
        [LAN LAN2] = del_time_st(LAN, pos, guardar);
end

end



function [LAN LAN2] = del_time_st(LAN, pos, guardar)
if pos ~= 0
        [y x] = size(pos);
        time_n = zeros(x,3);
        %o = length(laten.o.latency);
        %c = length(laten.c.latency);
        pos = sort(pos,2,'descend')
        cont = 0
        for i = pos
            cont = cont + 1;
            if guardar == 1
            time_n(x-(cont-1),:) = LAN.time(i,:) ;
            end
            LAN.time(i,:) = [];
        end
        if  guardar == 1
        LAN2 = create_lan;
        LAN2.time = time_n;
        LAN2.data = LAN.data;
        LAN2.cond = [LAN.cond 'del'];
        LAN2.srate = LAN.srate;
        LAN2.event = [];
        LAN2.event = LAN.event;
        end
else
   if  guardar == 1
        LAN2 = create_lan(LAN.nbchan, LAN.srate);
        LAN2.time = [];
        LAN2.data = LAN.data;
        LAN2.cond = [LAN.cond 'del'];
        LAN2.srate = LAN.srate;
        LAN2.event = [];
        LAN2.event = LAN.event;
   end  
    
end
end

