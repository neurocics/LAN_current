function LAN = cnt2lan(cfg)
% v.0.2
% Pablo Billeke
% from EEGLAB
%
% 12.04.2016 improve RT extraction 


if nargin == 0
    [filename, filepath] = uigetfile('*.CNT;*.cnt', 'Choose a CNT file -- cnt2lan()'); 
else
    if isstruct(cfg)
        filename = getcfg(cfg,'filename');
        filepath = getcfg(cfg,'filepath','');
    elseif ischar(cfg)
        filename= cfg;
        filepath = '';
    end
    
end
paso = loadcnt_lan([filepath filename]);

LAN.data = paso.data;
LAN.nbchan  = paso.header.nchannels;
LAN.srate    = paso.header.rate;
LAN.trials   = 1;
LAN.pnts     = paso.ldnsamples ;
LAN.cond = 'Continuo' ;

%electrode loc
for e = 1:LAN.nbchan 
LAN.chanlocs(e).labels = paso.electloc(e).lab;
LAN.chanlocs(e).X = [];
LAN.chanlocs(e).Y = [];
LAN.chanlocs(e).Z = [];
end



% inport events
% -------------
 I = 1:length(paso.event);
 if ~isempty(I)
     for i = I;
     LAN.event(i).type =  [paso.event(i).stimtype ];
     LAN.event(i).latency =  paso.event(i).offset +1;
     end
     
 end;
 
 LAN = lan_check(LAN);
 % event to RT
if ~isempty(LAN.event)
LAN.RT = event2RT(LAN.event,LAN.srate,LAN.time);

    if isfield(LAN.RT.OTHER,'names')
        if ~ischar(LAN.RT.OTHER.names{1})
            LAN.RT.est = cell2mat(LAN.RT.OTHER.names);
        end
    end
end
 


if nargout == 0
prompt = {'Enter LAN structure'' name:'};
title = [ lanversion('l') ' toolbox'];
lines = 1;
def = {'LAN'};
answer = inputdlg(prompt,title,lines,def);
assignin('base',answer{1},LAN);
end

end