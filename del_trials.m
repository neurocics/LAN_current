function [LAN] = del_trials(LAN, trials)
%
% v.1.9  worrking in compatibility for new LAN function 
%        (2.12.2024)
% v.1    form eliminar.m 9.4.2009

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
LAN.data_del.accept= [];
LAN.data_del.tag_mat = [];
LAN.data_del.selected = [];

LAN.data_del.trials = [];
LAN.data_del.pos = [];

[y, x ] = size(trials);
if x == 1 && y > 1
    trials = trials';
end
if islogical(trials)
    trials = find(trials);
end
tr = sort(trials, 'descend');

for i = 1:length(tr)

% data    
LAN.data_del.data{length(tr)-(i-1)} = LAN.data{tr(i)};
LAN.data(:,tr(i)) = [];

% select  
LAN.data_del.selected{length(tr)-(i-1)} = LAN.selected{tr(i)};
LAN.selected(:,tr(i)) = [];

% accept
LAN.data_del.accept{length(tr)-(i-1)} = LAN.accept(tr(i));
LAN.accept(tr(i)) = [];

% tag
LAN.data_del.tag_mat(:,length(tr)-(i-1)) = LAN.tag.mat(:,tr(i));
LAN.tag.mat(:,tr(i)) = [];

%pos
LAN.data_del.pos(length(tr)-(i-1)) = tr(i);    
end
LAN.data_del.trials = length(tr);

pos = tr;


        [y, x] = size(pos);
        time_n = zeros(x,3);
       
        pos = sort(pos,2,'descend');
        cont = 0;
        for i = pos
            cont = cont + 1;
            
            time_n(x-(cont-1),:) = LAN.time(i,:) ;
            
            LAN.time(i,:) = [];
        end
        
        
        LAN.data_del.time = time_n;
            

        LAN.RT = rt_del(LAN.RT,trials);
end

