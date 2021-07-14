%b8d3721ed219e65100184c6b95db209bb8d3721ed219e65100184c6b95db209b
%  For EEGLAB and LAN format
%  windows in points of signal
%  Only for continuous data
%
%
% Author: Javier Lopez-Calderon, CMB
% Davis, December 2007 - June 2008
%
% Copyright (C) 2008   Javier Lopez-Calderon  &  Steven Luck, 
% Center for Mind and Brain, University of California, Davis,
% javlopez@ucdavis.edu, sjluck@ucdavis.edu
%   
% This program is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
% 
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
% 
% You should have received a copy of the GNU General Public License
% along with this program.  If not, see <http://www.gnu.org/licenses/>.

function [LAN] = polydetrend(LAN,windows)


if nargin < 1
   help polydetrend
   return
end


if isstruct(LAN)
    LAN = polydetrend_struct(LAN,windows);
elseif iscell(LAN)
    for lan = 1:length(LAN)
    LAN{lan} = polydetrend_struct(LAN{lan},windows);
    end
end
end


function [EEG] = polydetrend_struct(EEG, window)



if isempty(EEG.data)
   disp('polydetrend error: cannot detrend an empty dataset')
   return
end

if ~isempty(EEG.epoch)
   disp('polydetrend error: Only for continuous data!')
   return
end

[ a b c] = size(EEG.data);
if c > 1
   disp('polydetrend error: Only for continuous data!')
   return
end
if a == 1 & iscell(EEG.data)
   disp('polydetrend error: Only for continuous data!')
   return
end

clear a b c





[numchan points] = size(EEG.data);
nwin = round(points/window); % a priori

% calculas los puntos representativos por ventana
xf = linspace(1,nwin,points);
%polydata = 0*EEG.data;
ss = zeros(numchan,nwin);
%trend = zeros(1,nwin);


for i = 1:numchan
   a = 1;
   b = window; %valor inicial
   for j=1:nwin
      if b <= points
         ss(i,j) = mean(EEG.data(i,a:b)); %canal * ventana
         a = b + 1;
         b = b + window;
      else
         ss(i,j) = ss(i,j-1);
      end
   end

   % Poner otros metodos aqui...
   %p = polyfit(1:nwin,ss(i,:),orderpoly);
   %polydata(i,:) = data(i,:) - polyval(p,xf);
   %polydata(i,:) = polyval(p,xf);
   %polydata(i,:) = interp1(1:nwin,ss(i,:),xf);

   %trend = spline(1:nwin, ss(i,:),xf);
   %polydata(i,:) = EEG.data(i,:) - trend;

   EEG.data(i,:) = EEG.data(i,:) - spline(1:nwin, ss(i,:),xf); % menos RAM!
   %EEG.data(i,:) = spline(1:nwin, ss(i,:),xf); % menos RAM!
end
end

%EEG.data = polydata;
% Putas que salio util esta weaita! Me anote un poroto!
