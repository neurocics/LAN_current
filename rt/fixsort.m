function [C error]= fixsort(uno,dos)


 if max(size(uno)) > max(size(dos))
     U = dos;
     D = uno;
 elseif max(size(uno)) == max(size(dos))
     C = uno;
     error =[];
     return
 else
     D=dos;
     U=uno;
 end


 cc=0;
 for i = 1:length(D)
    if U(i-cc)==D(i)
       C(i) = U(i-cc);
    else
        C(i) = -99;
        cc = cc + 1;
        error(cc) = i;  
    end
 end


 end