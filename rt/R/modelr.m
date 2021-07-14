function  COR =  modelr(COR,cfg) 
%   <*LAN)<]
%                v.0.0.11
% 
% 
%
%   Realiza modelos usando R
%   COR  estructura de datos
%   .cfg configuraciones
%      .model = 		formula del modelo segun R
%               'rt ~ BETA'
%      .command =  		comando a utilizar  
%   		'lme'		linwae mixed effect model
%      .random = '1|sujeto'	efectos random
%
%      .conditions(1) = 'est!=-99' 		condiconale de los datos    
%                 (x) = 'BETA!=-99'
%      .newvar = 
%
%      .electrode = 		electrodos a evaluar
%
%
%
%  21.06.2011
%
%  Pablo Billeke


    model = cfg.model;         %' lme(rt ~ BETA, random = ~ 1|sujeto, data=D)';
    try    
        electrode = cfg.electrode;
    catch
        electrode = 1:size(COR.FREQ(1).powspctrm{2},2);
        disp(['asigned electrode = ' num2str(size(COR.FREQ(1).powspctrm,2)) ])
    end

    if isfield(cfg, 'onlyR')
        onlyR = cfg.onlyR;
    elseif isempty(COR)
        onlyR=1;        
    else
        onlyR=0;
    end
        
        if isfield(cfg, 'pathtemp')&&~isempty(cfg.pathtemp)
           where = cfg.pathtemp;
        else
             where = mfilename('fullpath');
             where = where(1:(length(where)-7));%%%% OJO
        end
    
    
    
    
    ne = 0;
    [ifr whereR] = isr;
    
    if ~onlyR %
    for e = electrode;
        ne=ne+1;
        disp(['Electrode: ' num2str(ne) '/' num2str(length(electrode))   ])
    
    cfgt = [];
    cfgt.electrode = e;

   
    cfgt.where = where;
    cfgt.filename = ['borrame'  num2str(e)   '.txt'];

    COR2tableR(COR,cfgt);
    end
    end
    
    %%%% Probisorio
    clear COR
    COR = [];
    %%%%%%
    fid = fopen([ where 'BORRAMEmodelos.r' ],'wt');
    
    % directorio de trabajo
    fprintf(fid,' %s \n ',['setwd(''' where ''') ']);
    %fprintf(fid,' %s \n ',' source(''librerias.r'')');
    fprintf(fid,' %s \n ','library(MASS)');
    
    %newpre
    if isfield(cfg,'newpre')
      for nc = 1:length(cfg.newpre)
           fprintf(fid,' %s \n ', cfg.newpre{nc}   );
      end
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
    fprintf(fid,' %s \n ',['ccc = 0'] );
    fprintf(fid,' %s \n ',['for (ele in c( ' cne  '))'] );
    fprintf(fid,' %s \n ',['{'] );
    fprintf(fid,' %s \n ',['ccc = ccc + 1'] );
    fprintf(fid,' %s \n ',['a = paste("borrame", as.character(ele),".txt",sep="")'] );
    fprintf(fid,' %s \n ','D<-read.table(a,header=T)');
    %fprintf(fid,' %s \n ',' if (ccc==1) {attach(D)}');
    
    
    fprintf(fid,' %s \n ','print(a)');


    %newvar
    if isfield(cfg,'newvar')
      for nc = 1:length(cfg.newvar)
           fprintf(fid,' %s \n ', cfg.newvar{nc}   );
      end
    end
    %condictions
    if isfield(cfg,'conditions')
      for nc = 1:length(cfg.conditions)
           fprintf(fid,' %s \n ',['D = D['  cfg.conditions{nc}   ',]']);
      end
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
   
   fprintf(fid,' %s \n ',['}'] );
    
   
    %%%%
    if isfield(cfg,'writefileonly')&&(cfg.writefileonly==1)
            disp(['WARNING: only write file in (' where ')'])
            return
    end
    %%%% mandarlo a R
    
    system([ whereR 'r  ' where 'BORRAMEmodelos.r' ]);
    
    %%%% leerlo de R
	ne = 0;
    for e = electrode;
        ne=ne+1;
        disp(['Copiando: ' num2str(ne) '/' num2str(length(electrode))   ])
        
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
    
    %%% borar
    
    %%% system(['rm '  where 'borrame*   ' where 'BORRAME*' ]);
end


%%%%