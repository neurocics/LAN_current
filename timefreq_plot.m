function timefreq_plot(GLAN,cfg)
% timefreq_plot.m 
% v.1
%
% GUI para visualizar cartas tiempo frecuencia y estadistica.
%
%
%
%
% Pablo Billeke
% 28.10.2026 (PB-IA) Interactive channel selection from the N topoplot:
%                     click labels to add/remove electrodes in the ROI edit box.
%                    Add Clear all for every captured TF layer and a
%                     per-contour RGB color picker (including the primary).
%                     Capture GUI-computed NEW/NEW_ROI statistics directly
%                     in estataM; overlay up to 3 TF maps and cluster
%                     contours with one-click capture and selectable style.
%                      Fix overlay callbacks: default to an additional
%                     statistic, report unavailable or empty maps, refresh
%                     after MCC changes, and keep a maximum of 3 contours.
%                      Reuse figure windows/axes, refresh TF graphics,
%                     and overlay up to three statistical cluster contours.
% 01.06.2016 fix plot topo diff
% 14.08.2014  fix bug when comun baseline is ploted 
% 02.01.2014  fix multiple comparison correction  
% 29.08.2012  starting models compatibility!
% 14.06.2012  fix many wavelet compativility bugs  
% 04.04.2012  add getMAT for save variable with the polted data
% 15.03.2012  fix bug with base line
% 03.02.2012  fix read previus statistical computations
% 06.11.2011  find aprox time
% 10.05.2011  numbers of bin (threshold) to do cluster analisis
% 10.04.2011  Increase colormap resolution p-value
% 27.01.2011  Optimazed compuattion, 
%                      Add 'common' base line between conditions
%                      add simply smooth in no-paramitric chart (SnPM) 
%                      see [ smooth_2D.m ]
%                      
% 24.01.2011  fix no-paramitric chart (SnPM)
% 15.01.2011  Mejorando grafica, tiempos con frecuencias NaN
%
% 13.11.2010  Mejora  SnPM (statistic noparametric mapping), 
%                      Optimizando memeoria
% 27 .09.2010 
 



% --------------------------
try
iflantoolbox = evalin('caller', 'iflantoolbox');
catch
iflantoolbox = false;
end 

%---------------------------
if nargin < 2
    cfg= [];
end


% -- -------------------------------
% -- PARAMETROS DEFAULT PARA GRAFICO
% -- -------------------------------

getMAT = getcfg(cfg,'getMAT',false); % getMAT=false;
global pv_unc
pv_unc = getcfg(cfg,'pv_unc',0.05); % pv_unc = 0.05;
global stat_alpha
stat_alpha = getcfg(cfg,'stat_alpha',0.6); % atenuancion trasparente de areas no stadisticamente significativas

nthre = 10;
roi = 1;
fr = 1:length(  GLAN.timefreq.freq); %'1:45';
frt = [];
time = '';
if ischar(GLAN.suject{1})
nS = size(GLAN.suject,2);
SS = 1:nS;
elseif ischar(GLAN.suject{1}{1})
    nG = size(GLAN.suject,2);
    for gg = 1:nG
    nS{gg} = size(GLAN.suject{gg},2);
    end
    SS{gg} = 1:nS{gg};
end
%nS = size(GLAN.suject,2);
%SS = 1:nS;
n = 0; % normalizar
%cond1 = 1;
%cond2 = 2;
global condM
condM = [];
global congM
congM=[];
global difM
global tc_pc

ifstat = 0;

global pv_c
pv_c = 0.05;
%lb = [];
blc = 'i';
plb=[];
iflb = 0;
c_axis = [-10 10];
met = 'mdB';
figname = [ inputname(1) 'f' ];
global rs       % paired comparison = 'D' 
global sCOR 
sCOR = false;

% -- Ventanas
scrsz = get(0,'ScreenSize');

% -- cartas
global cartas
pc = [1 (2*scrsz(4))/6  scrsz(3)/2 (3*scrsz(4))/6];
cartas = figure('Visible','off','Position',pc,...
    'Name','Cartas','NumberTitle','off','MenuBar', 'none','CloseRequestFcn',@close_i);
% --
global cartasE
pce = [1 1  scrsz(3)/2 (1.5*scrsz(4))/6];
cartasE = figure('Visible','off','Position',pce,...
    'Name','CartasE','NumberTitle','off','MenuBar', 'none','CloseRequestFcn',@close_i);%
%
global topocond
topocond = figure('Visible','off','Name','Topoplot TF', ...
    'NumberTitle','off','MenuBar','none','CloseRequestFcn',@close_i);
%
global estata
estata = figure('Visible','off','Name','Statistical topoplot', ...
    'NumberTitle','off','MenuBar','none','CloseRequestFcn',@close_i);

global estataM
estataM = figure('Visible','off','Name','Statistical mask + cluster contours', ...
    'NumberTitle','off','MenuBar','none','CloseRequestFcn',@close_i);
% estataM: preserve snapshots of up to 3 GUI-computed statistics.
% This supports precomputed GLAN stats AND NEW / NEW_ROI results generated
% by lan_nonparametric inside cartas_button_Callback.
maskAxes = [];
maskColorbar = [];
clusterFigure = [];
maskLayers = struct('key',{},'label',{},'style',{},'color',{},'freq',{}, ...
    'time',{},'colorData',{},'boundary',{},'mode',{});
maskPending = []; % latest GUI calculation; not stored in GLAN
maskStylePopup = [];
maskColorButton = [];
maskColorChoice = [0 0 0];
maskColorUserSelected = false;
maskOverlayLabel = [];
maskStatusLabel = [];
maskAddButton = [];
maskRemoveButton = [];
maskClearButton = [];
maskClearAllButton = [];
maskAlpha = getcfg(cfg,'mask_background_alpha',0.20);
maskAlpha = max(0,min(1,maskAlpha));
% Figure and graphics handles for the interactive electrode map (N).
% These belong to this GUI instance and are not shared through globals.
roiTopoFigure = [];
roiTopoAxes = [];
roiTopoLabels = {};
roiTopoSelectedText = [];
% Captured maps keep their own frequency/time coordinates and ROI.
% A newly computed contrast is NOT used to overwrite earlier layers.

%
pcc =[1 5*(scrsz(4)/6) scrsz(3) scrsz(4)/6];
global controles
controles = figure('Position',pcc,...
    'Name',[ 'Controles en LAN v.' lanversion ],'NumberTitle','off','MenuBar', 'none');%,'Color','k');


% ----------------------------
% -- CHEQUEO DE LA MATRIZ

if ~isfield(GLAN, 'timefreq')
    disp('No existe campo timefreq')
    return
end

if ~isfield(GLAN.timefreq, 'subdata')
    disp('No hay matricez por sujetos, muchos analisis estadisticos no se van a poder realizar');
    sd = 0;
    ma_s = '(Solo Matriz grupal)';
else
    sd =1;
    ma_s = '(Matrices individuales)';
end

ds=false;
if isfield(GLAN.timefreq.cfg, 'stata')
    if ischar(GLAN.timefreq.cfg.stata) &&  (strcmp(GLAN.timefreq.cfg.stata,'glm'))
        ds =true;
    end
end
try    
ncond = length(GLAN.timefreq.cond)  ;
catch
ncond = length(GLAN.timefreq.data)  ;    
end
for cc = 1:ncond
    if ~isfield(GLAN.timefreq, 'cond')||isempty(GLAN.timefreq.cond{cc});
        namecond{cc} = [num2str(cc)  '(-empty-), ' ];
    else
        namecond{cc} = [num2str(cc) '(' GLAN.timefreq.cond{cc}  '), '];
    end
    
    
end

for ic = 1:length(GLAN.timefreq.comp)
    if size(GLAN.timefreq.comp{ic},1) ==1
      GLAN.timefreq.comp{ic}(2,:) = 1;
    end
    if  isfield(GLAN.timefreq.cfg, 'norma')  && ischar(GLAN.timefreq.cfg.norma)
       norma{ic} = GLAN.timefreq.cfg.norma;
       GLAN.timefreq.cfg.norma  = [];
       GLAN.timefreq.cfg.norma = norma;
    elseif ~isfield(GLAN.timefreq.cfg, 'norma') || length(GLAN.timefreq.cfg.norma)<ic || isempty(GLAN.timefreq.cfg.norma{ic})
      GLAN.timefreq.cfg.norma{ic} = ' ';  
    end
    if ~isfield(GLAN.timefreq.cfg, 'bl') || length(GLAN.timefreq.cfg.bl)<ic || length(GLAN.timefreq.cfg.bl{ic})<2
      GLAN.timefreq.cfg.bl{ic} = [0 0];
      GLAN.timefreq.cfg.norma{ic} = ' '; 
    end
end





COMP_CONTROL






% ---
comp = GLAN.timefreq.comp;
for cm = 1:length(comp)
    try
        compname{cm} = GLAN.timefreq.compname{cm};
    catch
        compname{cm} = num2str(cm);
        GLAN.timefreq.compname{cm} = compname{cm};
    end
end
compname{cm+1} = 'NEW_ROI';
compname{cm+2} = 'NEW';

% -- ---------------
% -- GUI: CONTROL
%
% botones
if iflantoolbox, paso='Back'; else paso = 'Close'; end
uicontrol('Style','pushbutton','String',paso,'Units','normalized',...
          'Position',[0.9, 0 ,0.05,0.2],... 'BackgroundColor',cf,... 'ForegroundColor',fc,...
         'Callback',{@close_button_Callback});
uicontrol('Style','pushbutton','String','pdf','Units','normalized',...
          'Position',[0.95, 0 ,0.05,0.2],... 'BackgroundColor',cf,... 'ForegroundColor',fc,...
         'Callback',{@pdf_button_Callback});     
     
uicontrol('Style','pushbutton','String','Cartas','Units','normalized',...
          'Position',[0.9, 0.25 ,0.1,0.2],... 'BackgroundColor',cf,... 'ForegroundColor',fc,...
         'Callback',{@cartas_button_Callback});     
uicontrol('Style','pushbutton','String','Topoplot','Units','normalized',...
          'Position',[0.9, 0.5 ,0.08,0.2],... 'BackgroundColor',cf,... 'ForegroundColor',fc,...
         'Callback',{@topo_button_Callback});  
uicontrol('Style','pushbutton','String','N','Units','normalized',...
          'Position',[0.98, 0.5 ,0.02,0.2],... 'BackgroundColor',cf,... 'ForegroundColor',fc,...
         'Callback',{@topo_button_Callback});       
