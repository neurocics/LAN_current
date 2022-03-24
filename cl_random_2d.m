function [hhc pvalc cluster] = cl_random_2d(hh,stat,alpha,nrandom,limc) 
% v.0.0.5
%
%      Correcciones multiples por permutacion de clusters
%      Inspitado en Maris & Oostenveld (2007), pero es solo una
%      aproximacion !!! 
%      
%
% Pablo Billeke
%

% 15.05.2013 (PB)  improve whe there are NaNs
% 03.02.2012 (PB)  improve the algoritm
% 15.03.2011 (PB)  addmin of bin for cluster, default 30
% 14.08.2010 (PB)  FIX pvalc.
% 05.07.2010 (PB)  FIX, acepta cartas TF con elementos NaN 
%                            (nonpamametric v.0.0.5)

%%%
if nargin < 5
    limc = 30;
end

if ~any(hh(:)==1)
    hhc=hh;
    pvalc = ones(size(hh));
    cluster = [];
    return
end

[d1 d2 d3] =size(hh);

if d3 ==1 && (d2>2)%3 ==1 && (d1>1 && d2>2)
    hh = permute(hh,[1,3,2]);
    stat = permute(stat,[1,3,2]);
end

disp('Making Multiple Comparision correction')
        hhc = zeros(size(hh));
        pvalc = ones(size(hh));
        cluster = hhc;
        nbchan = size(hh,2);
        
        
for e = 1:nbchan
    %timenonan = find(squeeze(~isnan( sum(stat(:,e,:),1))));
    %timenonan
       %e
    clusig = bwlabeln(squeeze(hh(:,e,:)),4);
    ccont=0;
    if isempty(clusig)
        continue
    end
    strealt = [];
    for cc = 1:max(max(clusig))
       paso = zeros(size(clusig)); 
       paso(clusig==cc)=1;
        if sum(sum(sum(paso)))<=limc
            continue
        end
       pasoR=reduce(paso);
       %%
       lc_f = size(pasoR,1);
       l_f = size(paso,1);
       lc_t = size(pasoR,2);
       l_t = size(paso,2);
       %%
       streal = zeros(size(paso));
       streal(clusig==cc) = 1;
       % 
       strealt(cc) = nansum(nansum(nansum(streal .* squeeze(stat(:,e,:)),3),2),1); % suma del estadisrtico
    end
    
    
    if isempty(strealt)
            continue
    end

    
    
      [ strealref cci ] = max(strealt);
      
      
      %cc = cci
      %for cc = 1:max(max(clusig))
       paso = zeros(size(clusig)); 
       paso(clusig==cci)=1;
      %  if sum(sum(sum(paso)))<=limc
      %      continue
      % end
       pasoR=reduce(paso);
       %%
       lc_f = size(pasoR,1);
       l_f = size(paso,1);
       lc_t = size(pasoR,2);
       l_t = size(paso,2);
       r = 0;
       while r <= nrandom
           pt = [];
           pf = [];
           st= [];
           pf = rand * (l_f-lc_f);
           pf = fix(pf+1);
           pt = rand * (l_t-lc_t);
           pt = fix(pt+1);
           %
           st = zeros(size(paso));
           st(pf:pf+(lc_f-1),pt:pt+(lc_t-1)) = pasoR;
           if sum(isnan(stat(logical(st(:)))))==0;
           paso2 = stat;
           paso2(isnan(stat(:))) = 0;
           st = st .* squeeze(paso2(:,e,:));%%%%%%%%%%
           r = r +1;
           stran(r) = sum(sum(st));
           end
       end
       %%%
       
       for cc = 1:max(max(clusig))
       paso = zeros(size(clusig)); 
       paso(clusig==cc)=1;
        if sum(sum(sum(paso)))<=limc
            continue
        end
        
       %streal = zeros(size(paso));
       %streal(clusig==cc) = 1;
       pval = sum(strealt(cc) <= stran)/nrandom;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       %%%
       if pval < alpha
          ccont = 1 + ccont;
          hhp = zeros(size(paso));
          
          pvalp = zeros(size(pvalc));
          hhp(clusig==cc)=1;
          pvalp(:,e,:)=hhp; % para el indice
          pvalc(pvalp==1) = pval;

          hhc(:,e,:) = squeeze(hhc(:,e,:)) + hhp;
          %pvalc(clusig==cc,e,timenonan)=pval;
          
          %%%
          %hhc(clusig==cc,e,timenonan)=1;
          %cluster(clusig==cc,e,timenonan)=ccont;
       else
          hhp = zeros(size(paso));
          %pasop=zeros(size());
          pvalp = zeros(size(pvalc));
          hhp(clusig==cc)=1;
          pvalp(:,e,:)=hhp; % para el indice
          pvalc(pvalp==1) = pval;
          %hhc(:,e,timenonan) = squeeze(hhc(:,e,timenonan)) + hhp;
          %pvalp(clusig==cc)=pval;
          % + squeeze(pvalc(:,e,timenonan)) ;
          %%%
          %hhp(clusig==cc)=ccont;
          %cluster(:,e,timenonan) = hhp;
       end

       end

    %pvalc(:,e,timenonan) = pvalp;
    %cluster(:,e,timenonan) = hhp;
    
     disp(['electrode n= ' num2str(e) ' encontre ' num2str(ccont) ' de ' num2str(max(max(clusig))) ]);
end% for e

end


%%%%%
%%%%%
%%%%%



function cluster = reduce(cluster,dir)
% cluster 2d mat v.2
if nargin < 2, dir=0; end
%------------------
if (dir == 1) || (dir == 0)
    m = sum(cluster,2);
    if sum(m~=0)>0
    cluster = cluster(m~=0,:);
    end 
end
%-------------------
%-------------------
%-------------------
if (dir == 2) || (dir == 0)
    m = sum(cluster,1);
    if sum(m~=0)>0
    cluster = cluster(:,m~=0);
    end
end
%-------------------
%-------------------

end

