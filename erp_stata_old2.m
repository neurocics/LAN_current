function GLAN = erp_stata(GLAN,cfg)
%           <*LAN)<]
%           v.0.0.996
%
% REALIZA ESTADISTICA NOPARAMETRICA A ERP
%
% cfg.
%  subject  = [{}{}{}]
%  comp 	= [n1 n2];  	  % INDEX OF THE CONDITION TO COMPARED
%  matdif   = [-1 1 -2 2]  % MATRIZ DE DIFERENCIAS, DEL MISMO TAMAGNO QUE cfg.comp.
%                         % DONDE LOS 1 CORRESPONDEN AL PRIMER GRUPO, -1 EL
%                         % QUE SE VA ARRESTAS A 1, LOS MISMO PARA 2 Y -2.
%                        
%  alpha 	=0.05;
%  alphap 	=0.05; alpha for permutation test
%  m		='d'; OR ='i' 	% RELATIONSHEAP TO THE SAMPLES 'i'NDEPENDENT OR 'd'EPENDET
%  bl		=[ 0 0.4];	% BASELINE
%  mcp      = 1 or 0 
%  nrandom  = 1000
%  stata    = 1; % TO MAKE STADISTIC, FOR DEFAULT.
%  savesub  = 0; % for save indivudal erp for sabject
%  srate = ;  % chequea los srate, resamplaendo los no concordantes; (See also RESAMPLE_LAN.)
%
%
%  OPTIONS
%  bias =    0 ; para permutaciones sesgadas cuando se realiza la
%                estadistica de una diferencia
%  time     = [s s]                    % time interval where to compute statistic 
%  delelectrode = [elec_1 elec_n ... ] % ELECTRODES EXCLUIDED TO THE ANALISIS
%  
%  mcpMt = 'CBP' por defecto
%                 'CRP'                                                
%  mat.prf  = 'str'                                 special carater:
%  mat.sf   = 'str'                                      %S subjectname
%  file.sf  = 'str'                                        
%  file.prf = 'str'
%
%  Pablo Billeke
%  Rodrigo Henriquez
%  Francisco Zamorano
%
%
%
%               FALTA!!! -> arregalr las correcion por comparaciones
%               multiples en caso de estadistica independiente
%
%
% 24.06.2011 (PB) add srate option
% 19.06.2011 (PB)  fix base line; add '%S' options in mat and file
%                            descriptions
% 06.05.2011  (PB)   add cfg.time option
% 07.02.2011  (FZ)   fix bug: save individual condiction when it use compare
%                    matrix
%
% 01.02.2011  (PB)    add cfg.alphap for determinig the alpha limit using
%                     in the permutation test.
%                     fix bug: save individual condiction when it use compare matrix 
% 24.01.2011   (PB FZ)  fix bug: delelctrode 
% 20.01.2011   (PB RH)  fix bug: de las matrices de diferenia
% 11.01.2011   (PB) habilitando calculo de estadistica entre diferencias entre
%                condiciones. basados en cfg.matdif
%              (PB) cambio de algoritmo: permutacion basado en
%                 clusters
%  05.08.2010  (PB) opcion de prefijos y sufijos por matrices y archivos.
%                   delectrode para excluir electrodos del analisis
%  22.06.2010  (PB) gurada erp por sujeto en GLAN.erp.datasub, 
%                   si cfg.savesub=1;                
%  14.06.2010  (PB) guarda clusters en GLAN.erp.cluster{nbcomp}
%  07.05.2010  (PB)
%  22.04.2010  (PB FZ RH)



if nargin == 0
    edit erp_stata.m
    help erp_stata.m
    return 
end



%%%-------------------------------------
%%% GRAPHIC FUNCTION TO CONFIGURATE .CFG 
%%%-------------------------------------

