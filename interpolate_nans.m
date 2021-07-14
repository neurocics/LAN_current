function Y = interpolate_nans(varargin)
% FILLNANS replaces all NaNs in array using inverse-distance weighting.
%
% Y = interpolate_nans(X) replaces all NaNs in the vector or array X by
% inverse-distance weighted interpolation:
%                       Y = sum(X/D^3)/sum(1/D^3)
% where D is the distance (in pixels) from the NaN node to all non-NaN
% values X. Values farther from a known non-NaN value will tend toward the
% average of all the values.
%
% Y = interpolate_nans(...,'power',p) uses a power of p in the weighting
% function. The higer the value of p, the stronger the weighting.
%
% Y = interpolate_nans(...,'radius',d) only used pixels < d pixels away in
% for weighted averaging.


X = varargin{1}; %input array
Y = X; %output array
n = 2; %weighting power
d = 0; %distance cut-off radius (0= all pixels, no cut-off)
if nargin > 1 && nargin < 6
    for k=2:2:length(varargin)
        if isnumeric(varargin{k}) || ~isnumeric(varargin{k+1})
            error('Input arguments must be in ''option'',value form.')
        end
        switch lower(varargin{k})	
            case 'power'
                n = varargin{k+1};
            case 'radius'
                d = varargin{k+1};
            otherwise
                error(['Unrecognized input argument: ',varargin{k}])
        end
    end
elseif nargin >= 6
    error('Too many input arguments')
end

[rn,cn]=find(isnan(X));
[r,c]=find(X>0 | X<0);     %row,col of non-nans
ind=find(X>0 | X<0);       %index of non-nans

%Break distance-finding loops into with cut-off and without cut-off
%versions. The cutoff conditional statement adds time
%if cut-off values near the max pixel distance are used.

if d %distance cut-off loop
    d=d.^2;				% (Urs:allows first step without SQRT())
    for k = 1:length(rn)
        D = (rn(k)-r).^2+(cn(k)-c).^2;	
        Dd = D < d;
        if sum(Dd) ~= 0
            D=1./sqrt(D(Dd)).^n;
            Y(rn(k),cn(k)) = sum(X(ind(Dd)).*D)./ sum(D);
        end
    end
else 
    for k = 1:length(rn)
        D = 1./(sqrt((rn(k)-r).^2+(cn(k)-c).^2)).^n;% 
        Y(rn(k),cn(k)) = sum(X(ind).*D)./sum(D);
    end
end



