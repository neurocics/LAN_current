% Normalize 
% throught the "dim" h dimention
%
%  Method 'z'
%  for z-score
%  
%  Method 'm'
%  for  mean substraction 
%
%  Method 'mdB'
%  for decilBell : 10*log(signal/baseline) 
%
%  Method 'bz'
%  for bootstrapping z-score (Revisar por que esto es absurdo)
%  
%
%
% V 0.1
%
% Pablo Billeke
%
% 15.06.2012
% 


function [Samp_in] = normalize_lan(Samp_in, baseline,dimn,Method)

 if nargin == 0
     if strcmp(lanversion('t'),'devel')
	edit normal_z
     end
     help normal_z
     return
 end

if nargin < 4 
    Method = 'z';
end

if nargin < 3 
   dimn = '3';
end

dime = size(Samp_in);


if nargin < 2 || isempty(baseline)
    %dimn = 3
    baseline = [1:dime(dimn)];
end

baseline = baseline(1):baseline(end);





if strcmp(Method, 'z' )
for xx = 1:x
    for yy = 1:y
        bl = Samp_in(xx,yy,baseline);
        bl(isnan(bl)) = [];
        Samp_in(xx,yy,:) = (Samp_in(xx,yy,:) - mean(squeeze(bl)) ) / std(squeeze(bl));
    end
end
elseif strcmp(Method, 'bz' )
for xx = 1:x
    for yy = 1:y
        bl = Samp_in(xx,yy,baseline);
        bl(isnan(bl)) = [];
        
        stat = bootstrp(50,@(x)[mean(x) std(x)],bl);
        mm = mean(stat(:,1));
        ss = mean(stat(:,2));
        
        Samp_in(xx,yy,:) = (Samp_in(xx,yy,:) - mm ) / ss;
    end
end





    
elseif strcmp(Method, 'm' )
warning off    
for xx = 1:x
    for yy = 1:y
        bl = Samp_in(xx,yy,baseline);
        bl(isnan(bl)) = [];
        mm = mean(bl);

        
        Samp_in(xx,yy,:) = (Samp_in(xx,yy,:) - mm ) ;
    end
end  
warning on 
elseif strcmp(Method, 'mdB' )
warning off    
%Samp_in = log10(Samp_in);
%baseline =log10(baseline);
for xx = 1:x
    for yy = 1:y
        bl = Samp_in(xx,yy,baseline);
        bl(isnan(bl)) = [];
        mm = (log10(mean(bl)));     
        Samp_in(xx,yy,:) = (log10(Samp_in(xx,yy,:)) - mm )*10 ;
    end
end
warning on
end
