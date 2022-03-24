function GLAN = erp_statad_old(GLAN,cfg)
%
% REALIZA ESTADISTICA NOPARAMETRICA A ERP
%
% cfg.
%  subject  = [{}{}{}]
%  comp 	=[n1 n2];  	% INDEX OF THE CONDITION TO COMPARED , ONLY TWO!!!
%  alpha 	=0.05;
%  m		='d'; OR ='i' 	% RELATIONSHEAP TO THE SAMPLES 'i'NDEPENDENT OR 'd'EPENDET
%  bl		=[ 0 0.4];	% BASELINE
%  mcp      = 1 or 0 (2= no progresivo)
%  nrandom  = 2000
%  stata    = 1; % TO MAKE STADISTIC, FOR DEFAULT.
%  savesub  = 0; % for save indivudal erp for sabject
%
%  OPTIONS
%
%  delelectrode = [elec_1 elec_n ... ] % ELECTRODES EXCLUIDED TO THE ANALISIS
% 
%  mat.prf  = 'str'
%  mat.sf   = 'str'
%  file.sf  = 'str'
%  file.prf = 'str'
%
%  Pablo Billeke
%  Rodrigo Henriquez
%  Francisco Zamorano
%
%  v.0.0.6   (old version of erp_stata)
%  
%  05.08.2010  (PB) opcion de prefijos y sufijos por matrices y archivos.
%                   delectrode para excluir electrodos del analisis
%  22.06.2010  (PB) gurada erp por sujeto en GLAN.erp.datasub, 
%                   si cfg.savesub=1;                
%  14.06.2010  (PB) guarda clusters en GLAN.erp.cluster{nbcomp}
%  07.05.2010  (PB)
%  22.04.2010  (PB FZ RH)

% search subject name

if nargin == 0
    edit erp_stata.m
    help erp_stata.m
    return 
end



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
%%% 
try filesf = cfg.file.sf; catch , filesf = ''; end
try fileprf = cfg.file.prf; catch , fileprf = ''; end
try matprf = cfg.mat.prf; catch , matprf=''; end
try matsf = cfg.mat.sf; catch , matsf =''; end

%
try
    savesub = cfg.savesub;
catch
    savesub=0;
end



%search condition index

if size(sujetos,1)>1
   disp('we''ll use erp_stata_group.m, see LAN manual ');
   GLAN = erp_stata_group(GLAN,cfg) ;
   return
end


% SEARCH COMPARATION
if isfield(GLAN,'erp') %&& ~isempty(GLancomp)
      nbcomp=size(GLAN.erp.comp,2)+1;
else
      nbcomp=1;
end 





try
cond = cfg.comp;
GLAN.erp.comp{nbcomp}=cond;
catch
    try
    nbcomp = nbcomp -1;
    cond = GLAN.erp.comp{nbcomp};
    disp('we compared the last contition in GLAN.comp, which would repite a realizad coparation')
    catch
    error('you must defined index of condition to compared');
    end
end

%serach electrode localization
try
    GLAN.chanlocs = cfg.chanlocs;
end



%search relation to samples
try
m = cfg.s;
GLAN.erp.cfg.s{nbcomp} = m;
catch
    try
m = GLAN.erp.cfg.s{nbcomp};
catch
m = 'd';
GLAN.erp.cfg.s{nbcomp} = m;
disp('you don'' defined the relatioship to the samples, so  we used statistic for Dependent samples');
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

%search relation between samples
try
bl = cfg.bl;
GLAN.erp.cfg.bl{nbcomp} = bl;
catch
    try
bl = GLAN.erp.cfg.bl{nbcomp-1};
catch
bl= 0;
GLAN.erp.cfg.bl{nbcomp} = bl;
disp('you don'' defined the baseline [cgf.bl] ');
    end
end

% SEARCH STATISTICAL CONFIGURATIONS
try
    ifstata = cfg.stata;
catch
    ifstata = 1;
end
%
%
try
    mcp = cfg.mcp;
catch
    mcp=0;
    disp('I''ll not made correction for multiple comparition')
end

if mcp >0
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

texto =plus_text();

% LOAD THE SUJECT'S MAT FILE
% 

for s = 1:length(sujetos)
eval(['load '  fileprf  sujetos{s}  filesf ' ']);
eval(['LAN = ' matprf   sujetos{s}  matsf ';' ]);




% elimina electrodos excluidos del analisis
    if isfield(cfg, 'delectrode') 
                 if ~isempty(cfg.delectrode)&&isfield(LAN,'chanlocs')    
                    LAN = electrode_lan(LAN, cfg.delectrode);
                    ifcc = 1;
                 elseif ~isempty(cfg.delectrode)&&~isfield(LAN,'chanlocs')
                     LAN = add_field(LAN, 'chanlocs = cfg.chanlocs');
                     %LAN.chanlocs = cfg.chanlocs; 
                     LAN = electrode_lan(LAN, cfg.delectrode);
                     ifcc = 1;
                 else
                    ifcc = 0; 
                    LAN = lan_check(LAN);
                 end
    else
            LAN = lan_check(LAN);
            ifcc = 0; 
    end
