function  LAN = erplab2lan(file,setfile)
% <°LAN)<] toolbox
% v.0.1
% load .erp file (ERPLAB) with the corresponding .set file (EEGLAB)
% file     = name (and path) of .erp file [ 'file.erp' ]
% setfile  = name (and path) of .set file [ 'file.set' ] 
%
% Pablo Billeke

% 29.08.2013


load(file,'-mat');

if nargin==1
    setfile = ERP.workfiles{1};
end

try
    LAN = pop_loadset_lan(setfile);
catch
    disp(['file ' ERP.workfiles{1} ' not found in current directory'])
    LAN = pop_loadset_lan();
end

if ~isempty(LAN)
    disp('getting trials ..')
    
    % conditions
    nbin = ERP.EVENTLIST.nbin;
    ttime = LAN.xmax-LAN.xmin;
    for bin = 1:nbin
        tbin = ifcellis({ERP.EVENTLIST.eventinfo.binlabel},['B' num2str(bin)  ''],'c');   
        tbin =  cell2mat({ERP.EVENTLIST.eventinfo(logical(tbin)).time}); 
        tbin = fix(tbin./ttime)+1;
        conditions.name{bin}=['B' num2str(bin)  ''];
        paso = false(1,LAN.trials);
        paso(tbin) = true;
        conditions.ind{bin} = paso;
    end
    LAN.cond='Continuo';
   
    % get data
    LAN = eeglab2lan(LAN,1);
    LAN.conditions = conditions;
    
    %rejected trials
    %if isfield(LAN.rej)
    
else
    warning('no trials for extraction')
LAN = ERP;

ind = zeros(1,size(ERP.bindata,3));

for c = 1:size(ERP.bindata,3)
LAN.data{c} =  ERP.bindata(:,:,c);
LAN.conditions.name{c} = [ 'Bin ' num2str(c) ];
paso = ind;
paso(c) = 1;
LAN.conditions.ind{c} = paso;
end
end





LAN = lan_check(LAN);

