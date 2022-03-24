function COR = cor_merge(COR1,COR2,varargin)
%   <*LAN)<] 
%
%   v.0.0.02
%   Pablo Billeke
%
% 06.06.2011
% 12.05.2011


%%% comprobaciones

if nargin > 2
    
   COR2 = cor_merge(COR2,varargin{:}) ;
   %COR = cor_merge(varargin{1:end-2}) ;
   %return
end

%COR1=varargin{1}
%COR2=varargin{2}

c1f = sort(fields(COR1));
c2f = sort(fields(COR2));

if size(c1f,1)~=size(c2f,1)
     error('structur COR must have the same fields')
else
    for i = 1:size(c1f,1)
        if ~strcmp(c1f{i},c2f{i})
        error('structur COR must have the same fields')
        end
    end
end

%%% union
for f = 1:size(c1f,1)
     if strcmp(c1f{f},'RT')
     COR.RT = rt_merge(COR1.RT,COR2.RT,0);
     %%% other simple vector fields
     elseif strcmp(c1f{f},'FREQ')
          if size(COR1.FREQ,2) == size(COR2.FREQ,2)
             compf = 0;
              for nf1 = 1:size(COR1.FREQ,2)
                  for nf2 = 1:size(COR2.FREQ,2)
                      if strcmp(COR1.FREQ(nf1).name,COR2.FREQ(nf2).name)
                         COR.FREQ(nf1).name =  COR1.FREQ(nf1).name;
                         try
                         COR.FREQ(nf1).cfg =  COR1.FREQ(nf1).cfg;
                         catch
                             disp(['WARNING: FREQ ' COR.FREQ(nf1).name  ' without .cfg'])
                         end
                         COR.FREQ(nf1).powspctrm =  cat(2,COR1.FREQ(nf1).powspctrm,COR2.FREQ(nf2).powspctrm);
                         %%% agregar otros posibilidaes coeficientes de
                         %%% fourier, fase, etc!!!!
                      compf = compf + 1;   
                      end
                  end
              end
              if compf ~= size(COR1.FREQ,2)
                  error('something do no work ???')
              end
          else
              error('COR.FREQ structur must have the same size')
          end

     
     %%% other simple vector fields
     elseif strcmp(c1f{f},'OTHER')
             %%% mas comprobaciones
              c1fo = sort(fields(COR1.OTHER));
              c2fo = sort(fields(COR2.OTHER));
                if size(c1fo,1)~=size(c2fo,1)
                     error('structur COR.OTHER must have the same fields')
                else
                    for i = 1:size(c1fo,1)
                        if ~strcmp(c1fo{i},c2fo{i})
                        error('structur COR.OTHER must have the same fields')
                        end
                    end
                end
                %%% UNION
                for fo = 1:size(c1fo,1)
                eval(['COR.OTHER.' c1fo{fo}  ' = cat(2, COR1.OTHER.' c1fo{fo}  ' , COR2.OTHER.' c2fo{fo}  ');  '   ])   ; 
                end
     
                
                
     end


end
%%% fin
end