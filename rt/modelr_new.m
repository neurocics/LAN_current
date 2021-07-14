function  COR =  modelr_new(COR,cfg) 
%   <*LAN)<]
%                v.0.2.3 devel
% 
% 
%
%   Realiza modelos usando R
%   COR  estructura de datos
%   .cfg configuraciones
%      .model = 		formula del modelo segun R
%                       'rt ~ BETA'
%      .command =  		comando a utilizar  
%   		       'lme'		liner mixed effect model
%                  'lmer'
%      .random = '1|sujeto'	efectos random
%
%      .conditions={ 'D$est!=-99' ...		condiconale de los datos donde D   
%                    'D$BETA!=-99' ...      es la tabla donde R guradad los
%                                }           datos
%      .newvar = { 'other R commander ' ...
%                  'per line ' ...
%                   }
%
%      .electrode = 		electrodos a evaluar
%
%       if COR is empty, is necesary defined the follow parameter
%
%       cfg.subject = {} {} ; nombre de sujetos
%       cfg.namefile = '%S\COR'
%       cfg.namemat  = 'COR' 
%
%       in order to perform the perfile options
%
%      cfg.writefileonly = true; solo realiza txt con la table de los datos por electrodod
%      cfg.onlyW = true ; idem
%      cfg.onlyR    = true; solo realiza computacion de modelo basado en tablas txt por electrodos ya realizadas
%      cfg.onlyE



%  Pablo Billeke

%  09.12.2011 fix bug
%  14.11.2011 add onlyE options
%  10.11.2011 add perfile options
%  21.06.2011




%---% parameter

    model = cfg.model;         %' lme(rt ~ BETA, random = ~ 1|sujeto, data=D)';


    %%% per file
    if isfield(cfg,'subject') && isempty(COR)
        perfile=true;
    else
        perfile=false;
    end
    
    
    
   electrode = getcfg(cfg,'electrodes',[]);
   if isempty(electrode)
      electrode = getcfg(cfg,'electrode',[]);
   end
   if isempty(electrode)     
      electrode = getcfg(cfg,'sensors',[]); 
   end
   if isempty(electrode)
      electrode = getcfg(cfg,'sources',[]);    
   end
   if isempty(electrode)
        if ~perfile
        electrode = 1:size(COR.FREQ(1).powspctrm{2},2);
        disp(['asigned electrode = ' num2str(size(COR.FREQ(1).powspctrm,2)) ])
        else
            error('In this modality you must indicate the number of sensors or sources in cfg.sensors')
        end
    end
    
    
    if isfield(cfg, 'onlyR')
        onlyR = cfg.onlyR;
    elseif isempty(COR)&&~perfile
        onlyR=1;        
    else
        onlyR=0;
    end
    
    if isfield(cfg, 'onlyE') && ~onlyR
        onlyE = cfg.onlyE;
    elseif onlyR;
        onlyE=0;        
    else
        onlyE=0;
    end
    
        
        if isfield(cfg, 'pathtemp')&&~isempty(cfg.pathtemp)
           where = cfg.pathtemp;
        else
             where = mfilename('fullpath');
             where = where(1:(length(where)-7));%%%% OJO
        end
        
       getcfg(cfg,'command'); 
       
       
switch command 
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
%-------------------------------%%%%       
%----% Computing model using R  %%%%             
           case {'lmer' , 'lme'}%%%%
%-------------------------------%%%%              
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%---%    
    
