function save_struct(file, str)

LAN='LAN';
save(file,'LAN')

for R=fieldnames(str)'   
   eval([ R{1} ' = str.' R{1} ';']) ;
   save(file, R{1}, '-append');
end