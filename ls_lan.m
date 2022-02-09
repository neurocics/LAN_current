function stre = ls_lan(e,e2)
% v0.2 
% P Billeke

if nargin == 0 || isempty(e)
stre = ls;
else
stre = ls(e);
if nargin<2
    e2=[];
end
end

stre(isspace(stre)) = ' ';



            nss=1;
            while ~isempty(stre)
                if isempty(find(stre(find(stre~=' ',1):end)==' ',1))
                   fin=length(stre);
                else
                   fin=find(stre(find(stre~=' ',1):end)==' ',1)-2+find(stre~=' ',1);
            end

                paso{nss}= stre(  find(stre~=' ',1):fin);
                stre(1:fin)=[];
                nss=nss+1;
            end
            
          
            stre = paso;
            if ~isempty(e2)
                
               stre = stre(~isnan(fun_in_cell(stre,['findstr(@,''' e2 ''')']))) ;
            end
            
            
            
           NO =  ifcellis(stre,'');
           stre(NO) = [] ;
           NO =  ifcellis(stre,'isempty(@)');
           stre(NO) = [] ;
            
         
            
        %    roi=[];
        %  for ne = length(paso):-1:1  
        %  roi =  cat(2, find(ifcellis({GLAN.chanlocs.labels},paso{ne})), roi);
        %  end
          
