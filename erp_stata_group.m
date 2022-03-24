function GLAN = erp_stata_group(GLAN,cfg)
%
% REALIZA ESTADISTICA NOPARAMETRICA A ERP
%
% cfg. 
%  subject = [{}{}{};{}{}{}]
%  comp 	= 1;  	% INDEX OF THE CONDITION TO COMPARED , ONLY TWO!!!
%  alpha 	=0.05;
%  s		='d'; OR ='i' 	% RELATIONSHEAP TO THE SAMPLES 'i'NDEPENDENT OR 'd'EPENDET
%  bl		=[ 0 0.4];	% BASELINE
%  mcp      = 1 or 0
%  nrandom  = 2000
%  
%  Pablo Billeke
%  Rodrigo Henriquez
%  Francisco Zamorano
%
%  v.0.0.3
%  
%  07.05.2010 (PB)
%  22.04.2010 (PB RH FZ) 
 


%SEARCH COMPARATION
if isfield(GLAN.erp,'comp') && ~isempty('comp')
      nbcomp=size(GLAN.comp,2)+1;
else
      nbcomp=1;
end 




% search subject name

try 
sujetos = cfg.subject;
GLAN.suject=sujetos;
catch
try
    sujetos = GLAN.subject;
catch
error('you must defined subject name in cfg.subject')
end
end
%search condition index

try
cond = cfg.comp;
GLAN.erp.comp{nbcomp}=cond;
catch
    try
    nbcomp = nbcomp -1;
    cond = GLAN.comp{nbcomp}
    disp('we compared the last contition in GLAN.comp, which would repite a realizad coparation')
    catch
    error('you must defined index of condition to compared');
    end
end

%serach electrode localization
try
    GLAN.chanlocs = cfg.chanlocs
end




%search relation to samples
try
m = cfg.s;
GLAN.erp.cfg.s{nbcomp} = m;
catch
    try
m = GLAN.erp.cfg.s{nbcomp};
catch
m = 'i'
GLAN.erp.cfg.s{nbcomp} = m;
disp('you don'' defined the relatioship to the samples, so  we used statistic for Independent samples');
    end
end



%search relation to samples
try
alpha = cfg.alpha;
GLAN.erp.cfg.alpha{nbcomp} = alpha;
catch
    try
alpha = GLAN.erp.cfg.alpha{nbcomp};
catch
alpha = 0.05;
GLAN.erp.cfg.alpha{nbcomp} = alpha;
disp('you don'' defined the alpha, so  we used 0,05 ');
    end
end

%search baseline
try
bl = cfg.bl;
GLAN.erp.cfg.bl{nbcomp} = bl;
catch
    try
bl = GLAN.erp.cfg.bl{nbcomp-1};
catch
bl= 0;
GLAN.erp.cfg.bl{nbcomp} = bl;
disp('you don'' defined the baseline ''cgf.bl = [ s_1 s_2]'' ] ');
    end
end

% SEARCH STATISTICAL CONFIGURATIONS
try
    mcp = cfg.mcp;
catch
    mcp=0;
    disp('I''ll not made correction for multiple comparition')
end

if mcp ==1
try
    nrandom = cfg.nrandom;
catch
    nrandom = 2000;

end
end
%
% BEGINING OF THE COMPUTATIONS
%
%


% LOAD THE SUJECT'S MAT FILE
% 

for g = cond % por gupos
    
for s = 1:length(sujetos)
    
    if isempty(sujetos{g,s})
       disp([ num2str(s-1) 'readed suject condition ' num2str(g)  ]); 
       break
    end
    
eval(['load ' sujetos{g,s} ' ']);
eval(['LAN = ' sujetos{g,s} ';' ]);
LAN = lan_check(LAN);
    
%
% EXTRATC DATA FOR LAN SIMPLE STRUCTURS

    for c = nbcomp:length(LAN) %cond

        for e = 1:LAN{c}.nbchan
            v_erp{g,c}(e,:,s) = erp_lan(LAN{c},e,bl,0);
        end
        if s == 1  %%% KEEP SPEFIFICATION FOR DEL GLAN STRUCTUR
                GLAN.time = LAN{c}.time(1,:);    
                GLAN.srate = LAN{c}.srate; 
                GLAN.nbchan = LAN{c}.nbchan;
                nbchan = GLAN.nbchan;
                try
                       GLAN.chanlocs = GLAN{c}.chanlocs
                    catch
                        disp('There is not channel location file')
                    end
        end
    end
    eval(['clear ' sujetos{g,s} ' ']);
    
