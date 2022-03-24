function LAN = freq_lan(LAN,cfg)
% freq_lan.m
% v 0.1.7
% 
%
% REQUIERTE:
%      LAN.freq.cfg.  o cfg
%      .type = 'Hilbert'  'Fourier' 'MultiTaper' 'Morlet'
%      .bin   = [r] ; resolucion en frecuiencias e.g = 1 
%      .win   = [n] ; ventana en puntos e.g = 512
%      .fwin  = [tw] ; cycles per time window for the 'type' MultiTaper ('MTaper')
%                     or time in second when it is a vector (lenght(f1:f2))
%      .tapsmofrq = [fw] ; width of frequency smooth, +-(n*Hz),for the 'type' MultiTaper ('MTaper') 
%                          +-(n*Hz) if numel == 1
%                          +-(n)    if numel == lenght(f1:f2)
%       K = 2*tw*fw-1,  where K is required to be larger than 0 (K is the numener of taper)
%
%      .step  = [n] ; numero de puntos entre ventanas e.g. = 10
%         %%
%        .toi = LAN.time(find(LAN.accept==1,1),1):(step/LAN.srate):LAN.time(find(LAN.accept==1,1),2);
%      .rang  = [f1 f2] ; rango de frecuencias e.g = [5 100]
%        .foi  = [f1f2 f3 f4 f5 f6 ... ] ; eje de frecuencias  e.g.: [1:0.25:5 5.5:0.5:12 13:35]
%      .resample = [ n n]; 
%      .keeptrials = 'no' - 'yes' - 'file' - ('file4chan' only for 'Morlet'  type ) 
%      .alpha = 0.05;     valor alfa para bootstraping por trails
%      .nrandom = 200;    numero de permuteciones para bootstrappimg
% DEPENDENCIAS
%       fourier_ind.m
%       hilbert_ind.m
%       spectrogram_lan.m
%       freq_mtmconvol_lan.m
%
% OPCIONES
%       cfg.delectrode    ; exclude electrodes of analysis
%
%
%       LAN.freq.cfg. 
%       .corfr = [l] ; si hace correlaciones
%       .corfr1 =
%       .corfr2 =  
%
% Pablo Billeke
%
%
%
% Example for Multipater
%
% cfg = [];
% cfg.type = 'MultiTaper'
% cfg.rang  = [1 60]; 
% cfg.fwin  = 0.250 * ones(1,60);
% cfg.tapsmofrq = 6 * ones(1,60);
% cfg.keeptriasl = 'file'
%
% (PB)

% 16.05.2013   fix bad_chan in file4chan option
% 09.10.2012   add file4chan option
% 04.07.2012   fix new segmegtation compatibility
% 04.05.2011   no procesar epocas rechazadas  
%
% OLDs
% v 0.1.2   - 19.1.2010





%false
if nargin == 0
    edit freq_lan
    help freq_lan
    return
end

if nargin == 1
    try
    donde = [... 
            {'type' },...
            {'rang'}...   = [f1 f2] ;
            {'bin' },...
            {'win' },...
            {'fwin' },...
            {'tapsmofrq' },...
            {'step' },...
            {'resample'},... = [ n n];
             ];
    opciones= [... 
            {'Hilbert'},{'Fourier'},{ 'MultiTaper'},{'MorletWavelets'};...
            {'#1'},{'[1 50]'},{ '[ ] '},{ '[ 1 45 ] '};...
            {'#2'},{'1'},{ '2'},{ '5'};...
            {'#3'},{'512'},{ '256'},{ '7'};...
            {'#4'},{'0.250 * ones(size(cfg.rang(1):cfg.rang(2)))'},{ '[ ]     '},{ '[    ]     '};...
            {'#5'},{'5 * ones(size(cfg.rang(1):cfg.rang(2)))'},{ '[ ]   '},{ '[      ]   '};...
            {'#6'},{'10'},{ '5  '},{ '15 '};...
            {'#7'},{'[ 1 8]'},{ '[1 2 ]   '},{ '[ 1 4]   '};...
            ];
    cfg = [];     
    cfg = pregunta_lan(cfg,donde,opciones,'Analisis Tiempo-Frecuencia');
    catch
    disp('UPS ...')   
    disp('ERROR to assigne cfg.''s fields ...')
    cfg = []; 
    end
    if isnumeric(LAN)
    if LAN == 1
        LAN=cfg;
        return
    end
    end
