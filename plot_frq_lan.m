function plot_frq_lan(LAN,cfg)
%
%
%
if nargin == 0
   edit plot_frq_lan.m 
   help plot_frq_lan
   return
end



try
    mod = cfg.mod;
catch
    mod = 'L1'
end


    
for c = 1:size(LAN,2)
    for l = 1:size(LAN,1)
     L{l,c} = LAN{l,c}.freq.powspctrm;  
    end   
end

for c = 1:size(LAN,2)
    Lx = mean(cat(4,L{:,c}),4);
    uno = strrep('Lc = Lx;', 'c', num2str(c));
    eval(uno);
end
    
clear L Lx

%mod = mod(2:length(mod));
data = eval(mod);
x = str2num(mod(2));

%%% channels
try
    chanlocs = cfg.chanlocs;
catch
    try
    chanlocs = LAN{1,x}.chanlocs;
    catch
    load chanlocs;
    end
end

%%% time
try
    time = cfg.time;
catch
        time = LAN{1,x}.freq.time;
end

%%% freq
try
       freq = cfg.freq;
catch
        freq = LAN{1,x}.freq.freq;
end
    
%%% norm
try
        norm = cfg.norm;
catch
        norm = [] ;%LAN{x}.freq.freq
end

%%% norm
try
        c_axis = cfg.c_axis;
catch
        c_axis = []; %LAN{x}.freq.freq
end
   


title = ['Ploting ' mod ' pow of '  inputname(1) ];

plot32(data,chanlocs,time,freq,norm,c_axis,title);