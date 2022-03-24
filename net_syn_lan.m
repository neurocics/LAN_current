function LAN = net_syn_lan(LAN, par)
%   V.0.0.0.
%   10.12.2009   
%  
%   
%
%   Calculate -> syncrony between electrodes througth hilbert transforms
%   example:
%   LAN  = syn_hilbert_lan(LAN, par);
% 
% parameters:

%-------------------------------------
% par{1} freq 		; LAN.phase.cfg.net_freq
% par{2} time 		; LAN.phase.cfg.net_time
% par{3} algorithm 	; LAN.phase.cfg.net_algo
% par{4} stata	 	; LAN.phase.cfg.net_stata
% par{5} permutation 	; LAN.phase.cfg.net_permute
%
% Algoritmos:
%           (1) 'PLV'  
%           (2) 'PLI'            Phase Lag Index: if -->   LAN.phase.cfg.pli = 1; 
%                                Calcula el indice de diferencia de fase
%                                numero de 0 a 1 que corrige efecto de 
%                                fuente comun en el calculo de sincronia
%                                formula:
%                                        PLI = | < sign[delat phi(t_k)] > |
%                                        (Stam et al., 2007)
%	    (3) 'BOTH'
% Estadistica:
%           (1) 'BOOT'	      bootstraping, if exist LAN.phase.cfg.stata = 'boot'
%                             and LAN.phase.cfg.nboot = # ; 100 recomended
%                             hace un muestar bootstrapingf de las fases de
%                             la misma se??al
%           (2) 'SURO'        surogate, if exist cfg.net_stata = 'suro'
%                             and .cfg.net_permute = # ; 100 recomended
%                             
%
%   Pablo Billeke
%   Basada en 
%   Hsynchrio.m
%   Diego Cosmelli
%
%
if nargin < 2
par = [];    
end

texto = plus_text(' ');
texto = plus_text(texto, ' net_syn_lan.m v.0.0.0 ' );

try
    LAN = lan_check(LAN);
catch
    warning('File not past the check');
    texto = plus_text(texto, ' File not past the check ' );
end


texto = plus_text(texto, ' ' ); 


if iscell(LAN)
    cuantos = length(LAN);
    for lan = 1: cuantos
        texto = last_text(texto,[ ' Procesando ' num2str(lan) ' de ' num2str(length(LAN)) ' condiciones' ]);
        LAN{lan} = net_syn_lan_st(LAN{lan}, par,texto);
    end
else
    texto = last_text(texto, 'Procesando ... '  );
    LAN = net_syn_lan_st(LAN, par,texto);
end
end


 
 
 function LAN = net_syn_lan_st(LAN, par, texto)


if iscell(LAN.data)
    ee = length(LAN.data);
    for epo = 1: ee
        LAN = syn_net_lan_epoch(LAN, par, texto,epo );
    end
else
    error('por ahora solo LAN.data en cells')
end

%LAN.phase.cfg.win_cy = win_cycles;
LAN.phase.cfg.net_freg = par{1};%freq;
LAN.phase.cfg.net_time = par{2};% time 		; 
LAN.phase.cfg.net_algo = par{3}; %  algorithm 	; 
LAN.phase.cfg.net_stata = par{4}; % stata	 	; 
LAN.phase.cfg.net_permute = par{5};%  permutation 	; 
end
 
 
 
 function  LAN = syn_net_lan_epoch(LAN, par, texto ,epo)                   

%%%% data dimension fix %%%%%%%%
%   time x electrode
data = LAN.data{epo};

[uno, dos] = size(data);
%[n_elec, timelength] = size(data);
if uno < dos
    n_elec = uno;
    timelength = dos;
    data = data';
elseif uno > dos
    n_elec = dos;
    timelength = uno;
end
clear uno dos

%---------------------
%%% create timeline
%%% totaltime = LAN.time(epo,1:2);
%%%   ImageGridTime = [totaltime(1):((totaltime(2)-totaltime(1))/(size(data,1)-1)):totaltime(2)] ;


%------------------------
%%% time
%for i = 1:LAN.trials
    time{epo}(1) = par{2}(1)*1000;%
    %LAN.freq.cfg.net_time(1)=par{5}(1);%
    times = linspace(LAN.time(epo,1),LAN.time(epo,2),length(LAN.data{epo})); 
    x = find(times<=time{epo}(1),1);
        if isempty(x)
            time{epo}(1) =1;
        else
            time{epo}(1) =x;
        end
    time{epo}(2) = par{2}(2)*1000;%
   % LAN.freq.cfg.inter_time(2) = par{5}(2);%*1000;
    x = find(times>=time{epo}(2),1);
        if isempty(x)
            time{epo}(2) =length(LAN.data{epo});
        else
            time{epo}(2) =x;
        end
    %end
%-----------------------------------------------------

%%%-----------------------------------------------------
Fs  = LAN.srate;

%%_-------------------------------------------------------
freq = par{1};