end


if isfield(cfg, 'delectrode')
    LAN = electrode_lan(LAN, cfg.delectrode);
else
    LAN = lan_check(LAN);
end




if isstruct(LAN)
    LAN = freq_lan_struct(LAN,cfg,1,1);
elseif iscell(LAN)
    for lan = 1:length(LAN)
        if ~isempty(LAN{lan})
        LAN{lan} = freq_lan_struct(LAN{lan},cfg,lan,length(LAN));
        else
            warning(['LAN{' num2str(lan) '} is empty '])
        end
    end
end
end

%---------------
function LAN = freq_lan_struct(LAN,cfg,ii,yc)

%-------------
% PARAMETROS
%-------------
if ~isempty(cfg)
    LAN.freq.cfg = cfg;
end


%-- keep trails
cfg.keeptrials = getcfg(cfg,'keeptrials','no');
if ischar(cfg.keeptrials)&&strcmp(cfg.keeptrials,'file')
    cfg.ktt='file';
    cfg.keeptrials = 'yes';
elseif ischar(cfg.keeptrials)&&strcmp(cfg.keeptrials,'file4chan')
    cfg.ktt='file4chan';
    cfg.keeptrials = 'yes';    
else
    cfg.ktt ='lan';
end


% Algoritmos
try
    type = LAN.freq.cfg.type;
catch
    try
    type = LAN.freq.cfg.method;
    LAN.freq.cfg.type=type;
    catch
    type = 'Fourier';
    %disp ('algoritomo = Fourier - Hamming');
    LAN.freq.cfg.type = type;
    end
end
texto = plus_text();
texto = plus_text(texto, ['Algoritmo en uso: ' type  ] );
%------

% rangos
try
    f_rang = LAN.freq.cfg.rang;
    if isempty(f_rang)
    f_rang = [5 100];   
    end
catch
    f_rang = [5 100];
    disp('Rango por defecto 5:100 hz');
    LAN.freq.cfg.rang = f_rang;
end
texto = plus_text(texto, ['Rango de frecuencias ' num2str(f_rang(1)) ' a ' num2str(f_rang(2))  ] );
%------------
%-------------
try
    bin = LAN.freq.cfg.bin;
    if isempty(bin)
    bin = [1];   
    end
catch
    bin = 1;
    disp('Bin por defecto 1 hz');
    LAN.freq.cfg.bin = bin;
end
%-------------
try
    win = LAN.freq.cfg.win;
    if isempty(win)
    win = fix(LAN.srate/4);   
    end
catch
    win = 512;
    disp('Ventana por defecto 512 puntos');
    LAN.freq.cfg.win = win;
end
%-------------
try
    fwin = LAN.freq.cfg.fwin;
    if isempty(fwin)
    fwin = 5;
    end
catch
    fwin = 5;
    %disp('Ventana por defecto 512 puntos');
    LAN.freq.cfg.fwin = fwin;
end
%-------------
try
    tapsmofrq = LAN.freq.cfg.tapsmofrq;
    if isempty(tapsmofrq)
    tapsmofrq = 6 ;  
    end
    
catch
    tapsmofrq = 6;
    disp('tapsmofrq por defecto 6');
    LAN.freq.cfg.tapsmofrq = tapsmofrq;
end
%-------------
try
    output = LAN.freq.cfg.output;
catch
    output = 'pow';
    %disp('Ventana por defecto 512 puntos');
    LAN.freq.cfg.output = output;
end


%-------------
try
    step = LAN.freq.cfg.step;
    if isempty(step)
    step = 10;   
    disp('Paso entre evntanas por defecto 10 puntos');
    end
catch
    step = 10;
    disp('Paso entre evntanas por defecto 10 puntos');
    LAN.freq.cfg.step = step;
end
%----------------
try
    r_s = LAN.freq.cfg.resample;
    texto = plus_text(texto, ['Resampleo en ' num2str(r_s(1)) '/' num2str(r_s(2)) ]);