uicontrol('Style','pushbutton','String','Topoplot(p-val)','Units','normalized',...
          'Position',[0.9, 0.75 ,0.1,0.2],... 'BackgroundColor',cf,... 'ForegroundColor',fc,...
         'Callback',{@estata_button_Callback});   
 %    
 % ---- PANEL info---
        if iscell(nS)
            paso = 'Sujetos';
            for gg = 1:nG
                paso = [paso ' (' num2str(nS{gg})  ') '];
            end
            paso = [paso  ma_s ];
        else
        paso = ['Sujetos: ' num2str(nS) '   '  ma_s ];
        end
        pa_inf = uipanel('Title','Info','Units','normalized','Position',[0.65, 0 ,0.25,1]);
        uicontrol('Parent',pa_inf,'Units','normalized','Style','text','String',paso,...
            'Position',[0,0.85,1,0.15]...%'BackgroundColor',cf,'ForegroundColor',fc
            );
        for gg = 1:size(GLAN.timefreq.cond,1)
        uicontrol('Parent',pa_inf,'Units','normalized','Style','text','String', [ ' C:  '  cat(2,namecond{gg,:}) ],...
            'Position',[0,0.85-(0.20*gg),1,0.2]...%'BackgroundColor',cf,'ForegroundColor',fc
            );
        end
%  pa_inf = uipanel('Title','Info','Units','normalized','Position',[0.65, 0 ,0.25,1]);
%  uicontrol('Parent',pa_inf,'Units','normalized','Style','text','String',['Sujetos: ' num2str(nS) '   '  ma_s ],...
%           'Position',[0,0.85,1,0.15]...%'BackgroundColor',cf,'ForegroundColor',fc
%            );
%   uicontrol('Parent',pa_inf,'Units','normalized','Style','text','String', [ ' Condiciones:  '  cat(2,namecond{:}) ],...
%           'Position',[0,0.45,1,0.4]...%'BackgroundColor',cf,'ForegroundColor',fc
%            );      

%----PANEL 1----
%---- condiciones

pa1 = uipanel('Title','Condiciones (numero, ver info->)','Units','normalized','Position',[0, 0.1 ,0.2,0.9]);

uicontrol('Parent',pa1 ,'Units','normalized','Style','text','String','Stat',...
          'Position',[0,0.7,0.25,0.2]...%'BackgroundColor',cf,'ForegroundColor',fc
           );
global STA       
STA =  uicontrol('Parent',pa1 ,'Units','normalized','Style','popupmenu','String',compname,...
          'Position',[0.25,0.7,0.75,0.2],'Callback',{ @STA_fun } ...%'BackgroundColor',cf,'ForegroundColor',fc
           );       

% %----matrices cond 
global GUIC
uicontrol('Parent',pa1 ,'Units','normalized','Style','text','String','Cond:',...
          'Position',[0,0.45,0.2,0.2]...%'BackgroundColor',cf,'ForegroundColor',fc
           );
GUIC =uicontrol('Parent',pa1 ,'Units','normalized','Style','edit',...
           'String', vec2str(GLAN.timefreq.comp{1}(1,:)) ,...opciones{pp,1},...
           'Position',[0.2,0.45,0.4,0.3],...'BackgroundColor',cf,...'ForegroundColor',fc,...
           'Callback',{ @condMat } );
       
uicontrol('Parent',pa1 ,'Units','normalized','Style','text','String','sample',...
          'Position',[0.6,0.45,0.15,0.2]...%'BackgroundColor',cf,'ForegroundColor',fc
           );
       
       global GUIS
       
GUIS =uicontrol('Parent',pa1 ,'Units','normalized','Style','popupmenu',...
           'String', {'D' , 'I'} ,...opciones{pp,1},...
           'Position',[0.75,0.45,0.25,0.2],...'BackgroundColor',cf,...'ForegroundColor',fc,...
           'Callback',{ @GUI_s } );  
       
uicontrol('Parent',pa1 ,'Units','normalized','Style','text','String','MCC',...
          'Position',[0.6,0.21,0.15,0.2]...%'BackgroundColor',cf,'ForegroundColor',fc
           );      
uicontrol('Parent',pa1 ,'Units','normalized','Style','popupmenu',...
           'String', {'unC' , 'Corr'} ,...opciones{pp,1},...
           'Position',[0.75,0.21,0.25,0.2],...'BackgroundColor',cf,...'ForegroundColor',fc,...
           'Callback',{ @GUI_s } );       
              
uicontrol('Parent',pa1 ,'Units','normalized','Style','text','String','Group:',...
          'Position',[0,0.2,0.2,0.2]...%'BackgroundColor',cf,'ForegroundColor',fc
           );
global GUIG       
GUIG = uicontrol('Parent',pa1 ,'Units','normalized','Style','edit',...
           'String', vec2str(GLAN.timefreq.comp{1}(2,:)) ,...opciones{pp,1},...
           'Position',[0.2,0.2,0.4,0.3],...'BackgroundColor',cf,...'ForegroundColor',fc,...
           'Callback',{ @contMat } );



%---- Caxis STata
%pa1 = uipanel('Title','Conciciones','Units','normalized','Position',[0, 0.7 ,0.2,1]);
uicontrol('Units','normalized','Style','text','String','C Axis:',...
          'Position',[0,0,0.05,0.2]...%'BackgroundColor',cf,'ForegroundColor',fc
           );
uicontrol('Units','normalized','Style','edit',...
           'String', '[-10 10]' ,...opciones{pp,1},...
           'Position',[0.05,0,0.05,0.3],...'BackgroundColor',cf,...'ForegroundColor',fc,...
           'Callback',{ @c_axis_Call } ); 
       
uicontrol('Units','normalized','Style','text','String','Stat:(#thr)',...
          'Position',[0.1,0,0.05,0.2]...%'BackgroundColor',cf,'ForegroundColor',fc
           );
GUIstat = uicontrol('Units','normalized','Style','edit',...
           'String', ifstat ,...opciones{pp,1},...
           'Position',[0.15,0,0.05,0.3],...'BackgroundColor',cf,...'ForegroundColor',fc,...
           'Callback',{ @condicion_tres } );   

%----- PANEL 2 -a     
%%%%% Electrodos  
global GUIroi
pa_elec = uipanel('Title','Electrodos (Numero)','Units','normalized','Position',[0.205, 0.7 ,0.1,0.29]);
GUIroi = uicontrol('Parent',pa_elec,'Style','edit','Units','normalized',...
           'String', num2str(roi) ,...opciones{pp,1},...
           'Position',[0,0,1,1],...'BackgroundColor',cf,...'ForegroundColor',fc,...
           'Callback',{ @electrode_Callback} );

%----- PANEL 2 -b    
%%%%% Fecuencias  
pa_fr = uipanel('Title','Frecuencias (Hz)','Units','normalized','Position',[0.305, 0.7 ,0.1,0.29]);
uicontrol('Parent',pa_fr,'Style','edit','Units','normalized',...
           'String', [num2str(GLAN.timefreq.freq(1)) ':' num2str(GLAN.timefreq.freq(end)) ] ,...opciones{pp,1},...
           'Position',[0,0,1,1],...'BackgroundColor',cf,...'ForegroundColor',fc,...
           'Callback',{ @fr_Callback} );
%%%%% linea de base

pa_lb = uipanel('Title','Line de base (s)','Units','normalized','Position',[0.205, 0.45 ,0.15,0.29]);
GUIbl = uicontrol('Parent',pa_lb,'Style','edit','Units','normalized',...
           'String', vec2str(GLAN.timefreq.cfg.bl{1}) ,...opciones{pp,1},...
           'Position',[0,0,0.66,1],...'BackgroundColor',cf,...'ForegroundColor',fc,...
           'Callback',{ @lb_Callback} );
            % lb_Callback(GUIbl)       
uicontrol('Parent',pa_lb,'Style','checkbox','Units','normalized',...
           'String', 'comun' ,...opciones{pp,1},...
           'Position',[0.66,0,0.33,1],...'BackgroundColor',cf,...'ForegroundColor',fc,...
           'Callback',{ @comun_Callback} );
%----- PANEL 2 -c    
%%%%% Normal
pa_nor = uipanel('Title','Normalizacion','Units','normalized','Position',[0.21, 0.05 ,0.3,0.29]);
GUImdB = uicontrol('Parent',pa_nor,'Style','checkbox','Units','normalized',...
           'String', 'mdB' ,...opciones{pp,1},...
           'Position',[0,0,0.25,1],...'BackgroundColor',cf,...'ForegroundColor',fc,...
           'Callback',{ @nor_Callback} );
GUIz = uicontrol('Parent',pa_nor,'Style','checkbox','Units','normalized',...
           'String', 'z' ,...opciones{pp,1},...
           'Position',[0.25,0,0.3,1],...'BackgroundColor',cf,...'ForegroundColor',fc,...
           'Callback',{ @nor_Callback} );       

%----- PANEL 2 -c    
%%%%% topoplot
pa_tp = uipanel('Title','Topoplot','Units','normalized','Position',[0.41, 0.05 ,0.15,0.95]);
%pa_tp_t = uipanel('Parent',pa_tp,'Title','Time','Units','normalized','Position',[0.1, 0.6,0.89,0.4]);
uicontrol('Parent',pa_tp,'Style','edit','Units','normalized',...
           'String', time ,...opciones{pp,1},...
           'Position',[0.28,0.7,0.7,0.3],...'BackgroundColor',cf,...'ForegroundColor',fc,...
           'Callback',{ @time_Callback} );
 uicontrol('Parent',pa_tp,'Style','text','Units','normalized',...
           'String', 'Time (s)' ,...opciones{pp,1},...
           'Position',[0.019,0.7,0.27,0.22]...'BackgroundColor',cf,...'ForegroundColor',fc,...
           );  
 uicontrol('Parent',pa_tp,'Style','edit','Units','normalized',...
           'String', frt ,...opciones{pp,1},...
           'Position',[0.28,0.45,0.7,0.3],...'BackgroundColor',cf,...'ForegroundColor',fc,...
           'Callback',{ @fr_tp_Callback} );
 uicontrol('Parent',pa_tp,'Style','text','Units','normalized',...
           'String', 'Freq (Hz)' ,...opciones{pp,1},...
           'Position',[0.005,0.45,0.3,0.22]...'BackgroundColor',cf,...'ForegroundColor',fc,...
           );        
%       
GUIgetMAT = uicontrol('Style','checkbox','Units','normalized',...
           'String', 'getMAT' ,...opciones{pp,1},...
           'Position',[0.57,0,0.06,0.1],...'BackgroundColor',cf,...'ForegroundColor',fc,...
           'Callback',{ @nor_Callback} );       
