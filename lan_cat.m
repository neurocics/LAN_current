function LAN = lan_cat(LAN)
%
% function in developing, usefull to merge resting state period, 
% or opauses recording  
%

if  LAN.trials == 1
    warning('LAN data seen as a continuous recording, nothing to do')
    return
end

% "selected"  field  
newselected{1} = LAN.selected{1};
newselected{1}(end)=0; % deja el ultimo punto de tiempo no selecionado para 
                       % marcar las descontinuidades
for t = 2:LAN.trials
 newselected{t} = LAN.selected{t};
 newselected{t}(end)=0; % deja el ultimo punto de tiempo no selecionado para 
end
LAN.selected{1} = cat(2,newselected{:});



% "RT"  field  
if isfield(LAN,'RT')
    if numel(LAN.RT.laten)==LAN.trials    
       delay = (LAN.time(:,2)-LAN.time(:,1))';
       delay = cumsum(delay);
       LAN.RT.laten = LAN.RT.laten + [ 0 delay(1:end-1)];
       LAN.RT.latency = LAN.RT.laten;
    else
        error("function no availbale for two continuoes data");
    end
end

% "trials" field
LAN.trials=1;

% "DATA" field
LAN.data = {cat(2,LAN.data{:})};


LAN = lan_check(LAN);


end