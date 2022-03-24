function LAN = lan_from_ncs(merge)
% Currently assumes one channel and even sampling rate
% It also assumes all Timestamps are sorted in ascending order
% If merge = true, all it does is concatenating all "recording"

[File, Path, iii] = uigetfile({'*.ncs','NCS file'}, 'Open .ncs EEG files','*.ncs', 'MultiSelect', 'off');

ncs = read_neuralynx_ncs([Path File]);

if length(unique(ncs.SampFreq)) > 1
    disp('Warning: Uneven sampling rates');
end
if length(unique(ncs.ChanNumber)) > 1
    disp('Warning: Multiple channels');
end
if merge
    ncs.dat = ncs.dat(:);
    ncs.NRecords = 1;
end

LAN.data = cell(ncs.NRecords, 1);
for c = 1:ncs.NRecords
    LAN.data{c} = ncs.dat(:,c)';
end
LAN.trials = ncs.NRecords;
LAN.nbchan = 1;
LAN.srate = ncs.SampFreq(1);
LAN.ncshdr = ncs.hdr;

% chns = unique(ncs.ChanNumber);
% s = sum(ncs.ChanNumber==chns(1));
% for c = 2:length(chns)
%     if sum(ncs.ChanNumber==chns(c)) ~= s;
%         disp('Error: Uneven number of recording by channel');
%         err = true;
%     end
% end
% if err
%     disp('Operation failed');
% else
%     TS = zeros(length(chns), s);
%     for c = 1:length(chns); TS(c,:) = ncs.TimeStamp( ncs.ChanNumber==chns(c) ); end;
% end

LAN.importrec.files = File;
LAN.importrec.Path = Path;

end