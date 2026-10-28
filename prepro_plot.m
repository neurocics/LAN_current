function prepro_plot(LAN)
%         v.1
%
%         GUI para realizar prepocesamiento de matrices segemnnatadas
%             tambien sirve de visualizaci??n para datos continuos 
%
%         prepro_plot(LAN)
%  See Also VOL_THR_LAN , LAN_INTERP , FFTAMP_THR_LAN
%
%  Pablo Billeke
%  28.10.2026 (PB-IA) Add PSD interquartile band (P25-P75) across trials.
%                    Add ICA component PSD (Welch) to aid artifact
%                    inspection; preserve accepted-trial ICA views.
%                    Improved figure and axes management, fixed graphical
%                    rendering and refresh issues, and corrected ICA
%                    component navigation.
%  18.04.2022 (PB) Bug ICA visualization with empty trials
%  22.03.2022 (PB) Bug ICA for a only EEG channels
%  27.02.2022 (PB) fix n_detec option  
%  27.08.2021 (PB) improbe ICA components visualization 
%  11.06.2020 (PB) funcion n> 
%  21.04.2015 (PB) add ICA decomposition and componente view  
%  14.01.2014 (PB) fix save for cell  array LAN structure
%  21.11.2013 (MS) Some bugs fixed. New Reject RT button.
%  07.11.2013 (MS) Fixed bug where all points in the screen were rejected
%  06.11.2013 (MS) RT.good is deducted from LAN.selected
%  17.10.2013 (PB) fix no location in chanlocs
%  07.01.2013 (PB) fix unselected area
%  31.12.2012 (PB) fix unselected area
%  19.12.2012 (PB) add select area
%  14.11.2012 (PB) fix hilbert
%  22.10.2012 (PB)
%  11.10.2012 (PB) add event visualization!! (in RT structure)
%  09.10.2012
%  25.09.2012 (PB) add FT cont visualization
%  30.08.2012 (PB) Working in continuos data
%  18.07.2012 (PB) add buttom for find rejected/accepted/or detected epoch
%  06.07.2012
%  27.04.2012      fix save no cell file, and numbers in traisl TAG edit
%  30.01.2012         fix save file
%  26.01.2012  (PB) next rejected trial buttom, save file
%  10.01.2012  (PB) fix screen size
%  17.09.2011  (PB)
%  16.09.2011  (PB)
%  22.07.2011  (PB)
%  19.06.2011  (PB)

try
iflantoolbox = evalin('caller', 'iflantoolbox');
catch
iflantoolbox = false;
end

% landef
fc = [0 0 0]; % get_landef('fc'); % 
bc = [0.75 0.75 0.75]; % get_landef('bc'); %

LAN = lan_check(LAN);
global  ncell;
if ~iscell(LAN)
    ncell=true;
    tlan = LAN;
    clear LAN
    LAN{1} = tlan;
    clear tlan
    LAN = lan_check(LAN);
else
    ncell=false;
end
global var
var = inputname(1);
global ifax
global ax
global ax2
global ifax2
ifax2 = 0;
global selectP 
selectP = [];
global ifbarax
global barax
global TAGat1
global TAGat2
global TAGat3
global FT_gui
global FTerp_gui
global hilbert_gui
global rej_gui
global Bra
global editv
global elecbot
global ytl
global r_elec
global ifcon      % if data is continuous
global nlabel  
global nlp
global paTAG
global uilabels
global ERPPLOT
global GUIcb
global GUIMAS
global GUIMENOS
global eegtitle
global n_ini
global l_seg
global ini_p
global fin_p
global view_chan
global view_comp
view_comp =0;
global comp_data
global ncomp
ncomp=1;
global tncomp
tncomp = [];
global n_detec
n_detec=3;
global viewCHAN
viewCHAN =1;
global bot_chan 

global topoICA
global ifica
global ifGUI_ica
global p_ica
global see_ica



    ifGUI_ica=0;
    if isfield(LAN,'ica')
        ifica=true;
    else
        ifica=false;
    end
    p_ica = [0.4 0.4 0.2 0.2];
    see_ica=false;
    



global guirt
global axrt
global channelTextHandles
channelTextHandles = {};
global ifguirt
ifguirt = 0;


% hilbert option
global nbCOMP_GUI
global HIL
global cfghilbert
global ifdatahil 
ifdatahil = 0;
global ifaxhil
ifaxhil =0;
global axhil
global GUI_HIL_plot
global ifGUI_HIL_plot
ifGUI_HIL_plot=0;
global datahil
global norbin
norbin=0;
global Hil_span
Hil_span=1;
global hilsmooth 
hilsmooth = '--';
global datahilsmooth 

%global view_chan_button_Callback
global  view_chan_eeg
% position of EEG windows
cfghilbert = {[0,0]};

global M % name of currect electrode 
global GUI_FT_CON
global ifGUI_FT_CON
ifGUI_FT_CON = 0;
global ifaxft
 ifaxft =0;
global axft
global ifdataft
ifdataft = 0;
global dataft
% Graphics caches are local to this GUI invocation (not LAN data).
ftLastTrial = [];
ftLastCond = [];
hilLastTrial = [];
hilLastCond = [];
hilLastChannels = [];
global caxis_ft
caxis_ft = [2 10];
global caxis_ft_gui
global nor_ft
nor_ft = 'z';
global nsmooth;
nsmooth=0;

r_elec=cell(1,length(LAN));
for ie = 1:length(r_elec)
    if ~isempty(LAN{ie})
    r_elec{ie} = zeros(LAN{ie}.nbchan,LAN{ie}.trials);
    end
end
elecbot=[];
ifbarax = 0;
ax=0;
ifax = 0;

global ncd
ncd = 1;
while isempty(LAN{ncd})
     ncd = ncd + 1;
end
%clear in


 
global sc
sc = 50;

scrsz = get(0,'ScreenSize');
if max(scrsz) <100
   scrsz = [0 0 1200 800];
end

view_chan = [1:LAN{ncd}.nbchan];


%EEG
global EEG
global pc
pc = [1 (1*scrsz(4))/6  scrsz(3)/2  (3.5*scrsz(4))/6];
EEG = figure('Visible','off','Position',pc,...
'Name','EEG plot','NumberTitle','off','MenuBar', 'none','CloseRequestFcn',{@close_EEG});

global ELECTRODE
global pce
ELECTRODE = -1;

%CONTROLES
pcc =[1 5*(scrsz(4)/6) scrsz(3) scrsz(4)/6];
global controles
controles = figure('Position',pcc,...
'Name',[ 'Controles en LAN v.' lanversion ],'NumberTitle','off','MenuBar', 'none','Color',bc,'CloseRequestFcn',{@close_button_Callback});%);%



%%%
%----- botones
uicontrol('Style','pushbutton','String','<~<','Units','normalized',...
          'Position',[0.9, 0 ,0.05,0.2],...'BackgroundColor',bc,'ForegroundColor',fc,...
         'Callback',{@condicion_menos});
uicontrol('Style','pushbutton','String','>~>','Units','normalized',...
          'Position',[0.95, 0 ,0.05,0.2],... 'BackgroundColor',bc,'ForegroundColor',fc,...
         'Callback',{@condicion_mas});
     if iflantoolbox
uicontrol('Style','pushbutton','String','Back to LANtoolbox','Units','normalized',...
          'Position',[0.9, 0.25 ,0.1,0.2],...'BackgroundColor',bc,'ForegroundColor',fc,...
         'Callback',{@close_button_Callback}); 
uicontrol('Style','pushbutton','String','Save(V)','Units','normalized',...
          'Position',[0.9, 0.5 ,0.05,0.2],...'BackgroundColor',bc,'ForegroundColor',fc,...
         'Callback',{@savews_button_Callback}); 
uicontrol('Style','pushbutton','String','Save(F)','Units','normalized',...
          'Position',[0.95, 0.5 ,0.05,0.2],...'BackgroundColor',bc,'ForegroundColor',fc,...
         'Callback',{@savews_button_Callback});  
     else
uicontrol('Style','pushbutton','String','Save(V) and Close','Units','normalized',...
          'Position',[0.9, 0.25 ,0.1,0.2],...'BackgroundColor',bc,'ForegroundColor',fc,...
         'Callback',{@close_button_Callback});   
uicontrol('Style','pushbutton','String','Save(V)','Units','normalized',...
          'Position',[0.9, 0.5 ,0.05,0.2],...'BackgroundColor',bc,'ForegroundColor',fc,...
         'Callback',{@savews_button_Callback}); 
uicontrol('Style','pushbutton','String','Save(F)','Units','normalized',...
          'Position',[0.95, 0.5 ,0.05,0.2],...'BackgroundColor',bc,'ForegroundColor',fc,...
         'Callback',{@savews_button_Callback}); 
     end
uicontrol('Style','pushbutton','String','EEG','Units','normalized',...
          'Position',[0.9, 0.75 ,0.05,0.2],...'BackgroundColor',bc,'ForegroundColor',fc,...
         'Callback',{@EEGplot_button});   
bot_chan = uicontrol('Style','pushbutton','String','Channels','Units','normalized',...
          'Position',[0.95, 0.75 ,0.05,0.2],...'BackgroundColor',bc,'ForegroundColor',fc,...
         'Callback',{@electrode_plot});      
%%%
%---- condiciones
pa1 = uipanel('Title','Condiciones (numero, ver info->)','Units','normalized',...
    'BackgroundColor',bc,'ForegroundColor',fc,...
    'Position',[0, 0.1 ,0.2,0.9]);
 
uicontrol('Parent',pa1 ,'Units','normalized','Style','text','String','Condicion #',...
          'Position',[0,0.75,0.3,0.2],'BackgroundColor',bc,'ForegroundColor',fc...
           );
global numeroC       
numeroC=uicontrol('Parent',pa1 ,'Units','normalized','Style','edit',...
           'String', ncd ,...opciones{pp,1},...
           'Position',[0.35,0.75,0.3,0.25],'BackgroundColor',bc,'ForegroundColor',fc,...
           'Callback',{ @condicion_button_Callback} );
       
 global nombreC      
 uicontrol('Parent',pa1 ,'Units','normalized','Style','text','String','Condicion',...
            'BackgroundColor',bc,'ForegroundColor',fc,...
          'Position',[0,0.5,0.3,0.22]...%'BackgroundColor',cf,'ForegroundColor',fc
           );
nombreC=uicontrol('Parent',pa1 ,'Units','normalized','Style','edit',...
           'String', LAN{ncd}.cond ,...opciones{pp,1},...
           'Position',[0.35,0.5,0.5,0.22],'BackgroundColor',bc,'ForegroundColor',fc,...
           'Callback',{ @nombrecondicion_button_Callback} );   
 %
  global nombreG      
 uicontrol('Parent',pa1 ,'Units','normalized','Style','text','String','Group',...
            'BackgroundColor',bc,'ForegroundColor',fc,...
          'Position',[0,0.25,0.3,0.22]...%'BackgroundColor',cf,'ForegroundColor',fc
           );
nombreG=uicontrol('Parent',pa1 ,'Units','normalized','Style','edit',...
           'String', LAN{ncd}.group ,...opciones{pp,1},...
           'Position',[0.35,0.25,0.5,0.22],'BackgroundColor',bc,'ForegroundColor',fc,...
           'Callback',{ @nombregrupo_button_Callback} );   
 global nombreS      
 uicontrol('Parent',pa1 ,'Units','normalized','Style','text','String','Subject',...
          'Position',[0,0,0.3,0.22],'BackgroundColor',bc,'ForegroundColor',fc......%'BackgroundColor',cf,'ForegroundColor',fc
           );
nombreS=uicontrol('Parent',pa1 ,'Units','normalized','Style','edit',...
           'String', LAN{ncd}.name ,...opciones{pp,1},...
           'Position',[0.35,0,0.5,0.22],'BackgroundColor',bc,'ForegroundColor',fc,...
           'Callback',{ @nombrename_button_Callback} );       
       
       
%---- Channel
paCh = uipanel('Title','Channel ()','Units','normalized','Position',[0.21, 0.1 ,0.2,0.9],...
    'BackgroundColor',bc,'ForegroundColor',fc);
uicontrol('Parent',paCh ,'Units','normalized','Style','text','String','Delete',...
    'BackgroundColor',bc,'ForegroundColor',fc,...
          'Position',[0,0.75,0.3,0.2]...%'BackgroundColor',cf,'ForegroundColor',fc
           );
global dele      
dele = uicontrol('Parent',paCh ,'Units','normalized','Style','edit',...
           'String', [],...opciones{pp,1},...
           'Position',[0.35,0.75,0.3,0.25],...
       'BackgroundColor',bc,'ForegroundColor',fc,......'BackgroundColor',cf,...'ForegroundColor',fc,...
           'Callback',{ @delectrode_button_Callback} ); 
       
