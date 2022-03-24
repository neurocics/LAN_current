function LAN = lan_from_int(channels, srate_new, File, Path)
% IMPORTANT: number of channels required
%
% *************DEPENDENCIES*************
% - read_intan_data.m (Intan Technologies)
% (c) 2010, Intan Technologies, LLC
% For more information, see http://www.intantech.com
% For updates and latest version, see http://www.intantech.com/software.html

if ~exist('read_intan_data', 'file')
    LAN = [];
    disp('Required: read_intan_data.m');
    return;
end
if nargin < 1 || length(channels) ~= 1
    LAN = [];
    disp('Required: number of channels');
    return;
end
if nargin < 2
    srate_new = 25000;
end

LAN.srate = 25000;
% LAN.importrec.files = File;
% LAN.importrec.Path = Path;

if nargin == 4
    [~,~,data,aux] = read_intan_data(1:channels, [Path File]);
else
    [~,~,data,aux] = read_intan_data(1:channels);
end

ind = sum(aux,1);
if sum(ind) ~= 0 && sum(ind) ~= size(aux,1)
    [~, ind] = max(ind);
    aux = aux(:, ind);
    LAN.ttl = aux;
    aux = diff(aux);
    aux = aux~=0;
    seq = (1:length(aux))+1;
    seq = seq(aux);
    LAN.ttl_start = seq(1) / LAN.srate;
    LAN.ttl_end = seq(end) / LAN.srate;
else
    disp('no TTL input detected');
    LAN.ttl_start = 0;
    LAN.ttl_end = 0;
end
clear aux;

if srate_new < LAN.srate
    nsamp = round(LAN.srate / srate_new);
    data = downsample(data, nsamp);
    if isfield(LAN,'ttl')
        LAN.ttl = downsample(LAN.ttl,nsamp);
    end
    LAN.srate = LAN.srate / nsamp;
elseif srate_new > LAN.srate
    disp('Impossible to get the desired sample rate. Using predetermined sample rate');
end
LAN.data{1} = data';

