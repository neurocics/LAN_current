function texto = last_text(texto1, agre,lugar)
% last_text.m
%
% ver plus_text.m
%
% v.0.0.1
% 26.4.2010
%
if nargin == 0
texto = plus_text();
end
%
%
if nargin == 1
texto = plus_text(texto1);
end
%
%
% agrega texto de mensaje
% para funciones internas de LAN

if nargin == 2
x = size(texto1,1);
texto = texto1;
texto{x,1} = agre;
end

if nargin == 3
    if lugar == 'a'
     x = size(texto1,1);
     texto = texto1;
     texto{x,1} = [ texto1{x,1} agre ];
    else
    x = size(texto1,1);
    texto = texto1;
    texto{x-(lugar-1),1} = agre;
    end
    
end



end