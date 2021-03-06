function [LAN] = del_trials(LAN, trials)
%
% v.1  form eliminar.m 9.4.2009

if iscell(LAN)
    for lan = 1:length(LAN)
        [LAN{lan}] = del_trials_st(LAN{lan}, trials{lan});
    end
else
        [LAN] = del_trials_st(LAN, trials);
end

end



function [LAN] = del_trials_st(LAN, trials)

LAN.data_del.data = [];
LAN.data_del.trials = [];
LAN.data_del.pos = [];

[y x ] = size(trials);
if x == 1 & y > 1
    trials = trials'
end

tr = sort(trials, 'descend');

for i = 1:length(tr)
LAN.data_del.data{length(tr)-(i-1)} = LAN.data{tr(i)};
LAN.data(:,tr(i)) = [];
LAN.data_del.pos(length(tr)-(i-1)) = tr(i);    
end
LAN.data_del.trials = length(tr);

pos = tr;


        [y x] = size(pos);
        time_n = zeros(x,3);
       
        pos = sort(pos,2,'descend')
        cont = 0
        for i = pos
            cont = cont + 1;
            
            time_n(x-(cont-1),:) = LAN.time(i,:) ;
            
            LAN.time(i,:) = [];
        end
        
        
        LAN.data_del.time = time_n;
            

end

