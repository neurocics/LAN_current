function path = fix_path(path)
% LAN
% v.2.0
% 09-06-2016

if ispc
    path = strrep(path,'/','\');
else
   path = strrep(path,'\','/'); 
end

path(isspace(path)) = [];

end