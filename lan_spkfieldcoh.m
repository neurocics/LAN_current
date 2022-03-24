function [events] = lan_spkfieldcoh(data, ts, freq, srate, std_thr)
%------- DEPENDENCIES
% - filter_hilbert.m
% - filtfilt.m
% - hilbert.m
%
% IMPORTANT: this function doesn't admit simultaneous continuous data.
% No results are provided if these are found.
%
%------- UNITS
% ts: seconds
% freq: 1/seconds
% srate: 1/seconds
% std_thr: standard deviations

if nargin < 5
    std_thr = NaN;
end

events = [];
nonsingdim = find(size(data)~=1);
if nargin < 4 || numel(nonsingdim) ~= 1
    return;
end
data = squeeze(data);
if nonsingdim==2
    data = data';
end

ANA = filter_hilbert(data, srate,freq(1),freq(2),0)';


amp = sqrt(real(ANA).*real(ANA) + imag(ANA).*imag(ANA));
events.indexes = ceil(ts*srate);
ANA = angle(ANA)*-1; % ¡¡¡QUITAR *-1!!!

events.phase = ANA(events.indexes);
events.power = amp(events.indexes);
events.vectors = events.power.*(cos(events.phase) + 1i*sin(events.phase)); % mod NEV 2013.07.04


if ~isnan(std_thr)
    events.valid = false(1,length(events.indexes));
    env = normal_z(amp,amp);
    events.valid( abs(env(events.indexes))>=std_thr ) = true;
else
    events.valid = true(1,length(events.indexes));
end
