function [matdif, ParElec] = difphaser3(matphase, step)

% [matdif, ParElec] = difphaser3(matphase, step)
% Computes the phase diferences between all the electrode pairs, provided
% in a matrix of phase info. (Output of sinwave6)
%
% INPUT
%   matphase : 3D Matrix of phase information. 1D electrodes, 2D timepoints, 3D frequencies
%
%   step     : subsampling factor. 
%
% METHOD
%       The phase difference is computed as:				
%	    delta(THETAij) = THETAi - THETAj =  matphase(i,:)*conj(matphase(j,:) 
%	    for any given electrode pair i, j
%
% OUTPUT
%	matdif: Matrix of phase difference between electrode pairs. It has as many 
%           rows as electrode pairs exist (2016 for 64 channels) as many 
%           columns as temporal bins and as many layers as frequencies. 
%
%	ParElec: Matrix index of compared pairs. It has as many rows as
%	         compared electrodes, and two columns with the electrode
%	         number (here between 1-64)
%
% Eg:
%   [matdif, ParElec] = difphaser3(MatPhi, 10);
%
%  E.Rodriguez 2003



[nelec,npts,nfreqs]= size(matphase);

% subsamples the 'matphase' matrix by 'step' points
matphase = matphase(:,1:step:npts,:);

%Computes the combination of electrodes 'ParElec'
count=0;
for ei = 2 : nelec
   for ej = 1 : ei-1
      count=count + 1;
      ParElec(count,:) = [ei,ej];
   end
end

% Computes the matrix of phase differences
matdif(:,:,:) = matphase(ParElec(:,1),:,:).*conj(matphase(ParElec(:,2),:,:));