end
end % end group
%
% STATISTICAL COMPUTATIONS


for c = nbcomp:length(LAN)% por condiciones

[pval, hh, stat] = nonparametric(v_erp{cond(1),c},v_erp{cond(2),c},alpha,m,0);

%
% SAVE RESULTS IN GLAN GROUPAL STRUCTURE

GLAN.erp.cond{nbcomp,c} = LAN{c}.cond;
GLAN.erp.cond{nbcomp,c} = LAN{c}.cond;

GLAN.erp.comp{nbcomp} = cond;

GLAN.erp.pval{nbcomp,c} = pval;
GLAN.erp.hh{nbcomp,c} = hh;
GLAN.erp.stat{nbcomp,c} = stat;

%GLAN.erp.fun_stat{nbcomp} = ['non-paramtric for ' m ' samples']; %% aca se cae 


GLAN.erp.data{cond(1),c} =  mean(v_erp{cond(1),c},3);
GLAN.erp.data{cond(2),c} =  mean(v_erp{cond(2),c},3);


%%%
%      MULTIPLE COMPARISON CORRECTION FOR ELECTRODES
%
if mcp == 1
    disp('Making Multiple Comparision correction')
    hhc = zeros(size(hh));
    %nbchan
for e = 1:GLAN.nbchan
   %e
clusig = bwlabel(hh(e,:),4);
ccont=0;
for cc = 1:max(clusig)
   lc = sum(clusig==cc);
   for r = 1:nrandom
       p = [];
       st=[];
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
   pval = sum(sum(streal) > stran)/nrandom;
   
   if pval < alpha
       ccont = 1 + ccont;
       hhp = zeros(1,length(hh));
       pvalp = zeros(1,length(hh));
      hhp(clusig==cc)=1;
      hhc(e,:) = hhc(e,:) + hhp;
      pvalc(e,clusig==cc) = pval;
   end
   
    end
 disp(['electrode n= ' num2str(e) ' encontre ' num2str(ccont) ' de ' num2str([max(clusig)]) ]);
end
%%%%%%% MULTIPLE COMPARISONS CORRECTION FOR ELECTRODE CLUSTERS
try 
        electrodemat = GLAN.chanlocs(1).electrodemat
        em=1;
    catch
            disp('You must spicify the electrode array')
            em=0;
