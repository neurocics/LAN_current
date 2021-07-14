 function LAN = syn_hilbert_lan_old(LAN, freq, win_cycles)
%   V.1.9
%   9.06.2009  
%    
%
%   
%
%   Calculate -> syncrony between electrodes througth hilbert transforms
%   example:
%   LAN  = syn_hilbert_lan(LAN, 25, 6);
% 
% parameters:
% LAN                        %  matrix 2d elec x time
% freq = 25;                 % in Hz
% win_cycles = 6;            % previously 6 
%                            % in cycles for the splv %%%%%%%%%%%%
%                            % 10 cycles seems ok too...
%   
% Estadistica:
%           (1) bootstraping, if exist LAN.phase.cfg.stata = 'boot'
%                             and LAN.phase.cfg.nboot = # ; 100 recomended  
%
%Pablo Billeke
%   Basada en 
%   Hsynchrio.m
%   Diego Cosmmelli
if nargin < 3
    win_cycles = 6;
end



if iscell(LAN)
    cuantos = length(LAN);
    for lan = 1: cuantos
        LAN{lan} = syn_hilbert_lan_st(LAN{lan}, freq, win_cycles,cuantos,lan);
    end
else
    
    LAN = syn_hilbert_lan_st(LAN, freq, win_cycles,1,1);
end
end

 
 
 
 function LAN = syn_hilbert_lan_st(LAN, freq, win_cycles, cuantos,ahora)


if iscell(LAN.data)
    ee = length(LAN.data);
    for epo = 1: ee
        LAN = syn_hilbert_lan_epoch(LAN, freq, win_cycles,epo, cuantos , ahora, ee, epo );
    end
else
    error('por ahora solo LAN.data en cells')
end
end
 
 
 
 function  LAN = syn_hilbert_lan_epoch(LAN, freq, win_cycles,epo,cuantos,ahora,cuantos2,ahora2)                      

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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%create timeline
totaltime = LAN.time(epo,1:2);
   ImageGridTime = [totaltime(1):((totaltime(2)-totaltime(1))/(size(data,1)-1)):totaltime(2)] ;
%%%
%%%
  Fs  = LAN.srate;
%%%%%%%%%%%%%%%%  parametros %%%%%%%%%%%%%%%%%%%%%%%%%%%%
F_ECH = Fs;
win_length_sec = win_cycles*(1/freq);   % in sec
win_length_pts = floor(win_length_sec*F_ECH);  % in pts
step = 0.1;       %0.05                     % in sec
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
start_time = (totaltime(1)+win_length_sec/2);
end_time = (totaltime(2)-win_length_sec/2);
%%%
total_steps = (end_time-start_time)/step + 1;
TimeLineSynchro = start_time:step:end_time;     % linea de tiempo para la sincronia
%%%                                             % in sec
%%%
indexTimeMin = find(round(ImageGridTime*1000)==round(start_time*1000));% revisar si la linea de tiempo esta en segundos o milisegundos
indexTimeMax = find(round(ImageGridTime*1000)==round(end_time*1000));
indexTimeMin = indexTimeMin(1);
indexTimeMax = indexTimeMax(1);
% 
%  %iminH = find(round(ImageGridTime*1000)==totaltime(1)*1000);   % indice del inicio de los datos que se van a Hilbert
%  %imaxH = find(round(ImageGridTime*1000)==(totaltime(2)+1)*1000); % indice del final de los datos que se van a Hilbert
% 
% 
% filtering
FILT_BAS = freq - 1.5; % use 1.5 Hz above and below the target frequency
FILT_HAU = freq + 1.5;
% lowpass = num2str(FILT_HAU);
% highpass = num2str(FILT_BAS);

X_hilbert = filter_hilbert(data,F_ECH,FILT_BAS,FILT_HAU);
X_hilbert = X_hilbert./abs(X_hilbert);

if isfield(LAN.phase, 'cfg')
    if isfield(LAN.phase.cfg, 'stata')
        if LAN.phase.cfg.stata == 'boot'
           if isfield(LAN.phase.cfg, 'nboot')
           nboot = LAN.phase.cfg.nboot;
           else
           nboot = 100; 
           end
            J_boot   = fft(data,[],1);
             phasew   = 2*pi*rand(size(J_boot));  
            %phasew = angle(J_boot);
             phase_bb = bootstrp(nboot, @(x) {x}, phasew );
            %phase_bb = bootstrp(nboot, @(x) {x}, phasew );
            for k = 1:length(phase_bb)
                boot_sig = real(ifft(abs(J_boot).*exp(1i*phase_bb{k}),[],1));
                boot_hilbert = filter_hilbert(boot_sig,F_ECH,FILT_BAS,FILT_HAU);
                phase_b{k} = boot_hilbert;%./abs(boot_hilbert);
            end
           
           %[phase_b yol] = bootstrp(nboot, @(x) {x}, X_hilbert );
           bt=1;
        end
    end
