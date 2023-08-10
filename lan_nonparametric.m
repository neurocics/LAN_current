function [pval , stats] = lan_nonparametric(data,cfg)
% v.0.6
% <*LAN)<] toolbox
% 
% [pval , stats] = lan_nonparametric(data,cfg) 
% Forms:  nonparametric(data,cfg)
% dependencies : statistic toolbox:
%        
% cfg.method  = 'rank'                                      
% cfg.paired =  true or false
% cfg.cortest   =  false correlation 
%
% cfg.text
%
% cfg.fast=1
% statistic toolbox:
% tiedrank.m
% normcdf

% From     nonparametric.m 
%          improve performance
%          but only approxiamted p values (normal approximation)
%
% Pablo Billeke
% 17.05.2020 Improve wait bar 
% 16.02.2018 Improve performance unparied samples 
% 17.06.2016
% 09.05.2012 fix problem with two-dimention matrix
% 25.04.2012
if nargout ==2
    stats = [];
end
 
if nargin==1
    cfg.method = 'rank';
end
getcfg(cfg,'cortest',false)
getcfg(cfg,'method','rank')
getcfg(cfg,'paired',2)
getcfg(cfg,'fast',1)
getcfg(cfg,'displayt',1)
texto = getcfg(cfg,'text','');
if isempty(texto), texto = plus_text(); end

        if paired == 2 & cortest==0
           if length(data)==1
               paired=true;
           %elseif length(data)==1
           %    paired=1;
           elseif ~(any(size(data{1})~=size(data{2})))
               paired=true;
           else
               paired=false;
           end
        end

switch method
    case 'rank'
        ifrank=true;
    case 'parametric'
        ifrank=false;
    otherwise
        ifrank=true;
