function cls = correction_3D(carta,elec_adj)
% busca cluster en cartas de valor p 0 y 1
% carta = [frec x tiempo x electrodo
%
%
% 3.Septiebre.2009
% P.Billeke
%
warning('Limite rango de frecuencias a analizar  para no caer en insufuciencia de memoria');

[yc,xc,zc] = size(carta);
if xc == 32%min([yc,xc,zc])
    for x = 1:xc
        r(:,:,x) = carta(:,x,:);
    end
carta = r;
clear r;
end

    

cls = [];



if nargin < 2
    ele = size(carta,3);
    uno = ['load '  'elec_adj' num2str(ele)];
    warning('No se indico matriz de adjasencia, se buscara por defecto'); 
    try
     eval(uno)
     elec_adj = elec.adj;
     disp('Se trabajara con matriz de adjasencia de:');
     disp(elec.coment);
    catch
        error('No se encuentra matriz de adjasencia');
    end
end

if isstruct(elec_adj)
    try
        disp(elec_adj.coment);
        elecadj = elec_adj.adj;
        clear elec_adj;
        elec_adj = elecadj;
        clear elecadj;
    end
end

total = sum(sum(sum(carta)));
llevo = 0;

disp(['making clusters ...']);

yc = size(carta,1);
xc = size(carta,2);
zc = size(carta,3);

cn = 0;
cg = 0;
gg = 0;

for z = 1:zc
    for y = 1:yc
        %find(squeeze(carta(y,:,z)))%if ~any(carta(y,:,z)),continue,end % salta filas sin significancia del loop
        for x = find(squeeze(carta(y,:,z)))
           if carta(y,x,z) == 0, continue, end

           a = zeros(size(carta)) ;
           a(y,x,z) = 1 ;
           [ a carta ] = busquedaloca_c(a,y,x,z,carta,elec_adj); % busca 1 anyasentes
           %carta(find(carta==2)) = 0; 
           llevo = sum(sum(sum(a))) + llevo;

	    %if sum(sum(sum(a))) < 7, continue, end
	    cn = cn +1;
	    cg = cg +1;

	    
	    %cls{cn} = a;
	    %cls = a;
            %clear a;

	    
	    clc;
	    disp(['numero de cluster = ' num2str(cn) ]);
	    disp(['llevo = ' num2str( [llevo/total]) ' analizado' ] );
	      if gg > 0
	      disp(['cluster guardados en ' num2str(gg) ' archivos en directorio de trabajo ' ]);
	      end

	    if cg == 1
	      cg = 0;
	      gg = gg +1;
              file = [ 'cls' num2str(gg) ];
	      disp( [ 'guardando cluster en archivo ' file ] );
	      save( file, 'a');
	      clear a;
	      pack
	    end
        end
    end
end

%-- recuperar archivos guardados
for f =1:gg
uno = ['load cls' num2str(f) ';'];
eval(uno);
cls{f} = a;
clear a 
end


end
%
%--------------------------
%---subrutinas


function [a carta] = busquedaloca_c(a,y,x,z,carta,elec_adj)

[a carta] = busquedaloca(a,y,x,z,carta,elec_adj);
yc = size(carta,1);
xc = size(carta,2);
zc = size(carta,3);

for yn = 1:yc  
    for xn = find(squeeze(a(yn,:,z)))
            if carta(yn,xn,z) == 0, continue, end
            [a carta] = busquedaloca_3d(a,y,x,z,carta,elec_adj);
    end
end
end




function [a carta] = busquedaloca(a,y,x,z,carta,elec_adj)
% busqueda unos adjasentes
%
%
%

 
for yi = [1,-1] %busqueda en eje y
    try
        if carta(y+yi,x,z)> 0% == 1
        a(y+yi,x,z) = 1; 
        carta(y+yi,x,z) = 0;
        [a carta] = busquedaloca(a,y+yi,x,z,carta,elec_adj);
        end
    end    
end

for xi = [1,-1]  % busqueda en eje X
    try
        if carta(y,x+xi,z) > 0%== 1
        a(y,x+xi,z) = 1;
        carta(y,x+xi,z) = 0;
        [a carta] = busquedaloca(a,y,x+xi,z,carta,elec_adj);
        end
    end    
end
end

function [a carta] = busquedaloca_3d(a,y,x,z,carta,elec_adj)


for zi = elec_adj{z} %busqueda en eje z por adjasencia
     try
       if carta(y,x,zi) > 0%
        a(y,x,zi) = 1; 
        carta(y,x,zi) = 0;
        [a carta] = busquedaloca_c(a,y,x,zi,carta,elec_adj);
       end
    end    
end
 

end





