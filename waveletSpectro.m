function [Samp, Sph] = waveletSpectro(SIG, FE, FRANGE, ResHz, step)
% [Samp, Sph] = waveletSpectro( SIG, FE, FRANGE, FRANGE,ResHz, step)
% [Fft] = waveletSpectro( SIG, FE, FRANGE, FRANGE,ResHz, step)
% uses a FFT transform to compute the spectral power and phase values, of a matrix of signals 'SIG'.
% The smaller dimension of 'SIG' is considered to contain the electrodes and
% the longer one, the timepoints.
%
% INPUT :
%    SIG      = Matrix of signals  1D time, 2D channels
%	 FE       = Sampling frequency in Hz.
%   FRANGE     = Range of analized frequencies in Hz. eg [10 100]
%   ResHz     = resolution in bins per Hz, 2 means  2 bins per Hz.
%   step      = if is a number = step  e.g (10)
%               if is a vector the points for calculus eg ( 100:20:1500) or
%               (100 100) --> for one points only!!!
%
%
% OUTPUT :
%
%    Samp   = Matrix of signal amplitudes.
%                    1D frequencies, 2D electrodes, 3D time-points/step.
%    Sph      = Matrix of phase information. in radians
%                   1D frequencies, 2D electrodes, 3D time-points/step.
%    Fft      = Matrix of fourier complex number
%                   1D frequencies, 2D electrodes, 3D time-points/step.
%    EjeF     = Frequency axis for plotting (in Hz)
%
% Eg:
%               [CumRho, Phi] = waveletSpectro( MatSig,1000, [1 40], 1, 10);
%
%       M. Chavez 2011

% LAN modifications 
% Pablo Billeke
% v.0.0.3

% 04.05.2012 (PB) specifict points options (a not step)
% 09.12.2011 (PB) variable output
% 22.11.2011 (PB)

%If columns are not signals, transpose

[rows, columns]=size(SIG);
% if rows < columns
% SIG = SIG';
% end

Npts = rows;       % time
Nsig = columns;    % channel

% specific points rather than step
if numel(step)>1
    pp = unique(step(:)');
else
    pp = 1:step:Npts;
end

% Range of frequencies that are computed (in Hz)
EjeF = [FRANGE(1):ResHz:FRANGE(2)];

for channel = 1 : Nsig
    Z = waveletTransformFourier(FRANGE(1)/FE,FRANGE(2)/FE,ResHz/FE,SIG(:, channel));
    Z = Z(:,pp);
    if nargout == 2
    Samp(channel,:,:) = abs(Z)';
    Sph(channel,:,:) = angle(Z)';
    else
    Samp(channel,:,:) = Z; 
    end
end

return
