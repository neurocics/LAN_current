function COR = cor_stata(COR,cfg)
%   v.0.0.4
%   <*LAN)<] 
%
% Compute basic statistic of COR structure. (non parametric)
% with differente subjet in COR.OTHER.subject or COR.OTHER.sujeto
%
% cfg.analysis={  ...  }    % analsis to compute between different estimuli
%             'correct'         % proporcion of creect responses
%             'rt:mean'         % mean diferenses
%             'rt:density'      % density analsis
%             'all'             % all de analsiis
% cfg.paired = true / false         % for paireed test (default: TRUE)
% cfg.onlycorrect = true / false    % for RT only of correct responce
%                                       (default: TRUE)
% cfg.d_width=25 v         % width of the gausean kernel of density plot
%
% Pablo Billeke
% Francisco Zamorano

% 13.07.2012 PB FZ add not paired test!
% 12.04.2012
% 21.11.2011 esthetic improvement
% 18.11.2011
% Pablo Billeke

if nargin == 1 
    ana = {'rt:mean','rt:density','correct'};
    cfg.ana = ana;
end
onlycorrect = getcfg(cfg,'onlycorrect',true);
paired = getcfg(cfg,'paired',true);
group = getcfg(cfg,'group',0);

if nargin==2
    %cfg.analysis
    % analysis
    try
        if ischar(cfg.analisis) && strcmp(cfg.analisis,'all')
            ana = {'rt:mean','rt:density','correct'};
        elseif ischar(cfg.analisis)
            ana = {cfg.analisis};
        else
            ana = cfg.analisis;
        end
    catch
        if ischar(cfg.analysis) && strcmp(cfg.analysis,'all')
            ana = {'rt:mean','rt:density','correct'};
        elseif ischar(cfg.analysis)
            ana = {cfg.analysis};
        else
            ana = cfg.analysis;
        end
    end
        
    %cfg.s
    % sample relationship
    getcfg(cfg,'s','d')
    
end

getcfg(cfg,'grouping',0)
d_width = getcfg(cfg,'width',25);

% looking for grouping factors
if ischar(grouping)
    AG = eval(['COR.OTHER.' grouping]);
    ifag=true;
elseif isfield(COR,'OTHER') && isfield(COR.OTHER,'sujeto')
    AG = COR.OTHER.sujeto;
    ifag=true;
elseif isfield(COR,'OTHER') && isfield(COR.OTHER,'subject')
    AG = COR.OTHER.subject;
    ifag=true;
else
    ifag=false;
end
%end
%looing for correct response
if isfield(COR,'RT') && isfield(COR.RT,'correct')
    ifc=true;
    ifrt=true;
elseif isfield(COR,'RT')
    ifc=false;
    ifrt=true;    
else
    ifc=false;
    ifrt=false;
end