end
%---corr test case
if cortest
    % name od the test
    if ifrank, nametest = 'Spearman';else nametest = 'Pearson'; end;
    
    % partial correlation
   if  length(data)>2,disp('two element only for correlation, I will do a partian corelation instead '), 
   dimen=size(data{1});
                  for dm =  1:length(data)-1
                      for d2m = dm:length(data)-1
                            stats.rho{dm,d2m+1}= ones(dimen(1:end-1)); 
                            pval{dm,d2m+1}=ones(dimen(1:end-1));  
                      end
                  end
   
   for nd = 1:length(data)
      if numel(data{nd}) == dimen(end), ifa{nd} = true; else ifa{nd} = false;  end 
   end
   
   paso = prod(dimen(1:end-1));
   if ~ifa{1}, nps = paso; end
   data{1} = reshape(data{1},paso,dimen(end));
  
   for nd = 2:length(data)     
   dimen=size(data{nd}); 
   paso = prod(dimen(1:end-1));   
   if ~ifa{nd}, nps = paso; end
   data{nd} = reshape(data{nd},paso,dimen(end));
   end
   
 
   for p = 1:nps
   bar = bar_wait(p,nps,['pre(' nametest ' Partial  Corr) pos( ) B(.) R(o)']);
              if ~isempty(bar)
              texto = last_text(texto,bar,1);
              disp_lan(texto);
              end %%%
              for nd = 1:length(data)  
              if ifa{nd}, pa = 1; else pa = p; end
                  if nd == 1
                  dd = data{nd}(pa,:); 
                  else
                  dd = cat(1,dd,data{nd}(pa,:));
                  end
              end
              [pasoR pasoP ] = partialcorr(dd' ,'type',nametest);
                  for dm =  1:length(data)-1
                      for d2m = dm:length(data)-1
                            stats.rho{dm,d2m+1}(p)= pasoR(d2m+1,dm);
                            pval{dm,d2m+1}(p)= pasoP(d2m+1,dm);
                      end
                  end
              end
   
   return
   end 
    % simple correlation
   dimen=size(data{1});
   pval = ones(dimen(1:end-1)); 
   stats.rho = ones(dimen(1:end-1)); 
   if numel(data{1}) == dimen(end), ifa = true; else ifa = false;  end
   if numel(data{2}) == dimen(end), ifb = true; else ifb = false;  end 
   paso = prod(dimen(1:end-1));
   if ~ifa, nps = paso; end
   data{1} = reshape(data{1},paso,dimen(end));
   dimen=size(data{2}); 
   paso = prod(dimen(1:end-1));
   if ~ifb, nps = paso; end
   data{2} = reshape(data{2},paso,dimen(end));
   for p = 1:nps
   bar = bar_wait(p,nps,'pre(Spearman Corr) pos( ) B(.) R(o)');
              if ~isempty(bar)
              texto = last_text(texto,bar,1);
              disp_lan(texto);
              end %%%
              if ifa, pa = 1; else pa = p; end
              if ifb, pb = 1; else pb = p; end
              d1 = data{1}(pa,:);
              d2 = data{2}(pb,:);
              [stats.rho(p), pval(p)] = corr(d1(:),d2(:) ,'type','s');
              
   end
   return
%---pairewise case
elseif length(data)<3
        if length(data) < 2 
            data{2} = zeros(size(data{1}));
            paired = true;
        elseif isscalar(data{2})
            data{2} = repmat(data{2}, size(data{1}));
            paired = true;
        end

if paired
   %%% signrank test
    dimen=size(data{1});
        if numel(dimen)>2
            pval = ones(dimen(1:end-1));
        elseif numel(dimen)==2
            pval = ones(dimen(1),1);    
        else
            error('problem with matrix dimensions')
        end
   

    diffd = data{1}(:) - data{2}(:);
    clear data
    paso = prod(dimen(1:end-1));
    diffd = reshape(diffd,paso,dimen(end));
    texto = plus_text(texto,'Wilcoxon test for paired samples');
    texto = plus_text(texto,'.');
    for p = 1:size(diffd,1)
    %%%p=1 ; %%%% P 
    bar = bar_wait(p,size(diffd,1),'pre(Wt) pos( ) B(.) R(o)');
              if displayt && ~isempty(bar)
              texto = last_text(texto,bar,1);
              disp_lan(texto);
              end %%%
           if (nargout > 1)
           if p ==1
           stats.zval = zeros(size(pval)) ;  
           end
           end
    diffxy = diffd(p,:);
    %%%diffxy = diffd;
    % Remove missing data
    diffxy(isnan(diffxy)) = [];
    if (isempty(diffxy))
       pval(p)=NaN;
       continue
    end

    nodiff = diffxy == 0;
    diffxy(nodiff) = [];
    n = length(diffxy);
    if (n == 0)         % degenerate case, all ties
        pval(p) = 1;
        continue
    end

    neg = diffxy<0;
    [tierank, tieadj] = tiedrank(abs(diffxy));

    % Compute signed rank statistic (most extreme version)
    w = sum(tierank(neg));
    w = min(w, n*(n+1)/2-w);

        z = (w-n*(n+1)/4) / sqrt((n*(n+1)*(2*n+1) - tieadj)/24);
        pval(p) = 2*normcdf(z,0,1);
       if (nargout > 1)
          stats.zval(p) = abs(z) .* sign(mean(diffd(p,:)));
       end
    end %for p
else % paired == false
   %%% sunrank test
    dimenx=size(data{1});
    x = data{1}(:);
    dimeny=size(data{2});
    y = data{2}(:);
    clear data
    
    if numel(dimenx)>2
    pval = ones(dimenx(1:end-1));
    elseif numel(dimenx)==2
    pval = ones(dimenx(1),1);    
    else
        error('problem with matrix dimensions')
    end
    
    nx = dimenx(end);
    ny = dimeny(end);
    if nx <= ny
       smsample = x;
       dimens = dimenx;
       lgsample = y;
       dimenl = dimeny;
       ns = dimenx(end);
    else
       smsample = y;
       dimens = dimeny;
       lgsample = x;
       dimenl = dimenx;
       ns = dimeny(end);
    end
    if prod(dimens(1:end-1)) == prod(dimenl(1:end-1))
        paso = prod(dimens(1:end-1));
    else
        error('no equal number of bin to compare')
    end
    
    smsample = reshape(smsample,paso,dimens(end));
    lgsample = reshape(lgsample,paso,dimenl(end));
    texto = plus_text(texto,'Wilcoxon test for unpaired samples');
    texto = plus_text(texto,'.');
    past=0;
    
    
    wmean = ns*(nx + ny + 1)/2;
    
    indxx = ((sum(isnan(smsample),2) + sum(isnan(lgsample),2))>0)';
    
    w=wmean*ones(size(pval(:)));
    tieadj_=ones(size(pval(:)));
    for p = 1:paso
        %if indxx(p)==1; continue; end; 
        %primero=1;
        bar = bar_wait(p,paso,'pre(Wt) pos( ) B(.) R(o)');
              if ~isempty(bar)
              texto = last_text(texto,bar,1);
              disp_lan(texto);
              end %%%
              
             
              
    % Compute the rank sum statistic based on the smaller sample
    
    nonan_sm = ~isnan(smsample(p,:)');
    nonan_lg = ~isnan(lgsample(p,:)');
    
   
    
    [ranks, tieadj] = tiedrank([smsample(p,nonan_sm)'; lgsample(p,nonan_lg)']);
    
    if isempty(ranks); continue; end; 
     % for fast computation, 
     % if p>2 && pval(p-1)>fast && past==1; past=0; continue;end; past=1;
    
    xrank = ranks(1:ns);
    w(p) = sum(xrank);
    tieadj_(p)=tieadj;
    end 
    
       tiescor = 2 * tieadj_ / ((nx+ny) * (nx+ny-1));
       wvar  = nx*ny*((nx + ny + 1) - tiescor)/12;
       wc = w - wmean;
       z = (wc - 0.5 .* sign(wc))./sqrt(wvar);
       
       pval_e = 2*normcdf(-abs(z));
       pval(:) = pval_e(:);
       %pval(p) = 2*normcdf(-abs(z));
       if (nargout > 1)
%            if primero ==1
%            stats.zval = zeros(size(pval));  
%            primero=0;
%            end
%           %stats.zval = zeros(size(pval)); 
           stats.zval = z;
       end
    %end


end % paired 
%---multiple case
elseif length(data)>2
   if paired
     %%% friedman
      dimen=size(data{1});
      pval = ones(dimen(1:end-1));
      paso = prod(dimen(1:end-1));
      for fac = 1:length(data)
          if fac == 1
             ndata =  reshape((data{fac}),paso,1,dimen(end));
          else
             ndata = cat(2,ndata,(reshape(data{fac},paso,1,dimen(end))));
          end
      end
      r = dimen(end);
      c = length(data);
      reps=1;
      texto = plus_text(texto,'Friedman test for paired samples');
      texto = plus_text(texto,'.');
      clear data
        for p = 1:paso
        bar = bar_wait(p,paso,'pre(FRIEDMAN) pos( ) B(.) R(o)');
              if ~isempty(bar)
              texto = last_text(texto,bar,1);
              disp_lan(texto);
              end %%%
        %bar_wait(p,paso,'pre( ) pos( ) B(.) R(o)');    
        X = squeeze(ndata(p,:,:))';    
        m = X;
        sumta = 0;
        for j=1:r
           %jrows = reps * (j-1) + (1:reps);
           %v = X(jrows,:);
           [a,tieadj] = tiedrank(X(j,:)');
           m(j,:) = a(:);%reshape(a, reps, c);;
           sumta = sumta + 2*tieadj;
        end

            [r2,c2] = size(X);
            colmean = mean(m,1);        % column means
            rowmean = mean(m,2)';       % row means
            gm = mean(colmean);
            chistat = r2*reps*(colmean - gm)*(colmean-gm)';
        

        sigmasq = c*reps*(reps*c+1) / 12;
        if (sumta > 0)
           sigmasq = sigmasq - sumta / (12 * r * (reps*c-1));
        end
        if (chistat > 0)
           chistat = chistat / sigmasq;
        end
        pval(p) = chi2pval(chistat, c-1); 
        if (nargout > 1)
           if p ==1
           stats.chistat = zeros(size(pval));  
           end
           stats.chistat(p) = chistat;
        end
        end
     
   else
       
       
       
     %%% Kruskal-Wallis  
     
      dimen=size(data{1});
      pval = ones(dimen(1:end-1));
      paso = prod(dimen(1:end-1));
      for fac = 1:length(data)
          dimen=size(data{fac});
          if fac == 1
             ndata  =  reshape((data{fac}),paso,dimen(end));
             ngrupo =  ones(1,dimen(end));
          else
             ndata = cat(2,ndata,(reshape(data{fac},paso,dimen(end))));
             ngrupo = cat(2,ngrupo, fac*ones(1,dimen(end)));
          end
      end
      %r = dimen(end);
      %c = length(data);
      %reps=1;
      clear data
      ngrupo = ngrupo(:);
      texto = plus_text(texto,'Kruskal-Wallis Test  for unpaired samples');
      texto = plus_text(texto,'.');
          for p = 1:paso
         
              bar = bar_wait(p,paso,'pre(KW test) pos( ) B(.) R(o)');
              if ~isempty(bar)
              texto = last_text(texto,bar,1);
              disp_lan(texto);
              end %%%
            
          x = squeeze(ndata(p,:,:))';

           nonan = ~isnan(x);
           x = x(nonan);
        
        % Convert group to indices 1,...,g and separate names  
        
            
            ngrupofix = ngrupo(nonan,:);
            [groupnum, gnames] = grp2idx(ngrupofix);
            named = 1;
          % Remove NaN values
           nonan = ~isnan(groupnum);
           if (~all(nonan))
              groupnum = groupnum(nonan);
              x = x(nonan);
           end
               lx = length(x);
               xorig = x;                    % use uncentered version to make M
               groupnum = groupnum(:);
               maxi = size(gnames, 1);
               if isa(x,'single')
                  xm = zeros(1,maxi,'single');
               else
                  xm = zeros(1,maxi);
               end
               countx = xm;

               [xr,tieadj] = tiedrank(x);

                  for j = 1:maxi
                      % Get group sizes and means
                      k = find(groupnum == j);
                      lk = length(k);
                      countx(j) = lk;
                      xm(j) = mean(xr(k));       % column means
                  end
               
               
                   gm = mean(xr);                      % grand mean
                   df1 = sum(countx>0) - 1;            % Column degrees of freedom
                   df2 = lx - df1 - 1;                 % Error degrees of freedom
                   xc = xm - gm;                       % centered
                   xc(countx==0) = 0;
                   RSS = dot(countx, xc.^2); 
            
                    TSS = (xr(:) - gm)'*(xr(:) - gm);  % Total Sum of Squares
                    SSE = TSS - RSS;                   % Error Sum of Squares

                    if (df2 > 0)
                       mse = SSE/df2;
                    else
                       mse = NaN;
                    end

                    
                       F = (12 * RSS) / (lx * (lx+1));
                       if (tieadj > 0)
                          F = F / (1 - 2 * tieadj/(lx^3-lx));
                       end
                       
            
               
        pval(p) = chi2pval(F,df1);
        if (nargout > 1)
           if p ==1
           stats.chistat = zeros(size(pval));  
           end
           stats.chistat(p) = F;
        end
        end

   

     
     
   end
    
    
    
end % pairwise or multiple





%end % swicth method
end



function p = chi2pval(x,v)
%FPVAL Chi-square distribution p-value function.
%   P = CHI2PVAL(X,V) returns the upper tail of the chi-square cumulative
%   distribution function with V degrees of freedom at the values in X.  If X
%   is the observed value of a chi-square test statistic, then P is its
%   p-value.
%
%   The size of P is the common size of the input arguments.  A scalar input  
%   functions as a constant matrix of the same size as the other inputs.    
%
%   See also CHI2CDF, CHI2INV.

%   References:
%      [1]  M. Abramowitz and I. A. Stegun, "Handbook of Mathematical
%      Functions", Government Printing Office, 1964, 26.4.

%   Copyright 2009 The MathWorks, Inc. 
%   $Revision: 1.1.6.1 $  $Date: 2009/11/05 17:04:17 $


[errorcode,x,v] = distchck(2,x,v);

if errorcode > 0
    error('stats:chi2pval:InputSizeMismatch',...
          'Requires non-scalar arguments to match in size.');
end

% Return NaN for out of range parameters.
v(v <= 0) = NaN;
x(x < 0) = 0;

p = gammainc(x/2,v/2,'upper');
end



