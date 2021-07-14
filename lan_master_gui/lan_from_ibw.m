function LAN = lan_from_ibw(Files, Path)

LAN.data{1} = [];
if nargin < 2
    [Files, Path, ~] = uigetfile({'*.ibw','IBW file';}, 'Open .ibw EEG file(s)',...
        '*.ibw', 'MultiSelect', 'on');
end

if iscell(Files)
    for c = Files
        LAN = importibw(LAN, c{1}, Path);
    end
else
    LAN = importibw(LAN, Files, Path);
end
LAN = lan_check(LAN);
LAN.importrec.files = Files;
LAN.importrec.Path = Path;

    function LAN = importibw(LAN, filename, pathname)
        IBW = IBWread([pathname filename]);
        LAN.data{1}(end+1,:) = IBW.y';
        if isfield(LAN, 'srate') && 1/IBW.dx~=LAN.srate
            warndlg('Warning. Sampling rate mismatch', 'Warning');
        end
        LAN.srate = 1/IBW.dx;
    end
end