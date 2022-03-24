function LAN = lan_from_nsx(chan, srate_new)
% *************DEPENDENCIES*************
% - openNSx (Neural Processing Matlab toolkit)

[File, Path, ~] = uigetfile({'*.ns*','NSx file';}, 'Open .nsx file', '', 'MultiSelect', 'off');

NSx = openNSx([Path, File]);
LAN.srate = NSx.MetaTags.SamplingFreq;
LAN.importrec.files = File;
LAN.importrec.Path = Path;

if nargin < 2
    srate_new = LAN.srate;
end
if nargin < 1 || isempty(chan)
    chan = 1:size(NSx.Data,1);
end

if srate_new < LAN.srate
    nsamp = round(LAN.srate / srate_new);
    NSx.Data = downsample(NSx.Data', nsamp)';
    LAN.srate = LAN.srate / nsamp;
elseif srate_new > LAN.srate
    disp('Impossible to get the desired sample rate. Using predetermined sample rate');
end
LAN.data{1} = NSx.Data(chan, :);