end



%%% waitbar %%%%%%%%%%%%%%1%%%%%%%%
%
a = ' ';
cont = 0
for pol = 1:50
    a = cat(2,a,'.');
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for j = 1:total_steps   %% loop over windows through the trial
    %
    %init_w_index = floor(indexTimeMin+(j-1)*step*F_ECH);
    init_w_index = floor((j-1)*step*F_ECH)+1;
    end_w_index = init_w_index + win_length_pts;
    %
    %%%%%
        X_hilbert_win = X_hilbert(init_w_index:end_w_index,:);
        largoventana = length(X_hilbert_win);
        is = 0;
        %
        %phase = X_hilbert_win./abs(X_hilbert_win);
        %angles = unwrap(angle(X_hilbert_win));
        c = real(X_hilbert_win);
        s = imag(X_hilbert_win);
        %
        pause (0.0001)
        %
        for m = 2:1:n_elec
             for n = 1:m-1
                %%% 
                %%% formula 
                 dphi = c(:,m).*c(:,n) + s(:,m).*s(:,n) + i*(s(:,m).*c(:,n)-c(:,m).*s(:,n));
                %%% Kuramoto %dphi = (exp(angles(:,m).*i) + exp(angles(:,n).*i))./2;
                  % sum the phase difference 
                  SS = abs(mean(dphi));
                  MM = angle(mean(dphi)); % keep phi between signals
                  % syn(m,n) = SS;
                  % syn(n,m)= SS;
                  is=is+1;
                  v_save(is,j)=SS;
                  d_save(is,j)=MM;
              
              end % for n
        end % for m
%%%%%%%%%%%%%%%%%%%%%%%%bootstrat

if bt ==1
    for boot = 1:nboot
        X_hilbert_b_win = phase_b{boot}(init_w_index:end_w_index,:);
        
        is = 0;
        c = real(X_hilbert_b_win);
        s = imag(X_hilbert_b_win);
        %
        pause (0.0001)
        %
        for m = 2:1:n_elec
             for n = 1:m-1

                 dphi = c(:,m).*c(:,n) + s(:,m).*s(:,n) + i*(s(:,m).*c(:,n)-c(:,m).*s(:,n));
 
                  SS = abs(mean(dphi));
                  % MM = angle(mean(dphi)); % keep phi between signals
                
                  is=is+1;
                  v_save_b{j}(is,boot)=SS;
                  %d_save_b{boot}(is,j)=MM;
              
              end % for n boot
        end % for m boot
      
    end % for boot
    %for sbot = 1:nboot
            for pares = 1:is
                syn_bot = squeeze(v_save_b{j}(pares,:));
                syn_bot(nboot+1) = squeeze(v_save(pares,j));
                [syn_bot, ind] = sort(syn_bot);
                p_v_save(pares,j) = 1 - (ind(nboot+1)/(nboot+1));
               % clear syn_bot ind
            end %pares
            %clear v_save_b
    %end % for sbot
end %if bt



%%%%%%%%%%%%%%%%%%%%%%%%
        
        
        

% wairbar %%%%%%%%%%%%%%%%%%%2%%%%%%%%%%%%%%%%%
cont = cont + 1;
porcentaje(cont) = fix(100 * cont/ total_steps);
pp = [num2str(ahora) ' of ' num2str(cuantos) ' Conditions '  ];
condi = LAN.cond;
pp2 = [num2str(ahora2) ' of ' num2str(cuantos2) ' Epochs '  ];
if cont == 1 
    
    p = [num2str(porcentaje(cont)) ' % ' ];
    clc;
    disp(pp)
    disp(condi)
    disp(pp2)
    disp(p)
    disp(a)
    
else
    if porcentaje(cont) >porcentaje(cont-1)
    p = [num2str(porcentaje(cont)) ' % ....' ];
    clc;
    disp(pp)
    disp(condi)
    disp(pp2)
    disp(p)
    if fix(porcentaje(cont)/2) > 1
    a(1:fix(porcentaje(cont)/2)) = 'x';    
    a(fix(porcentaje(cont)/2)) = '>';
    end
    disp(a)
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


end % for j, end loop over windows

LAN.phase.syn{epo} = v_save;
LAN.phase.diff{epo} = d_save;
LAN.phase.stime{epo} = TimeLineSynchro + (win_length_sec/2);
LAN.phase.p_val{epo} = p_v_save;



end


