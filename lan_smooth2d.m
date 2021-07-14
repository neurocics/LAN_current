function A = lan_smooth2d(A, span, fact, times)
% deprecated. See lan_smooth.m
if nargin < 2
    A = lan_smooth(A);
elseif nargin < 3
    A = lan_smooth(A,span);
elseif nargin < 4
    A = lan_smooth(A,span,fact);
else
    A = lan_smooth(A,span,fact,times);
end
