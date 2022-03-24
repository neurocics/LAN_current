function LAN = lan_from_trc()

[File, Path, ~] = uigetfile({'*.trc, *.TRC','TRC file';}, 'Open .trc EEG file',...
    '*.trc', 'MultiSelect', 'off');

LAN =lan_read_file([Path File],'trc');

choice = questdlg('Load coordinates (.mat) file?', ...
	'Coordinates', 'Yes','No', 'No');
if strcmp(choice, 'Yes')
    LAN = lan_add_coord(LAN);
end

choice = questdlg('Load references (.reflan) from file?', ...
	'Coordinates', 'Yes','No', 'No');
if strcmp(choice, 'Yes')
    LAN = lan_add_ref(LAN);
end
