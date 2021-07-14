% freq_inter_band.m
% v 0.0.2b fix
% Estudios interbandas
% Experimental
% 
%-----------------------------------------------------------------------------------
%-----------------------------------------------------------------------------------
% 
% LAN = freq_inter_band(LAN)
%      parametros definidos en estructura LAN.freq.cfg, o si no se sempliega GUI para
%      configurar.
% LAN = freq_inter_band(LAN,par)
% 
%-----------------------------------------------------------------------------------
%-----------------------------------------------------------------------------------
% 
% LAN.freq.cfg.
% .inter_fr1 : f1:f2
% par{1}     : f1:f2       
%            - primera banda de frecuencias
% .inter_fr2 : f3:f4
% par{2}     : f3:f4  
%            - senguda banda de frecuecia
% .inter_fr1_w: 'phase' o 'amplitud' o 'both'
% par{3}      : 'phase' o 'amplitud' o 'both' 
%             - que se va a compara de la primera banda
% .inter_fr1_w: 'amplitud'
% par{4}:       'amplitud'                           
%              - que se va a compara de la segunda banda 
% .inter_time   : [t1 t2]  
% par{5}        : [t1 t2]  
%              - tiempo para el calculo inter frecuencia
%
%
%
% 11.12.2009
% Pablo Billeke

function LAN = freq_inter_band(LAN,par)

%-------Configuraciones parametros-----------------------------------------------------------------------
   que = [{'fr1'},{'fr2'},{'what_f1'},{'what_f2'},{'time'}] ;
   donde = [{'freq.cfg.inter_fr1'} , {'freq.cfg.inter_fr2'}, ...
                    {'freq.cfg.inter_fr1_w'},{'freq.cfg.inter_fr2_w'},...
                    {'freq.cfg.inter_time'}];
   opciones =  [ {'#1'},{'[8:16]'},{'[:]'};...
                 {'#2'},{'[17:50] '},{'[8:60]'};...
                 {'phase1'} , {'amplitud1'},{'both1'};...
                 {'phase2'},  {'amplitud2'},{'both2'};...
                 {'#3'},{'[-2.5 0]'},{'[ ]'}] ;
%--------------------------------------------------------------------------------------------------------

if nargin < 2
     try 
         par = busca_cfg(LAN,donde);
     catch
          LAN = pregunta_lan(LAN,donde,opciones, 'Análisis Inter-Bandas');
          par = busca_cfg(LAN,donde);
     end
end
    

%
texto = plus_text(        '                                                           ');% iniciar mensaje
texto = plus_text(texto,  ' OJO: function '' freq_inter_band.m '' en etapa preliminar ');
texto = plus_text(texto, ' v.0.0.2b fix                                              ');
texto = plus_text(texto,' ');
%
 if isstruct(LAN)
	texto = last_text(texto,' Procesando...');
        LAN = freq_inter_band_struct(LAN, par,texto);
	%
 elseif iscell(LAN)
            for lan = 1:length(LAN)
		%
                texto = last_text(texto, [' Procesando condicion ' num2str(lan) ' de ' num2str(length(LAN)) ]  );
                texto = plus_text(texto,' ');
                LAN{lan} = freq_inter_band_struct(LAN{lan}, par,texto);
            end
end
end



function LAN = freq_inter_band_struct(LAN, par,texto) 

%------
%------
%------PARAMETROS------------------------------------
%------
%------

%------
%------ frecuencias para analizar
 try
    range = LAN.freq.cfg.rang;
    fr1 = par{1} - range(1) +1; % pasar de frecuacias a numero de fila
    fr2 = par{2} - range(1) +1;
 catch
     texto = plus_text(texto, 'OJO: Sin rango de frecucias: solo para datos crudos');
 end
