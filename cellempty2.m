function A = cellempty2(A,r)
%
% v.0.0.1
%
if iscell(A)
[y x z] = size(A);
for yy = 1:y;
for xx = 1:x;    
for zz = 1:z;
    
    if isempty(A{yy,xx,zz})
       A{yy,xx,zz} = r; 
    end
    
end
end
end

else
    error('A must be cell-array')
end