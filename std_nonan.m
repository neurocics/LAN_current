function y = std_nonan(x,dim)
%
% LAN version of std.m to computed std in matrix with NaN values
%
% Y = STD_NONAN(X,DIM) takes the standard deviation along the dimension
%   DIM of X. 
%   

% Pablo Billeke
% 25.09.2012

  dd = size(x);
  dm=(ones(size(dd)));
  dm(dim)=dd(dim);
  dd(dim)=1;
  mx = zeros(size(x));
  mx(isnan(x)) = 1;
  x(isnan(x)) = 0;
  y = sum(x,dim) ./ (repmat(size(x,dim),dd)-sum(mx,dim));
  y = repmat(y,dm);
  x(mx==1) = y(mx==1);



y = sqrt(var(x,[],dim));