function [Samp, Sph, EjeX, EjeF] = spectrogram_hilbert_lan( SIG, FE, FRANGE, TRANGE,r_s)
%  v.0.0.2
%
%
% [Rho, Phi, EjeX, EjeF] = spectrogram_hilbert_lan( SIG, FE, FRANGE, TRANGE, WinSig, ResHz, step)
% this function uses a hibert transform to compute the amplitud  and phase values of a matrix of signals 'SIG'. 
% The smaller dimension of 'SIG' is considered to contain the electrodes and
% the longer one, the timepoints.
%
% INPUT :
%    SIG      = Matrix of signals of dimension 2D (asumes # time points > # channels)
%	 FE       = Sampling frequency in Hz.
%  FRANGE     = Range of analized frequencies in Hz. eg [10:2:100]
%  TRANGE     = Range of trial time in ms.  eg [-300 700]            
%  r_s        = resample parametres [1 4]
% OUTPUT :
%
%    Samp    = Matrix of signal amplitudes:
%            1D frequencies, 2D electrodes, 3D time-points/step, 
%    Sph    = Matrix of phase information: same dimensions as Rho 
%             1D frequencies, 2D electrodes, 3D time-points/step, 
%    EjeX   = Time axis for plotting (in ms): same length of time/steps
%    EjeF   = Frequency axis for plotting (in Hz)
%      
% Eg:
%       [Rho, Phi, EjeX, EjeF] = spectrogram_hilbert_lan( MatSig, 1000, [11:70],[-300 700]);
%
%
% Pablo Billeke                  
%                               
% 12.05.2010
% 2009




% If columns are not signals, transpose
[rows, columns, z]=size(SIG);
if rows < columns & z==1
    SIG = SIG';
end




% re sample
if ~isempty(r_s)
SIG = resample(double(SIG), r_s(1),r_s(2));
SIG = single(SIG);
end

%%%
%%% arreglar efecto borde:
%%%
[t l] = size(SIG);
tt = floor(t/2);
iS(tt:-1:1,:) = SIG(1:tt,:);
fS(1:tt,:)    = SIG(t:-1:(t-tt+1),:);
SIGa = cat(1,iS,SIG,fS);
clear iS fS SIG
%%% evaluar utilidad de esta primera parte
[t l] = size(SIGa);
SIGa = SIGa .* repmat( jphamm(l),t,1) ; %% HAMMING
%%%
%%%
%%%

% tiempo x electrodos

for i = 1 : length(FRANGE)
    FILT_BAS = FRANGE(i) - 1.5;
        if  FILT_BAS < 0.5
            FILT_BAS = 0.51;
        end
    FILT_HAU = FRANGE(i) + 1.5;
    SIG_A = filter_hilbert(SIGa,FE,FILT_BAS,FILT_HAU);
  
    SIG_A = SIG_A(tt+1:t+tt,:);
    SIG_A = SIG_A';
   % pause(0.001)
   %
   Samp{i}(:,:) = abs(SIG_A);
   % Samp(i,:,:) = abs(SIG_A);
   %
   % Sph(i,:,:) = angle(SIG_A);
 Sph{i}(:,:) = angle(SIG_A) ;
    %
    clear SIG_A
    
end
clear SIGa
%

Samp = cat(3,Samp{:});
Samp = shiftdim(Samp,2);
Sph = cat(3,Sph{:});
Sph = shiftdim(Sph,2);
% tiempo
EjeX = linspace(TRANGE(1),TRANGE(2),tt);%[TRANGE(1):((TRANGE(2)-TRANGE(1))/(size(SIG,1)-1)):TRANGE(2)];
EjeF = FRANGE;
end


function w = jphamm(n)
%HAMMING HAMMING(N) returns the N-point Hamming window.

%	    Copyright (c) 1984-94 by The MathWorks, Inc.
%       $Revision: 1.4 $  $Date: 1994/01/25 17:59:14 $

w = .54 - .46*cos(2*pi*(0:n-1)'/(n-1));
end