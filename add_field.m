function LAN = add_field(LAN, field)
% v.1.0.5
%
%
% Pablo Billeke
%
% 24.01.2011   add ';'
% 26.08.2010   puede agregar variables de otros workspase.
%              oreden:
%              de la funcion > base > del la funcion que la llamo.
% 12.06.2009
%
% field = ['phase.cfg.stata = ''boot''']




if iscell(LAN)
    cuantos = length(LAN);
    for lan = 1: cuantos
        LAN{lan} = add_field_st(LAN{lan}, field);
    end
else
    
        LAN = add_field_st(LAN, field);
end
end

function cfg = add_field_st(cfg, field)
m = ['cfg.' field ];
try
eval(m);   
catch
%%% for variable in base workspace
r = find(m == '=');
rl =length(m );
  try
  s = evalin('base',m(r+1:rl));    
  catch
  s = evalin('caller',m(r+1:rl));   
  end
m = [ m(1:r-1) ' = s ;' ];
eval(m);  
  
end

end