%-------
%------- time
    r = 0;
    % time si explite "freq.time.ind"
    %-------------------------------
    if isfield(LAN,'freq')
    if isfield(LAN.freq, 'time') 
    if isfield(LAN.freq.time, 'ind')
    for i = 1:LAN.trials
    time{i}(1) = par{5}(1)*1000;%
    LAN.freq.cfg.inter_time(1)=par{5}(1);%
    x = find(LAN.freq.time.ind{i}<=time{i}(1),1);
        if isempty(x)
            time{i}(1) =1;
        else
            time{i}(1) =x;
        end
    time{i}(2) = par{5}(2)*1000;%
    LAN.freq.cfg.inter_time(2) = par{5}(2);%*1000;
    x = find(LAN.freq.time.ind{i}>=time{i}(2),1);
        if isempty(x)
            time{i}(2) =length(LAN.freq.time.ind{i});
        else
            time{i}(2) =x;
        end
    end 	% for i
    r = 1;	% para alternativa
    end,end,end	% arreglar condiciones  

    % time si no existe "freq.time.ind" 
    if r == 0
      for i = 1:LAN.trials
    time{i}(1) = par{5}(1)*1000;%
    LAN.freq.cfg.inter_time(1)=par{5}(1);%
    ti = linspace(LAN.time(i,1),LAN.time(i,2), length(LAN.data{i}));
    x = find(ti<=time{i}(1),1);
        if isempty(x)
            time{i}(1) =1;
        else
            time{i}(1) =x;
        end
    time{i}(2) = par{5}(2)*1000;%
    LAN.freq.cfg.inter_time(2) = par{5}(2);%*1000;
    x = find(ti>=time{i}(2),1);
        if isempty(x)
            time{i}(2) =length(LAN.data{i});
        else
            time{i}(2) =x;
        end
      end
    texto = plus_text(texto, 'Sin rango de tiempo: solo para datos crudos');
    end % if r
    clear r
%
nbchan = LAN.nbchan;
    
   
%------
%------ Condiciones
%------ 

%----------------------------------------------------
%-- amplitud v/s amplitud ---------------------------
%----------------------------------------------------

if strcmp (par{3} , 'amplitud')  || strcmp (par{3} , 'amplitud1') 
if strcmp (par{4} , 'amplitud')  || strcmp (par{4} , 'amplitud2') 


    % eje de bin 0.1 en desviaciones standart -3:3
    ejex = -2:0.1:2; 
    sumy = ones(length(par{2}),1);

      %
        bin = length(ejex) -1;
        carta_a = zeros(length(par{2}),nbchan,bin);
        carta_a_d = zeros(length(par{2}),nbchan,bin);
    
    % for frecuency time decomposition done
    %----------------------------------------
    if isfield(LAN.freq, 'ind')
    for i = 1:length(LAN.freq.ind)% epocas
        base = LAN.freq.ind{i}(fr1,:,:);
        base = mean(base,1);
        base = normal_z(base);
      
        %
        otro = LAN.freq.ind{i}(fr2,:,:);
        otro = normal_z(otro);
        %

        %
        
        for elec = 1:size(otro,2)   % electrodos
        for ii = time{i}(1):time{i}(2)%-1   % por tiempo

		 if (base1(1,elec,ii) >= ejex1(1) )&&( base1(1,elec,ii) < ejex1(length(ejex1)))
                      r = find(ejex1>=base1(1,elec,ii),1) -1;
                      carta_a1(:,elec,r) = carta_a1(:,elec,r) + otro1(:,elec,ii);%%%% fix
                      carta_a_d1(:,elec,r) = carta_a_d1(:,elec,r) + sumy;

             	 end
             %for iii = 1:length(ejex)-1 % ordenar segun amplitud
             %     % Optimizar esta basura!!!
             %     if base(1,elec,ii) >= ejex(iii) && base(1,elec,ii) < ejex(iii+1)
             %         carta_a(:,elec,iii) = carta_a(:,elec,iii) + otro(:,elec,iii);
             %         carta_a_d(:,elec,iii) = carta_a_d(:,elec,iii) + sumy;
             %         break
             %     end
             %     
             %end
        end
        end
    end


	 % for frecuency time decomposition not done
         %----------------------------------------
    else % for dato of voltage
        
        texto = plus_text(texto,' ');
    for i = 1:length(LAN.data)% epocas del dato crudo
        % msn
        
        texto = last_text(texto,['Obteniendo Envolvente Mediante  Hilbert ' num2str(fix(100*i/length(LAN.data))) ' % ']);
        clc, disp(texto);
        
        
        [Rho, Phi, EjeX, EjeF] = spectrogram_hilbert_lan( LAN.data{i}, LAN.srate, par{1}, (par{5}*1000),[]);
       
        % base = LAN.freq.ind{i}(fr1,:,:);
        base = Rho;%(fr1,:,:); 
	base = normal_z(base);
        base = mean(base,1);
        
        %
       [Rho, Phi, EjeX, EjeF] = spectrogram_hilbert_lan( LAN.data{i}, LAN.srate, par{2}, (par{5}*1000),[]);
        %  
        %otro = LAN.freq.ind{i}(fr2,:,:);
        otro = Rho;
        otro = normal_z(otro);
        %
        clear Rho Phi EjeX EjeF
        %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        for elec = 1:size(otro,2)   % electrodos
        for ii = time{i}(1):time{i}(2)%-1   % por tiempo  
              if (base1(1,elec,ii) >= ejex1(1) )&&( base1(1,elec,ii) < ejex1(length(ejex1)))
                      r = find(ejex1>=base1(1,elec,ii),1) -1;
                      carta_a1(:,elec,r) = carta_a1(:,elec,r) + otro1(:,elec,ii);%%% fix
                      carta_a_d1(:,elec,r) = carta_a_d1(:,elec,r) + sumy;

              end
            %
            % for iii = 1:length(ejex)-1 % ordenar segun amplitud
            %      % Optimizar esta basura!!!
            %      if base(1,elec,ii) >= ejex(iii) && base(1,elec,ii) < ejex(iii+1)
            %          carta_a(:,elec,iii) = carta_a(:,elec,iii) + otro(:,elec,iii);
            %          carta_a_d(:,elec,iii) = carta_a_d(:,elec,iii) + sumy;
            %          break
            %      end
            %      
            % end
        end
        end
    end
    
    
    
    
    end
    %-----------------------------
    carta_a_d = carta_a_d +1 ;
    %- 
    % sumo 1 por dos motivos:
    %     - evitar dividir por 0
    %     - castigar la variaza de intervalos con poco ene.
    %-----------------------------
    
    
     LAN.freq.inter_a_a = carta_a ./ carta_a_d;
     LAN.freq.freq.inter_a_a = par{2};% frecuencias
     LAN.freq.time.inter_a_a = ejex(1:bin);% en este caso son SD
