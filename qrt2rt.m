function RT = qrt2rt(qRT)
RT.laten = qRT.laten{1};
RT.est = ones(1, length(qRT.laten{1})) * qRT.chan(1);
for c = 2:length(qRT.laten)
    RT.laten = [RT.laten qRT.laten{c}];
    RT.est = [RT.est ones( 1,length(qRT.laten{c}) )*qRT.chan(c)];
end
RT = rt_check(RT);