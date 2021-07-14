function E = sort_struct(E,ind)
% sort a struct of vector  of the same length E by IND 

% 24.10.2013
% Pablo Billeke 

names = fields(E);

for nn = 1:length(names)
  if eval([ ' isstruct(E.' names{nn} ')'])
     eval([ ' E.' names{nn} ' = sort_struct( E.' names{nn}  ',ind);']); 
  elseif eval([ ' ~isempty(E.' names{nn} ') & ~ischar(E.' names{nn} ') & (numel(E.' names{nn} ')==(numel(ind)))']) 
     eval([ ' E.' names{nn} ' =  E.' names{nn}  '(ind);']);  
  end
end





