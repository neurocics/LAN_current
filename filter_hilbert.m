
function xend = filter_hilbert(x,Fs,Fp1,Fp2,norbin)
%          <°LAN)<]
%          v.0.1.2
%
% Hilbert filter
%	(1) Realizar filtros pasabanda de la senal x,   Entre Fp1 yFp2, 
%        Fs como frecuencia de muestreo
%	(2) Aplica transfomada de hilbert para generar senal analitica (Sa) 
%       de la senal (S), forma:
%
%			Sa(t) = S(t) + i*H(S(t)) 
%
%
%         
%  Modificada por P.Billeke 

%  22.04.2013
%  10.01.2013
%  03.12.2012 fix two dimenction matrix normalization
%  21.11.2012
%  20.11.2012 add normalizacion per frequency, using the smooth per bin of
%                 frequency given by "norbin"
%  22.04.2009

% Experimental options, to normalized per bin of frequency WHITENING (PB)
if nargin <5
   norbin=0;
end
x = double(x);

% data centered
x_mean=mean(x,1); % mean in time

% restar la media
for k=1:size(x_mean,2) % electrode
    tmp(k,k)=x_mean(k);
end
tmp1=ones(size(x));
tmp=tmp1*tmp;
x=x-tmp;
%mean (x,1)

%Default values in Hz
Fs1 = Fp1 - 0.5; 
Fs2 = Fp2 + 0.5;
if Fs1<= 0;Fs1=Fp1/2;end;


if size(x,1) == 1
    x = x';
end

% Make x EVEN
Norig = size(x,1); 
if rem(Norig,2)
    x = [x' zeros(size(x,2),1)]';                
end

% Normalize frequencies  
Ns1 = Fs1/(Fs/2);
Ns2 = Fs2/(Fs/2);
Np1 = Fp1/(Fs/2);
Np2 = Fp2/(Fs/2);


% Construct the filter function H(f)
N = size(x,1);
Nh = N/2;

B = fir2(N-1,[0 Ns1 Np1 Np2 Ns2 1],[0 0 1 1 0 0]); 
% Make zero-phase filter function
H = abs(fft(B));  


% Work along the first nonsingleton dimension
[x,nshifts] = shiftdim(x);
n = size(x,1);
xfft = fft(x,n,1); % n-point FFT over columns.



f = ones(size(x,2),1)*H; % size f = number of electrodes * number of time samples

% WHITENING
% do the normalization per frequeincy, using a smooth for a given bin of
% frequency "norbin"
if norbin>0
    
   % do the smoothing
   
   % span (Hz to points)
   span = fix((norbin./(Fs./n))/2)*2 +1;
   
   % smooth
   for dm = 1:size(xfft,2)
   nor2(:,dm) = smooth(abs(xfft(:,dm)), span ); 
   end
   %disp(span)
   
   % normalize the amplitud to the mean of the filter band
   for dm = 1:size(xfft,2)
   % normalize amplitud (by the smooth freqcuency spectrum)
   nor(:,dm) = sum(abs(xfft(:,dm).* f(dm,:)'))./nor2(:,dm);
   % to amplified by the  mean amplitud  of the filter band
   nor(:,dm) = nor(:,dm)./sum(f(dm,:)');
   end
   
   %%%------ A graphical explanation of the procedure---------
   if 0
   disp(['using a span of ' num2str(span) ' points '])   
    ejeh = [  0:(Fs/n):(Fs/2) (-Fs/2):(Fs/n):0 ]; 
    ejeh = ejeh(1:fix(n/2));
   figure
    subplot(2,1,1)
    x = abs(xfft);
    %semilogy(ejeh,x(1:fix(n/2))), hold on
    loglog(ejeh,x(1:fix(n/2))), hold on
    x = nor2;
    %semilogy(ejeh,(x(1:fix(n/2))),'r')
    loglog(ejeh,(x(1:fix(n/2))),'r')
    title(['Amplitude  and ' num2str(norbin) ' Hz  smoothed amplitude ' ] )
    subplot(2,1,2)
    x = abs(xfft)./(nor2);
    %semilogy(ejeh,x(1:fix(n/2))), hold on
    loglog(ejeh,x(1:fix(n/2))), hold on
    x = (nor2)./(nor2);
    % semilogy(ejeh,x(1:fix(n/2)),'r')
    loglog(ejeh,x(1:fix(n/2)),'r')
    title('Amplitude normalized by the smoothed amplitude')
    %subplot(3,1,3)
    %plot(log(abs(xfft)).*log(nor)), hold on
    %plot(log(nor),'r')
    %title('normalize per frequiency band smooth aplitud')
   end
   
   %%%--------------------------------------------------------- 
else
   nor = ones(size(x)); 
end
    


% apply the filter and the normalization to the signal
xf = xfft.* f'.*nor;

%xr=real(ifft(xf));
%mean(xr,1)
%figure
%plot(real(xr(:,16)))
%hold on
%plot(real(xr(:,22)),'r')
%pause

% hilbert transform
h  = zeros(n,~isempty(xf)); % nx1 for nonempty. 0x0 for empty.
if n>0 && 2*fix(n/2)==n
  % even and nonempty
  h([1 n/2+1]) = 1;
  h(2:n/2) = 2;
elseif n>0
  % odd and nonempty
  h(1) = 1;
  h(2:(n+1)/2) = 2;
end

xhilbert = ifft(xf.*h(:,ones(1,size(xf,2))));

% Convert back to the original shape.
xend = shiftdim(xhilbert,-nshifts);