if nargin == 1
    try
    donde = [... 
            {'subject' },...
            {'cond'}...   = [f1 f2] ;
            {'stata' },...
            {'statap' },...
            {'alpha' },...
            {'s' },...
            {'bl' },...
            {'mcp' },...
            {'mcpMt'},... = [ n n];
            {'savesub'},... 
            {'delectrode'},... 
            {'mat.sf'},... 
            {'mat.prf'},... 
            {'file.sf'},... 
            {'file.prf'},... 
             ];
    opciones= [... 
            {'V: '},{ 'sujetos'},{'[{''sujeto1''},{''sujeto1''}]'};...
            {'#1'},{'[1 2]'},{ '[ ]  '};... []  
            {'#2'},{'1 '},{ '0'};...
            {'#3'},{'0.05'},{ '0.01'};...
            {'#4'},{'0.05 '},{ '0.001 '};...
            {'i'},{'d'},{ '[ ] '};...
            {'#6'},{'[-1 0]'},{ '[ ]   '};...
            {'#7'},{'0 '},{ '1  '};...
            {'CBP'},{'CRP'},{ '[ ]   '};...
            {'#9'},{'1   '},{ '0  '};...
            {'#10'},{'[ 1 2 5 6 ]'},{  '  [ ] '};...
            {'str1 '},{'str1'},{ ' [  ]   '};...
            {'str2 '},{'str2'},{ '    [ ]   '};...
            {'str3 '},{'str3'},{ '  [ ]   '};...
            {'str4 '},{'str4'},{ '   [ ]   '};...            
            ];
    cfg = [];     
    cfg = pregunta_lan(cfg,donde,opciones,'Estadistica ERP');
    catch
    disp('UPS ...')   
    disp('ERROR to assigne cfg.''s fields ...')
    cfg = []; 
    end
    if isnumeric(GLAN)
    if GLAN == 1
        GLAN=cfg;
        return
    end
    end
end


%%%-------------------------------------
%%% SETIANDO PARAMNETROS
%%%-------------------------------------



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
%search condition index

if size(sujetos,1)>1
   %disp('we''ll use erp_stata_group.m, see LAN manual ');
   %GLAN = erp_stata_group(GLAN,cfg) ;
   %grup = 1;
   try
       grup = CFG.grup;
       if isempty(grup)
           grup = [1,2];
       end
   catch
       grup = [1,2];
   end
else
   try
       grup = CFG.grup;
       if isempty(grup)
           grup = [1];
       end
   catch
       grup = 1;
   end 
   %grup = 1;
   %return
end









try
mcpMt = cfg.mcpMt;
catch
mcpMt = 'CBP';
end

if strcmp(mcpMt,'CRP'), 
    disp('Cluster-based randomitazation permutation analysis')
    GLAN = erp_statad_old(GLAN,cfg); 
   return
end


try filesf1 = cfg.file.sf;           catch , filesf1 = '';   end
try fileprf1 = cfg.file.prf;         catch , fileprf1 = '';  end
try matprf1 = cfg.mat.prf;           catch , matprf1='';    end
try matsf1 = cfg.mat.sf;             catch , matsf1 ='';     end

if length(grup) == 1
  if ~iscell(filesf1),filesf{grup} = filesf1;else filesf = filesf1; end
  if ~iscell(fileprf1),fileprf{grup} = fileprf1;else fileprf = fileprf1; end
  if ~iscell(matsf1),matsf{grup} = matsf1; else matsf = matsf1;end
  if ~iscell(matprf1),matprf{grup(1)} = matprf1; else matprf = matprf1;end
  
elseif length(grup) == 2
  if ~iscell(filesf1),filesf{grup(1)} = filesf1; filesf{grup(2)} = filesf1;else filesf = filesf1; end
  if ~iscell(fileprf1),fileprf{grup(1)} = fileprf1;fileprf{grup(2)} = fileprf1;else fileprf = fileprf1; end
  if ~iscell(matsf1),matsf{grup(1)} = matsf1; matsf{grup(2)} = matsf1;else matsf = matsf1;end
  if ~iscell(matprf1),matprf{grup(1)} = matprf1; matprf{grup(2)} = matprf1;else matprf = matprf1;end 
 
end
%
try
    savesub = cfg.savesub;
catch
    savesub=0;
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

try
alphap = cfg.alphap;
GLAN.erp.cfg.alphap{nbcomp} = alphap;
catch
    try
alphap = GLAN.erp.cfg.alphap{nbcomp};
catch
alphap = alpha;
GLAN.erp.cfg.alphap{nbcomp} = alphap;
disp('you don'' defined the alpha, so  we used 0,05 ');
    end
end



%search base line
try
bl = cfg.bl;
GLAN.erp.cfg.bl{nbcomp} = bl;
catch
    try
bl = GLAN.erp.cfg.bl{nbcomp-1};
catch
bl= [];
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

if mcp ==1
try
    nrandom = cfg.nrandom;
catch
    nrandom = 2000;

end
end

%%%
try
    bias = cfg.bias;
catch
        bias = 0;
end


