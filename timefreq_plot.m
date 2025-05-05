function timefreq_plot(GLAN,cfg)
% timefreq_plot.m 
% v.0.2
%
% GUI para visualizar cartas tiempo frecuencia y estadistica.
%
%                     FALTA!!!
%                      - Dejar funcionando las matrices de contrastes!!!
%                      - Optimizar mas la memoria!!!
%
%
%
% Pablo Billeke

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
    'Name','Cartas','NumberTitle','off','MenuBar', 'none');
% --
global cartasE
pce = [1 1  scrsz(3)/2 (1.5*scrsz(4))/6];
cartasE = figure('Visible','off','Position',pce,...
    'Name','CartasE','NumberTitle','off','MenuBar', 'none');%
%
global topocond
topocond = figure('Visible','off');
%
global estata
estata = figure('Visible','off');

global estataM
estataM = figure('Visible','off');
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
uicontrol('Units','normalized','Style','edit',...
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
            case {'unC'}
                sCOR = false;      
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
       editF({'E','S','C','X','Y','Jet'});   
    % check base line
    lb_Callback(GUIbl)  
    
    if ischar(fr), eval([ 'fr = [' fr '];' ]); end
    if ischar(roi),eval([ 'roi = [' roi '];' ]); end
   clear ndata nndata
     for nc = 1:length(condM)
         if sd
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
             try
                 name = fieldnames(GLAN.timefreq.stat{stav});
                 rval = eval([ 'GLAN.timefreq.stat{stav}.' name{1}    ';'    ]);
             catch
             rval = GLAN.timefreq.pval{stav};                  
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
             
         elseif staOK&&isfield(GLAN.timefreq,'hh')&&~sCOR
             
             try
             name = fieldnames(GLAN.timefreq.stat{stav});
             rval = eval([ 'GLAN.timefreq.stat{stav}.' name{1}    ';'    ]);
             catch
             rval = GLAN.timefreq.pval{stav};                  
             end
             %
             rval = squeeze(rval(fr,roi,:));
             
             
             hh = GLAN.timefreq.hh{stav};
             pval = GLAN.timefreq.pval{stav};
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
subplot(2*ntc,1,pp:pp+1,'align'),
pp = pp+2;
pcolor(GLAN.timefreq.time, GLAN.timefreq.freq(fr) , double(data1{nc})), caxis([c_axis]),shading interp;% flat;
set(gca,'xtick',[])
try 
    title([' Cond: ' GLAN.timefreq.cond{condM(nc)} ', Channels: ' cell2mat({GLAN.chanlocs(roi).labels}) ' ('  num2str(roi) ')'  ] )
end
axcopy_lan;
end
if ntc>nc
subplot(6,1,5:6,'align')
pcolor(GLAN.timefreq.time,GLAN.timefreq.freq(fr), double(data3)), caxis([c_axis/2]); shading interp;%flat;
try
    title([' Cond: ' GLAN.timefreq.cond{condM(1)} '-' GLAN.timefreq.cond{condM(2)} ] )
end
axcopy_lan;
end
if ifstat>0
try    
    figure(cartasE),
catch
    cartasE = figure('Visible','off','Position',pce,...
    'Name','CartasE','NumberTitle','off','MenuBar', 'none');%
    figure(cartasE),
end
%
        editF({'E','S','C','X','Y','Jet'}); 
        
 if size(pval,3) >1
     if size(pval,2)>1
     ppval= squeeze(mean(pval(fr,roi,:),2));
     ppval_2 = squeeze(min(pval(fr,roi,:),[],2));
     
     if nthre(1) >1  % delete little clusters
        clR = bwlabeln(hhc);
        for nrr = 1:max(clR(:))
           if sum(clR(:)==nrr) <=nthre(1)
               hhc(clR==nrr) = 0;
           end
        end
     end
       
        
     ppval(hhc==1) = ppval_2(hhc==1);
     

     
     else
     ppval = squeeze(pval(:,:,:));
     end%(roi?)
 else
     ppval = squeeze(pval(fr,:));
 end
%-----
try
    MASK = evalin('base','pval_mask');
    disp('Using base WS variable pval_mask')
catch
    MASK=pv_unc+0.01;
end
%-----
ppval(squeeze(hhc==0)&(ppval<MASK)) = MASK;
ssg = sign(rval); 
pcolor(GLAN.timefreq.time, GLAN.timefreq.freq(fr), -log10(double((squeeze(ppval)))) );
a = ppval(~isnan(ppval)&(ppval~=0));
a = -log10(min(a(:)));
colormaplan('logP',100,pv_unc,1,a);
%caxis([0,0.2]);
shading flat;% interp;%  
set(cartas,'Visible','on');

try % probando figura de stadistica con mask !!!
    
    figure(estataM)
catch
    estataM = figure('Visible','on');
    figure(estataM)
end
    
    %
    editF({'E','S','C','Jet'});

    W = pcolor(GLAN.timefreq.time,GLAN.timefreq.freq(fr), double(data3)); caxis([c_axis/2]); shading interp;%flat;
    alpha(W,0.2), hold on %stat_alpha
    Hp=single(ppval<=(pv_unc));
    Hp = lan_smooth(Hp);
    data3(Hp<=0.3)=NaN;
    pcolor(GLAN.timefreq.time,GLAN.timefreq.freq(fr), double(data3)); caxis([c_axis/2]); shading interp;%flat;
    box off
    caxis([c_axis])
    set(estataM,'Visible','on')
    
     if isfield(GLAN.timefreq, 'clusig')
     figure_lan('Clusters')
     data = clusig;% squeeze(max(clusig(fr,roi,:),[],2));
     data(pvalc>pv_c)=0;
     if size(data,3)>1
     data = squeeze(max(data,[],2));
     end
     pcolor(GLAN.timefreq.time, GLAN.timefreq.freq(fr), ...
             data );shading flat;
     end

%end


%axcopy_lan;
end
%disp('')
clear *data*
end


%------------------------------------------
%------------------------------------------
%------------- TOPOPLOT --------------------
%------------------------------------------
%------------------------------------------

function topo_button_Callback(source,eventdata) 
    
 if strcmp('N',get(source, 'String'))  
     figure
     topoplot_lan([],GLAN.chanlocs,'style','blank','electrodes','labelpoint');  
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

   if (stav < length(stas(:)')-1)&&ifz
   zdatan{congM(c),condM(c)} = GLAN.timefreq.stat{stav}(freq,:,:,:); 
   ifz = 1;
   else
   ifz = 0;
   end %else
   ndatan{congM(c),condM(c)} = ndata{congM(c),condM(c)}(freq,:,:,:); %SS
   %end
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


cfgS=[];
cfgS.paired = strcmp(rs,'D');


 [pval, stat] = lan_nonparametric(ndatan,cfgS);
 pfdr = max(pval(pval<=fdr2(pval,0.05)));
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

try
    figure(estata);
catch
        estat=figure;
end
    
    
%
        uicontrol('Style','pushbutton','Position',[0,0,20,20],'String','E','Callback',{@editF})
        uicontrol('Style','pushbutton','Position',[0,20,20,20],'String','S','Callback',{@editF})
        uicontrol('Style','pushbutton','Position',[0,40,20,20],'String','C','Callback',{@editF})
        
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
            print(cartas, '-dpsc','-r300', '-opengl',    [figname ]) %pdf'-append'
            display('Cartas TF,')
            end
            end
            try  
                if strcmp('on',get(cartasE,'Visible'))
            print(cartasE, '-dpsc','-r300', '-opengl', '-append' ,[figname ] )
            display('Carats nonparametricas,')
                end
            end
            try  
                if strcmp('on',get(topocond,'Visible'))
            print(topocond, '-dpsc','-r300', '-append', [figname ] )
            display('TOPOPLOT,')
                end
            end
            try  
                if strcmp('on',get(estata,'Visible'))
            print(estata, '-dpsc','-r300', '-zbuffer','-append',[figname]  )
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
    warning off
    %try close gcf , end;
    try delete(controles); end
    try  close(cartas);   end
    try  delete(topocond); end
    try  close(estata);   end
    try  close(cartasE);   end
    try 
        delete(gcf) 
    end
    %try clear all , end
    warning on
    if iflantoolbox
        lantoolbox(GLAN)    
        else
        disp('....')
        disp('Thank you for using LAN toolbox')
    end
    clear
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
       if exist('controles')==1
       try pcc=get(controles,'Position'); close(controles);catch , cpc = [1 5*(scrsz(4)/6) scrsz(3) scrsz(4)/6]; end 
        else
       pcc = [1 5*(scrsz(4)/6) scrsz(3) scrsz(4)/6];
       end
       controles = figure('Position',pcc,...
       'Name',[ 'TIMEFREQ - Controles en LAN v.' lanversion ],'NumberTitle','off','MenuBar', 'none');%,'Color','k');    
        set(controles,'CloseRequestFcn',@close_button_Callback)
   end

    function COMP_CARTAS
       if exist('cartas')==1
       try  pc=get(cartas,'Position'); close(cartas) ; end
       else
       %Pe =[1   fix(1.3*scrsz(4)/6)       fix(scrsz(3)/2) fix(3*scrsz(4)/6) ];
       end
       cartas = figure('Visible','on','Position',pc,...
       'Name','cartas TF','NumberTitle','off','MenuBar', 'none');
    end


    function COMP_topocond
       if exist('topocond')==1
       try  tc_pc=close_i(topocond) ; end
       else
       %Pe =[1   fix(1.3*scrsz(4)/6)       fix(scrsz(3)/2) fix(3*scrsz(4)/6) ];
       end
       topocond = figure('Visible','on','Position',tc_pc,...
       'Name','topoplot TF','NumberTitle','off','MenuBar', 'none','CloseRequestFcn',@close_i);
   
    end



% active currect value
set(STA,'Value', 1)
STA_fun(STA); 
lb_Callback(GUIbl);
GUI_s(GUIS);
%nor_Callback();







end

