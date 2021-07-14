function LAN = lan_rt_segmentation(LAN, RT, chan, window)
% Assumes unsegmented signal
%
% chan : for common events, use empty array : [];
% window : window of interest in miliseconds
%   example: [-500 1000] (default). Our window of interest begins 500 ms
%   before the event and ends 1000 ms after the event.

if LAN.trials > 1
    disp('Cannot segment anymore. Returning.')
    return;
end
if nargin < 3
    window = [-500 1000];
end
window = fix(window*LAN.srate/1000);


% extract time stamps
if isempty(chan)
    RT = rt_del(RT,(RT.good==0));
else
    RT = rt_del(RT,(RT.est~=chan)|(RT.good==0));
end
mRT = fix(RT.laten*LAN.srate/1000) + RT.OTHER.time_max;
mRT = mRT(mRT+window(1) > 0 & mRT+window(2) <= LAN.pnts);
ptime = mRT + window(1);

% rejection and segmentation
orig = LAN.data{1};
rej = false(1, numel(mRT));
nrej = 0;
for c = 1:length(mRT)
    sel = LAN.selected{1}(mRT(c)+window(1):mRT(c)+window(2));
    if sum(sel) < numel(sel)
        rej(c) = true;
        nrej = nrej + 1;
    else
        LAN.data{c-nrej} = orig(:, mRT(c)+window(1):mRT(c)+window(2));
    end
end
ptime = ptime(~rej);

% store
LAN = rmfield(LAN,'selected');
LAN = rmfield(LAN,'accept');
LAN = rmfield(LAN,'correct');
LAN = rmfield(LAN,'tag');
LAN = lan_check(LAN);
LAN.time(:,3) = ptime';