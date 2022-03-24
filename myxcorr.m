function [cc,lags] = myxcorr(A, B,maxlag,bin)

A = ceil(A);
B = ceil(B);
cc = zeros(1, 2*maxlag+1);
for c = 1:length(B)
    aux = B(c)-A;
    aux = aux( aux<=maxlag & aux>=-maxlag ) + maxlag + 1;
    cc(aux) = cc(aux)+1;
end
phase = (length(cc)+1) / 2; % middle point
% cc(phase) = 0;

% binning
phase = phase - (bin-1)/2; % middle point at the bin's center
for c = bin:length(cc)
    aux = c - mod(c-phase,bin);
    if aux ~= c
        cc(aux) = cc(aux) + cc(c);
        cc(c) = 0;
    end 
end
cc(1:bin-1) = 0;
% centrar
aux = (bin-1)/2;
cc(1+aux:end) = cc(1:end-aux);
lags = -maxlag:maxlag;