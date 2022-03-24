function [pval, stats] = lan_model_stat(varargin)
% v.0.5
% [pval stats] = lan_model_stat(y,x1,x2,...,cfg)
% [pval stats] = lan_model_stat( {y,x1,x2,...}, cfg)
%
%  Y            : n_dim matrix of data 
%  X1, X2,...   : Vectors of Regressors 
%
% cfg.type = 'glm' , 'robust', 'lme'
% cfg.ops = 'option' % for bar  SEE bar_wait.m  
% cfg.text= 'char'   % SEE bar_wait.m  
% Dependences: Statistic Toolbox
%
% Pablo Billeke
% 03.03.2022 --> Visualization compatibility 
% 21.06.2017 --> implenetado modelo mixto LME, REQUIERE MATLAB 2015 en
%                adelante!!!; ultimo X, es el factoro de agrpaci?n para
%                intercepto!!!!
% 11.04.2014
% 05.03.2014
% 16.05.2012

if nargin == 0
   help  lan_model_stat
   if strcmp(lanversion('t'),'devel')
       edit lan_model_stat
   end
   return
end


if isstruct(varargin{end})
  cfg = varargin{end};
  varargin = varargin(1:end-1);
%  nx = length(varargin)-1;  
else
  cfg = [];
%  nx = length(varargin);
end

% check this 
if length(varargin)==1 && iscell(varargin{1});
   varargin = varargin{1}; 
end
y=varargin{1};
varargin(1)=[];
varargin = varargin(1:end);
nx=length(varargin);

%cfg
ntype = getcfg(cfg,'type','glm');
ops = getcfg(cfg,'ops',' ');
texto = getcfg(cfg,'texto', [' ']);
texto = plus_text(texto,['Model fitting  ...'  ]);
dimen = size(y);
ns = dimen(end);

for x = 1:nx+1
pval{x} = zeros(dimen(1:(end-1)));
stats.t{x} = zeros(dimen(1:(end-1)));
stats.b{x} = zeros(dimen(1:(end-1)));
end

np = prod(dimen(1:(end-1)));


y = reshape(y,np,ns);

% regresors
for x = 1:nx
  if numel(varargin{x})==ns;
  ifuni(x) = true;
  elseif numel(varargin{x})==np*ns;
  varargin{x} = reshape(y,np,ns);
  ifuni(x) = false;
  else
    error('dimension of xs')
  end
end
warning off
% type
switch ntype
    
    case {'lme', 'fitlme'}    
    
    x_s = '' ;
    x_n = ' ';
    f='Y ~ 1 ';
    for x=1:nx
       if ifuni, rp = '1'; else rp = 'p' ; end
       %if x==1, first=''; ys='y(p,:)'; else first=' , '; ys='' ;;end
       x_s = [ x_s , strrep( strrep([', varargin{x}(p,:)'' ' ], 'x' , num2str(x)), 'p' , rp )    ];
       x_n = [ x_n   ', ''X' num2str(x) ''' '  ];
       if x==nx
       f= [f '+ (1|X' num2str(x)  ') ' ];   
       else
       f= [f '+X' num2str(x)  ' ' ];
       end
    end
    x_s = ['table(y(p,:)''  ' x_s ', ''VariableNames'' , { ''Y'' ' x_n  ' } )  '];
    
    
    
    
    for p = 1:np
    bar_wait(p,np,ops,texto);
    % no perform regretion with NaNs    
    if any(isnan(y(p,:)))   
        continue
    end
    
    D=eval(x_s);
    clear lme
    lme = fitlme(D,f);
    
    %[b a s] = glmfit( eval(x_s) , y(p,:) );
    for x = 1:nx
    pval{x}(p)=lme.Coefficients.pValue(x);
    stats.t{x}(p)=lme.Coefficients.tStat(x);
    stats.b{x}(p)=lme.Coefficients.Estimate(x);
    end
    end        
        
        
        
        
case {'glm','lm'}
    x_s = 'cat(2' ;
    for x=1:nx
    if ifuni, rp = '1'; else rp = 'p' ; end
       x_s = [ x_s , strrep( strrep(', varargin{x}(p,:)'' ' , 'x' , num2str(x)), 'p' , rp )    ];
    end
    x_s = [ x_s ' )  '];

    for p = 1:np
    bar_wait(p,np,ops,texto);
    % no perform regretion with NaNs    
    if any(isnan(y(p,:)))   
        continue
    end
    
    %[b a s] = glmfit( eval(x_s) , y(p,:) );
    x = eval(x_s);
    yy = y(p,:)'; 
    b   = (x'*x)\x'*yy;
      
    y_fit = x*b;
    df  = -diff(size(x));
    s   = (sum((yy-y_fit).^2)/df)^0.5;
    se  = (diag(inv(x'*x))*s^2).^0.5;
    T   = real(b./se); % aboid error in redundant regressors ??
    %P   = (T>=0).*(1 - tcdf(T,df))*2 + (T<0).*(tcdf(T,df))*2;
 
    for x = 1:nx%+1
    %pval{x}(p)=P(x);
    stats.t{x}(p)=T(x);
    stats.b{x}(p)=b(x);
    end
    end
    
    for x = 1:nx%+1
    pval{x}=  (stats.t{x}>=0).*(1 - tcdf(stats.t{x},df))*2 + (stats.t{x}<0).*(tcdf(stats.t{x},df))*2;  %P(x);
    %stats.t{x}(p)=T(x);
    %stats.b{x}(p)=b(x);
    end
    
    
case 'robust'
    x_s = 'cat(2' ;
    for x=1:nx
       if ifuni, rp = '1'; else rp = 'p'; end
       x_s = [ x_s , strrep( strrep(', varargin{x}(p,:)'' ' , 'x' , num2str(x)), 'p' , rp )    ];
    end
    x_s = [ x_s ' )  '];

    for p = 1:np
    bar_wait(p,np,ops,texto);
    % no perform regretion with NaNs    
    if any(isnan(y(p,:)))   
        continue
    end
    
    [b  s] = robustfit( eval(x_s) , y(p,:) );
   
    for x = 1:nx+1
    pval{x}(p)=s.p(x);
    stats.t{x}(p)=s.t(x);
    stats.b{x}(p)=b(x);
    end
    end	
end% switch type
 warning on


end % fucntion