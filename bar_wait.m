function bar = bar_wait(i,n,ops,texto)
%    v.0.0.5
%    bar = bar_wait(i,n,ops,texto)
%    ops : '  xxx '  string with the comand
%        M(100)    : modo de 100
%        m(f)      : tipo flecha
%        m(c)      : tipo centro (default)
%       pre(tt)   : texto previo a la barra 
%       pos(xx)   : texto posterior a la barra
%       B(.)      : texto de barra vacia
%       R(o)      : texto de barra llena
%  e.gRe: Reuni?n comit? acad?mico DCCS - Mi?rcoles 16/12
%         bar_wait(i,n)
% Pablo Billeke

% 28.06.2012
% 7.02.2012 optimize memory
% 8.12.2011
% 6.12.2011

if (fix(100*i/n) == fix(100*(i-1)/n)) && (i>1)% && (nargin<4) %||nargout==0) 
    if nargout>0
        bar = [];
    end
    return
end

if nargin < 3
   mode=100;
   modo='c';
   B = '.';
   R = '                                                  >=(*>';
   preA = 'LAN';
   posA = lanversion;
else
	% opstions:
	
    % mode
    nb = strfind(ops,'M(');
    if ~isempty(nb)
	  fn = find(ops(nb:end)==')')-2+nb;
      mode = eval(ops(nb+2:fn(1)));
      else
      mode = 100;
    end

    % modo
    if ~isempty(strfind(ops,'m:f')) || ~isempty(strfind(ops,'m(f)'))
      modo = 'f';
    else
      modo='c';
    end

    % pre_ambulo
    nb = strfind(ops,'pre(');
    if ~isempty(nb)
	  fn = find(ops(nb:end)==')')-2+nb;
      preA = ops(nb+4:fn(1));
      else
       preA = ' ';
    end

    % post_barra
    nb = strfind(ops,'pos(');
    if isempty(nb), nb = strfind(ops,'post(') +1;end
    if ~isempty(nb)
	  fn = find(ops(nb:end)==')')-2+nb;
      posA = ops(nb+4:fn(1));
      else
      posA = ' ';
    end

	% empty bar
    nb = strfind(ops,'B:');
    if isempty(nb), nb = strfind(ops,'B(');end
    if ~isempty(nb)
      B = ops(nb+2);
    else
      B = '.';
    end

	% fill bar
    nb = strfind(ops,'R:');
    if isempty(nb), nb = strfind(ops,'R('); end
    if ~isempty(nb)
	  fn = find(ops(nb:end)==')')-2+nb;
	  if isempty(fn), fn=nb+2;end
      R = ops(nb+2:fn(1));
    else
       R = '                                                  >=(*>';
    end

end



 

   
   
%   ifd = true;



%lg = fix(2*mode*i/n);   
if  fix(mode*i/n) > fix(mode*(i-1)/n) ||(i==1) || (nargin==4||nargout>0)                   %(mod(lg,2)==0)||(n<mode)||(i==1)   
      bar=[ preA '   ' repmat(B,[1,49]) '  ' posA];
      
      lA = length(preA);   
    if i>1
   lg = fix(50*i/n);
   R =  repmat(R,1,50);
   ll = lA+4:lg+(lA+2);
   bar(ll) = R((end-length(ll)+1):end);%repmat('o',lg);
   end
    
    
    ifd = true;
    p = fix(100*i/n);
   str = [ num2str(p) '%' ];
   switch  modo
     case 'f'
     p2 = fix(50*(i+1)/n)+lA;   
     case 'c'
     p2 = 26+lA; 
   end   
   bar(p2:(p2+length(str)-1)) = str; 
else
   ifd = false;
end


% display options
if ifd || nargin==4
  if (nargin==4) && iscell(texto)
  bar = last_text(texto,bar,1);
    if nargout == 0   
      disp_lan(bar);
      clear bar
    end
  else
    if nargout == 0 
	clc
	disp(bar);
    clear bar
    end
  end
  %return
else
    clear bar
end


end %function




% oOo.oOo.oOo~~~~~~~~~~~~~~~