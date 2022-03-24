function par = busca_cfg(LAN,donde)
% v.0.1
%
% 26.11.2009
if isstruct(LAN)
    for  i = 1:length(donde)
    uno = ['par{' num2str(i) '} = LAN.' donde{i} ';' ]    ;
    eval(uno);  
    end
    
elseif iscell(LAN)
     for  i = 1:length(donde)
    uno = [ 'par{' num2str(i) '}  = LAN{1}.' donde{i} ';' ]    ;
    eval(uno);  
     end
end