%----------------------
%parametros %
F_ECH = Fs;
%win_length_sec = win_cycles*(1/freq);   % in sec
%win_length_pts = floor(win_length_sec*F_ECH);  % in pts
%step = 0.05 ;        %     0.1;               % in sec
%-------------------------
%start_time = (totaltime(1)+win_length_sec/2);
%end_time = (totaltime(2)-win_length_sec/2);
%%%
%total_steps = (end_time-start_time)/step + 1;
%TimeLineSynchro = start_time:step:end_time;     % linea de tiempo para la sincronia
%%%                                             % in sec
%%%
%indexTimeMin = find(round(ImageGridTime*1000)==round(start_time*1000));% revisar si la linea de tiempo esta en segundos o milisegundos
%indexTimeMax = find(round(ImageGridTime*1000)==round(end_time*1000));
%indexTimeMin = indexTimeMin(1);
%indexTimeMax = indexTimeMax(1);
% 

FILT_BAS = freq - 1.5; % use 1.5 Hz above and below the target frequency
FILT_HAU = freq + 1.5;


 
X_hilbert = filter_hilbert(data(time{epo}(1):time{epo}(2),:),F_ECH,FILT_BAS,FILT_HAU);

%X_hilbert = X_hilbert./abs(X_hilbert);


%-----------------------------
% Default paramnetres
%-----------------------------
PLI = 0; 		% Algoritmo de fase
	try
	if strcmp(par{3},'PLI') ||strcmp(par{3},'BOTH') 
	PLI = 1;
	else
	PLI = 0;
    end
    end
bt = 1; 	%estadistica
STATA = 1 ; 	%surogat
	try
	if strcmp(par{4},'SURO')
	   STATA = 1;
	elseif strcmp(par{4},'BOOT')
	   STATA = 2;
	elseif strcmp(par{4},'NO')
	   bt=0;
	
    end	
    end
    nboot = 100;  % 100 simulaciones
    try nboot = par{5}; end
	%try  w = LAN.phase.cfg.nsuro; end
	%try w = LAN.phase.cfg.alpha; w = round(1/w-1);end
	% try   = w; end
%-------------------------
% simulaciones
%-------------------------

if STATA == 2
%------FT1 bootstraping
        J_boot   = fft(data(time{epo}(1):time{epo}(2),:),[],1);
        %phasew   = 2*pi*rand(size(J_boot));  
        phasew = angle(J_boot);
        phase_b = bootstrp(nboot, @(x) {x}, phasew );
           for k = 1:length(phase_b)
               boot_sig = real(ifft(abs(J_boot).*exp(1i*phase_b{k}),[],1));
               boot_hilbert = filter_hilbert(boot_sig,F_ECH,FILT_BAS,FILT_HAU);
               phase_b{k} = boot_hilbert;%./abs(boot_hilbert);
           end
        %LAN = add_field(LAN,'phase.cfg.stata = ''boot'' ');
	    %LAN = add_field(LAN,['phase.cfg.nboot = ' num2str(nboot)]);

elseif STATA == 1
%-------- FT1 surrogates
          J_boot   = fft(data(time{epo}(1):time{epo}(2),:),[],1);
          phasew   = 2*pi*rand(size(J_boot)) - pi;  
          %phasew = angle(J_boot);
          %nboot
          phase_b = bootstrp(nboot, @(x) {x}, phasew );
          for k = 1:length(phase_b)
              boot_sig = real(ifft(abs(J_boot).*exp(1i*phase_b{k}),[],1));
              boot_hilbert = filter_hilbert(boot_sig,F_ECH,FILT_BAS,FILT_HAU);
              phase_b{k} = boot_hilbert;%./abs(boot_hilbert);
          end
        %LAN = add_field(LAN,'phase.cfg.stata = ''suro'' ');
	    %LAN = add_field(LAN,['phase.cfg.nsuro = ' num2str(nboot)]);
        %else
	    %LAN = add_field(LAN,'phase.cfg.stata = ''no'' ');
       
end

%---------- waitbar----------- 
a = ' ';
cont = 0;
for pol = 1:50
    a = cat(2,a,'.');
end
%-----------------------------

%for j = 1:total_steps   %% loop over windows through the trial
    %init_w_index = floor(indexTimeMin+(j-1)*step*F_ECH);
 %   init_w_index = floor((j-1)*step*F_ECH)+1;
  %  end_w_index = init_w_index + win_length_pts;
    %
    %%%%%
       % X_hilbert_win = X_hilbert(time{}:end_w_index,:);
        X_hilbert = X_hilbert./abs(X_hilbert);
       
        is = 0;
       
        c = real(X_hilbert);
        s = imag(X_hilbert);
        %
        %pause (0.0001)
        %
        for m = 2:1:n_elec
             for n = 1:m-1
                %%% formula 
                 dphi = c(:,m).*c(:,n) + s(:,m).*s(:,n) + i*(s(:,m).*c(:,n)-c(:,m).*s(:,n));
                
                  SS = abs(mean(dphi)); % sum the phase difference 
                  MM = angle(mean(dphi)); % keep phi between signals
                  if PLI == 1
                  LI = abs(mean(sign(angle(dphi))));
                  end
                  %
                  is=is+1;
                  v_save(is,1)=SS;
                  d_save(is,1)=MM;
                  if PLI == 1
                  l_save(is,1)=LI;
                 end
              end % for n
        end % for m
