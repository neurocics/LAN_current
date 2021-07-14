function [pval] = stata_cluster_3d(cls, stat, nrandom,elec)
% Realiza Cluster-Randomization-Analysis en cartas timepo-frecuencia 
% por electrdo 
% recomendado primero hacer correci{on cluster por cada electrodo
% cls -> custers detectados por corrention.m , en { [cluste1] [cluster2] }
%
% P Billeke
% 9 agosto 2009
% stata = [frecuancia  x tiempo x electrodo ]
% elec = adjasencia de electrodos

[yc,xc,zc] = size(stat);

if xc == 32 %min([yc,xc,zc])
    for x = 1:xc
        r(:,:,xc) = stat(:,xc,:);
    end

stat = r;
clear r;
end

if nargin < 4
    ele = size(stat,3);
    uno = ['load '  'elec_adj' num2str(ele)];
    warning('No se indico matriz de adjasencia, se buscara por defecto'); 
    try
     eval(uno);
     disp('Se trabajara con matriz de adjasencia de:');
     disp(elec.coment);
     elecd = elec.adj;
     clear elec;
     elec = elecd;
    clear elecd;
    catch
        error('No se encuentra matriz de adjasencia');
    end
end

nelec = size(stat,3); % numero de electrodos 

for ncl = 1:length(cls) % ciclo por cluster

por = fix(ncl*100/length(cls));
por = ['calculando ... ' num2str(por) '% con ' num2str(nrandom) ' randomizaciones'];
clc;
%disp(['electrodo ' num2str(elec) ]);
disp(por);
cluster = cls{ncl};
lim = sum(sum(sum(cluster)));
% solo analizar claster mayores a dos
    if lim <= 2
        pval(ncl) = 9; % no calculado
        continue
    end
    tval = sum(sum(sum((cluster.*stat))));
    cluster = reduce_3d(cluster);
    
    y = (size(stat,1));%-(size(cluster,1)));
    x = (size(stat,2));%-(size(cluster,2)));
    
    %--------------------------
    %-Random cluster-----------
    
    %-- electrodos
     rt = size(cluster,3);	% numero de el??ectrodos del cluster
     
     for ran = 1:nrandom
	r = random('unid',nelec);	% ran electrodo inicial
	elec_ran(1) = r; 
	elec_ran = search_elec(r,rt,elec,elec_ran);
	
	w=1;
	tval_ran(ran) = 0; 
	for cada_e = elec_ran
	  %---- tiempo frecuencias
	  %clusterp = reduce(cluster(:,:,));
	  %yr = random('unid',y);
	  %xr = random('unid',x);
	  mat = zeros(y,x);
	  mat(:,:) = cluster(:,:,w);
	  tval_ran(ran) = sum(sum(mat .* stat(:,:,cada_e))) + tval_ran(ran) ;
	  w+1;
	end
	end
	%--------------------------
	nm = sum(tval_ran < tval); 
	% valores menores (mas significativos) por wilcoxon
	pval(ncl) = nm/nrandom;
	
    end
end

%---- subrutina
function a = reduce_3d(cluster)
el = size(cluster,3);
d = 1;
for ele = 1:el % loop elec
      % ----- eliminar electrodos sin significancia
      if any(any(cluster(:,:,ele)))
	a(:,:,d) = cluster(:,:,ele);
	d = d +1;
      end
end % loop de elec
end


%--- subrutina para armar grupos de electrodos random adjasentes
                                           
function [elec_ran] = search_elec(r,rt,elec,elec_ran)
i = length(elec_ran);
xx = elec{r};
lar = length(xx);
p = 0;
while p <= xx
  %for zi = elec{r} %busqueda en eje z por adjasencia
      z = elec{r};
      zi = z(random('unid',lar));
      if i == rt, return, end
          if  sum(zi == elec_ran) == 0 % si no esta el electrodo
            i = i + 1;
            elec_ran(i) = zi;
                    try
                    elec_ran  = search_elec(zi,rt,elec,elec_ran);
                    end
          end
 end
      
  %end
end
