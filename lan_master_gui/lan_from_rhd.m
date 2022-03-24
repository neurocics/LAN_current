function LAN = lan_from_rhd(srate_new, filename, pathname)
% *************DEPENDENCIES*************
% - read_Intan_RHD2000_file_.m (Intan Technologies)
% (c) 2010, Intan Technologies, LLC
% For more information, see http://www.intantech.com
% For updates and latest version, see http://www.intantech.com/software.html

%% arguments
if ~exist('read_Intan_RHD2000_file_', 'file')
    LAN = [];
    disp('Required: read_Intan_RHD2000_file_.m');
    return;
end

if nargin == 3
    [amplifier_data, board_dig_in_data, frequency_parameters] = read_Intan_RHD2000_file_(filename, pathname);
else
    [amplifier_data, board_dig_in_data, frequency_parameters] = read_Intan_RHD2000_file_;
end

if nargin < 1 || srate_new == 0
    srate_new = frequency_parameters.amplifier_sample_rate;
end

LAN.srate = frequency_parameters.amplifier_sample_rate;

%% TTL
board_dig_in_data = board_dig_in_data';
ind = sum(board_dig_in_data,1);
if sum(ind) ~= 0 && sum(ind) ~= size(board_dig_in_data,1)
    [~, ind] = max(ind);
    board_dig_in_data = board_dig_in_data(:, ind);
    LAN.ttl = board_dig_in_data;
    board_dig_in_data = diff(board_dig_in_data);
    board_dig_in_data = board_dig_in_data~=0;
    seq = (1:length(board_dig_in_data))+1;
    seq = seq(board_dig_in_data);
    LAN.ttl_start = seq(1) / LAN.srate;
    LAN.ttl_end = seq(end) / LAN.srate;
else
    disp('no TTL input detected');
    LAN.ttl_start = 0;
    LAN.ttl_end = 0;
    LAN.ttl = 0;
end
clear aux;

%% downsample
amplifier_data = amplifier_data';
if srate_new < LAN.srate
    nsamp = round(LAN.srate / srate_new);
    amplifier_data = downsample(amplifier_data, nsamp);
    LAN.ttl = downsample(LAN.ttl, nsamp);
    LAN.srate = LAN.srate / nsamp;
elseif srate_new > LAN.srate
    disp('Impossible to get the desired sample rate. Using predetermined sample rate');
end
LAN.data{1} = amplifier_data';
LAN = lan_check(LAN);