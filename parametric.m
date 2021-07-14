function [pval, hh, stat,rval] = parametric(a,b,alpha,m,means,texto,ifv,METHOD)
%
%
% e.g --> [Wil,Wilh] =nonparametric(objetos4,controles4,0.05)
% a , b --> matrices a comparar en la ultima diemcion,  siendo esta los sujetos
%           (hasta 4 dimenciones)
% aplha --> nivel de significancia
% m --> relaci?n entre las muestras
%     -- 'i' independientes
%     -- 'd' dependiente
% means --> promedio de area
%
% Pablo Billeke
% v.0.0.8
%
% (PB)
% 04.11.2010 Cosmeticos 'texto'
% 15.10.2010 se volvio al algoritmo signrank, se agrego output rval, para
%            graficar p-val.
% 08.08.2010 cambio del algoritmo del wilcoxon para muestras independientes
%                    a wilcoxon2t  // signrank.m --> genera erroneos
%                    estadistico W.
% 24.06.2010  correcion de estadistico 0 y pval 1 duando la variaza de las
%                     nmuestar es 0 // se arreglo con fix 08.08.2010.
% 28.04.2010
% 27.04.2010
% 16.04.2010
%

if nargin < 8, METHOD = 'approximate'; end% 'exact'
if nargin < 7, ifv = 1; end
if nargin < 6, texto= plus_text(); end
if isnumeric(texto), ifv = 0; end
if nargin < 5, means=0; end
if nargin <4,m = 'i';disp('Se asume muestras independientes');end
if nargin < 3, alpha=0.05; end
if m=='i', ml = 'independientes'; else ml = 'dependientes'; end
texto = plus_text(texto,[ 't-test para muestras ' ml ]);

% the last nonsingleton dimentions is puted in the 4th dimention
%
[x,y,z,w] = size(a);
if w ==1
    if z ==1
        if y ==1
            a = permute(a,[2,3,4,1]);
            b = permute(b,[2,3,4,1]); 
        else
        a = permute(a,[1,3,4,2]);
        b = permute(b,[1,3,4,2]); 
        end
    else
    a = permute(a,[1,2,4,3]);
    b = permute(b,[1,2,4,3]);
    end
end
%a(isnan(a))=0;
%b(isnan(b))=0;

[x,y,z,w] = size(a);

if means == 0
%-------only a game-------------------%
j = ' ';                                 
for i = 1:51                        
    j = cat(2,j,'.');                 
end                                   
cont = 0 ;                          
cont_p = 0     ;  
if ~isnumeric(texto)
texto = plus_text(texto,' ');
texto = plus_text(texto,' ');
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for i = 1:x
    for ii = 1:y
        for iii = 1:z
            
            if any(isnan(sum(a(i,ii,iii,:)))) || any(isnan(sum(b(i,ii,iii,:))))
             pval(i,ii,iii) = NaN;   
             hh(i,ii,iii)  = 0; %% ojo!!!  
             stat(i,ii,iii) = NaN;   
             rval(i,ii,iii) = NaN;  
            else
                
                if m == 'i'    
                    [ hh(i,ii,iii) pval(i,ii,iii) ci stats] = ttest2(squeeze(a(i,ii,iii,:)), squeeze(b(i,ii,iii,:)),alpha );
                    stat(i,ii,iii) = stats.tstat;%ranksum;
               r =  pval(i,ii,iii);
                 if r > 0.1 , r = 0.1; end
                 if (mean(squeeze(a(i,ii,iii,:))) - mean(squeeze(b(i,ii,iii,:)))) < 0
                           r = (0.2-r);
                 end
                 rval(i,ii,iii) = r;     
                
                 %stat(i,ii,iii) = stats.ranksum;
                elseif m =='d'
              [ hh(i,ii,iii) pval(i,ii,iii) ci stats] = ttest(squeeze(a(i,ii,iii,:)),squeeze(b(i,ii,iii,:)),alpha );
                stat(i,ii,iii) = stats.tstat;%signedrank;   
               r =  pval(i,ii,iii);
                if r > 0.1 , r = 0.1; end
                if (mean(squeeze(a(i,ii,iii,:))-squeeze(b(i,ii,iii,:)))) > 0
                          r = (0.2-r);
                end
                rval(i,ii,iii) = r;  
           
                %stat(i,ii,iii) = stats.signedrank;
                %maxstat = max(max(max(max(stat))));
                %stat(pval==1) = maxstat;
                %stat = (ones(size(stat))*maxstat ) - stat;
                
               %R = wilcoxon2t(squeeze(a(i,ii,iii,:)), squeeze(b(i,ii,iii,:)));
               %pval(i,ii,iii) = R.p;
               %stat(i,ii,iii) = abs(R.W);
               %hh(i,ii,iii) = R.p < alpha;
                end
            end
        end
        cont = cont + 1;                                    %%%
        if ifv
        total = y*x;
        porcentaje(cont) =  fix(100*cont/total);
        if cont == 1 || ((cont > 1) && (porcentaje(cont) > porcentaje(cont-1)))        %%%
            p = [num2str(porcentaje(cont)) ' % procesando... ']; 
            cont_p = cont_p+1;
            if fix(cont_p/2) >= 1                           %%
            j(fix(cont_p/2)) = 'x';
            end
            clc;                                            %%%
            texto = last_text(texto,p,2);
            texto = last_text(texto,j,1);
            disp_lan(texto);                                        %%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        end
        end
    end
end

elseif means == 1
        a_m = squeeze(mean((mean(((mean(a,1))),2)),3));
        b_m = squeeze(mean((mean(((mean(b,1))),2)),3));
            
        if m == 'i'
            [pval hh stat] = ranksum(a_m,b_m,'alpha',alpha );
        elseif m == 'd'
            [pval hh stat] = signrank(a_m,b_m,'alpha',alpha ); 
           stat = stats.signedrank;
            
        end
end
%%% corregir pval=1 % stat =0;
            
            maxstat(1) = max(max(max(max(stat))));
            n = size(a,4);
            %borra = floor((n+1)/2 );
            borraa = repmat([1,2],[1,n]);borraa=borraa(1:n);
            borrab = repmat([2,1],[1,n]);borrab=borrab(1:n);
            [borra1,borra2,borra3] = signrank(borraa,borrab);
            maxstat(2) = borra3.signedrank;
            clear borra*
            maxstat = max(maxstat);
            stat(pval==1) = maxstat;
            stat = (ones(size(stat))*maxstat ) - stat;
%%%

pval = squeeze(pval);
hh = squeeze(hh);
stat = squeeze(stat);  
rval = squeeze(rval);
