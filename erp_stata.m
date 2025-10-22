function GLAN = erp_stata(GLAN,cfg)
%           <*LAN)<]
%           v.0.2.6
%
%ERP_STATA REALIZA ESTADISTICA NOPARAMETRICA A ERP
% 
% cfg.
%  subject  = {[{}{}{}]},{....}
%  comp 	= [n1 n2];  	  % INDEX OF THE CONDITION TO COMPARED
%  matdif   = [-1 1 -2 2]     % MATRIZ DE DIFERENCIAS, DEL MISMO TAMAGNO QUE cfg.comp.
%                             % DONDE LOS 1 CORRESPONDEN AL PRIMER groupO, -1 EL
%                             % QUE SE VA ARRESTAS A 1, LOS MISMO PARA 2 Y -2.
%  group = [g1 g2]
%  groupname = {nombre_de_los_groupos}     
%  conditionname = {'task', 'rest', ...}
%  alpha 	=0.05;
%  alphap 	=0.05; alpha for permutation test
%  m		='d'; OR ='i' 	% RELATIONSHEAP TO THE SAMPLES 'i'NDEPENDENT OR 'd'EPENDET
%  bl		=[ 0 0.4];	% BASELINE
%  mcp      = 1 or 0 
%  nrandom  = 100
%  stata    = 1; % TO MAKE STADISTIC, FOR DEFAULT.
%  savesub  = 0; % for save indivudal erp for sabject
%  srate = ;  % chequea los srate, resamplaendo los no concordantes; 
%  laplace = false; % true : compute laplace tranformation with default parameters.
%                   % use cfg.G = G; and cfg.H = H; for pre calculated G ang H matrix for
%                   % a monatge
%
%		    % for more details see  LAPLACE.m	 
%  mcpMt = 'CBP' por defecto
%                 'CRP'                                                
%  matname  = 'str'                                 special carater:
%  .................                                     %S subjectname
%  filename  = 'str'                                     %G groupname 
%  .................                                     %C conditionname 
%
%
%  OPTIONS  --> by defaout all are off!!
%  bias =    0 ; para permutaciones sesgadas cuando se realiza la
%                estadistica de una diferencia
%  time     = [s s]                    % time interval to extract of original LAN structure to compute statistic 
%  delelectrode = [elec_1 elec_n ... ] % ELECTRODES EXCLUIDED TO THE ANALISIS
%  lowpass  = [30] 
%  lowpass_type = 'fir'
%  reref = 'all'  % to re-referenciate the data 
%  
%
%
%  Pablo Billeke
%  Rodrigo Henriquez
%  Francisco Zamorano
%
%  (See also RESAMPLE_LAN )

%
%
%               FALTA!!! -> arregalr las correcion por comparaciones
%               multiples en caso de estadistica independiente
%

% 02.06.2015 (PB)  fix bug in time extraction 
% 08.04.2015 (PB)  add time option and fix bug in time extraction 
% 16.12.2013 (PB)  add lowpass option
% 03.11.2013 (PB)  fix permutation per 'conditions' format
% 26.09.2013 (PB)  fix multiple comparizon correction
% 04.07.2012 (PB)  fix continuos mode extraction!
% 26.06.2012 (PB)  fix base line correction
% 10.02.2012 (PB)  fix bug in matdif
% 01.02.2012 (PB)  fix save clusters 
% 11.01.2012 (PB)  improve cluster leves statistic
% 10.01.2012 (PB)  fix bug raed cfg.matdif
% 17.11.2011 (PB)  fix permutation test
% 24.06.2011 (PB)  add srate option
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
%%% GRAPHIC FUNCTION TO CONFIGURATE .cfg 
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
    if  GLAN == 1
        GLAN=cfg;
        return
    end
    end
end


%%%-------------------------------------
%%% SETIANDO PARAMNETROS
%%%-------------------------------------

try
cond = cfg.comp;
end

try 
sujetos = cfg.subject;
GLAN.subject=sujetos;
catch
try
    sujetos = GLAN.subject;
catch
error('you must defined subject name in cfg.subject')
end
end
%%% 
%search condition index
try
group = cfg.group;
end

try
groupname = cfg.groupname;
end

if (size(sujetos,2)>1 && (~iscell(sujetos{1}))) 
    try
        group = cfg.group;
        if isempty(group)
            group = ones(size(cond));
        end
    catch
        group = ones(size(cond));
    end
   try
       groupname = cfg.groupname;
       if isempty(groupname)
           groupname = {'g1'};
       end
   catch
       groupname = {'g1'};
   end
   if (~iscell(sujetos{1}))
   paso{1} = sujetos;
   sujetos = paso; clear paso
   end
   %%%
elseif size(sujetos,2)>1 && ( iscell(sujetos{1})) && (ischar(sujetos{1}{1}) )
       
    try
       group = cfg.group;
       if isempty(group) || (length(group)~=length(cond))
           paso = group(1);
           group=[];
           group = ones(size(cond))*paso;
       end
   catch
           paso = group(1);
           group=[];
           group = ones(size(cond))*paso;
   end 
   try
       groupname = cfg.groupname;
       if isempty(groupname) || (length(groupname)~=length(sujetos))
           groupname=[];
           for l =1:length(sujetos)
               groupname{l} = ['G' num2str(l) ];
           end
       end
   catch
           groupname=[];
           for l =1:length(sujetos)
               groupname{l} = ['G' num2str(l) ];
           end
   end 
end


 clear paso


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




% mat file name and path for subject
try
    filename = cfg.filename;
    if isempty(filename) || ~ischar(filename)
    filename = '%S';
    end
catch
    filename = '%S';
