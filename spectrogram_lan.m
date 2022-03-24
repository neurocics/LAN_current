function [Samp, Sph, EjeX, EjeF] = spectrogram_lan( SIG, FE, FRANGE, TRANGE, WinSig, ResHz, step)
% [Rho, Phi, EjeX, EjeF] = spectrogram_lan( SIG, FE, FRANGE, TRANGE, WinSig, ResHz, step)
% uses a FFT transform to compute the spectral power and phase values, of a matrix of signals 'SIG'. 
% The smaller dimension of 'SIG' is considered to contain the electrodes and
% the longer one, the timepoints.
%
% INPUT :
%    SIG      = Matrix of signals of dimension 2D (electtode x time)
%	 FE       = Sampling frequency in Hz.
%  FRANGE     = Range of analized frequencies in Hz. eg [10:2:100]
%  TRANGE     = Range of trial time in ms.  eg [-300 700]            
%   WinSig    = windows of signal (number of points) to be used in each fft computation.
%   ResHz     = resolution in bins per Hz, 2 means  2 bins per Hz.
%    step     = number of time points between succesive computation windows 'WinSig'
%  
% OUTPUT :
%
%    Rho    = Matrix of signal amplitudes: (electrode x time/steps x frequency)
%             1D electrodes, 2D time-points/step, 3D frequencies.
%    Phi    = Matrix of phase information: same dimensions as Rho 
%             1D electrodes, 2D time-points/step, 3D frequencies.
%    EjeX   = Time axis for plotting (in ms): same length of time/steps
%    EjeF   = Frequency axis for plotting (in Hz)
%      
% Eg:
%       [Rho, Phi, EjeX, EjeF] = spectrogram( MatSig, 1000, [11:70],[-300 700], 256, 1, 10);
%
%       E.Rodriguez 2008
%       fixed by P.Billeke, compatibility for eeglab structure 
%                       EEG.data with epochs
%                       


                                      




% % If columns are not signals, transpose
 [rows, columns, z]=size(SIG);
% if rows < columns & z==1
     SIG = SIG';
% end

Npts = columns ;%max(rows, columns);
Nsig = rows;    %min(rows, columns);

% transforming a 2D signal matrix in a 3D matrix of
% 1D: time points(in one window), 2D: channels, 3D: Nwindows
if z == 1
    [wsM] = WinMat(SIG, WinSig, step);
elseif (z > 1 ) && (rows > columns)
    [wsM] = SIG;
elseif (z > 1 ) && (rows < columns)
    SIG = fixed(SIG,2);
    [wsM] = SIG;
else
    error('bad matrix size')
end

%[rows, columns, z]=size(SIG);
%Npts = max(rows, columns);
%Nsig = min(rows, columns);

% the 2D signal matrix is no longer needed
clear SIG


[WinSig, Nsig, Nwins] = size(wsM);

% Computing the time axis
EjeX = TRANGE(1) + (1000/FE)* cumsum([fix(WinSig/2),repmat(step,1,Nwins-1)]);





for i = 1 : Nwins
    % a single time window of signal to be procesed at a time
    % it is a layer of wsM smoothed with a hamming window
    MATSIG = wsM(:,:,i).*repmat(jphamm(WinSig),[1 Nsig]);
    
    % Spectral amplitude and phase of MATSIG
    [Samp(:,:,i), Sph(:,:,i), EjeF] = spctr(MATSIG, ResHz, FE, FRANGE);
    
end




%-------------- Subroutines ---------------


function w = jphamm(n)
%HAMMING HAMMING(N) returns the N-point Hamming window.

%	Copyright (c) 1984-94 by The MathWorks, Inc.
%       $Revision: 1.4 $  $Date: 1994/01/25 17:59:14 $

w = .54 - .46*cos(2*pi*(0:n-1)'/(n-1));

function [new_sig] = fixed(sig,type)

[xxx, yyy, zzz] = size(sig);
new_sig = [];
if type == 1
    for i = 1:zzz
    new_sig = cat(2,new_sig,sig(:,:,i));
    end
elseif type == 2
    for i = 1:zzz
    new_sig(:,:,i) = sig(:,:,i)';
    end
end