%logo = uipanel('Title','Topoplot','Units','normalized','Position',[0.51, 0.05 ,0.15,0.95]);    
%
 uicontrol('Style','text','Units','normalized','BackgroundColor',[0.8 0.8 0.8],...
           'String', lanversion('l') ,...opciones{pp,1},...
           'Position',[0.57,0.8,0.06,0.1]...'BackgroundColor',cf,...'ForegroundColor',fc,...
           ); 
  uicontrol('Style','text','Units','normalized','BackgroundColor',[0.8 0.8 0.8],...
           'String', 'toolbox' ,...opciones{pp,1},...
           'Position',[0.57,0.7,0.06,0.1]...'BackgroundColor',cf,...'ForegroundColor',fc,...
           );       
       
 uicontrol('Style','text','Units','normalized','BackgroundColor',[0.8 0.8 0.8],...
           'String', 'version' ,...opciones{pp,1},...
           'Position',[0.57,0.5,0.06,0.1]...'BackgroundColor',cf,...'ForegroundColor',fc,...
           ); 
 uicontrol('Style','text','Units','normalized','BackgroundColor',[0.8 0.8 0.8],...
           'String', lanversion ,...opciones{pp,1},...
           'Position',[0.57,0.4,0.06,0.1]...'BackgroundColor',cf,...'ForegroundColor',fc,...
           ); 



%%%%%% ----------------------
%%%%%% Sub-funciones de GUI

function sv = vec2str(vecc)
    sv = '[ ';
    for nv = 1:length(vecc)
        sv = [sv ' ' mat2str(vecc(nv))  ];
    end
    sv = [ sv ' ] '];
end


    function GUI_s(source,eventdata)
        stre = get(source, 'String');
        val = get(source, 'Value');
        switch stre{val}
            case {'I'}
                rs = 'i';
            case {'D'}
                rs = 'd';
            case {'Corr'}
                sCOR = true;
                mask_status('MCC mode changed. Click Add current to calculate and capture the new mask.');
            case {'unC'}
                sCOR = false;
                mask_status('MCC mode changed. Click Add current to calculate and capture the new mask.');      
        end
    end



    function STA_fun(source,eventdata)
        stre = get(source, 'String');
        val = get(source, 'Value');
        disp(['setting ' stre{val} ' stat'])
        switch stre{val}
            case {'NEW' }
                set(GUIC,'String','put  condicions')
                set(GUIG,'String','put  groups')
                set(GUIC,'BackgroundColor' ,[1 0 0])
                set(GUIG,'BackgroundColor' ,[1 0 0])
            case  'NEW_ROI'
                set(GUIroi,'String','put  new roi')
                set(GUIroi,'BackgroundColor' ,[1 0 0]) %''ForegroundColor'
            otherwise
                set(GUIC,'String',vec2str(GLAN.timefreq.comp{val}(1,:)) )
                condMat(GUIC)
                %condM = GLAN.timefreq.comp{val}(1,:);
                set(GUIG,'String',vec2str(GLAN.timefreq.comp{val}(2,:)) )
                %congM = GLAN.timefreq.comp{val}(2,:);
                contMat(GUIG)
                set(GUIbl,'String',vec2str(GLAN.timefreq.cfg.bl{val}(:))) 
                lb_Callback(GUIbl)
                nor_Callback(GLAN.timefreq.cfg.norma{val})
                if~iscell(GLAN.timefreq.cfg.s)
                   s{val}=GLAN.timefreq.cfg.s;
                   GLAN.timefreq.cfg.s = [];
                   GLAN.timefreq.cfg.s=s;  
                end
                if GLAN.timefreq.cfg.s{val}=='i' %|| 
                   nv = 2;
                else
                    nv=1;
                end
                set(GUIS,'Value',nv)
                GUI_s(GUIS);
        end
    end

function condicion_tres(source,eventdata) 
          stre = get(source, 'String');
          ifstat = eval(['[' stre ']' ]);
          
          if numel(ifstat)>2
             pv_c = ifstat(3);
          else
             pv_c = 0.05; 
          end
          
          if numel(ifstat)>1
             pv_unc = ifstat(2);
          else
             pv_unc = 0.05; 
          end
            
          if  ifstat(1) >= 1
              nthre = ifstat;
              ifstat = 1;
          end

          
          %hold off;
end
function condMat(source,eventdata) 
          stre = get(source, 'String');
          condM = abs(eval(['[' stre ']' ]));
          difM = sign(eval(['[' stre ']' ]));
          set(GUIC,'BackgroundColor' ,[0.702 0.702 0.702])
end
function contMat(source,eventdata) 
          stre = get(source, 'String');
          congM = eval(['[' stre ']' ]);
          
          set(GUIG,'BackgroundColor' ,[0.702 0.702 0.702])
end



function electrode_Callback(source,eventdata) 
          stre = get(source, 'String');
          roi = evalin('base',['[' stre ']' ]);
          set(GUIroi,'BackgroundColor' ,[0.702 0.702 0.702])
          % Keep the N electrode window synchronized with manual ROI edits.
          if ~isempty(roiTopoFigure) && ishghandle(roiTopoFigure,'figure')
              roi_topo_update_labels();
          end
          %get(GUIroi,'BackgroundColor' )
          %hold off;
end
function fr_Callback(source,eventdata) 
          stre = get(source, 'String');
          fr = eval(['[' stre ']' ]);
          fr(1) = find_approx(GLAN.timefreq.freq,fr(1));
          fr(end) = find_approx(GLAN.timefreq.freq,fr(end));
          fr = fr(1):fr(end);
          %hold off;
end
function fr_tp_Callback(source,eventdata) 
          stre = get(source, 'String');
          frt = eval(['[' stre ']' ]);
          frt(1) = find_approx(GLAN.timefreq.freq,frt(1));
          frt(end) = find_approx(GLAN.timefreq.freq,frt(end));
          frt = frt(1):frt(end);
          %hold off;
end
function c_axis_Call(source,eventdata) 
          stre = get(source, 'String');
          c_axis = eval(['[' stre ']' ]);
          %hold off;
end

function lb_Callback(source,eventdata)
          if n
          stre = get(source, 'String');
          lb = eval(['[' stre ']' ]);
          if isempty(lb), iflb = 0; elseif length(lb)==2, iflb = 1; end 
          plb(1) = find_approx(GLAN.timefreq.time,lb(1));
          plb(2) = find_approx(GLAN.timefreq.time,lb(2));
          disp(['Linea de base asignada: ' num2str(GLAN.timefreq.time(plb(1))) ' a ' num2str(GLAN.timefreq.time(plb(2))) ' segundos '])
          end
end

    function comun_Callback(hObject, eventdata, handles)
     if get(hObject,'Value')==1
         blc='c';
         disp(['Line de base comun']);
    else
         blc='i';
         disp(['Line de base independiente']);
    end
    end

function time_Callback(source,eventdata) 
          stre = get(source, 'String');
          time = eval(['[' stre ']' ]);
          time(1) = find_approx(GLAN.timefreq.time,time(1));
          time(2) = find_approx(GLAN.timefreq.time,time(2));
          disp(['tiempo topoplot asignado: ' num2str(GLAN.timefreq.time(time(1))) ' a ' num2str(GLAN.timefreq.time(time(2))) ' segundos '])
          time = time(1):time(2);
          %hold off;
end

function nor_Callback(hObject, eventdata, handles)
    
    if isstr(hObject)
       caso =  hObject;
       sigo = true;
    elseif (get(hObject,'Value') == get(hObject,'Max'))
       caso = get(hObject,'String');
       sigo = true;
    else
        sigo = false;
        caso = get(hObject,'String');
    end
    
    
    n = true;
    switch caso
        case  'mdB' 
            if sigo
            met = 'mdB';
            set(GUImdB,'Value',1)
            set(GUIz,'Value',0)            
            end
        case 'z'
            if sigo
            met  = 'z';
            set(GUImdB,'Value',0)
            set(GUIz,'Value',1)
            end
        case 'getMAT'
            getMAT = get(hObject,'Value');
            if getMAT, disp('getMAT'); end
            sigo = true;
        otherwise
            met = '';
            n = false;
            set(GUImdB,'Value',0)
            set(GUIz,'Value',0)            
    end
    if ~sigo
    n = false;
    end
    %met = 'm'
    %end

end



