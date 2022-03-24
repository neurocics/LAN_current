function ndataF = svd_reduce_component_AMP(dataF)
%  LAN toolbox v.0.2
%  Reduce componente of source bases in AMPLITUDE of frequency !!!
%  rotate de bipolar commponente to the maximum variaotion of amplitud ( freq - time - trial !!!) 
%  Pablo Billeke
%  18.04.2016



inx = ~isemptycell(dataF);
ndataF = cell(size(dataF));

paso= cat(4,dataF{:});

%paso=mean(paso,1);
% freq x source x time x trial 
[x y z o] = size(paso);

clear dataF;
%for xi=1:x        %%% MEJORAR ESTA ABSURA !!!!!!
    for yi=1:3:y
        bar_wait(yi/3,y/3);
        %for zi=1:z
        
             paso2 =  double(paso(:,yi:(yi+2),:,:));
             
             l1 = paso2(:,1,:,:);
             l2 = paso2(:,2,:,:);
             l3 = paso2(:,3,:,:);
             
             paso_fin = nan(size(l1));
             
            % paso2 = double(paso(xi,yi:(yi+2),zi,:));
            
            paso2 =[ l1(:)' ;  l2(:)'  ; l3(:)' ];
            
            if ~any(isnan(paso2(:)))
            [u] = svds((paso2)); 
            ut = u';      % this rotates the data in the direction of the maximum power
            paso2  = ut * paso2;
            paso_fin(:) = paso2(:);
            nt=0;
                %for t=1:length(inx)
                 %   if inx(t)
                        nt=nt+1;
                        dataF(1:x,(floor(yi/3)+1),1:z,inx) = single(paso_fin(:,:,:,:)) ; % single presicion data !!!
                  %  end
                %end
            end
        %end
    end
    
 
             for t=1:length(inx)
                    if inx(t)
                        nt=nt+1;
                        ndataF{t} = dataF(:,:,:,nt);
                    end
             end
    
    
    
%end






end