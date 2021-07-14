function ERP = erp_fieldt2lan(ERP,FT,c,g,s)



if nargin <4
    g=1;
end

if nargin <3
    c=1;
end



if nargin <5
    for ns = 1:size(FT.individual,1);
    s{ns} =  [ 'Sub_' num2str(ns)  ];
    end
end


ERP.subject{g} = s;
ERP.time = [ FT.time(1) FT.time(end)];
ERP.srate = fix(1/ abs(FT.time(2)-FT.time(1)) );
ERP.nbchan = size(FT.individual,2);
ERP.cond{g,c} = ['CON_' num2str(c)];

%
ERP.erp.compC={c};
ERP.erp.compG={g};
ERP.erp.data{g,c} = squeeze(mean(FT.individual,1));
ERP.erp.subdata{g,c} = permute(FT.individual,[ 2 3 1]);
ERP.erp.comp{1}= [ c;g];

ERP.erp.cfg.bl{1} = [];
ERP.erp.cfg.s{1} = 'd';
end