%%%-------------------------------------
%%%  BEGINING OF THE COMPUTATIONS
%%%-------------------------------------


texto =plus_text();

% LOAD THE SUJECT'S MAT FILE
 
texto = plus_text(texto,['load subject files ... '  ]);
disp_lan(texto)

for g = grup
texto = plus_text(texto,[ 'Grupo: ' num2str(g)  ]);    
texto = plus_text(texto,[': '  ]);
for s = 1:length(sujetos)
    
    % find    %S
    FP = strrep(fileprf{g} ,'%S',sujetos{g,s});
    FS = strrep( filesf{g} ,'%S',sujetos{g,s});
    MP = strrep( matprf{g}  ,'%S',sujetos{g,s});
    MS = strrep( matsf{g} ,'%S',sujetos{g,s});
    
    eval(['load '  FP  sujetos{g,s}  FS '  ' MP  sujetos{g,s}  MS ' ']);
    eval(['LAN = ' MP   sujetos{g,s}  MS ';' ]);
    eval(['clear ' MP  sujetos{g,s}  MS ' ']);
    
    %%% elimina ensayos no acceptados
    LAN = lan_check(LAN,1);
    
    %%% chequea srate!!!
    if (isfield(cfg,'srate'))&&(~isempty(cfg.srate))
        LAN = resample_lan(LAN,cfg.srate);
    end
    
   %%% elimina electrodos excluidos del analisis
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
                    LAN = lan_check(LAN,1);
                 end
    else
            LAN = lan_check(LAN,1);
            ifcc = 0; 
    end
    
%------------------------------------
% EXTRATC DATA FOR LAN SIMPLE STRUCTURS
%------------------------------------

    for c = cond
        texto = last_text(texto,[ sujetos{g,s} ' '  ],'a');
        disp_lan(texto)
        for e = 1:LAN{c}.nbchan
            v_erp{g,c}(e,:,s) = erp_lan(LAN{c},e,bl,0);
        end
        
        %%% KEEP SPEFIFICATION FOR DEL GLAN STRUCTUR
        if s == 1 
                GLAN.time       = LAN{c}.time(1,:);    
                GLAN.srate      = LAN{c}.srate; 
                GLAN.nbchan     = LAN{c}.nbchan;
                GLAN.cond{c}    = LAN{c}.cond;
                    try
                    GLAN.chanlocs = LAN{c}.chanlocs;
                    catch
                        disp('There is not channel location file')
                    end
        end
        
        
       disp_lan(texto);
    end
    
    
end % for s
end % for g

%%% save de new chanlocs (without deleted electrode)
if ifcc
GLAN.chanlocs = LAN{1}.chanlocs; 
end

%%% time
    try
    time = cfg.time;
            ini = time(1) - GLAN.time(1,1);
            ini = fix(ini * GLAN.srate);
            if ini < 1, ini =1; end
            fini = time(2) - GLAN.time(1,1);
            fini = fix(fini * GLAN.srate); 
            time = zeros(size(LAN{1}.data{1}(1,:)));
            time(ini:fini)=1;
            iftime = 1;
    catch
            iftime = 0;
    end



            




%%%-------------------------------------
%%%  BEGINING  STATISTICAL COMPUTATIONS
%%%-------------------------------------


%%% comprobar indices
cp = 0;
if length(cond) ==1, cond(2) = cond(1); cp=1+cp; ci = 1; else ci = [1,2]; end
if length(grup) ==1, grup(2) = grup(1); cp=1+cp; gi = 1; else gi = [1,2];end
if length(cond) > 1 && isfield(cfg,'matdif'), mdif=1; matdif = cfg.matdif ; else mdif=0; end
if cp==2; error('You must indicate two condiction/group for comparison')
end

if ifstata && ~mdif
[pval, hh, stat] = nonparametric(v_erp{grup(1),cond(1)},v_erp{grup(2),cond(2)},alpha,m,0,texto);