end
end


%-----------------------------------------------
%-- fase v/s amplitud ---------------------------
%-----------------------------------------------
if strcmp (par{3} , 'phase')  || strcmp (par{3} , 'phase1') 
if strcmp (par{4} , 'amplitud')  || strcmp (par{4} , 'amplitud2') 

    % eje 
    
    ejex = -1*(pi):(pi/20):pi; 
    sumy = ones(length(par{2}),1);
    
      %
        bin = length(ejex) -1;
        carta_a = zeros(length(par{2}),nbchan,bin);
        carta_a_d = zeros(length(par{2}),nbchan,bin);
    if isfield(LAN.freq,'ind') 
    for i = 1:length(LAN.freq.ind)% epocas
        base = LAN.phase.ind{i}(fr1,:,:);
	%base = normal_z(base);
        base = mean(base,1);
        %
      
        %
        otro = LAN.freq.ind{i}(fr2,:,:);
        otro = normal_z(otro);
        %

        %
        
        for elec = 1:size(otro,2)   % electrodos
        for ii = time{i}(1):time{i}(2)%-1   % por tiempo
		 if (base1(1,elec,ii) >= ejex1(1) )&&( base1(1,elec,ii) < ejex1(length(ejex1)))
                      r = find(ejex1>=base1(1,elec,ii),1) -1;
                      carta_a1(:,elec,r) = carta_a1(:,elec,r) + otro1(:,elec,ii);%%%fix
                      carta_a_d1(:,elec,r) = carta_a_d1(:,elec,r) + sumy;

                 end
             %for iii = 1:bin % ordenar segun amplitud
             %     % Optimizar esta basura!!!
             %     if base(1,elec,ii) >= ejex(iii) && base(1,elec,ii) < ejex(iii+1)
             %         carta_a(:,elec,iii) = carta_a(:,elec,iii) + otro(:,elec,iii);
             %         carta_a_d(:,elec,iii) = carta_a_d(:,elec,iii) + sumy;
             %         break
             %     end
             %     
             %end
        end
        end
    end
    
    %-----------------------------
    carta_a_d = carta_a_d +1 ;
    %- 
    % sumo 1 por dos motivos:
    %     - evitar dividir por 0
    %     - castigar la variaza de intervalos con poco ene.
    %-----------------------------
     LAN.freq.inter_ph_a = carta_a ./ carta_a_d;
     LAN.freq.freq.inter_ph_a = par{2};
     LAN.freq.time.inter_ph_a = ejex(1:bin);% en este caso son radianes

    else % for voltage data------------------------------------------
 
    for i = 1:length(LAN.data)% epocas del dato crudo
        %msn
         texto = plus_text(texto,'.');
         texto = last_text(texto,['Obteniendo Fase Mediante  Hilbert ' num2str(fix(100*i/length(LAN.data))) ' % ']);
        clc, disp(texto);
        
        
        [Rho, Phi, EjeX, EjeF] = spectrogram_hilbert_lan( LAN.data{i}, LAN.srate, par{1}, (par{5}*1000),[]);
       
        %base = LAN.freq.ind{i}(fr1,:,:);
        base = Phi;%(fr1,:,:); 
	base = normal_z(base);
        base = mean(base,1);
        
        %
       [Rho, Phi, EjeX, EjeF] = spectrogram_hilbert_lan( LAN.data{i}, LAN.srate, par{2}, (par{5}*1000),[]);
        %  
        %otro = LAN.freq.ind{i}(fr2,:,:);
        otro = Phi;
        otro = normal_z(otro);
        %
        clear Rho Phi EjeX EjeF
        %
        
        for elec = 1:size(otro,2)   % electrodos
        for ii = time{i}(1):time{i}(2)%-1   % por tiempo
	     if (base1(1,elec,ii) >= ejex1(1) )&&( base1(1,elec,ii) < ejex1(length(ejex1)))
                      r = find(ejex1>=base1(1,elec,ii),1) -1;
                      carta_a1(:,elec,r) = carta_a1(:,elec,r) + otro1(:,elec,ii);%%% fix
                      carta_a_d1(:,elec,r) = carta_a_d1(:,elec,r) + sumy;

             end
             %for iii = 1:bin % ordenar segun amplitud
             %     % Optimizar esta basura!!!
             %     if base(1,elec,ii) >= ejex(iii) && base(1,elec,ii) < ejex(iii+1)
             %         carta_a(:,elec,iii) = carta_a(:,elec,iii) + otro(:,elec,iii);
             %         carta_a_d(:,elec,iii) = carta_a_d(:,elec,iii) + sumy;
             %         break
             %     end
             %     
             %end
        end
        end
    end
    end
    
