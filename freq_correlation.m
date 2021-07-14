% freq_correlation.m
% v.0.1
%-------------
% correlaciones entre frecuencias por trial
% experimental
%
% REQUIERE EN LAN.freq.cfg
%       .corfr = 1
%       .corfr1 = {f1:f2} {} ... Rangos de freciencia acorrelacionar de 
%                                         con corfr2
%       .corfr2 = {f1:f2} {} ... Rangos de freciencia acorrelacionar de 
%                                         con corfr1
%       .cortime = [t1 t2]
%
% Pablo Billeke
% 22.11.2009
%--------------
function LAN = freq_correlation(LAN,e)
if nargin<2
    e = 0;
end
if isstruct(LAN)
    LAN = freq_correlation_struct(LAN,e);
elseif iscell(LAN)
    for lan = 1:length(LAN)
    LAN{lan} = freq_correlation_struct(LAN{lan},e);
    end
end


end

function LAN = freq_correlation_struct(LAN,e)

%----------------------------------
disp('Haciendo comprobaciones')
try 
    cr = LAN.freq.cfg.corfr;
    notacr1 = 'Se realizan Correlatos';
    notacr2 = 'Esto es experimental aun ... ';
catch
    cr=0;
    disp('No se realizan correlacion, falta configurar LAN.freq.cfg')
end
try
    nbchan = LAN.nbchan;
catch
    nbchan = size(LAN.freq.ind{1},1);
    LAN = add_field(LAN,['nbchan = ' num2str(nbchan) ]);
end
    disp(['numero de canales = ' num2str(nbchan)]);
try
     trails = length(LAN.freq.ind);%trails = LAN.trails;
catch
    trails = length(LAN.freq.ind);
    LAN = add_field(LAN,['trials = ' num2str(nbchan) ]);
end    
   disp(['numero de trials = ' num2str(trails)]);
% tiempo

if e==0
    e = 1:nbchan;
end



if cr == 1
    
    
    for i =1:trails
    % 
    Rho = LAN.freq.ind{i};
    %
    time(1) = LAN.freq.cfg.cortime(1)*1000;
    x = find(LAN.freq.time.ind{i}<=time(1),1);
        if isempty(x)
            time(1) =1;
        else
            time(1) =x;
        end
    time(2) = LAN.freq.cfg.cortime(2)*1000;
    x = find(LAN.freq.time.ind{i}>=time(2),1);
        if isempty(x)
            time(2) =length(LAN.freq.time.ind{i});
        else
            time(2) =x;
        end
    clear x;
    for ncor = 1:length(LAN.freq.cfg.corfr1)% numero de correlaciones
    fr1 = LAN.freq.cfg.corfr1{ncor};
    fr1 = fr1 - (LAN.freq.cfg.rang(1) -1 );
    fr2 = LAN.freq.cfg.corfr2{ncor};
    fr2 = fr2 - (LAN.freq.cfg.rang(1) -1 );
    %------
    for c = e;
     %
    co1(:,1) = squeeze(mean(mean(normal_z(Rho(fr1,c,time(1):time(2))),1),2))';
    co2(:,1) = squeeze(mean(mean(normal_z(Rho(fr2,c,time(1):time(2))),1),2))';
   %Xx = squeeze(mean(normal_z(DG.c.i(30:36,32,:)),1));
   %Yy = squeeze(mean(normal_z(DG.c.i(8:17,32,:)),1));
    [rcs(c),pcs(c)]=corr(co1(:,1),co2(:,1));
    clear co1 co2
    end
    LAN.freq.corfre_b{ncor,i} = rcs;
    LAN.freq.corfre_p{ncor,i} = pcs;
    end
end
end
end

%--------------
% fin correlatos
%--------------