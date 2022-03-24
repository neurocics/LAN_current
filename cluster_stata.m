function cls = cluster_stata(carta,elec_adj,n)
%
%  cluster de significancia  en 3 dimenciones siendo 
%
%
%  en construccion
% v.0.0.1
% P.Billeke


dm = size(carta,3);
el = size(carta,1);

if dm == 1
    els = size(carta,1);
    for ad = 1:length(elec_adj)
      rcarta = carta(elec_adj{ad},:);
      paso = bwlabel(rcarta,n);
          for e =1:els
               orden(e,:) = paso(find(elec_adj{ad}==e),:);
          end
          clsp{ad} = orden;
    end
    %
    %
    % unir claster
    %     for ii = 1:length(elec_adj)
    %         for iii = 1:length(elec_adj{ii})
    %              
    %         
    %         end
    %     end
    cont = 0;
    final = zeros(size(carta));
    for d1 = 1:max(max(max(clsp{1})))
         uno = zeros(size(carta));
         uno(find(clsp{1}==d1)) =1;
        for d2 = 1:max(max(max(clsp{2})))
         dos = zeros(size(carta));
         dos(find(clsp{2}==d2)) =1;
         tres = uno + dos;
             if max(max(max(tres))) == 2
                 cont = cont +1;
                 uno(find(clsp{2}==d2))= 1;
                 clsp{2}(find(clsp{2}==d2)) =0;
                 agregado(cont) = d2;
             end
        end
        final(find(uno==1)) = d1;
    end
    
    recont = max(max(max(clsp{1})));
    for iii =1:max(max(max(clsp{2})))
        if abs(sum(iii==agregado)-1)
            recont=recont+1;
            final(find(clsp{2}==iii)) = recont;
        end
    end
    
    
end
cls = final;
end
% 
% 
% 
% 
% 
% 
% %%%%%%%%%%%%%%%%%%
% 
% 
% if size(carta,3)==1
%     cls = bwlabel(carta,4)
%     return
% end
% 
% disp(['making clusters ...'])
% yc = size(carta,1);
% 
% cn = 0;
% for y = 1:yc
%     if ~any(carta(y,:)),continue,end
% for x = find(carta(y,:))
%    if carta(y,x) == 0, continue, end
%    cn = cn +1;
%    a = zeros(size(carta)) ;
%    a(y,x) = 1 ;
%        
%       
%    [ a carta ] = busquedaloca(a,y,x,carta);
%    
%     cls{cn} = a;
% end
% end
% end
% %--------------------------
% %---subrutinas
% 
% function [a carta] = busquedaloca(a,y,x,carta)
% 
% 
% for xi = [1,-1]
%     try
%         if carta(y,x+xi) == 1
%         a(y,x+xi) = 1; carta(y,x+xi) = 0;
%         [a carta] = busquedaloca(a,y,x+xi,carta);
%         end
%     end    
% end
% for yi = [1,-1]
%     try
%         if carta(y+yi,x) == 1
%         a(y+yi,x) = 1; carta(y+yi,x) = 0;
%         [a carta] = busquedaloca(a,y+yi,x,carta);
%         end
%     end    
% end
% 
% 
% end
% 
% 
