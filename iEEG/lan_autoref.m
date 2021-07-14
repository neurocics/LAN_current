function LAN = lan_autoref(LAN,tol)
% <*LAN)<] lantoolbox
% v.0.0.1
%
% Auto local references for iEEG
% tol = 0 ; how many distances of  electrode tolerate for the local references
%          0 =  Only the immediately adjacent electrode
%          n =  n electrode of distance  
%
%  Pablo Billeke
%  16.11.2013 

if nargin==1
   tol=0;
end

electrodemat = LAN.chanlocs(1).electrodemat;
[d1, d2] = size(electrodemat);
references = zeros(d1,d2);

for p = 1:d1
    n=1;
    for s = 1:d2
    if electrodemat(p,s)>0
       if n==1
          references(p,s)=electrodemat(p,s);
          n=2;
       elseif electrodemat(p,s-1)>0
          references(p,s)=electrodemat(p,s-1);
          n=n+1;
       else
           for r = 1:n+1;
              if (r>(tol+1))||(r==n+1) 
                 references(p,s)=electrodemat(p,s); 
                 n=n+1;
                 break
              elseif electrodemat(p,s-r)>0 
                 references(p,s)=electrodemat(p,s-r);
                 n=n+1;
                 break
              end
           end
       end
    end
    end
end

LAN.references = references;
disp(['Done: Local auto reference with tolerance adjacency : ' num2str(tol)])
end