end
try
    matname = cfg.matname;
    if isempty(matname) || ~ischar(matname)
    matname = '%S';
    end
catch
    matname = '%S';
end


% conditions names

conditionname = getcfg(cfg,'conditionname',[]);

if isempty(conditionname)||any(isemptycell(conditionname))
    for i = 1:length(cond)
    conditionname{i} = '';
    end
end






% save erp per subject in GLAN structure
try
    savesub = cfg.savesub;
catch
    savesub=1;
end






% SEARCH COMPARATION
if isfield(GLAN,'erp') %&& ~isempty(GLancomp)
      nbcomp=size(GLAN.erp.comp,2)+1;
else
      nbcomp=1;
end 





try
cond = cfg.comp;
GLAN.erp.compC{nbcomp}=cond;
GLAN.erp.compG{nbcomp}=group;
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
    if isfield(cfg.delectrode);
        GLAN.chanlocs([cfg.delectrode]) = [];
    end
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

% set alpha por permutation test
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
ifbl =false;
% SEARCH STATISTICAL CONFIGURATIONS
try
    ifstata = cfg.stata;
catch
    ifstata = 1;
end
%
%



getcfg(cfg,'mcp',false);
getcfg(cfg,'nrandom',100);
getcfg(cfg,'stat_roi',[]);
ttime = getcfg(cfg,'time',[]);

getcfg(cfg,'sig',false)

s = getcfg(cfg,'s','i');
if ifstata && mcp && strcmp(s,'d')
    iftempfile = true;
    tempfile = ['tempLAN_' datestr(now,'yymmdd_HHMMss') ];
else
    iftempfile = false;
end

% simplificar permutacion (not documented)
getcfg(cfg,'fastmcp',0.8)
if fastmcp <1
   iffastmcp = true;
else
   iffastmcp = false;
end


lowpass = getcfg(cfg,'lowpass',[]);
getcfg(cfg,'lowpass_type','fir')





% bias options (not documented)
try
    bias = cfg.bias;
catch
    bias = true;
end

% lapalce transformations
try
  iflaplace = cfg.laplace;
catch
  iflaplace = false;
end
GLAN.erp.cfg.laplace{nbcomp} = iflaplace;



%%%-------------------------------------
%%%  BEGINING OF THE COMPUTATIONS
%%%-------------------------------------


texto =plus_text();
if iflaplace, texto =plus_text(texto,['::Laplace transformation per subject ERP']);end
% LOAD THE SUJECT'S MAT FILE
 
texto = plus_text(texto,['load subject files ... '  ]);
disp_lan(texto)
pasog = 1;

%


for ix = 1:length(group)
    g = group(ix);
    % c = cond(ix);
    % no repetir condiciones/grupos ya extraidos
     if ix >1;
         if any(group(1:(ix-1))==g)
             continue
         end
     end
     %pasog = pasog+1;
    
