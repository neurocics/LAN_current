function idx = label2idx_elec(chanlocs,label)
%   <*LAN)<Toolbox
%
%   LABEL2IDX_ELEC find the index of the label electrode
%   idx = label2idx_elec(chanlocs,label)
%
%   v.0.0.2
%   Pablo Billeke

%  19.12.2012
%  13.07.2011


if ischar(label)
    %
    for e = 1:length(chanlocs)
        le = chanlocs(e).labels;
        le(double(le)<32) = [];
        if strcmp(label,chanlocs(e).labels)
            idx = e;
            return
        end
    end
    %
elseif iscell(label)&&ischar(label{1})
    idx = zeros(size(label));
    for i = 1:length(label)
        for e = 1:length(chanlocs)
            if strcmp(label{i},chanlocs(e).labels)
                idx(i) = e;
                break
            end
        end
    end
    
else
    error('eletrode label error')
end






end