catch
    r_s = [];
    disp('Sin resampleos');
    LAN.freq.cfg.resample = [];
end
%-------------------
try 
   alpha = LAN.freq.cfg.alpha;
   boot =1;
   try
   nrandom = LAN.freq.cfg.nrandom;
   catch
   nrandom = 200;
   end
   
   texto = plus_text(texto, [' Significance alpha = ' num2str(alpha) ' for bootstraping distribution n:' num2str(nrandom)  ]);
catch
   boot=0;
   alpha = [];
   nrandom = [];

end
%-------
% no prosesar epocas rechazadas
if isfield(LAN, 'accept') && (length(LAN.accept)==length(LAN.data))
   datatemp = LAN.data;
   %LAN = lan_check(LAN,1);
   ifaccept = 1;
   
else
    ifaccept = 0;
end




%-------------------

       texto = plus_text(texto,' ' );
       texto = plus_text(texto,['Sujeto : ' LAN.name ] );
       texto = plus_text(texto, [ ' Pasos ' num2str(ii)  ' de ' num2str(yc)    ]);
       %
       %%%% Fourier - Haming
       %
       switch type
           case {'Fourier', 'fourier' , 'fft' , 'FFT' }
       %if strcmp( type ,  )
           
       LAN  = fourier_ind(LAN, win,step, f_rang(1):bin:f_rang(2),bin,0,[],texto,output,boot,alpha,nrandom);
       
       %
       %%%% Hilbert
       %
           case {'Hilbert', 'hilbert'}
       %elseif strcmp( type ,  )
        
       LAN  = hilbert_ind(LAN, f_rang(1):bin:f_rang(2),0,[],r_s,texto);
       
       %
       %%%%---- Multitaper ----------------------------------
       %
           case {'MTaper','MultiTaper','MT', 'mt'}
       %elseif strcmp(type, 'MTaper' ) || strcmp(type, 'MultiTaper' )
       % en processo de adaptaci??n desde fieltrip
        cfg.method = 'mtmconvol';
        cfg.taper = 'dpss';
         if ~isfield(cfg,'foi')
        cfg.foi = f_rang(1):bin:f_rang(2);
         end
        if ~isfield(cfg,'toi')
           cfg.toi = LAN.time(find(LAN.accept==1,1),1):(step/LAN.srate):LAN.time(find(LAN.accept==1,1),2);
        end
        
        if length(fwin) == 1
            cfg.t_ftimwin = fwin./cfg.foi;
        else
            cfg.t_ftimwin = fwin;
        end
        
        if length(tapsmofrq) == 1
            cfg.tapsmofrq = tapsmofrq*cfg.foi;
        else
            cfg.tapsmofrq = tapsmofrq;
        end
        
        cfg.output = output;


        LAN.freq = freq_mtmconvol_lan(cfg,LAN,texto);
        clear cfg;
       %
       %%%% Morlet Wavelets
       %
           case {'MWavelets','Morlet','MorletWavelets','Wavelet'}
       %elseif strcmp(type, 'MWavelets' ) || strcmp(type, 'Morlet' ) || strcmp(type, 'MorletWavelets' )
        %en processo de adaptacion desde fieltrip
        cfg.method = 'wltconvol';
         if ~isfield(cfg,'foi')
        cfg.foi = f_rang(1):bin:f_rang(2);
         end
        if ~isfield(cfg,'toi')
           cfg.toi = LAN.time(find(LAN.accept==1,1),1):(step/LAN.srate):LAN.time(find(LAN.accept==1,1),2);
        end
        
        if ~isfield(cfg,'width')
        if ~isfield(cfg,'win')
           cfg.width = 7;% LAN.time(1,1):(step/LAN.srate):LAN.time(1,2);
        else
            cfg.width = cfg.win;
        end
        end
        cfg.output = output;
        getcfg(cfg,'bad_chan',0)
        %
      
        
        if strcmp(cfg.ktt,'file4chan')
           old_chanlocs = LAN.chanlocs;
           old_data = LAN.data;
           del = [1:LAN.nbchan];
           if isfield(LAN,'freq')&&isfield(LAN.freq,'powspctrm')
               LAN.freq = rmfield(LAN.freq,'powspctrm');
           end
           
           for n_ch = 1:LAN.nbchan
               if (~any(bad_chan==n_ch))%&&(any(bad_chan)))||isempty(bad_chan)% only good channels
                   ddel = del;
                   ddel(n_ch) = [];
                   LANp = rmfield(LAN,'freq');
                   LANp = electrode_lan(LANp,ddel);   
                   LANp.freq = freq_wltconvol_lan(cfg,LANp,texto);
                   LAN.freq.powspctrm(n_ch,1) =  LANp.freq.powspctrm(1,1);
