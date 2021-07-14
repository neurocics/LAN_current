function LAN = lan_from_csv(Files, Path)

LAN.data{1} = [];
if nargin == 0
    [Files, Path, ~] = uigetfile({'*.csv','CSV file';}, 'Open .csv EEG files',...
        '*.csv', 'MultiSelect', 'on');
elseif nargin == 1
    Path = '';
end

if iscell(Files)
    for c = Files
        LAN = importcsv(LAN, c{1}, Path);
    end
else
    LAN = importcsv(LAN, Files, Path);
end
LAN.importrec.files = Files;
LAN.importrec.Path = Path;

    function LAN = importcsv(LAN, filename, pathname)
        data = importdata([pathname filename], ',');
        if isnumeric(data)
            LAN.data{1}(end+1,:) = data;
        elseif isstruct(data)
            LAN.data{1}(end+1,:) = data.data';
        end
    end
end