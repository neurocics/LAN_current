function pv = FDRlan(a,alfa)

if nargin==1
    alfa=0.05;
end

[y x] = size(a);
if (y == 1)&&(x>1)
    a = a';
end

a = sort(a);
a(isnan(a))= [];
[y x] = size(a);

for nv = 1:x
    p=[];
for i =1:y
   if a(i,nv) > (i/y)*alfa; 
   p(i,nv)=0; 
   else
   p(i,nv)=1;    
   end
  
end


if isempty(find(p(:,nv),1,'last'))
%pv=a(1,nv)/2;
pv=0;
else
pv(nv) = a(find(p(:,nv),1,'last'),nv);    
end

end
