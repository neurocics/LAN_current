function M = fun_in_cell(C,fun)
%
% M = fun_in_cell(C,'FUN(@)')
%     eval de function FUN in each cell.
%     @ is de content od each cell in de cell array C
%
% Pablo Billeke
% 02.03.2016

M = nan(size(C));

for n = 1:numel(C);
   s = strrep(fun,'@','C{n}');
   try
       paso = [eval(s)];
    M(n) =  paso(1);
   catch
    warning(['cell index:' num2str(n)   ' with errors'])   
   end
end