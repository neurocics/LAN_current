function  [r p a b] = isr()
% <*LAN)<] 
%
% checkea que littler y GNU R
% esten correctamente instalados en el sistema
% y da el path para ejecutarlo
%
% v.0.0.1
% Pablo Billeke

% 30.07.2011



    p = mfilename('fullpath');
    a = length(p);
    p = p(1:(a-3));
    p = [ p 'littler/'] ;
        [a b ] = system(['"' p 'r" -V']);
       
            if ~isempty(findstr(b,'littler'))
	      r = 1;
	    else
	      r = 0;
	      p = [];
            end

  r = logical(r);  
  disp(b);
end