elseif ifstata && mdif
    %%g1
    g1index = (abs(matdif)==1).*sign(matdif);
    g1index = g1index(logical(abs(matdif)==1));
    g1data = v_erp(cond(logical(abs(matdif)==1)));
    g1data = op_cell(g1data,g1index,'.*');
    ud = length(size(g1data{1}))+1;
    g1data = sum(cat(ud,g1data{:}),ud);
    %%g2
    g2index = (abs(matdif)==2).*sign(matdif);
    g2index = g2index(logical(abs(matdif)==2));
    g2data = v_erp(cond(logical(abs(matdif)==2)));
    g2data = op_cell(g2data,g2index,'.*');
    ud = length(size(g2data{1}))+1;
    g2data = sum(cat(ud,g2data{:}),ud);
    %
    if iftime
        [d1 d2 d3] = size(g1data);
        g1data = g1data .* (repmat(time, [d1,1,d3] ));
        g2data = g2data .* (repmat(time, [d1,1,d3] ));
    end
    %
    [pval, hh, stat] = nonparametric(g1data,g2data,alpha,m,0,texto);
    try
        maxcomp = max(length(LAN),length(GLAN.erp.data))+1;
    catch
        maxcomp = length(LAN)+1;
    end
    if savesub
    GLAN.erp.subdata{maxcomp} = g1data;
    GLAN.erp.subdata{maxcomp+1} = g2data;
    
% %         %%%save condiction
% %       for c = cond
% %           GLAN.erp.subdata{cond} = v_erp{cond};
% %       end
% %     end
% %       for c = cond
% %           GLAN.erp.data{cond} = mean(v_erp{cond},3);
% %       end

    %%%save condiction
      for c = cond
          GLAN.erp.subdata{c} = v_erp{c};
      end
     end
      for c = cond
          GLAN.erp.data{c} = mean(v_erp{c},3);
      end
    GLAN.erp.data{maxcomp} = mean(g1data,3);
    GLAN.erp.data{maxcomp+1} = mean(g2data,3);
    GLAN.cond{maxcomp} = [ '1:' num2str((abs(matdif)==1).*sign(matdif))] ;
    GLAN.cond{maxcomp+1} = [ '2:' num2str((abs(matdif)==2).*sign(matdif))];
    %clear g1data g2data
end




% SAVE RESULTS IN GLAN GROUPAL STRUCTURE

for g = grup
for c=cond
GLAN.cond{g,c} = LAN{c}.cond;
GLAN.cond{g,c} = LAN{c}.cond;
GLAN.erp.data{g,c} =  mean(v_erp{g,c},3);
    if savesub
       GLAN.erp.subdata{g,c} =  v_erp{g,c};
    end
end
end
GLAN.erp.comp{nbcomp} = cond;

%
% clear v_erp
%
if ~ifstata
    disp('DONE without statistic computations')
    return
end

GLAN.erp.pval{nbcomp} = pval;
GLAN.erp.hh{nbcomp} = hh;
GLAN.erp.stat{nbcomp} = stat;

%%%
bval = ones(size(pval));
bval = bval-pval;
stat = bval;
%GLAN.erp.fun_stat{nbcomp} = ['non-paramtric for ' m ' samples']; %% aca se
%cae 

%
%      MULTIPLE COMPARISON 
%      BY CLUSTER-BASED PERMUTATION
%
nbchan=GLAN.nbchan;

if mcp == 1 %%
    disp('Making Multiple Comparision correction')
    hhc = zeros(size(hh));
    pvalc = hhc;
    cluster=hhc;

% CHECK ELECTRODE POSITIONS
%
try 
        electrodemat = GLAN.chanlocs(1).electrodemat;
        em=1;
    catch
         disp('You must specify the electrode array')
         em=0;
end
    
    
if em == 0    
   
for e = 1:nbchan

clusig = bwlabel(hh(e,:),4);
%
%
%%% buscado el mayor cluster
for cc = 1:max(clusig)
    clu = zeros(size(clusig));
    clu(clusig==cc)=1;
    statclusig(cc) = sum(sum(sum(stat(e,:).*clu))); % suma del valor estadistico
    statclusign(cc) = sum(sum(sum(clu))); % numero de puntos
end
maxclusig = statclusig==max(statclusig); 
if sum(maxclusig)>1
    maxclusig = (maxclusig.*statclusign)==max(maxclusig.*statclusign);
end
maxclusig = find(maxclusig==1);
maxclusig = maxclusig(1);
clu = zeros(size(clusig));
clu(clusig==maxclusig)=1;
%
%
%


%%%%%%%%%%%%%%%%%%%%%%%%
%%% distribucion de probabilidad
%%% por permutacion
for c = cond;
gt(c) = size(v_erp{c},3);
%g2 = size(v_erp{cond(2)},3);
end
if ~mdif
    g1 = gt(cond(1));
    g2 = gt(cond(2));