uicontrol('Parent',paCh ,'Units','normalized','Style','text','String','Voltage thr',...
    'BackgroundColor',bc,'ForegroundColor',fc,...
          'Position',[0,0.5,0.3,0.25]...%'BackgroundColor',cf,'ForegroundColor',fc
           );
       %voltaje
        global vlt      
        vlt = uicontrol('Parent',paCh ,'Units','normalized','Style','edit',...
                   'String', [],...opciones{pp,1},...
                   'Position',[0.35,0.5,0.3,0.25],'BackgroundColor',bc,'ForegroundColor',fc,...
                   'Callback',{ @vlt_button_Callback} ); 
               
         % interpol        
        uicontrol('Parent',paCh ,'Units','normalized','Style','text','String',...
                  'Interpolate:',...
                  'BackgroundColor',bc,'ForegroundColor',fc,...
                  'Position',[0,0.25,0.3,0.25]...%'BackgroundColor',cf,'ForegroundColor',fc
                   );      
        uicontrol('Parent',paCh, 'Style','pushbutton','String',...
          't:bad','Units','normalized',...
          ...'BackgroundColor',bc,'ForegroundColor',fc,...
          'Position',[0.35, 0.25 ,0.3,0.25],... 'BackgroundColor',cf,... 'ForegroundColor',fc,...
         'Callback',{@interpolbad});         
        chint = uicontrol('Parent',paCh ,'Units','normalized','Style','edit',...
           'String', [],...opciones{pp,1},...
           'BackgroundColor',bc,'ForegroundColor',fc,...
           'Position',[0.65,0.25,0.3,0.25],...'BackgroundColor',cf,...'ForegroundColor',fc,...
           'Callback',{ @chint_button_Callback} );        
       
         % fftAmp        
        uicontrol('Parent',paCh ,'Units','normalized','Style','text','String',...
                  'fft_Amp:',...
                  'BackgroundColor',bc,'ForegroundColor',fc,...
                  'Position',[0,0,0.2,0.25]...%'BackgroundColor',cf,'ForegroundColor',fc
                   );
               global fftM
           fftM= uicontrol('Parent',paCh, 'Style','edit','String',...
          'f','Units','normalized',...
          'BackgroundColor',bc,'ForegroundColor',fc,...
          'Position',[0.2, 0 ,0.2,0.25]... 'BackgroundColor',cf,... 'ForegroundColor',fc,...
          ...% 'Callback',{@amet_f}
          );
            global fftA
          fftA = uicontrol('Parent',paCh ,'Units','normalized','Style','edit',...
           'String', '[STD p]',...opciones{pp,1},...
           'BackgroundColor',bc,'ForegroundColor',fc,...
           'Position',[0.4,0,0.25,0.25]...'BackgroundColor',cf,...'ForegroundColor',fc,...
          ... 'Callback',{ @fftA_f}
          );    
           global fftR
          fftR = uicontrol('Parent',paCh ,'Units','normalized','Style','edit',...
           'String', 'f1 f2',...opciones{pp,1},...
           'BackgroundColor',bc,'ForegroundColor',fc,...
           'Position',[0.65,0,0.25,0.25]...'BackgroundColor',cf,...'ForegroundColor',fc,...
          ... 'Callback',{ @fftA_f}
          );    
          uicontrol('Parent',paCh ,'Units','normalized','Style','pushbutton',...
           'String', ')*>',...opciones{pp,1},...
           ...BackgroundColor',bc,'ForegroundColor',fc,...
           'Position',[0.9,0,0.1,0.25],...'BackgroundColor',cf,...'ForegroundColor',fc,...
           'Callback',{ @fft_f}...
          );  
    function fft_f(paso,paso2,paso1) 
        clear paso*
        paso.method = get(fftM,'String');
        paso.thr = eval(['[' get(fftA,'String') ']' ] );
        paso.frange = eval(['[' get(fftR,'String') ']' ] );
        LAN = fftamp_thr_lan(LAN,paso);
        ifdatahil = false; ifdataft = false;
        EEGplot(cnt)
        electrode_plot()
        
    end

%---- Components
paCom = uipanel('Title','Component()','Units','normalized','Position',[0.42, 0.1 ,0.2,0.9],...
    'BackgroundColor',bc,'ForegroundColor',fc);

uicontrol('Parent',paCom ,'Units','normalized','Style','text','String','Algoritm',...
    'BackgroundColor',bc,'ForegroundColor',fc,...
          'Position',[0.01,0.75,0.3,0.2]...%'BackgroundColor',cf,'ForegroundColor',fc
           );    
global Algo
       Algo = uicontrol('Parent',paCom ,'Units','normalized','Style','popup',...
           'String', {'runica'},...opciones{pp,1},...
           'Position',[0.31,0.75,0.3,0.25],...
       'BackgroundColor',bc,'ForegroundColor',fc......'BackgroundColor',cf,...'ForegroundColor',fc,...
           ); 
uicontrol('Parent',paCom ,'Units','normalized','Style','pushbutton',...
           'String', {'ICA'},...opciones{pp,1},...
           'Position',[0.61,0.75,0.3,0.25],...
       ...'BackgroundColor',bc,'ForegroundColor',fc,......'BackgroundColor',cf,...'ForegroundColor',fc,...
           'Callback',{ @pp_runica} ); 
       
uicontrol('Parent',paCom ,'Units','normalized','Style','text','String','Nb Comp',...
    'BackgroundColor',bc,'ForegroundColor',fc,...
          'Position',[0.01,0.5,0.3,0.2]...%'BackgroundColor',cf,'ForegroundColor',fc
           );
       
nbCOMP_GUI = uicontrol('Parent' , paCom ,'Units','normalized','Style','edit','String', num2str(tncomp) ,...
    'BackgroundColor',bc,'ForegroundColor',fc,...
          'Position',[0.31,0.5,0.3,0.2]...%'BackgroundColor',cf,'ForegroundColor',fc
           );        
global guiplotICA       
guiplotICA = uicontrol('Parent',paCom ,'Units','normalized','Style','pushbutton',...
           'String', {'plot Component'},...opciones{pp,1},...
           'Position',[0.61,0.5,0.3,0.25],...
       ...'BackgroundColor',bc,'ForegroundColor',fc,......'BackgroundColor',cf,...'ForegroundColor',fc,...
           'Callback',{ @plot_comp} );
       if isfield(LAN{ncd},'ica_weights')& ~isempty(LAN{ncd}.ica_weights)
       else
           set(guiplotICA,'ForegroundColor',[0.5 0.5 0.5]);
       end
global electrode_comp

electrode_comp  = uicontrol('Parent',paCom ,'Units','normalized','Style','pushbutton',...
           'String', 'Showing: electrodes',...opciones{pp,1},...
           'Position',[0.61,0.02,0.3,0.2],...
       ...'BackgroundColor',bc,'ForegroundColor',fc,......'BackgroundColor',cf,...'ForegroundColor',fc,...
           'Callback',{ @shift_comp_elect} );
       
       
uicontrol('Parent',paCom ,'Units','normalized','Style','text','String','Components',...
    'BackgroundColor',bc,'ForegroundColor',fc,...
          'Position',[0.01,0.25,0.3,0.2]...%'BackgroundColor',cf,'ForegroundColor',fc
           );        
global compE     
if isfield(LAN{ncd}, 'ica_del')
    ww=[ num2str(sort(LAN{ncd}.ica_del)) ];
else
    ww='';
end
compE = uicontrol('Parent',paCom ,'Units','normalized','Style','Edit','String',ww,...
    'BackgroundColor',bc,'ForegroundColor',fc,...
          'Position',[0.31,0.25,0.3,0.2]...%'BackgroundColor',cf,'ForegroundColor',fc
           ); 
uicontrol('Parent',paCom ,'Units','normalized','Style','pushbutton','String','Del Components',...
    ...'BackgroundColor',bc,'ForegroundColor',fc,...
          'Position',[0.61,0.25,0.3,0.2]...%'BackgroundColor',cf,'ForegroundColor',fc
            ,'Callback',{ @shift_comp_elect} );   

% ---- PANEL info---
pa_inf = uipanel('Title','Info','Units','normalized','Position',[0.65, 0 ,0.25,1],...
    'BackgroundColor',bc,'ForegroundColor',fc...
    );
% uicontrol('Parent',pa_inf,'Units','normalized','Style','text','String',['Sujetos: ' num2str(nS) '   '  ma_s ],...
 %         'Position',[0,0.85,1,0.15]...%'BackgroundColor',cf,'ForegroundColor',fc
  %         );
  ncond = length(LAN)  ;
    for cc = 1:ncond
        if isempty(LAN{cc})
            namecond{cc,1} = [num2str(cc)  '(-empty-), ' ];
        elseif isempty(LAN{cc}.cond);
            namecond{cc,1} = [num2str(cc)  '(-noname-), ' ];
        else
            namecond{cc,1} = [num2str(cc) '(' LAN{cc}.cond  '), '];
        end
    end
  uicontrol('Parent',pa_inf,'Units','normalized','Style','text','String', [ ' Condiciones:  '  cat(2,namecond{:}) ],...
          'Position',[0,0.45,1,0.4],...
          'BackgroundColor',bc,'ForegroundColor',fc...%'BackgroundColor',cf,'ForegroundColor',fc
           );   
%%%%%%

global cnt
cnt=1;
global nameLAN

if iflantoolbox
    nameLAN =evalin('base','nameLAN_tempLAN');
else
    nameLAN = inputname(1);
end

   
%%%
EEGplot(cnt)
electrode_plot()
%%%%


