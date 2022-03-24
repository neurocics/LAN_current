function [Samp, Sph, EjeX, EjeF] = spectrogram_hilbert_lan( SIG, FE, FRANGE, TRANGE)
% [Rho, Phi, EjeX, EjeF] = spectrogram_hilbert_lan( SIG, FE, FRANGE, TRANGE, WinSig, ResHz, step)
% uses a hibert transform to compute the amplitud  and phase values, of a matrix of signals 'SIG'. 
% The smaller dimension of 'SIG' is considered to contain the electrodes and
% the longer one, the timepoints.
%
% INPUT :
%    SIG      = Matrix of signals of dimension 2D (asumes # time points > # channels)
%	 FE       = Sampling frequency in Hz.
%  FRANGE     = Range of analized frequencies in Hz. eg [10:2:100]
%  TRANGE     = Range of trial time in ms.  eg [-300 700]            
%  
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
%       E.Rodriguez 2008
%       fixed by P.Billeke, compatibility for eeglab structure 
%                       EEG.data with epochs
%                       


                                      




% If columns are not signals, transpose
[rows, columns, z]=size(SIG);
if rows < columns & z==1
    SIG = SIG';
end

Npts = max(rows, columns);
Nsig = min(rows, columns);



for i = 1 : length(FRANGE)
    FILT_BAS = FRANGE(i) - 1.5;
    FILT_HAU = FRANGE(i) + 1.5;
    SIG_A = filter_hilbert(SIG,FRANGE(i),FILT_BAS,FILT_HAU);
    
    % Spectral amplitude and phase of MATSIG
    %  [Samp(:,:,i), Sph(:,:,i), EjeF] = spctr(MATSIG, ResHz, FE, FRANGE);
    
    Samp (i,:,:) = abs(SIG_A);
    Sph(i,:,:) = angle(SIG_A);
    
end

% tiempo
EjeX = [TRANGE(1):((TRANGE(2)-TRANGE(1))/(size(SIG,1)-1)):TRANGE(2)];
EjeF = FRANGE;
end