simulerp = cat(3,v_erp{cond(1)}(e,:,:), v_erp{cond(2)}(e,:,:)) .* repmat(clu,[1,1,(gt(cond(1))+gt(cond(2)))]);
simulerp = squeeze(sum(simulerp,2));
for nr = 1:nrandom
    simulerp = simulerp([randperm(g1+g2)]);
    a = simulerp(1:g1);
    b = simulerp(g1+1:g2+g1);
    if m == 'i'
    [borra2, borra1 borra3, borra4] = ttest2(a,b);
    elseif m == 'd'
    [borra2, borra1 borra3, borra4] = ttest(a-b,0);  
    end
    ranpval(nr) = abs(borra4.tstat);
end
elseif mdif
simulerp = cat(3,v_erp{cond});
simulerp = simulerp(e,:,:) .* repmat(clu,[1,1,sum(gt)]);
simulerp = squeeze(sum(simulerp,2));   
 for nr = 1:nrandom
    simulerp = simulerp([randperm(sum(g))]);
    llv = 0;
    for c = 1:length(cond)
    t(c,:) =simulerp(llv+1:gt(c)); 
    llv = llv + gt(c);
    end
    g1index = (abs(matdif)==1).*sign(matdif);
    g1index = g1index(logical(abs(matdif)==1))
    a = t(logical(abs(matdif)==1),:);
    
    %%g2
    g2index = (abs(matdif)==2).*sign(matdif);
    g2index = g2index(logical(abs(matdif)==2));
    b = t(logical(abs(matdif)==2),:);
    
    if m == 'i'
    [borra2, borra1 borra3, borra4] = ttest2(a,b);
    elseif m == 'd'
    [borra2, borra1 borra3, borra4] = ttest(a-b,0);  
    end
    ranpval(nr) = abs(borra4.tstat);
 end

 
end
clear borra*


%%%
%%% p-val por cluster
ccont = 0;
for cc = 1:max(clusig)
    clu = zeros(size(clusig));
    clu(clusig==cc) = 1;
    if ~mdif
    a =  v_erp{cond(1)}(e,:,:) .* repmat(clu,[1,1,g1]) ;
    a = squeeze(sum(sum(a,2),1));
    b = v_erp{cond(2)}(e,:,:) .* repmat(clu,[1,1,g2]) ;
    b = squeeze(sum(sum(b,2),1));
    elseif mdif
    a =  g1data(e,:,:) .* repmat(clu,[1,1,g1]) ;
    a = squeeze(sum(sum(a,2),1));
    b =  g2data(e,:,:) .* repmat(clu,[1,1,g2]) ;
    b = squeeze(sum(sum(b,2),1));    
    end
     if m == 'i'
    [borra2, borra1 borra3, borra4] = ttest2(a,b);%ttest2(a,b);
    elseif m == 'd'
    [borra2, borra1 borra3, borra4] = ttest(a-b,0);%ttest(a-b,0);  
     end
    p_val_c =     sum(abs(borra4.tstat) < ranpval)/nrandom;
     if p_val_c <= alphap
            ccont = 1 + ccont;
            hhc(e,clusig==cc)=1;
            pvalc(e,clusig==cc) = p_val_c;
            cluster(e,clusig==cc) = ccont;
     end
end
disp(['electrode n= ' num2str(e) ' encontre ' num2str(ccont) ' de ' num2str([max(clusig)]) ]);
   
end %%% for e nbchan




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% FOR CLUSTER OF ELECTRODES

elseif em == 1
      
    %%%MAKE NEW 3D ARRAY
    for e = 1:nbchan
        [y x] = find(electrodemat==e);
        newhh(y,x,:) = hh(e,:); 
    end% for e    
    clusig_b = bwlabeln(newhh);
    for e = 1:nbchan
        [y x] = find(electrodemat==e);
        clusig(e,:)=clusig_b(y,x,:);
    end% for e 
    %%% check 
    if size(clusig)~=size(hh), error('mala transformacion'),end
    clear clusig_b newhh





%%% buscado el mayor cluster
for cc = 1:max(max(clusig))
    clu = zeros(size(clusig));
    clu(clusig==cc)=1;
    statclusig(cc) = sum(sum(sum(stat.*clu))); % suma del valor estadistico
    statclusign(cc) = sum(sum(sum(clu)));      % numero de puntos
end
maxclusig = statclusig==max(statclusig); 
if sum(maxclusig)>1
    maxclusig = (maxclusig.*statclusign)==max(maxclusing.*statclusign);
