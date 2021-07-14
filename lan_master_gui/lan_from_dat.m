function LAN = lan_from_dat()

[File, Path, ~] = uigetfile({'*.dat','DAT file';}, 'Open .dat EEG file',...
    '*.dat', 'MultiSelect', 'off');
memm = memmapfile([Path File], 'format', 'int16');

prompt = {'Enter number of channels (crucial) :', 'Enter space-separated relevant channels (empty = all) :'};
answer = inputdlg(prompt, 'Complete', 1, {'', ''});

LAN.nbchan = eval(answer{1});
W = eval(['[' answer{2} ']']);
if isempty(W)
    W = 1:LAN.nbchan;
end

for w = W
    LAN.data{1}(w,:) = memm.data(w:LAN.nbchan:end);
end

LAN.importrec.files = File;
LAN.importrec.Path = Path;