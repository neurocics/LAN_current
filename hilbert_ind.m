function LAN = hilbert_ind(LAN,  Fre,  Norm, baseline ,r_s, texto)
% v 0.0.1
% 3.12.2009
%   
% Falta optimiza memoria
%
Sig = LAN.data;
srate = LAN.srate;
%if nargin < 7, cuantos= 1; end
if nargin < 6, texto = plus_text([' Hilbert']); end
if nargin < 5, r_s = []; end
if nargin < 4, baseline = []; end
if nargin < 3,  Norm = 0; end
if nargin < 2,  Fre = [1:100]; end





z = length(Sig);
cont = 0;
a = ' ';
for i = 1:50
    a = cat(2,a,'.');
end
%%%%%%%%%%%%%%%%%%%%%
for i = 1:z
 % largo de cada epoca
 largoepoca = [LAN.time(i,1)*1000,  LAN.time(i,2)*1000];   
    
[Rho, Phi, EjeX, EjeF] = spectrogram_hilbert_lan( Sig{i}, srate, Fre, largoepoca,r_s);

if ~isempty(baseline)
    RhobL = spectrogram_hilbert_lan(baseline{i}(:,:), srate, Fre,largolb,r_s);
else
    RhobL = [];
end



    if Norm == 1
        if isempty(baseline)
        Rho = normal_z(Rho);
        else
        Rho = normal_z(Rho,RhobL);    
        end
    end

% guarda por trails
% LAN.freq.ind{i} = Rho;
% LAN.phase.ind{i} = Phi;
% LAN.freq.time.ind{i} = EjeX;
% LAN.freq.freq.ind{i} = EjeF;
%-----------------------    

if i == 1
    Rhot = Rho;
    Phit = Phi;
    RhoBL = RhobL;
else 
    Rhot = Rhot + Rho;
    Phit = Phit + Phi;
    RhoBL = RhoBL + RhobL ;   
end
clear Rho;
clear Phi;
clear RhobL;
%pack

if i == z
    Rhot = Rhot / z;
    Phit = Phit / z;
    RhoBL = RhoBL / z;
end


%%%%%%% only a game
cont = cont + 1;
porcentaje(cont) = fix(100 * cont/ z);
%pp = [num2str(ahora) ' de ' num2str(cuantos) ' pasos '  ];
if cont == 1 
    
    p = [num2str(porcentaje(cont)) ' % ' ];
    clc;
    disp_lan(texto)
    disp(p)
    disp(a)
        try
            disp(notacr1),disp(notacr2)
        end
    
else
    if porcentaje(cont) >porcentaje(cont-1)
    p = [num2str(porcentaje(cont)) ' % ....' ];
    clc;
    disp_lan(texto)
    disp(p)
    if fix(porcentaje(cont)/2) > 1
    a(fix(porcentaje(cont)/2)) = 'x';
    end
    disp(a)
        try
            disp(notacr1),disp(notacr2)
        end
    end
end
%%%%%



end
LAN.freq.cfg.type = 'Hilbert';
LAN.freq.cfg.rang = [Fre(1) Fre(length(Fre))];
LAN.freq.powspctrm = (Rhot.^2);
clear Rhot
LAN.freq.phase = Phit;
clear Phit

%LAN.phase.time.ind_m = EjeX;
LAN.freq.time = EjeX;

LAN.freq.freq = EjeF;
%LAN.phase.freq.ind_m = EjeF;
end




