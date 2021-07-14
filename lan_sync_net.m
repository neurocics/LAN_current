function LAN = lan_sync_net(LAN,cfg)
% 		v.0.0.3.5
% LAN provisory function for syncrony network
%
%
% cfg.
% cfg.freq_method = 'Wavelet'
% cfg.algoritm	  = 'PLV'
% cfg.across	  ='trials'
%                 ='time'
% cfg.step       = [ n ]    %  step to calculated syncrony across trail
			    %  windows to calculate syncroni across time
% cfg.frange     =  [f1 f2] % Range of analized frequencies in Hz. eg [10 100]
% cfg.ResHz     =  [ n ]    %resolution in bins per Hz, 2 means  2 bins per Hz

% cfg.ifdiv
% cfg.imagingkernel = transformation matrix for source stimation
% cfg.ncomponents   = numeber of components (dipoles) per source
% cfg.ndiv   {[f end] , [f2 end2],...}

% Mario Chavez
% Pablo Billeke

% 07.05.2012 add imegignkernel options, and fix source reduction
% 04.05.2012
% 14.03.2012
% 11.01.2012
% 22.11.2011
% 21.11.2011


% generic cicle for LAN cell
if iscell(LAN)   
   funhandle = str2func(mfilename); 
   for lan = 1:lenght(LAN)
   LAN{lan}  = funhandle(LAN{lan},varargin{2:nargin});
   end
   return
end
    
% function for LAN structure   

% options
getcfg(cfg,'freq_method','Wavelet');
nstep = getcfg(cfg,'step',10);
getcfg(cfg,'ResHz',1); 
getcfg(cfg,'across','trials')
getcfg(cfg,'ncomponents',1)
getcfg(cfg,'ops','')
getcfg(cfg,'ifdiv',false)
getcfg(cfg,'ndiv')
getcfg(cfg,'conditions','')
getcfg(cfg,'onlypow',false)
getcfg(cfg,'output','pha')
getcfg(cfg,'imagingkernel','')


if onlypow
    ifpha = false;
    ifpow = true;
else
    ifpha = true;
    ifpow = false;   
end

switch output
    case 'pha'
    ifpha = true;
    ifpow = false;  
    case 'pow'
    ifpha = false;
    ifpow = true; 
    case 'both'
    ifpha = true;
    ifpow = true;
end




if ncomponents==1
   ifreduce=false;
else
   ifreduce=true;
end
llevo = 0;
% compativility 
if ~isempty(conditions) %&& ifreduce
   ifdiv = true; 
   for c = 1:length(conditions)
      if length(LAN.conditions.ind{conditions(c)})==length(LAN.data)
         ci = logical(LAN.conditions.ind{conditions(c)});
      else
         ci = false(1,length(LAN.data));
         ci(LAN.conditions.ind{conditions(c)}) = true;
      end
      ndiv{c}(1) = llevo + 1;
      ndiv{c}(2) = sum(ci) + llevo;
      llevo = sum(ci) + llevo;
      accept{c} = LAN.accept(ci); 
      data{c} = LAN.data(ci); 
      correct{c} = LAN.correct(ci); 
   end 
   accept = cat(2,accept{:});
   correct = cat(2,correct {:});
   data = cat(2,data{:});
   M = cat(3,data{accept});
else
   M = cat(3,LAN.data{LAN.accept});
end
   

if ~strcmp(across,'trials')
    error([' across: ' across  ': This Opticion no work yet'])
end
    


% LAN = lan_check(LAN,'D');


switch freq_method

   
    
    
%%%%%%%%%%%%%%%  Wavelts for syncrony
case {'Wavelet', 'wavelet','W'}
    
    
  
  [K,T,N] = size(M);

  % Computing the time axis
  EjeX = LAN.time(1,1):(1/LAN.srate):(LAN.time(1,1)+(T/LAN.srate));
  EjeX = EjeX(1:nstep:end);

  % Range of frequencies that are computed (in Hz)
  EjeF = [cfg.frange(1):ResHz:cfg.frange(2)];

  %matriz de potenciales evocados
  %Mevp = mean(M,3);

