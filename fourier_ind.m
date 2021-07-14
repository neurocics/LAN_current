
function LAN = fourier_ind(LAN, Win,Point, Fre,bin,  Norm, baseline,texto,output,boot,alpha,nrandom)
% v 0.9.2
% baseline [s1 s1]: segundos limites de la linea de base
%

% 16.05.2013  fix epocas vacias o malas
% 22.12.2009
%   FALTA
%        0 --- ajustar para trial de duraci?n variable
%        0 --- ajustar linea de base 
%
%
Sig = LAN.data;
srate = LAN.srate;

if nargin == 11 && boot == 1 ,  nrandom = 200; end
if nargin == 10 && boot == 1 , alpha = 0.05; nrandom = 200; end
if nargin < 10, boot = 0; end
if nargin < 9, output = 'pow'; end
if nargin < 8, texto = plus_text(); end
if nargin < 7, baseline = []; end
if nargin < 6,  Norm = 0; end
if nargin < 5,  bin = 1; end
if nargin < 4,  Fre = [1:100]; end
if nargin < 3,  Point = 10; end
if nargin < 2,  Win = 512; end
%if nargin < 2,  epoch = [0 (1000*length(Sig{1})/srate)]; end




z = length(Sig);
cont = 0;
a = ' ';
for i = 1:50
    a = cat(2,a,'.');
end



rz=0;% ccontador de epocas procesadas
%%%%%%%%%%%%%%%%%%%%%
for i = 1:z
    if isempty(Sig{i})||(LAN.accept(i)==0)
        continue
    end
 % largo de cada epoca
 largoepoca = [LAN.time(i,1).*LAN.srate,  LAN.time(i,2).*LAN.srate];   
    
  [Rho, Phi, EjeX, EjeF] = spectrogram_lan( Sig{i}, srate, Fre, largoepoca, Win, bin, Point);
 
  EjeX=EjeX/1000;
  %if ~isempty(baseline)
  %    RhobL = spectrogram_lan(baseline{i}(:,:), srate, Fre,largolb, Win, bin, Point);
  %else
  %    RhobL = [];
  %end
%-------------
% correlacion entre frecuencias por trial
% experimental
%--------------
  try 
      cr = LAN.freq.cfg.corfr;
      notacr1 = 'Se realizan Correlatos';
      notacr2 = 'Esto es experimental aun ... ';
    
  catch
      cr=0;
  end


  if cr == 1
      for ncor = 1:length(LAN.nbchan)
      fr1 = LAN.freq.cfg.corfr1{ncor};
      fr1 = fr1 - (LAN.freq.cfg.rang(1) -1 );
      fr2 = LAN.freq.cfg.corfr2{ncor};
      fr2 = fr2 - (LAN.freq.cfg.rang(1) -1 );
      %------
      for c = 1:LAN.nbchan
      co1(:,1) = squeeze(mean(mean(Nz(Rho(fr1,c,1:470)),1),2))';
      co2(:,1) = squeeze(mean(mean(Nz(Rho(fr2,c,1:470)),1),2))';
    %Xx = squeeze(mean(normal_z(DG.c.i(30:36,32,:)),1));
    %Yy = squeeze(mean(normal_z(DG.c.i(8:17,32,:)),1));
      [rcs(c),pcs(c)]=corr(co1(:,1),co2(:,1));
      end
      LAN.freq.corfre_b{ncor,i} = rcs;
      LAN.freq.corfre_p{ncor,i} = pcs;
      end
  end
%--------------
% fin correlaciones
%--------------
    % baseline
    if ~isempty(baseline)
    bl1 = find(EjeX>=baseline(1),1,'first');
    bl2 = find(EjeX>=baseline(2),1,'first');
    RhobL = Rho(:,bl1:bl2);
    else
    RhobL = [];
    end
    %Rho = normal_z(Rho);

    if Norm == 1
        if isempty(baseline)
        Rho = normal_z(Rho);
        else
        Rho = normal_z(Rho,RhobL);    
        end
    end

  % boot 
  if boot

      if i ==1
	bootindex = fix((rand(1,z)*z))+1
	bootindex(bootindex>z)=z;  % elitar posible index z+1
	for xi = 1:nrandom
	  bootdata{xi} = zeros(size(RhoBL));
	end
      end

      bboot = zeros(size(bootindex));
      bboot(bootindex==i) = 1;
      bboot = sum(bboot,2)
      %bootndata(bboot~=0,1) = bootndata(bboot~=0,1)+1;
      for xi = find(bboot~=0)
      bootdata{xi} = bootdata{xi} + (mean(RhoBL,3)*bboot(xi));
      end

      if i == z
	for xi = 1:length(bootdata)
	bootdata{xi} = bootdata{xi} ./ z;
	end
      end
  %bootdata(bboot~=0,2) = e................. 
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
  
  rz = rz+1;% Contadpr de epocas procesadas
  
  %pack
  clear Rho;
  clear Phi;
  clear RhobL;




  %%%%%%% only a game
  cont = cont + 1;
  porcentaje(cont) = fix(100 * cont/ z);
  %pp = [num2str(ahora) ' de ' num2str(cuantos) ' pasos '  ]

  if cont == 1 
      
      p = [num2str(porcentaje(cont)) ' % ' ];
      clc;disp_lan(texto)
      %disp(pp)
      disp(p)
      disp(a)
	  try
	      disp(notacr1),disp(notacr2)
	  end
      
  else
      if porcentaje(cont) >porcentaje(cont-1)
      p = [num2str(porcentaje(cont)) ' % ....' ];
      clc;disp_lan(texto)
      %disp(pp)
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



end%%%% for i -> lenght(Sig)
%if i == z
      Rhot = Rhot / rz;
      Phit = Phit / rz;
      RhoBL = RhoBL / rz;
%  end


 LAN.freq.phase = Phit;
 LAN.freq.cfg.type = 'Fourier-Hamming';
 if strcmp(output,'pow')
 LAN.freq.powspctrm = (Rhot.^2);
 else
 LAN.freq.powspctrm = Rhot;
 end

 LAN.freq.time  = EjeX;
 LAN.freq.freq  = EjeF;



if boot
%%%% guardar boot y hacer estadistica


end

end