texto = plus_text(texto,[ 'group: ' groupname{g} ]);    
texto = plus_text(texto,[': '  ]);
for s = 1:length(sujetos{g})
    
    % find    %S
    filenameA = strrep( filename ,'%S',sujetos{g}{s});
    filenameA = strrep( filenameA ,'%G',groupname{g});
    %filenameA = strrep( filenameA ,'%C',conditionname{c});
    matnameA = strrep( matname ,'%S',sujetos{g}{s});
    matnameA = strrep( matnameA ,'%G',groupname{g});
    %matnameA = strrep( matnameA ,'%C',conditionname{c});
    
    if strfind( filenameA,'*')
       filenameA = eval(['ls(''' filenameA   ''')']);
    end
    
    eval(['load '  filenameA '  ' matnameA ' ']);
    if ~strcmp('LAN',matnameA )
        eval(['LAN = ' matnameA ';' ]);
        eval(['clear ' matnameA ' ']);
    end

    
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
                     LAN = add_field(LAN, 'chanlocs = cfg.chanlocs;');
                     %LAN.chanlocs = cfg.chanlocs; 
                     LAN = electrode_lan(LAN, cfg.delectrode);
                     ifcc = 1;
                 else
                    ifcc = 0; 
                    %LAN = lan_check(LAN,'D~V');
                 end
    else
            
            ifcc = 0; 
    end
    LAN = lan_check(LAN,'D~V');
    %%% laplace tranformation (by trials MUY LENTO)
    %if iflaplace
    %LAN = lan_laplace(LAN,cfg);
    %end
%------------------------------------
% EXTRATC DATA FOR LAN SIMPLE STRUCTURS
%------------------------------------
    pasocond = [];
    texto = last_text(texto,[ sujetos{g}{s} ' '  ],'a');
    formato = '';
    for c = cond(group==g)
        %if any(pasocond==c)
        %    continue
        %end
        pasocond = cat(2,pasocond,c);
        %
        disp_lan(texto)
        
          if iscell(LAN)&&((length(LAN)>1)||~(isfield(LAN{1},'conditions')))
              
            %%% elimina ensayos no acceptados
            formato='cell';
            LAN = lan_check(LAN,'D~V');
            v_erp{g,c}(:,:,s) = mean(cat(4,LAN{c}.data{:}),4);
            iscont = false;
          elseif isstruct(LAN)&&isfield(LAN,'conditions')
              if ~isempty(lowpass)
                    LAN = lan_filter(LAN,[],lowpass,'all','fir2');
              end
            formato='conditions';
              % fixME
              % some problems with this new segmentations
              if any(LAN.conditions.ind{c}>1)
                 paso = false(size(LAN.accept));
                 paso(LAN.conditions.ind{c})=true;
                 LAN.conditions.ind{c} = paso;
                 clear paso 
              elseif length(LAN.conditions.ind{c})<length(LAN.data)
                  error([' Less tarial than condicions !!!'])
                  %paso = false(size(LAN.accept));
                  %paso(1:length(LAN.conditions.ind{c})) = LAN.conditions.ind{c};
                  %LAN.conditions.ind{c} = paso;
                  %clear paso                   
              end
              
              ind = (LAN.conditions.ind{c}(:))&(LAN.accept(:));%fix!
              if sum(ind)==0
                  error(['Sujeto ' cfg.subject{g}{s} ...
                      ' no tiene trials de la condicion '...
                      LAN.conditions.name{c}  ' ' ])
              end
              if isempty(ttime)% extract specific time !!
                  v_erp{g,c}(:,:,s) = mean(cat(4,LAN.data{ind}),4);
              else
                  id1=find_approx(min(ttime),timelan(LAN));
                  id2=find_approx(max(ttime),timelan(LAN));
                  paso = cat(4,LAN.data{ind});
                  v_erp{g,c}(:,:,s) = mean(paso(:,id1:id2,:,:),4);
              end
              iscont = true;
          else
              iscont = false;
          end
          
          if ~isempty(bl)&&(isstruct(LAN))
            linetime = timelan(LAN);
            bl1 = find_approx(linetime,bl(1));
            bl2 = find_approx(linetime,bl(end));
            bl = [];
            ifbl = true;
          elseif ~isempty(bl)&&(iscell(LAN));
            linetime = timelan(LAN{c});
            bl1 = find_approx(linetime,bl(1));
            bl2 = find_approx(linetime,bl(end));
            bl = [];
            ifbl = true;
          end
          
           %laplace transfor to ERP wave
           if iflaplace && (isfield(cfg,'G')&&isfield(cfg,'H'))
              v_erp{g,c}(:,:,s) = CSD(v_erp{g,c}(:,:,s), cfg.G, cfg.H, 0.00001, 10);
           end
           
  
           
        %%% KEEP SPEFIFICATION FOR DEL GLAN STRUCTUR
        if (s == 1)&&(~iscont)
                f = find(LAN.accept,1);
                if  isempty(ttime)
                    GLAN.time = LAN{c}.time(f,:); 
                else
                    GLAN.time = ttime;
                end 
                GLAN.srate      = LAN{c}.srate; 
                GLAN.nbchan     = LAN{c}.nbchan;
                GLAN.cond{g,c}    = LAN{c}.cond;
                    if ~isfield(GLAN,'chanlocs')
                    try
                        GLAN.chanlocs = LAN{c}.chanlocs;
                    catch
                        disp('There is not channel location file')
                    end
                    end
        elseif (s == 1)&&(iscont)
                f = find(LAN.accept,1);
                if  isempty(ttime)
                    GLAN.time = LAN.time(f,:); 
                else
                    GLAN.time = ttime;
                end      
                GLAN.srate      = LAN.srate; 
                GLAN.nbchan     = LAN.nbchan;
                GLAN.cond{g,c}    = LAN.conditions.name{c};
                    if ~isfield(GLAN,'chanlocs')
                    try
                        GLAN.chanlocs = LAN.chanlocs;
                    catch
                        disp('There is not channel location file')
                    end            
                    end
        end
        
        
       disp_lan(texto);
    end
    
    if iftempfile
       npaso = cond(group==g); 
        
       switch formato
           case 'conditions'
                ind = LAN.conditions.ind{npaso(1)};
                TRI = LAN.data(ind);
                clear nT
                nT(1) = size(cat(4,LAN.data{ind}),4);
                n = 2;
                while n <= length(npaso)
                    ind = LAN.conditions.ind{npaso(n)};
                    TRI = cat(2,TRI,LAN.data(ind));
                    nT(n) =  size(cat(4,LAN.data{ind}),4);
                    n = n+1;
                end               
               
               
           case 'cell'
               TRI = LAN{npaso(1)}.data;
               clear nT
                nT(1) = size(cat(4,LAN{npaso(1)}.data{:}),4);
                n = 2;
                while n <= length(npaso)
                    TRI = cat(2,TRI,LAN{npaso(n)}.data);
                    nT(n) = size(cat(4,LAN{npaso(n)}.data{:}),4);%LAN{npaso(n)}.trials;
                    n = n+1;
                end
       
       end;
       
       
       
       TRI = cat(3,TRI{:});
          if ifbl
              TRI =  TRI - repmat(mean(TRI(:,bl1:bl2,:),2),[1,size(TRI,2),1]);
          end
       save([tempfile 'S_' num2str(s) 'G_' num2str(g) ],'TRI','nT')
    end
    
end % for s
end % for g

%%% save de new chanlocs (without deleted electrode)
if ifcc && ~isfield(GLAN,'chanlocs');
GLAN.chanlocs = LAN{1}.chanlocs; 
end




%%% reref
if isfield(cfg,'reref') && ~isempty(cfg.reref)
    % pasar de label a indice
    if ischar(cfg.reref)&&strcmp(cfg.reref,'all')
        cfg.reref = 1:length(GLAN.chanlocs);
    elseif iscell(cfg.reref)||ischar(cfg.reref)
        cfg.reref = label2idx_elec(GLAN.chanlocs,cfg.reref);
    end
    for g = group
        pasocond =[];
        for c=cond
                if any(pasocond==c)
                    continue
                end
                pasocond = cat(2,pasocond,c);
            for s = 1:length(sujetos{g})
               ref = squeeze(mean(v_erp{g,c}(cfg.reref,:,s),1));
               v_erp{g,c}(:,:,s) = v_erp{g,c}(:,:,s) - repmat(ref,[size(v_erp{g,c},1),1]);
            end
              if length(cfg.reref)<length(GLAN.chanlocs)
              v_erp{g,c}(cfg.reref,:,:) = [];
              GLAN.chanlocs(cfg.reref) = [];
              end
        end
    end
    
    
    nbchan = length(GLAN.chanlocs);
    GLAN.nbchan = nbchan;
    
    
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

getcfg(cfg,'matdif',0);
if ~isempty(matdif) && length(matdif)~=1
    mdif =1; 
    getcfg(cfg,'matdif')
    getcfg(cfg,'matdif_transform','none')
    getcfg(cfg,'matw',[])
    getcfg(cfg,'matfun','mean')
    if isempty(matw)
        matw=ones(size(matdif));
    end 
else
    mdif=0;
end

if ifstata && ~mdif
    
    
    
    
    
    a =[];
    for i = 1:length(cond)
    a{i} = v_erp{group(i),cond(i)};
    if ifbl
              a{i} =  a{i} - repmat(mean(a{i}(:,bl1:bl2,:),2),[1,size(a{i},2),1]);
    end
           
    end
    %try
     pc.paired = strcmp(m,'d');
     pc.method = 'rank';
     pc.text = texto;
    [pval, stat] = lan_nonparametric(a,pc);
    hh = false(size(pval));
    hh(pval<alpha)=true;
    try
        stat = stat.zval;
    catch
        stat = stat.chistat;
    end
    %catch
    %[pval, hh, stat] = nonparametric(a,[],alpha,m,0,texto);
    %end
    clear a

	% SAVE RESULTS IN GLAN GROUPAL STRUCTURE

% 	for g = group
% 	for c=cond
% 	%GLAN.cond{g,c} = LAN{c}.cond;
% 	%GLAN.cond{g,c} = LAN{c}.cond;
% 	GLAN.erp.data{g,c} =  mean(v_erp{g,c},3);
% 	    if savesub
% 	       GLAN.erp.subdata{g,c} =  v_erp{g,c};
% 	    end
% 	end
% 	end
	% verificar
	GLAN.erp.comp{nbcomp} = cat(1,cond,group);




elseif ifstata && mdif
    
    gdata =[];
    for gi = 1:max(abs(matdif))
        
    %pasoindex = (abs(matdif)==gi).*sign(matdif);
    pasoindex = (abs(matdif)==gi).*sign(matdif).*matw;
    
    pasoindex = pasoindex(logical(abs(matdif)==gi));
    gindx = group(logical(abs(matdif)==gi));
    cindx = cond(logical(abs(matdif)==gi));
    for iii = 1:length(gindx)
    pasodata{iii} = v_erp{gindx(iii),cindx(iii)};
    end
    pasodata = op_cell(pasodata,pasoindex,'.*');
    ud = length(size(pasodata{1}))+1;
    
    %pasodata = sum(cat(ud,pasodata{:}),ud);
    
    
    
    
            switch matdif_transform
                case 'log'
                pasodata = log(cat(ud,pasodata{:})); 
                %pasodata = nansum(log(cat(ud,pasodata{:})),ud); 
                case 'log10'
                pasodata = log10(cat(ud,pasodata{:}));     
                otherwise
                pasodata = cat(ud,pasodata{:});      
            end
    
            switch matfun
                case 'sum'
                pasodata = nansum(pasodata,ud);%log(cat(ud,pasodata{:})); 
                %pasodata = nansum(log(cat(ud,pasodata{:})),ud);  
                case 'mean'
                pasodata = nanmean(pasodata,ud);
                case 'std'
                pasodata = nanstd(pasodata,[],ud);
            end
            
            
            if iftime
                [d1 d2 d3] = size(pasodata);
                pasodata = pasodata .* (repmat(time, [d1,1,d3] ));
            end 
    gdata{gi}    = pasodata;
    if ifbl
              gdata{gi} =  gdata{gi} - repmat(mean(gdata{gi}(:,bl1:bl2,:),2),[1,size(gdata{gi},2),1]);
    end
    clear pasodata
    end
    clear paso*

   
    %
    % [pval, hh, stat] = nonparametric(gdata,[],alpha,m,0,texto);
    Tcfg = [];
    Tcfg.paired = (m=='d');
    Tcfg.text =texto; 
    
    [pval , stats] = lan_nonparametric(gdata,Tcfg);
    hh = pval<= alpha;
    stat = -log(pval);
	% SAVE RESULTS IN GLAN GROUPAL STRUCTURE
    if isfield(GLAN.erp, 'datadif')
        maxdatadif=length(GLAN.erp.datadif);
    else
        maxdatadif=0;
    end
%     try
%         maxcomp = max(length(LAN),length(GLAN.erp.data))+1;
%     catch
%         maxcomp = length(LAN)+1;
%     end
    if savesub
            %%% save dif in differente structur        
            GLAN.erp.subdatadif((maxdatadif+1):(maxdatadif+length(gdata))) = gdata(:);
            %GLAN.erp.subdatadif{maxcomp+1} = gdata{2};
            %%% save condiction
              for g = group
              for c = cond(group==g)
                  GLAN.erp.subdata{g,c} = v_erp{g,c};
              end
              end
    end
    
        for g = group
              for c = cond(group==g)
                    GLAN.erp.data{g,c} = mean(v_erp{g,c},3);
              end
         end
      % verificar
        GLAN.erp.comp{nbcomp} = cat(1,cond,group,matdif);
      % verificar
        maxcond = length(GLAN.cond(:));
		for ni = 1:length(gdata)
    		GLAN.erp.datadif{maxdatadif+(ni)} = mean(gdata{ni},3);
			GLAN.conddif{maxdatadif+(ni)} = [num2str(ni) ':' num2str(find(abs(matdif)==ni).*sign(matdif(abs(matdif)==ni)))] ;
		    matdifind(ni) = maxdatadif+(ni);
            %GLAN.cond{maxcomp+1} = [ '2:' num2str((abs(matdif)==2).*sign(matdif))];
        end
        GLAN.erp.matdifind{nbcomp} = matdifind;
   clear gdata
end


	for g = group
	for c=cond
	%GLAN.cond{g,c} = LAN{c}.cond;
	%GLAN.cond{g,c} = LAN{c}.cond;
	GLAN.erp.data{g,c} =  mean(v_erp{g,c},3);
	    if savesub
	       GLAN.erp.subdata{g,c} =  v_erp{g,c};
	    end
	end
    end
    % verificar
	GLAN.erp.comp{nbcomp} = cat(1,cond,group);

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
%bval = ones(size(pval));
%bval = bval-pval;
%stat = bval;

stat = -log(pval);
stat(isinf(stat)) = max(stat(~isinf(stat)))*10;

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
    ngs = fun_in_cell(v_erp(cond), 'size(@,3)');
    simulerp = simulerp(e,:,:) .* repmat(clu,[1,1,size(simulerp,3)]);
    simulerp = squeeze(sum(simulerp,2));   
 for nr = 1:nrandom
    simulerp = simulerp([randperm(length(simulerp))]);
    llv = 0;
    for c = 1:length(matdif)
      t(c,:) =simulerp(llv+1:llv+ngs(c)); 
      llv = llv + ngs(c);
    end
    g1index = (abs(matdif)==1).*sign(matdif);
    g1index = g1index(logical(abs(matdif)==1))
    a = sum(t(logical(abs(matdif)==1),:).* repmat(sign(matdif((abs(matdif)==1)))',[1, size(t,2)])  , 1);
   
    %%g2
    g2index = (abs(matdif)==2).*sign(matdif);
    g2index = g2index(logical(abs(matdif)==2));
    b = sum(t(logical(abs(matdif)==2),:).* repmat(sign(matdif((abs(matdif)==2)))',[1, size(t,2)])  , 1);
   
    
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
            %%% roi only in selected electrode 
            if isempty(stat_roi)
                stat_roi=1:nbchan;
            end
            for e = stat_roi
                [y x] = find(electrodemat==e);
                newhh(y,x,:) = hh(e,:);
                if sig
                sigst(y,x,:)=sign(stat(e,:));
                end
            end% for e
               if sig
                   p_n = newhh;
                   p_n(sigst==-1)=0;
                   clusig_b = bwlabeln(p_n);
                   p_n = newhh;
                   p_n(sigst==1)=0;
                   p_p =(bwlabeln(p_n));
                   clusig_b = clusig_b + p_p + (max(max(max(p_p))))*(p_p~=0) ;
               else
                   clusig_b = bwlabeln(newhh);
               end 
    for e = stat_roi
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
    statclusig(cc) = sum(sum(sum(abs(stat).*clu))); % suma del valor estadistico
    statclusign(cc) = sum(sum(sum(clu)));      % numero de puntos
end
maxclusig = statclusig==max(statclusig); 
if sum(maxclusig)>1
    maxclusig = (maxclusig.*statclusign)==max(maxclusing.*statclusign);
end
maxclusig = find(maxclusig==1);
maxclusig = maxclusig(1);
refclu = zeros(size(clusig));
refclu(clusig==maxclusig)=1;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% distribucion de probabilidad
%%% por permutacion de trials por sujetos
%%% Estadistica dependiente

if strcmp(m,'d') %%%001start
a=zeros(nrandom,1,1,length(sujetos));
b=a;
%disp(' ')
fprintf('Permuting trials n=%5.0f',nrandom);

ww=1;
for nr = 1:nrandom

%for ng = 1:length(cond)%%%%%%%%%%%%%%%%%%%%%%%%%%%
for g = unique(group)
       
for s = 1:length(sujetos{g})
    
    load([tempfile 'S_' num2str(s) 'G_' num2str(g) ],'TRI','nT');
    TRI = TRI(:,:,randperm(size(TRI,3)));
    ntc = cat(2,0,cumsum(nT)) ;
    


    % ARREGLAR!!!!
    if ~mdif  
	% entendemos que por ahora las estadistica dependiente es solo entre parejas
    %if length(rc)>1
    %datasimul = [];
    cn = 1;
    
    %for c = cond(group==g)
    %    ct = find(cond==c); %% para no sobreescribir igual c distinto g
    %    %datasimul = cat(2,datasimul, LAN{c}.data);    
    %    l(ct) = nT(cn);
    %    cn = cn + 1;
    %end
    
    % TRI !! datasimul = cat(3,datasimul{:});
    %else
    %datasimul{g} = LAN{cond(1)}.data;    
    %end
    elseif mdif
    simulerp = [];

        if bias
	      %%% verificar !!!!
          paso = 1:length(cond);
          nc=0;
          for c = paso(group==g)
              nc=nc+1;
	        %%% solo las del grupo, seguir arreglado para abajo              
            %l(c) = nT(nc);
            callmat{c} = TRI(:,:,(1+ntc(nc)):(ntc(nc+1)));%cat(3,LAN{cond(c)}.data{:});
          end
          clear l
           for iii = unique(abs(matdif));
            datapaso{iii} =  callmat{matdif==iii} - repmat(mean(callmat{find(matdif==(iii*-1))},3),[1,1,size(callmat{find(matdif==iii)},3)]);
            l(iii) = size(datapaso{iii},3);
           end
            nT = l;
            ntc = cumsum([ 0 , nT]);
            TRI = cat(3,datapaso{:});
            clear datapaso
        else  
	        %nc=0;           
            %for c = 1:length(cond)
            %nc=nc+1;    
            %simulerp = cat(2,simulerp,LAN{cond(c)}.data);
            %l(c) = LAN{cond(c)}.trials;
            %l(c) = nT(nc);
            %end  
           %datasimul = cat(3,simulerp{:});
        end
     end



%elec = ones(1,LAN{cond(1)}.nbchan);
%if isfield(cfg,'delectrode')
%elec(cfg.delectrode) =0;
%datasimul = datasimul(elec==1,:,:);
%end


%%%% ARREGLAR !!

if iffastmcp
    pasop=pval;
    no_stat_roi=[];
    for ne_n =LAN.nbchan:-1:1
        if sum(stat_roi==ne_n)==0
        no_stat_roi= [ ne_n no_stat_roi ];
        end
    end
    
    pasop(no_stat_roi,:)=1;
    ind_fn = pval>=fastmcp;
    ind_fn = logical(ind_fn(:)); 
end





    
   if (~mdif )||( bias==1)
       
            %TRI = datasimul(:,:,randperm(size(datasimul,3))); % permute trials
            %pasor{1} = mean(datasimul(:,:,1:l(1)),3);       % simulates ERP a
            %pasor{2} = mean(datasimul(:,:,1+l(1):l(1)+l(2)),3); % simulates ERP b
             %if length(cond(group==g))>2
             if mdif
                 types = unique(abs(matdif(group==g)));
             else
                 types = cond(group==g);
             end
             
                for nc = 1:length(types)
                pasor{nc}(:,:,:) = mean(TRI(:,:,(1+ntc(nc)):(ntc(nc+1))),3);   
                end
             %end
           
              for nc = 1:length(types)
                  % laplace transfor to simulated ERP wave
              %    if iflaplace && (isfield(cfg,'G')&&isfield(cfg,'H'))
              %          pasor{nc} = CSD(pasor{nc}, cfg.G, cfg.H, 0.00001, 10);
              %    end
              %aa{nc}(nr,1,1,s) = sum(sum(pasor{nc}.*refclu,1),2) / sum(sum(refclu)); % only cluster Tlectrode x Time             
              aa{nc}(:,1,1,s) = pasor{nc}(~ind_fn); 
              end
              clear paso*      

 
        
%         w = 10*nr/nrandom;
%         if w > ww
%              fprintf('%2.0f%%>', ((ww*10)/length(sujetos{g})  )+( (s-1)*100/length(sujetos{g}))    );
%             ww = ww+1;
%         elseif nr==1 %&& s==1
%             fprintf('%2.0f%%>',( (s-1)*100/length(sujetos{g})) );
%         end
      elseif (mdif) && ( bias==0)
            %datasimul =   datasimul(:,:,randperm(size(datasimul,3)));
            t=[];
            llv = 0;
            for c = 1:length(cond)
                paso = mean(datasimul(:,:,llv+1:llv+l(c)),3);
                       % laplace transfor to simulated ERP wave
                 %      if iflaplace && (isfield(cfg,'G')&&isfield(cfg,'H'))
                 %         paso = CSD(paso, cfg.G, cfg.H, 0.00001, 10);
                 %      end
                %t(c) = mean(mean(paso.*clu,2),1); 
                for nc = 1:length(cond(group==g))
                    
                t(c,:,:) = paso;
                end
            %llv = llv + l(c);
            end
            
            for iii = unique(abs(matdif))
            g1index = (abs(matdif)==iii).*sign(matdif);
            g1index = g1index(logical(abs(matdif)==iii));
           
            pasor = t(logical(abs(matdif)==iii),:,:).* repmat(g1index',[1,size(t,2),size(t,3)]);
            aa{iii}(nr,:,1,s) = pasor(~ind_fn);
            end
            

        
%         w = 10*nr/nrandom;
%         if w > ww
%              fprintf('%2.0f%%>', ((ww*10)/length(sujetos{g})  )+( (s-1)*100/length(sujetos{g}))    );
%             ww = ww+1;
%         elseif nr==1 %&& s==1
%             fprintf('%2.0f%%>',( (s-1)*100/length(sujetos{g})) );
%         end
       
       
   end

end % for s
%clear datasimul
end % for g

%%% end % for ix g-c

% ----
textop = plus_text(texto,'Permutations:');
textop = plus_text(textop,'...');
%texto = plus_text(texto,'...');

%for nr = 1:nrandom
clear paso  

 %for na = 1:length(aa)
     % extraer los datos y borrar
     %paso{na} = aa{na}(1,:,:,:);
     %aa{na}(1,:,:,:)=[]; 
 %end

textop=bar_wait(nr,nrandom,['pre(#' num2str(nr) ')'],textop);
%[borra1n , borra2n ] = nonparametric(aa,alpha,m,0,texto,1);

%[borra1 , borra2 ] = nonparametric(aa,alpha,m,0,texto,1);

%clear aa
pc = [];
pc.paired=true;
pc.method='rank';
pc.text=textop;
[borra1 , borra3 ] = lan_nonparametric(aa,pc);

%paso = zeros(size(hh));
%paso(stat_roi,:)=borra1;
%borra1=paso;
borra2 = false(size(borra1));
borra2(borra1<alpha)=true;
try
    borra3 = borra3.zval;
catch
    borra3 = borra3.chistat;
end
%    paso = zeros(size(hh));
%    paso(stat_roi,:)=borra3;
%    borra3=paso;
clear aa
%
   
if iffastmcp
    rhh = zeros(size(hh));
    rstat = zeros(size(hh));
    r_pv = pval;
    r_pv(~ind_fn) = borra1;
    rhh(~ind_fn) = borra2;
    rstat(~ind_fn) = borra3;
    r_pv = 1-r_pv;
else
    r_pv=1-borra1;
    rhh = borra2;
    rstat = borra3;
end
   %clear borra*


        %%%MAKE NEW 3D ARRAY
            for e = 1:nbchan
                [y(e) x(e)] = find(electrodemat==e);
                newhh(y(e),x(e),:) = rhh(e,:);
                if sig
                sigst(y(e),x(e),:)=sign(stat(e,:));
                end
            end% for e
               if sig
                   p_n = newhh;
                   p_n(sigst==-1)=0;
                   clusig_b = bwlabeln(p_n);
                   p_n = newhh;
                   p_n(sigst==1)=0;
                   p_p =(bwlabeln(p_n));
                   clusig_b = clusig_b + p_p + (max(max(max(p_p))))*(p_p~=0) ;
                   %clusig_b = clusig_b + (bwlabeln(p_n)) + (max(max(max(clusig_b))))*(clusig_b~=0) ;
                   %clusig_b = clusig_b + (bwlabeln(p_n)) + max(max(max(clusig_b)));
               else
                   clusig_b = bwlabeln(newhh);
               end  
            for e = 1:nbchan
                %[y x] = find(electrodemat==e);
                r_clusig(e,:)=clusig_b(y(e),x(e),:);
            end% for e 
            %%% check 
            if size(clusig)~=size(hh), error('mala transformacion'),end
            clear clusig_b newhh x y

        %%% buscado el mayor cluster de la comparacion randoms
        if max(max(r_clusig))>0
        for cc = 1:max(max(r_clusig))
            clu = zeros(size(r_clusig));
            clu(r_clusig==cc)=1;
            r_statclusig(cc) = sum(sum(sum(abs(rstat).*clu))); % suma del valor estadistico
            r_statclusign(cc) = sum(sum(sum(clu)));      % numero de puntos
        end
        r_maxclusig = r_statclusig==max(r_statclusig); 
        if sum(r_maxclusig)>1% si hay dos iguales tomamos el mas extenso
            r_maxclusig = (r_maxclusig.*r_statclusign)==max(r_maxclusing.*r_statclusign);
        end
        r_maxclusig = find(r_maxclusig==1);
        r_maxclusig = r_maxclusig(1);
        rclu = zeros(size(clusig));
        rclu(r_clusig==r_maxclusig)=1;
        
        
        
        W(nr) = sum(sum(abs(rstat).*rclu));        
        end

end % nr


clear borra*
end%%%% 001end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% distribucion de probabilidad
%%% por permutacion de sujetos
%%% Estadistica independiente

if strcmp(m,'i') %%% 002start

%fprintf('Permuting subject n=%5.0f',nrandom);
% ----
textop = plus_text(texto, [ 'Permuting subject n= ' num2str(nrandom) ]);
textop = plus_text(textop,'...');
%texto = plus_text(texto,'...');

%textop =[ 'Permuting subject n= ' num2str(nrandom) ] ;
clear aa l
%la = 0;lb =0;
if mdif
    ng = unique(abs(matdif));
        for ix = 1:length(ng)
            ixp = find(group==ix,1);
            if ~isempty(v_erp{group(ixp),cond(ixp)})
            l(ix) = size(v_erp{group(ixp),cond(ixp)},3);    
            end
        end
        
    datasimul = cat(3,GLAN.erp.subdatadif{:});    
    
else
    
    
        datasimul = v_erp{group(1),cond(1)};
        
        for ix = 1:length(group)
        if ~isempty(v_erp{group(ix),cond(ix)})
        l(ix) = size(v_erp{group(ix),cond(ix)},3);    
            if ix>1
               datasimul = cat(3,datasimul,v_erp{group(ix),cond(ix)});
            end
        end
        
        
        end
    
    %datasimul = datasimul.*repmat(refclu,[1,1,size(datasimul,3)]);
    %datasimul = squeeze(sum(sum(datasimul,2),1))/sum(sum(refclu));
end

% olvidar areas lejos de la significancia
if iffastmcp
    ind_fn = pval>=fastmcp;
    ind_fn = logical(ind_fn(:)); 
end



for nr = 1:nrandom
    %if ~mod(nr-1,fix(nrandom/200))
        fprintf('.')
    %end
    
    
pasodata =   datasimul(:,:,randperm(size(datasimul,3)));



% cluster mayor
if mdif
    ng = unique(abs(matdif));
else
    ng= group;
end
for ix = 1:length(ng)
        for is=  1:l(ix)  
           paso =  pasodata(:,:,is);
           
           % ojo !!!
           if iffastmcp
              paso(ind_fn) = [];
              aa{ix}(:,1,1,is) = paso; 
           else
              aa{ix}(:,:,1,is) = paso; 
           end
           %paso(refclu==0)=[];
           %
           
           clear paso
        end
        pasodata(:,:,1:l(ix)) = [];
end

textop = plus_text(texto,'Permutations:');
textop = plus_text(textop,'...');
%texto = plus_text(texto,'...');

%for nr = 1:nrandom
clear paso  

 %for na = 1:length(aa)
     % extraer los datos y borrar
     %paso{na} = aa{na}(1,:,:,:);
     %aa{na}(1,:,:,:)=[]; 
 %end

textop=bar_wait(nr,nrandom,['pre(#' num2str(nr) ')'],textop);

%[borra1 borra2] = nonparametric(aa,[],alpha,m,0,[],0);
%clear aa
pc = [];
pc.paired=false;
pc.method='rank';
pc.text=textop;
[borra1 , borra3 ] = lan_nonparametric(aa,pc);
borra2 = false(size(borra1));
borra2(borra1<alpha)=true;
try
    borra3 = borra3.zval;
catch
    borra3 = borra3.chistat;
end
clear aa
%


% ojo!!!
if iffastmcp
    rhh = zeros(size(hh));
    rstat = zeros(size(hh));
    r_pv = pval;
    r_pv(~ind_fn) = borra1;
    rhh(~ind_fn) = borra2;
    rstat(~ind_fn) = borra3;
    r_pv = 1-r_pv;
else
    r_pv=1-borra1;
    rhh = borra2;
    rstat = borra3;
end
   clear borra*


        %%%MAKE NEW 3D ARRAY
        %%%MAKE NEW 3D ARRAY
            for e = 1:nbchan
                [y(e) x(e)] = find(electrodemat==e);
                newhh(y(e),x(e),:) = rhh(e,:);
                if sig
                sigst(y(e),x(e),:)=sign(stat(e,:));
                end
            end% for e
               if sig
                   p_n = newhh;
                   p_n(sigst==-1)=0;
                   clusig_b = bwlabeln(p_n);
                   p_n = newhh;
                   p_n(sigst==1)=0;
                   p_p =(bwlabeln(p_n));
                   clusig_b = clusig_b + p_p + (max(max(max(p_p))))*(p_p~=0) ;
                   %clusig_b = clusig_b + (bwlabeln(p_n)) + (max(max(max(clusig_b))))*(clusig_b~=0) ;
                   %clusig_b = clusig_b + (bwlabeln(p_n)) + max(max(max(clusig_b)));
               else
                   clusig_b = bwlabeln(newhh);
               end  
            for e = 1:nbchan
                [y x] = find(electrodemat==e);
                r_clusig(e,:)=clusig_b(y,x,:);
            end% for e 
            %%% check 
            if size(clusig)~=size(hh), error('mala transformacion'),end
            clear clusig_b newhh

        %%% buscado el mayor cluster de la comparacion randoms
        if max(max(r_clusig))>0
        for cc = 1:max(max(r_clusig))
            clu = zeros(size(r_clusig));
            clu(r_clusig==cc)=1;
            r_statclusig(cc) = sum(sum(sum(abs(rstat).*clu))); % suma del valor estadistico
            r_statclusign(cc) = sum(sum(sum(clu)));      % numero de puntos
        end
        r_maxclusig = r_statclusig==max(r_statclusig); 
        if sum(r_maxclusig)>1
            r_maxclusig = (r_maxclusig.*r_statclusign)==max(r_maxclusing.*r_statclusign);
        end
        r_maxclusig = find(r_maxclusig==1);
        r_maxclusig = r_maxclusig(1);
        rclu = zeros(size(r_clusig));
        rclu(r_clusig==r_maxclusig)=1;
        
        
        
        W(nr) = sum(sum(abs(rstat).*rclu));        
        end
        
        
end
fprintf('\n')

clear datasimul

%[borra1 , borra2, W ] = nonparametric(aa,{},alpha,m,0,[],0);
%
%if strcmp(m,'i')
%    W = 1-borra1;
%end
clear borra*


end %%% 002end


%%% p-val por cluster
% if mdif
% g1 = size(g1data,3);
% g2 = size(g2data,3);
% v_erp{group(1),cond(1)} = g1data;
% v_erp{group(2),cond(2)} = g2data;
% else
%     for ix = 1:length(group)
%     g(ix) = size(v_erp{group(ix),cond(ix)},3);
%     end
% end
% 

nccont = 0;
ccont = 0;
clear aa

%For more exiget p val computing
%pp = ksdensity(W,0:1/10000:1);
%pp = pp/(sum(pp));

%stat = 1-pval;

%stat = -log10(pval);
%stat(isinf(stat)) = max(stat(~isinf(stat)))*10;


hhc = zeros(size(hh));
pvalc = ones(size(hh));
cluster = zeros(size(hh));

for cc = 1:max(max(clusig))
    clu = zeros(size(clusig));
    clu(clusig==cc) = 1;    
    Wr = sum(sum(abs(stat).*clu));
p_val_c = sum(Wr <= W)/nrandom;
     if p_val_c <= alphap
            ccont = 1 + ccont;
            hhc(clusig==cc)=1;
            pvalc(clusig==cc) = p_val_c;
            cluster(clusig==cc) = ccont;
     else
           nccont =  nccont -1;
           pvalc(clusig==cc) = p_val_c;
           cluster(clusig==cc) = nccont;
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
%for nc =1:length(cond)
%paso(group(nc),cond(nc)) = nc;
%ccc(nc) = find(paso==nc);
%end
GLAN.erp.comp{nbcomp}(1,:)=cond;
GLAN.erp.comp{nbcomp}(2,:)=group;
if mdif
   GLAN.erp.matdif{nbcomp}=matdif;
   %GLAN.erp.comp{nbcomp} = [ maxcomp , maxcomp+1];
end
%%%%
%%%
GLAN.infolan.version = lanversion;
GLAN.infolan.date = date;
      if ~isfield(GLAN.infolan, 'creation_date')
      GLAN.infolan.creation_date=date;    
      end
      
      
      % delete temporal file
      try
         if mcp
         if isunix
             system('rm tempLAN*.mat');
         elseif ispc
            system('del tempLAN*.mat');
         end
         end
      end
      
end%%% END OF THE FUNCTION
%%%

%%%
%%%
%%%

