function [LAN] = lan_add_ttl(LAN, path_clock_csv, threshold)
% 
% Daniel Acuna, Marcelo Stockle
%
% input : 
%   threshold (en desviaciones estandar)

% Load csv
if nargin < 2 || isempty(path_clock_csv)
    path_clock_csv = uigetfile({'*.csv','CSV file';}, 'Open .csv clock file',...
        '*.csv', 'MultiSelect', 'off');
end
data = importdata(path_clock_csv);
if isstruct(data)
    data = data.data;
end

% Set threshold
if(nargin >= 3)
    ths = std(data)*threshold;
else 
    ths = std(data)*4.5;
end

% Discretize data
med = median(data);
seq = 1:length(data);
seq = seq( abs(data) > (med + ths));
seq = seq(seq>10);

% Find first and last events
LAN.ttl_start = seq(1) / LAN.srate;
LAN.ttl_end = seq(end) / LAN.srate;

end
