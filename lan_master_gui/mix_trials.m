function LAN = mix_trials(LANa, LANb)

if nargin == 1
    if iscell(LANa)
        LAN = LANa{1};
        for c = 2:length(LANa)
            LAN = mix_trials(LAN, LANa{c});
        end
    end
else
    if LANa.nbchan ~= LANb.nbchan
        disp('error: All trials should have the same number of channels')
        LAN = [];
    elseif LANa.srate ~= LANb.srate
        disp('error: Both LAN structures must be sampled at the same rate')
        LAN = [];
    else
        newRT = {};
        if isfield(LANa, 'RT')
            if iscell(LANa.RT)
                newRT = LANa.RT;
            else
                newRT = {LANa.RT};
            end
            LANa = rmfield(LANa, 'RT');
        end
        if isfield(LANb, 'RT')
            if iscell(LANb.RT)
                newRT = cat(2, newRT, LANb.RT);
            else
                newRT{end+1} = LANb.RT;
            end
            LANb = rmfield(LANb, 'RT');
        end
        LAN = merge_lan(LANa, LANb);
        if ~isempty(newRT)
            LAN.RT = newRT;
        end
    end
end