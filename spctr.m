function    [Samp, Sph, EjeF] = spctr(s, FreqRes, SampFreq, FreqRange)

% spctr Computes the spectral amplitude and phase
% of a signal or matrix of signals 's' based on fft transform.
% if 's' is a 2D or 3D matrix, fourier proceed on each column independently.
%
% NOTE!! Asumes that there are more points than independent signals!!
%
% Input variables
%
%     s        : signal or matrix of signals.
%
%    FreqRes   : Frequency resolution in Hz/bin. eg 2 means 2 Hz in one bin, 
%              and 0.5 means  0.5 Hz per bin.
%
%    SampFreq  : Sampling frequency in Hz.
%
%    FreqRange : range of frequencies to be analized eg [10 : 50]
%
% Output Variables
%
%     Samp    : Spectral amplitude of signal 's'
%
%     Sph     : Spectral phase of signal 's'
%
%     EjeF    : axis of analized frequencies. Each element of this vector contains 
%               the central frequency corresponding to each analized bin.
%


 [r,c] = size(s);



% number of points required to obtain a frequency resolution
% as requested in 'FreqRes' given that the sampling frequency is 'SampFreq'
N = SampFreq/FreqRes;

% new N is the next power of 2 of the original N
N = 2^nextpow2(N);

% N points fourier transform of signal s
S = fft(s,N);

% angulos
Sph=angle(S);
   
% amplitudes
Samp=abs(S);

% range of frequencies that are computed by the fft (in Hz)                     
Frequencies = (0:N/2)*(SampFreq/N);

% range of indexes valid for the fft
Indexes = [1:N/2+1];
                          
% range of indexes corresponding to the frequency range specified by FRANGE
IRANGE = unique(interp1(Frequencies,Indexes,FreqRange,'nearest'));
    
% frequency axis as specified by FRANGE
EjeF = Frequencies(IRANGE);

Samp = Samp(IRANGE,:);
Sph  = Sph (IRANGE,:);

