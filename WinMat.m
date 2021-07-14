function  [wsM] = WinMat(M, win, step)

% WinMat(M, win, step); uses data from signal matrix 'M'
% to construct a 3D matrix wsM using 'win' succesive rows
% The sorting procedes on the columns, by taking the first 'win' rows.
% Then, separated by 'step', the following 'win' rows and so on. 
%
% Ej:  M =[ 1  4
%           2  3      ----> WinSum(M,2,1) = (:,:,1)= [1 4
%           3  2                                      2 3]
%           4  1]
%                                           (:,:,2)= [2 3
%                                                     3 2]
%
%                                           (:,:,3)= [3 2
%                                                     4 1]
%
%  See also 'SumN' and 'Wmean'
%  E. Rodriguez 2008

[rows, cols] = size (M);

nsteps = 1+(rows - win)/step;
fnsteps = fix(nsteps);
% if  'nsteps' is not integer, change the matrix size to make 'nsteps' integer 
if nsteps ~= fnsteps
    drows =(fnsteps)*step + win - rows;
    M = [M;zeros(drows,cols)];
    [rows, cols] = size (M);
    nsteps = 1+(rows - win)/step;
end

% I advancing of indexes in 'win' windows separated by step
MindI = repmat([1:win]',1 ,nsteps) + repmat([0:nsteps-1]*step,win ,1); 
MindI = repmat(MindI,1, cols);
% J adds the values required by the number of columns
MindJ = reshape(repmat([0:cols-1]*rows,win*nsteps,1), win, nsteps*cols); 

% constructing a 3D matrix 1D: time points, 2D: signals 3D: succesive time windows 
wsM =permute(reshape(M(MindI+MindJ),[win nsteps cols]),[1 3 2]);