%------------simualcion

if bt ==1
    for boot = 1:nboot
        X_hilbert_b_win = phase_b{boot};%(init_w_index:end_w_index,:);
        X_hilbert_b_win = X_hilbert_b_win./abs(X_hilbert_b_win);
        is = 0;
        c = real(X_hilbert_b_win);
        s = imag(X_hilbert_b_win);
        %
        %pause (0.0001)
        %
        for m = 2:1:n_elec
             for n = 1:m-1

                 dphi = c(:,m).*c(:,n) + s(:,m).*s(:,n) + i*(s(:,m).*c(:,n)-c(:,m).*s(:,n));
 
                  SS = abs(mean(dphi));
                  % MM = angle(mean(dphi)); % keep phi between signals
                  if PLI ==1
                  LI = abs(mean(sign(angle(dphi))));
                  end 
                  
                  is=is+1;
                  v_save_b(is,boot)=SS;
                  %d_save_b{j}(is,boot)=MM;
                  if PLI == 1; l_save_b(is,boot)=LI;end;
              end % for n boot
        end % for m boot
      
        
        
    end % for boot
       for pares = 1:is
                %%%% calculo p con estimaci??n funci??n  densidad
                % 
                syn_bot = squeeze(v_save_b(pares,:));
                if PLI ==1
                lag_bot = squeeze(l_save_b(pares,:));
                end
                evalp = squeeze(v_save(pares,1));
                if PLI ==1
                evall = squeeze(l_save(pares,1));
                end
                % condicion error
                %if max(syn_bot)>1 | min(syn_bot)<0
                  % alpha_v_save(pares,1) =9;
                  % error('revisar')
                %elseif evalp>1 | evalp<0
                   % alpha_v_save(pares,1) =8;
                   % error('revisar')
                %else
                % 
                p_v_save(pares,1)=ksdensity(syn_bot,[evalp],'support',[-0.01 1.01],'function', 'survivor');% funcion densidad, "sobrevida"
                 if PLI ==1;
                 p_l_save(pares,1)=ksdensity(lag_bot,[evall],'support',[-0.01 1.01],'function', 'survivor');% funcion densidad, "sobrevida"
                 end;
                    if evalp > max(syn_bot)
                        alpha_v_save(pares,1) =1;
                    else
                        alpha_v_save(pares,1) =0;
                    end
                    if PLI ==1;
                    if evall > max(lag_bot)
                        alpha_l_save(pares,1) =1;
                    else
                        alpha_l_save(pares,1) =0;
                    end; 
                    end;
              %  end
              
        end % for pares
   end %if bt




%--------------------------

%-----wairbar-------------
%cont = cont + 1;
%porcentaje(cont) = fix(100 * cont/ total_steps);
%pp = [num2str(ahora) ' of ' num2str(cuantos) ' Conditions '  ];
%condi = LAN.cond;
%pp2 = [num2str(ahora2) ' of ' num2str(cuantos2) ' Epochs '  ];
%if cont == 1 
    
   % p = [num2str(porcentaje(cont)) ' % ' ];
    clc
    por = fix(100*epo/length(LAN.data));
    texto = plus_text(texto,[ ' Llevo ' num2str(por) '% de esta condicion ' ]);
    disp_lan(texto);
%     disp(pp)
%     disp(condi)
%     disp(pp2)
%     disp(p)
%     disp(a)
    
%else
%     if porcentaje(cont) >porcentaje(cont-1)
%     p = [num2str(porcentaje(cont)) ' % ...' ];
%     clc;
%     disp(pp)
%     disp(condi)
%     disp(pp2)
%     disp(p)
%     if fix(porcentaje(cont)/2) > 1
%     a(1:fix(porcentaje(cont)/2)) = 'x';    
%     a(fix(porcentaje(cont)/2)) = '>';
%     end
%     disp(a)
%     end
%end
%---------------------------------------

%end % for j, end loop over windows


LAN.phase.net_syn{epo} = v_save;
LAN.phase.net_diff{epo} = d_save;
%LAN.phase.stime{epo} = TimeLineSynchro + (win_length_sec/2);
LAN.phase.net_p_val{epo} = p_v_save;
LAN.phase.net_alpha{epo} = alpha_v_save;

if PLI == 1
    LAN.phase.net_pli{epo} = l_save;
    LAN.phase.net_pli_p{epo} = p_l_save;
    LAN.phase.net_pli_a{epo} = alpha_v_save;
end


end
