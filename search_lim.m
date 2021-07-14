function [limit, LAN] = search_lim(LAN, therhold, finn)
% search time limit for lost % of the dates, and graphic
% Pablo Billeke 15.4.2009
% limit = time limit (in seconds), 
%
% therhold = therhold in porcentege eg. 80 o [90 80]
% 
% fin = axe "x" of grafic 
%
%  

if nargin < 3
    finn = [];
end

% crea latencias
% subject
if iscell(LAN)
    for lan = 1:length(LAN)
        laten = [];
        for tr = 1:length(LAN{lan}.data)
            % latency for subject for tr
            laten(1,tr) = length(LAN{lan}.data{tr}); 
            % maximum (limit for the graphic)
            
        end
        subject{1,lan} = laten; 
        max_aux(1,lan) = max(laten);clear laten;
        aaa{lan} =[ LAN{lan}.name   LAN{lan}.cond  ];
     end
    eegrate = LAN{1}.srate;
    
    fin = fix(max(max_aux)/eegrate)+1;
    
    
else
    laten = [];
        for tr = 1:length(LAN.data)
            laten(1,tr) = length(LAN.data{tr});
        end
        
        subject{1,1} = laten; clear laten;
        eegrate = LAN.srate;
        aaa{1} =[ LAN.name   LAN.cond  ];
        fin = max(laten)/eegrate +1;
end

%%%%%

if ~isempty(finn)
    fin = finn;
end





% colorl = [1 0 0 ];
[fil col] = size(subject);
nlimit = length(therhold);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% arreglar
if fil == 1 &&  ~iscell(subject)
    positiont = (0.6 * length(subject) );
for w = 1:nlimit


    % pos = 0;
    limit_t = 0;
    for i = 0:0.001:fin
        a = eva_lat(subject, i, eegrate);
            if a <= floor(therhold(w)/100 * length(subject))%%%%%%%%%%5
            %pos = pos + 1;
            %limit_t(pos) = i;
            limit_t = i;
                break
            end
    end
    limit{w} = limit_t(1) ;
    x = 0:0.01:fin ;
    y = zeros(1,length(x));
    pos = 0;
     for i = 0:0.01:fin
         a = eva_lat(subject, i, eegrate);
         pos = pos + 1;
         y(pos) = a;
              end
     
     for i = length(y):-1:2;
         if y(i) == y(i-1)
             y(i) = [];
             x(i) = [];
         end
     end
       
        
   if w ==1
       figure; name = ['Sujeto: ' char(aaa) ];
    plot(x,y), title( name ); 
   % plot(y), title( name );
   end
   cc = line([limit{w} limit{w}],[ 0 length(subject)], 'LineWidth', [0.7], 'Color', 'm');
   positiont = positiont + (length(subject)* 0.07);
   tt = text(7, positiont , ['percentil: '  num2str(therhold(w)) '->' num2str(limit{w})], 'FontSize', 15, 'FontWeight', 'bold', 'HorizontalAlignment','center'... 
 ...%,'BackgroundColor',[.9 .9 .9]
 );


end
histograma(subject, [1:fin],1);



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% areglado
elseif iscell(subject) & col > 1
    
      
    for ix = 1:col
        positiont = (0.6 * length(subject{ix}) );
        colorl = [1 0 0 ];   
     
      for w = 1:nlimit  
        %pos = 0;
        limit_t = 0;
        
        order = sort(subject{ix});
        post =  floor(therhold(w)/100 * length(subject{ix}));
        times = order(post);
        limit_t = times/eegrate;
        
        
%         for i = 0:0.001:fin
%             a = eva_lat(subject{ix}, i, eegrate);
%                 if a <= floor(therhold(w)/100 * length(subject{ix}))%%%%%%%%%%%%%%%%%
%                 %pos = pos + 1;
%                 limit_t = i;
%                 break
%                 end
%         end


        
    limit{w}=limit_t;
    finit = 1000;
    x = 0:(1/finit):fin;
    yy = zeros(1,length(x));
    %pos = 0;
    
         if w == 1
             
             order = sort(subject{ix});
             for i = 1:length(subject{ix})
                 ll = fix((order(i)/eegrate)*finit);
                 yy(ll) = length(subject{ix})-i;
                 if ll/finit >= fin
                     break
                 end
             end
                 yy(1) = length(subject{ix});
                 clear order;   

                  y = yy(1,1:length(x)); 
                  conserva = find(y);
                  for i = 1:length(conserva)

                         y_c(i) = y(conserva(i));
                         x_c(i) = x(conserva(i));
                  end
                  clear y x;
                  y = y_c; x = x_c;
                  clear y_c x_c;

         
         
         end

         
         
         
     
     
       if ix <= 4
       if ix == 1 & w == 1
            h = figure; set(h, 'Name', ['graficos']);
       end
        name = ['Sujeto: ' char(aaa{ix}) ];
        if w == 1
            subplot(2,2,ix),  plot(x,y), title(name);
            ultimo = max(x);
        end
        
        
        
        cc = line([limit{w} limit{w}],...
           [ 0 length(subject{ix})], 'LineWidth', [0.7], 'Color', colorl, 'LineStyle',':'  ); %;'m');
        positiont = positiont + (length(subject{ix})*0.07) ;
        tt = text((3 * ultimo)/4, positiont , ['percentil: '  num2str(therhold(w)) '->' num2str(limit{w})], 'FontSize', 10, 'FontWeight', 'bold', 'HorizontalAlignment','center'... 
        ...;%,'BackgroundColor',[.9 .9 .9]
        )   ;
        colorl = colorl + [-0.08 0.01 0.08];
       
    end
    
    end
    end
end
    
