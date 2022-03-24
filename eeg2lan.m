function LAN = eeg2lan(cfg)
%     <*LAN)<]    
%     v.0.0.2
%
%  cfg.filename
%  cfg.where
%  cfg.delbad


if nargin == 0
    [file, path] = uigetfile('*.EEG;*.eeg', 'Choose a EEG Neuroscan file -- cnt2lan()');
    delbad = 0;
elseif ischar(cfg)

%%$ compatibility with old versions

   file = cfg;
   path = '';
   delbad = 0;
elseif isstruct(cfg)
    if isfield(cfg,'filename') 
        file = cfg.filename;
    else
        error('there is not  filename')
    end
    %
    if isfield(cfg,'where') 
        path = cfg.where;
    else
        path = '';
    end
    %
    if isfield(cfg, 'delbad')
        delbad = cfg.delbad;
    else
        delbad = 0;
    end
end

EEG = pop_loadeeg_lan( file, path,  'all', 'all', 'all', 'all', 'int32');
EEG.setname='1';
EEG = eeg_checkset( EEG ); 
loog = logical(EEG.accept);
loog = find(~loog);
LAN=eeglab2lan(EEG,1);
clear EEG

if delbad
    if ~isempty(loog)
    LAN = del_epo(LAN,loog);
    end
end




