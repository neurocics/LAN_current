function EEG = eraseventcodes(EEG, expression)
% Deletes all event codes that match with expression
% (to deal with biosemi when your using 8 bits trigger...
% and some weird codes appear...or whatever else)
%
% expresion has to be someting like this:
% '==1'  or '>255' or '~41'
% Example:
% EEG = eraseventcodes(EEG, '==0')   % erase all 0 event codes
%
% Author:  Javier Lopez-Calderon
% Luck Lab
% Center for Mind & Brain
% University of California, Davis
% javlopez@ucdavis.edu

if nargin < 1
   help eraseventcodes
   return
end

if isempty(EEG.data)
   disp('eraseventcodes error: cannot work with an empty dataset')
   return
end

if ~isempty(EEG.epoch)
   disp('eraseventcodes error: Only for continuous data!')
   return
end

%[numchan points] = size(EEG.data);

currcode = cell2mat({EEG.event.type});
currlate = cell2mat({EEG.event.latency});
%[logic,loc]   = find(currcode>255);
[logic,loc]   = eval(['find(currcode' expression ')']);

currcode(loc) = [];
currlate(loc) = [];

levent = length(currcode);

if isfield(EEG.event, 'duration')
   currdura      = cell2mat({EEG.event.duration});
   currdura(loc) = [];
else
   currdura      = ones(1,levent);
end


levent = length(currcode);
EEG.event = [];

for i=1:levent
   EEG.event(i).type    = currcode(i);
   EEG.event(i).latency = currlate(i);
   EEG.event(i).duration = currdura(i);
end