end
%%%
if em==1
    %MAKE NEW 3D ARRAY
    for e = 1:nbchan
        [y x] = find(electrodemat==e);
        newhh(y,x,:) = hhc(e,:);
        newstat(y,x,:) = stat(e,:);
        %%% MARK THE NO-ELECTRODE POSITION
        if e ==nbchan
          [y x] = find(electrodemat==e);
          no_e = zeros(size(newhh))
          for noe = 1:length(y)
              no_e(y(noe),x(noe),:) =2;
          end
        end
    end% for e
    
    %SEARCH ADJACENTIA
    clusig = bwlabeln(newhh,8);% we use 8-conected clusters
    hhp = zeros(size(newhh));
    pvalp = zeros(size(newhh));
    for nc = 1:max(max(max(clusig)));
        disp(['evaluando cluster ' num2str(nc) ]);
        paso = zeros(size(newhh));
        paso(clusig==nc) =1;
        pasoR = reduce(paso);
        [ym xm zm] = size(paso);
        [y x z] = size(pasoR);
        cuantos_e = sum(sum(any(pasoR,3)));% colapso el tiempo
        [donde_ex donde_ey] = find(any(pasoR,3))% colapso el tiempo
        nr =1;
        while  nr <= nrandom
            zr = fix(rand * (zm-z))+1;
            %xr = rand * (xm-x)+1; 
            yr = fix(rand * (ym-1))+1; 
            xr = fix(rand * (xm-1))+1;
            %
            rancluster = zeros(size(newstata));
            nelec = 1
            while nelec <= cuantos_e
                %try    
                    %rancluster(yr:(yr+y-1),xr:(xr+x-1),zr:(zr+z-1)) = pasoR;
                    rancluster(yr,xr,zr:(zr+z-1)) = ...
                               pasoR(donde_ex(nelec),donde_ey(nelec),:);
                    usado(1,nelec) = yr;
                    usado(2,nelec) = xr;
                    si=0;
                    while si == 0;
                        yrp = yr + fix( (rand *2) -1);
                        xrp = xr + fix( (rand *2) -1);
                        %% para no ocupar lugares sin electrodos
                        if yrp<=ym && xrp<= xm
                        if ( sum(yrp~=usado(1,:)) && sum(xrp~=usado(2,:)) ) && (  ~isnan(electrodemat(yrp,xrp))   )
                            yr = yrp;
                            xr = xrp;
                            si =1;
                        end 
                        end
                    end
                %catch
                %    si=0;
                %    while si == 0;
                %        yrp = yr + fix( (rand *2) -1);
                %        xrp = xr + fix( (rand *2) -1);
                %        if ( sum(yrp==usado(1,:)) || sum(xrp==usado(2,:)) ) && ((yrp<=ym) && (xrp<=xm) )
                %            yr = yrp;
                %            xr = xrp;
                %            si =1;
                %        end 
                %    end
                %
                %end
            end
            %
            comprobador = max(max(max(rancluster+no_e)));
            %
                if comprobador<3 % eviatr cluster fuera de lso electrodos
                    s_perrandom(nr) = sum(sum(sum(newstata*rancluster)));
                    %
                    nr = nr +1;
                end
        end% while nr
        %
        p_val_cc= sum(  sum(sum(sum(newstata*paso))) > s_perrandom )/nrandom
        
        if p_val_cc < alpha
            %ccont = 1 + ccont;
            %
            disp('accepted')
            %
            hhp(clusig==nc)=1;
            pvalp(clusig==nc) = p_val_cc;
            %
            %
            %
        else
           disp('rejected') 
        end
    end% for nc
    
%%% combert newhh to hh
   for e = 1:nbchan
        [y x] = find(electrodemat==e);
        hhcc(e,:)=hhp(y,x,:);
        pvalcc(e,:)=pvalp(y,x,:);
        
   end% for e 
    hhc = hhcc;
    pvalc = pvalcc;
end%%%if em==1

%%%%%%%

GLAN.erp.hhc{nbcomp,c}=hhc;
GLAN.erp.pvalc{nbcomp,c}=pvalc;
end

end
%%%
end%%% END OF THE FUNCTION
%%%

%%%
%%%
%%%

%SUBRUTINA FOR REDUCE CLUSTER ONLY A MATRIZ OF SIGNIFICAN AREAS
function cluster = reduce(cluster,dir)
% cluster 3d mat


if nargin < 2, dir=7; end
%------------------
if (dir == 1) || (dir == 7)
    if ~any(any((cluster(1,:,:))))
        cluster = cluster(2:size(cluster,1),:,:);
        cluster = reduce(cluster,1);
    end    
end
%-------------------
if (dir == 2) || (dir == 7)
    if ~any(any(any(cluster(size(cluster,1),:,:))))
        cluster = cluster(1:(size(cluster,1)-1),:,:);
        cluster = reduce(cluster,2);
    end
end
%-------------------
%-------------------
if (dir == 3) || (dir == 7)
        %~any(cluster(:,size(cluster,2)),1)
    if ~any(any(any(cluster(:,size(cluster,2),:))))
        cluster = cluster(:,1:(size(cluster,2)-1),:);
        cluster = reduce(cluster,3);
    end
end
%-------------------
if (dir == 4) || (dir == 7)
    %~any(cluster(:,1),1)
    if ~any(any(any(cluster(:,1,:))))
        cluster = cluster(:,2:(size(cluster,2)),:);
        cluster = reduce(cluster,4);
    end
end
%-------------------
%-------------------
if (dir == 5) || (dir == 7)
        %~any(cluster(:,size(cluster,2)),1)
    if ~any(any(any(cluster(:,:,size(cluster,3)))))
        cluster = cluster(:,:,1:(size(cluster,3)-1));
        cluster = reduce(cluster,5);
    end
end
%-------------------
if (dir == 6) || (dir == 7)
    %~any(cluster(:,1),1)
    if ~any(any(any(cluster(:,:,1))))
        cluster = cluster(:,:,2:(size(cluster,2)));
        cluster = reduce(cluster,6);
    end
end
%-------------------



end