%%----------------------------------
%%%     EEGplot
%%----------------------------------
function EEGplot(nt,Nlabels)
    
    
    
    
    
   if isempty(LAN{ncd}.data{nt})
       cnt = cnt+1;
       disp([ 'no data for rejected trial: ' num2str(nt)]);
       EEGplot(cnt)
   else
       if nargin==1
           for e = 1:LAN{ncd}.nbchan;
           Nlabels{e} = [  LAN{ncd}.chanlocs(e).labels ];      
           end   
       end
       
       electrode_plot()
       COMP_EEG
       %set(0,'CurrentFigure',EEG);
       
       c=0;
       ytl=[];
       yt=[];
       
       %r_view
       for i = sort(view_chan,'descend')%max(view_chan):-1:min(view_chan)
           
           c=c+1;
           try
               ytl{c} = Nlabels{i};%LAN{ncd}.chanlocs(i).labels;
           catch
               ytl{c} = ['E:' num2str(i)];
           end
           yt(c) = -(numel(view_chan)-c+1)*sc; % map descending labels to ascending trace offsets
       end
       
       if LAN{ncd}.trials ==1
           ifcon =1; nC = 'Continuo';
       else
           ifcon=0;nC ='Trial : ';
       end
       
       if ~ifax2 || ~ishghandle(ax2)
           selectP = [];
           
           ax2 = axes('Parent',EEG,...
               'Position',[0.05 0.0 0.9 0.05],...
               'YTickLabel',[],'YTick',[],'XTickLabel',[],'XTick',[],... axes
               'ButtonDownFcn',@C_selected);
           ifax2=true;
       end
       
       if ~ifax || ~ishghandle(ax)
           ifax = 0;
           if ifcon
               n_ini = 1 ;
               l_seg = LAN{ncd}.srate;
               nCn = (n_ini * l_seg) -1;
           else
               nCn = cnt;
           end
           ax = axes('Parent',EEG,...
               'Position',[0.05 0.1  0.9 0.85],...
               'YTickLabel',ytl,'YTick',yt);
           
           if any(diff(view_chan)~=1)
               r_view = num2str(view_chan);
           else
               r_view = [num2str(min(view_chan)) ':'  num2str(max(view_chan))];
           end
           view_chan_eeg = uicontrol('Parent',EEG,...
               'Style','edit',...
               'Units','normalized', 'Position',[0.0 0.95 0.05 0.05], ...
               'String', r_view ,...opciones{pp,1},...
               'Callback',{ @view_chan_button_Callback} );
           
           uicontrol('Parent',EEG,...
               'Style','Text',...
               'Units','normalized', 'Position',[0.05 0.95 0.15 0.05], ...
               'String', nC );
           eegtitle = uicontrol('Parent',EEG,...
               'Style','edit',...
               'Units','normalized', 'Position',[0.30 0.95 0.5 0.05], ...
               'String', nCn ,...opciones{pp,1},...
               'Callback',{ @cnt_button_Callback} );
           GUIMENOS =  uicontrol('Parent',EEG,...
               'Style','pushbutton','String','<R','Units','normalized',...
               'Position',[0.80 0.95 0.08 0.05],... 'BackgroundColor',cf,... 'ForegroundColor',fc,...
               'Callback',{@MENOS_button_Callback});
           uicontrol('Parent',EEG,...
               'Style','pushbutton','String','@','Units','normalized',...
               'Position',[0.88 0.95 0.04 0.05],... 'BackgroundColor',cf,... 'ForegroundColor',fc,...
               'Callback',{@CAMBIO_button_Callback});
           GUIMAS = uicontrol('Parent',EEG,...
               'Style','pushbutton','String','R>','Units','normalized',...
               'Position',[0.92 0.95 0.08 0.05],... 'BackgroundColor',cf,... 'ForegroundColor',fc,...
               'Callback',{@MAS_button_Callback});
           
       end
       
       if  LAN{ncd}.accept(cnt)
           color = 'b';
       else
           color = 'r';
       end
       
       %%bad
       bad = find(ifcellis(LAN{ncd}.tag.labels,'bad','c'));
       badA = find(ifcellis(LAN{ncd}.tag.labels,'bad:A'));
       badV = find(ifcellis(LAN{ncd}.tag.labels,'bad:V'));
       badO = find(ifcellis(LAN{ncd}.tag.labels,'bad:off'));
       if ifcon
           ini_p = fix(1 + ((n_ini-1 )* l_seg));
           fin_p = fix(ini_p + (l_seg -1));
           if fin_p >LAN{ncd}.pnts
               fin_p = LAN{ncd}.pnts;
               ini_p = fix(fin_p - (l_seg -1));
           end
           ltime =linspace((ini_p-1)/LAN{ncd}.srate,(ini_p-1+l_seg)/LAN{ncd}.srate, l_seg);
       else
           ini_p = 1;
           fin_p = size(LAN{ncd}.data{cnt},2);
           ltime =linspace(LAN{ncd}.time(cnt,1),LAN{ncd}.time(cnt,2), LAN{ncd}.pnts(cnt));
       end
       c = 0;
       
       cla(ax); % remove previous EEG traces and event overlays once per refresh
       hold(ax,'on');
       for i = sort(view_chan)
           c = c +1;
           if r_elec{ncd}(i,cnt)==0
               gr=1;
           else
               gr=2;
           end
           
           % bad channel 
           if ~view_comp 
           if any(LAN{ncd}.tag.mat(i,cnt) == bad)
               paso = color;
               color = 'yellow';
               if any(LAN{ncd}.tag.mat(i,cnt) == badA)%&& any(LAN{ncd}.tag.mat(i,cnt) == badA)
                   color=[1 0.25 0];
               elseif any(LAN{ncd}.tag.mat(i,cnt) == badO)
                   color=[1 0.5 0];
              %elseif any(LAN{ncd}.tag.mat(i,cnt) == badO)
              %     color=[0 0 0];    
               end
           end
           end
           % delected componnete 
           if view_comp 
           if isfield(LAN{ncd}, 'ica_del')
           if any(LAN{ncd}.ica_del == i)
               paso = color;
               color = 'red';
               if isfield(LAN{ncd}, 'ica_del_comp')
                   comp_data{nt}(i,:) = LAN{ncd}.ica_del_comp{nt}(LAN{ncd}.ica_del == i,:);
               end
           end
           end
           end
           
           
           %%%
           
           if ifcon    %con
               if view_comp
                    plot(ax,ltime,comp_data{1}(i,ini_p:fin_p)-(c*sc)-(nanmean(LAN{ncd}.data{1}(i,ini_p:fin_p))),'Color',color,...
                   'LineWidth',gr);
               else
               plot(ax,ltime,LAN{ncd}.data{1}(i,ini_p:fin_p)-(c*sc)-(nanmean(LAN{ncd}.data{1}(i,ini_p:fin_p))),'Color',color,...
                   'LineWidth',gr);
               end
               try  color = paso;  end
               
           else    %seg
               if view_comp
               plot(ax,ltime,comp_data{nt}(i,:)-(c*sc)-(nanmean(LAN{ncd}.data{nt}(i,:))),'Color',color,...
                   'LineWidth',gr);
               else
               plot(ax,ltime,LAN{ncd}.data{nt}(i,:)-(c*sc)-(nanmean(LAN{ncd}.data{nt}(i,:))),'Color',color,...
                   'LineWidth',gr);
               end
               try  color = paso;  end
               
           end
           
       end
       
       
       % EEG axes are addressed explicitly; do not change global CurrentAxes
       
       if ifcon
           set(eegtitle,'String', num2str([ (n_ini-1) * (l_seg/LAN{ncd}.srate)  l_seg/LAN{ncd}.srate]) );
       else
           set(eegtitle,'String', num2str(cnt) );
       end
       set(ax,'Parent',EEG,...
           ...'Position',[0.05 0.05 0.9 0.9],...
           'YTickLabel',ytl,'YTick',yt);
       hold(ax,'off');
       
       
       % ejes
       if ifcon
           xlim(ax,[   (ini_p-1)/LAN{ncd}.srate,(ini_p-1+l_seg)/LAN{ncd}.srate  ]);
       else
           xlim(ax,[LAN{ncd}.time(cnt,1), LAN{ncd}.time(cnt,2)  ]);
       end
       ylim(ax,[ (c+1)*(-sc) 0]);
       %set(EEG,'title')
       
       
       
       
       
       if ~ifax
           % EEG axes are addressed explicitly; do not change global CurrentAxes
           c = 0;
           n = length(view_chan);
           for el = sort(view_chan)%1:LAN{ncd}.nbchan
               c = c+1;
               elecbot{c}= uicontrol('Parent',EEG, 'Style','pushbutton',...
                   'String',ytl{c},'Units','normalized',...
                   'Position',[0, (0.1 + ((0.85/n)*(c-1)) ) ,0.05,(0.85/n)],... 'BackgroundColor',cf,... 'ForegroundColor',fc,...
                   'Callback',{@no});
           end
           
           uicontrol('Parent',EEG,'Style','pushbutton','String','<','Units','normalized',...
               'Position',[0.95, 0 ,0.025,0.2],... 'BackgroundColor',cf,... 'ForegroundColor',fc,...
               'Callback',{@MENOS_button_Callback});
           uicontrol('Parent',EEG,'Style','pushbutton','String','>','Units','normalized',...
               'Position',[0.975, 0 ,0.025,0.2],... 'BackgroundColor',cf,... 'ForegroundColor',fc,...
               'Callback',{@MAS_button_Callback});
           if LAN{ncd}.accept(cnt)
               reval = 'Rej';
           else
               reval = 'Acc';
           end
           Bra = uicontrol('Parent',EEG,'Style','pushbutton','String',reval,'Units','normalized',...
               'Position',[0.95, 0.25 ,0.05,0.1],... 'BackgroundColor',cf,... 'ForegroundColor',fc,...
               'Callback',{@REJECT_button_Callback});
           
           uicontrol('Parent',EEG,'Style','pushbutton','String','(+)','Units','normalized',...
               'Position',[0.95, 0.4 ,0.05,0.09],... 'BackgroundColor',cf,... 'ForegroundColor',fc,...
               'Callback',{@up_button_Callback});
           uicontrol('Parent',EEG,'Style','pushbutton','String','(-)','Units','normalized',...
               'Position',[0.95, 0.55 ,0.05,0.09],... 'BackgroundColor',cf,... 'ForegroundColor',fc,...
               'Callback',{@low_button_Callback});
           editv =  uicontrol('Parent',EEG,'Style','Edit','String',[num2str(sc) ],'Units','normalized',...
               'Position',[0.95, 0.71 ,0.05,0.05],... 'BackgroundColor',cf,... 'ForegroundColor',fc,...
               'Callback',{@edituv_button_Callback});
           uicontrol('Parent',EEG,'Style','Text','String',LAN{ncd}.unit ,'Units','normalized',...
               'Position',[0.95, 0.65 ,0.05,0.05]... 'BackgroundColor',cf,... 'ForegroundColor',fc,...
               );
           ifax=1;
       else
           
           % EEG axes are addressed explicitly; do not change global CurrentAxes
           
              for el = 1:numel(view_chan)
                  if ishghandle(elecbot{el})
                      set(elecbot{el},'String',ytl{el});
                  end
              end
           
           if LAN{ncd}.accept(cnt)
               reval = 'Rej';
           else
               reval = 'Acc';
           end
           nn = length(view_chan);
           for el=1:nn
               if r_elec{ncd}(view_chan(el),cnt)==1
                   set(elecbot{(nn-el+1)},'ForegroundColor','red')
               else
                   set(elecbot{(nn-el+1)},'ForegroundColor','black')
               end
           end
           
           
           set(Bra,'String',reval);
           set(editv,'String',[num2str(sc) ]);
       end
       cla(ax2)
       % Selection timeline stays on ax2 regardless of the active figure
       DIF = find(abs(diff(LAN{ncd}.selected{cnt})));
       AR = LAN{ncd}.selected{cnt}(ini_p:fin_p);
       rDIF =DIF( (DIF>=ini_p)&(DIF<=fin_p) );
       if (ini_p==1)&(LAN{ncd}.selected{cnt}(1)==0); rDIF=cat(2,1,rDIF); end;
       Xs = [];
       if sum(AR==0) == length(AR==0)
           Xs = [ini_p fin_p];
       else
           if (AR(1,1)==0)&(rDIF(1)~=ini_p); Xs(1) = ini_p;end
           for pp = rDIF;
               Xs(end+1) = pp;
           end
           if (AR(end)==0)&(rDIF(end)~=fin_p); Xs(end+1) = fin_p; end
           
       end
       plot(ax2,rDIF,ones(size(rDIF)),'ro','LineWidth',2);hold(ax2,'on')
       for pp = 1:2:length(Xs)
           line(ax2,Xs(pp:pp+1),[1 1],'color','red','LineWidth',2);
       end
       hold(ax2,'off');
       %surface(double(cat(1,~LAN{ncd}.selected{cnt},~LAN{ncd}.selected{cnt}))); caxis([-0.1 1.1 ])
       xlim(ax2,[ini_p fin_p]); ylim(ax2,[0 2]);
       %shading flat;
       %area(cat(1,LAN{ncd}.selected{cnt}(ini_p:fin_p),~LAN{ncd}.selected{cnt}(ini_p:fin_p))'); caxis([0.9 2.1 ])
       set(ax2,'Parent',EEG,...
           ...'Position',[0.05 0.05 0.9 0.9],...
           'YTickLabel',[],'YTick',[],'XTickLabel',[],'XTick',[],'ButtonDownFcn',@C_selected ...
           );
       
       
       
   end % empty trial
   
if ifGUI_FT_CON % ) && strcmp('on',get(GUI_FT_CON,'Visible'))
    FT_CON(1, cnt);
end
if ifGUI_HIL_plot %)&& strcmp('on',get(GUI_HIL_plot,'Visible')) 
    HIL_plot(1);
end
if ifguirt %)&& strcmp('on',get(GUI_HIL_plot,'Visible')) 
    GUI_RT(1);
end
drawnow limitrate;

end
%%----------------------------------
%%%     electrode_plot
%%----------------------------------
function electrode_plot(source,eventdata,handles)
    if nargin>0
      ColorB =   get(source,'ForegroundColor') ;
      if ColorB(1) == 0;
         ColorB = [ 0.5 0.5 0.5];
         viewCHAN = 0;
         close(ELECTRODE);
      else
         ColorB = [ 0 0 0]; 
         viewCHAN = 1;
      end
      set(source,'ForegroundColor',ColorB ) ;
    end
    if viewCHAN==0
        return
        
    end
    clear source eventdata handles
COMP_ELECTRODE
%set(0,'CurrentFigure',ELECTRODE);
    c=0;
        for i = LAN{ncd}.nbchan:-1:1
            c=c+1;
            try
                ytl{c} = LAN{ncd}.chanlocs(i).labels;
            catch
                ytl{c} = ['E:' num2str(i)];
            end
               yt(c) = c;% (i*sc)*(-1);    
        end
if  LAN{ncd}.trials>1       
        
if ~ifbarax

   %claer ax
    barax = axes('Parent',ELECTRODE,...
    'Position',[0.05 0.05 0.5 0.9],'CLim',[1 6],...
    'XLim',[1 LAN{ncd}.trials],...
    'YLim',[1 LAN{ncd}.nbchan ],...
    'YTickLabel', ytl,'YTick',yt...
    );

end
%

%%% search tag by trial and electrode
interpolados = find(ifcellis(LAN{ncd}.tag.labels,'interpolated'));
bad = find(ifcellis(LAN{ncd}.tag.labels,'bad','c'));


for i = 1:LAN{ncd}.nbchan
    iy = LAN{ncd}.nbchan-(i-1);
    if ~isempty(interpolados) 
    paso = (LAN{ncd}.tag.mat(i,:)==interpolados);   
    %%% Green : interpolated in good trials
    G(iy) =  sum(paso(logical(LAN{ncd}.accept)));
    %%% Black : interpolated in bad trials
    Bk(iy) =  sum(paso(~logical(LAN{ncd}.accept)));
    else
    G(iy)=0;   Bk(iy)=0; 
    end
    
    if ~isempty(bad)
        paso = (LAN{ncd}.tag.mat(i,:)==bad(1));
        for ib = 2:length(bad)%% 
            paso = (LAN{ncd}.tag.mat(i,:)==bad(ib))+paso;
        end
    %%% Yellow : bad in good trials
    Y(iy) =  sum(paso(logical(LAN{ncd}.accept)));
    %%% Red d : bad in bad trials
    Rd(iy) =  sum(paso(~logical(LAN{ncd}.accept)));
    else
    Y(iy)=0;   Rd(iy)=0;   
    end
    
    %if (~isempty(interpolados))&&(~isempty(bad)) 
    %paso = (LAN{ncd}.tag.mat(i,:)~=interpoldos)&(LAN{ncd}.tag.mat(i,:)~=bad);   
    %%% Bluie : good in good trials
    B(iy) =  sum((logical(LAN{ncd}.accept)))-Y(iy)-G(iy);
    %%% Black : good in bad trials
    R(iy) =  sum((~logical(LAN{ncd}.accept)))-Rd(iy)-(Bk(iy));
   % elseif
    %B(iy) =  sum(LAN{ncd}.accept);
    %R(iy) =  sum(~LAN{ncd}.accept);
    %end
end
 %size(cat(2,G',B',Y',Rd',R',Bk'))
  cla(barax);
  bar(barax,cat(2,G',B',Y',Rd',R',Bk'),'Horizontal','on','BarLayout','stacked');
 ylim(barax,[1 LAN{ncd}.nbchan]);
 xlim(barax,[0 LAN{ncd}.trials]);
set(barax,'Parent',ELECTRODE,...
    'Position',[0.05 0.05 0.5 0.9],'CLim',[0.9 6.1],...
    'XLim',[1 LAN{ncd}.trials],...
    'YLim',[1 LAN{ncd}.nbchan ],...
    'YTickLabel', ytl,'YTick',yt...
    );

else
if ~ifbarax

   %claer ax
    barax = uipanel('Parent',ELECTRODE,...
    'Position',[0.05 0.05 0.5 0.9]...%'CLim',[1 6],...
    ...%'XLim',[1 LAN{ncd}.trials],...
    ...%'YLim',[1 LAN{ncd}.nbchan ],...
    ...%'YTickLabel', ytl,'YTick',yt...
    );

end

%i = 
nn = length(view_chan);
if numel(channelTextHandles) > nn
    for kk = (nn+1):numel(channelTextHandles)
        if ishghandle(channelTextHandles{kk}), delete(channelTextHandles{kk}); end
    end
    channelTextHandles = channelTextHandles(1:nn);
end
n = 1/(nn);
c = nn;
for e = sort(view_chan)
   try 
     paso = num2str(LAN{ncd}.chanlocs(1).locations{e}) ;
   catch
        paso = '';   
   end
   try
       loccc= [num2str(LAN{ncd}.chanlocs(e).X) ' ' ...
       num2str(LAN{ncd}.chanlocs(e).Y) ' ' ...
       num2str(LAN{ncd}.chanlocs(e).Z) ' ' ...
       ];
   catch
       loccc = '?'; 
   end
   labelText = [num2str(e) ' ' LAN{ncd}.chanlocs(e).labels ': ' loccc paso ' '];
   labelPos = [0.1 (c-1)*n 0.8 n];
   if numel(channelTextHandles) >= c && ishghandle(channelTextHandles{c})
       set(channelTextHandles{c},'String',labelText,'Position',labelPos);
   else
       channelTextHandles{c} = uicontrol('Parent',barax,'Style','Text',...
           'String',labelText,'Units','normalized','Position',labelPos);
   end
    c = c-1;
end

    
end



%%% search tag by trial
%%% tag
%---- Channel
if ~ifbarax;
paTAG = uipanel('Title','TAGs ()','Units','normalized','Position',[0.6, 0.1 ,0.4,0.9]);
uicontrol('Parent',paTAG ,'Units','normalized','Style','text','String','TAG',...
          'Position',[0,0.9,0.2,0.1]...%'BackgroundColor',cf,'ForegroundColor',fc
           );  
TAGat1  = uicontrol('Parent',paTAG ,'Units','normalized','Style','edit',...
           'String', ['c'],...opciones{pp,1},...
           'Position',[0.2,0.9,0.2,0.1]); 
