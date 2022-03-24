function [spikes, xax] = qrt_get_spikes(qRT, LAN, chan, w_pre, w_post)

if nargin < 5; w_post=qRT.cfg.w_post; end
if nargin < 4; w_pre = qRT.cfg.w_pre; end
% if nargin < 3; chan = qRT.chan; end

ind = find(qRT.chan == chan);
TS = ceil(qRT.laten{ind} * LAN.srate / 1000);
bounds = [w_pre+1 LAN.pnts-w_post];
useless = TS >= bounds(1) & TS <= bounds(2);

if qRT.cfg.fmin==0 && qRT.cfg.fmax==0
    x = {LAN.data{1}};
else
    x = lan_butter(LAN, qRT.cfg.fmin, qRT.cfg.fmax, chan);
end
spikes = zeros(length(TS),w_pre+w_post+1);
for c = 1:length(TS)
    if useless(c)
        spikes(c,:) = x{1}(chan, TS(c)-w_pre:TS(c)+w_post );
    else
        spikes(c,:) = NaN;
    end
end

xax = (-w_pre:w_post) * 1000 / LAN.srate;