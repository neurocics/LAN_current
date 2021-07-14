function r = op_cell(a,b,op)
% LAN
% 10.1.2011



if iscell(a) && iscell(b)
if size(a)==size(b)
    [y , x] = size(a) ;
    for yi = 1:y
       for xi = 1:x
          if strcmp(op,'.*')
          r{yi,xi}= a{yi,xi} .* b{yi,xi};
          elseif strcmp(op,'+')
          r{yi,xi}= a{yi,xi} + b{yi,xi};    
          end
       end
        
    end
else
    error('a and b must have same size')
end   
elseif  iscell(a) && isnumeric(b)  
 if size(a)==size(b)
    [y , x] = size(a) ;
    for yi = 1:y
       for xi = 1:x
          if strcmp(op,'.*')
          r{yi,xi}= a{yi,xi} .* b(yi,xi);
          elseif strcmp(op,'+')
          r{yi,xi}= a{yi,xi} + b(yi,xi);    
          end
       end       
    end     
else
    error('a and b must have same size')
end
else
    erro('a  must be cell-array and b must be cell-array or mat')
end
end