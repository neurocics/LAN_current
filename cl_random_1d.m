function [hhc pvalc cluster] = cl_random_1d(hh,stat,alpha,nrandom) 
% v.0.0.0
%
%
%
%
%
%

    disp('Making Multiple Comparision correction')
    hhc = zeros(size(hh));
    cluster = hhc;
    nbchan = size(hh,1);
    pvalc=[];
for e = 1:nbchan
   %e
clusig = bwlabel(hh(e,:),4);
ccont=0;
for cc = 1:max(clusig)
   lc = sum(clusig==cc);
   for r = 1:nrandom
       %p = [];
       %st=[];
       p = rand * (length(hh)-(lc));
       p = fix(p+1);
       st = zeros(1,length(hh));
       st(p:p+(lc-1)) = 1;
       st = st .* stat(e,:);
       stran(r) = sum(st);
   end
   streal = zeros(1,length(hh));
   streal(clusig==cc) = 1;
   streal = streal .* stat(e,:);
   pval = sum(sum(streal) <= stran)/nrandom;
   
   if pval < alpha
       ccont = 1 + ccont;
       hhp = zeros(1,length(hh));
       %pvalp = zeros(1,length(hh));
      hhp(clusig==cc)=1;
      hhc(e,:) = hhc(e,:) + hhp;
      pvalc(e,clusig==cc) = pval;
      cluster(e,clusig==cc) = ccont;
   end
   
end
 disp(['electrode n= ' num2str(e) ' encontre ' num2str(ccont) ' de ' num2str([max(clusig)]) ]);
end

%%%

if exist('chanlocs','var')  && isfield(chanlocs,'electrodemat')
   
    %%%MAKE NEW 3D ARRAY
    for e = 1:nbchan
        [y x] = find(electrodemat==e);
        newhh(y,x,:) = hhc(e,:);
        newstat(y,x,:) = stat(e,:);
        %%% MARK THE NO-ELECTRODE POSITION
        if e ==nbchan
          [y x] = find(isnan(electrodemat));
          no_e = zeros(size(newhh));
          for noe = 1:length(y)
              no_e(y(noe),x(noe),:) =2;
          end
        end
    end% for e
    
    %SEARCH ADJACENTIA
    ccont = 0;
    clusig = bwlabeln(newhh);% 
    cluster = zeros(size(clusig));
    hhp = zeros(size(newhh));
    pvalp = zeros(size(newhh));
    fin_nc = max(max(max(clusig)));
    for nc = 1:fin_nc 
        
        %disp(['evaluando cluster ' num2str(nc) ]);
        paso = zeros(size(newhh));
        paso(clusig==nc) =1;
        %%%%
        if sum(sum(sum(paso)))<=5;
            disp('rejected') 
            continue
        end
        
        pasoR = reduce(paso);
        [ym xm zm] = size(paso);
        [y x z] = size(pasoR);
        cuantos_e = sum(sum(any(pasoR,3)));       % colapso el tiempo
        [donde_ey donde_ex] = find(any(pasoR,3)); % colapso el tiempo
        nr =1;
        disp(['evaluating cluster ' num2str(nc) ' of ' num2str(fin_nc) '(' num2str(cuantos_e)   ' electrodes)' ]);
               nn=0;
        while  nr <= nrandom
            % seed for random cluster
            zr = fix(rand * (zm-z))+1;
            rancluster = zeros(size(newstat));
            
             re = randperm(nbchan);
             re = re(1:cuantos_e);
            
             for ee = 1:cuantos_e
             [yr xr] = find(electrodemat==re(ee));
             rancluster(yr,xr,1)=1;
             end
             comp = bwlabeln(rancluster(:,:,1));
            

           

           [yr xr] =  find(comp==1);
            for ee = 1:size(yr,1)
                rancluster(yr(ee),xr(ee),:) = 0;
                rancluster(yr(ee),xr(ee),zr:(zr+z-1)) = pasoR(donde_ey(ee),donde_ex(ee),:);
            end
           
            s_perrandom(nr) = sum(sum(sum(newstat.*rancluster)));
            nr = nr +1;
            
               

        end% while nr
        %
        p_val_cc= sum(  sum(sum(sum(newstat.*paso))) < s_perrandom )/nrandom ;
        
        if p_val_cc < alpha
            ccont = 1 + ccont;
            %
            disp(['accepted with p=' num2str(p_val_cc)  ])
            %
            hhp(clusig==nc)=1;
            pvalp(clusig==nc) = p_val_cc;
            %
            cluster(clusig==nc) = ccont;
            %
        else
           disp('rejected') 
        end
    end% for nc
    
%%% combert newhh to hh
   for e = 1:GLAN.nbchan
        [y x] = find(electrodemat==e);
        hhcc(e,:)=hhp(y,x,:);
        pvalcc(e,:)=pvalp(y,x,:);
        ccluster(e,:) = cluster(y,x,:);
   end% for e 
    
    hhc = hhcc; 
    pvalc = pvalcc;
    cluster = ccluster;
end%%%if em==1












