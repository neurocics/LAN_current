function LAN = lan_merge(LAN1, LAN2, ts1, ts2)
% Optional : ts1 and ts2 are simultaneous time stamps in LAN1 and LAN2
% respectively (units: sample count, index-1)

if nargin < 4
    ts1 = 1;
    ts2 = 1;
end

LAN = [];

if LAN1.srate ~= LAN2.srate
    disp('lan_merge requires consistent sampling rates');
    return;
end
if LAN1.trials > 1 || LAN2.trials > 1
    disp('lan_merge requires unsegmented data');
    return
end

pnts = max(ts1,ts2);
nbchan = LAN1.nbchan + LAN2.nbchan;

LAN = LAN1;
LAN.pnts = pnts;
LAN.data{1} = zeros(nbchan, pnts);

if ts1>ts2
    init1 = 0;
    init2 = abs(ts1-ts2);
else
    init1 = abs(ts1-ts2);
    init2 = 0;
end
LAN.data{1}(1:LAN1.nbchan    , (1:LAN1.pnts)+init1) = LAN1.data{1};
LAN.data{1}(LAN1.nbchan+1:end, (1:LAN2.pnts)+init2) = LAN2.data{1};
LAN.pnts = pnts;
LAN.nbchan = nbchan;
LAN = rmfield(LAN, 'time');
LAN = rmfield(LAN, 'chanlocs');
LAN = rmfield(LAN, 'xmax');
LAN = rmfield(LAN, 'tag');
LAN = lan_check(LAN);

end