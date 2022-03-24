function [hh pval] = freq_bootstrapping(freq,bl,alpha)
%
%  Calcula significacia por medio de test boostrapping de cartas de
%  tiempo/frecuencia en realcion a linea de base.
%  Test muy exigetes, solo usar con linea de base, 
%  sino no tiene mucho sentidos  
%
%
% fre=[fq_elec_time_s]
%              Carta tiempo frecuencia en matrix de tres dimenciones
%              frecuiencias x electrodos x tiempo x sujetos, 
% bl = [n n]   Limite de los puntos de la linea de base
%              si es [], hace bootstrapping en relacion 
%              a toda la carta (defecto = [])
% alpha = 0.05 valor de alpha para la estadistica
%              (defecto = 0.05)
%
% v.0.0.2
%
% Pablo Billeke
%
% 26.05.2010 (PB)
% 07.05.2010 (PB)

if nargin == 0
    edit freq_bootstrapping.m
    help freq_bootstrapping
    return
end


if nargin < 3
    alpha = 0.05;
end
if nargin < 2
    bl = [];
end

%%%
%%% numero de randomizaciones
nrandom = ((1/alpha)*2)+1; 
if nrandom < 100 ,nrandom = 100;end
%%%

if isempty(bl)
    bl = freq;
    
else 
    bl = freq(:,:,bl(1):bl(2),:);
end
  


[f e t s] = size(bl);
%mean_bt = 0;
%lim_boot_min = 0;
%lim_boot_max = 0;

order = fix((alpha/2)*t) +1; 
order2 = fix((alpha)*nrandom) +1;

for ee = 1:e % loop for electrodes
for ff = 1:f % loop for frecuences
    
mfreq = squeeze(mean(freq(ff,ee,:,:),4)); 
pp = zeros(size(mfreq));

for i =1:nrandom % permutations
boot = fix(rand(1,t) .* (t-1))+1;
boots = fix(rand(1,s) .* (s-1))+1;
mboot = sort( squeeze(mean(freq(ff,ee,boot,boots),4)) );
lim_boot_min(i) = mboot(order);
lim_boot_max(i) = mboot(t-order+1);
pp = (mfreq > lim_boot_max(i))  -   (mfreq < lim_boot_min(i)) + pp ;
mean_bt(i) = mean(mboot);
end % for i


mean_bt = sort(mean_bt);
lim_boot_min =lim_boot_min(order);
lim_boot_max =lim_boot_max(nrandom-order+1);
mean_bt = mean(mean_bt);%   /nrandom;


hh(ff,ee,:) = (mfreq<lim_boot_min)+(mfreq>lim_boot_max);
pp = ( abs(pp./nrandom) - 1 ).* -1;
pval(ff,ee,:) = pp;
end % for ee
end % for ff


end