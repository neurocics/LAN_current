function RGB = colormaplan(type,n,lim,cbar,nmax,ne)
%       <*LAN)<]        
%       v.0.0.3
%
% RGB = colormaplan(type,n,lim,cbar,nmax,ne)
% Created Colormap and colorbar
% type = 'pval'    % using the rval result of nonparamteric.m
%        'logP'    % plot the -log10(p value)
% n    =    n      % resolution, default = 100
% lim  =   alpha   % limite for the color change, typically the alpha value
%                  % default = (0.05)
% cbar = true      % add a colorbar in the current active figure
%                  % default = false
% max =            % maximun value if correspond
% RGB = colormaplan(type,n,lim,cbar)
% colormaplan('pval',100, 0.05,1)
%
% See also LAN_NONPARAMETRIC
%
% Pablo Billeke

% 22.01.2014 Fix compatibility with timefreq_plot.m
% 19.10.2011
% 11.04.2011
%
if nargin <5
    nmax=[];
end
if nargin <4
    cbar=0;
end
if nargin < 3
    lim =[];
end
if nargin < 2
    n =100;
end


switch type
    case {'pval','Pval','p-value','p'}
   % RGB     % 1 1 1 ---- 0 0 1 ---  0 0 0.4 - 0 0 0.2 --- 000:
   % ALPHA % 0---------0.02---------0.05------------:
   if isempty(lim)
       razon = 2; %% alfa = 0.05
   else
       razon = (0.1/lim) ;
   end
   
   
   if mod(n,2)==1, n = n-1; end
   a01     = n/2;
   a005   = fix(a01/razon);
   a002   = fix(a01/(razon*2));
   r = cat(2, ...
                  1-(((1:a002)-1)/(a002-1))  ,...
                  zeros(1,(n/2)-a002)    );
   b = cat(2,...
               ones(1,a002),...
               ((((((a005-a002):-1:1)-1)/((a005-a002)-1)))*0.6)+0.4,...
               ((((((a01-a005):-1:1)-1)/((a01-a005)-1)))*0.2)+0 ...
             );
    R = cat(2,r,0,b((n/2):-1:1));   
    B = cat(2,b,0,r((n/2):-1:1)); 
    G = cat(2,r,0,r((n/2):-1:1));  
    
    RGB = [R;G;B];
    RGB = RGB';
    
    % set in the current active figure
    if nargout==0
    colormap(RGB);caxis([0 0.2]);
    if cbar        
        colorbar('YTick',[0,0.02,0.05,0.15,0.18,0.2],'YTickLabel',{'<0.001',' 0.02','0.05','0.05','0.02','<0.001'});
    end
    end
    
    case {'tval','Tval','t-value','t','T'}


    case {'logP','log-p','log(p)','LogP','log10'}
           if isempty(lim)                      
                lim = 0.05;
           end 
           if isempty(nmax) || (-log10(lim)>= nmax)
               nmax = 6; %% alfa = 0.05
           end

           razon =  (nmax+log10(lim))/ nmax ;
           a01    = n/2;
           a005   = fix(a01*razon);
           a002   = fix(a01*razon/2); % 
           
           Lm = num2str(10.^(-(((nmax - (-log10(lim)))/2) + (-log10(lim)))));
           %Lm = Lm(1:5);
           Lt = num2str(10.^(-nmax));
           Lt = ['<' Lt];
           %Li
           Li = num2str(lim);
           
           r = cat(2, ...
                          1-(((1:a002)-1)/(a002-1))  ,...
                          zeros(1,(n/2)-a002)    );
           b = cat(2,...
                       ones(1,a002),...
                       ((((((a005-a002):-1:1)-1)/((a005-a002)-1)))*0.5)+0.4,...
                       ((((((a01-a005):-1:1)-1)/((a01-a005)-1)))*0.2)+0 ...
                     );
            R = cat(2,r,0,b((n/2):-1:1));   
            B = cat(2,b,0,r((n/2):-1:1)); 
            G = cat(2,r,0,r((n/2):-1:1));  
            
            %R = cat(2,1-b,1,ones(size(b)));   
            %B = cat(2,ones(size(b)),1,1-b((n/2):-1:1)); 
            %G = cat(2,1-r,1,1-r((n/2):-1:1)); 

            RGB = [R;G;B];
            RGB = RGB';      
           
    % set in the current active figure
    if nargin == 6
       RGB = RGB * abs(ne);
       if ne >0
       RGB = RGB + ((1-abs(ne)));
       else
           RGB = 1 - RGB;
       end
    end
    
    
    if nargout==0
        
    colormap(RGB);caxis([-nmax nmax]);
    
    if cbar     
        f= 2*nmax/(a01*2);
        a = [0,a002,a005,a01+a01-a005,a01+a01-a002,a01*2]-a01;
        colorbar('YTick',a.*f,'YTickLabel',{Lt,Lm,Li,Li,Lm,Lt});
    end
    
    clear RGB
    end
           
end
end