function B = smooth_2D(A,met)
%       <*LAN)<}
%     
%       Aproximation for made a simply smooth in 2D data.
%       
%       27.01.2011

if nargin ==1
    met = 'moving';
end
warning off   %% no disply warning divide by zero
[x y] =  size(A);
for xi =1:x
    B1(xi,:) = smooth(A(xi,:),met);
end
for yi =1:y
    B2(:,yi) = smooth(A(:,yi),met);
end
B = (B1+B2 + A)/3;
warning on