function GLAN = timefreq_stata(GLAN,cfg)
%           <*LAN)<]
%  
% v.1
% REALIZA ESTADISTICA NOPARAMETRICA A TRIEMP-FRECUENCIA
% cfg.
%  subject  =   [{'ID11' ,'ID12' , ...} , {'ID21' , 'ID22' , ...} , ... ]
%             % subjects' ID per group
%  groupname =  {'controls' , 'case' , ...}
%             % groups' ID
%  conditionname = {'task', 'rest', ...}
%  comp 	=[n1 n2];  	% INDEX OF THE CONDITION TO COMPARED
%  group    =[g1  g2];  % INDEX OF THE CONDITION TO COMPARED
%   to compare two contrast
%     comp = [ c1 c2 c3 c4]
%     group = [g1 g1 g2 g2]
%     matdif   = [1 -1 2 -2]
%     matdif_transform = 'log', 'none', 'log10'
%
% --------------------------------------------------------
%  %% EN implementacion
%   model for second levels 
%   to activite this option it is requiered that cfg.stata was setted in
%   thesos option 
%     stata,'glm'
%     stata,'robust'
%     stata,'lme'
%
%   glm_matrix = [ ]
%  RegressorOI
% -------------------------------------------------
%  stata =   'nonparametric' || 1
%             
%  data_type = 'pow', 't', 'b'      
%  alpha 	=0.05;
%  m		='d'; OR ='i' 	% RELATIONSHEAP TO THE SAMPLES 'i'NDEPENDENT OR 'd'EPENDET
%  bl		=[ 0 0.4];	% BASELINE
%  norma   = 'mdB'
%  mcp      = 1 or 0
%  nrandom  = 2000
%  delelectrode = [elec_1 elec_n ... ] % ELECTRODES EXCLUIDED TO THE ANALISIS
%  mean_eoi = [elec_1 elec_n ...] Electrodos of interes for mean analsis 
%  savesub = 0  % save matrix per subjects  
%  range = [f1 f2]
%  permute_name = { 'Real', 'Permut1', 'Permutex', ...}
%  matname  = 'str'                                 special carater:
%  .................                                     %S subjectname
%  filename  = 'str'                                     %G groupname 
%                                                        %C conditionname  
%                                                        %R permute indicator
%                                                         
%  .................
%  nbcomp = n % to do mcp in a pre-calculated uncorreted stat. 
%  mcp_fast = 0.9
%  Pablo Billeke
%  Rodrigo Henriquez
%  Francisco Zamorano

% 10.07.2023 (PB) fix time in models
% 28.04.2020 (PB) fix an error in permutation test por paired data with null/permute  models! 
% 08.07.2019 (PB) improving multiple comparison correction for cluters
%                 paired samples and null/permute  models!
% 15.02.2018 (PB) improve multiple comparison correction for cluters
%                 no-paired samples 
% 06.06.2013 (PB) fix mean for timefreq.data
% 15.05.2013 (PB) fix empty matdif
% 28.10.2012
% 29.08.2012 (PB) fix condition name bug
% 13.08.2012
% 05.07.2012 (PB) new segmetation and timefreq_plot compativility       
% 03.02.2011               (PB) compatibility with FT in  .lan file
%                          improve permutation for cluter correction 
% 01.07.2010 (PB) opcion guardar cartas por sujeto, solo realizas
%                 promedios, optimizar rapidez de MCP por electrodos,
%                 descartar electrodos del analisis.
% 28.04.2010
% 27.04.2010

if nargin == 0
    help timefreq_stata.m
    edit timefreq_stata.m
    return
end

% search subject name
try 
sujetos = cfg.subject;
GLAN.suject=sujetos;
catch
    try
        sujetos = GLAN.subject;
    catch
%    error('you must defined subject name in cfg.subject')
    end
end
%

try
    savesub = cfg.savesub;
catch
    savesub=1;
end

no1_st=0;
%--  SEARCH COMPARATION
if isfield(cfg,'nbcomp') & isfield(GLAN,'timefreq');
    if cfg.nbcomp<=size(GLAN.timefreq.comp,2)
       nbcomp = cfg.nbcomp;
       no1_st=1;
    else
       nbcomp=size(GLAN.timefreq.comp,2)+1;
    end
elseif isfield(GLAN,'timefreq') %&& ~isempty(GLancomp)
      nbcomp=size(GLAN.timefreq.comp,2)+1;
else
      nbcomp=1;
end



% data_type
  getcfg(cfg,'data_type','pow')
  if ~isfield(GLAN , 'timefreq' ) | iscell(GLAN.timefreq.cfg.data_type) | ~isfield(GLAN.timefreq.cfg,  'data_type' )
  GLAN.timefreq.cfg.data_type{nbcomp}=data_type;
  else
  GLAN.timefreq.cfg.data_type = {GLAN.timefreq.cfg.data_type };
  GLAN.timefreq.cfg.data_type{nbcomp} = data_type;
  end

if (strcmp(data_type,'t'))||(strcmp(data_type,'b'))
    ifmodel=true;
else
    ifmodel=false;
end


%



%-- type of stadistic
glm_matrix = getcfg(cfg,'glm_matrix',[]);
stata = getcfg(cfg,'stata','nonparametric'); % nonparamteric default
if ischar(stata)
    ifstata = true;
else 
    ifstata = logical(stata);
    if ifstata && isempty(glm_matrix)
       stata = 'nonparametric';
    elseif ifstata && ~isempty(glm_matrix)
       stata = 'glm';
    end
end

if strcmp(stata,'glm') || strcmp(stata,'robust') || strcmp(stata,'lme')
    RegressorOI = getcfg(cfg, 'RegressorOI',1);
end

% if strcmp(stata,'glm') && isempty(glm_matrix)
%     
% end

%-- 

savetempfile = getcfg(cfg, 'savetempfile',0);
tempfilename = getcfg(cfg, 'tempfilename','');

if ~isempty(tempfilename)
 savetempfile=1
end

try
cond = cfg.comp;
GLAN.timefreq.comp{nbcomp}(1,:)=cond;
%GLAN.timefreq.comp{nbcomp}(2,:)=group;
catch
    try
    nbcomp = nbcomp -1;
    cond = GLAN.timefreq.comp{nbcomp};
    disp('we compared the last contition in GLAN.comp, which would repite a realizated comparison')
    catch
    error('you must defined index of condition to compared');
    end
