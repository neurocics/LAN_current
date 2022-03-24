function [stat_cra] = c_r_a(hh,stat,alpha,nrandom)
% Correccion por comparaciones multiples
% a traves de  metodo de clusters y randomizacion
% descrito por Maris & Oostenveld 2007
% 
% clusters en tiempo y frecuencia, 
% aun no habilitada cluster por electrodos
%
%  hh =  matrix con los resultados de significancia estadistica 
%        1 = significante
%        0 = sin significancia 
%
%  stat = matriz con los resultados del estadistico (eg. Wilcoxon, T)
%
% P. Billeke 
% 9.Agosto.2009
%

if size(hh) ~=size(stat)
    error('hh & stat deber ser de las mismas diemnciones');
end

if nargin < 4, nrandom = 2000;end
if nargin < 3, alpha = 0.05;end

set(0,'RecursionLimit',nrandom);
[y,x,z] = size(stat);
% x electrodos
for elec = 1:x
    hh_e = squeeze(hh(:,elec,:));
    stat_e = squeeze(stat(:,elec,:));
    cls = correction(hh_e);
    pval = stata_cluster(cls, stat_e, nrandom,elec);
    cc = zeros(size(stat_e));
    for sig = find(pval < alpha)
        cc = cc + cls{sig};
    end
    stat_cra(:,elec,:) = cc;
end
set(0,'RecursionLimit',500);   