%------------------------------------------
%------------------------------------------
%------------- CARTAS ----------------------
%------------------------------------------
%------------------------------------------
function cartas_button_Callback(source,eventdata) 
  
    COMP_CARTAS
        %
       editF({'E','S','C','X','Y','Jet','i'});   
    % check base line
    lb_Callback(GUIbl)  
    
    if ischar(fr), eval([ 'fr = [' fr '];' ]); end
    if ischar(roi),eval([ 'roi = [' roi '];' ]); end
   clear ndata nndata
   
     for nc = 1:length(condM)
         if sd  %&& ~sd
         ndata{nc} = nanmean(GLAN.timefreq.subdata{congM(nc),condM(nc)}(fr,roi,:,:),2);
         %nndata =mean( GLAN.timefreq.subdata{cond2}(fr,roi,:,:),2);
         else
         ndata{nc} = nanmean(GLAN.timefreq.data{congM(nc),condM(nc)}(fr,roi,:,:),2);
         %nndata =mean( GLAN.timefreq.data{cond2}(fr,roi,:,:),2);   
         end
     end  
 if n  %0% 
   for  nc = 1:length(condM) 
   for ss = 1:size(ndata{nc},4)
       if strcmp(blc,'i')
         ndatan{nc}(:,:,:,ss) = normal_z(ndata{nc}(:,:,:,ss),ndata{nc}(:,:,plb(1):plb(2),ss),met);
       elseif strcmp(blc,'c') % 'c'
       ndatan{nc}(:,:,:,ss) = normal_z(ndata{nc}(:,:,:,ss), ...
                               (ndata{2}(:,:,plb(1):plb(2),ss) + ndata{1}(:,:,plb(1):plb(2),ss)  )./2 ... %FIXME!!!
                               ,met);
       else
           error('asc')
      end
   end
   end
 else
   ndatan = ndata;
   %nndatan = nndata; 
 end 
 
 
 stav = get(STA,'Value');
 stas = get(STA,'String');

 if stav < length(stas(:)')-1
     staOK = true;
 else
     staOK = false;
 end
 
 if ifstat>0
         if staOK&&isfield(GLAN.timefreq,'hhc')&&sCOR
             
           
             
             hhc = GLAN.timefreq.hhc{stav};
             try hhc = GLAN.timefreq.pvalc{stav} <= pv_c;end
             hh = GLAN.timefreq.hh{stav};
             pval = GLAN.timefreq.pval{stav};
             pvalc = GLAN.timefreq.pvalc{stav};
             pvalc_d = GLAN.timefreq.pvalc_d{stav};
             clusig = GLAN.timefreq.clusig{stav};
             currentStat = GLAN.timefreq.stat{stav};
             if isstruct(currentStat)
                 if isfield(currentStat,'t')
                     rval = currentStat.t;
                 else
                     fieldsStat = fieldnames(currentStat);
                     rval = currentStat.(fieldsStat{1});
                 end
             else
                 rval = currentStat;
             end
             
             
             %rval(rval>0.1) = 0.1 ;
             %rval((squeeze(hh)==1)&(squeeze(hhc)==0)&(rval<0.06)) = 0.06;
             %rval((squeeze(hh)==1)&(squeeze(hhc)==0)&(rval>0.14)) = 0.14             
             rval = squeeze(rval(fr,roi,:));
             hhc = squeeze(max(hhc(fr,roi,:),[],2));
             hh = squeeze(max(hh(fr,roi,:),[],2));
             
             pvalc = squeeze((pvalc(fr,roi,:)));
             clusig = squeeze((clusig(fr,roi,:)));
             pvalc_d = squeeze((pvalc_d(fr,roi,:)));
             
             for c_ = (unique(clusig(logical(pvalc<0.2))))';
                 pv = pvalc(clusig==c_);p_d = pvalc_d(clusig==c_);
                 pv = unique(pv(:));p_d = unique(p_d(~isnan(p_d(:))));
                 
                 if pv<0.1
             disp([ 'Cluster ' num2str(c_) '  p: '  num2str(pv)  ...
             '  p_d: '  num2str(p_d)...    
             ]);
                 end
             end
             
              %pvalc = squeeze(min(pvalc_d(:,:,:),[],2));
             
         elseif staOK&&isfield(GLAN.timefreq,'hh')&&~sCOR % ---------------------------------------------------------------------------------------
             
             % Use the selected statistical comparison (stav) for all
             % model types. Indexing by condM(1) selects a condition,
             % not necessarily the corresponding GLAN.timefreq.stat entry.
             currentStat = GLAN.timefreq.stat{stav};
             if isstruct(currentStat)
                 if isfield(currentStat,'t')
                     rval = currentStat.t;
                 else
                     fieldsStat = fieldnames(currentStat);
                     rval = currentStat.(fieldsStat{1});
                 end
             else
                 rval = currentStat;
             end
             rval = squeeze(rval(fr,roi,:));
             hh = GLAN.timefreq.hh{stav};
             pval = GLAN.timefreq.pval{stav};
             %
            
            % if length(nthre)==2, calfa=nthre(2); else calfa=0.05; end 
            [hhc pvalc cluster ] = cl_random_2d((pval(fr,roi,:)<=pv_unc),...
                                   -log10(pval(fr,roi,:)),...
                                    pv_c,10000,nthre(1));
            % 
            %[hhc pvalc cluster ] = cl_random_2d(hh(fr,roi,:),-log10(pval(fr,roi,:)),calfa,10000,nthre(1));
            %rval = squeeze(rval(fr,roi,:));
            %rval((squeeze(hh(fr,roi,:))==1)&(squeeze(hhc)==0)&(rval<0.06)) = 0.06;
            %rval((squeeze(hh(fr,roi,:))==1)&(squeeze(hhc)==0)&(rval>0.14)) = 0.14;
            disp('significant p-val clusters levels');
            disp(unique(pvalc(logical(hhc))));
            
            %rval = rval);
            
         else
          if ~isfield(GLAN.timefreq,'hhc')
              disp('Statistical correction not pre-calculated')
              set(STA,'Value',length(stas)-1);
              set(GUIroi,'String',vec2str(roi));
          end
          if length(ndata)==2   
            difftemp = nanmean(ndatan{1},4)-nanmean(ndatan{2},4); %FIXME!!!! 
            diffok = true;
          elseif any(difM<0)
              clear difftemp
              for c = 1:length(difM)                  
                   difftemp{c} =  ndatan{c} .* difM(c);
              end
              difftemp = sum(cat(5,difftemp{:}),5); %FIXME!!!! 
          else
              diffok = false;
          end
          
            Pcfg.method  = 'rank';                                      
            Pcfg.paired =  strcmp(rs,'d'); 
          

            [pval stats] = lan_nonparametric(ndatan,Pcfg);
            %[pval, hh, stat,rval] = nonparametric(ndatan,0.05,rs);
            hh = (pval<pv_unc); 
            paso = fields(stats);
            rval = eval(['stats.' paso{1} ';']);% valor del estadistico;
            %try mcc = evalin('base','if_mcc'); catch  mcc = true; end
                
        if sCOR 
            [hhc pvalc cluster ] = cl_random_2d((pval<=pv_unc),...
                                   -log10(pval),...
                                    pv_c,10000,nthre(1));
            

         disp('significant p-val clusters levels');
         disp(unique(pvalc(logical(hhc))));
        else
           hhc = hh ;
        end
         rval = squeeze(rval);
         end
 end

 for nc = 1:length(ndatan)
data1{nc} =  (nanmean(ndatan{nc},4) );
data1{nc} = squeeze(nanmean(data1{nc},2)); % promedio electrodos
 end
%data2 =  (mean(nndatan,4) );
clear ndata* nndata*


%data2 = squeeze(mean(data2,2));
try

end
if nc ==2
    ntc=nc+1;
    data3 = ((data1{1}-data1{2})) ;%FIXME!!! .* squeeze(hhc)
    data3(data3==0)=NaN;
else
    ntc=nc;
    data3 = data1{1};
end
 
figure(cartas),
pp = 1;
for nc=1:length(condM)
subplot(2*ntc,1,pp:pp+1,'align','Parent',cartas),
pp = pp+2;
pcolor(gca,GLAN.timefreq.time, GLAN.timefreq.freq(fr), double(data1{nc}));
caxis(gca,c_axis); shading(gca,'interp');
set(gca,'xtick',[])
try 
    title([' Cond: ' GLAN.timefreq.cond{condM(nc)} ', Channels: ' cell2mat({GLAN.chanlocs(roi).labels}) ' ('  num2str(roi) ')'  ] )
end
axcopy_lan;
end
if ntc>nc
subplot(6,1,5:6,'align','Parent',cartas)
pcolor(gca,GLAN.timefreq.time,GLAN.timefreq.freq(fr), double(data3));
caxis(gca,c_axis/2); shading(gca,'interp');
try
    title([' Cond: ' GLAN.timefreq.cond{condM(1)} '-' GLAN.timefreq.cond{condM(2)} ] )
end
axcopy_lan;
end
if ifstat>0
cartasE = ensure_plot_figure(cartasE,'CartasE',pce);
clf(cartasE);
set(cartasE,'Visible','on');
figure(cartasE);
        editF({'E','S','C','X','Y','Jet','i'}); 
        
 % Reduce p-values and significance masks to frequency x time.
 % Multi-electrode ROIs use mean p-values for the background (legacy),
 % and the minimum p-value wherever any selected electrode is significant.
 if ndims(pval) >= 3 & size(pval,2)>1
     tmp_p = pval(fr,roi,:);
     ppval = reshape(nanmean(tmp_p,2),numel(fr),[]);
     ppval_min = reshape(nanmin(tmp_p,[],2),numel(fr),[]);
 else
     ppval = pval(fr,:);
     ppval_min = ppval;
 end
 sigMask = mask_to_ft(hhc,fr,roi);
 if ~isequal(size(sigMask),size(ppval))
     error('timefreq_plot:MaskDimensions', ...
         'Statistical mask and p-values differ in time/frequency dimensions.');
 end
 if nthre(1)>1 && exist('bwlabeln','file')==2
     clR = bwlabeln(sigMask);
     for nrr = 1:max(clR(:))
         if nnz(clR==nrr) <= nthre(1)
             sigMask(clR==nrr) = false;
         end
     end
 end
 ppval(sigMask) = ppval_min(sigMask);
%-----
try
    MASK = evalin('base','pval_mask');
    disp('Using base WS variable pval_mask')
catch
    MASK=pv_unc+0.01;
end
%-----
ppval(~sigMask & (ppval<MASK)) = MASK;
ssg = sign(rval); 
axP = axes('Parent',cartasE,'Position',[0.10 0.12 0.82 0.80]);
pcolor(axP,GLAN.timefreq.time, GLAN.timefreq.freq(fr), -log10(double(ppval)));
a = ppval(~isnan(ppval)&(ppval~=0));
if isempty(a), a = pv_unc; end
a = -log10(max(min(a(:)),realmin));
axes(axP);
colormaplan('logP',100,pv_unc,1,a);
%caxis([0,0.2]);
shading(axP,'flat');
set(cartas,'Visible','on');

% Statistical opacity window: retain the original heatmap and add
% thresholded cluster boundaries. The overlay UI lives in this figure.
Hp = single(ppval <= pv_unc);
Hp(~isfinite(ppval)) = 0;
if exist('lan_smooth','file') == 2
    Hp = lan_smooth(Hp);
end
% Keep the legacy smooth opacity rendering separate from boundaries.
% Contours must follow the actual statistical mask, not its smoothed edges.
primaryMask = logical(sigMask);
draw_mask_window(data3,primaryMask,stav,fr,roi);

if isfield(GLAN.timefreq,'clusig') && exist('clusig','var') && ...
        exist('pvalc','var')
    % Preserve the legacy auxiliary cluster-ID figure, but do not let
    % it become the target for subsequent EEG/TF plotting.
    if isempty(clusterFigure) || ~ishghandle(clusterFigure,'figure')
        clusterFigure = figure('Name','Clusters', ...
            'NumberTitle','off','Tag','LAN_TF_Clusters');
    else
        clf(clusterFigure);
    end
    clusterAxes = axes('Parent',clusterFigure);
    clusterData = clusig;
    if isequal(size(clusterData),size(pvalc))
        clusterData(pvalc>pv_c)=0;
    end
    if ndims(clusterData) == 3 && size(clusterData,2)>1
        clusterData = squeeze(max(clusterData,[],2));
    else
        clusterData = squeeze(clusterData);
    end
    if isequal(size(clusterData),[numel(fr),numel(GLAN.timefreq.time)])
        pcolor(clusterAxes,GLAN.timefreq.time,GLAN.timefreq.freq(fr),clusterData);
        shading(clusterAxes,'flat');
    end
end

%end


%axcopy_lan;
end
%disp('')
clear *data*
end