end


%---search relation to samples
% try
% m = cfg.s;
% GLAN.timefreq.cfg.s{nbcomp} = m;
% catch
%     try
% m = GLAN.timefreq.cfg.s{nbcomp};
% catch
% m = 'd';
% GLAN.timefreq.cfg.s{nbcomp} = m;
% disp('you don'' defined the relatioship to the samples, so  we used statistic for Dependent samples');
%     end
% end

%---search relation to samples
m = getcfg(cfg, 's', 0 );
if m == 0
   m = getcfg(cfg, 'm', 'i' );    
end
  if ~isfield(GLAN.timefreq.cfg,  's' ) | iscell(GLAN.timefreq.cfg.s) 
  GLAN.timefreq.cfg.s{nbcomp} = m;
  else
  GLAN.timefreq.cfg.s = {GLAN.timefreq.cfg.s };
  GLAN.timefreq.cfg.s{nbcomp} = m;
  end


%---

ifsmooth = getcfg(cfg, 'ifsmooth', 1 );

%--search frequency range
try 
    range = cfg.range;
catch
    range = [];
end
%--

%--search alpha
try
alpha = cfg.alpha;
GLAN.timefreq.cfg.alpha{nbcomp} = alpha;
catch
    try
alpha = GLAN.timefreq.cfg.alpha{nbcomp};
catch
alpha = 0.05;
GLAN.timefreq.cfg.alpha{nbcomp} = alpha;
disp('you don'' defined the alpha, so  we''ll use 0.05 ');
    end
end
%--


%--search relation between samples
try
    bl = cfg.bl;
    GLAN.timefreq.cfg.bl{nbcomp} = bl;
catch
    try
        bl = GLAN.timefreq.cfg.bl{nbcomp-1};
    catch
        bl= 0;
        GLAN.timefreq.cfg.bl{nbcomp} = bl;
        disp('you did not define the baseline [cgf.bl] ');
    end
end
GLAN.timefreq.cfg.bl{nbcomp} = bl;
%--

getcfg(cfg,'norma','mdB',{'z','m','mdB'})

%-- SEARCH STATISTICAL CONFIGURATIONS
try
    mcp = cfg.mcp;
catch
    mcp=0;
    disp('I''ll not made correction for multiple comparison')
end

if mcp ==1
    try
        nrandom = cfg.nrandom;
    catch
        nrandom = 2000;

    end
    
  % data_type
  getcfg(cfg,'mcp_fast',0.9)
end
%--


%--serach electrode localization
if isfield(cfg,'chanlocs')
    GLAN.chanlocs = cfg.chanlocs;
end
%--

% mean electrods of interes 
mean_eoi = getcfg(cfg,'mean_eoi',[]); % esto no esta implementado  



%--mat file name and path for subject
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
%-- permute indicator names 
permute_name = getcfg(cfg,'permute_name', [] );
if isempty(permute_name)
    permute_name = {''};
end

%--
%--
time = getcfg(cfg,'time','all');



%--search condition index
if (size(sujetos,2)>1 && (~iscell(sujetos{1}))) || (size(sujetos,1)==1)
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
%--
GLAN.timefreq.comp{nbcomp}(2,:)=group;
%--

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

% conditions names

conditionname = getcfg(cfg,'conditionname',0);
if ~iscell(conditionname)&&~conditionname
   conditionname = cell(1,max(group)); 
end


%-------------------------------
%
%--BEGINING OF THE COMPUTATIONS--
%
%-------------------------------


%--LOAD THE SUJECT'S MAT FILE


texto =plus_text();
disp_lan(texto);

if ~no1_st
pasog = 1;
for g = unique(abs(group))
%     % no repetir condiciones/grupos ya extraidos
%     if pasog >1;
%         if group(pasog)==g
%             pasog = pasog +1;
%             continue
%         end
%     end
%    pasog = pasog+1;
    
