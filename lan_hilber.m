function LAN = lan_hilber(LAN,cfg)
%
%   cfg.out   = 'signal' , 'amp' , 'phase'
%   cfg.band  = [f1  f2]
%
%
%



if iscell(LAN)
    for lan = length(LAN)
        LAN{lan} = lan_hilber(LAN{lan},cfg);
    end
    return
end

getcfg(cfg,'out','signal');
getcfg(cfg,'band');
getcfg(cfg,'norbin',false);

if iscell(LAN.data)
  for t = 1:length(LAN.data)
     if LAN.accept(t) 
     LAN.data{t} = hilber_p(LAN.data{t},band,out,LAN.srate,norbin); 
     end
  end
else
     LAN.data = hilber_p(LAN.data,band,out,LAN.srate,norbin); 
end
end


function ndata= hilber_p(data,band,out,srate, norbin)

for e = 1:size(data,1)   
    ndata(e,:) = filter_hilbert(data(e,:)', srate, min(band) , max(band) , norbin );   
end

switch out
    case 'amp'
    ndata = single(abs(ndata));
    case 'phase'
    ndata = single(phase(ndata));   
end
end