%--------------------------------------------------------------
% GUI-computed TF masks: one-click capture, maximum three contour layers.
% Statistical tests remain performed by cartas_button_Callback. The GUI
% snapshots the resulting map; GLAN itself is not modified.
%--------------------------------------------------------------
function draw_mask_window(baseData,primaryMask,statIndex,frIndex,roiIndex)
    if isempty(estataM) || ~ishghandle(estataM,'figure')
        estataM = figure('Visible','off', ...
            'Name','Statistical mask + GUI contours', ...
            'NumberTitle','off','MenuBar','none', ...
            'CloseRequestFcn',@close_i);
        maskAxes = [];
        maskColorbar = [];
        maskStylePopup = [];
        maskColorButton = [];
        maskOverlayLabel = [];
        maskStatusLabel = [];
        maskAddButton = [];
        maskRemoveButton = [];
        maskClearButton = [];
        maskClearAllButton = [];
    end
    set(estataM,'Visible','on');
    if isempty(maskAxes) || ~ishghandle(maskAxes,'axes')
        maskAxes = axes('Parent',estataM,'Units','normalized', ...
            'Position',[0.10 0.255 0.77 0.665]);
        maskColorbar = colorbar(maskAxes,'eastoutside');
        % One-time creation; never add controls to whichever figure is gcf.
        create_mask_controls();
    end

    fValues = GLAN.timefreq.freq(frIndex);
    tValues = GLAN.timefreq.time;
    baseData = squeeze(double(baseData));
    primaryMask = squeeze(logical(primaryMask));
    expectedSize = [numel(fValues), numel(tValues)];
    if ~isequal(size(baseData),expectedSize) || ...
            ~isequal(size(primaryMask),expectedSize)
        mask_status('TF map and significance mask have incompatible dimensions.');
        return
    end

    names = get(STA,'String');
    selectedName = names{get(STA,'Value')};
    if strcmp(selectedName,'NEW') || strcmp(selectedName,'NEW_ROI')
        origin = ['GUI ' selectedName];
    else
        origin = selectedName;
    end
    selection = sprintf('C:%s G:%s ROI:%s', ...
        strtrim(get(GUIC,'String')),strtrim(get(GUIG,'String')), ...
        strtrim(get(GUIroi,'String')));
    mode = 'unC';
    if sCOR, mode='Corr'; end
    maskPending = struct('key',current_mask_key(), ...
        'label',[origin ' | ' selection], ...
        'style','-', 'color',maskColorChoice, ...
        'freq',fValues(:)', 'time',tValues(:)', ...
        'colorData',baseData,'boundary',primaryMask,'mode',mode);

    % Preserve color/style for a captured layer. For a newly calculated
    % statistic, offer a distinct default unless the user chose a color.
    matched = find(strcmp({maskLayers.key},maskPending.key),1);
    if ~isempty(matched)
        maskPending.color = maskLayers(matched).color;
    elseif ~maskColorUserSelected
        maskPending.color = default_mask_color(numel(maskLayers)+1);
    end
    if ~maskColorUserSelected
        maskColorChoice = maskPending.color;
        update_mask_color_swatch();
    end

    % The first successfully plotted statistic is the primary layer.
    % Later GUI changes become pending until Add current is clicked.
    if isempty(maskLayers)
        maskLayers = maskPending;
        mask_status(['Primary TF map: ' maskPending.label]);
    elseif strcmp(maskPending.key,maskLayers(end).key)
        % Recalculate current layer without creating duplicate contours.
        maskPending.style = maskLayers(end).style;
        maskPending.color = maskLayers(end).color;
        maskLayers(end) = maskPending;
        mask_status('Current GUI statistic recalculated; captured layer updated.');
    else
        found = find(strcmp({maskLayers.key},maskPending.key),1);
        if ~isempty(found)
            maskPending.style = maskLayers(found).style;
            maskPending.color = maskLayers(found).color;
            maskLayers(found) = maskPending;
            mask_status('A captured statistic was recalculated; layer updated.');
        else
            mask_status(['New map calculated: ' origin '. Choose a border style, then Add current.']);
        end
    end
    refresh_mask_overlays();
end

function create_mask_controls()
    % Captured statistics use the current GUI selection. The color picker
    % controls the new/current layer, and works without a custom toolbox.
    uicontrol('Parent',estataM,'Style','text', ...
        'Units','normalized','HorizontalAlignment','left', ...
        'String','GUI statistic: current Stat / Cond / Group / ROI', ...
        'Position',[0.10 0.205 0.79 0.035]);
    uicontrol('Parent',estataM,'Style','text', ...
        'Units','normalized','HorizontalAlignment','left', ...
        'String','Contour style', 'Position',[0.10 0.152 0.15 0.032]);
    maskStylePopup = uicontrol('Parent',estataM,'Style','popupmenu', ...
        'Units','normalized','Position',[0.25 0.145 0.17 0.054], ...
        'String',{'Solid (-)','Dashed (--)','Dotted (:)'});
    maskColorButton = uicontrol('Parent',estataM,'Style','pushbutton', ...
        'Units','normalized','String','Line color...', ...
        'Position',[0.43 0.145 0.20 0.054], ...
        'TooltipString','Choose an RGB color for the current contour.', ...
        'Callback',@mask_choose_color);
    update_mask_color_swatch();
    maskAddButton = uicontrol('Parent',estataM,'Style','pushbutton', ...
        'Units','normalized','String','Add current', ...
        'Position',[0.64 0.145 0.24 0.054], ...
        'TooltipString','Compute if needed, then add the current GUI statistic and TF map.', ...
        'Callback',@mask_add);
    maskRemoveButton = uicontrol('Parent',estataM,'Style','pushbutton', ...
        'Units','normalized','String','Remove last', ...
        'Position',[0.10 0.090 0.21 0.048], ...
        'Callback',@mask_remove);
    maskClearButton = uicontrol('Parent',estataM,'Style','pushbutton', ...
        'Units','normalized','String','Clear extras', ...
        'Position',[0.32 0.090 0.21 0.048], ...
        'Callback',@mask_clear);
    maskClearAllButton = uicontrol('Parent',estataM,'Style','pushbutton', ...
        'Units','normalized','String','Clear all', ...
        'Position',[0.54 0.090 0.21 0.048], ...
        'TooltipString','Remove ALL captured color maps and contours, including the primary.', ...
        'Callback',@mask_clear_all);
    maskOverlayLabel = uicontrol('Parent',estataM,'Style','text', ...
        'Units','normalized','HorizontalAlignment','left', ...
        'Position',[0.10 0.049 0.89 0.034],'String','');
    maskStatusLabel = uicontrol('Parent',estataM,'Style','text', ...
        'Units','normalized','HorizontalAlignment','left', ...
        'Position',[0.10 0.006 0.89 0.037],'String','');
    editF({'E','S','C','X','Y','Jet','i'});
end

function c = default_mask_color(k)
    palette = [0 0 0; 0.75 0 0.68; 0 0.48 0.22];
    c = palette(min(max(k,1),size(palette,1)),:);
end

function update_mask_color_swatch()
    if isempty(maskColorButton) || ~ishghandle(maskColorButton)
        return
    end
    % Ensure readable text for both dark and light user-selected colors.
    luminance = maskColorChoice * [0.2126; 0.7152; 0.0722];
    if luminance < 0.5
        fg = [1 1 1];
    else
        fg = [0 0 0];
    end
    set(maskColorButton,'BackgroundColor',maskColorChoice, ...
        'ForegroundColor',fg);
end

function mask_choose_color(~,~)
    % MATLAB's native RGB color picker; Cancel leaves the current color.
    chosen = uisetcolor(maskColorChoice,'Choose contour line color');
    if ~isnumeric(chosen) || numel(chosen)~=3 || ...
            any(~isfinite(chosen(:))) || any(chosen(:)<0) || any(chosen(:)>1)
        return
    end
    maskColorChoice = reshape(chosen,1,3);
    maskColorUserSelected = true;
    update_mask_color_swatch();

    % Update the currently captured GUI statistic immediately, if any.
    currentKey = current_mask_key();
    if ~isempty(maskLayers)
        ix = find(strcmp({maskLayers.key},currentKey),1);
        if ~isempty(ix)
            maskLayers(ix).color = maskColorChoice;
            if ~isempty(maskPending) && strcmp(maskPending.key,currentKey)
                maskPending.color = maskColorChoice;
            end
            refresh_mask_overlays();
            mask_status(sprintf('Contour %d color updated.',ix));
            return
        end
    end
    if ~isempty(maskPending) && strcmp(maskPending.key,currentKey)
        maskPending.color = maskColorChoice;
    end
    mask_status('Color selected. Click Add current to use it for the next contour.');
end

function mask_status(message)
    if ~isempty(maskStatusLabel) && ishghandle(maskStatusLabel)
        set(maskStatusLabel,'String',message);
    end
    fprintf('[timefreq_plot contours] %s\n',message);
end

function key = current_mask_key()
    % Read live controls: the callback must not silently capture an old
    % calculation after NEW / NEW_ROI or a threshold/ROI change.
    raw = {num2str(get(STA,'Value')),get(GUIC,'String'), ...
        get(GUIG,'String'),get(GUIroi,'String'),mat2str(fr), ...
        num2str(n),met,blc,mat2str(plb), ...
        mat2str([pv_unc,pv_c,nthre]),num2str(sCOR), ...
        num2str(ifstat)};
    key = strjoin(raw,'|');
end

function mask_add(~,~)
    % A single click can compute a NEW / NEW_ROI statistic and capture it.
    if ifstat==0
        ifstat = 1;
        if ~isempty(GUIstat) && ishghandle(GUIstat)
            set(GUIstat,'String','1');
        end
    end
    currentKey = current_mask_key();
    % Avoid an expensive 10,000-permutation GUI recomputation when full.
    if numel(maskLayers)>=3 && ~any(strcmp({maskLayers.key},currentKey))
        mask_status('Maximum 3 contours/maps. Remove last or Clear extras first.');
        return
    end
    if isempty(maskPending) || ~strcmp(maskPending.key,currentKey)
        mask_status('Calculating current GUI statistic ...');
        try
            cartas_button_Callback([],[]);
        catch ME
            mask_status(['Could not calculate GUI statistic: ' ME.message]);
            warning('timefreq_plot:LiveStat','%s',getReport(ME,'basic','hyperlinks','off'));
            return
        end
    end
    if isempty(maskPending) || ~strcmp(maskPending.key,current_mask_key())
        mask_status('Statistic could not be captured. Check Stat, Cond, Group, ROI and thresholds.');
        return
    end
    noClusters = ~any(maskPending.boundary(:));
    % Even with zero surviving clusters, keep the TF color map available.
    % No contour is drawn for an empty mask (rather than fabricating one).
    styles = {'-','--',':'};
    choice = styles{get(maskStylePopup,'Value')};
    if maskColorUserSelected
        maskPending.color = maskColorChoice;
    elseif isempty(maskLayers)
        maskPending.color = default_mask_color(1);
    end
    found = find(strcmp({maskLayers.key},maskPending.key),1);
    if isempty(found)
        if numel(maskLayers)>=3
            mask_status('Maximum 3 contours. Remove last or Clear extras first.');
            return
        end
        added = maskPending;
        added.style = choice;
        maskLayers(end+1) = added;
        mask_status(['Added TF map and contour: ' added.label]);
    else
        maskLayers(found) = maskPending;
        maskLayers(found).style = choice;
        mask_status(['Updated TF map and line style: ' maskPending.label]);
    end
    maskColorUserSelected = false;
    refresh_mask_overlays();
    if noClusters
        mask_status('TF color map captured; no points passed the contour threshold.');
    end
    if ishghandle(estataM,'figure')
        figure(estataM);
    end