texto = plus_text(texto,[ 'group: ' groupname{abs(g)} ]); 
disp_lan(texto)
for s = 1:length(sujetos{g})
    %texto = plus_text(texto,['load subject files ... '  ]);
    
    fprintf(['load subject files ... '  ])
    
    warning off
    filenameA = strrep( filename ,'%S',sujetos{g}{s});
    filenameA = strrep( filenameA ,'%G',groupname{g});
    filenameA = fix_path(  strrep( filenameA ,'%C',conditionname{g}));
    filenameA = fix_path(  strrep( filenameA ,'%R',permute_name{1}));
    matnameA = strrep( matname ,'%S',sujetos{g}{s});
    matnameA = strrep( matnameA ,'%G',groupname{g});
    matnameA = strrep( matnameA ,'%C',conditionname{g});
    matnameA = fix_path(  strrep( matnameA ,'%R',permute_name{1}));
    warning on 
    
    eval(['load '  filenameA '  ' matnameA ' ']);
    eval(['LAN = ' matnameA ';' ]);
    if ~strcmp('LAN',matnameA)
        eval([' clear ' matnameA])
    end
    
    if numel (permute_name)>1
       for npn= 2:numel (permute_name)
          warning off
            filenameA = strrep( filename ,'%S',sujetos{g}{s});
            filenameA = strrep( filenameA ,'%G',groupname{g});
            filenameA = fix_path(  strrep( filenameA ,'%C',conditionname{g}));
            filenameA = fix_path(  strrep( filenameA ,'%R',permute_name{npn}));
            matnameA = strrep( matname ,'%S',sujetos{g}{s});
            matnameA = strrep( matnameA ,'%G',groupname{g});
            matnameA = strrep( matnameA ,'%C',conditionname{g});
            matnameA = fix_path(  strrep( matnameA ,'%R',permute_name{npn}));
            warning on 

            eval(['PER{' num2str(npn)  '} = load( '''  filenameA ''' ,  ''' matnameA ''' );']);
            eval(['PER{' num2str(npn)  '}.LAN = PER{' num2str(npn)  '}.' matnameA ';' ]);
           
           
           
       end
        
        
        
    end

    
    
    try
       if iscell(LAN) 
       for i = 1:length(LAN)
       LAN{i}.data = []; % libera espacio inutil para la computacion
       end
       else
       LAN.data = [];    
       end
    end
    
    %--Promediar cartas tiempo frecuencias
%     try %if iscell() 
%        if iscell(LAN) 
%        for i = 1:length(LAN)%length(LAN{i}.freq.powspctrm)%
%        LAN{i}.freq.powspctrm =  mean(cat(4, LAN{i}.freq.powspctrm{:}),4)    ;   
%        end
%        else
%        LAN.freq.powspctrm =  mean(cat(4, LAN.freq.powspctrm{:}),4)    ;       
%        end
%     end
    %--



%--elimina electrodos excluidos del analisis
if isfield(cfg, 'delectrode')
    LAN = electrode_lan(LAN, cfg.delectrode);
else
    if iscell(LAN)
        if isfield(LAN{1}, 'data') && ~isempty(LAN{1}.data)
        LAN = lan_check(LAN);
        end
    else
        if isfield(LAN, 'data') && ~isempty(LAN.data)
        LAN = lan_check(LAN);
        end
    end
end
%--


%-- EXTRACT DATA FOR LAN SINGLE STRUCTURS
    %texto = last_text(texto,['load subject file ' sujetos{g}{s}   ]);
    fprintf(['>>> ' sujetos{g}{s}  '\n' ]);
    for c = cond(group==g)
        
        
        % case of cell LAN
        if iscell(LAN)
        
        
        %ci = find()
            if isempty(range)
                fr = 1:length(LAN{c}.freq.freq);
            else % 
                fr(1) = find_approx(LAN{c}.freq.freq,range(1)) ;  
                fr(2) = find_approx(LAN{c}.freq.freq,range(end)) ;  
                fr = fr(1):fr(2);
            end
            switch data_type
                case 'pow'
            if isfield(LAN{c}.freq,'powspctrm')
                if iscell(LAN{c}.freq.powspctrm)
                mft = mean(cat(4,LAN{c}.freq.powspctrm{:}),4); 
                %--Borrar variable de frecuncias para mejorar uso de memoria 
                LAN{c}.freq.powspctrm  = [] ;
                %--
                v_freq{g,c}(:,:,:,s) = mft(fr,:,:);
                clear mft
                elseif isstruct(LAN{c}.freq.powspctrm)
                    % names of file
                    v_fn{g,c,s} = LAN{c}.freq.powspctrm.filename;     
                    v_pn{g,c,s} = LAN{c}.freq.powspctrm.path;  
                    v_vn_mean{g,c,s} = LAN{c}.freq.powspctrm.mean;
                    v_vn_trials{g,c,s} = LAN{c}.freq.powspctrm.trials;
                    % data
                    try
                        paso = lan_getdatafile(v_fn{g,c,s},v_pn{g,c,s},v_vn_mean{g,c,s});
                    catch % por cambios de path desde la creacion del archivo
                        pasoi = findstr(filenameA,'/');
                        pasoi = pasoi(end)-1;
                        paso = lan_getdatafile(v_fn{g,c,s},filenameA(1:pasoi),v_vn_mean{g,c,s});
                        v_pn{g,c,s} = filenameA(1:pasoi);
                        end
                    v_freq{g,c}(:,:,:,s) = paso(fr,:,:);    
                    clear paso*
                else
                v_freq{g,c}(:,:,:,s) = LAN{c}.freq.powspctrm(fr,:,:);    
                end
                
                
            end
                
                    
            end
        if s == 1  %%% KEEP SPEFIFICATION FOR DEL GLAN STRUCTUR
                GLAN.time = LAN{c}.time(1,:);    
                GLAN.srate = LAN{c}.srate; 
                GLAN.nbchan = LAN{c}.nbchan;
                nbchan = LAN{c}.nbchan;
                GLAN.timefreq.freq = LAN{c}.freq.freq;
                if isfield(cfg, 'range')
                   uno = find(LAN{c}.freq.freq==range(1));
                   dos = find(LAN{c}.freq.freq==range(2));
                   GLAN.timefreq.freq = LAN{c}.freq.freq(uno:dos);
                end
                GLAN.timefreq.time = LAN{c}.freq.time;
                GLAN.timefreq.cond{c} = LAN{c}.cond;
                %GLAN.timefreq.cond{cond(2)} = LAN{cond(2)}.cond;
                
                 try
                                GLAN.chanlocs = cfg.chanlocs
                  end
                
                
                    if ~isfield(GLAN,'chanlocs')
                        try

                            GLAN.chanlocs = LAN{c}.chanlocs;
                        catch
                            disp('There is not channel location file')
                        end
                    end
        end
        
        % case of structure LAN
        elseif isstruct(LAN) && (isfield(LAN,'conditions') || ifmodel  )
            
            if isempty(range)
                if ifmodel && isfield(LAN.freq.model,'freq')
                fr = 1:length(LAN.freq.model.freq);
                else
                fr = 1:length(LAN.freq.freq);
                end
            else % 
                try
                if ifmodel && isfield(LAN.freq.model,'freq')
                fr(1) = find_approx(LAN.freq.model.freq,range(1)) ;  
                fr(2) = find_approx(LAN.freq.model.freq,range(end)) ;  
                fr = fr(1):fr(2);
                else
                fr(1) = find_approx(LAN.freq.freq,range(1)) ;  
                fr(2) = find_approx(LAN.freq.freq,range(end)) ;  
                fr = fr(1):fr(2);
                end
                catch
                fr = range(1):range(2);    
                end
            end
            
            switch data_type
                case 'pow'
            if isfield(LAN.freq,'powspctrm')
                 if iscell(LAN.freq.powspctrm)%
                     ind = LAN.conditions.ind{c};
                     if length(ind)== length(LAN.accept)
                        ind(~LAN.accept) =0;
                     else
                         error('arregalr esta parte del script!!!')
                     end
                     mft = mean(cat(4,LAN.freq.powspctrm{ind}),4); 
                 %--
                 v_freq{g,c}(:,:,:,s) = mft(fr,:,:);
                 clear mft
                 elseif isstruct(LAN.freq.powspctrm)
                    % names of file
                    v_fn{g,c,s} = LAN.freq.powspctrm.filename;     
                    v_pn{g,c,s} = LAN.freq.powspctrm.path;  
                    v_vn_mean{g,c,s} = LAN.freq.powspctrm.mean;
                    v_vn_trials{g,c,s} = LAN.freq.powspctrm.trials;
                    ind = LAN.conditions.ind{c};
                    if any(ind>1)
                       paso = false(size(LAN.accept));
                       paso(ind) = true;
                       ind =paso;
                    end
                    %ind(~LAN.accept) =false;
                    v_ind{g,c,s} =  ind;
                    % data
                    try
                        paso = lan_getdatafile(v_fn{g,c,s},v_pn{g,c,s},v_vn_trials{g,c,s});
                    catch % por cambios de path desde la creacion del archivo
                        pasoi = findstr(filenameA,'/');
                        pasoi = pasoi(end)-1;
                        paso = lan_getdatafile(v_fn{g,c,s},filenameA(1:pasoi),v_vn_trials{g,c,s});
                        v_pn{g,c,s} = filenameA(1:pasoi);
                    end
                    
                    %
                    if length(paso)== length(LAN.accept)
                       v_ind{g,c,s}(~LAN.accept) =false;
                    elseif length(paso) == sum(LAN.accept)
                       v_ind{g,c,s}(~LAN.accept) =[];
                    elseif length(paso) == length(fix_cero_end(LAN.accept))
                           [AA nn] = fix_cero_end(LAN.accept);
                           paso(end+1:end+nn) = {[]};
                           v_ind{g,c,s}(~LAN.accept) =false;
                    else   
                          
                       error('The length of ft trials is not the same that accepted trials ')
                    end
                    %
                    
                    paso = cat(4,paso{v_ind{g,c,s}}); 
                    paso = mean(paso(fr,:,:,:),4); 
                    if isnumeric(time)&&(numel(time)==2)
                        pasoi = true(1,size(paso,3)); % time
                        pasoi((LAN.freq.time<min(time))|(LAN.freq.time>max(time))) = false;
                        paso = paso(:,:,pasoi,:);
                    end
                    v_freq{g,c}(:,:,:,s) =    paso;
                    clear paso*
                 else
                    error('? LAN fixME')
                %v_freq{g,c}(:,:,:,s) = LAN{c}.freq.powspctrm(fr,:,:);    
                end
                
                
            end
                case 't'
                
                    paso =     LAN.freq.model.t{c}(fr,:,:); 
                    if isnumeric(time)&&(numel(time)==2)
                            pasoi = true(1,size(paso,3)); % time
                            pasoi((LAN.freq.time<min(time))|(LAN.freq.time>max(time))) = false;
                            paso = paso(:,:,pasoi);
                    end
                    v_freq{g,c}(:,:,:,s) = paso;
                
                    % permute file 
                     if numel(permute_name)>1
                        for npn = 2:numel(permute_name) 
                        paso =     PER{npn}.LAN.freq.model.t{c}(fr,:,:); 
                        if isnumeric(time)&&(numel(time)==2)
                                pasoi = true(1,size(paso,3)); % time
                                pasoi((PER{npn}.LAN.freq.time<min(time))|(PER{npn}.LAN.freq.time>max(time))) = false;
                                paso = paso(:,:,pasoi);
                        end
                        np_freq{g,c,npn-1}(:,:,:,s) = paso;
                        end
                     end
                
                
                
                case 'b'
                paso =     LAN.freq.model.b{c}(fr,:,:); 
                    if isnumeric(time)&&(numel(time)==2)
                            pasoi = true(1,size(paso,3)); % time
                            pasoi((LAN.freq.time<min(time))&(LAN.freq.time>max(time))) = false;
                            paso = paso(:,:,pasoi);
                    end
                v_freq{g,c}(:,:,:,s) = paso;                 
                    % permute file 
                     if numel(permute_name)>1
                        for npn = 2:numel(permute_name) 
                        paso =     PER{npn}.LAN.freq.model.b{c}(fr,:,:); 
                        if isnumeric(time)&&(numel(time)==2)
                                pasoi = true(1,size(paso,3)); % time
                                pasoi((PER{npn}.LAN.freq.time<min(time))|(PER{npn}.LAN.freq.time>max(time))) = false;
                                paso = paso(:,:,pasoi);
                        end
                        np_freq{g,c,npn-1}(:,:,:,s) = paso;
                        end
                     end
                
                
            end
        if s == 1  %%% KEEP SPEFIFICATION FOR DEL GLAN STRUCTUR
                GLAN.time = LAN.time(1,:);    
                GLAN.srate = LAN.srate; 
                GLAN.nbchan = LAN.nbchan;
                nbchan = LAN.nbchan;
               
                if isfield(cfg, 'range')
                    try
                        uno = find(LAN.freq.freq==range(1));
                        dos = find(LAN.freq.freq==range(2));
                        GLAN.timefreq.freq = LAN.freq.freq(uno:dos);
                    catch
                        GLAN.timefreq.freq = range; 
                    end
                else
                        if ifmodel && isfield(LAN.freq.model,'freq')   
                        GLAN.timefreq.freq = LAN.freq.model.freq;
                        else
                        GLAN.timefreq.freq = LAN.freq.freq;
                        end    
                    
                end
                try
                if ifmodel && isfield(LAN.freq.model,'time')   
                GLAN.timefreq.time = LAN.freq.model.time;
                else
                GLAN.timefreq.time = LAN.freq.time;
                end    
                
                end
                %GLAN.timefreq.cfg = cfg;
                try
                    if ifmodel
                        GLAN.timefreq.cond{c} = LAN.freq.model.r{c};
                    else
                        GLAN.timefreq.cond{c} = LAN.conditions.name{c};
                    end
                
                %
                catch
                    try
                    GLAN.timefreq.cond{c} = LAN{c}.cond;   
                    catch
                    GLAN.timefreq.cond{c} = '?';       
                    end
                    
                end
                    if ~isfield(GLAN,'chanlocs')
                        try
                            GLAN.chanlocs = LAN.chanlocs;
                        catch
                            disp('There is not channel location file')
                        end
                    end
        end    
            
            
            
        end % end LAN cell or structur
    end
    clear LAN PER;
    %eval(['clear ' sujetos{g}{s} ' ']);
    
end % by subject
end % by group

end % no1_st



%---------------------------
% STATISTICAL COMPUTATIONS %
%---------------------------

% chequera matrices de diferencias
if isfield(cfg,'matdif')&&(~isempty(cfg.matdif))
    mdif =1;
    getcfg(cfg,'matdif')
    getcfg(cfg,'matdif_transform','none')
    getcfg(cfg,'matw',[])
    if isempty(matw)
        matw=ones(size(matdif));
    end
else
    mdif=0;
end


% smooth 
if ifsmooth==1
   for i = 1:length(abs(group))
       paso= v_freq{abs(group(i)),cond(i)};
      [df, de, dt, ds] = size(paso) ;
      for ie= 1:de
          for is= 1:ds
              %paso
              paso(:,ie,:,is) = lan_smooth(squeeze(paso(:,ie,:,is)));
          end
      end 
      v_freq{abs(group(i)),cond(i)}=paso;
   end
end


if ifstata && ~mdif && ~no1_st
    
    a =[];
    for i = 1:length(cond)
    a{i} = v_freq{group(i),cond(i)};
        % baseline correction
        if length(bl)>1
            nm1 = find_approx(GLAN.timefreq.time , bl(1));
            nm2 = find_approx(GLAN.timefreq.time , bl(end));
            for nm = 1:size(a{i},4)
                a{i}(:,:,:,nm) = normal_z(a{i}(:,:,:,nm) ,a{i}(:,:,nm1:nm2,nm),norma );
            end
        end
    end
    
    
    switch stata
        case {'nonparametric'}
            cfg.paired = strcmp(m,'d');
            cfg.text = texto;
            cfg.method = 'rank';
            %[pval, hh, stat] = nonparametric(a,[],alpha,m,0,texto);
            [pval, stat] = lan_nonparametric(a,cfg);
        case {'glm','robust', 'mle'}
            cfgM=[];
            cfgM.type = stata ; %'glm'; % , 'robust', 'lme' % -------------------------------------------------------
            cfgM.ops = ['pre(Second Level ' stata    ' MODEL)' ];
            cfgM.texto = texto;
            
            Regressors=[];
            for nR =1:size(glm_matrix,2)
               Regressors{nR} =  glm_matrix(:,nR)';
            end
            
            for i = 1:length(a)
                if isempty(Regressors)
                [r_pval r_stat] = lan_model_stat(a{i}, cfgM);    
                else
                [r_pval r_stat] = lan_model_stat(cat(2,a(i),Regressors{:}), cfgM);
                end
                pval{group(i),cond(i)}=r_pval{RegressorOI};
                stat{group(i),cond(i)}=r_stat.t{RegressorOI};
                betas{group(i),cond(i)}=r_stat.b{RegressorOI};
            end
            
            % for MCP calculatation will be use A and not  v_freq
            %clear v_freq
        otherwise
            error(['ERROR: stata: '  stata ' UNKOWN'] );
    end
    
    % Save results in the LAN structur 
    
    %-------case of model glm   robust lme-------
    if iscell(pval)
    GLAN.timefreq.stat(:,nbcomp) = stat(:)';   
    GLAN.timefreq.pval(:,nbcomp) = pval(:)';
    for np = 1:length(pval)
    hh = false(size(pval{np}));
    hh(pval{np}<alpha)=true;
    GLAN.timefreq.hh{np,nbcomp} = hh  ;
    GLAN.data = betas;
    end
    %----------------------------------------------

    else

    GLAN.timefreq.stat{nbcomp} = stat;   
    GLAN.timefreq.pval{nbcomp} = pval;
    hh = false(size(pval));
    hh(pval<alpha)=true;
    GLAN.timefreq.hh{nbcomp} =hh  ;
    if length(a)==2 %&&  ~strcmp(stata,'nonparametric');
       hhsig = sign(mean(a{1},4)- mean(a{2},4));
    elseif length(a)==1 %&&  ~strcmp(stata,'nonparametric');
       hhsig = sign(mean(a{1},4)); 
    end
    end
elseif ifstata && mdif && ~no1_st
     
    gdata =[];
    for gi = 1:max(abs(matdif))
        
       
    pasoindex = (abs(matdif)==gi).*sign(matdif).*matw;
  
    pasoindex = pasoindex(logical(abs(matdif)==gi));
    gindx = group(logical(abs(matdif)==gi));
    cindx = cond(logical(abs(matdif)==gi));
    for iii = 1:length(gindx)
    pasodata{iii} = v_freq{gindx(iii),cindx(iii)};
    end
    pasodata = op_cell(pasodata,pasoindex,'.*');
    ud = length(size(pasodata{1}))+1;
    
    %----------------------
    switch matdif_transform
        case 'log'
        pasodata = nansum(log(cat(ud,pasodata{:})),ud);      
        case 'log10'
        pasodata = nansum(log10(cat(ud,pasodata{:})),ud);     
        otherwise
        pasodata = nansum(cat(ud,pasodata{:}),ud);      
    end
      
            if iftime
                [d1 d2 d3] = size(pasodata);
                pasodata = pasodata .* (repmat(time, [d1,1,d3] ));
            end 
    gdata{gi}    = pasodata;
    clear pasodata
    end
    clear paso*

    if length(bl)>1
        nm1 = find_approx(GLAN.timefreq.time , bl(1));
        nm2 = find_approx(GLAN.timefreq.time , bl(end));
        for i = 1:gdata
        for nm = 1:size(gdata{i},4)
            gdata{i}(:,:,:,nm) = normal_z(gdata{i}(:,:,:,nm) ,gdata{i}(:,:,nm1:nm2,nm),norma );
        end
        end
    end
    %
    cfg.paired = strcmp(m,'d');
    cfg.text = texto;
    cfg.method = 'rank';
    %[pval, hh, stat] = nonparametric(a,[],alpha,m,0,texto);
    [pval, stat] = lan_nonparametric(gdata,cfg);
    %pval, hh, stat] = nonparametric(gdata,[],alpha,m,0,texto);
    GLAN.timefreq.stat{nbcomp} = -log(pval);%stat.zval;
    GLAN.timefreq.pval{nbcomp} = pval;
    hh = false(size(pval));
    hh(pval<alpha)=true; 
    
    % signo de la diferencia 
    if length(gdata)==2
       hhsig = sign(mean(gdata{1},4)- mean(gdata{2},4));
    end
    
    
	% SAVE RESULTS IN GLAN GRUPAL STRUCTURE
    if isfield(GLAN.timefreq, 'datadif')
        maxdatadif=length(GLAN.timefreq.datadif);
    elseif isfield(GLAN.timefreq, 'subdatadif')
        maxdatadif=length(GLAN.timefreq.subdatadif);
    else
        maxdatadif=0;
    end

    if savesub
            %%% save dif in differente structur        
            GLAN.timefreq.subdatadif((maxdatadif+1):(maxdatadif+length(gdata))) = gdata(:);
            %GLAN.timefreq.subdatadif{maxcomp+1} = gdata{2};
            %%% save condiction
              for g = group
              for c = cond(group==g)
                  GLAN.timefreq.subdata{g,c} = v_freq{g,c};
              end
              end
    end
    
        for g = group
              for c = cond(group==g)
                    GLAN.timefreq.data{g,c} = mean(v_freq{g,c},4);
              end
         end
      % verificar
        GLAN.timefreq.comp{nbcomp} = cat(1,cond,group,matdif);
      % verificar
        maxcond = length(GLAN.timefreq.cond(:));
		for ni = 1:length(gdata)
    		%GLAN.timefreq.datadif{maxdatadif+(ni)} = mean(gdata{ni},3);
			GLAN.timefreq.conddif{maxdatadif+(ni)} = [num2str(ni) ':' num2str(  ( (abs(matdif)==ni).*sign(matdif) )    ) ] ;
		   %GLAN.cond{maxcomp+1} = [ '2:' num2str((abs(matdif)==2).*sign(matdif))];
		end
   clear gdata

end


              %%%save condiction
              for g = group
              for c = cond(group==g)
                  if  ~no1_st
                  GLAN.timefreq.subdata{g,c} = v_freq{g,c};
                  GLAN.timefreq.data{g,c} = mean(v_freq{g,c},4);
                  else
                  v_freq{g,c}=GLAN.timefreq.subdata{g,c};
   
                  end
              end
              end

 clear v_freq;
 
 % check redundance !!
if ifstata  && ~no1_st && strcmp(stata,'nonparametric')
GLAN.timefreq.pval{nbcomp} = pval;
GLAN.timefreq.hh{nbcomp} = hh;
GLAN.timefreq.stat{nbcomp} = -log(pval);
%elseif ifstata  && no1_st && (strcmp(stata,'glm') || strcmp(stata,'robust') ||strcmp(stata,'mle'))  %, 
%GLAN.timefreq.pval{nbcomp} = pval;
%GLAN.timefreq.hh{nbcomp} = hh;
%GLAN.timefreq.stat{nbcomp} = stat;
%GLAN.timefreq.data{nbcomp} = stat;
elseif ifstata  && no1_st && strcmp(stata,'nonparametric')
pval= GLAN.timefreq.pval{nbcomp};
hh= GLAN.timefreq.hh{nbcomp};
stat= GLAN.timefreq.stat{nbcomp};
nbchan= GLAN.nbchan;    
end

% --
% MULTIPLE COMPARISON CORRECTION 
% --

if 0  % strcmp(stata,'glm')||strcmp(stata,'robust')
             intercepto = glm_matrix==1;
             intercepto = sum(intercepto,1)==size(intercepto,1);
            % if any(intercepto) && size(glm_matrix,2)==1
%               glm_matrix(:,intercepto) = []; 
            %    indexROF=1;
            % elseif ~any(intercepto) 
            %    indexROF=RegressorOI+1; 
            % else
            %    indexROF=RegressorOI; 
            % end    
    
    stat = GLAN.timefreq.stat{indexROF};
    pval = GLAN.timefreq.pval{indexROF};
    hh = false(size(pval));
    hh(pval<alpha) = true;
end



if (mcp == 1) && ifstata
        disp('Making Multiple Comparision correction')
        %stat = -log(pval);
try 
   electrodemat = GLAN.chanlocs(1).electrodemat;
   em=1;
catch
   disp('WARNING: You must specify the electrode array')
   em=0;
end

%-----------

if em~=1
    stat = -log(pval);
    [hhc pvalc cluster] = cl_random_2d(hh,stat,alpha,nrandom);
else
    %--- Mask for fast computation 
    %if mcp_fast<1
       mcp_mask = zeros(size(pval));
       mcp_mask(pval>mcp_fast)=1;
       mcp_mask(isnan(pval))=1;
    %end
    %---- Cluster por permutacion
    for  nr = 0:nrandom
        if nr
            texto = last_text(texto,[' permutation ' num2str(nr) ' of '  num2str(nrandom) ]);
        else
            texto = plus_text(texto,[' making clusters ' ]);
            disp_lan(texto);
        end
       
    
    % --  reload subject
    if nr&&strcmp(cfg.m,'d')&&strcmp(stata, 'nonparametric')
        
            %--  permute per subject 
            for g = unique(group)
                for s = 1:length(sujetos{group(1)})   % revisar!!!! 
                    switch data_type
                        case 'pow'
                            for cc = 1:length(cond)
                                    if group(cc)~=g, break, end
                                    paso{cc} = lan_getdatafile(v_fn{group(cc),cond(cc),s},v_pn{group(cc),cond(cc),s},v_vn_trials{group(cc),cond(cc),s});                            
                                    np{cc} = length(paso{cc}); 
                            end
                           paso = cat(2,paso{:});
                           paso = paso(randperm(length(paso)));
                           nll = 0;
                            for cc = 1:length(cond)
                            if group(cc)~=g, break, end    
                                paso2{cc} = mean(cat(4,paso{nll+1:nll+np{cc}}),4);  
                                v_freq{group(cc),cond(cc)}(:,:,:,s) = paso2{cc}(fr,:,:);  
                            end
                            clear paso*
                     case 't'

                            for cc = 1:length(cond)
                                
                                
                                p_suj = randi(numel(permute_name)-1);
                                
                                if group(cc)~=g, break, end  
                            
                                
                                v_freq{group(cc),cond(cc)}(:,:,:,s) = np_freq{group(cc),cond(cc),p_suj}(:,:,:,s) ;  
                                
                            end
                            clear paso*                            
                            
                            
                    end
                end
            end
            %--
    
            %-- stat % ver si se puede simplificar
            paso = [];
            for cc = 1:length(cond)
                paso{cc} = v_freq{group(cc),cond(cc)};
                    a =[];
                    
                    if length(bl)>1
                        nm1 = find_approx(GLAN.timefreq.time , bl(1));
                        nm2 = find_approx(GLAN.timefreq.time , bl(end));
                        for nm = 1:size(paso{cc},4)
                            paso{cc}(:,:,:,nm) = normal_z(paso{cc}(:,:,:,nm) ,paso{cc}(:,:,nm1:nm2,nm),norma );
                        end
                    end
                    
                  
            end
            clear v_freq
            
            cfg.paired = strcmp(m,'d');
            cfg.text = texto;
            cfg.method = 'rank';
            [pval, stat] = lan_nonparametric(paso,cfg);
            stat     = -log(pval);%stat.zval;
            hh = false(size(pval));
            hh(pval<alpha)=true; 

            %--
    %elseif    
    elseif ~nr&&strcmp(cfg.m,'i') 
        
        
         rpaso2 = [];
         if mdif
                ccont = 0;  
                for cc = (1+maxdatadif):(max(abs(matdif))+maxdatadif)
                    ccont = ccont +1;
                    rpaso2{ccont} = GLAN.timefreq.subdatadif{cc};  
                    n_cond(ccont) = size(rpaso2{ccont},4);
                end    
         else
             
                ccont = 0;
                for cc = 1:length(cond)
                    ccont = ccont +1;
                    rpaso2{ccont} = GLAN.timefreq.subdata{group(cc),cond(cc)};  
                    n_cond(ccont) = size(rpaso2{ccont},4);
                end
         end
         rpaso2 = cat(4,rpaso2{:});
    elseif ~nr&&(strcmp(stata, 'glm') || strcmp(stata, 'robust') )%% add other    mle ?
        
         if length(cond) >1
            error([' Use MCP for glm model each only per one condition  once !!!!!!']) 
         end
      
%             % detec intercep MODEL   
             intercepto = glm_matrix==1;
             intercepto = sum(intercepto,1)==size(intercepto,1);
             if any(intercepto) && size(glm_matrix,2)==1
%               glm_matrix(:,intercepto) = []; 
                indexROF=1;
             else
                indexROF=RegressorOI+1; 
             end            
        
        stat     = GLAN.timefreq.stat.t{indexROF};
        hhsig = sign(stat);
        pval = GLAN.timefreq.pval{indexROF};           
        hh = false(size(pval));
        hh(pval<alpha)=true;         
        hhsig = sign(stat); 
         
         
        
    elseif nr&&strcmp(cfg.m,'i') && strcmp(stata, 'nonparametric') 
         real_c = ones(1,n_cond(1));
         for i =  2:length(n_cond)
             real_c = [ real_c ones(1,n_cond(i))*i];
         end
         pass=0;
         while pass<100
             rand_c = real_c(randperm(length(real_c)));
             if abs(corr(rand_c(:),real_c(:)))<.75 % check it !
                 pass=100;
             else
                 pass=pass+1;
             end
         end
         
         %rpaso2 = rpaso2(:,:,:,randperm(sum(n_cond)));
         paso = [];
         %llv = 1;
         
        %--
        borrame = ones(size(mcp_mask));
        borrame(mcp_mask==1)=NaN;
        %--
        
         for cc = 1:length(n_cond)
         paso{cc} = rpaso2(:,:,:,rand_c==cc);
         %--
         paso{cc} = paso{cc}.*repmat(borrame,[1 1 1 size(paso{cc},4)]);
         %--
         %llv = llv+n_cond(cc);
         end
         cfg.paired = strcmp(m,'d');
        cfg.text = texto;
        cfg.method = 'rank';
        cfg.fast = mcp_fast;

        [pval, stat] = lan_nonparametric(paso,cfg);
        
        stat     = -log(pval);%stat.zval;
        hh = false(size(pval));
        hh(pval<alpha)=true; 

    elseif  nr&&(strcmp(stata, 'glm') || strcmp(stata, 'robust'))  %% add other    mle ?
        
        
%             % detec intercep MODEL   
             intercepto = glm_matrix==1;
             intercepto = sum(intercepto,1)==size(intercepto,1);
             if any(intercepto) && size(glm_matrix,2)==1
%               glm_matrix(:,intercepto) = []; 
                indexROF=1;
                         % Permuting Regressor for intercept model %% it is
                         % nor the preference, use non paramteric stat and
                         % firts level permutacion !!!!!!!!!
                         real_RegressorOI = glm_matrix(:,RegressorOI);
                         pass=0;
                         %while pass <100;
                             rand_RegressorOI = real_RegressorOI .* (sign(randi(2,size(real_RegressorOI))-1.5));
                         %    if abs(corr(real_RegressorOI(:),rand_RegressorOI(:)))<.6 % check it !
                         %        pass=100;
                         %    else
                         %        pass=pass+1;
                         %    end
                         %end
             else
                indexROF=RegressorOI+1; 
                         % Permuting Regressor of interes 
                         real_RegressorOI = glm_matrix(:,RegressorOI);
                         pass=0;
                         while pass<100
                             rand_RegressorOI = real_RegressorOI(randperm(length(real_RegressorOI )));
                             if abs(corr(real_RegressorOI(:),rand_RegressorOI(:)))<.6 % check it !
                                 pass=100;
                             else
                                 pass=pass+1;
                             end
                         end
             end 
        
        
        
        

        
        
        
        
            cfgM=[];
            cfgM.type = stata; % , 'robust', 'lme'
            cfgM.ops = ['pre(Second Level ' stata '  MODEL)' ];
            cfgM.texto = texto;
            

           


            Regressors=[];
            for nR =1:size(glm_matrix,2)
                if nR== RegressorOI
                        Regressors{nR} =  rand_RegressorOI(:)';
                else
                        Regressors{nR} =  glm_matrix(:,nR)';
                end
            end
            
                %-- fast computing, BUT decress precision !!!
                borrame = ones(size(mcp_mask));
                borrame(mcp_mask==1)=NaN;            
                 for ia = 1:length(a)
                 a{ia} = a{ia}.*repmat(borrame,[1 1 1 size(a{ia},4)]);
                 end
                %--
            
            
            
            for i = 1:length(a)
                if isempty(Regressors)
                [pval, stat] = lan_model_stat(a{i}, cfgM);    
                else
                [pval, stat] = lan_model_stat(cat(2,a(i),Regressors{:}), cfgM);
                end
                %pval{i}=r_pval;
                %stat{i}=r_stats;
            end

  
        stat     = stat.t{indexROF};
        pval = pval{indexROF};           
        hh = false(size(pval));
        hh(pval<alpha)=true;         
        hhsig = sign(stat);
        
        
    end %--
    
             
            
            %--- extract the sign of the cluster % --- borrara redundacias
            %y calcualr previa,ente 
            if length(group)==2 && ~nr
                       Sig =  GLAN.timefreq.data{group(1),cond(1)}-GLAN.timefreq.data{group(2),cond(2)};
                       Sig = sign(Sig);
            elseif exist('hhsig','var')==1 %&& ~nr
                   Sig = hhsig;     
            elseif exist('paso','var')==1 && length(paso)==2 && nr
                       Sig =  mean(paso{1},4)-mean(paso{2},4);
                       Sig = sign(Sig);  
            elseif exist('paso','var')==1 && length(paso)==1 && nr
                       Sig =  mean(paso{1},4);
                       Sig = sign(Sig);                        
            else
                        Sig = ones(size(hh));
            end
            
            
            %-- 4d matrix of adjacencia  
                    hh1 = hh;
                    hh2 = hh;
                    hh1(Sig==-1)=false;
                    hh2(Sig==1)=false;
            
                for e   = 1:nbchan
                    [ye(e), xe(e)] = find(electrodemat==e);
                    
                    
                    newhh1(ye(e),xe(e),:,:) = hh1(:,e,:);
                    newhh2(ye(e),xe(e),:,:) = hh2(:,e,:);
                end
                
                
             %--  find cluster    
                pasoclusig = bwlabeln(newhh1);
                pasoclusig2 = bwlabeln(newhh2);
                pasoclusig2(pasoclusig2>0) = pasoclusig2(pasoclusig2>0) + max(pasoclusig(:));
                pasoclusig = pasoclusig +pasoclusig2;
                clusig=zeros(size(hh));
                for e  = 1:nbchan
                clusig(:,e,:) = pasoclusig(ye(e),xe(e),:,:);
                end
                clear pasoc*
             % --
            
             % -- find max cluster
                fin_nc = max(max(max(max(   clusig   ))));
                if isstruct(stat) && isfield(stat,'zval');
                   stat =  stat.zval;
                end
                
                for nc = 1:fin_nc;
                    statcluster(nc) = sum(sum(sum(sum( abs(  stat(clusig==nc)  )  ))));
                end% for nc    
                
                
                
              % -- real and permute cluster 
                if nr
                maxcluster = max(statcluster);    
                nr_cluster(nr) = maxcluster(1);
                else
                reals_cluster_stat = statcluster;
                reals_clusig = clusig;
                end
             % --
             if savetempfile && nr && mod(nr,50)==0
                
                 save(['paso_nrandom_' tempfilename  '_' num2str(nr) ],'nr_cluster' )
                 
             end

    end %for nr
    
    % claer large auxiliar variable 
    %clear rpaso* a v_freq hh* pval 
    
    
    % -- mantercalo p value per cluster 
    disp(' making mantercalo p value per cluster')
    pvalc = ones(size(GLAN.timefreq.pval{nbcomp}));
    pvalc_d = ones(size(GLAN.timefreq.pval{nbcomp}));
    hhc = zeros(size(GLAN.timefreq.hh{nbcomp}));
    cluster_ok = 0;
    cluster_dead = 0;
    
    if isfield(GLAN.timefreq, 'nr_cluster' )
       nr_cluster = [ GLAN.timefreq.nr_cluster{nbcomp}   nr_cluster] ;
    end
    
       [exG] = exgauss_fit(nr_cluster);
    
    for ncl = 1:max(max(reals_clusig(:)))
        paso = sum(reals_cluster_stat(ncl) < nr_cluster)/length(nr_cluster);
        pvalc(reals_clusig==ncl) = paso;
        paso = 1-sum(exgauss_pdf(1:reals_cluster_stat(ncl),exG));
        pvalc_d(reals_clusig==ncl) = paso;
        if  paso <= alpha   %
            hhc(reals_clusig==ncl) = 1;
            cluster_ok = cluster_ok +1;
        else
            cluster_dead = cluster_dead +1;
        end
    end
    % --
    
%---
end%-- if em=1
%---
if sum(bl~=0)
GLAN.timefreq.cfg.norma{nbcom}=norma;    
end

GLAN.timefreq.hhc{nbcomp}=hhc;
GLAN.timefreq.pvalc{nbcomp}=pvalc;
GLAN.timefreq.pvalc_d{nbcomp}=pvalc_d;
GLAN.timefreq.pvalc_exGaus_par{nbcomp}=exG;
GLAN.timefreq.nr_cluster{nbcomp}=nr_cluster;
try
GLAN.timefreq.clusig{nbcomp}=reals_clusig;
catch
    disp('Error: I Can''t save clusig matrix')
end

end% if mcp

%%%%%%%%%%%%%%%%%%%%
GLAN.infolan.version = lanversion;
GLAN.infolan.date = date;
      if ~isfield(GLAN.infolan, 'creation_date')
      GLAN.infolan.creation_date=date;    
      end

%%%%%%%%%%%%%%%%%%%%
GLAN.timefreq.cfg = cfg;
texto = plus_text(texto,['DONE']);
disp_lan(texto);
end%%% function

    function  [A n] = fix_cero_end(A,n)
        if nargin == 1, n = 0;end
        if A(end)==0
           A(end) = [];
           n = n + 1;
           [A n]= fix_cero_end(A,n);    
        end
    end
