function disp_lan(texto)
%
if nargin ==0
    texto = plus_text;
end
%
clc
for i=1:size(texto,1)
disp(texto{i,1});
end