end

function mask_remove(~,~)
    if numel(maskLayers)>1
        removed = maskLayers(end).label;
        maskLayers(end) = [];
        maskColorChoice = maskLayers(end).color;
        maskColorUserSelected = false;
        update_mask_color_swatch();
        refresh_mask_overlays();
        mask_status(['Removed last overlay: ' removed]);
    else
        mask_status('Only the primary contour remains.');
    end
end

function mask_clear(~,~)
    if numel(maskLayers)>1
        maskLayers = maskLayers(1);
        maskColorChoice = maskLayers(1).color;
        maskColorUserSelected = false;
        update_mask_color_swatch();
        refresh_mask_overlays();
        mask_status('All extra contours and their color maps removed.');
    else
        mask_status('No extra contours to clear.');
    end
end

function mask_clear_all(~,~)
    % Clear every captured layer (including the original color map), but
    % keep GLAN and the latest computed maskPending intact for fast re-add.
    maskLayers = maskLayers([]);
    maskColorChoice = default_mask_color(1);
    maskColorUserSelected = false;
    update_mask_color_swatch();
    if ~isempty(maskStylePopup) && ishghandle(maskStylePopup)
        set(maskStylePopup,'Value',1);
    end
    refresh_mask_overlays();
    mask_status('All contours and TF color maps cleared. Click Add current to start again.');
end

function m2 = mask_to_ft(mask,frIndex,roiIndex)
    % Convert freq x electrode x time masks to freq x time; support an ROI
    % with multiple channels without changing the underlying statistics.
    nfreq = numel(GLAN.timefreq.freq);
    if size(mask,1)==nfreq
        mask = mask(frIndex,:,:,:);
    elseif size(mask,1)~=numel(frIndex)
        error('timefreq_plot:FreqMismatch', ...
            'Map has %d frequencies, current selection has %d.', ...
            size(mask,1),numel(frIndex));
    end
    if ndims(mask)>3 && size(mask,4)>1
        error('timefreq_plot:MultipleEntries', ...
            'Map contains several model comparisons in dimension 4.');
    end
    if ndims(mask)>=3
        if size(mask,2)>1
            if size(mask,2)==numel(roiIndex)
                % Some live maps were computed AFTER selecting the ROI.
                % Do not index a second time with the original channel IDs.
            elseif max(roiIndex)<=size(mask,2)
                mask = mask(:,roiIndex,:,:);
            else
                error('timefreq_plot:ROIOutsideMap', ...
                    'Selected ROI exceeds the map electrode dimension.');
            end
        end
        m2 = reshape(any(mask~=0 & isfinite(mask),2),size(mask,1),size(mask,3));
    else
        m2 = mask~=0 & isfinite(mask);
    end
    m2 = logical(m2);
end

function refresh_mask_overlays()
    if isempty(maskAxes) || ~ishghandle(maskAxes,'axes')
        return
    end
    cla(maskAxes);
    if isempty(maskLayers)
        legend(maskAxes,'off');
        if ~isempty(maskColorbar) && ishghandle(maskColorbar)
            set(maskColorbar,'Visible','off');
        end
        set(maskAxes,'XTick',[],'YTick',[]);
        text(maskAxes,0.5,0.5,'No captured maps / contours', ...
            'Units','normalized','HorizontalAlignment','center', ...
            'VerticalAlignment','middle','FontSize',11);
        title(maskAxes,'GUI statistical contours (0 / 3)');
        if ~isempty(maskOverlayLabel) && ishghandle(maskOverlayLabel)
            set(maskOverlayLabel,'String','Captured layers: none');
        end
        if ~isempty(maskRemoveButton) && ishghandle(maskRemoveButton)
            set(maskRemoveButton,'Enable','off');
        end
        if ~isempty(maskClearButton) && ishghandle(maskClearButton)
            set(maskClearButton,'Enable','off');
        end
        if ~isempty(maskClearAllButton) && ishghandle(maskClearAllButton)
            set(maskClearAllButton,'Enable','off');
        end
        drawnow limitrate;
        return
    end
    set(maskAxes,'XTickMode','auto','YTickMode','auto');
    if ~isempty(maskColorbar) && ishghandle(maskColorbar)
        set(maskColorbar,'Visible','on');
    end
    set(maskAxes,'NextPlot','add');
    % All TF layers share c_axis (the original LAN color scale).
    % The first map remains as a translucent reference. Captured new maps
    % are drawn in color only where their own significance mask is true.
    base = maskLayers(1);
    underlay = pcolor(maskAxes,base.time,base.freq,base.colorData);
    set(underlay,'EdgeColor','none','FaceAlpha',maskAlpha);
    for k=1:numel(maskLayers)
        layer = maskLayers(k);
        if k>1
            % Preserve the map of each newly calculated contrast even when
            % no clusters survive. Significant regions remain prominent.
            faint = pcolor(maskAxes,layer.time,layer.freq,layer.colorData);
            set(faint,'EdgeColor','none','FaceAlpha',0.14);
        end
        vals = layer.colorData;
        vals(~layer.boundary) = NaN;
        if any(layer.boundary(:))
            h = pcolor(maskAxes,layer.time,layer.freq,vals);
            set(h,'EdgeColor','none','FaceAlpha',0.82);
        end
    end
    shading(maskAxes,'interp');
    caxis(maskAxes,c_axis);
    if numel(maskLayers)==1
        % Restore the LAN color scale and default viewport.
        f_all = base.freq; t_all = base.time;
    else
        f_all = [maskLayers.freq];
        t_all = [maskLayers.time];
    end
    if numel(t_all)>1 && numel(f_all)>1
        xlim(maskAxes,[min(t_all),max(t_all)]);
        ylim(maskAxes,[min(f_all),max(f_all)]);
    end
    xlabel(maskAxes,'Time (s)'); ylabel(maskAxes,'Frequency (Hz)');

    contHandles = gobjects(0);
    contLabels = {};
    for k=1:numel(maskLayers)
        layer = maskLayers(k);
        if ~any(layer.boundary(:)) || numel(layer.time)<2 || ...
                numel(layer.freq)<2
            continue
        end
        b = zeros(size(layer.boundary,1)+2,size(layer.boundary,2)+2);
        b(2:end-1,2:end-1) = double(layer.boundary);
        tPad = [layer.time(1)-(layer.time(2)-layer.time(1)), ...
                layer.time,layer.time(end)+(layer.time(end)-layer.time(end-1))];
        fPad = [layer.freq(1)-(layer.freq(2)-layer.freq(1)), ...
                layer.freq,layer.freq(end)+(layer.freq(end)-layer.freq(end-1))];
        [~,hc] = contour(maskAxes,tPad,fPad,b,[0.5 0.5], ...
            'LineColor',layer.color,'LineStyle',layer.style,'LineWidth',1.9);
        contHandles(end+1) = hc; %#ok<AGROW>
        contLabels{end+1} = sprintf('%d: %s (%s)',k, ...
            layer.label,layer.mode); %#ok<AGROW>
    end
    if ~isempty(contHandles)
        legend(maskAxes,contHandles,contLabels, ...
            'Interpreter','none','Location','northeast','FontSize',8);
    else
        legend(maskAxes,'off');
    end
    set(maskAxes,'NextPlot','replace');
    box(maskAxes,'off');
    title(maskAxes,sprintf('GUI statistical contours (%d / 3)', ...
        numel(maskLayers)));
    if ~isempty(maskOverlayLabel) && ishghandle(maskOverlayLabel)
        names = arrayfun(@(l) sprintf('%s: %s',l.mode,l.style), ...
            maskLayers,'UniformOutput',false);
        set(maskOverlayLabel,'String',['Captured layers: ' strjoin(names,'  |  ')]);
    end
    if ~isempty(maskRemoveButton) && ishghandle(maskRemoveButton)
        set(maskRemoveButton,'Enable',onoff(numel(maskLayers)>1));
    end
    if ~isempty(maskClearButton) && ishghandle(maskClearButton)
        set(maskClearButton,'Enable',onoff(numel(maskLayers)>1));
    end
    if ~isempty(maskClearAllButton) && ishghandle(maskClearAllButton)
        set(maskClearAllButton,'Enable','on');
    end
    drawnow limitrate;
end

function value = onoff(tf)
    if tf, value='on'; else, value='off'; end
end