%---% write table for R    
    ne = 0;
    [ifr whereR] = isr;
    

    
    if (~onlyR)&&(~onlyE) %
        
        if ~ifr
            error('R or Littler is not install in your system !!!')
        end       
        
        %%% optimizando escriture
        cfgt = [];
        %cfgt.electrode = e;
        cfgt.where = where;
        cfgt.filename = ['borrameGRAL.txt'];
        if perfile
            cfgt.subject = cfg.subject;
            cfgt.namefile = cfg.namefile;
            cfgt.namemat = cfg.namemat;
            cfgt.nofield = 'FREQ';
            COR2tableR([],cfgt);
        else
            paso = rmfield(COR, 'FREQ');
            COR2tableR(paso,cfgt);
            %clear paso
            paso = COR;
            % removing field not depentied of electrodes
            try 
                paso = rmfield(paso, 'RT'); end
            try 
                paso = rmfield(paso, 'OTHER'); end
        end
        %removing field depentied of electrodes
        
        
        
        
        
    %for e = electrode;

        
        %ne=ne+1;
        %disp(['Electrode: ' num2str(ne) '/' num2str(length(electrode))   ])
            cfgt = [];
            

   
            cfgt.where = where;
           
             
        if perfile
            cfgt.format = getcfg(cfg,'format','txt');
            cfgt.electrode = electrode;
            cfgt.subject = cfg.subject;
            cfgt.namefile = cfg.namefile;
            cfgt.namemat = cfg.namemat;
            cfgt.filename = ['borrame%E.' cfgt.format ];
            cfgt.nofield = {'RT','OTHER'};
            COR2tableR([],cfgt);
        else
            
            for e = electrode;
            cfgt.electrode = e;
            cfgt.filename = ['borrame' num2str(e) '.txt'];
            %ne=ne+1;
            disp(['Electrode: ' num2str(e) '/' num2str(length(electrode)) ...
            ])
            COR2tableR(paso,cfgt);
            end
        end
    
    %end
    clear paso
    end % ~onlyR
    
%---%       
    