%


%
% EXTRATC DATA FOR LAN SIMPLE STRUCTURS
    texto = plus_text(texto,['load subject files ... '  ]);
    disp_lan(texto)
    for c = cond
        texto = last_text(texto,['load subject file ' sujetos{s}   ]);
        disp_lan(texto)
        for e = 1:LAN{c}.nbchan
            v_erp{c}(e,:,s) = erp_lan(LAN{c},e,bl,0);
        end
        if s == 1 %%% KEEP SPEFIFICATION FOR DEL GLAN STRUCTUR
                GLAN.time = LAN{c}.time(1,:);    
                GLAN.srate = LAN{c}.srate; 
                GLAN.nbchan = LAN{c}.nbchan;
                GLAN.cond{c} = LAN{c}.cond;
                    try
                    GLAN.chanlocs = LAN{c}.chanlocs;
                    catch
                        disp('There is not channel location file')
                    end
        end
       disp_lan(texto);
    end
    eval(['clear '  matprf  sujetos{s}  matsf ' ']);
    
end

if ifcc
GLAN.chanlocs = LAN{1}.chanlocs; 
end


%
% STATISTICAL COMPUTATIONS
if ifstata
[pval, hh, stat] = nonparametric(v_erp{cond(1)},v_erp{cond(2)},alpha,m,0,texto);
end
%
% SAVE RESULTS IN GLAN GROUPAL STRUCTURE


for c=cond
GLAN.erp.cond{c} = LAN{c}.cond;
GLAN.erp.data{c} =  mean(v_erp{c},3);
    if savesub
       GLAN.erp.subdata{c} =  v_erp{c};
    end
end

GLAN.erp.comp{nbcomp} = cond;

%
clear v_erp
%
if ~ifstata
    disp('DONE without statistic computations')
    return
end

GLAN.erp.pval{nbcomp} = pval;
GLAN.erp.hh{nbcomp} = hh;
GLAN.erp.stat{nbcomp} = stat;

%%%ARREGLOS NO NECESARIOS A PARTIR DE nonparametric.m v.0.0.7
%stat = ones(size(pval)) - pval;        %% (busca cluster segun valor b)
%stat = ones(size(pval)) * max(max(stat)) -stat;

%%%
%      MULTIPLE COMPARISON CORRECTION FOR ELECTRODES
%
if mcp > 0
    disp('Making Multiple Comparision correction')
    hhc = zeros(size(hh));
    %nbchan
    
if mcp == 1    
for e = 1:LAN{1}.nbchan
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
   pval = sum(sum(streal) < stran)/nrandom;
   
   if pval < alpha
       ccont = 1 + ccont;
       hhp = zeros(1,length(hh));
       %pvalp = zeros(1,length(hh));
      hhp(clusig==cc)=1;
      hhc(e,:) = hhc(e,:) + hhp;
      pvalc(e,clusig==cc) = pval;
   end
   
end
 disp(['electrode n= ' num2str(e) ' encontre ' num2str(ccont) ' de ' num2str([max(clusig)]) ]);
end

end
%%%%%%% MULTIPLE COMPARISONS CORRECTION FOR ELECTRODE CLUSTERS
try 
        electrodemat = GLAN.chanlocs(1).electrodemat;
        em=1;
    catch
            disp('You must specify the electrode array')
            em=0;
end

%%%
if mcp==2
    hhc = hh;
end

nbchan=GLAN.nbchan;
%%%
if em==1
   
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

%%%%%%%
try
GLAN.erp.hhc{nbcomp}=hhc;
GLAN.erp.pvalc{nbcomp}=pvalc;
GLAN.erp.cluster{nbcomp}=cluster;
catch
  texto = plus_text(texto,['without significant cluster after Multiple Comparison Correction']);
  disp_lan(texto)
end
end
%%%
end%%% END OF THE FUNCTION
%%%

%%%
%%%
%%%

% %SUBRUTINA FOR REDUCE CLUSTER ONLY A MATRIZ OF SIGNIFICAN AREAS
function cluster = reduce(cluster,dir)
% cluster 3d mat v.2
if nargin < 2, dir=0; end
%------------------
if (dir == 1) || (dir == 0)
    m = sum(sum(cluster,3),2);
    if sum(m~=0)>0
    cluster = cluster(m~=0,:,:);
    end 
end
%-------------------
%-------------------
%-------------------
if (dir == 2) || (dir == 0)
    m = sum(sum(cluster,3),1);
    if sum(m~=0)>0
    cluster = cluster(:,m~=0,:);
    end
end
%-------------------
%-------------------
%-------------------
if (dir == 3) || (dir == 0)
    m = sum(sum(cluster,2),1);
    if sum(m~=0)>0
    cluster = cluster(:,:,m~=0);
    end
end
%-------------------
%-------------------
end
