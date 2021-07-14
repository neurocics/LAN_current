function [EEG, cuantos] = sound2event(EEG, channel, code, Threshold, win)
% sound2event v.2
% 3.4.2009
%
% for LAN & EEGLAB structur
% Sound 'si' or 'yes' to event
%         needed --> earasecode.m 
%                    eeglab
%
% EEG = data (EEG.data)
%           channel = 53    % channel 
%           Threshold = 2   % threshold for detection, standard deviation
%           win =           % windows in points for 'refractary' time post
%                             verbal response
%           
%  
% step one 
%     change in zeros and ones
%     eg. sig:  1 2 1 2 3 4  1 2 3 34 -34 45 0 -23 34 1 2 -1 2 0 0
%          -->  0 0 0 0 0 0  0 0 0 1   1   1 0   1  1 0 0   0 0 0 0
%  step two 
%     create cuadrate pulse (win of 4)
%     eg. sig:  1 2 1 2 3 4  1 2 3 34 -34 45 0 -23 34 1 2 -1 2 0 0
%          -->  0 0 0 0 0 0  0 0 0 1   1   1 0   1  1 0 0   0 0 0 0
%          -->  0 0 0 0 0 0  0 0 0 1   0    0 0   0 1  0 0  0 0 0 0 
%  
%  needed --> earasecode.m 

if nargin < 5, win = fix(EEG.srate/4); end
if nargin < 4, Threshold = 4; end
if nargin < 3, code = 10; end
if nargin < 2,  channel = 1; end


[col fil z] = size(EEG.data);
if col > 1
    channel = channel
elseif col == 1
    channel = 1
end

data = EEG.data(channel,:);
data = abs(data);
means = mean(data);
stds = std(data);
thd = means + (Threshold * stds);


data_c = zeros(1,length(data));

%%%% step one & two

mark = 0

for i = 1:length(data)
    if i < mark
        continue
    end
    if data(i) > thd
        data_c(i) = 1;
        mark = i + win
    %else data_c(i) = 0;
    end
end

data = data_c;
clear data_c;
cuantos = 0;

contandoRes = 0;
Res=[]
for i= 1:length(data)
    
    if data(i) == 1
        contandoRes = contandoRes + 1;
        Res(contandoRes) = i;
    end
end

cuantosRes = 0 ; 
EEG = eeg_checkset( EEG );
currcode = cell2mat({EEG.event.type});
currlate = cell2mat({EEG.event.latency});
if isfield(EEG.event, 'duration' )
    currdura = cell2mat({EEG.event.duration});
else currdura = ones(1,length(currcode))
end
for i = 1:length(Res)

currcode(i+length(EEG.event)) = code;
currlate(i+length(EEG.event)) = Res(i);
currdura(i+length(EEG.event)) = 1;
end
levent = length(currcode);
EEG.event = [];

for i=1:levent
   EEG.event(i).type    = currcode(i);
   EEG.event(i).latency = currlate(i);
   EEG.event(i).duration = currdura(i);
end


% create phatom event by eeglab scrits for sorting events
EEG = pop_editeventvals(EEG, 'insert',{1,[],[],[]}, 'changefield',{1, 'type',100}, 'changefield',{1, 'latency',1}, 'changefield',{1, 'duration',0.1});
EEG = eeg_checkset( EEG );
% erase phantom event
EEG = eraseventcodes(EEG, '>11');
%EEG.data = data;
EEG = eeg_checkset( EEG );
pop_eegplot(EEG,1,1,1); %'winlength',100);