uicontrol('Parent',paTAG ,'Units','normalized','Style','Text',...
           'String', 'trial: ',...opciones{pp,1},...
           'Position',[0.2,0.8,0.2,0.1]); 
    %%%
    uicontrol('Parent',paTAG ,'Style','pushbutton','String','Current','Units','normalized',...
              'Position',[0.2,0.75,0.2,0.05],... 'BackgroundColor',cf,... 'ForegroundColor',fc,...
              'Callback',{@TAGat1_button})
    uicontrol('Parent',paTAG ,'Style','pushbutton','String','All','Units','normalized',...
              'Position',[0.2,0.7,0.2,0.05],... 'BackgroundColor',cf,... 'ForegroundColor',fc,...
              'Callback',{@TAGat1_button})      
       
TAGat2  = uicontrol('Parent',paTAG ,'Units','normalized','Style','edit',...
           'String', ['name'],...opciones{pp,1},...
           'Position',[0.4,0.9,0.2,0.1]); 
       
uicontrol('Parent',paTAG ,'Units','normalized','Style','Text',...
           'String', 'channel name ',...opciones{pp,1},...
           'Position',[0.4,0.8,0.2,0.1]);  
       %%%
uicontrol('Parent',paTAG ,'Style','pushbutton','String','mark','Units','normalized',...
              'Position',[0.4,0.75,0.2,0.05],... 'BackgroundColor',cf,... 'ForegroundColor',fc,...
              'Callback',{@TAGat2_button})       
TAGat3  = uicontrol('Parent',paTAG ,'Units','normalized','Style','edit',...
           'String', ['bad'],...opciones{pp,1},...
           'Position',[0.6,0.9,0.2,0.1]); 
 uicontrol('Parent',paTAG ,'Units','normalized','Style','Text',...
           'String', 'tag label ',...opciones{pp,1},...
           'Position',[0.6,0.8,0.2,0.1]); 
       nlabel=length(LAN{ncd}.tag.labels);
       nlp = 0.8;
       for nl = 1:nlabel
           nlp = nlp -0.05;
           uilabels{nl}=uicontrol('Parent',paTAG ,'Units','normalized','Style','pushbutton',...
           'String', LAN{ncd}.tag.labels{nl} ,...opciones{pp,1},...
           'Position',[0.6,nlp,0.2,0.05],'Callback',{@TAGat3_button}) ;  
       end
       
%%% conditions in continuo
if  strcmp(LAN{ncd}.cond,'Continuo') && (isfield(LAN{ncd},'conditions'))
    for c = 1:length(LAN{ncd}.conditions.name)
            
    GUIcb{c} = uicontrol('Parent',paTAG ,'Style','checkbox','String',LAN{ncd}.conditions.name{c},'Units','normalized',...
              'Position',[0.1,0.7-(c/20),0.2,0.05],... 'BackgroundColor',cf,... 'ForegroundColor',fc,...
              'Callback',{@cb_conditions},'Value',LAN{ncd}.conditions.ind{c}(cnt));
    %set(GUIcb{c},LAN{ncd}.conditions.ind{c}(cnt));
    end   
   
    
end
      
       
       
uicontrol('Parent',paTAG ,'Style','pushbutton','String','OK','Units','normalized',...
          'Position',[0.8,0.9,0.1,0.1],... 'BackgroundColor',cf,... 'ForegroundColor',fc,...
         'Callback',{@TAG_button_Callback}); 
     
ERPPLOT = uicontrol('Parent',paTAG ,'Style','Edit','String','','Units','normalized',...
          'Position',[0.1,0.2,0.4,0.05]... 'BackgroundColor',cf,... 'ForegroundColor',fc,...
         );
     
if isfield(LAN{ncd}, 'RT')
     uicontrol('Parent',paTAG ,'Style','pushbutton','String','RT','Units','normalized',...
         'Position',[0.5,0.425,0.4,0.05],'ForegroundColor',[0 0 0],...... 'BackgroundColor',cf,... 
         'Callback',{@GUI_RT});
     uicontrol('Parent',paTAG ,'Style','pushbutton','String','Reject RT','Units','normalized',...
         'Position',[0.5,0.375,0.2,0.05],'ForegroundColor',[0 0 0],...... 'BackgroundColor',cf,... 
         'Callback',{@GUI_rejRT});
     rej_gui = uicontrol('Parent',paTAG ,'Style','edit','String','100','Units','normalized',...
         'Position',[0.7,0.375,0.1,0.05]);
     uicontrol('Parent',paTAG ,'Style','text','String','msec','Units','normalized',...
         'Position',[0.81,0.375,0.09,0.05]);
end
     
     
hilbert_gui =  uicontrol('Parent',paTAG ,'Style','pushbutton','String','Hilbert','Units','normalized',...
          'Position',[0.5,0.325,0.4,0.05],'ForegroundColor',[0.5 0.5 0.5],...... 'BackgroundColor',cf,... 
         'Callback',{@hilbertPLOT});         
     
FT_gui = uicontrol('Parent',paTAG ,'Style','pushbutton','String','FT cont','Units','normalized',...
          'Position',[0.5,0.275,0.4,0.05],'ForegroundColor',[0.5 0.5 0.5],...... 'BackgroundColor',cf,... 
         'Callback',{@ferpPLOT});     
     
FTerp_gui = uicontrol('Parent',paTAG ,'Style','pushbutton','String','FT plot','Units','normalized',...
          'Position',[0.5,0.225,0.4,0.05],'ForegroundColor',[0.5 0.5 0.5],...... 'BackgroundColor',cf,... 
         'Callback',{@ferpPLOT});

uicontrol('Parent',paTAG ,'Style','pushbutton','String','ERP plot','Units','normalized',...
          'Position',[0.5,0.175,0.4,0.05],... 'BackgroundColor',cf,... 'ForegroundColor',fc,...
         'Callback',{@Eerp_PLOT});       
     
uicontrol('Parent',paTAG ,'Style','pushbutton','String','Clear TAG','Units','normalized',...
          'Position',[0.1,0.1,0.4,0.05],... 'BackgroundColor',cf,... 'ForegroundColor',fc,...
         'Callback',{@clearTAG});      
uicontrol('Parent',paTAG ,'Style','pushbutton','String','Clear mark TAG','Units','normalized',...
          'Position',[0.5,0.1,0.4,0.05],... 'BackgroundColor',cf,... 'ForegroundColor',fc,...
         'Callback',{@clearMTAG});      
ifbarax=1;
else
    set(TAGat1,'String',['c']);
    set(TAGat2,'String',['name']);
    set(TAGat3,'String',['bad']);
    if length(LAN{ncd}.tag.labels)>nlabel  
       for nl = (nlabel+1):length(LAN{ncd}.tag.labels)
           nlp = nlp -0.05;
           uilabels{nl}=uicontrol('Parent',paTAG ,'Units','normalized','Style','pushbutton',...
           'String', LAN{ncd}.tag.labels{nl} ,...opciones{pp,1},...
           'Position',[0.6,nlp,0.2,0.05],'Callback',{@TAGat3_button}) ;  
       end
       nlabel=length(LAN{ncd}.tag.labels);

    end
    for nl=1:length(LAN{ncd}.tag.labels);
        try set(uilabels{nl},'String',LAN{ncd}.tag.labels{nl});end
    end
    if iscell(GUIcb) && ~isempty(GUIcb) && ...
            ishandle(GUIcb{1}) && isfield(LAN{ncd},'conditions')
    for c = 1:min(length(LAN{ncd}.conditions.name),numel(GUIcb))
        if ~ishghandle(GUIcb{c}), continue; end
        if any(LAN{ncd}.conditions.ind{c}>1)
           paso = false(size(LAN{ncd}.data));
           paso(LAN{ncd}.conditions.ind{c}) = true;
           LAN{ncd}.conditions.ind{c} = paso;
           clear paso
        end
    %GUIcb{c} = uicontrol('Parent',paTAG ,'Style','checkbox','String',LAN{ncd}.conditions.name{c},'Units','normalized',...
    %          'Position',[0.1,0.7-(c/20),0.2,0.05],... 'BackgroundColor',cf,... 'ForegroundColor',fc,...
    %          'Callback',{@cb_conditions},'Value',LAN{ncd}.conditions.ind{c}(cnt));
    set(GUIcb{c},'Value',LAN{ncd}.conditions.ind{c}(cnt));
    end
    end
end
end

%-------------------
%  RUN ICA
%-------------------
    function pp_runica(b,bb,bbb);

        clear b bb bbb
        
        tipo = get(Algo,'string');
        tipo = tipo{get(Algo,'Value')};
        switch tipo
            case 'runica'
                
                tncomp = eval([ '[' get(nbCOMP_GUI,'String') ']']);
                if isempty(tncomp)
                    tncomp = LAN{ncd}.nbchan-1;
                elseif tncomp<1
                    tncomp = LAN{ncd}.nbchan + tncomp;
                end
                set(nbCOMP_GUI,'String',num2str(tncomp))
             
                disp(['runica(LAN,data,''extended'', 1,''pca'',' num2str(tncomp) ' );'])
                
                sel_eeg_ica = logical(fun_in_cell({LAN{ncd}.chanlocs.type}, 'strcmp(@, ''EEG'')'));
                data_eeg_ica = cat(2,LAN{ncd}.data{logical(LAN{ncd}.accept)});
                data_eeg_ica = data_eeg_ica(sel_eeg_ica,:);
                
            [weights,sphere] = runica(data_eeg_ica,'extended', 1,'pca',tncomp);
            LAN{ncd}.ica_weights = weights;
            LAN{ncd}.ica_sphere = sphere;
            LAN{ncd}.ica_select = find(sel_eeg_ica);
            set(guiplotICA,'ForegroundColor',fc)
            
        end
    end
%-------------------
%  Change component 
%-------------------
    function comp_c(b,bb,bbb);
    %clear(gca)
    % dtat to plot
    
    op = get(b,'String');
    switch op
        case '<'
            ncomp=ncomp-1;
        case '>'
            ncomp=ncomp+1;
        case 'Mark'
            R = get(b,'BackgroundColor');
            if R(2)==1
                set(compE,'String', [ get(compE,'String') ' ' num2str(ncomp) ]);
                set(b,'BackgroundColor','red') 
            else
                Sel = eval([ '[' get(compE,'String') ']' ]);
                Sel(Sel==ncomp) = [];
                set(compE,'String', num2str(Sel));
                set(b,'BackgroundColor','white') 
            end
        otherwise
            ncomp=eval(op);
    end
    % Wrap over the ACTUAL number of ICA components (may be < nbchan).
    nICA = size(LAN{ncd}.ica_weights,1);
    if nICA > 0 && isnumeric(ncomp) && isscalar(ncomp) && isfinite(ncomp)
        ncomp = mod(round(ncomp)-1,nICA)+1;
    else
        ncomp = 1;
    end
    plot_comp()         
    end

