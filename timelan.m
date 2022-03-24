function T = timelan(LAN,type)
% v.0.3
if nargin == 1
    if isfield(LAN,'pnts')
        type = 'data';
    else
        type='ERP';
    end
end

switch type
    case {'data', 'd', 'Data', 'D'}
        if isfield(LAN,'accept')
            f = find(LAN.accept,1);
        else
            f=1;
        end
        T = linspace(LAN.time(f,1),LAN.time(f,2),LAN.pnts(f) );
    case 'ERP'
        if isfield(LAN,'accept')
            f = find(LAN.accept,1);
        else
            f=1;
        end
        c = find(~isemptycell(LAN.erp.data),1);
        T = linspace(LAN.time(1,1),LAN.time(1,2),length(LAN.erp.data{c}) );
end
end
