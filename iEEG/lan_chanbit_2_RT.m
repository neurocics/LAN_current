function LAN = lan_chanbit_2_RT(LAN,cfg) %
% <*LAN)<] 
% v.0.3
%
% Extract channels with cuadratic pulse to event in the RT structure
%  
% cfg.channels = [ch1 ch2 ...]     
                        % channles sorting following bit information 
                        % the firt bit (ch1) 0^2 , 
                        % the second bit (ch2), 1^2, 
                        % the third bit (ch3),  2^2 , etc  ....
% cfg.width = [ms]      % minimum pulse width for detecting an event 
                        % Recomendacion es alredor de la mitad del ancho
                        % real (ir probando!)
% cfg.onset = [s]       % time in second whree beging the task, default =
%                       % any signal before this time will be ignored 
% cfg.sen = [volt]      % sensitivity to the voltage changes (ir probando!)
% cfg. thr = [M1 M2 M3 
%             M1 M2 M3 ...        ]
%                       % Matrix of threshold values for the signal (pulse)
%                       % per channles ([ n_channels x 3 ])
%                       % Where M1 is the "off" value (tipically near 1 or 0)
%                       %       M2 is the "on"  value  (tipically M1+ or - 0.25 volt / 250000 uV  )
%                       %       M3 is the "no" signal value (tipivcally 0)
%                       % an example for a PC paralle port :
%                       %         Easy 3 EEG - Cadwell example
%                       %    [  1 1.22 0  ...  or 
%                       %       1 0.77 0 .... ]   (depen on the polatiy of the signal)
%                       %         NATUS  example
%                       %    [  .5 3 0  ...   
%                       %       .5 3 0 .... ]*1e6   
%                       % if is empty, try to calculate this value
%                       %    automatically 
%
% Pablo Billeke
% 26.08.2020
% 12.08.2019
% 11.08.2019

% Parameters
sen   = getcfg(cfg,'sen',0.07);
ancho = fix(getcfg(cfg,'width',50)/1000 * LAN.srate);
channels = getcfg(cfg,'channels',[]);
onset = getcfg(cfg,'onset',0);

onset = fix(onset*LAN.srate);
onset = max(1,onset);

thr = getcfg(cfg,'thr',[]);
%
if isempty(channels)
    error(['You must define the channels for transforming to events [cfg.channles = [ch1, ch2, ...] ] ']);
end


cc=0;
for NCH = channels;
    cc=cc+1;
    if isempty(thr)
        D = (LAN.data{1}(NCH,:));
        M1 =  median(D(onset:end));
        D = D( D<(M1-sen) | D>(M1+sen));
        M2 = median(D(onset:end));

        % check it, ... Is it necesary ??
        % D = D( D<(M2-sen) | D>(M2+sen));
        % M3 = median(D);
        M3 = 0;
        %  [M1 M2 M3]
     else
        M1 = thr(cc,1);    
        M2 = thr(cc,2);  
        M3 = thr(cc,3);  
    end
    
    D = (LAN.data{1}(NCH,onset:end));
    
    D = [abs(D-M1) ; abs(D-M2) ; abs(D-M3)];
    [n, D] = min(D,[],1);
    D = [ones(1,(onset-1)) D  ];
    indx = find(D==2) ;

    indx(indx>((length(D))-2*ancho)) = []; 
    
    eve =0;
    for n_indx = indx
        % n_indx = indx(1);
       if mean(D(n_indx-ancho:n_indx-1)) == 1 && mean(D(n_indx:n_indx+ancho)) == 2 
           eve = eve +1;
           EV{NCH}(eve) = NCH;
           LATEN{NCH}(eve) = n_indx;
       end

    end
end

 EVt = cat(2,EV{:});
 LATENt = cat(2,LATEN{:});
 La = unique(LATENt);
 ce = length(La);
 ev =0;
 
    while ce > 0
        pasoE = LATENt < (La(1)+ancho*1.5) & LATENt >= (La(1));
        if sum(pasoE)>0
            ev=ev+1;
            STIM(ev) = sum(2.^(EVt(pasoE)-min(cfg.channels)));
            LATENCY(ev) = fix(mean(LATENt(pasoE)));
            La(La<La(1)+ancho*1.5)=[];
        end
        if isempty(La)
            ce=0;
        end
    end
    
LAN.RT = [];
LAN.RT.est = STIM;
LAN.RT.laten = (LATENCY/LAN.srate)*1000;
LAN.RT.rt = ones(size(STIM))*-99;
LAN.RT.resp = ones(size(STIM))*-99;
LAN.RT.good = ones(size(STIM));

LAN.RT = rt_check(LAN.RT);
LAN = lan_check(LAN);
