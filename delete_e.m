function EEG = delete_e(EEG, a)
% fix 21.1.2010
% a = numers of event e.g. [2 3 4 5 ]
if  ~isempty(a)
    a = sort(a,'descend');
    for i = a
    EEG = pop_editeventvals(EEG, 'delete', i);
    EEG = eeg_checkset( EEG );
    end
end