%---% correct response
if ifag && ifrt && ifc && any(ifcellis(ana,'correct'))
    AG_t = unique(AG);
    E_t = unique(COR.RT.est);
    R_cor = zeros(length(E_t),length(AG_t));
    correct = COR.RT.correct;

    for s = 1:length(AG_t)
        for es = 1:length(E_t)
            idx = (COR.RT.est==E_t(es))&(ifcellis(AG,AG_t{s}));
            R_cor(es,s) = sum(correct(idx)) / sum(idx); % porcentaje de rspuetas correcats
            if group
                gg_n(s) =  eval(['COR.OTHER.' group '(find(idx==1,1)) ']);
                
            end
        end
    end
    figure('name','Correct response per estimulus');
    boxplot(R_cor')
    ylim([ min([ 0.45 min(min(R_cor)) ])  1 ]);
    line([0,es],[0.5 0.5],'Color','red')
    xlabel('Estimulus')
    
    
      
    set(gca,'XTickLabel',E_t,...
        'XTick',[1:length(E_t)]);
    %figure,
    if paired
    [p,table,stats] = friedman(R_cor');
    else
    [p,table,stats] =kruskalwallis(R_cor');
    end
    
    figure,
    [c,m,h,gnames] = multcompare(stats);
    COR.STAT.correct.p = p;
    COR.STAT.correct.c = c;
    COR.STAT.correct.h = h;
    COR.STAT.correct.data=R_cor';
    if group
       COR.STAT.correct.group=gg_n';
    end
    %
elseif ifag && ifrt
    correct = true(size(COR.RT.rt));
end
%---%

%---% RT for correct response
if ifag && ifrt &&  or(any(ifcellis(ana,'rt:mean')),any(ifcellis(ana,'rt:density')))  
    AG_t = unique(AG);
    E_t = unique(COR.RT.est);
    % for mean
    R_cor = zeros(length(E_t),length(AG_t));
    
    % for distributions
    rt_max = max(COR.RT.rt);
    rt_min = min(COR.RT.rt(COR.RT.rt>0));
    rt_lt = ceil(rt_min):ceil(rt_max);
    %D_cor = zeros(length(rt_lt),length(E_t),length(AG_t));
    
   
    for s = 1:length(AG_t)
        for es = 1:length(E_t)
            idx = (COR.RT.est==E_t(es))&(ifcellis(AG,AG_t{s}));            
            % only  correct response
            oc = COR.RT.rt(idx);
            if onlycorrect
                if isfield(COR.RT,'correct')
                oc(~logical(COR.RT.correct(idx))) = [];    
                end
            end
            %mean
            R_cor(es,s) = mean(oc);
            
            %density smooth
            if any(ifcellis(ana,'rt:density')) && (~isempty(oc))
            D_cor{es}(:,s) = ksdensity(oc,rt_lt,'width',d_width);
            elseif isempty(oc)
            D_cor{es}(:,s) = nan(size(rt_lt)); 
            end
        end
    end
    
    % del nan
        for es = 1:length(E_t)
               D_cor{es}(:,isnan(D_cor{es}(1,:))) = []; 
        end

    
    
    if any(ifcellis(ana,'rt:mean'))
        
        
    figure('name','Reaction time per estimulus');
    boxplot(R_cor')
    %ylim([ min([ 0.45 min(min(R_cor)) ])  1 ]);
    %line([0,es],[0.5 0.5],'Color','red')
    xlabel('Estimulus')
    set(gca,'XTickLabel',E_t,...
        'XTick',[1:length(E_t)]);
    try
        unit = COR.RT.cfg.unit;
    catch
        unit = 'ms';
    end
    ylabel(['Reaction time (' unit ')'])
    
    
    %figure,
    if paired
    [p,table,stats] = friedman(R_cor');
    else
     ind = ~isnan(R_cor');
     nc = sum(ind,1);
     R_cor2 = R_cor';
     R_cor2(~ind) =[];
     
     agrup= ones(nc(1),1);
     for gg = 2:length(nc)
     agrup= cat(1,agrup,repmat(gg,nc(gg),1));
     end
     
     [p,table,stats] =  kruskalwallis(R_cor2,agrup);
     
    end
    
    figure,
    [c,m,h,gnames] = multcompare(stats);    
        % save results
        COR.STAT.rt.datamean=R_cor';
        COR.STAT.rt.p = p;
        COR.STAT.rt.c = c;
        COR.STAT.rt.h = h;
    end
    
    %---%
    if any(ifcellis(ana,'rt:density'))
    figure('name','RT density function')
    if paired
    [ pval h ] = nonparametric(D_cor,[],0.05,'d',0,[],0,'exact');%a,b,alpha,m,means,texto,ifv,METHOD
    else
        cfg.method = 'rank';
        % getcfg(cfg,'paired',2)
        % [pval stats] = lan_nonparametric(data,cfg)
        [ pval  ] = lan_nonparametric(D_cor,cfg);%nonparametric(D_cor,[],0.05,'i',0,[],0,'exact');%a,b,alpha,m,means,texto,ifv,METHOD    
        h = pval<0.05;
    end
    %false discovery rate
    cvf = FDRlan(pval);
    
    %bonferroni
    cvb = 0.05/length(pval);
    
    %h = false(size(pval));
    h_fdr = false(size(pval));
    h_bon = false(size(pval));
    %h(pval<0.05)=true
    h_bon(pval<=cvb)=true;
    h_fdr(pval<=cvf)=true;
    
    
    
    colorlan = {'blue','red', 'green','black','yellow',[0.5 0.5 0.5]};
    for i = 1:es  %ksd(:,:,i) !!!!!!!!!!!!!!!!!!
        ksd{i} = mean(D_cor{i},2);
        plot(rt_lt,ksd{i},'Color',colorlan{i}), hold on;
    end
    yli = get(gca,'ylim');
    for i = 1:es
        text(rt_lt(end)*0.8,yli(2)*(1-i*0.05),['Stimulus ' num2str(E_t(i))],'Color',colorlan{i})
    end
    
    line([rt_lt(1)  rt_lt(end) ] , [yli(2) yli(2)])
    sig = rt_lt;sig(~h) = [];
    plot(sig,ones(size(sig))*yli(2),'*'),hold on,
    text(rt_lt(end), yli(2), 'unc','Color','blue')
    
    line([rt_lt(1)  rt_lt(end) ] , [yli(2)*1.05 yli(2)*1.05],'Color','red')
    sig = rt_lt;sig(~h_fdr) = [];
    plot(sig,ones(size(sig))*yli(2)*1.05,'*','Color','red'),hold on,
    text(rt_lt(end), yli(2)*1.05, ['fdr(' num2str(cvf) ')'],'Color','red' )
    
    line([rt_lt(1)  rt_lt(end) ] , [yli(2)*1.1 yli(2)*1.1],'Color','black')
    sig = rt_lt;sig(~h_bon) = [];
    plot(sig,ones(size(sig))*yli(2)*1.1,'*','Color','black'),hold on,
    text(rt_lt(end), yli(2)*1.1, ['bon(' num2str(cvb) ')'],'Color','black' )
    
    
    yli(2) = yli(2)*1.15;
    set(gca,'ylim',yli);
    
    COR.STAT.rt.datadensity=D_cor;
    
    ylabel(['Density'])
    try
        unit = COR.RT.cfg.unit;
    catch
        unit = 'ms';
    end
    xlabel(['Reaction time (' unit ')'])
    end
    
    

    

end

% save options 

COR.STAT.cfg=cfg;

end