end
maxclusig = find(maxclusig==1);
maxclusig = maxclusig(1);
clu = zeros(size(clusig));
clu(clusig==maxclusig)=1;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% distribucion de probabilidad
%%% por permutacion de trials por sujetos
%%% Estadistica dependiente

if strcmp(m,'d') %%%001start
a=zeros(nrandom,1,1,length(sujetos));
b=a;
%disp(' ')
fprintf('Permuting trials n=%5.0f',nrandom);

for s = 1:length(sujetos)
for g = grup
        % find    %S
    FP = strrep(fileprf{g} ,'%S',sujetos{g,s});
    FS = strrep( filesf{g} ,'%S',sujetos{g,s});
    MP = strrep( matprf{g}  ,'%S',sujetos{g,s});
    MS = strrep( matsf{g} ,'%S',sujetos{g,s});
    
 fprintf(['\nReload Subject file:  '   sujetos{g,s}   '' ]) 
 
        eval(['load '  FP  sujetos{g,s}  FS  '   '  MP   sujetos{g,s}  MS ' ']);
        eval(['LAN = ' MP   sujetos{g,s}  MS ';' ]);
        eval(['clear ' MP   sujetos{g,s}  MS ' ']);
         LAN = lan_check(LAN,1);
if ~mdif
    if cond(1) ~= cond(2);
    datasimul = cat(2,LAN{cond(1)}.data, LAN{cond(2)}.data);
    datasimul = cat(3,datasimul{:});
    la = LAN{cond(1)}.trials;
    lb = LAN{cond(2)}.trials;
    else
    datasimul{g} = LAN{cond(1)}.data;    
    end
elseif mdif
    simulerp = [];

        if bias
          for c = 1:length(cond)
            l(c) = LAN{cond(c)}.trials;
            callmat{c} = cat(3,LAN{cond(c)}.data{:});
          end
            datauno =  callmat{matdif==1} - repmat(mean(callmat{find(matdif==-1)},3),[1,1,size(callmat{find(matdif==1)},3)]);
            datados =  callmat{matdif==2} - repmat(mean(callmat{find(matdif==-2)},3),[1,1,size(callmat{find(matdif==2)},3)]);
            la = size(datauno,3);
            lb = size(datados,3);
            datasimul = cat(3,datauno,datados);
            clear datauno datados
        else             
            for c = 1:length(cond)
            simulerp = cat(2,simulerp,LAN{cond(c)}.data);
            l(c) = LAN{cond(c)}.trials;
          end  
        datasimul = cat(3,simulerp{:});
        end
end
end % for g

if (grup(1) ~= grup(2))%  
la = length(datasimul{grup(1)});
lb = length(datasimul{grup(2)});    
datasimul = cat(2,datasimul{grup(1)},datasimul{grup(2)} );
datasimul = cat(3,datasimul{:});    
end



elec = ones(1,LAN{cond(1)}.nbchan);

if isfield(cfg,'delectrode')
elec(cfg.delectrode) =0;
end
datasimul = datasimul(elec==1,:,:);
datasimul = datasimul.*repmat(clu,[1,1,size(datasimul,3)]);
datasimul = squeeze(mean(mean(datasimul,2),1));

ww=1;
for nr = 1:nrandom
    
   if (~mdif )||( bias==1)
        datasimul =   datasimul(randperm(size(datasimul,1)));
        a(nr,1,1,s) = mean(datasimul(1:la)); 
        b(nr,1,1,s) = mean(datasimul(1+la:la+lb)); 
        w = 10*nr/nrandom;
        if w > ww
             fprintf('%2.0f%%>', ((ww*10)/length(sujetos)  )+( (s-1)*100/length(sujetos))    );
            ww = ww+1;
        elseif nr==1 %&& s==1
            fprintf('%2.0f%%>',( (s-1)*100/length(sujetos)) );
        end
   elseif (mdif) &&( bias==0)
        datasimul =   datasimul(randperm(size(datasimul,1)));
            t=[];
            llv = 0;
            for c = 1:length(cond)
            t(c) = mean(datasimul(llv+1:llv+l(c))); 
            llv = llv + l(c);
            end
            g1index = (abs(matdif)==1).*sign(matdif);
            g1index = g1index(logical(abs(matdif)==1));
            aa = t(logical(abs(matdif)==1)).* g1index;
            %%g2
            g2index = (abs(matdif)==2).*sign(matdif);
            g2index = g2index(logical(abs(matdif)==2));
            bb = t(logical(abs(matdif)==2)).* g2index;
            
            
        a(nr,1,1,s) = sum(aa); 
        b(nr,1,1,s) = sum(bb); 
        
        w = 10*nr/nrandom;
        if w > ww
             fprintf('%2.0f%%>', ((ww*10)/length(sujetos)  )+( (s-1)*100/length(sujetos))    );
            ww = ww+1;
        elseif nr==1 %&& s==1
            fprintf('%2.0f%%>',( (s-1)*100/length(sujetos)) );
        end
       
       
   end

