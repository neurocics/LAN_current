function texto = plus_text(texto1, agre)
% v.0.3
% 
%
%
if nargin == 0
texto{1,1} = ['                           _                     '];
texto{2,1} = [' TOOLBOX:               ' lanversion('l') '      ']; 
texto{3,1} = ['                                                 '];
texto{4,1} = ['      laboratorio de analisis en neurociencia    '];
texto{5,1} = ['                       version (' lanversion('t')  ')            v.' lanversion ];
texto{6,1} = ['                       ultima actualizacion:      '  lanversion('d') ];
texto{7,1} = ['                                                  '];
return
end
%
%
if nargin == 1
texto = plus_text();
texto{8,1} = texto1;
return
end
%
%
% agrega texto de mensaje
% para funciones internas de LAN
if (nargin == 2) && (iscell(texto1))
x = size(texto1,1) + 1;
texto = texto1;
texto{x,1} = agre;
else
    texto{1,1} = texto1;
    texto{2,1} = agre;
end


end