%                else
%                    %LAN.freq = freq_wltconvol_lan(cfg,LAN,texto);
%                    LANp = LAN;
% BILLEKE: coment?? el else porque en la ??ltima iteraci??n necesitas un LANp
% que incluya freq.time, freq.freq y freq.cfg, pero LAN no tiene ninguno de
% esos y se cae: Reference to non-existent field 'time' en l??nea 385
               end
           end
           LAN.freq.time = LANp.freq.time;
           LAN.freq.freq = LANp.freq.freq;
           LAN.freq.cfg = LANp.freq.cfg;
           clear LANp
        else
          if any(bad_chan);
           old_chanlocs = LAN.chanlocs;
           old_data = LAN.data;
           
           if islogical(bad_chan)
              good_ind = ~bad_chan; 
           else
              good_ind = true(1,LAN.nbchan);
              good_ind(bad_chan) = false;
           end
           end    
            
            
        LAN.freq = freq_wltconvol_lan(cfg,LAN,texto);
        end
        clear cfg; 
        
        
        if any(bad_chan);
           LAN.chanlocs = old_chanlocs;
           LAN.data = old_data;
           if iscell(LAN.freq.powspctrm)
               for t =1:length(LAN.freq.powspctrm)
                   if ~ isempty(LAN.freq.powspctrm{t})
                       clear paso
                       paso(:,good_ind,:,:) = LAN.freq.powspctrm{t};
                       LAN.freq.powspctrm{t} = paso;
                       clear paso
                   end
               end
           elseif isnumeric(LAN.freq.powspctrm)
                       clear paso
                       paso(:,good_ind,:,:) = LAN.freq.powspctrm;
                       LAN.freq.powspctrm = paso;
                       clear paso 
           end
        end
        
        
           otherwise 
       
           error( [ 'Incorrect algorithm type :' type  '?'] );
       
       end
       %LAN.freq.ind_m = Rho;
       %LAN.phase.ind_m = Phi;
      
       
       %-----------------------------
       % calculo evocado
       %---------
            if strcmp( type , 'Fourier' )
       datam = zeros(size(LAN.data{find(LAN.accept==1,1)}));
        largoepoca = [LAN.time(1,1)*1000,  LAN.time(1,2)*1000];
        try
           for epo = 1:length(LAN.data)
              datam = datam + LAN.data{epo}  ;
           end
              datam = datam / length(LAN.data);
              %datam = mean(LAN.data,3);
         
              [Rho_e  Phi_e] = spectrogram_lan(datam, LAN.srate, LAN.freq.cfg.rang(1):bin:LAN.freq.cfg.rang(2), largoepoca ,LAN.freq.cfg.win, LAN.freq.cfg.bin,LAN.freq.cfg.step);
              
              
                LAN.freq.evo.powspctrm = (Rho_e.^2);
                LAN.freq.evo.phase = Phi_e;
                
           catch
              disp('No se pudo hacer calculo evocado')
        end
            end
       %------------------------------------
       %
      
     
       
       clear uno dos 
       
       clear EEG Rho Phi Rho_e Phi_e
      % pack
       
   % end

   % Put the pow in correct order
if ifaccept %&& strcmp(cfg.keeptrials,'yes')
    if iscell(LAN.freq.powspctrm)
        if sum(logical(LAN.accept)) == length(LAN.freq.powspctrm)
        pwc = cell(1,length(LAN.accept));
        pwc(logical(LAN.accept)) = LAN.freq.powspctrm;
        LAN.freq.powspctrm = pwc;
        LAN.data = datatemp;
        clear datatemp
        clear pwc
        end
    end
end



end
%----------------





