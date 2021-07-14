function  B = ifactive(A)

if ishandle(A)
   in  = sum(get(A,'ForegroundColor')==[0.5 0.5 0.5])==3 ;
   sel = sum(get(A,'ForegroundColor')==[1 0 0])==3 ;
   ac = sum(get(A,'ForegroundColor')==[0 0 0])==3 ;
end
if in
    B = 0;
elseif sel
    B =2;
else
    B =1;
end
end