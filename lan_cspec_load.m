function cspec = lan_cspec_load(LAN,chan,trial)
% IMPORTANT
% this script's purpose is to provide a single smoothed and normalized
% spectrogram, regardless of the output format (LAN.freq.powspctrm)
%
% chan : a SINGLE channel indicator
% trial : a SINGLE trial indicator
% cspec : smoothed and normalized SINGLE spectrogram

if nargin < 3
    trial = 1;
end

cspec = [];
if isfield(LAN, 'freq') && all(isfield(LAN.freq, {'chan','powspctrm', 'time'}))
    ind = find(LAN.freq.chan == chan);
    if ~isempty(ind)
        if isnumeric(LAN.freq.powspctrm) || iscell(LAN.freq.powspctrm)
            cspec = LAN.freq.powspctrm;
        else
            if numel(LAN.freq.powspctrm>1)
                fullpath = cat(2, LAN.freq.powspctrm(ind).path, filesep,...
                    LAN.freq.powspctrm(ind).filename);
            else
                fullpath = cat(2, LAN.freq.powspctrm.path, filesep,...
                    LAN.freq.powspctrm.filename);
            end
            load(fullpath, 'cspec');
        end
        if iscell(cspec)
            cspec = cspec{trial};
        end
        
        if ndims(cspec)==3
            cspec = squeeze(cspec(ind,:,:));
        end
        cspec = abs(cspec.*conj(cspec));
        
        % pad
        nanspec = nan(size(cspec,1),LAN.pnts(trial));
        ind = ceil(LAN.freq.time * LAN.srate);
        nanspec(:,ind) = cspec;
        cspec = nanspec;
        
        % smoothing
        cspec = lan_smooth2d(cspec, 4, .4, 3);
        % normalization
        cspec = normal_z(cspec, cspec(:,LAN.selected{trial}));
    end
end