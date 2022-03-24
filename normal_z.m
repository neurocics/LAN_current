% Normalize 
% throught the 3th or 2th  dimention
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
% V 1.7
%
% Pablo Billeke
%

% 17.03.2015 add option of baseline
% 21.07.2014 Bug in mdB with baseline
% 17.12.2012 improve performance, and _nonan function
% 12.10.2010 add warning off
% 22.09.2010
% 11.05.2010
% 28.01.2009
% 


function [Samp_out] = normal_z(Samp_in, baseline,Method)

[d1 d2 d3 d4] = size(Samp_in);

if nargin ==1
    baseline = [];
end


if d4>1
   if nargin==1 
       for i = 1:d4
          Samp_out(:,:,:,i) = normal_z(Samp_in(:,:,:,i)) ;
       end
   elseif nargin==2
        if isempty(baseline)
            baseline=Samp_in;
        elseif numel(baseline)==3
            if baseline(1)==1; baseline = Samp_in(baseline(2):baseline(3),:,:,:);
            elseif baseline(1)==2; baseline = Samp_in(:,baseline(2):baseline(3),:,:);
            elseif baseline(1)==3; baseline = Samp_in(:,:,baseline(2):baseline(3),:);end    
        end
        for i = 1:d4
          Samp_out(:,:,:,i) = normal_z(Samp_in(:,:,:,i),baseline(:,:,:,i)) ;
       end
   else
        if isempty(baseline)
            baseline=Samp_in;
        elseif numel(baseline)==3
            if baseline(1)==1; baseline = Samp_in(baseline(2):baseline(3),:,:,:);
            elseif baseline(1)==2; baseline = Samp_in(:,baseline(2):baseline(3),:,:);
            elseif baseline(1)==3; baseline = Samp_in(:,:,baseline(2):baseline(3),:);end    
        end
        
       for i = 1:d4
          Samp_out(:,:,:,i) = normal_z(Samp_in(:,:,:,i),baseline(:,:,:,i),Method) ;
       end 
   end
   return    
end





if (d3==1)&&(d2==1)
    pp = [3,2,1];
   ifp = 1; 
elseif d3==1
   pp=[1,3,2];
   ifp = 1;
else
   ifp=0; 
end



if isempty(baseline)
            baseline=Samp_in;
        elseif numel(baseline)==3
            if baseline(1)==1; baseline = Samp_in(baseline(2):baseline(3),:,:,:);
            elseif baseline(1)==2; baseline = Samp_in(:,baseline(2):baseline(3),:,:);
            elseif baseline(1)==3; baseline = Samp_in(:,:,baseline(2):baseline(3),:);end    
end
        



if ifp      
   Samp_in = permute(Samp_in,pp);
   try baseline = permute(baseline,pp); end 
end



 if nargin == 0
     edit normal_z
     help normal_z
     return
 end

if nargin < 3 
    Method = 'z';
end


if nargin < 2 || isempty(baseline)
    baseline = Samp_in;
end
[x  y  z] = size(Samp_in); 

if strcmp(Method, 'z' )
    
    Samp_in = reshape(Samp_in,x*y,z);
    baseline = reshape(baseline,size(baseline,1)*size(baseline,2),size(baseline,3));
    Samp_out = (Samp_in - repmat(mean_nonan(baseline,2),[1,z])) ./ repmat(std_nonan(baseline,2),[1,z]);
    Samp_out = reshape(Samp_out,x,y,z);
%  for xx = 1:x
%      for yy = 1:y
%          bl = baseline(xx,yy,:);
%          bl(isnan(bl)) = [];
%          Samp_out(xx,yy,:) = (Samp_in(xx,yy,:) - mean(squeeze(bl)) ) / std(squeeze(bl));
%      end
%  end

elseif strcmp(Method, 'bz' )
for xx = 1:x
    for yy = 1:y
        bl = baseline(xx,yy,:);
        bl(isnan(bl)) = [];
        
        stat = bootstrp(50,@(x)[mean(x) std(x)],bl);
        mm = mean(stat(:,1));
        ss = mean(stat(:,2));
        
        Samp_out(xx,yy,:) = (Samp_in(xx,yy,:) - mm ) / ss;
    end
end    
elseif strcmp(Method, 'm' )
warning off    
for xx = 1:x
    for yy = 1:y
        bl = baseline(xx,yy,:);
        bl(isnan(bl)) = [];
        mm = mean(bl);

        
        Samp_out(xx,yy,:) = (Samp_in(xx,yy,:) - mm ) ;
    end
end  
warning on 
elseif strcmp(Method, 'mdB' ) || strcmp(Method, 'dB' ) 
warning off    
Samp_in = log10(Samp_in);
baseline =log10(baseline);

    Samp_in = reshape(Samp_in,x*y,z);
    baseline = reshape(baseline,size(baseline,1)*size(baseline,2),size(baseline,3));
    Samp_out = (Samp_in - repmat(mean_nonan(baseline,2),[1,z]));
    Samp_out = 10*reshape(Samp_out,x,y,z);




% for xx = 1:x
%     for yy = 1:y
%         bl = baseline(xx,yy,:);
%         bl(isnan(bl)) = [];
%         mm = (mean(bl));     
%         Samp_out(xx,yy,:) = ((Samp_in(xx,yy,:)) - mm )*10 ;
%     end
% end
warning on


end

if ifp
Samp_out = permute(Samp_out,pp);
end

end

