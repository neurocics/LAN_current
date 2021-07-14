function E = del_struct(E,ind)
% del a struct of vector  of the same length E by IND 

% 4.10.2013
% Pablo Billeke 

names = fields(E);

for nn = 1:length(names)
  if eval([ ' isstruct(E.' names{nn} ')'])
     eval([ ' E.' names{nn} ' = del_struct( E.' names{nn}  ',ind);']); 
  else
     eval([ ' E.' names{nn} '(ind) = [];']);  
  end
end