%------------------------------------------
% Interactive ROI selection in the N electrode map.
% topoplot_lan already renders the channel labels as text objects.
% Map each text object to GLAN.chanlocs(i).labels, and attach callbacks
% directly to those labels, without changing topoplot_lan itself.
%------------------------------------------
function roi_topo_open()
    if ~isfield(GLAN,'chanlocs') || isempty(GLAN.chanlocs)
        warning('timefreq_plot:NoChanlocs', ...
            'Cannot select ROI channels: GLAN.chanlocs is missing.');
        return
    end

    % Start from the current text field, including manually typed changes.
    % NEW_ROI uses a placeholder instead of numbers: start empty in that case.
    rawROI = strtrim(get(GUIroi,'String'));
    if isempty(rawROI) || strcmpi(rawROI,'put  new roi')
        roi = [];
    else
        parsedROI = str2num(rawROI); %#ok<ST2NM>  Supports LAN expressions such as 1:8.
        if isnumeric(parsedROI) && isvector(parsedROI) && ...
                all(isfinite(parsedROI(:))) && ...
                all(parsedROI(:)==fix(parsedROI(:))) && ...
                all(parsedROI(:)>=1) && ...
                all(parsedROI(:)<=numel(GLAN.chanlocs))
            roi = unique(parsedROI(:)','stable');
        else
            warning('timefreq_plot:InvalidROI', ...
                'Invalid electrode ROI in GUI; select channels in the N map.');
            roi = [];
        end
    end

    roiTopoFigure = ensure_plot_figure(roiTopoFigure, ...
        'EEG channels - click labels to select ROI', ...
        [max(20,round(scrsz(3)*0.50)),max(40,round(scrsz(4)*0.17)), ...
         max(450,round(scrsz(3)*0.39)),max(430,round(scrsz(4)*0.65))]);
    clf(roiTopoFigure);
    set(roiTopoFigure,'Visible','on','CloseRequestFcn',@close_i, ...
        'NumberTitle','off','MenuBar','none');
    uicontrol('Parent',roiTopoFigure,'Style','text','Units','normalized', ...
        'Position',[0.05 0.94 0.90 0.045], ...
        'String','Click a channel label to add/remove it from the ROI.', ...
        'HorizontalAlignment','center');
    roiTopoSelectedText = uicontrol('Parent',roiTopoFigure, ...
        'Style','text','Units','normalized', ...
        'Position',[0.05 0.052 0.68 0.065], ...
        'HorizontalAlignment','left','String','');
    uicontrol('Parent',roiTopoFigure,'Style','pushbutton', ...
        'Units','normalized','Position',[0.77 0.055 0.18 0.065], ...
        'String','Clear ROI','Callback',@roi_topo_clear);

    roiTopoAxes = axes('Parent',roiTopoFigure, ...
        'Units','normalized','Position',[0.10 0.14 0.80 0.77]);
    axes(roiTopoAxes); %#ok<LAXES> topoplot_lan draws in the current axes.
    topoplot_lan([],GLAN.chanlocs,'style','blank', ...
        'electrodes','labelpoint');

    % Capture the actual text handles produced by topoplot_lan.  Some
    % versions of the helper change gca, so search the entire N figure.
    labels = cell(1,numel(GLAN.chanlocs));
    for iE = 1:numel(GLAN.chanlocs)
        if isfield(GLAN.chanlocs(iE),'labels') && ...
                ~isempty(GLAN.chanlocs(iE).labels)
            labels{iE} = strtrim(char(GLAN.chanlocs(iE).labels));
        else
            labels{iE} = '';
        end
    end
    roiTopoLabels = cell(size(labels));
    allText = findall(roiTopoFigure,'Type','text');
    for iT = 1:numel(allText)
        hText = allText(iT);
        txt = get(hText,'String');
        if iscell(txt)
            if numel(txt)~=1, continue; end
            txt = txt{1};
        end
        if ~(ischar(txt) || (isstring(txt) && isscalar(txt)))
            continue
        end
        txt = strtrim(char(txt));
        % EEGlab-style labelpoint text objects carry the exact channel
        % index in UserData. Prefer it when available; older LAN builds
        % may omit it, in which case match the displayed channel label.
        channelID = get(hText,'UserData');
        candidates = [];
        if isnumeric(channelID) && isscalar(channelID)
            channelID = double(channelID);
        elseif ischar(channelID) || (isstring(channelID) && isscalar(channelID))
            channelID = str2double(char(channelID));
        else
            channelID = NaN;
        end
        if isfinite(channelID) && channelID==fix(channelID) && ...
                channelID>=1 && channelID<=numel(labels)
            candidates = channelID;
        end
        if isempty(candidates)
            candidates = find(strcmpi(txt,labels));
        end
        if isempty(candidates), continue; end
        % A duplicate channel name can occur; never assign a text handle
        % to two different indices. The first unused matching label wins.
        candidates = candidates(cellfun(@isempty,roiTopoLabels(candidates)));
        if isempty(candidates), continue; end
        index = candidates(1);
        roiTopoLabels{index} = hText;
        setappdata(hText,'LAN_RoiOriginalLabel',get(hText,'String'));
        setappdata(hText,'LAN_RoiOriginalColor',get(hText,'Color'));
        setappdata(hText,'LAN_RoiOriginalWeight',get(hText,'FontWeight'));
        set(hText,'HitTest','on', ...
            'ButtonDownFcn',{@roi_topo_toggle,index});
        if isprop(hText,'PickableParts')
            set(hText,'PickableParts','all');
        end
    end
    if ~any(~cellfun(@isempty,roiTopoLabels))
        warning('timefreq_plot:TopoplotLabels', ...
            ['No channel label text objects matched GLAN.chanlocs. ' ...
             'Please provide topoplot_lan.m to adapt its graphics.']);
        set(roiTopoSelectedText,'String', ...
            'No clickable labels found; check topoplot_lan.m.');
    else
        roi_topo_update_labels();
    end
end

function roi_topo_toggle(~,~,channel)
    % Second click deselects; never duplicate an electrode number.
    if any(roi==channel)
        roi(roi==channel) = [];
    else
        roi(end+1) = channel;
    end
    roi = unique(roi,'stable');
    set(GUIroi,'String',vec2str(roi), ...
        'BackgroundColor',[0.702 0.702 0.702]);
    roi_topo_update_labels();
end

function roi_topo_clear(~,~)
    roi = [];
    set(GUIroi,'String','[]', ...
        'BackgroundColor',[0.702 0.702 0.702]);
    roi_topo_update_labels();
end

function roi_topo_update_labels()
    if isempty(roiTopoFigure) || ~ishghandle(roiTopoFigure,'figure')
        return
    end
    for iE = 1:numel(roiTopoLabels)
        hText = roiTopoLabels{iE};
        if isempty(hText) || ~ishghandle(hText,'text')
            continue
        end
        if any(roi==iE)
            set(hText,'String',num2str(iE), ...
                'Color',[0.0 0.40 0.75],'FontWeight','bold');
        else
            set(hText,'String',getappdata(hText,'LAN_RoiOriginalLabel'), ...
                'Color',getappdata(hText,'LAN_RoiOriginalColor'), ...
                'FontWeight',getappdata(hText,'LAN_RoiOriginalWeight'));
        end
    end
    if ~isempty(roiTopoSelectedText) && ishghandle(roiTopoSelectedText)
        if isempty(roi)
            info = 'ROI: []  (select a channel before plotting)';
        else
            info = ['ROI: ' mat2str(roi)];
        end
        set(roiTopoSelectedText,'String',info);
    end
    drawnow limitrate;
end

%------------------------------------------
%------------------------------------------
%------------- TOPOPLOT --------------------
%------------------------------------------
%------------------------------------------

function topo_button_Callback(source,eventdata) 
    
 if strcmp('N',get(source, 'String'))
     roi_topo_open();
     return
 end
    
freq =   frt;
tiempo = time;
%n = 1;
clear *data*

if strcmp(blc,'c')

comun = zeros(size(GLAN.timefreq.subdata{congM(1),condM(1)}(freq,:,plb(1):plb(2),:)));
comunn = 0;
end
for c  = 1:length(condM)  
ndata{congM(c),condM(c)} = GLAN.timefreq.subdata{congM(c),condM(c)};
if strcmp(blc,'c')
comun = comun + ndata{congM(c),condM(c)}(freq,:,plb(1):plb(2),:);
comunn = comunn +1;
end
end

for c  = 1:length(condM)  
    %c = [congM(c),condM(c)]
if n
  for s = 1:size(ndata{congM(c),condM(c)},4)%length(SS)
     if iflb 
          if strcmp(blc,'i')
          ndatan{congM(c),condM(c)}(:,:,:,s) = normal_z((ndata{congM(c),condM(c)}(freq,:,:,s)),(ndata{congM(c),condM(c)}(freq,:,plb(1):plb(2),s)),met);
         elseif strcmp(blc,'c')
             % FIx ME
           ndatan{congM(c),condM(c)}(:,:,:,s) = normal_z((ndata{congM(c),condM(c)}(freq,:,:,s)), ...
                                   (comun(:,:,:,s))/comunn,...
                                    met);   
          end
         else
     %ndatan{congM(c),condM(c)}(:,:,:,s) = normal_z((ndata{congM(c),condM(c)}(freq,:,:,s)),[],met);
         end
  end

  
  
 else
   %ndatan = ndata(:,:,:,SS);
   ifz = 1;
   stav = get(STA,'Value');
   stas = get(STA,'String');
   if (stav < length(stas(:)')-1) && sd
   ndatan{congM(c),condM(c)} = GLAN.timefreq.stat{congM(c),condM(c)}(freq,:,:,:); 
   ifz = 0;
   elseif (stav < length(stas(:)')-1)&&ifz
   zdatan{congM(c),condM(c)} = GLAN.timefreq.stat{stav}(freq,:,:,:); 
   ifz = 1;
   else
   ifz = 0;
   %end %else
   ndatan{congM(c),condM(c)} = ndata{congM(c),condM(c)}(freq,:,:,:); %SS
   end
end
 % not mean nan
 pp = ndatan{congM(c),condM(c)}(:,:,tiempo,:);
     for e = 1:size(pp,2)
     ppe = pp(:,e,:,:);
     ppe = ppe(:);
     ppe(isnan(ppe)) = [];
     ppf(e) = mean(ppe,1);
     end
 ndatan{congM(c),condM(c)} = ppf;
 clear pp*
% nndatan = mean(mean(nndatan(freq,:,tiempo,:),3),1);
end


if n
COMP_topocond
%
        uicontrol('Style','pushbutton','Position',[0,0,20,20],'String','E','Callback',{@editF})
        uicontrol('Style','pushbutton','Position',[0,20,20,20],'String','S','Callback',{@editF})
        uicontrol('Style','pushbutton','Position',[0,40,20,20],'String','C','Callback',{@editF})
        uicontrol('Style','pushbutton','Position',[0,60,20,20],'String','Jet','Callback',{@editF})
        uicontrol('Style','pushbutton','Position',[0,80,20,20],'String','i','Callback',{@editF})
cc =0;
for c = 1:length(condM)
    cc = cc +1;
subplot(1,length(condM)+1,cc)
ndata = squeeze(mean(ndatan{congM(c),condM(c)},4));
topoplot_lan(ndata,GLAN.chanlocs,'electrodes','off','shading' ,'interp','style' , 'map', 'conv','on' );caxis([c_axis]);%, 'shrink', 'force' 
end
subplot(1,length(condM)+1,length(condM)+1)
ndata = squeeze(mean(cat(5,ndatan{:}),4));
if ifz
difdata = squeeze(mean(zdatan{congM(c),condM(c)},4));
elseif size(ndata,2)==2
difdata = ndata(:,1)-ndata(:,2);    
else
difdata = squeeze(std(ndata,[],2));
end
topoplot_lan(difdata,GLAN.chanlocs,'electrodes','off', 'shading' ,'interp' ,'style' , 'map', 'conv','on' );caxis([c_axis]);%,'shrink', 'force'
colormap(jet(300))
axcopy_lan;

else
    
COMP_topocond
        uicontrol('Style','pushbutton','Position',[0,0,20,20],'String','E','Callback',{@editF})
        uicontrol('Style','pushbutton','Position',[0,20,20,20],'String','S','Callback',{@editF})
        uicontrol('Style','pushbutton','Position',[0,40,20,20],'String','C','Callback',{@editF})
        uicontrol('Style','pushbutton','Position',[0,60,20,20],'String','Jet','Callback',{@editF})
        uicontrol('Style','pushbutton','Position',[0,80,20,20],'String','i','Callback',{@editF})

cc =0;

if length(condM) == 1
   n_ex_subplot=0;
else
   n_ex_subplot=1;
end
n2data=[];
for c = 1:length(condM)
    cc = cc +1;
subplot(1,length(condM)+n_ex_subplot,cc)
ndata = (squeeze(mean(ndatan{congM(c),condM(c)},4)));
n2data = cat(5,n2data,ndata);
topoplot_lan(ndata,GLAN.chanlocs,'electrodes','off','shading' ,'interp','style' , 'map', 'conv','on' );caxis([c_axis]);%, 'shrink', 'force' 
end

if n_ex_subplot
subplot(1,length(condM)+n_ex_subplot,length(condM)+n_ex_subplot)
ndata = squeeze(mean(n2data,4));
    if size(ndata,2)==2
    difdata = ndata(:,1)-ndata(:,2);    
    else
    difdata = squeeze(std(ndata,[],2));
    end
topoplot_lan(difdata,GLAN.chanlocs,'electrodes','off', 'shading' ,'interp' ,'style' , 'map', 'conv','on'  );caxis([c_axis]);%,'shrink', 'force'
end    
    

colormap(jet(300))
axcopy_lan;
end
if getMAT
   %DATA_LAN.topoplot.nndatan=nndatan;
   DATA_LAN.topoplot.ndatan = ndatan;
   DATA_LAN.topoplot.difdata = difdata;
   assignin('base','DATA_LAN',DATA_LAN);
   disp('Variable DATA_LAN with the values of topoplot in the workspace !')
   set(GUIgetMAT,'Value',0)
   getMAT=false;
end
clear *data*
%set(topocond, 'Position',[1.1*scrsz(3)/2  1.8*scrsz(4)/4 0.95*scrsz(3)/2 2*scrsz(4)/6],...
%    'Name','Topoplot','NumberTitle','off','MenuBar', 'none','Visible', 'on'); 
 

end
%------------------------------------------
%------------------------------------------
%----------Estatistica topoplot------------
%------------------------------------------
%------------------------------------------


function estata_button_Callback(source,eventdata) 

    
freq =   frt;
tiempo = time;
%n = 1;
 stav = get(STA,'Value');
 stas = get(STA,'String');

 if stav < length(stas(:)')-1
     staOK = true;
 else
     staOK = false;
 end


clear *data*
for c = 1:length(congM)
ndata{c} = GLAN.timefreq.subdata{congM(c),condM(c)};
end
if strcmp(blc,'c')
mdata = mean(cat(5,ndata{:}),5);
end

for c = 1:length(congM)
if n
    
    for s = 1:size(ndata{c},4)%length(SS)
     if iflb 
         if strcmp(blc,'i')
          ndatan{c}(:,:,:,s) = normal_z((ndata{c}(:,:,:,s)),(ndata{c}(:,:,plb(1):plb(2),s)),met);
         elseif strcmp(blc,'c')
           ndatan{c}(:,:,:,s) = normal_z((ndata{c}(:,:,:,s)), ...
                                   mdata(:,:,plb(1):plb(2),s) ,...
                                    met);   
         end
     else
     ndatan{c}(:,:,:,s) = normal_z((ndata{c}(:,:,:,s)),[],met);
     end
    
    
end   
else
   ndatan{c} = ndata{c};
   %nndatan = nndata(:,:,:,:); 
end

ndatan{c} = nanmean(nanmean(ndatan{c}(freq(1):freq(end), :,time,:),3),1);

end

if ~staOK && sd %% si hay datos for sujetos y son validos para stadistica 
cfgS=[];
cfgS.paired = strcmp(rs,'D');


[pval, stat] = lan_nonparametric(ndatan,cfgS);
 pfdr = max(pval(pval<=fdr2(pval,0.05)));




elseif staOK

%%%%  glm 

pval1 = nanmin(nanmin(GLAN.timefreq.pval{condM(c),congM(c)}(freq(1):freq(end), :,time,:),[],3),[],1);
paso=GLAN.timefreq.stat{condM(c) ,congM(c)};
paso(paso==0)=NaN;
T  = nanmean(nanmean(paso(freq(1):freq(end), :,time,:),3),1);
df = size(GLAN.timefreq.subdata{congM(c),condM(c)},4)   -1;
pval   = (T>=0).*(1 - tcdf(T,df))*2 + (T<0).*(tcdf(T,df))*2;
pval   = (pval+2*pval1)/3;

pfdr = max(pval(pval<=fdr2(pval,0.05)));

end


 %ind_x = find(pval<=pfdr);
 if ~isempty( pfdr)
  disp([ 'to ajust for FDR, please run the following  command in the command window :)'  ])
   disp([ ' '  ])
  disp([ 'colormaplan(''logP'',100,'  num2str(pfdr)  ',1)'  ])
 %  disp([ ' '  ])
 % disp([ ''  num2str(ind_x)  ''  ])
 else
  disp([ 'No electrodes survived FDR correction :('  ])  
 end
clear *data*


estata = ensure_plot_figure(estata,'Statistical topoplot', ...
    [scrsz(3)/2 1 scrsz(3)/2 (3*scrsz(4))/6]);
clf(estata);
set(estata,'Visible','on');
figure(estata);
    
    
%
        uicontrol('Style','pushbutton','Position',[0,0,20,20],'String','E','Callback',{@editF})
        uicontrol('Style','pushbutton','Position',[0,20,20,20],'String','S','Callback',{@editF})
        uicontrol('Style','pushbutton','Position',[0,40,20,20],'String','C','Callback',{@editF})
        uicontrol('Style','pushbutton','Position',[0,60,20,20],'String','S','Callback',{@editF})
        uicontrol('Style','pushbutton','Position',[0,80,20,20],'String','i','Callback',{@editF})
        
topoplot_lan(-log(pval),GLAN.chanlocs , 'shading' ,'interp' , 'style' , 'map', 'conv','on'); %caxis([0,0.2]),%shading interp;%%, 'shrink', 'force'
% Create colorbar
colormaplan('logP',100,pv_unc,1)

axcopy_lan;
end
%%-------------------------------------------
%%-------------------------------------------
%%-----------PDF---------------------------
%%-------------------------------------------
%%-----------------------------------------
function pdf_button_Callback(source,eventdata)
    if exist([figname '.pdf'],'file')==2 || exist([figname '.ps'],'file')==2 
        figname = [figname '1'];
        pdf_button_Callback
        return
    end
            display([ 'Save a graphic as a file: ' figname ' with: '])    
            %try  
            %saveas(ERP, figname,'pdf')
            %if strcmp('on',get(controles,'Visible'))
            %print(controles, '-dpsc','-r300', '-zbuffer',   [figname ]) %pdf
            %display('Controles,')
            %end
            %end
            try  
            %saveas(ERP, figname,'pdf')
            if strcmp('on',get(cartas,'Visible'))
            print(cartas, '-dpdf','-r300', '-opengl',    [figname ]) %pdf'-append'
            display('Cartas TF,')
            end
            end
            try  
                if strcmp('on',get(cartasE,'Visible'))
            print(cartasE, '-dpdf','-r300', '-opengl', '-append' ,[figname ] )
            display('Carats nonparametricas,')
                end
            end
            try  
                if strcmp('on',get(topocond,'Visible'))
            print(topocond, '-dpdf','-r300', '-append', [figname ] )
            display('TOPOPLOT,')
                end
            end
            try
                if ishghandle(estataM,'figure') && strcmp('on',get(estataM,'Visible'))
                    print(estataM, '-dpdf','-r300','-append',[figname]);
                    display('Statistical mask with cluster overlays,')
                end
            catch ME
                warning('timefreq_plot:PDFMask','Cannot export estataM: %s',ME.message);
            end
            try  
                if strcmp('on',get(estata,'Visible'))
            print(estata, '-dpdf','-r300', '-zbuffer','-append',[figname]  )
            display('TOPOPLOT(p-value),')
                end
            end
            try
                if isunix
                un = unix(['ps2pdf  ' figname '.ps' ]);
                if un == 0
                disp('ps -> pdf ');
                un = unix(['rm  ' figname '.ps' ]);
                end
                elseif ispc
                un = dos(['ps2pdf  ' figname '.ps' ]);
                if un == 0
                disp('ps -> pdf ');
                un = dos(['del  ' figname '.ps' ]);
                disp('ps -> pdf ');   
                end
                end
            catch              
                disp('ONLY .ps ... Have you ps2pdf (Latex) in the path ')
            end
            if un ~= 0
                 disp('ONLY .ps ... Have you ps2pdf (Latex) in the path ')
            end
            disp('ok')
    end

%%-------------------------------------------
%%-------------------------------------------
%%-----------CLOSE---------------------------
%%-------------------------------------------
%%-----------------------------------------

function close_button_Callback(source,eventdata,handles)
    % Close only windows belonging to this GUI (never an unrelated gcf).
    wins = {controles,cartas,cartasE,topocond,estata,estataM, ...
        clusterFigure,roiTopoFigure};
    for iw = 1:numel(wins)
        if ~isempty(wins{iw}) && ishghandle(wins{iw},'figure')
            delete(wins{iw});
        end
    end
    if iflantoolbox
        lantoolbox(GLAN);
    else
        disp('Thank you for using LAN toolbox');
    end
end

function pos = close_i(source,eventdata,handles) 
    pos = get(source,'Position');
    set(source,'Visible','off');
    
end


%%-------------------------------------------
%%-------------------------------------------
%%-----------COMP_---------------------------
%%-------------------------------------------
%%-----------------------------------------

   function COMP_CONTROL
       % Keep the original controls figure: don't destroy and recreate it.
       if ~ishghandle(controles,'figure')
           controles = figure('Position',pcc,'NumberTitle','off', ...
               'MenuBar','none');
       end
       set(controles,'Name',['TIMEFREQ - Controles en LAN v.' lanversion], ...
           'CloseRequestFcn',@close_button_Callback,'Visible','on');
       figure(controles);
   end

   function COMP_CARTAS
       % Reuse the same figure handle; clearing its old content also removes
       % old editF controls, which get recreated once by the plotting code.
       cartas = ensure_plot_figure(cartas,'cartas TF',pc);
       clf(cartas);
       set(cartas,'Visible','on','CloseRequestFcn',@close_i);
       figure(cartas);
   end

   function COMP_topocond
       topocond = ensure_plot_figure(topocond,'topoplot TF', ...
           [1 fix(1.3*scrsz(4)/6) fix(scrsz(3)/2) fix(3*scrsz(4)/6)]);
       clf(topocond);
       set(topocond,'Visible','on','CloseRequestFcn',@close_i);
       figure(topocond);
   end

   function f = ensure_plot_figure(f,displayName,defaultPosition)
       % Never depend on gcf for the target figure; support closed windows.
       if isempty(f) || ~ishghandle(f,'figure')
           f = figure('Visible','off','Position',defaultPosition, ...
               'Name',displayName,'NumberTitle','off','MenuBar','none', ...
               'CloseRequestFcn',@close_i);
       else
           set(f,'Name',displayName,'CloseRequestFcn',@close_i);
       end
   end


% active currect value
set(STA,'Value', 1)
STA_fun(STA); 
lb_Callback(GUIbl);
GUI_s(GUIS);
%nor_Callback();







end

