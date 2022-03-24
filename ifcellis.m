function [T ind]= ifcellis(a,con,type)
%   <*LAN)<]
%   v.0.2
%
%   IFCELLIS computedlogical operation (a==con) in a cell-array
%   [T ind] = IFCELLIS(A,CON) CON puede ser numero o string
%                             if CON contain '@' eval de exprecion of the
%                             where '@' es de value of each cell of A
%   [T ind] = IFCELLIS(A,CON,'c') TYPE='c' busca si en str CON esta
%                                 contenido en A
%
% Pablo Billeke
% 25.07.2018
% 14.12.2011
% 03.04.2017 (PB)
% 14.12.2011 (PB) add eval '@' string option
% 22.07.2011 (PB)
% 01.03.2011   (PB)
% 01.01.2011   (PB)

if nargin == 2
t_c=0;type=0;
elseif strcmp(type,'c')
t_c=1;
else
t_c=0;
end

if iscell(con)
    T=false(size(a));
    for nc = 1:numel(con)
       T = T + ifcellis(a,con{nc},type)    ;    
    end
    T = logical(T);
    ind = find(T);
    return
end


T = false(size(a));
if isnumeric(con)
for d1 = 1:size(a,1);
for d2 = 1:size(a,2);
for d3 = 1:size(a,3);
    if   ~isempty(a{d1,d2,d3})  
    T(d1,d2,d3) = a{d1,d2,d3} == con;
    else
    T(d1,d2,d3) = false;   
    end

end
end
end
elseif ischar(con)
if any(strfind(con,'@'))
con = strrep(con,'@','a{d1,d2,d3}');
iff = true;
else
iff = false;
end
for d1 = 1:size(a,1);
for d2 = 1:size(a,2);
for d3 = 1:size(a,3);
if t_c
T(d1,d2,d3) = any(strfind(a{d1,d2,d3},con));
elseif iff
T(d1,d2,d3) = eval(con);
else
T(d1,d2,d3) = strcmp(a{d1,d2,d3},con);
end

end
end
end
end



T = logical(T);
ind = find(T);