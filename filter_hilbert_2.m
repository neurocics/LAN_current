
function xend = filter_hilbert_2(x,Fs,Fp1,Fp2)
% En proceso
%
% Hilbert filter
%	(1) Realizar filtros pasabanda de la senal x,   Entre Fp1 yFp2, 
%        Fs como frecuencia de muestreo
%	(2) Aplica transfomada de hilbert para general se??al analitica (Sa) 
%       de la se??al (S), forma:
%
%			Sa(t) = S(t) + i*H(S(t)) 
%
%
%
%  Modificada por P.Billeke 3.12.2009
%
% data centered

x = double(x);

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
xf = xfft.* f';  

xr=real(ifft(xf));

xr = hilbert(xr);

xend = shiftdim(xr,-nshifts);


%mean(xr,1)
%figure
%plot(real(xr(:,16)))
%hold on
%plot(real(xr(:,22)),'r')
%pause
%xend = hilbert(B);
%h  = zeros(n,~isempty(xf)); % nx1 for nonempty. 0x0 for empty.
%if n>0 & 2*fix(n/2)==n
  % even and nonempty
 % h([1 n/2+1]) = 1;
 % h(2:n/2) = 2;
%elseif n>0
  % odd and nonempty
 % h(1) = 1;
%  h(2:(n+1)/2) = 2;
%end

%xhilbert = ifft(xf.*h(:,ones(1,size(x,2))));

% Convert back to the original shape.
%xend = shiftdim(xhilbert,-nshifts);
