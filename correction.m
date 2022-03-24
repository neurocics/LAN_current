function cls = correction(carta)
% busca cluster en cartas de valor p 0 y 1
% 9.Agosto.2009
% P.Billeke
%
if size(carta,3)==1
    cls = bwlabel(carta,4)
    return
end

disp(['making clusters ...'])
yc = size(carta,1);

cn = 0;
for y = 1:yc
    if ~any(carta(y,:)),continue,end
for x = find(carta(y,:))
   if carta(y,x) == 0, continue, end
   cn = cn +1;
   a = zeros(size(carta)) ;
   a(y,x) = 1 ;
       
      
   [ a carta ] = busquedaloca(a,y,x,carta);
   
    cls{cn} = a;
end
end
end
%--------------------------
%---subrutinas

function [a carta] = busquedaloca(a,y,x,carta)


for xi = [1,-1]
    try
        if carta(y,x+xi) == 1
        a(y,x+xi) = 1; carta(y,x+xi) = 0;
        [a carta] = busquedaloca(a,y,x+xi,carta);
        end
    end    
end
for yi = [1,-1]
    try
        if carta(y+yi,x) == 1
        a(y+yi,x) = 1; carta(y+yi,x) = 0;
        [a carta] = busquedaloca(a,y+yi,x,carta);
        end
    end    
end


end


