function  COR =  modelr1(COR,cfg) 
%   <*LAN)<]
%                v.0.0.1
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


    model = cfg.model;         %' lme(rt ~ BETA, random = ~ 1|sujeto, data=D)';
    try    
        electrode = cfg.electrode;
    catch
        electrode = 1:size(COR.FREQ(1).powspctrm{2},2);
        disp(['asigned electrode = ' num2str(size(COR.FREQ(1).powspctrm,2)) ])
    end


    ne = 0;
    [ifr whereR] = isr;
    for e = electrode;
        ne=ne+1;
        disp(['Electrode: ' num2str(ne) '/' num2str(length(electrode))   ])
    
    cfgt = [];
    cfgt.electrode = e;
    where = mfilename('fullpath');
    where = where(1:(length(where)-6));
    cfgt.where = where;
    cfgt.filename = 'borrame.txt';

    COR2tableR(COR,cfgt);

    
    %%%%%%
    fid = fopen([ where 'BORRAMEmodelos.r' ],'wt');
    
    % directorio de trabajo
    fprintf(fid,' %s \n ',['setwd(''' where ''') ']);
    %fprintf(fid,' %s \n ',' source(''librerias.r'')');
    fprintf(fid,' %s \n ','D<-read.table("borrame.txt",header=T)');
  
    fprintf(fid,' %s \n ','library(MASS)');
    fprintf(fid,' %s \n ','attach(D)');
    
    %condictions
    if isfield(cfg,'conditions')
      for nc = 1:length(cfg.conditions)
           fprintf(fid,' %s \n ',['D = D['  cfg.conditions{nc}   ',]']);
      end
    end

    %newvar
    if isfield(cfg,'newvar')
      for nc = 1:length(cfg.newvar)
           fprintf(fid,' %s \n ', cfg.newvar{nc}   );
      end
    end


    % model
    if strcmp(cfg.command,'lme' )
      fprintf(fid,' %s \n ','library(nlme)');
      model_listo =[ 'lme(' model ', random = ~'  cfg.random ', data=D    )   '] ;       
    end
    %fprintf(fid,' %s \n ','attach(D)');
    fprintf(fid,' %s \n ',['R<-' model_listo ]);
    fprintf(fid,' %s \n ',['R=summary(R)']);
    %
    fprintf(fid,' %s \n ',['write.matrix(R$tTable[,1], file = "borrameRc.txt", sep = "\n ")']);
    fprintf(fid,' %s \n ',['write.matrix(R$tTable[,2], file = "borrameRsd.txt", sep = "\n ")']);
    fprintf(fid,' %s \n ',['write.matrix(R$tTable[,3], file = "borrameRdf.txt", sep = "\n ")']);
    fprintf(fid,' %s \n ',['write.matrix(R$tTable[,4], file = "borrameRt.txt", sep = "\n ")']);
    fprintf(fid,' %s \n ',['write.matrix(R$tTable[,5], file = "borrameRp.txt", sep = "\n ")']);
    fprintf(fid,' %s \n ',['write.matrix(names(R$tTable[,1]), file = "borrameRn.txt", sep = "\n ")']);
  
    
    
    %%%% mandarlo a R
    
    system([ whereR 'r  ' where 'BORRAMEmodelos.r' ]);
    
    %%%% leerlo de R

        
        if  ne ==1
            if isfield(COR, 'models')
                nm = length(COR.models) + 1;
            else
                nm = 1;
            end     
            
    COR.models(nm).c = importdata([ where 'borrameRc.txt'])';
    COR.models(nm).sd = importdata([ where 'borrameRsd.txt'])';
    COR.models(nm).df = importdata([ where 'borrameRdf.txt'])';    
    COR.models(nm).t = importdata([ where 'borrameRt.txt'])';
    COR.models(nm).p = importdata([ where 'borrameRp.txt'])';
    COR.models(nm).model.f = model;
    COR.models(nm).model.c = importdata([ where 'borrameRn.txt']);
        else
    COR.models(nm).c = cat  (1,COR.models(nm).c,  importdata([ where 'borrameRc.txt'])'   );
    COR.models(nm).sd =cat  (1,COR.models(nm).sd  , importdata([ where 'borrameRsd.txt'])');
    COR.models(nm).df =cat  (1,COR.models(nm).df  , importdata([ where 'borrameRdf.txt'])');    
    COR.models(nm).t = cat  (1,COR.models(nm).t  ,importdata([ where 'borrameRt.txt'])');
    COR.models(nm).p =cat  (1,COR.models(nm).p   ,importdata([ where 'borrameRp.txt'])');
    %COR.models(nm).model.f =cat  (1,   model;
    %COR.models(nm).model.c = importdata([ where 'borrameRn.txt']);       
            
            
        end
     
    end
    %%% borar
    
    system(['rm '  where 'borrame*   ' where 'BORRAME*']);
end


%%%%


