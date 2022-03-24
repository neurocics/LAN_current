function COR = cor_add_other(COR,campo,dato)
%   <*LAN)<]    
%   v.0.0.0
%  Adding a field in COR.OTHER

% Pablo Billeke

if ischar(dato)
    
    for n = 1:length(COR.RT.rt)
        eval(['COR.OTHER.' campo '{' num2str(n)   '} =  dato ;'  ])
    end
    
end








end