%-------------------
%  PLOT ICA componente
%-------------------
    function plot_comp(b,bb,bbb)
        clear b bb bbb
        if isfield(LAN{ncd},'ica_weights') &&  ~isempty(LAN{ncd}.ica_weights);
            % Keep component navigation valid after changing conditions/PCA rank.
            nICA = size(LAN{ncd}.ica_weights,1);
            ncomp = mod(round(ncomp)-1,nICA)+1;

            if size(LAN{ncd}.ica_weights,1)==size(LAN{ncd}.ica_weights,2);
                winv = inv(LAN{ncd}.ica_weights*LAN{ncd}.ica_sphere);
            else
                winv = pinv(LAN{ncd}.ica_weights*LAN{ncd}.ica_sphere);
            end 
            
            
            
            
            if ~isempty(topoICA) && ishghandle(topoICA)
                clf(topoICA); % reuse the same window and its position
                set(topoICA,'Visible','on');
            else
                topoICA = figure('Visible','on','Units','normalized',...
                   'Position',p_ica,...
                   'Name','ICA calulated','NumberTitle','off','MenuBar','none',...
                   'CloseRequestFcn',@close_ica);
            end
            figure(topoICA);
            editF
            axes('Parent',topoICA,'Position',[0.01 0.1 0.4 0.7]);
            if ~isfield(LAN{ncd}, 'ica_select');
                LAN{ncd}.ica_select = 1:LAN{ncd}.nbchan;
            end
                
                
            figure(topoICA); % topoplot_lan draws into gca
            topoplot_lan(winv(:,ncomp),LAN{ncd}.chanlocs(LAN{ncd}.ica_select));
            uicontrol(topoICA,'Style','pushbutton','String','<','Units','normalized',...
                      'Position',[0.05, 0.85 ,0.1,0.15],...'BackgroundColor',bc,'ForegroundColor',fc,...
                      'Callback',{@comp_c});
            uicontrol(topoICA,'Style','pushbutton','String','>','Units','normalized',...
                      'Position',[0.25, 0.85 ,0.1,0.15],...'BackgroundColor',bc,'ForegroundColor',fc,...
                      'Callback',{@comp_c}); 
            uicontrol(topoICA,'Style','Edit','String',num2str(ncomp),'Units','normalized',...
                      'Position',[0.15, 0.85 ,0.1,0.15],...'BackgroundColor',bc,'ForegroundColor',fc,...
                      'Callback',{@comp_c});
                  if any(str2num(get(compE,'String'))==ncomp)
                      pasoc = 'red';
                  else
                      pasoc=[1 1 1];
                  end
            uicontrol(topoICA,'Style','pushbutton','String','Mark','Units','normalized',...
                      'Position',[0.15, 0.75 ,0.1,0.1],'BackgroundColor',pasoc,...,'ForegroundColor',fc,...
                      'Callback',{@comp_c});      
                  
                  
                  
            axICATrials = axes('Parent',topoICA,'Position',[0.54 0.31 0.40 0.26]);
            %if strcmp( get(electrode_comp,'String') ,'Showing: electrodes')
                W = LAN{ncd}.ica_weights*LAN{ncd}.ica_sphere;
            %else
            %    W=eye(size(LAN{ncd}.ica_weights));
            %end
                for t =1:LAN{ncd}.trials
                    if LAN{ncd}.accept(t)
                    D{t} = (LAN{ncd}.data{t} - repmat( mean(LAN{ncd}.data{t},2),[ 1 length(LAN{ncd}.data{t})])  ); 
                    % Only project the displayed ICA component. This is
                    % equivalent to selecting row ncomp of W*D, but avoids
                    % materializing every component for every accepted trial.
                    D{t} = W(ncomp,:)*D{t}(LAN{ncd}.ica_select,:);
                    end
                end
                Tm = timelan(LAN{ncd});

                % PSD from each accepted trial BEFORE the epoch-length crop.
                % Use the original activation saved by LAN when a component
                % has already been removed (LAN.ica_del_comp).
                [psdHz,psdDB,psdN,psdWinSec,psdP25,psdP75] = ...
                    ICA_component_PSD(D,LAN{ncd},ncomp);

                % min time por trial with diferent duration 
                min_p = fix(min((LAN{ncd}.time(LAN{ncd}.accept,2) - LAN{ncd}.time(LAN{ncd}.accept,1) )* LAN{ncd}.srate));
                for  t =1:LAN{ncd}.trials
                    if LAN{ncd}.accept(t)
                    D{t} = D{t}(:,1:min_p);
                    end
                end    
                Tm = Tm(1:min_p);
                D = cat(3,D{LAN{ncd}.accept});
                if isfield(LAN{ncd}, 'ica_del') && any(LAN{ncd}.ica_del==ncomp);
                D = cat(3,LAN{ncd}.ica_del_comp{LAN{ncd}.accept});    
                D = D(LAN{ncd}.ica_del==ncomp,1:min_p,:);
                else
                D = D(1,:,:); % already selected component ncomp
                end
                axes(axICATrials);  % pcolor2 uses the active axes
                pcolor2(Tm,1:size(D,3),squeeze(D)');
                shading(axICATrials,'flat');
            axICAMean = axes('Parent',topoICA,'Position',[0.54 0.10 0.40 0.12]);
                plot(axICAMean,Tm,squeeze(mean(D,3)));
                xlim(axICAMean,[Tm(1) Tm(end)]);

            % Component power spectrum: same accepted trials as the raster.
            % Dedicated axes prevent the PSD from overwriting EEG/ICA panels.
            axICAPSD = axes('Parent',topoICA,'Position',[0.54 0.68 0.40 0.23]);
            if ~isempty(psdHz)
                psdColor = [0.1 0.35 0.65];
                % The IQR describes trial-to-trial variability in dB/Hz.
                % Draw it first, behind the original mean-power PSD curve.
                if psdN >= 2 && ~isempty(psdP25) && ~isempty(psdP75)
                    patch('Parent',axICAPSD, ...
                        'XData',[psdHz(:); flipud(psdHz(:))], ...
                        'YData',[psdP25(:); flipud(psdP75(:))], ...
                        'FaceColor',psdColor,'FaceAlpha',0.20, ...
                        'EdgeColor','none','HitTest','off');
                    hold(axICAPSD,'on');
                end
                plot(axICAPSD,psdHz,psdDB,'LineWidth',1.2, ...
                    'Color',psdColor);
                hold(axICAPSD,'off');
                xlim(axICAPSD,[1 min(45, LAN{ncd}.srate/2)]);
                title(axICAPSD,sprintf('PSD mean + P25-P75 | %d trials | %.2f s', ...
                    psdN,psdWinSec),'FontSize',9);
            else
                text(0.5,0.5,'PSD unavailable (insufficient data or pwelch missing)', ...
                    'Parent',axICAPSD,'Units','normalized', ...
                    'HorizontalAlignment','center','FontSize',8);
                xlim(axICAPSD,[0 1]);
                ylim(axICAPSD,[0 1]);
            end
            xlabel(axICAPSD,'Frequency (Hz)');
            ylabel(axICAPSD,'Power (dB/Hz)');
            grid(axICAPSD,'on');
            
                  
        else
            warning('Not ICA components computed!!')
        end
        
    end

    % PSD averaged across accepted trials (never concatenating trials).
    % The ICA scale is arbitrary, so interpret spectral SHAPE rather than
    % absolute levels when comparing different components.
    function [freqShow,powerDB,nUsed,winSeconds,p25DB,p75DB] = ICA_component_PSD(Dtrials,lanICA,compIndex)
        freqShow = [];
        powerDB = [];
        p25DB = [];
        p75DB = [];
        nUsed = 0;
        winSeconds = NaN;

        if exist('pwelch','file') == 0 || ...
                ~isfield(lanICA,'srate') || lanICA.srate <= 2
            return;
        end

        fsICA = lanICA.srate;
        accepted = find(logical(lanICA.accept));
        signals = cell(1,numel(accepted));
        keep = false(1,numel(accepted));
        delIndex = [];
        if isfield(lanICA,'ica_del')
            delIndex = find(lanICA.ica_del == compIndex,1);
        end

        for k = 1:numel(accepted)
            t = accepted(k);
            if ~isempty(delIndex) && isfield(lanICA,'ica_del_comp') && ...
                    t <= numel(lanICA.ica_del_comp) && ...
                    ~isempty(lanICA.ica_del_comp{t})
                x = lanICA.ica_del_comp{t}(delIndex,:);
            elseif ~isempty(delIndex)
                % No stored original waveform: do not use residual data.
                continue;
            elseif t <= numel(Dtrials) && ~isempty(Dtrials{t})
                x = Dtrials{t}(1,:); % single displayed component
            else
                continue;
            end
            x = double(x(:));
            if numel(x) < 16 || any(~isfinite(x))
                continue;
            end
            signals{k} = x;
            keep(k) = true;
        end
        signals = signals(keep);
        if isempty(signals)
            return;
        end

        % Common window for comparable trial PSD estimates (2 s maximum).
        lengths = cellfun(@numel,signals);
        winN = min([max(16,round(2*fsICA)), lengths]);
        if winN < 16
            return;
        end
        winSeconds = winN/fsICA;
        win = hamming(winN);
        overlap = floor(winN/2);
        nfft = max(256,2^nextpow2(winN));
        powerSum = [];
        powerByTrial = [];
        freqs = [];
        for k = 1:numel(signals)
            % Demeaning prevents DC offsets from obscuring the spectrum.
            signal = signals{k} - mean(signals{k});
            [p,f] = pwelch(signal,win,overlap,nfft,fsICA);
            if isempty(powerSum)
                powerSum = zeros(size(p));
                powerByTrial = zeros(numel(p),numel(signals));
                freqs = f;
            end
            powerSum = powerSum + p;
            powerByTrial(:,k) = p;
            nUsed = nUsed + 1;
        end
        limHz = min(45,fsICA/2);
        show = freqs >= 1 & freqs <= limHz;
        if ~any(show)
            nUsed = 0;
            return;
        end
        freqShow = freqs(show);
        % Preserve the original PSD: average linear power, then convert to dB.
        powerDB = 10*log10(max(powerSum(show)/nUsed,realmin));
        if nUsed >= 2
            % Percentiles are calculated across trials at each frequency,
            % on the same log-power scale displayed by the PSD axes.
            powerTrialsDB = 10*log10(max(powerByTrial(show,:),realmin));
            p25DB = prctile(powerTrialsDB,25,2);
            p75DB = prctile(powerTrialsDB,75,2);
        end
    end

    function close_ica(b, bb, bbb)
        p_ica=get(topoICA,'Position');
        delete(topoICA)
        ifGUI_ica =  0;
    end
%------------------------
%-- shift data/componente              EN CONSTRUCCION
%------------------------
    function shift_comp_elect(b,bb,bbb)
    op = get(b,'String');
    if iscell(op), op = op{1};,end
    switch op
        case 'Showing: electrodes'
            if isfield(LAN{ncd},'ica_weights')
                set(b,'String','Showing: components')
                view_comp=1;
                
           W = LAN{ncd}.ica_weights*LAN{ncd}.ica_sphere;
           
           if ~isfield(LAN{ncd}, 'ica_select')
               LAN{ncd}.ica_select=1:LAN{ncd}.nbchan;
           end
           
           view_chan = 1:size(W,1);
           for e = 1:size(W,1);
           Nlables{e} = [ 'Co' num2str(e) ];      
           end 
           
           for t =1:LAN{ncd}.trials
               comp_data{t} = W*LAN{ncd}.data{t}(LAN{ncd}.ica_select,:);   
           end
           close(EEG)
           EEGplot(cnt,Nlables)
           end
            
        case 'Showing: components'
           set(b,'String','Showing: electrodes') 
               view_comp=0;
           view_chan = 1:LAN{ncd}.nbchan;
           for e = 1:LAN{ncd}.nbchan;
           Nlables{e} = [  LAN{ncd}.chanlocs(e).labels ];      
           end 
%            
%            invW = pinv(LAN{ncd}.ica_weights*LAN{ncd}.ica_sphere); 
%            
%            for t =1:LAN{ncd}.trials
%                LAN{ncd}.data{t} = (invW)*LAN{ncd}.data{t};   
%            end 
           close(EEG)
           EEGplot(cnt,Nlables)
        case 'Del Components'
          if strcmp(get(electrode_comp,'String'),'components')
             shift_comp_elect(electrode_comp) 
          end
            ind_x = eval([ '[' get( compE, 'String') '];']);
            LAN{ncd} = lan_rm_chan(LAN{ncd}, ind_x,'ica');
        ifdatahil = false; ifdataft = false;
            set(compE,'String',['[' num2str(sort(LAN{ncd}.ica_del)) ']'])
          EEGplot(cnt)
    %Nlabels 
    %
    end
    
    end
%-------------------
%  FT plot com
%-------------------
    function FT_CON(b,bb,bbb)
        if isequal(b,1)
           % Reuse the spectrogram only while the same trial is displayed.
           ifdataft = logical(ifdataft) && isequal(ftLastTrial,cnt) && ...
                      isequal(ftLastCond,ncd);
        else
           ifdataft = false; 
        end
        if nargin >= 2
            nt = bb;
        end
        
        clear bb bbb
        COMP_FT_CON
       
        
        

        
        nM= label2idx_elec(LAN{ncd}.chanlocs,M);
        
        
        
        
        if ~ifdataft
           if isstruct(LAN{ncd}.freq.powspctrm) 
               if size(LAN{ncd}.freq.powspctrm,1)>1
                 dataft = lan_getdatafile(LAN{ncd}.freq.powspctrm(nM,1).filename,...
                      LAN{ncd}.freq.powspctrm(nM,1).path,...
                      LAN{ncd}.freq.powspctrm(nM,1).trials);
                  dataft =dataft{1};
               else
                 dataft = lan_getdatafile(LAN{ncd}.freq.powspctrm(1,1).filename,...
                      LAN{ncd}.freq.powspctrm(1,1).path,...
                      LAN{ncd}.freq.powspctrm(1,1).trials); 
                 dataft = dataft{1}(:,nM,:);
               end
               dataft = lan_smooth2d(squeeze(dataft),4,.4,nsmooth);
           else
               dataft = lan_smooth2d(squeeze(LAN{ncd}.freq.powspctrm{cnt}(:,nM,:)),4,.4,nsmooth);
           end
           
           dataN = dataft;
           dataN(:,~LAN{ncd}.selected{cnt}) = NaN;
           
           switch nor_ft
               case 'z'
               dataft = normal_z(dataft,dataN);
               case 'log10(e)'
               dataft = log10(dataft,dataN); 
               case 'dB'
               dataft = 10*(log10(dataft)-repmat(log10(mean_nonan(dataft,2)),[1,size(dataft,2)]));              
           end
           ifdataft = true;
           ftLastTrial = cnt;
           ftLastCond = ncd;
           clear dataN
        end
        
        if (size(dataft,2)-LAN{ncd}.pnts)>-10;
            rz=1;
        else
            rz =  size(dataft,2)/LAN{ncd}.pnts(cnt); %% chequear
        end
        
        if ifcon
            serietime = ceil(ini_p*rz):ceil(fin_p*rz);
        else
            serietime = 1:length(LAN{ncd}.freq.time);%(0:LAN{ncd}.pnts(nt)-1)+LAN{ncd}.time(nt,3);
        end
        if ~ifaxft || ~ishghandle(axft)
            axft = axes('Parent',GUI_FT_CON,...
                'Position',[0.05 0.1 0.9 0.85]);
            caxis_ft_gui = uicontrol('Parent',GUI_FT_CON,'Style','Edit',...
                'String',num2str(caxis_ft),'Units','normalized',...
                'Position',[0.95 0.5 0.05 0.1],'Callback',@caxis_ft_edt);
            uicontrol('Parent',GUI_FT_CON,'Style','popup',...
                'String',{'z','dB','e','log10(e)'},'Units','normalized',...
                'Position',[0.95 0.61 0.05 0.1],'Callback',@nor_ft_edt);
            uicontrol('Parent',GUI_FT_CON,'Style','edit','String',num2str(nsmooth),...
                'Units','normalized','Position',[0.95 0.71 0.05 0.09],...
                'Callback',@smooth_ft_edt);
            uicontrol('Parent',GUI_FT_CON,'Style','text','String','smooth',...
                'Units','normalized','Position',[0.95 0.81 0.05 0.09]);
            colormap(axft,hot(200));
            colorbar('peer',axft,'Position',[0.9625 0.05 0.025 0.4]);
            ifaxft = 1;
        else
            cla(axft);
        end
        % The axes belongs to the FT figure, even if another GUI has focus.
        pcolor(axft,LAN{ncd}.freq.time(serietime),LAN{ncd}.freq.freq,...
            double(squeeze(dataft(:,serietime))));
        shading(axft,'interp');
        xlabel(axft,'Time(Second)');
        ylabel(axft,'Frequency(Hz)');
        caxis(axft,caxis_ft);

    end


%-------------------
%  Hilbert plot 
%-------------------
    function HIL_plot(b,bb,bbb)
        if isequal(b,1)
            ifdatahil = logical(ifdatahil) && isequal(hilLastTrial,cnt) && ...
                        isequal(hilLastCond,ncd);
        else
            ifdatahil = false;
        end
        
        clear bb bbb
        COMP_HIL_plot
        
          if strcmp(M,'mark')
                nM = find(r_elec{ncd}(:,cnt))';% busca todos los electrodos marcados

          else
                %[n LAN{ncd}.tag] = getntag(LAN{ncd}.tag,label);
                nM = getncha(LAN{ncd}.chanlocs,M);     
          end
          % The marked-channel selection can change within the same trial.
          if ifdatahil && ~isequal(hilLastChannels,nM)
              ifdatahil = false;
          end
        
        if ~ifdatahil
            datahilsmooth = cell(1,size(cfghilbert,1));
            paso = (LAN{ncd}.data{cnt}(nM,:))';
            for nh =  1:size(cfghilbert,1)
                 sign = ones(size(paso));
                 nborde = ceil(( 1/(min(cfghilbert{nh})-0.5) ) * LAN{ncd}.srate );
                 win = hann(4*nborde+1);
                 sign(1:2*nborde,:) = repmat(win(1:2*nborde),[1,size(paso,2)]);
                 sign(end-2*nborde-1:end,:) = repmat(win(end-2*nborde-1:end),[1,size(paso,2)]);
                
               DA = filter_hilbert( paso.*sign     ,LAN{ncd}.srate,min(cfghilbert{nh}),max(cfghilbert{nh}),norbin(nh,1))';
               % no include unselected areas
               DAN = DA;
               DAN(:,~LAN{ncd}.selected{cnt}) = NaN;
               datahil{nh} = (normal_z(DA,DAN))' ; 
               clear DA DAN
               
               if strcmp(hilsmooth,'Smooth')&&Hil_span(nh)>0;
                   datahilsmooth{nh} = [];
                   for dm = 1:size(datahil{nh},2)    
                        datahilsmooth{nh}(:,dm) = smooth(abs(datahil{nh}(:,dm) ),Hil_span(nh));
                   end
               elseif strcmp(hilsmooth,'Rectified')&&Hil_span(nh)>0; 
                   datahilsmooth{nh} = [];
                    for dm = 1:size(datahil{nh},2)   
                    datahilsmooth{nh}(:,dm) = (lan_rectified(datahil{nh}(:,dm) ,Hil_span(nh),LAN{ncd}.srate,2)); 
                    end
               end
            end
           ifdatahil = true;
           hilLastTrial = cnt;
           hilLastCond = ncd;
           hilLastChannels = nM;
        end
         rz=1;
          if ifcon
            ini_p = fix(1 + ((n_ini-1 )* l_seg));
            fin_p = fix(ini_p + (l_seg -1));
            if fin_p >LAN{ncd}.pnts
             fin_p = LAN{ncd}.pnts;
             ini_p = fix(fin_p - (l_seg -1));
            end
            ltime =linspace((ini_p-1)/LAN{ncd}.srate,(ini_p-1+l_seg)/LAN{ncd}.srate, l_seg);   
            else 
            ltime =linspace(LAN{ncd}.time(cnt,1),LAN{ncd}.time(cnt,2), LAN{ncd}.pnts(cnt));    
           end
       
        if ~ifaxhil || ~ishghandle(axhil)
            axhil = axes('Parent',GUI_HIL_plot,...
                'Position',[0.05 0.1 0.9 0.85]);
            ifaxhil = 1;
        else
            cla(axhil);
        end
        hold(axhil,'on');
        Rec = 0;
        for nh = 1:size(cfghilbert,1)
            Rec = 0; % Original per-band offset convention
            for dm = 1:size(datahil{nh},2)
                idx = ceil(ini_p*rz):ceil(fin_p*rz);
                yy = datahil{nh}(idx,dm);
                plot(axhil,ltime,real(yy)+Rec,'b');
                plot(axhil,ltime, abs(yy)+Rec,'k');
                plot(axhil,ltime,-abs(yy)+Rec,'k');
                if Hil_span(nh)>1 && numel(datahilsmooth)>=nh && ...
                        ~isempty(datahilsmooth{nh})
                    plot(axhil,ltime,datahilsmooth{nh}(idx,dm)+Rec,'r','LineWidth',2);
                end
                if size(datahil{nh},2)==1
                    phaseTrace = mean(abs(yy))*(angle(yy)/pi) - 3*mean(abs(yy));
                    plot(axhil,ltime,phaseTrace,'red');
                end
                Rec = Rec - 6;
            end
        end
        hold(axhil,'off');
        ylabel(axhil,'uV');
        xlabel(axhil,'Time(Second)');
        ylim(axhil,[Rec+2 4]);
        title(axhil,M);

    end

%-------------------
%  GUI reject rt
%-------------------
    function GUI_rejRT(b,bb,bbb)
        if LAN{ncd}.trials == 1
            win = eval( get(rej_gui, 'string') );
            win = win * LAN{ncd}.srate / 1000;
            win = floor(win / 2); % half win
            laten = LAN{ncd}.RT.latency * LAN{ncd}.srate / 1000;
            for c = 1:length(laten)
                seq = laten(c)-win:laten(c)+win;
                seq = seq( seq>0 & seq<=LAN{ncd}.pnts(1) );
                LAN{ncd}.selected{1}(seq) = false;
            end
            ifdataft = false; ifdatahil = false;
            EEGplot(cnt);
        else
            disp('For unsegmented signals only');
        end
    end
%-------------------
%  GUI rt
%-------------------
    function GUI_RT(b,bb,bbb)

        
        clear b  bb bbb
        COMP_guirt
        
        %nM= label2idx_elec(LAN{ncd}.chanlocs,M);

          if ifcon
            ini_p = fix(1 + ((n_ini-1 )* l_seg));
            fin_p = fix(ini_p + (l_seg -1));
            if fin_p >LAN{ncd}.pnts
             fin_p = LAN{ncd}.pnts;
             ini_p = fix(fin_p - (l_seg -1));
            end
            ltime =( linspace((ini_p-1)/LAN{ncd}.srate,(ini_p-1+l_seg)/LAN{ncd}.srate, l_seg));   
            else 
            ltime =(linspace(LAN{ncd}.time(cnt,1),LAN{ncd}.time(cnt,2), LAN{ncd}.pnts(cnt)));
            dtime = LAN{ncd}.time(:,2)-LAN{ncd}.time(:,1);
            dtime = cat(1,0,cumsum(dtime(1:end)));
          end
       
            if isempty(axrt) || ~ishghandle(axrt)
                axrt = axes('Parent',guirt,...
                    'Position',[0.05 0.1 0.9 0.85]);
            else
                cla(axrt);
            end
            % Remove only RT event markers; retain all EEG traces.
            if ifax && ishghandle(ax)
                delete(findall(ax,'Tag','LAN_RTMarker'));
            end
            
            if ifcon % indice de enventos a plotear
               ind =  (LAN{ncd}.RT.latency>=1000*min(ltime))&(LAN{ncd}.RT.latency<=1000*max(ltime));
            else
               ind =  (LAN{ncd}.RT.latency>=(1000*(min(ltime)+(LAN{ncd}.time(cnt,3)/LAN{ncd}.srate))))&...
                      (LAN{ncd}.RT.latency<=(1000*(max(ltime)+(LAN{ncd}.time(cnt,3)/LAN{ncd}.srate)))); 
            end
            
               lim =[];
               pasoe = LAN{ncd}.RT.est(LAN{ncd}.RT.est>0);
               pasor = LAN{ncd}.RT.resp(LAN{ncd}.RT.est>0);
               pasot = unique(cat(2,pasoe,pasor));
               lim(1) = 0.5;
               lim(2) = length(pasot)+0.5;
               
               if diff(lim) == 0; lim(2)=lim(2)+1;end;
               set(axrt,'xlim',[ min(ltime) max(ltime)],'ylim',lim)
               if any(ind)
                   
               % compatibility    
               if ~isfield(LAN{ncd}.RT,'good')
                  LAN{ncd}.RT.good = true(size(LAN{ncd}.RT.est));
               end
                   
               LL = LAN{ncd}.RT.latency(ind);
                    for nrt = find(ind==1)
                    
                        
                    %if isfield(LAN{ncd}.RT,'chan')
                        % est
                        yye = find(pasot==LAN{ncd}.RT.est(nrt))  ;                    
                        yyr = find(pasot==LAN{ncd}.RT.resp(nrt)) ;
                    %end
                    %if (yy <1)||(yy >LAN{ncd}.nbchan)||isempty(yy)||~isnumeric(yy);
                    %    yy =LAN{ncd}.nbchan/2; 
                    %end
                    
                    if ifcon
                        xxt =LAN{ncd}.RT.latency(nrt)/1000;
                    else
                        xxt =(LAN{ncd}.RT.latency(nrt)/1000) -(LAN{ncd}.time(cnt,3)/LAN{ncd}.srate) ;
                    end
                    
                    
                    if LAN{ncd}.RT.est(nrt)~=-99 % green = event
                    if LAN{ncd}.RT.good(nrt), color_tc = 'green'; else  color_tc = [0.5 0.5 0.5]; end
                         if isfield(LAN{ncd}.RT,'OTHER') && isfield(LAN{ncd}.RT.OTHER,'names')
                             txt = LAN{ncd}.RT.OTHER.names{nrt};
                         else
                             txt =num2str(LAN{ncd}.RT.est(nrt));
                         end
                         if isnumeric(txt), txt=num2str(txt);end
                         text(xxt,yye,txt,...
                        'Parent',axrt,'Color',color_tc,'FontSize',12,'userdata',nrt, ...
                        'buttondownfcn', @event_green)
                         if ifax
                         line([xxt xxt],[ get(ax,'ylim') ],...
                        'Parent',ax,'Color',[0.6 0.6 0.6],'Tag','LAN_RTMarker') ;
                         end
                        
                    if isfield(LAN{ncd}.RT,'resp') && LAN{ncd}.RT.resp(nrt)~=-99
                         if LAN{ncd}.RT.good(nrt), color_tc = 'red'; else  color_tc = [0.5 0.5 0.5]; end    
                         text( (LAN{ncd}.RT.latency(nrt)+LAN{ncd}.RT.rt(nrt))/1000,yye,num2str(LAN{ncd}.RT.est(nrt)),...
                        'Parent',axrt,'Color',color_tc,'FontSize',12, 'userdata',nrt, ...
                        'buttondownfcn',@event_red)                    
                    end
                    end
                    
                    
                    end
               end
%             for nh =  1:size(cfghilbert,1)
%             plot(ltime, ... time
%                    real(datahil{nh}(ceil(ini_p*rz):ceil(fin_p*rz))), 'b'); hold on;
%             plot(ltime, ... time
%                    abs(datahil{nh}(ceil(ini_p*rz):ceil(fin_p*rz))), 'k')
%             plot(ltime, ... time
%                    -abs(datahil{nh}(ceil(ini_p*rz):ceil(fin_p*rz))), 'k')   
%             plot(ltime,   mean(abs(datahil{nh}(ceil(ini_p*rz):ceil(fin_p*rz))))*(angle(datahil{nh}(ceil(ini_p*rz):ceil(fin_p*rz)))/pi) - 3*mean(abs(datahil{nh}(ceil(ini_p*rz):ceil(fin_p*rz)))) ,'red'  ); 
%             hold off   
%             ylabel('uV'),xlabel('Time(Second)')
%             
%             %shading interp, colormap(hot(200)), caxis(axft, caxis_ft)
%             end
            

            %end
            %title(M)
            

        
        

    end
%-------------------

%-------------------
%  EEGplot
%-------------------
function EEGplot_button(source,eventdata,handles) 
    EEGplot(cnt)
end
%-------------------
%  MAS
%-------------------
function MAS_button_Callback(source,eventdata,handles) 
    if ifcon
        
         n_ini= n_ini+1;
         if n_ini > floor(LAN{ncd}.pnts/l_seg)+1;
         n_ini = n_ini -1;
         return        
         end
        
    else
    if strcmp(get(source, 'String'),'R>');
        r = find(LAN{ncd}.accept==0);
        ri = find(r>cnt,1,'first');
        if ~isempty(ri)
            cnt = r(ri);
        end
    elseif strcmp(get(source, 'String'),'D>');
        r = find((LAN{ncd}.accept==0)|any(LAN{ncd}.tag.mat));
        ri = find(r>cnt,1,'first');
        if ~isempty(ri)
            cnt = r(ri);
        end    
    elseif strcmp(get(source, 'String'),'A>');
        r = find((LAN{ncd}.accept==1));
        ri = find(r>cnt,1,'first');
        if ~isempty(ri)
            cnt = r(ri);
        end
       elseif strcmp(get(source, 'String'),'N>');
       try
           
           if n_detec ~= evalin('base','lan_temp_var.n_detec')
            n_detec = evalin('base','lan_temp_var.n_detec');
            
            disp('######## LAN #######################')
            disp('#   using:                          #')
            disp(['#   lan_temp_var.n_detec =  [' num2str(n_detec) ']   #'])
            disp('####################################')
           end
      
       catch
           % n_detec =2;   
       end
        
        r = find((LAN{ncd}.accept==0)|(sum(LAN{ncd}.tag.mat>0,1) >= n_detec));
        ri = find(r>cnt,1,'first');
        if ~isempty(ri)
            cnt = r(ri);
        end    
    else
    cnt = cnt+1;
    if cnt > LAN{ncd}.trials
        cnt=LAN{ncd}.trials;
        return        
    end
    end
    
 
    end
  EEGplot(cnt) 
end
%-------------------
%  MENOS
%-------------------
function MENOS_button_Callback(source,eventdata,handles)
    if ifcon
    n_ini = n_ini-1;
    if n_ini < 1
        n_ini=1;
        return
    end 
        
        
    else
    if strcmp(get(source, 'String'),'<R');
        r = find(LAN{ncd}.accept==0);
        ri = find(r<cnt,1,'last');
        if ~isempty(ri)
            cnt = r(ri);
        end
    elseif strcmp(get(source, 'String'),'<D');
        r = find((LAN{ncd}.accept==0)|any(LAN{ncd}.tag.mat));
        ri = find(r<cnt,1,'last');
        if ~isempty(ri)
            cnt = r(ri);
        end
   elseif strcmp(get(source, 'String'),'<N');
       try
           if n_detec ~= evalin('base','lan_temp_var.n_detec')
            n_detec = evalin('base','lan_temp_var.n_detec');
            
          disp('######## LAN #######################')
          disp('#   using:                          #')
          disp(['#   lan_temp_var.n_detec =  [' num2str(n_detec) ']   #'])
          disp('####################################')
           end
            
       catch
            %n_detec =2;   
       end
        
        r = find((LAN{ncd}.accept==0)|(sum(LAN{ncd}.tag.mat,1) >= n_detec));
        ri = find(r<cnt,1,'last');
        if ~isempty(ri)
            cnt = r(ri);
        end     
    elseif strcmp(get(source, 'String'),'<A');
        r = find((LAN{ncd}.accept==1));
        ri = find(r<cnt,1,'last');
        if ~isempty(ri)
            cnt = r(ri);
        end     
    else
    cnt = cnt-1;
    if cnt < 1
        cnt=1;
        return
    end 
    end
    end
 EEGplot(cnt)  
end

%-------------------
%  ELECTRODE VIEW
%-------------------

function view_chan_button_Callback(source,eventdata,handles) 
    stre = get(source, 'String');
        view_chan = evalin('base',['[' stre ']']);
    if min(view_chan)<1
    view_chan(view_chan==min(view_chan)) = 1;
    %else
    %view_chan(1) = min(stre);
    end
    if max(view_chan) > LAN{ncd}.nbchan;
    view_chan(view_chan>LAN{ncd}.nbchan) = LAN{ncd}.nbchan;    
    %else
    %view_chan(2) = max(stre);
    end
    view_chan = sort(unique(view_chan));
    disp(['view channels: ' num2str(view_chan) ])
    %set(view_chan_eeg)
    close(EEG)
    elecbot=[];
    EEGplot(cnt)
end
%-------------------
%  CAMBIO SELECTION
%-------------------
    function C_selected(source,eventdata,handles)
    d = get(source,'CurrentPoint');
    d = fix(d(1));
    d = min(max(d,1),numel(LAN{ncd}.selected{cnt}));
    
    if numel(selectP)~=1
       selectP = d;
       disp(['selected points = ' num2str(selectP)])
    else
       selectP(2) = d;
       if any(~LAN{ncd}.selected{cnt}(min(selectP):max(selectP)))
          LAN{ncd}.selected{cnt}(min(selectP):max(selectP)) = true;
       else
          LAN{ncd}.selected{cnt}(min(selectP):max(selectP)) = false; 
       end
       
       disp(['select points = ' num2str(selectP)])
       selectP = [];
       ifdataft = false;
       ifdatahil = false;
       EEGplot(cnt)
    end
    
    end


%-------------------
%  CAMBIO
%-------------------
function CAMBIO_button_Callback(source,eventdata,handles)
   if ifcon
      if strcmp(get(GUIMENOS, 'String'),'<0.5');
      set(GUIMENOS, 'String','<1');
      set(GUIMAS, 'String','1>');
   elseif strcmp(get(GUIMENOS, 'String'),'<1');
      set(GUIMENOS, 'String','<1.5');
      set(GUIMAS, 'String','1.5>');
   elseif strcmp(get(GUIMENOS, 'String'),'<1.5');
      set(GUIMENOS, 'String','<');
      set(GUIMAS, 'String','>');
   elseif strcmp(get(GUIMENOS, 'String'),'<');
      set(GUIMENOS, 'String','<0.5');
      set(GUIMAS, 'String','0.5>');   
   end   
       
       
       
   else
   if strcmp(get(GUIMENOS, 'String'),'<R');
      set(GUIMENOS, 'String','<D');
      set(GUIMAS, 'String','D>');
   elseif strcmp(get(GUIMENOS, 'String'),'<D');
      set(GUIMENOS, 'String','<A');
      set(GUIMAS, 'String','A>');
   elseif strcmp(get(GUIMENOS, 'String'),'<A');
      set(GUIMENOS, 'String','<');
      set(GUIMAS, 'String','>');
  elseif strcmp(get(GUIMENOS, 'String'),'<');
      set(GUIMENOS, 'String','<N');
      set(GUIMAS, 'String','N>'); 
      try
      n_detec = evalin('base','lan_temp_var.n_detec');
      end
      disp('######## LAN #######################')
      disp('#   using:                          #')
      disp(['#   lan_temp_var.n_detec =  [' num2str(n_detec) ']   #'])
      disp('####################################')

   elseif strcmp(get(GUIMENOS, 'String'),'<N');
      set(GUIMENOS, 'String','<R');
      set(GUIMAS, 'String','R>');   
   end
   end
end    
%-------------------
%  REJECT
%-------------------
function REJECT_button_Callback(source,eventdata,handles) 
    if ~isfield(LAN{ncd},'accept')
        LAN{ncd}.accept = true(1,LAN{ncd}.trials);
    end
    if LAN{ncd}.accept(cnt)
         LAN{ncd}.accept(cnt) =0;
    else
         LAN{ncd}.accept(cnt) =1;
    end
       EEGplot(cnt)
    if ishandle(ELECTRODE) 
      if strcmp( 'on',get(ELECTRODE,'Visible'))
       electrode_plot();
      end
    end
end
%-------------------
%  up (+)
%-------------------
function up_button_Callback(source,eventdata,handles) 
    sc = sc + (sc*0.5);
    EEGplot(cnt);
end
%-------------------
%  low (-)
%-------------------
function low_button_Callback(source,eventdata,handles) 
    sc = sc - (sc*0.5);
    EEGplot(cnt);
end
%-------------------
%  edit (uv)
%-------------------
function edituv_button_Callback(source,eventdata,handles) 
    stre = get(source, 'String');
    sc = eval(['[' stre ']' ]);
    EEGplot(cnt);
end
%-------------------
%  TAG
%-------------------
function TAG_button_Callback(source,eventdata,handles)
    clear source eventdata handles
    tra = get(TAGat1, 'String');
    cha = get(TAGat2, 'String');
    label = get(TAGat3, 'String');
    
    if strcmp(tra,'c')
        tra = cnt;
    elseif strcmp(tra,'all')
        tra = 1:LAN{ncd}.trials;
    elseif isnumeric(eval(tra))
        tra = eval(tra);
    end
    
    if strcmp(cha,'mark')
        DEL = find(r_elec{ncd}(:,cnt))';
        for ri = DEL;
            [n LAN{ncd}.tag] = getntag(LAN{ncd}.tag,label);
            if isfield(LAN{ncd}, 'chanlocs')
            [ncha] = getncha(LAN{ncd}.chanlocs,LAN{ncd}.chanlocs(ri).labels);
            else
            ncha =  ri;  
            end
            for i = tra
               LAN{ncd}.tag.mat(ncha,tra) = n;
            end  
        end
    else
        [n LAN{ncd}.tag] = getntag(LAN{ncd}.tag,label);
        [ncha] = getncha(LAN{ncd}.chanlocs,cha);
        for i = tra
           LAN{ncd}.tag.mat(ncha,tra) = n;
        end        
    end

    EEGplot(cnt);
    electrode_plot();
end
%-------------------
%  clearTAG
%-------------------
function clearTAG(source,eventdata,handles) 
    LAN{ncd}.tag.mat(:,cnt) = 0;
    EEGplot(cnt);
    electrode_plot();
end
function clearMTAG(source,eventdata,handles) 
    DEL = find(r_elec{ncd}(:,cnt));
    %DEL = find(DEL(end:-1:1));
    LAN{ncd}.tag.mat(DEL,cnt) = 0;
    EEGplot(cnt);
    electrode_plot();
end

%-------------------
%  TAG1_button
%-------------------
function TAGat1_button(source,eventdata,handles) 
    clear eventdata handles
stre = get(source, 'String');
    if strcmp(stre,'Current')
        set(TAGat1,'String','c')
    else strcmp(stre,'All')
        set(TAGat1,'String','all')      
    end
end






%-------------------
%  TAG3_button
%-------------------
function TAGat3_button(source,eventdata,handles) 
stre = get(source, 'String');
set(TAGat3,'String',stre)
end
function TAGat2_button(source,eventdata,handles) 
stre = get(source, 'String');
set(TAGat2,'String',stre)
set(ERPPLOT,'String',stre)
end
%-------------------
%  condicion
%-------------------
function condicion_button_Callback(source,eventdata,handles) 
stre = get(source, 'String');
ncd = eval(['[' stre ']' ]);
camcond(ncd)
end

function cnt_button_Callback(source,eventdata,handles) 
stre = get(source, 'String');
if ~ifcon
cnt = evalin('base',['[' stre ']' ]);
else
n_ini = evalin('base',['[' stre ']' ]);  
if length(n_ini)>1
l_seg = fix(n_ini(2)*LAN{ncd}.srate);
end
n_ini = ((n_ini(1)*LAN{ncd}.srate)/l_seg) + 1;

cnt=1;
end
EEGplot(cnt);
end

function condicion_mas(source,eventdata,handles)
    if ncd<length(LAN)
    ncd = ncd +1;
    camcond(ncd)
    end
end
function condicion_menos(source,eventdata,handles)
    if ncd>1
    ncd = ncd -1;
    camcond(ncd)
    end
end
function camcond(ncd)
% A segmented bar axes and a continuous-channel information panel are
% different graphics types. Rebuild this one figure only when switching type.
newContinuous = LAN{ncd}.trials == 1;
if ~isempty(ifcon) && (logical(ifcon) ~= newContinuous)
    if ishghandle(EEG), close(EEG); end
    if ishghandle(ELECTRODE), delete(ELECTRODE); end
    ELECTRODE = -1;
    ifbarax = 0;
    barax = [];
    channelTextHandles = {};
    GUIcb = {};
end
set(numeroC,'String', ncd );
set(nombreC,'String', LAN{ncd}.cond );
set(nombreG,'String', LAN{ncd}.group );
set(nombreS,'String', LAN{ncd}.name );

cnt=1;
if ~isempty(view_chan) && any(view_chan>LAN{ncd}.nbchan)
    view_chan = 1:LAN{ncd}.nbchan;
    if ishghandle(EEG), close(EEG); end
end
EEGplot(cnt)
    if ishandle(ELECTRODE) 
      if strcmp( 'on',get(ELECTRODE,'Visible'))
       electrode_plot();
      end
    end
end
%-------------------
%  nombrecondicion
%-------------------
function nombrecondicion_button_Callback(source,eventdata,handles) 
stre = get(source, 'String');
LAN{ncd}.cond = char(stre);
end
%-------------------
%  nombregroup
%-------------------
function nombregrupo_button_Callback(source,eventdata,handles) 
stre = get(source, 'String');
LAN{ncd}.group = char(stre);
end
%-------------------
%  nombrename
%-------------------
function nombrename_button_Callback(source,eventdata,handles) 
stre = get(source, 'String');
LAN{ncd}.name = char(stre);
end
%-------------------
%  electrode boton
%-------------------
function no(source,eventdata,handles) 
stre = get(source, 'String');
[paso, ind]= ifcellis(ytl,stre); clear paso
if isfield(LAN{ncd},'chanlocs')
[ind2]= label2idx_elec(LAN{ncd}.chanlocs,stre);
else
    ind2 = str2num(stre(3:end));
end
%ind = ind(ind>=min(view_chan));
%ind = ind(ind<=max(view_chan));
k = get(elecbot{ind},'ForegroundColor');
if sum(k==[0 0 0])==3
    set(elecbot{ind},'ForegroundColor','red');
    r_elec{ncd}(ind2,cnt)=1;
    try  TAGat2_button(source); end
    if isfield(LAN{ncd},'freq')&&isfield(LAN{ncd}.freq,'fourierp')
       set(FTerp_gui,'ForegroundColor','k')
    else
       set(FTerp_gui,'ForegroundColor',[0.5 0.5 0.5]) 
    end
    if sum(diff(LAN{ncd}.data{cnt}(ind2,:)))~=0
    set(hilbert_gui,'ForegroundColor','k');
    else
     set(hilbert_gui,'ForegroundColor',[0.5 0.5 0.5]);   
    end
    
    if isfield(LAN{ncd},'freq')&&isfield(LAN{ncd}.freq,'powspctrm')
       if isstruct(LAN{ncd}.freq.powspctrm) 
          %if size(LAN{ncd}.freq.powspctrm,1)>1
             if ~isempty(LAN{ncd}.freq.powspctrm(ind2,1).filename)
             set(FT_gui,'ForegroundColor','k');
             end
          %end
       elseif ~isempty(LAN{ncd}.freq.powspctrm)
       if any(any(LAN{ncd}.freq.powspctrm{cnt}(:,ind2,:)))
       set(FT_gui,'ForegroundColor','k') 
       end
       end
    else
     set(FT_gui,'ForegroundColor',[0.5 0.5 0.5]);   
    end
    
    
    
else    
    set(elecbot{ind},'ForegroundColor','black')    
    r_elec{ncd}(ind2,cnt)=0;
end
EEGplot(cnt)
end
%-------------------
%  delectrode
%-------------------
function delectrode_button_Callback(source,eventdata,handles) 
    clear eventdata handles
stre = get(source, 'String');
if strcmp(stre,'OK')
      set(dele,'String','')  
      return
else
    stre = eval([ '[' stre ']' ]);
    %LAN{ncd} = electrode_lan(LAN{ncd},stre);
    LAN = electrode_lan(LAN,stre);
    ifdatahil = false; ifdataft = false;
    view_chan = 1:LAN{ncd}.nbchan;
    set(dele,'String','OK')
end
    if ishghandle(EEG), close(EEG); end
    if ishghandle(ELECTRODE), delete(ELECTRODE); end
    ELECTRODE = -1;
    ifbarax = 0;
    barax = [];
    channelTextHandles = {};
    GUIcb = {};
    r_elec=cell(1,length(LAN));
        for ie = 1:length(r_elec)
            if ~isempty(LAN{ie})
                r_elec{ie} = zeros(LAN{ie}.nbchan,LAN{ie}.trials);
            end
        end
    EEGplot(cnt);
end
%-------------------
%  voltage thr
%-------------------
function vlt_button_Callback(source,eventdata,handles) 
stre = get(source, 'String');
if strcmp(stre,'OK')
      set(dele,'String','')  
      return
else
    stre = eval([ '[' stre ']' ]);
    LAN{ncd} = vol_thr_lan(LAN{ncd},stre);
        ifdatahil = false; ifdataft = false;
    set(vlt,'String','OK')
end
    EEGplot(cnt);
    if ishandle(ELECTRODE) 
      if strcmp( 'on',get(ELECTRODE,'Visible'))
       electrode_plot();
      end
    end
end
%-------------------
%  interpol ch
%-------------------
function chint_button_Callback(source,eventdata,handles) 
stre = get(source, 'String');
if strcmp(stre,'OK')
      set(dele,'String','')  
      return
else
    stre = eval([ '[''' stre ''']' ]);
     if ischar(stre)
%         for i =1:LAN{ncd}.nbchan;
%             if strcmp(LAN{ncd}.chanlocs(i).labels,stre)
%                 stre=i;
%                 break
%             end
%         end
%     end

    cfg=[]; cfg=[]; cfg.type=stre;
    %cfg.bad_elec=stre; cfg.bad_trial=1:LAN{ncd}.trials;
    LAN{ncd} = lan_interp(LAN{ncd},cfg);
        ifdatahil = false; ifdataft = false;
    set(chint,'String','OK')
     end
end
    EEGplot(cnt);
    if ishandle(ELECTRODE) 
      if strcmp( 'on',get(ELECTRODE,'Visible'))
       electrode_plot();
      end
    end
end
%-------------------
%  interpol bad
%-------------------
function interpolbad(source,eventdata,handles) 
    cfg=[]; cfg.type='bad';
    LAN{ncd} = lan_interp(LAN{ncd},cfg);
    ifdatahil = false; ifdataft = false;
    
    EEGplot(cnt);
    if ishandle(ELECTRODE) 
      if strcmp( 'on',get(ELECTRODE,'Visible'))
       electrode_plot();
      end
    end
end
%-----------------
%ferpPLOT
%-----------------
    function ferpPLOT(b,bb,bbb)
        if ifactive(b)
            M = get(ERPPLOT,'String');
            if strcmp(M,'mark')
            M = find(r_elec{ncd}(:,cnt))';
            end
            switch get(b,'String')
                case 'FT plot'
                plot_fourierp(LAN{ncd},M,cnt);    
                case 'FT cont'
                FT_CON(M, cnt)    
            end
                
        clear b bb bbb
        
       
        end
    end
%-----------------
%hilbertPLOT
%-----------------
    function hilbertPLOT(b,bb,bbb)
        if ifactive(b)
            M = get(ERPPLOT,'String'); % obtener el nobre del electrodo a plotear
            clear b bb bbb
            HIL = figure('Visible','off');
            nh = 1;
            uicontrol(HIL,'Position',[2.5, 5,95,40],'String',' + Band','Style','pushbutton','Callback',@add_band);
            uicontrol(HIL,'Position',[100,5,95,40],'String',' - Band','Style','pushbutton','Callback',@remube_band);   
            uicontrol(HIL,'Position',[200,5,95,40],'String','OK','Style','pushbutton','Callback',@hil_band); 
            while nh <= size(cfghilbert,1) 
                uicontrol(HIL,'Position',[10, 50*nh,100,25],'String','Band:','Style','Text');
                uicontrol(HIL,'Position',[110, 50*nh,190,25],'String',num2str(cfghilbert{nh,1}),'Style','Edit',...
                          'Callback',@hil_band,'UserData',nh);
                      
                uicontrol(HIL,'Position',[10, 50*nh+25,90,25],'String','Norm bin:','Style','Text');
                uicontrol(HIL,'Position',[100, 50*nh+25,40,25],'String',num2str(norbin(nh,1)),'Style','Edit',...
                          'Callback',@nor_bin,'UserData',nh);      
                uicontrol(HIL,'Position',[160, 50*nh+25,90,25],'String',hilsmooth,'Style','pushbutton','Callback',@hil_sm_t);
                uicontrol(HIL,'Position',[240, 50*nh+25,40,25],'String',num2str(Hil_span(nh,1)),'Style','Edit',...
                          'Callback',@hil_sm,'UserData',nh);      
                %cfghilbert.band
                nh = 1+nh;
            end
            set(HIL,'Position',[0, 0, 300, 55+50*nh])
            movegui(HIL,'center')
            set(HIL,'Visible','on')
        end
        
    end
    function hil_band(b,bb,bbb)
        str = get(b,'String');
        if strcmp(str,'OK')
            close(HIL)
            try close(GUI_HIL_plot); ifGUI_HIL_plot=0; end
            ifGUI_HIL_plot=0;
            HIL_plot(b);
        else
        n = get(b,'UserData');
        cfghilbert{n,1} = eval(['[ ' str  '   ]']);    
        end
    end
   function nor_bin(b,bb,bbb)  
   str = get(b,'String');    
   n = get(b,'UserData');
   norbin(n,1) = evalin('base',['[ ' str  '   ]']);   
   end
   function hil_sm(b,bb,bbb)  
   str = get(b,'String');    
   n = get(b,'UserData');
   Hil_span(n,1) = evalin('base',['[ ' str  '   ]']);   
   end
   function hil_sm_t(b,bb,bbb)  
   str = get(b,'String');
   switch str
       case 'Smooth'
       %n = get(b,'UserData');
       hilsmooth = 'Rectified';
       set(b,'String','Rectified');
       case 'Rectified'
       %n = get(b,'UserData');
       hilsmooth = '--';
       set(b,'String','Rectified');    
       otherwise
       %n = get(b,'UserData');
       hilsmooth = 'Smooth';
       set(b,'String','Smooth');
   end
   end

    function add_band(b,bb,bbb)
      cfghilbert{size(cfghilbert,1)+1,1} = [0,0];
      close(HIL)
      hilbertPLOT(hilbert_gui)
    end
   function remube_band(b,bb,bbb)
       if size(cfghilbert,1)>1
      cfghilbert(size(cfghilbert,1),:) = [];
      close(HIL)
      hilbertPLOT(hilbert_gui)
       end
   end
%-----------------
%EerpPLOT
%-----------------
    function Eerp_PLOT(b,bb,bbb)
        clear b bb bbb
        M = get(ERPPLOT,'String');
        if strcmp(M,'mark')
        M = find(r_elec{ncd}(:,cnt))';
        end
        lan_erp_plot(LAN{ncd}.time,LAN{ncd}.data,LAN{ncd}.chanlocs,cnt,M,LAN{ncd}.accept);
        
    end

%-----------------
%  caxis_ft_edt
%-----------------
    function caxis_ft_edt(b,bb,bbb)
        clear bb bbb
        str = get(b,'String');
        str = eval(['[ ' str '  ]']);
        str = [ min(str) max(str)];
        set(caxis_ft_gui,'String',num2str(str));
        caxis_ft = str;
        caxis(axft,caxis_ft);
    end


%-----------------
%  nor_ft_edt
%-----------------
    function nor_ft_edt(b,bb,bbb)
        val = get(b,'Value');
        str = get(b,'String');
        nor_ft = str{val};
        if ifGUI_FT_CON && ishghandle(GUI_FT_CON), FT_CON(0,cnt); end
    end
%-----------------
%  smooth_ft_edt
%-----------------
    function smooth_ft_edt(b,bb,bbb)    
        str = get(b,'String');
        nsmooth = eval([  '['  str  ']']);
        if ifGUI_FT_CON && ishghandle(GUI_FT_CON), FT_CON(0,cnt); end
    end
%--
%-------------------
%  SAVEWS
%-------------------
function savews_button_Callback(source,eventdata,handles)
    if ncell
        LAN = LAN{1};
        if isfield(LAN, 'RT'); LAN.RT = rt_check(LAN.RT, LAN); end
    elseif iscell(LAN)
        for lan = 1:length(LAN)
            if isfield(LAN{lan},'RT')
            LAN{lan}.RT = rt_check(LAN{lan}.RT, LAN{lan});
            end
        end
    end
    
    
    assignin('base',  nameLAN  , LAN);
    if strcmp(get(source,'String'),'Save(F)')
       [FileName,PathName,~] = uiputfile('.mat','Save LAN variable',[nameLAN]);
       if isequal(FileName,0) || isequal(PathName,0)
           disp('User selected Cancel')
        else
           disp(['Saving ',fullfile(PathName,FileName)])
           fprintf('Please wait ...')
           evalin('base',[ ' save(  ''' PathName FileName ''' , ''' nameLAN ''' )' ]);
           fprintf('  ok  \n')
       end   
    else
        disp(['Saving variable '  nameLAN ' in the Workspace'])
    end
    if ncell
       paso = LAN;
       clear LAN
       LAN{1} = paso;
       clear paso;
    end
end
%-------------------
%  CLOSE
%-------------------
    function close_BB(source,eventdata,handles)
        delete(ELECTRODE)
        try 
            set(bot_chan,'ForegroundColor',[0.5 0.5 0.5]); 
            viewCHAN=0;
        end
    end
      
function close_button_Callback(source,eventdata,handles) 
    savews_button_Callback(source,1,1)
    warning off
    %try close gcf , end;
    try delete(controles); catch;  delete(gcf); end
    try  close(EEG);   end
    try  close(topocond); end
    try  close(estata);   end
    try  close(ELECTRODE);   end
    try  close(GUI_FT_CON);   end
    try  close(GUI_HIL_plot);   end  
    try  close(guirt);   end
    %disp('DONE')
    %try delete(gcf) , end
    %try clear all , end
    warning on
    %uiwait(controles)
    if iflantoolbox
        disp('Back to LANtoolbox ... remeber to save your work!!')
        close all
        lantoolbox(LAN)
        clear %all
        %assignin('caller','xLAN',LAN)
    else
        disp('....')
        disp('Thank you for using LAN toolbox')
    end

end
    function close_EEG(source,eventdata,handles)
        if ishghandle(EEG)
            pc = get(EEG,'Position');
            delete(EEG);
        end
        ifax = 0;
        ifax2 = 0;
        ax = [];
        ax2 = [];
        elecbot = [];
    end
%-event
                
    function event_green(b,bb,bbb)
                 nrt = get(b, 'userdata');
                 LAN{ncd}.RT.good(nrt) = ~LAN{ncd}.RT.good(nrt)  ;
                 if LAN{ncd}.RT.good(nrt), set(gco, 'Color','green'); else set(gco, 'Color',[0.5 0.5 0.5 ]); end
    end
    function event_red(b,bb,bbb)
                 nrt = get(b, 'userdata');
                 LAN{ncd}.RT.good(nrt) = ~LAN{ncd}.RT.good(nrt)  ;
                 if LAN{ncd}.RT.good(nrt), set(gco, 'Color','red'); else set(gco, 'Color',[0.5 0.5 0.5]); end
    end            



%--------------
%  COMP_
%--------------
    function COMP_EEG
        warning off
       if ishghandle(EEG)
                try  
                pc=get(EEG,'Position'); %close(EEG) ; 
                set(EEG,'Visible','on');
                catch
                    EEG = figure('Visible','on','Position',pc,...
                   'Name','EEG plot','NumberTitle','off','MenuBar', 'none');
                end
       else
               %Pe =[1   fix(1.3*scrsz(4)/6)       fix(scrsz(3)/2) fix(3*scrsz(4)/6) ];
                EEG = figure('Visible','on','Position',pc,...
               'Name','EEG plot','NumberTitle','off','MenuBar', 'none',...
               'CloseRequestFcn',@close_EEG);
               ifax=0;
               ifax2=0;
       end
       %set(EEG,'CloseRequestFcn',@closeEEG)
       warning on
    end
%---------------
function COMP_ELECTRODE
    if ishandle(ELECTRODE)
        warning off
        try
            pce=get(ELECTRODE,'Position'); %close(EEG) ;
            set(ELECTRODE,'Visible','on');
        catch
            %figure1 = figure();
            ELECTRODE = figure('Visible','on','Position',pce,...
                'Name','Channel','NumberTitle','off','MenuBar', 'none','CloseRequestFcn', @close_BB,...
                ...%   'XVisual' ,...
                ...%'0x22 (TrueColor, depth 24, RGB mask 0xff0000 0xff00 0x00ff)',...
                'Colormap',[0 1 0;0 0 1;1 1 0;1 0 1;1 0 0;0 0 0]...
                );
            caxis([1 6]);
        end
    else
        pce =[fix(scrsz(3)/2)   fix(1.3*scrsz(4)/6)       fix(scrsz(3)/2)  fix(3*scrsz(4)/6) ];
        ELECTRODE = figure('Visible','on','Position',pce,...
            'Name','Channels','NumberTitle','off','MenuBar', 'none','CloseRequestFcn', @close_BB);
        ifbarax=0;
        barax=[];
        channelTextHandles={};
        GUIcb={};
    end
    %set(EEG,'CloseRequestFcn',@closeEEG)
    warning on
end
  %---------------
    function COMP_FT_CON
  
    if ifGUI_FT_CON && ishghandle(GUI_FT_CON)
       set(GUI_FT_CON,'Visible','on');
    else
       GUI_FT_CON = figure('Visible','on','Position',pc,...
               'Name',['FT continuous plot: ' M],'NumberTitle','off','MenuBar', 'none',...
               'CloseRequestFcn',@close_FT_CON);
       ifaxft=0;
       ifdataft=0;
       ifGUI_FT_CON = 1;
       ftLastTrial = []; ftLastCond = [];
    end
    end
    function close_FT_CON(b, bb, bbb)
        if ishghandle(GUI_FT_CON), delete(GUI_FT_CON); end
        ifGUI_FT_CON = 0;
        ifaxft = 0;
        axft = [];
        ifdataft = 0;
    end
  %--------------
  function COMP_guirt
  
    if ifguirt && ishghandle(guirt)
       set(guirt,'Visible','on');
    else
       lg(1) = pc(1); lg(2) = pc(2)+pc(4); lg(3) = pc(3); lg(4) = 30;    
       guirt = figure('Visible','on','Position',lg,...
               'Name','event','NumberTitle','off','MenuBar', 'none',...
               'CloseRequestFcn',@closeguirt);
       %ifaxhil=0;
       %ifdatahil=0;
       ifguirt = 1;
    end
    end
    function closeguirt(b, bb, bbb)
        if ishghandle(guirt), delete(guirt); end
        ifguirt = 0;
        axrt = [];
        if ifax && ishghandle(ax)
            delete(findall(ax,'Tag','LAN_RTMarker'));
        end
    end
  %---------------
    function COMP_HIL_plot
  
    if ifGUI_HIL_plot && ishghandle(GUI_HIL_plot)
       set(GUI_HIL_plot,'Visible','on');
    else
       
       GUI_HIL_plot = figure('Visible','on','Position',pc,...
               'Name','HILBERT plot','NumberTitle','off','MenuBar', 'none',...
               'CloseRequestFcn',@close_HIL_plot);
       ifaxhil=0;
       ifdatahil=0;
       ifGUI_HIL_plot = 1;
       hilLastTrial = []; hilLastCond = []; hilLastChannels = [];
    end
    end
    function close_HIL_plot(b, bb, bbb)
        if ishghandle(GUI_HIL_plot), delete(GUI_HIL_plot); end
        ifGUI_HIL_plot = 0;
        ifaxhil = 0;
        axhil = [];
        ifdatahil = 0;
    end
%----------------





  %---------------
% uiwait(controles)
% if iflantoolbox
%     disp('Back to LANtoolbox ... remeber to save your work!!')
%     close all
%     lantoolbox(LAN)
%     clear %all
%     %assignin('caller','xLAN',LAN)
% end
end
