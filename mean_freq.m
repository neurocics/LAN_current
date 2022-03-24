function LAN = mean_freq(LAN,dim)
% v.1.0.1   24.11.2009
%
% LAN =  ; signal with fields 'freq' in cell {trail x elect} with matrix [freq x time]
% dim =  ; dimention of outcome
%         if dim = 3 ; matrix 3d [freq x time x elect]
%         if dim ~= 3 ; cell 1d {1, elect} with matrix 2d [freq x time]
%   
%
% P.Billeke & F.Zamorano 

if nargin < 2
    dim = 2;
end 

freq = LAN.freq.ind;
[t elec] = size(freq);
[fr time] = size(freq{1,1});
uno = ' ';
freq_m = [] ;


for ie = 1:elec
    tr = mean(cat(3,freq{1:t,ie}),3);
     freq_m{1,ie} = tr ;
     clear tr:
end

if dim == 3
    LAN.freq.ind_m = cat(3, freq_m{1,1:elec});
else
    LAN.freq.ind_m = freq_m;
end 


end
