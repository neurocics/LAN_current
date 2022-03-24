function EEG = insert(EEG, b , c)
% b = latency of de eventes in secoinds e.g. [112 234 454] 
% c = type of events e.g. 10
if ~isempty(b)
    for i = b
    EEG = pop_editeventvals( EEG, 'insert',{1,[],[],[]}, 'changefield',{1, 'type', c}, 'changefield',{1, 'latency', i}, 'changefield',{1, 'duration',(1/EEG.srate)});
    EEG = eeg_checkset( EEG );
end
end