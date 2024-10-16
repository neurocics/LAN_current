function EEG = lan2eeglab(LAN)
% v.0.2
% provisorio
% para guarda en .set y hacer ica
%

% 12.12.2022

EEG = lan_check(LAN);
%EEG = LAN;


ref_field   = {
                'trials',...
                'srate',...
                'xmin',...
                'xmax',...
                'data',...
                'event',...
                'epoch'};
        





    if iscell(LAN.data)
        try
          a = LAN.data{1};
          for i = 2:length(LAN.data)
             a = cat(3,a,LAN.data{i});
             try
             EEG.event_e = LAN.event; % provisorio
             EEG.event = [];
             catch
              EEG.event = [];   
             end
          end
        catch
          a = cell2mat(LAN.data); 
          EEG.event = []; 
        end
    
    EEG = rmfield(EEG,'data');
    EEG.data = a;
    clear a;
    else
    EEG.data = LAN.data;  
    end

[ch time trial ] = size(EEG.data);
EEG.nbchan = ch;
%EEG.nchan = ch;
EEG = check(EEG,'reject');
EEG.trials = trial 
EEG = check(EEG,'chanlocs');

EEG.epoch = size(EEG.data,3),

EEG.xmin = 0;
EEG.xmax = fix(length(EEG.data)/EEG.srate);
EEG = check(EEG,'trials');
EEG = check(EEG,'icawinv');
EEG = check(EEG,'icaact');
EEG = check(EEG,'icaweights');
EEG = check(EEG,'icasphere');
EEG.pnts = length(EEG.data); % arreglar
EEG.setname = ['LAN']; 
EEG.filename = ['']; 
EEG.filepath =[''];
EEG = check(EEG,'epoch','LAN.accept');

%EEG = lan_check(EEG)  

end





function LAN1 = check(LAN, field, val)
if nargin<3
    val='[]';
end
LAN1 = LAN;
if ~isfield(LAN,field)
    uno = strrep('LAN1.%x = %y;','%x',field);
    uno = strrep(uno,'%y',val);
    eval(uno); clear uno;
end
end 