disp(['Trials : ' ])  
%cicla a traves de los Trials
for t = 1:N
    % mostrar avanze
     fprintf([ num2str(t) '.'])
     if mod(t,20)==0, fprintf('\n'); end
    % bar_wait(t,N,ops)
    
    %data
    MatSig = squeeze(M(:,:,t))';
    
    % sources
    if ~isempty(imagingkernel)
    MatSig = (imagingkernel * MatSig')';
    end
    %Definiendo Acumuladores para Trials 1%
    if t == 1
        %calcula amplitud y fase
        if ~ifdiv
        [Rho Phi] = waveletSpectro( MatSig, LAN.srate, cfg.frange, ResHz, nstep);
        if ifpha
                Phi=cos(Phi)+sqrt(-1)*sin(Phi);
                %calcula la matriz de diferencias de fase a partir de la matriz de fases
                [CumMatdif, ParElec] = difphaser3(Phi,1);
         end       
                %power
                 CumRho = Rho;
        
        else
           [FF(:,:,:,t) ] = waveletSpectro( MatSig, LAN.srate, cfg.frange, ResHz, nstep); 
        end

    else %Trial 2 y siguientes%
        if ~ifdiv
        %calcula amplitud y fase
        [CumRho, Phi] = waveletSpectro( MatSig, LAN.srate, cfg.frange, ResHz, nstep);
        Phi=cos(Phi)+sqrt(-1)*sin(Phi);
        if ifpha
            %calcula la matriz de diferencias de fase a partir de la matriz de fases
            [Matdif, ParElec] = difphaser3(Phi,1);
            CumMatdif = CumMatdif + Matdif;
            %figure, imagesc(abs(squeeze(CumMatdif(1,:,:)))'/N); pause
            end
        %power
         CumRho = CumRho + Rho;
        else
           [FF(:,:,:,t) ] = waveletSpectro( MatSig, LAN.srate, cfg.frange, ResHz, nstep); 
        end
    end
end


if ifreduce
                fprintf('\n')
                disp(['Reducing components and caltulating phase differences: ' ])  %         
                % haciendolo aun
            ne=0;
            for e = 1:ncomponents:size(FF,1) 
                ne=ne+1;
                for yy = 1:size(FF,2);
                    for zz = 1:size(FF,3);
                        FFF = squeeze( FF(e:(e+ncomponents-1),yy,zz,:) );
                        newFF(ne,yy,zz,:) = svdfft(FFF,1);
                        clear FFF
                          
                    end
                end

            end
            FF = newFF;
            clear newFF;
end

%if ifdiv
            if ifdiv
                 % phase
                  Phi = angle(FF);
                  Rho = single(FF.*conj(FF));
                  clear FF
                  Phi=cos(Phi)+sqrt(-1)*sin(Phi);
                % per trials 

                
                        for nd = 1:length(ndiv)
                        if ifpha
                        for t = ndiv{nd}(1):ndiv{nd}(end)
                            fprintf([ num2str(t) '.'])
                            if mod(t,20)==0, fprintf('\n'); end
                            if t == ndiv{nd}(1)
                               
                            [CumMatdif{nd}, ParElec] = difphaser3(Phi(:,:,:,t),1); 
                                                               
                            else
                            [Matdif, ParElec] = difphaser3(Phi(:,:,:,t),1);
                            CumMatdif{nd} = CumMatdif{nd} + Matdif;    
                            end
                        end 
                        end
                        if ifpow
                           pow{nd}= mean(Rho(:,:,: , [ndiv{nd}(1):ndiv{nd}(end) ] ),4);
                        end
                   end 
                   clear Phi Pho
                   
                elseif ifreduce
                % phase
                  Phi = angle(FF);
                  clear FF
                  Phi=cos(Phi)+sqrt(-1)*sin(Phi);
                % per trials
                        if ifpha
                        for t = 1:N
                            fprintf([ num2str(t) '.'])
                            if mod(t,20)==0, fprintf('\n'); end
                            if t == 1
                            [CumMatdif, ParElec] = difphaser3(Phi(:,:,:,t),1);   
                            else
                            [Matdif, ParElec] = difphaser3(Phi(:,:,:,t),1);
                            CumMatdif = CumMatdif + Matdif;    
                            end
                        end                    
                        end
                end

                
                
            %end
             
    
%end


%LAN.FREQ.powspctrm= (CumRho .* conj(CumRho)) ./N;

%Matriz de Sincronia Bruta
if ifpha
if iscell(CumMatdif)
    for nd = 1:length(ndiv)
       if ~isempty(conditions) 
           nc = conditions(nd);
       else
           nc = nd;
       end
       LAN.SYNC.B{nc} = abs(CumMatdif{nd}) / length(ndiv{nd}(1):ndiv{nd}(end)) ; 
    end
else
LAN.SYNC.B = abs(CumMatdif)/N;
end
LAN.SYNC.parelec = ParElec;
end

if ifpow
    if iscell(pow)
        for nd = 1:length(ndiv)
           if ~isempty(conditions) 
               nc = conditions(nd);
           else
               nc = nd;
           end
           LAN.SYNC.pow{nc} = pow{nd} ; 
        end
    else
    LAN.SYNC.pow = pow;
    end   

end
LAN.SYNC.freq = EjeF;
LAN.SYNC.time = EjeX;

%dummy = squeeze(mean(BSYNC,1));
%figure, imagesc(EjeX, EjeF, dummy');

%Normalizing the sync matrices
%baselineSampled=unique(ceil(baseline/step));
%ZSYNC=Znorm3(BSYNC,baselineSampled,2); %Matriz de Sincronia Normalizada



fprintf('\n')





otherwise
  error(sprintf('Freq method ''%s'' is not implemented for syncrony network', cfg.freq_method));
end % switch cfg.freq_method
end % function 