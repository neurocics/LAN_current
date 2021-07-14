function [pval] = stata_cluster(c_cls, stat, nrandom,elec)
% v.0.0.9
%
% Realiza Cluster-Randomization-Analysis en cartas timepo-frecuencia 
% en prueba por cambio de algoritmo de clusters
%
% un electrodo por ahora
% cls -> custers detectados por corrention.m , en { [cluste1] [cluster2] }
%
% P Billeke
%
%
% 9 agosto 2009
% abril 2010
%


if nargin < 4, elec = 1;end

for ncl = 1:max(max(max(c_cls))) % ciclo por cluster
cls = zeros(size(c_cls));
cls(find(c_cls==ncl)) = 1;
    
    
por = fix(ncl*100/max(max(max(c_cls))));
por = ['calculando ... ' num2str(por) '% con ' num2str(nrandom) ' randomizaciones'];
clc;
disp(['electrodo ' num2str(elec) ]);
disp(por);
cluster = cls;

lim = (sum(sum(cluster)));
    % solo analizar claster mayores a dos
    if lim <= 2
        pval(ncl) = 1;
        continue
    end
    tval = sum(sum((cluster.*stat)));
    cluster = reduce(cluster);
    
    y = ((size(stat,1))-(size(cluster,1)));
    x = ((size(stat,2))-(size(cluster,2)));
    
    %--------------------------
    %-Random cluster-------------
    
    for ran = 1:nrandom
    yr = random('unid',y);
    xr = random('unid',x);
    mat = zeros(size(stat));
    mat(yr:yr+(size(cluster,1))-1, xr:xr+(size(cluster,2))-1) = cluster(:,:);
    tval_ran(ran) = sum(sum(mat .* stat));
    end
    %--------------------------
    nm = sum(tval_ran < tval); 
    % valores menores (mas significativos) por wilcoxon
    pval(ncl) = nm/nrandom;
    
end
end

%---- subrutina
function cluster = reduce(cluster,dir)
if nargin < 2, dir=5; end
%------------------
if (dir == 1) || (dir == 5)
    if ~any(cluster(1,:),2)
        cluster = cluster(2:size(cluster,1),:);
        cluster = reduce(cluster,1);
    end    
end
%-------------------
if (dir == 2) || (dir == 5)
    if ~any(cluster(size(cluster,1),:),2)
        cluster = cluster(1:(size(cluster,1)-1),:);
        cluster = reduce(cluster,2);
    end
end
%-------------------
if (dir == 3) || (dir == 5)
    if ~any(cluster(:,size(cluster,2)),1)
        cluster = cluster(:,1:(size(cluster,2)-1));
        cluster = reduce(cluster,3);
    end
end
%-------------------
if (dir == 4) || (dir == 5)
    if ~any(cluster(:,1),1)
        cluster = cluster(:,2:(size(cluster,2)));
        cluster = reduce(cluster,4);
    end
end
end







