% Normalize for z-score
%  alias de normal_z.m
% V 0
% 
% Pablo Billeke


function [Samp_out] = Nz(Samp_in, baseline,format)
if nargin <3
    format = 0;
end
if nargin < 2
    baseline = Samp_in;
end

Samp_out = normal_z(Samp_in, baseline,format);

end