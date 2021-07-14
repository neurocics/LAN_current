function plot_error(x,D,E,C,A)
%   <°LAN)<] toolbox
%   v.0.1
%
%  Plot line graphic with error areas 
%  x  :  X eje,  a vector
%  D  : Data,    a vector
%  E  : Error    a vector 
%  C  : Color    a charecter e.g. 'blue'
%  A  : Trasparency, a scalar e.g.  0.4
%
%
%  Pablo Billeke
%  07.01.2015

% alpha for transparency
if nargin < 5
    A=0.5;
end

% Color
if nargin < 4
    C='blue';
end


% line plot
plot(x,D,'Color',C);

% area plot
errorX = [x x(end:-1:1) x(1)]; 
p =D+E;
n = D-E;
errorY = [ p n(end:-1:1) p(1)];


F = patch(errorX, errorY, -ones(size(errorX)),'FaceColor',C,'EdgeColor','none');
alpha(F,A);


