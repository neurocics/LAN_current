function Z = waveletTransformFourier(f1,f2,pas,X)
% wavelet transform (Morlet complex wavelet)  of signal X
%
% Z = waveletTransformFourier(f1,f2,pas,k,x)

%  INPUTS:
%      X         is a column  vector
%      f1        is the lower frequency in the decomposition (in normalized units, ie the highest frequency is 0.5)
%      f2        is the higher frequency in the decomposition (in normalized units, ie the highest frequency is 0.5)
%      pas      frequency resolution (in normalized units)
%      
%  OUTPUT
%      Z       wavelet transform of X (can be complex valued)

taille = max(size(X));
X = X - mean(X);
if taille == size(X,2)
    X = X';
end;
widthMorlet = 7;   %--- width of the mother wavelet 
m = length(f1:pas:f2);
n = length(X);
l=1;
Nfref = floor(taille/2);
freq = ((0:(Nfref-1))/(Nfref-1))/2;
fftx = fft(X);
Psi = zeros(1,taille);
Z = zeros(m,n);
for f = f1:pas:f2 
    sigmaF = f/widthMorlet;
    sigmaT = 1/(2*pi*sigmaF);             
    w = 2*pi*(freq - f)*sigmaT;
    Psi(1:Nfref) = realpow(4*pi*sigmaT*sigmaT, 1/4)*exp(-(w .* w)/2);   
    %figure, plot(Psi), pause;
    Z(l,:)  = fliplr(ifft(fftx'.* Psi));
    l = l+1;
end
return