function A = mat_t_cell(B)
%
% v0.0.01
% 22.09.2010

if ~iscell(B)
   filas = ones(1,size(B,1));
   columnas = ones(1,size(B,2));
   
   A = mat2cell(B,filas,columnas);
%elseif isnumeric(B)
%    display('B cell')
%else
%    erro('B must be mat')
%end
else
    A=B;
end