end
clear datasimul
end % for s




[borra1 , borra2, W ] = nonparametric(a,b,alpha,m);
%
if strcmp(m,'d')
    W = 1-borra1;
end
clear borra*
end%%%% 001end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% distribucion de probabilidad
%%% por permutacion de sujetos
%%% Estadistica independiente

if strcmp(m,'i') %%% 002start

fprintf('Permuting subject n=%5.0f',nrandom);
la = 0;lb =0;

    if ~isempty(v_erp{grup(1),cond(1)})
    la = size(v_erp{grup(1),cond(1)},3);    
    end
    if ~isempty(v_erp{grup(2),cond(2)})
    lb =size(v_erp{grup(2),cond(2)},3);     
    end

datasimul = cat(3,v_erp{grup(1),cond(1)},v_erp{grup(2),cond(2)});
datasimul = datasimul.*repmat(clu,[1,1,size(datasimul,3)]);
datasimul = squeeze(mean(mean(datasimul,2),1));

ww=1;
for nr = 1:nrandom
datasimul =   datasimul(randperm(size(datasimul,1)));
a(nr,1,1,:) = (datasimul(1:la)); 
b(nr,1,1,:) = (datasimul(1+la:la+lb)); 
end

clear datasimul

[borra1 , borra2, W ] = nonparametric(a,b,alpha,m);
%
if strcmp(m,'i')
    W = 1-borra1;
end
clear borra*


end %%% 002end


%%% p-val por cluster
if mdif
g1 = size(g1data,3);
g2 = size(g2data,3);
v_erp{grup(1),cond(1)} = g1data;
v_erp{grup(2),cond(2)} = g2data;
else
g1 = size(v_erp{grup(1),cond(1)},3);
g2 = size(v_erp{grup(2),cond(2)},3);
end


ccont = 0;
for cc = 1:max(max(clusig))
    clu = zeros(size(clusig));
    clu(clusig==cc) = 1;
    a =  v_erp{grup(1),cond(1)} .* repmat(clu,[1,1,g1]) ;
    a = squeeze(sum(sum(a,2),1));
    b = v_erp{grup(2),cond(2)} .* repmat(clu,[1,1,g2]) ;
    b = squeeze(sum(sum(b,2),1));
%      if m == 'i'
%     [borra2, borra1 borra3, borra4] = ttest2(a,b);
%     elseif m == 'd'
%     [borra2, borra1 borra3, borra4] = ttest(a-b,0);  
%      end
[borra1 , borra2, Wr ] = nonparametric(a,b,alpha,m);


    Wr = 1-borra1;


clear borra*    %% Wr = real W =distr 
p_val_c =     sum(Wr < W)/nrandom;%% sum(Wr <= W)/nrandom;
     if p_val_c <= alphap
            ccont = 1 + ccont;
            hhc(clusig==cc)=1;
            pvalc(clusig==cc) = p_val_c;
            cluster(clusig==cc) = ccont;
     else
           pvalc(clusig==cc) = p_val_c;
     end
end

 texto = plus_text(texto,['Sobrevivieron ' num2str(ccont) ' cluster,  de ' num2str([max(max(clusig))])]);
 disp_lan(texto)
end


%%%
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
%%% corrige comp index

paso = zeros(size(GLAN.erp.data));
paso(grup(1),cond(1)) = 1;
paso(grup(2),cond(2)) = 2;
ccc(1) = find(paso==1);
ccc(2) = find(paso==2);
GLAN.erp.comp{nbcomp}=ccc;
if mdif
   GLAN.erp.matdif{nbcomp}=matdif;
   GLAN.erp.comp{nbcomp} = [ maxcomp , maxcomp+1];
end
%%%%
%%%
end%%% END OF THE FUNCTION
%%%

%%%
%%%
%%%