end%----
end%----

%-----------------------------------------------
%-- both v/s amplitud ---------------------------
%-----------------------------------------------

if strcmp (par{3} , 'both')  || strcmp (par{3} , 'both1') 
if strcmp (par{4} , 'amplitud')  || strcmp (par{4} , 'amplitud2') 
    
   
    

    % eje de bin 0.1 en desviaciones standart -3:3
    ejex1 = -2:0.1:2; 
    ejex2 = -1*(pi):(pi/20):pi; 
    sumy = ones(length(par{2}),1);
    
      %
        bin1 = length(ejex1) -1;
        bin2 = length(ejex2) -1;
        %
        carta_a1 = zeros(length(par{2}),nbchan,bin1);
        carta_a_d1 = zeros(length(par{2}),nbchan,bin1);
        %
        carta_a2 = zeros(length(par{2}),nbchan,bin2);
        carta_a_d2 = zeros(length(par{2}),nbchan,bin2);

    %-----------------------------------------
    % for frecuency time decompocition done.
    %-----------------------------------------

    texto = plus_text(texto,' ');
    if isfield(LAN.freq, 'ind')
    for i = 1:length(LAN.freq.ind)% epocas
        base1 = LAN.freq.ind{i}(fr1,:,:);
        base1 = normal_z(base1);	
	base1 = mean(base1,1);
        %
        otro1 = LAN.freq.ind{i}(fr2,:,:);
        otro1 = normal_z(otro1);
        %

        %
        
        for elec = 1:size(otro1,2)   % electrodos
        for ii = time{i}(1):time{i}(2)%-1   % por tiempo
                if (base1(1,elec,ii) >= ejex1(1) )&&( base1(1,elec,ii) < ejex1(length(ejex1)))
                      r = find(ejex1>=base1(1,elec,ii),1) -1;
                      carta_a1(:,elec,r) = carta_a1(:,elec,r) + otro1(:,elec,ii); %%%fix
                      carta_a_d1(:,elec,r) = carta_a_d1(:,elec,r) + sumy;

                 end
		%for iii = 1:bin1 % ordenar segun amplitud
                %  % Optimizar esta basura!!!
                %  if base1(1,elec,ii) >= ejex1(iii) && base1(1,elec,ii) < ejex1(iii+1)
                %      carta_a1(:,elec,iii) = carta_a1(:,elec,iii) + otro1(:,elec,iii);
                %      carta_a_d1(:,elec,iii) = carta_a_d1(:,elec,iii) + sumy;
                %      break
                %  end
                %  
                %end
        end
        end
    end
		%-----------------------------------------------
    else 	% for crude data
       		%-----------------------------------------------
        
    for i = 1:length(LAN.data) % epocas del dato crudo
        
       
        texto = last_text(texto,['Obteniendo Envolvente y Fase Mediante Hilbert ' num2str(fix(100*i/length(LAN.data))) ' % ']);
        clc, disp_lan(texto);
        %
        %
        [Rho, Phi, EjeX, EjeF] = spectrogram_hilbert_lan( LAN.data{i}, LAN.srate, par{1}, (par{5}*1000),[]);
        %
        %base = LAN.freq.ind{i}(fr1,:,:);
        base1 = Rho;%(fr1,:,:); 
        base1 = normal_z(base1);
 	base1 = mean(base1,1);
        %
        base2 = Phi;%(fr1,:,:); 
	base2 = normal_z(base2);
        base2 = mean(base2,1);
        
        
        clear Rho Phi EjeX EjeF
        %
       [Rho, Phi, EjeX, EjeF] = spectrogram_hilbert_lan( LAN.data{i}, LAN.srate, par{2}, (par{5}*1000),[]);
        %  
        %otro = LAN.freq.ind{i}(fr2,:,:);
        otro1 = Rho;
        otro1 = normal_z(otro1);
        %
        otro2 = Phi;
        otro2 = normal_z(otro2);
        
        clear Rho Phi EjeX EjeF
        %
        
        for elec = 1:size(otro1,2)   % electrodos
        for ii = time{i}(1):time{i}(2)%-1   % por tiempo
                  % sort by  amplitud
                  if (base1(1,elec,ii) >= ejex1(1) )&&( base1(1,elec,ii) < ejex1(length(ejex1)))
                      r = find(ejex1>=base1(1,elec,ii),1) -1;
                      carta_a1(:,elec,r) = carta_a1(:,elec,r) + otro1(:,elec,ii);%%%%fix
                      carta_a_d1(:,elec,r) = carta_a_d1(:,elec,r) + sumy;

             	  end
		  % sort by phase
  		  if base2(1,elec,ii) >= ejex2(1) && base2(1,elec,ii) < ejex2(length(ejex2))
                      r = find(ejex2>=base2(1,elec,ii),1) -1;
                      carta_a2(:,elec,r) = carta_a2(:,elec,r) + otro2(:,elec,ii);%%%%fix
                      carta_a_d2(:,elec,r) = carta_a_d2(:,elec,r) + sumy;
             end

        end
        end
        %%%%
        %%%%%
    end
    
    
    
    
    end
    %-----------------------------
    carta_a_d1 = carta_a_d1 +1 ;
    carta_a_d2 = carta_a_d2 +1 ;
    %- 
    % sumo 1 por dos motivos:
    %     - evitar dividir por 0
    %     - castigar la variaza de intervalos con poco ene.
    %-----------------------------
    
    
     LAN.freq.inter_a_a = carta_a1 ./ carta_a_d1;
     LAN.freq.inter_ph_a = carta_a2 ./ carta_a_d2;
     LAN.freq.freq.inter_a_a = par{2};% frecuencias
     LAN.freq.time.inter_a_a = ejex1(1:bin1);% en este caso son SD
     LAN.freq.freq.inter_ph_a = par{2};% frecuencias
     LAN.freq.time.inter_ph_a = ejex2(1:bin2);% en este caso son radianes
end
end










end %function