%---% write de script for R        
    
    %%%% Probisorio
    clear COR
    COR = [];
    %%%%%%
    fid = fopen([ where 'BORRAMEmodelos.r' ],'wt');
    
    % directorio de trabajo
    fprintf(fid,' %s \n ',['setwd(''' where ''') ']);
    %fprintf(fid,' %s \n ',' source(''librerias.r'')');
    fprintf(fid,' %s \n ','library(MASS)');
    fprintf(fid,' %s \n ','library(session)');
    
    %newpre
    if isfield(cfg,'newpre')&&iscell(cfg.newpre)
      fprintf_cell(fid,cfg.newpre)  
    end
    
    
    nw = 1;
    for w = electrode
        if nw==1
            cne = [num2str(w)];
        else
            cne = [cne ' , ' num2str(w)];
        end
        nw = nw+1;
    end
    
    fcell={...
        'ccc = 0',...
        'G<-read.table("borrameGRAL.txt",header=T)',...
        ['for (ele in c( ' cne  '))'] ,...       % Open loop per electrode 
        '{' , ...
        'ccc = ccc + 1', ...
    	'a = paste("borrame", as.character(ele),".txt",sep="")', ...
      	'E<-read.table(a,header=T)',...
        'D=G',...
        'for (RR in names(E)) {',...
            'texteval(paste( "D$" , RR , " = E$" , RR , sep=""    ))',... % add de condition per electrode
            '}',...
        '#attach(D)', ...
        'print(a)', ...
        };
    fprintf_cell(fid,fcell)

    %newvar
    if isfield(cfg,'newvar')&&iscell(cfg.newvar)
      fprintf_cell(fid,cfg.newvar)  
    end
    
    %condictions
    if isfield(cfg,'conditions')&&iscell(cfg.conditions)
      for nc = 1:length(cfg.conditions)
           fprintf(fid,' %s \n ',['D = D['  cfg.conditions{nc}   ',]']);
      end
    elseif isfield(cfg,'conditions')&&ischar(cfg.conditions)
           fprintf(fid,' %s \n ',['D = D['  cfg.conditions   ',]']);
    end

    % model
    if strcmp(cfg.command,'lme' )
      fprintf(fid,' %s \n ','library(nlme)');
      model_listo =[ 'lme(' model ', random = ~ +'  cfg.random ', data=D    )   '] ;  
      %fprintf(fid,' %s \n ','attach(D)');
    fprintf(fid,' %s \n ',['R<-' model_listo ]);
    fprintf(fid,' %s \n ',['R=summary(R)']);
    %
    fprintf(fid,' %s \n ',['write.matrix(R$tTable[,1], file = paste("borrameRC", as.character(ele),".txt",sep=""), sep = "\n ")']);
    fprintf(fid,' %s \n ',['write.matrix(R$tTable[,2], file = paste("borrameRsd", as.character(ele),".txt",sep=""), sep = "\n ")']);
    fprintf(fid,' %s \n ',['write.matrix(R$tTable[,3], file = paste("borrameRdf", as.character(ele),".txt",sep=""), sep = "\n ")']);
    fprintf(fid,' %s \n ',['write.matrix(R$tTable[,4], file = paste("borrameRt", as.character(ele),".txt",sep=""), sep = "\n ")']);
    fprintf(fid,' %s \n ',['write.matrix(R$tTable[,5], file = paste("borrameRp", as.character(ele),".txt",sep=""), sep = "\n ")']);
    fprintf(fid,' %s \n ',['write.matrix(names(R$tTable[,1]), file = paste("borrameRn", as.character(ele),".txt",sep=""), sep = "\n ")']);
   
    elseif strcmp(cfg.command,'lmer' )
       fprintf(fid,' %s \n ','library(lme4)'); 
       if ~isfield(cfg,'family')
           cfg.family = 'gaussian(link = "identity")';
       end
       model_listo =[ 'lmer(' model ' + ('  cfg.random ' ), data=D , family = ' cfg.family  '   )   '] ; 
        %fprintf(fid,' %s \n ','attach(D)');
    fprintf(fid,' %s \n ',['R<-' model_listo ]);
    fprintf(fid,' %s \n ',['R=summary(R)']);
    %
    fprintf(fid,' %s \n ',['write.matrix(R@coefs[,1], file = paste("borrameRC", as.character(ele),".txt",sep=""), sep = "\n ")']);
    fprintf(fid,' %s \n ',['write.matrix(R@coefs[,2], file = paste("borrameRsd", as.character(ele),".txt",sep=""), sep = "\n ")']);
    %fprintf(fid,' %s \n ',['write.matrix(R@coefs[,3], file = paste("borrameRdf", as.character(ele),".txt",sep=""), sep = "\n ")']);
    fprintf(fid,' %s \n ',['write.matrix(R@coefs[,3], file = paste("borrameRt", as.character(ele),".txt",sep=""), sep = "\n ")']);
    fprintf(fid,' %s \n ',['write.matrix(R@coefs[,4], file = paste("borrameRp", as.character(ele),".txt",sep=""), sep = "\n ")']);
    %fprintf(fid,' %s \n ',['write.matrix(names(R@coefs[,1]), file = paste("borrameRn", as.character(ele),".txt",sep=""), sep = "\n ")']);
   

    end
   fprintf(fid,' %s \n ',['# detach(D)'] );
   fprintf(fid,' %s \n ',[' }'] );
    
   fclose(fid);
    %%%%
    if (isfield(cfg,'writefileonly')&&(cfg.writefileonly==1))||(isfield(cfg,'onlyW')&&(cfg.onlyW==1))
            disp(['WARNING: only write file in (' where ')'])
            return
    end

   
    %---% %%%% mandarlo a R
    
    %---% performing the models in R    
    if ~onlyE
    system([ whereR 'r  ' where 'BORRAMEmodelos.r' ]);
    else
	disp('WARNING: only extract data of models have already permformed')
    end



    %---% %%%% estraerlo de R
    
    %---% Extract de results from R  
	ne = 0;
    nne = length(electrode);
    for e = electrode;
        ne=ne+1;
        if nne>1000
            if mod(ne,10)==0
            disp(['Copiando: ' num2str(ne) '/' num2str(nne)  ' #' num2str(e)  ])    
            end
        else
            disp(['Copiando: ' num2str(ne) '/' num2str(nne)  ' #' num2str(e)  ])
        end
        
            if  ne ==1
            if isfield(COR, 'models')
                nm = length(COR.models) + 1;
            else
                nm = 1;
            end     
            
	    COR.models(nm).c = importdata([ where 'borrameRc' num2str(e)  '.txt'])';
	    COR.models(nm).sd = importdata([ where 'borrameRsd' num2str(e)  '.txt'])';
	    COR.models(nm).df = importdata([ where 'borrameRdf' num2str(e)  '.txt'])';    
	    COR.models(nm).t = importdata([ where 'borrameRt' num2str(e)  '.txt'])';
	    COR.models(nm).p = importdata([ where 'borrameRp' num2str(e)  '.txt'])';
	    COR.models(nm).model.f = model;
	    COR.models(nm).model.c = importdata([ where 'borrameRn' num2str(e)  '.txt']);
	    else
	    COR.models(nm).c = cat  (1,COR.models(nm).c,  importdata([ where 'borrameRc' num2str(e)  '.txt'])'   );
	    COR.models(nm).sd =cat  (1,COR.models(nm).sd  , importdata([ where 'borrameRsd' num2str(e)  '.txt'])');
	    COR.models(nm).df =cat  (1,COR.models(nm).df  , importdata([ where 'borrameRdf' num2str(e)  '.txt'])');    
	    COR.models(nm).t = cat  (1,COR.models(nm).t  ,importdata([ where 'borrameRt' num2str(e)  '.txt'])');
	    COR.models(nm).p =cat  (1,COR.models(nm).p   ,importdata([ where 'borrameRp' num2str(e)  '.txt'])');
	    %COR.models(nm).model.f =cat  (1,   model;
	    %COR.models(nm).model.c = importdata([ where 'borrameRn.txt']);       
		
		
	    end
    end
    
    %%% borrar
    % system(['rm '  where 'borrame*   ' where 'BORRAME*' ]);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %------------------------------------%%%       
    %----% Computing model using Matlab  %%%            
           case {'robustfit'}            %%%
    %------------------------------------%%%  
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %fix sintaxis error
    cfg.model = formule_fix(cfg.model,'r2m');
    cfg.newvar = formule_fix(cfg.newvae,'r2m');
    cfg.conditions = formule_fix(cfg.conditions,'r2m');
    
    % dependen var
    lim = find(cfg.model=='=');
    Y = strrep(cfg.model(1:(lim-1)),' ','');
    rm = cfg.model((lim+1):end);
    
    % independen vars   
    c=0;
    while ~isempty(rm)
       c = c +1;         
       lim = find(rm=='+',1); 
       if isempty(lim), 
           lim = length(rm)+1;
       else
           lim = find(rm=='+',1);
       end 
       X{c} = strrep(rm(1:(lim-1)),' ','');
       rm = rm((lim+1):end); 
    end
    
end % switch command
end % function


%%%%
function C = formule_fix(C,tipo)

    if ischar(C)
        C = {C};
    end

switch tipo
    case 'm2r'
        for i = 1:size(C,1)
            C{i} = strrep(C{i},'~','!');
            C{i} = strrep(C{i},'.','$');
            C{i} = strrep(C{i},'=','~');
        end       
    case'r2m'
        for i = 1:size(C,1)
            C{i} = strrep(C{i},'!','~');
            C{i} = strrep(C{i},'$','.');
            C{i} = strrep(C{i},'~','=');
        end        
        
end
end



function D = add_D(D,COR,str)

%
if isfield(COR,'RT')
    RT = fieldnames(COR.RT)';
else
    RT = 'NaN';
end

%
if isfield(COR,'OTHER')
    OTHER = fieldnames(COR.OTHER)';
else
    OTHER = 'NaN';
end

%
if isfield(COR,'FREQ')
    FREQ = {COR.FREQ.label};
else
    FREQ = 'NaN';
end

switch str
    case RT
    eval(['D.' str ' = COR.RT.' str ' ;'  ]);
    case OTHER
    eval(['D.' str ' = COR.OTHER.' str ' ;'  ]);
    case FREQ
    indx=find(ifcellis(FREQ,str));
    eval(['D.' str ' = COR.FREQ(' num2str(indx) ').'  str ' ;'  ]);
end
end



