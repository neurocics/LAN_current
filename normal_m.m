% Normalize for mean
% V 1.0
% 21.12.2009
% Pablo Billeke
% % format 1 = fieldtrip electrodo/frecuencia/tiempo
% % format 0 = frecuencia/electrodo/tiempo

function [Samp_out] = normal_z(Samp_in, baseline,format)
if nargin <3
    format = 0;
end
if nargin < 2
    baseline = Samp_in;
end
[x  y  z] = size(Samp_in); 

if format == 0
for xx = 1:x
    for yy = 1:y
        Samp_out(xx,yy,:) = (Samp_in(xx,yy,:) - mean(squeeze(baseline(xx,yy,:))) ); %/ std(squeeze(baseline(xx,yy,:)));
    end
end
end



