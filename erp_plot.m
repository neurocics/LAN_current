function erp_plot(GLAN)
%   v.0.2.0
%            <*LAN)<] 
%
%   erp_plot(GLAN)
%
% Pablo Billeke
% Francisco Zamorano

% 04.04.2018 (PB) add call electrodes by their labels 
% 09.92.2016 (PB) add ICA calculate
% 13.10.2015 (PB) add color 
% 31.07.2014 (PB) improve edit figure bottom 
% 19.10.2012 (PB)
% 26.06.2012 (PB) fix base line correction, add roi stat!, fix plot 'all' electrodes 
% 15.03.2012 (PB) fix bug with time in topoplot
% 09.03.2012 (PB) E edit figure button, lantoolbox compativility
% 02.03.2012 (PB) change stata view
% 01.02.2012 (PB) fix view cluster for a time intervals
% 11.01.2012 (PB) add cluster no-significanta after permutations
% 10.01.2012 (PB) fix screen size
% 04.07.2011 (PB) h plot 
% 08.06.2011 (PB) p value corrected, colormap resolution.
% 24.02.2011 (FZ)
% 24.01.2011 (PB) add PDF botton that create .ps and .pdf . ps2pdf (Latex function) is necesary 
%                           [in develop]
% 22.01.2011 (PB) add posibility of eletrode 'all', and plot topological
%                           ERP per electrode.
%                           new fucntion plotall_lan.m  
%                           matlab:help plotall_lan
%                           
% 20.01.2011
%
% See also ERP_STATA, PLOTALL_LAN 

%    base on  erp_glan.m v.0.1.7

% general lantoolbox 
try
iflantoolbox = evalin('caller', 'iflantoolbox');
catch
 global nameLAN
 
      
 nameLAN = inputname(1);

 
 %- temp in base ws
 evalin('base','exist nameLAN_tempLAN var;')
 if evalin('base','ans')
     nameLAN = evalin('base','nameLAN_tempLAN');
 else
     assignin('base','nameLAN_tempLAN',nameLAN)
 end
 evalin('base','clear ans:')
 
 %-
 evalin('base','exist menuposition_tempLAN var;')
 if evalin('base','ans')
    pp = evalin('base','menuposition_tempLAN');
 else
     scrsz = get(0,'ScreenSize');
        if max(scrsz) <100
            scrsz = [0 0 1200 800];
        end
     pp =[fix(0.4*scrsz(3))   fix(1.35*scrsz(4)/6)       fix(0.2*scrsz(3))  fix(3*scrsz(4)/6) ];
 end
 evalin('base','clear ans')
 

iflantoolbox = true;
end 


%%%%--------------------------
global guitiempo
global guicondMat
global ltime
txt = 0;

% Ventanas
scrsz = get(0,'ScreenSize');
if max(scrsz) <100
    scrsz = [0 0 1200 800];
end
texto = plus_text;
%texto = plus_text(' this function remplace to  erp_glan.m');
%
Pe =[1   fix(1.35*scrsz(4)/6)       fix(1.1*scrsz(3)/2) fix(3*scrsz(4)/6) ];
global ERP
ERP = figure('Visible','off','Position',Pe,...
    'Name','ERP','NumberTitle','off','MenuBar', 'none');
Pea =[1   fix(1.35*scrsz(4)/6)       fix(1.1*scrsz(3)/2) fix(3*scrsz(4)/6) ];
global ERP_ALL
ERP_ALL= figure('Visible','off','Position',Pea,...
    'Name','ERP_all','NumberTitle','off','MenuBar', 'none');
%
Pt =[1+fix(3.5*scrsz(3)/6)   fix(1.35*scrsz(4)/6)       fix(scrsz(3)/6) fix(3*scrsz(4)/6) ];
global TOPOS
TOPOS = figure('Visible','off','Position',Pt,...
    'Name','TOPOPLOT','NumberTitle','off','MenuBar', 'none');
Pd =[1+fix(4.6*scrsz(3)/6)   fix(1.35*scrsz(4)/6)       fix(scrsz(3)/6) fix(3*scrsz(4)/6) ];
global TOPODIF
TOPODIF = figure('Visible','off','Position',Pd,...
    'Name','TOPOPLOTdif','NumberTitle','off','MenuBar', 'none');
%%%% now in COMP_CONTROLES
global CONTROLES
CONTROLES = figure('Position',[1 5*(scrsz(4)/6) scrsz(3) scrsz(4)/6],'Visible','off',...
    'Name',[ 'ERP - Controles en LAN v.' lanversion ],'NumberTitle','off','MenuBar', 'none');%,'Color','k');

dif = 0;
c_axis=[-5 5];
color =[{'blue'},{'red'},{'yellow'},{'green'},{'cyan'},...
    {'magenta'},{'yellow'},{'black'},{[1 0.5 0.5 ]}];...
    
%%%----------------------------
%%% CHEQUEO DE LA MATRIZ
%%% y parametros basicos

if nargin == 0
    edit erp_plot.m
    help erp_plot
    return
end

if ~isfield(GLAN, 'erp')
    error('No existe campo .erp')
    return
end

if isfield(GLAN.erp,'hhc')
    hh = GLAN.erp.hhc;
    pvalc = GLAN.erp.pvalc;
    ifh = 1;
elseif isfield(GLAN.erp,'hh')
    hh = GLAN.erp.hh;
    pvalc = GLAN.erp.pval;
    ifh =1;
else
    ifh=0; % without statistic values
    disp('There not exit pre-calculated stadistic in GLAN.erp structur')
end


global ifbl
try
    
    try
        bl = GLAN.erp.cfg.bl{comp};
        
    catch
        bl = GLAN.erp.cfg.bl{1};
        ifbl =1;
    end
    
    if isempty(bl)
        ifbl=0;
    else
        ifbl=1;
    end
    
catch
    ifbl=0;
end

if ~isfield(GLAN.erp, 'subdata')
    disp('No hay matrices por sujetos, muchos analisis estadisticos no se van a poder realizar');
    sd = 0;
    ma_s = '(Solo matriz grupal)';
else
    sd =1;
    ma_s = '(Matrices individuales)';
end

ncond = size(GLAN.cond,2)  ;
ngroup = size(GLAN.cond,1) ;
ncci = 0;
for cc = 1:ncond
    for gg = 1:ngroup
    ncci =  ncci+1 ;    
    if isempty(GLAN.cond{gg,cc});
        namecond{gg,cc} = [num2str(ncci)  '(-empty-), ' ];       
    else
        namecond{gg,cc} = [num2str(ncci) '(' GLAN.cond{gg,cc}  '), '];
    end
    end
end
%%%% ---------------------------------
%%%% PARAMETROS DEFAULT PARA GRAFICO
roi = 1;
fr = 1:40; %'1:45';
frt = [];
global time
global Y
global ifaxh
ifaxh = 0;
global ifaxerp
global difind
global matdif
global ifica
global ifGUI_ica
global p_ica
global see_ica
global ica_W
global ica_iW
global fun_erp
fun_erp = 'mean';
global see_ACI

    ifGUI_ica=0;
    if isfield(GLAN.erp,'ICAerp')
        ifica=true;
    else
        ifica=false;
    end
    p_ica = [0.4 0.4 0.2 0.2];
    see_ica=false;
    

ifaxerp = 0;
time = [];

% fix error in previous scripts
if ~isfield(GLAN, 'subject')
    GLAN.subject  = GLAN.suject;
end


if ischar(GLAN.subject{1})
nS = size(GLAN.subject,2);
SS = 1:nS;
elseif ischar(GLAN.subject{1}{1})
    nG = size(GLAN.subject,2);
    for gg = 1:nG
    nS{gg} = size(GLAN.subject{gg},2);
    end
    SS{gg} = 1:nS{gg};
end

n = 1; % normalizar
if isfield(GLAN.erp,'comp') && ~isempty(GLAN.erp.comp{1})
    cond1 = GLAN.erp.comp{1}(1);
    cond2 = GLAN.erp.comp{1}(2);
    condM = GLAN.erp.comp{1};
else
    cond1 = 1;
    cond2 = 2;
    condM = [1 2];
end
%condM = [];
%contM=[];
global congM
ifstat = 0;
lb = [];
plb=[];
iflb = 0;
c_axis = [-5 5];
X=[];
y_ax = [];
met = 'mdB';
figname = [ inputname(1) 'f' ];


% ---
comp = GLAN.erp.comp;
for cm = 1:length(comp)
    try
        compname{cm} = GLAN.erp.compname{cm};
    catch
        compname{cm} = num2str(cm);
        GLAN.erp.compname{cm} = compname{cm};
    end
end
compname{cm+1} = 'NEW_ROI';
compname{cm+2} = 'NEW';


%%%%
%%%%
%%%%

global ifmat
global GUIroi
global STA
global GUIS
global GUIG
global GUIC
global GUID
global GUIbl
global rs
global GUI_ICA_cal
global FUN_boton
global FUN_type
GUI_CONTROL%%

%%%%
%%%% ---------------
%%%% GUI: CONTROL
%%%%

    function GUI_CONTROL
        COMP_CONTROL
        
        % botones------------------------------------------------------------------------------     
        if iflantoolbox
        uicontrol('Style','pushbutton','String','Back','Units','normalized',...
            'Position',[0.9, 0 ,0.05,0.2],... 'BackgroundColor',cf,... 'ForegroundColor',fc,...
            'Callback',{@close_button_Callback});    
        else
        uicontrol('Style','pushbutton','String','Close','Units','normalized',...
            'Position',[0.9, 0 ,0.05,0.2],... 'BackgroundColor',cf,... 'ForegroundColor',fc,...
            'Callback',{@close_button_Callback});
        end
        uicontrol('Style','pushbutton','String','ERP','Units','normalized',...
            'Position',[0.9, 0.25 ,0.1,0.2],... 'BackgroundColor',cf,... 'ForegroundColor',fc,...
            'Callback',{@erp_button_Callback});
        uicontrol('Style','pushbutton','String','Topoplot','Units','normalized',...
            'Position',[0.9, 0.5 ,0.1,0.2],... 'BackgroundColor',cf,... 'ForegroundColor',fc,...
            'Callback',{@topo_button_Callback});
        uicontrol('Style','pushbutton','String','Topoplot FUN','Units','normalized',...
            'Position',[0.9, 0.75 ,0.06,0.2],... 'BackgroundColor',cf,... 'ForegroundColor',fc,...
            'Callback',{@dif_button_Callback});
 FUN_boton = uicontrol('Style','pushbutton','String','Dif','Units','normalized',...
            'Position',[0.96, 0.75 ,0.04,0.2],... 'BackgroundColor',cf,... 'ForegroundColor',fc,...
            'Callback',{@FUN_button_Callback});        
        uicontrol('Style','pushbutton','String','pdf','Units','normalized',...
            'Position',[0.95, 0 ,0.05,0.2],... 'BackgroundColor',cf,... 'ForegroundColor',fc,...
            'Callback',{@ep_button_Callback});
        
        % ----
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
        for gg = 1:size(GLAN.cond,1)
        uicontrol('Parent',pa_inf,'Units','normalized','Style','text','String', [ ' C:  '  cat(2,namecond{gg,:}) ],...
            'Position',[0,0.85-(0.20*gg),1,0.2]...%'BackgroundColor',cf,'ForegroundColor',fc
            );
        end
        % ----
        %
        % ----PANEL 1----
        % ---- condiciones
       
        pa1 = uipanel('Title','Conditions (Index, See info->)','Units','normalized','Position',[0, 0.01 ,0.2,0.98]);
        uicontrol('Parent',pa1 ,'Units','normalized','Style','text','String','Pre Cal Stat',...
          'Position',[0,0.7,0.25,0.2]...%'BackgroundColor',cf,'ForegroundColor',fc
           );
        % global STA       
        STA =  uicontrol('Parent',pa1 ,'Units','normalized','Style','popupmenu','String',compname,...
          'Position',[0.25,0.7,0.75,0.2],'Callback',{ @STA_fun } ...%'BackgroundColor',cf,'ForegroundColor',fc
           ); 
%         uicontrol('Parent',pa1 ,'Units','normalized','Style','text','String','Cond1:',...
%             'Position',[0,0.7,0.25,0.2]...%'BackgroundColor',cf,'ForegroundColor',fc
%             );
%         uicontrol('Parent',pa1 ,'Units','normalized','Style','edit',...
%             'String', cond1 ,...opciones{pp,1},...
%             'Position',[0.25,0.7,0.25,0.3],...'BackgroundColor',cf,...'ForegroundColor',fc,...
%             'Callback',{ @condicion_uno } );
%         uicontrol('Parent',pa1 ,'Units','normalized','Style','text','String','Cond2:',...
%             'Position',[0.5,0.7,0.25,0.2]...%'BackgroundColor',cf,'ForegroundColor',fc
%             );
%         uicontrol('Parent',pa1 ,'Units','normalized','Style','edit',...
%             'String', cond2 ,...opciones{pp,1},...
%             'Position',[0.75,0.7,0.25,0.3],...'BackgroundColor',cf,...'ForegroundColor',fc,...
%             'Callback',{ @condicion_dos } );

        % ----matrices cond
        % %----matrices cond 
        %
        uicontrol('Parent',pa1 ,'Units','normalized','Style','text','String','Cond Indx',...
                  'Position',[0,0.45,0.2,0.2]...%'BackgroundColor',cf,'ForegroundColor',fc
                   );
        GUIC =uicontrol('Parent',pa1 ,'Units','normalized','Style','edit',...
                   'String', vec2str(GLAN.erp.comp{1}(1,:)) ,...opciones{pp,1},...
                   'Position',[0.2,0.45,0.4,0.3],...'BackgroundColor',cf,...'ForegroundColor',fc,...
                   'Callback',{ @condMat } );
        %uicontrol('Parent',pa1 ,'Units','normalized','Style','text','String','CondMat:',...
        %    'Position',[0,0.45,0.25,0.2]...%'BackgroundColor',cf,'ForegroundColor',fc
        %    );
        %condMst = [];
        %for xi = 1:length(condM)
        %    condMst = [condMst ' ' num2str(condM(xi))];
        %end
        %guicondMat = uicontrol('Parent',pa1 ,'Units','normalized','Style','edit',...
        %    'String', condMst ,...opciones{pp,1},...
        %    'Position',[0.25,0.45,0.75,0.3],...'BackgroundColor',cf,...'ForegroundColor',fc,...
        %    'Callback',{ @condMat } );
        
        %uicontrol('Parent',pa1 ,'Units','normalized','Style','text','String','ContMat:',...
        %    'Position',[0,0.2,0.25,0.2]...%'BackgroundColor',cf,'ForegroundColor',fc
        %    );
        %uicontrol('Parent',pa1 ,'Units','normalized','Style','edit',...
        %    'String', contM ,...opciones{pp,1},...
        %    'Position',[0.25,0.2,0.75,0.3],...'BackgroundColor',cf,...'ForegroundColor',fc,...
        %    'Callback',{ @contMat } );
        %----
        %
               
        uicontrol('Parent',pa1 ,'Units','normalized','Style','text','String','Sample',...
          'Position',[0.6,0.45,0.15,0.2]...%'BackgroundColor',cf,'ForegroundColor',fc
           );
             %  global sr
        GUIS =uicontrol('Parent',pa1 ,'Units','normalized','Style','popupmenu',...
                   'String', {'Paired' , 'Unpaired'} ,...opciones{pp,1},...
                   'Position',[0.75,0.45,0.25,0.2],...'BackgroundColor',cf,...'ForegroundColor',fc,...
                   'Callback',{ @GUI_s } );       

        uicontrol('Parent',pa1 ,'Units','normalized','Style','text','String','Group:',...
                  'Position',[0,0.2,0.2,0.2]...%'BackgroundColor',cf,'ForegroundColor',fc
                   );
        if size(GLAN.erp.comp{1},1)==1
           GLAN.erp.comp{1}(2,:) = 1; 
        end
        GUIG = uicontrol('Parent',pa1 ,'Units','normalized','Style','edit',...
                   'String', vec2str(GLAN.erp.comp{1}(2,:)) ,...opciones{pp,1},...
                   'Position',[0.2,0.2,0.4,0.3],...'BackgroundColor',cf,...'ForegroundColor',fc,...
                   'Callback',{ @contMat } );
               
        uicontrol('Parent',pa1 ,'Units','normalized','Style','text','String','Dif:',...
                  'Position',[0,0,0.2,0.2]...%'BackgroundColor',cf,'ForegroundColor',fc
                   );
        if ~isfield(GLAN.erp,'matdif')
           GLAN.erp.matdif{1}=[]; 
        end
        GUID = uicontrol('Parent',pa1 ,'Units','normalized','Style','edit',...
                   'String', vec2str(GLAN.erp.matdif{1}) ,...opciones{pp,1},...
                   'Position',[0.2,0,0.4,0.3],...'BackgroundColor',cf,...'ForegroundColor',fc,...
                   'Callback',{ @difMat } );
               
        %---- Caxis STata
        %pa1 = uipanel('Title','Conciciones','Units','normalized','Position',[0, 0.7 ,0.2,1]);
        uicontrol('Units','normalized','Style','text','String','C Axis:',...
            'Position',[0.2,0,0.05,0.2]...%'BackgroundColor',cf,'ForegroundColor',fc
            );
        uicontrol('Units','normalized','Style','edit',...
            'String', num2str(c_axis) ,...opciones{pp,1},...
            'Position',[0.25,0,0.05,0.3],...'BackgroundColor',cf,...'ForegroundColor',fc,...
            'Callback',{ @c_axis_Call } );
        
        uicontrol('Units','normalized','Style','text','String','Stat:',...
            'Position',[0.1,0,0.05,0.2]...%'BackgroundColor',cf,'ForegroundColor',fc
            );
        uicontrol('Units','normalized','Style','edit',...
            'String', ifstat ,...opciones{pp,1},...
            'Position',[0.15,0,0.05,0.3],...'BackgroundColor',cf,...'ForegroundColor',fc,...
            'Callback',{ @condicion_tres } );
        %-----
        %
        %----- PANEL 2 -a
        %----- Electrodos
        %global GUIroi
        
        if ifica
            colorica = [0 0 0];
        else
            colorica = [0.5 0.5 0.5];
        end
        
        pa_elec = uipanel('Title','Electrodes (Indx)','Units','normalized','Position',[0.205, 0.7 ,0.1,0.29]);
        GUIroi = uicontrol('Parent',pa_elec,'Style','edit','Units','normalized',...
           'String', num2str(roi) ,...opciones{pp,1},...
           'Position',[0,0,1,1],...'BackgroundColor',cf,...'ForegroundColor',fc,...
           'Callback',{ @electrode_Callback} );
       
       % ica
        uicontrol('Style','pushbutton','Units','normalized',...
           'String', 'ICA' ,...opciones{pp,1},...
           'Position',[0.308, 0.7 ,0.049,0.29],...'BackgroundColor',cf,...
           ...'ForegroundColor',colorica,...
           'Callback',{ @ICA_Callback} );
        see_ACI=uicontrol('Style','pushbutton','Units','normalized',...
           'String', 'Components' ,...opciones{pp,1},...
           'Position',[0.358, 0.7 ,0.049,0.29],...'BackgroundColor',cf,...
           'ForegroundColor',colorica,...
           'Callback',{ @ICA_Callback} );
        %----line de base
        
        %pa_lb = uipanel('Title','Line de base (s)','Units','normalized','Position',[0.205, 0.45 ,0.2,0.29]);
        pa_lb = uipanel('Title','Base Line (s)','Units','normalized','Position',[0.205, 0.45 ,0.1,0.29]);
        GUIbl = uicontrol('Parent',pa_lb,'Style','edit','Units','normalized',...
           'String', vec2str(GLAN.erp.cfg.bl{1}) ,...opciones{pp,1},...
           'Position',[0,0,1,1],...'BackgroundColor',cf,...'ForegroundColor',fc,...
           'Callback',{ @lb_Callback} );

       
        %-------------
        %---- topoplot
        %--------------
        pa_tp = uipanel('Title','Topoplot','Units','normalized','Position',[0.41, 0.05 ,0.15,0.95]);
        
        guitiempo = uicontrol('Parent',pa_tp,'Style','edit','Units','normalized',...
            'String', num2str(time) ,...opciones{pp,1},...
            'Position',[0.28,0.7,0.7,0.3],...'BackgroundColor',cf,...'ForegroundColor',fc,...
            'Callback',{ @edit_time_menu_Callback} );
        
        
        uicontrol('Parent',pa_tp,'Style','text','Units','normalized',...
            'String', 'Time (s)' ,...opciones{pp,1},...
            'Position',[0.019,0.7,0.27,0.22]...'BackgroundColor',cf,...'ForegroundColor',fc,...
            );
        
                uicontrol('Parent',pa_tp,'Style','pushbutton','Units','normalized',...
            'String', 'Table R' ,...opciones{pp,1},...
            'Position',[0.28,0.4,0.27,0.2],...'BackgroundColor',cf,...'ForegroundColor',fc,...
            'Callback',{ @B_table_r});
        
            uicontrol('Parent',pa_tp,'Style','pushbutton','Units','normalized',...
            'String', fun_erp ,...opciones{pp,1},...
            'Position',[0.58,0.4,0.27,0.2],...'BackgroundColor',cf,...'ForegroundColor',fc,...
            'Callback',{ @fun_B_table_r});
        
        
        %---logo
        
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
        
        
        
    end %%% GUI_CONTROLEs


%%%%%%%%%%%%%%%%%%%%%%
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
            case {'Unpaired'}
                rs = 'i';
            case {'Paired'}
                rs = 'd';
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
                set(GUID,'String','[]')
                set(GUIC,'BackgroundColor' ,[1 0 0])
                set(GUIG,'BackgroundColor' ,[1 0 0])
                set(GUID,'BackgroundColor' ,[1 0 0])
            case  'NEW_ROI'
                set(GUIroi,'String','put  new roi')
                set(GUIroi,'BackgroundColor' ,[1 0 0]) %''ForegroundColor'
            otherwise
                set(GUIC,'String',vec2str(GLAN.erp.comp{val}(1,:)) )
                condMat(GUIC)
                set(GUIG,'String',vec2str(GLAN.erp.comp{val}(2,:)) )
                contMat(GUIG)
                if val>length(GLAN.erp.matdif)
                     set(GUID,'String',' ') 
                else
                    set(GUID,'String',vec2str(GLAN.erp.matdif{val}) )
                end
                difMat(GUID)
                set(GUIbl,'String',vec2str(GLAN.erp.cfg.bl{val}(:))) 
                lb_Callback(GUIbl)
                %nor_Callback(GLAN.erp.cfg.norma{val})
                if GLAN.erp.cfg.s{val}=='i'
                   nv = 2;
                else
                    nv=1;
                end
                set(GUIS,'Value',nv)
                GUI_s(GUIS);
        end
   end

    function condMat(source,eventdata) 
              stre = get(source, 'String');
              condM = eval(['[' stre ']' ]);
              set(GUIC,'BackgroundColor' ,[0.702 0.702 0.702])
    end
    function contMat(source,eventdata) 
              stre = get(source, 'String');
              congM = eval(['[' stre ']' ]);
              set(GUIG,'BackgroundColor' ,[0.702 0.702 0.702])
    end
    function difMat(source,eventdata) 
              stre = get(source, 'String');
              matdif = eval(['[' stre ']' ]);
              set(GUID,'BackgroundColor' ,[0.702 0.702 0.702])
              if  isempty(matdif)
                  ifmat = false;
              else
                  ifmat = true;
                  if get(STA, 'Value') < (length(get(STA, 'String'))-1)
                  difind = GLAN.erp.matdifind{get(STA, 'Value')};
                  else
                  difind =[]   ; %%%%%FIXME!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
                  end
              end
    end



    function condicion_tres(source,eventdata)
        stre = get(source, 'String');
        ifstat = eval(['[' stre ']' ]);
        %hold off;
    end



    function electrode_Callback(source,eventdata)
        stre = get(source, 'String');
        try
        roi = eval(['[' stre ']' ]);
        catch
            nss=1;
            while ~isempty(stre)
                if isempty(find(stre(find(stre~=' ',1):end)==' ',1))
                   fin=length(stre);
                else
                   fin=find(stre(find(stre~=' ',1):end)==' ',1)-2+find(stre~=' ',1);
                end
                paso{nss}= stre(  find(stre~=' ',1):fin);
                stre(1:fin)=[];
                nss=nss+1;
            end
            roi=[];
          for ne = length(paso):-1:1  
          roi =  cat(2, find(ifcellis({GLAN.chanlocs.labels},paso{ne})), roi);
          end
          
        end
        set(GUIroi,'BackgroundColor' ,[0.702 0.702 0.702])
        %hold off;
    end
    function fr_Callback(source,eventdata)
        stre = get(source, 'String');
        fr = eval(['[' stre ']' ]);
        %hold off;
    end
    function fr_tp_Callback(source,eventdata)
        stre = get(source, 'String');
        frt = eval(['[' stre ']' ]);
        %hold off;
    end
    function c_axis_Call(source,eventdata)
        stre = get(source, 'String');
        c_axis = eval(['[' stre ']' ]);
        disp(['set new c_axis : ' stre ])
        %hold off;
    end

    function lb_Callback(source,eventdata)
        if n
            
            stre = get(source, 'String');
            lb = eval(['[' stre ']' ]);
            if isempty(lb), 
                ifbl = 0; 
            elseif length(lb)==2, 
                ifbl = 1; 
            ttime = linspace(GLAN.time(1,1),GLAN.time(1,2),size(GLAN.erp.data{congM(1) ,condM(1)},2));
            plb(1) = find_approx(ttime,lb(1));
            plb(2) = find_approx(ttime,lb(2));
            disp(['Linea de base asignada: ' num2str(lb(1)) ' a ' num2str(lb(2)) ' segundos '])
            bl = lb;
            end
        end
    end

    function ICA_Callback(source,eventdata)
        
        switch get(source, 'String')
            case 'ICA'
                COMP_ICA_cal
                
            case 'Components'
                if get(source, 'ForegroundColor')==[ 0 0 0]
                   set(source, 'String', 'Electrodes')
                   see_ica=true;
                else
                    disp('You must calculates ICA  before!!')
                    
                end 
            case 'Electrodes'
                  set(source, 'String', 'Components')
                  see_ica=false;
        end
         
    end

    function time_Callback(source,eventdata)
        stre = get(source, 'String');
        time = eval(['[' stre ']' ]);
        time(1) = find(GLAN.timefreq.time <= time(1),1,'last');
        time(2) = find(GLAN.timefreq.time >= time(2),1,'first');
        disp(['tiempo topoplot asignado: ' num2str(time(1)) ' a ' num2str(time(2)) ' segundos '])
        time = time(1):time(2);
        %hold off;
    end

    function normdb_Callback(hObject, eventdata, handles)
        if (get(hObject,'Value') == get(hObject,'Max'))
            n = n+1;
            met = 'mdB';
        else
            n = n-1;
            %met = 'm'
        end
    end
    function norzs_Callback(hObject, eventdata, handles)
        if (get(hObject,'Value') == get(hObject,'Max'))
            n = n+1;
            met = 'z';
        else
            n = n-1;
            %met = 'm'
        end
    end

%%%---------------------------
%%% GUI ERP
%%%---------------------------
    function erp_button_Callback(source,eventdata)
        if size(GLAN.erp.data,1)<100 %%% why?
            
            time = [0 0];
            time(2) = size(GLAN.erp.data{congM(1) ,condM(1)},2) /GLAN.srate;
            time = time + GLAN.time(1);
            ltime =linspace(time(1),time(2), size(GLAN.erp.data{congM(1) ,condM(1)},2));
            
        
            
            if  ifstat&&(get(STA,'Value')<(length(get(STA,'String'))-1))  % r == 2
                 hh = GLAN.erp.hh{get(STA,'Value')}; 
                
                %bl = GLAN.erp.cfg.bl{get(STA,'Value')};
                
                ifh = 1;
                if  isfield(GLAN.erp, 'hhc') && ~isempty(GLAN.erp.hhc{get(STA,'Value')}) 
                    hhc= GLAN.erp.hhc{get(STA,'Value')};
                    ifhhc = true;
                else
                    ifhhc = false;
                end
            else
                 ifh =0;
                 ifhhc = false;
            end
            %%%-------------------------------
            
            
            
            %%% grafico de todos los electrodos
            if isstr(roi) && strcmp(roi,'all')
                COMP_ERP_ALL
                 uicontrol('Style','pushbutton','Position',[0,0,20,20],'String','E','Callback',{@editF})
                 uicontrol('Style','pushbutton','Position',[0,20,20,20],'String','S','Callback',{@editF})
                 uicontrol('Style','pushbutton','Position',[0,40,20,20],'String','C','Callback',{@editF})
     
                    data{1} = GLAN.erp.data{congM(1) ,condM(1)};
                    for c = 2:length(congM)
                    data{c} = GLAN.erp.data{congM(c) ,condM(c)};
                    end
                    if ifhhc
                     data{c+1}   = logical(hhc);
                    elseif ifh 
                     data{c+1}   = logical(hh);
                    end
                
                plotall_lan(data, GLAN.chanlocs,ltime,c_axis);
                return
            end
            %%%---------------------------------
            
            
            COMP_ERP
            set(0,'CurrentFigure',ERP);
            cont = 0;
            %plot(0,0)
            
            %%% preparando grafico de estadistica
            % eje
            c=0;
            for i = roi
                c=c+1;
                if see_ica 
                    ytl{c} = ['Comp' num2str(i)];
                    yt(c) = (c); 
                else
                    try
                        ytl{c} = GLAN.chanlocs(i).labels;
                    catch
                        ytl{c} = ['Elec' num2str(i)];
                    end
                    yt(c) = (c); 
                end
            end
            %
            if ~ifaxh 
                axh = axes('Parent',ERP,...
                'Position',[0.05 0.05 0.9 0.1],...
                'YTickLabel',ytl,'YTick',yt);
                uicontrol('Style','pushbutton','Position',[0,0,20,20],'String','E','Callback',{@editF})
                uicontrol('Style','pushbutton','Position',[0,20,20,20],'String','S','Callback',{@editF})
                uicontrol('Style','pushbutton','Position',[0,40,20,20],'String','Y','Callback',{@editF})
                uicontrol('Style','pushbutton','Position',[0,60,20,20],'String','X','Callback',{@editF})
                uicontrol('Style','pushbutton','Position',[0,80,20,20],'String','+','Callback',{@editFc})
            end
            set(ERP,'CurrentAxes',axh);
            hold on
            %%% significant bin
            
            ifhn = false;
            if ~ifh&&ifstat(1)>0
                if ifmat

                    for c = difind %[cond1 cond2];
                        cont = cont + 1;
                        %Div{cont} = GLAN.erp.datadif{c}(roi,:);
                        paso{cont} = mean(GLAN.erp.datadif{c}(roi,:,:),1);
                        if ifbl
                            paso{cont} = paso{cont} - repmat(mean(paso{cont}(:,plb(1):plb(2),:),2),[1,size(paso{cont},2),1]);
                        end
                    end
                    
                       aal = 0.05;
                       cfg_new = [];
                       cfg_new.paired = strcmp(rs,'d');
                       pv = lan_nonparametric(paso,cfg_new);
                       hh = zeros(size(pv));
                       hh(pv<aal) = 1;
                       ifhn = true;
                    
                    
                    
                else
                cont = 0;
                
               
               for c = condM %[cond1 cond2];
                cont = cont + 1;
                g = congM(cont);
                %Div{cont} = GLAN.erp.data{g,c}(roi,:);
                if see_ica
                    disp('Statistic over ICA componentes')
                    pasoD=[];
                    for s = 1:size(GLAN.erp.subdata{g,c},3)
                    pasoD(:,:,s) = ica_W*GLAN.erp.subdata{g,c}(:,:,s);
                    end
                else
                    pasoD = GLAN.erp.subdata{g,c};
                end
                
                paso{cont} = mean(pasoD(roi,:,:),1);
                if ifbl
                    paso{cont} = paso{cont} - repmat(mean(paso{cont}(:,plb(1):plb(2),:),2),[1,size(paso{cont},2),1]);
                end
               end
               aal = 0.05;
               cfg_new = [];
               cfg_new.paired = strcmp(rs,'d');
               pv = lan_nonparametric(paso,cfg_new);
               [hhc pvalc cluster] = cl_random_2d(pv<=0.05,-log(pv),0.05,10000,20); 
               disp(unique(pvalc))
               hh = zeros(size(pv));
               hh(pv<aal) = 1;
               ifhn = true;
                end 
            end
            if ifh
                for nroi = 1:length(roi)
                    xxx = ltime(any(hh(roi(nroi),:),1)==1);
                    yyy = (ones(1,length(find(any(hh(roi(nroi),:),1)==1))) * nroi) -0.1;
                    plot(xxx,yyy,...
                    '--gs','LineStyle','none',...%'LineWidth',5,...
                    'MarkerFaceColor',[1 0.8 0.8],...'g',...
                    'MarkerSize',3);
                    if ifhhc
                        xxx = ltime(any(hhc(roi(nroi),:),1)==1);
                        yyy = (ones(1,length(find(any(hhc(roi(nroi),:),1)==1))) * nroi) +0.1;
                    plot(xxx,yyy,...
                        '--rs','LineStyle','none',...%'LineWidth',5,...
                        'MarkerFaceColor',[0.8 1 0.8],...'g',...
                        'MarkerSize',3)                        
                    end

                end
            elseif ifhn
                    nroi = fix(length(roi)/2);
                    xxx = ltime(any(hh(1,:),1)==1);
                    yyy = (ones(1,length(find(any(hh(1,:),1)==1))) * nroi) -0.1;
                    plot(xxx,yyy,...
                    '--gs','LineStyle','none',...%'LineWidth',5,...
                    'MarkerFaceColor',[1 0.8 0.8],...'g',...
                    'MarkerSize',3);
                    if ifhhc
                        xxx = ltime(any(hhc(roi(nroi),:),1)==1);
                        yyy = (ones(1,length(find(any(hhc(1,:),1)==1))) * nroi) +0.1;
                        plot(xxx,yyy,...
                        '--rs','LineStyle','none',...%'LineWidth',5,...
                        'MarkerFaceColor',[0.8 1 0.8],...'g',...
                        'MarkerSize',3)                        
                    end 
            end
                set(get(gca,'Title'),'String','stat');
                %close ax
                set(axh,'Parent',ERP,...
                'Position',[0.05 0.05 0.9 0.1],...
                'YTickLabel',ytl,'YTick',yt);
                 hold off
                 xlim([ltime(1)  ltime(length(ltime))]);
                 ylim(([-1 , length(roi)]+0.5));     
                 
            %%% ejeHfin
            if ~ifaxerp 
                axerp = axes('Parent',ERP,...
                'Position',[0.05 0.2 0.9 0.75]...'YTickLabel',ytl,'YTick',yt
                );
            end
            set(ERP,'CurrentAxes',axerp);
            
            %%%%%
            if evalin('base', 'exist(''Cond_Color'')==1') 
             
                color = evalin('base','Cond_Color');
                
            end
            
            %%%%%
            
            
            if ifbl ==1
                hold on
                line([bl(1) bl(2)],[-0 -0],'LineWidth',10,'Color',[.5 .5 .5]);
            end
            
            %GLAN.erp.cfg.laplace{nbcomp} = laplace;
            %Div = 0;
            if ifmat
            
            for c = difind %[cond1 cond2];
                cont = cont + 1;
                Div{cont} = GLAN.erp.datadif{c}(roi,:);
                
                plot(ltime,mean(GLAN.erp.datadif{c}(roi,:),1),'Color',color{cont},'LineWidth',2......
                    );%,'Interruptible','off');
                ylim(c_axis)
                hold on;
                
                if ifbl
                    xlim([ltime(1)  ltime(length(ltime))]);
                    line([bl(1) bl(2)],[0 0],'LineWidth',10,'Color',[.5 .5 .5]);
                    %xlim([bl(1,1)  time(1,2)]);
                    text( (bl(1,1) ), 2+(-0.8 * cont ),[ GLAN.conddif{c} ],'Color',color{cont} );
                else
                    xlim([ltime(1)  ltime(length(ltime))]);
                    text( (ltime(1) ), 2+(-0.5 * cont ),[ GLAN.conddif{c} ],'Color',color{cont} );
                    
                end
            end 
             else   
                
                cont = 0;
            for c = condM %[cond1 cond2];
                
                cont = cont + 1;
                g = congM(cont);
                
                
                if see_ica
                    disp('See components')
                    pasoD = ica_W*GLAN.erp.data{g,c};
                else
                    pasoD = GLAN.erp.data{g,c};
                end
                
                
                Div{cont} = pasoD(roi,:);
                paso = mean(pasoD(roi,:),1);
                if ifbl
                    paso = paso - repmat(mean(paso(:,plb(1):plb(2)),2),[1,size(paso,2),1]);
                    Div{cont} = Div{cont} - repmat(mean(Div{cont}(:,plb(1):plb(2)),2),[1,size(Div{cont},2),1]);
                end
                if cont<=length(color)
                    currentcolor = color{cont};
                else
                    currentcolor = [rand(1,3)] ;   
                end
                plot(ltime,paso,'Color',currentcolor,'LineWidth',2......
                    );%,'Interruptible','off');
                ylim(c_axis)
                hold on;
                
                if ifbl % ==1
                    xlim([ltime(1)  ltime(length(ltime))]);
                    %xlim([bl(1,1)  time(1,2)]);                     %GLAN.group{g}
                    text( (bl(1,1) ), 2+(-0.8 * cont ),[ GLAN.cond{c} ' - '   ],'Color',currentcolor );
                else
                    xlim([ltime(1)  ltime(length(ltime))]);
                    text( (ltime(1) ), 2+(-0.5 * cont ),[ GLAN.cond{c}  ' - '  ],'Color',currentcolor );
                    
                end
            end
            end
            
            if length(Div)>2
                Div = std(cat(4,Div{:}),0,4);
            elseif length(Div)==2
                Div = Div{1}-Div{2};
            else
                Div = zeros(size(Div));
            end
            
            plot(ltime,mean(Div,1),'--','Color',[0.5 0.5 0.5]...
                );%,'Interruptible','off');
            hold on;
            if see_ica
                title( [ 'ERP of ICA Component  (' num2str(roi) ')']);
            else
                title( [ 'ERP of electrode ' GLAN.chanlocs(roi).labels  '(' num2str(roi) ')']);
            end
            
            xlabel('Seconds');
            ylabel('\mu V');
            if isfield(GLAN.erp,'time')
                set(gca,'XTick',GLAN.erp.time.tick)
                set(gca,'XTickLabel',GLAN.erp.time.label)
            end
            if exist('y_ax')==1 || isempty(y_ax)
                y_ax = get(gca,'ylim');
                %if y_ax(1) > -3 , y_ax(1) = -3;end
                %if y_ax(2) < 3 , y_ax(2) = 3;end
            end
            set(gca,'ylim',y_ax);
             set(axerp,'Parent',ERP,...
                ... 'YTickLabel',ytl,'YTick',yt
                'Position',[0.05 0.2 0.9 0.75]...
               );
            if see_ica
                figure
                %topoplot_lan(winv(:,ncomp),LAN{ncd}.chanlocs)
                %subplot('Position',[0.85 0.85 0.1 0.1],'Units','Normalize')
                [b,bb,handle_ica] = topoplot_lan(ica_iW(:,roi),GLAN.chanlocs,'emarker' , {'.','k',5,1}  ,'shading' ,'interp' , 'style' , 'map' );
                %set(handle_ica,'Parent',ERP,...
                %... 'YTickLabel',ytl,'YTick',yt
                %'Position',[0.85 0.85 0.1 0.1]...
               %);
            end
            
            
           
           
            
            
            
            
            
            ifaxh=1;
            ifaxerp=1;
        else%%%% for group
            
            time(1) = 0;
            time(2) = size(GLAN.erp.data{comp},2) /GLAN.srate;
            time = time + GLAN.time(1);
            
            linspace(time(1),time(2),size(GLAN.erp.data{comp},2));
            cont = 0;
            
            
            for cc = 1:length(GLAN.erp.data)
                
                plot(ltime(find(hh{cc}(roi,:)==1)),ones(1,length(find(hh{cc}(roi,:)==1))),...
                    '--rs','LineStyle','none',...
                    'MarkerFaceColor',[1 0.8 0.8],...'g',...
                    'MarkerSize',3);
                d =diff(hh{cc}(roi,:));
                for pp = find(d==1)
                    text(ltime(pp),-2,['pval=' num2str(pvalc{cc}(roi,pp+1)) ]);
                end
                if ~isempty(bl)
                    line([bl(1) bl(2)],[-0 -0],'LineWidth',10,'Color',[.5 .5 .5]);
                end
                if cc == length(GLAN.erp.data)
                    hold off;
                else
                    hold on;
                end
                
                
                cont = 0;
                
                
                
                for g = 1:size(GLAN.erp.data,1)
                    cont = cont + 1;
                   % bll=0;
                    plot(ltime,GLAN.erp.data{g,cc}(roi,:),'Color',color{cont}...
                        );%hold on;,'Interruptible','off'
                    
                    
                    if bll ==1
                        xlim([bl(1,1)  time(1,2)]);
                        text( bl(1,1)+0.3 ,-1*cont ,[ GLAN.cond{cc} ],'Color',color{cont} );
                    else
                        xlim([ltime(1)  ltime(length(ltime))]);
                    end
                end
            end
        end
        
        

    end
    function editFc(paso,paso1)
        butt=3;
        while butt == 3 
   %         try 
                figure(ERP)
                [X Y butt]=ginput(1);
                if ~isempty(X)&&(X >= ltime(1))&&(X <= ltime(end))
                t =  X;
                time = t;
                set(guitiempo,'String', num2str(time));
                refresh(CONTROLES)
                topo_button_Callback,
                dif_button_Callback,
                %butt
                X=[];
  %              else
                    
                X=[];
  %              end
            end
            %
            %COMP_CONTROLES
        end 
    end

%%%%%%%%%%%%%%%%%%
%%%
%%%  WITH TOPOPLOT
%%%
%%%%%%%%%%%%%%%%%%

    function topo_button_Callback(source,eventdata)
        
        
        COMP_TOPOPLOT
        uicontrol('Style','pushbutton','Position',[0,0,20,20],'String','E','Callback',{@editF})
        uicontrol('Style','pushbutton','Position',[0,20,20,20],'String','S','Callback',{@editF})
         uicontrol('Style','pushbutton','Position',[0,40,20,20],'String','C','Callback',{@editF})
       % check time
        edit_time_menu_Callback(guitiempo)
        
        if ~txt
            texto = plus_text(texto,'Please select a time point for topographic plot');
            disp_lan(texto);
            txt =1;
        end
        if isfield(GLAN, 'chanlocs')
            
            X = time;
            
            t = fix((X*GLAN.srate) - (GLAN.time(1)*GLAN.srate));
            if length(t)==1
                t(2) = t(1);
            end
            
            
            
            if ifmat
            cont = 0;
            for c = difind %[cond1 cond2];
                cont = cont + 1;
                gp{cont} = mean(GLAN.erp.datadif{c}(:,t(1):t(2)),2);
            end
            else
                cont = 0;
             for  c = condM
                  cont = cont + 1;
                  g = congM(cont);
                %n1 = cond1;
                %n2 = cond2;
                paso = mean(GLAN.erp.subdata{g,c}(:,:,:),3);
                if ifbl
                    paso = paso - repmat(mean(paso(:,plb(1):plb(2),:),2),[1,size(paso,2),1]);
                end
                gp{cont} = mean(paso(:,t(1):t(2)),2);
               %gp2 = mean(GLAN.erp.data{n2}(:,t(1):t(2)),2);
             end
            end
            
            
            
            if isnumeric(roi)
                rroi = arreglaroi(roi,GLAN.chanlocs);
                ifroi = 1;
            else
                ifroi = 0;
            end
            %%% TOPOPLOT
            
            for ng = 1:length(gp)
            
            subplot(length(gp),1,ng)
            if ifroi
                [gx gy] = topoplot_lan(gp{ng},GLAN.chanlocs,'emarker' , {'.','k',5,1}  ,'emarker2' , {rroi,'*','k'},'shading' ,'interp' , 'style' , 'map' );
            else
                [gx gy] = topoplot_lan(gp{ng},GLAN.chanlocs,'emarker' , {'.','k',5,1}  ,'shading' ,'interp' , 'style' , 'map' );
                
            end
            colormap('jet');
            caxis([c_axis]);hold on;
            try 
                if ifmat
                title({GLAN.conddif{difind(ng)};['at ' num2str(fix(X*1000)) ' ms'] });    
                else
                title({GLAN.cond{congM(ng),condM(ng)};['at ' num2str(fix(X*1000)) ' ms'] }); 
                end
            end
            if ifroi
                plot(gy(rroi),gx(rroi),...
                    'ko','LineStyle','none',...
                    'MarkerFaceColor',[1 0.8 0.8],...'g',...
                    'MarkerSize',8);
                colorbar; %%%otro cambio FZ
            end
            hold off;
            %%%%%%
            end
            
                
            
            
            
        end
    end

    function FUN_button_Callback(source,eventdata)
     stre = get(source, 'String');
        switch stre    
        case 'Dif'
              set(source,'String','Mean')
        case 'Mean'
              set(source,'String','Dif')  
        end
        
    end
    function dif_button_Callback(source,eventdata)
    FUN_type = get(FUN_boton,'String');     
        
        COMP_TOPODIF
        uicontrol('Style','pushbutton','Position',[0,0,20,20],'String','E','Callback',{@editF})
        uicontrol('Style','pushbutton','Position',[0,20,20,20],'String','S','Callback',{@editF})
        uicontrol('Style','pushbutton','Position',[0,40,20,20],'String','C','Callback',{@editF})
        uicontrol('Style','pushbutton','Position',[0,60,20,20],'String','Hot','Callback',{@editF})
     % check time
        edit_time_menu_Callback(guitiempo)
        
        %end
        
        
        % buscando estadisticas ya hechas
        for bc = 1:length(GLAN.erp.comp)
%             try 
%                 r = sum(sort([cond1 cond2])==sort(GLAN.erp.comp{bc}));
%             catch
%                     r=0;
%             end
            if 1 %r ==2
                if isfield(GLAN.erp,'hhc')
                    try
                    hh = GLAN.erp.hhc{bc};
                    pvalc = GLAN.erp.pvalc{bc};
                    cluster = GLAN.erp.cluster{bc};
                    catch
                     ifh = 0; r =1;cluster = [];   
                    end
                elseif isfield(GLAN.erp,'hh')
                    try
                    hh = GLAN.erp.hh{bc};
                    pvalc = GLAN.erp.pval{bc};
                    cluster = [];
                    catch
                     ifh = 0; r =1;cluster = [];   
                    end   
                else
                    ifh = 0; r =1;cluster = [];
                end
                
                break
            end
        end
        if ~txt
            texto = plus_text(texto,'Please select a time point for topographic plot');
            disp_lan(texto);
            txt=1;
        end
        %%% arregalr para calcular comparaciones no realizadas
            if  ifstat&&(get(STA,'Value')<(length(get(STA,'String'))-1))  % r == 2
                hh = GLAN.erp.hh{get(STA,'Value')};
                ifh = 1;
                if  isfield(GLAN.erp, 'hhc') && ~isempty(GLAN.erp.hhc{get(STA,'Value')}) 
                    hhc= GLAN.erp.hhc{get(STA,'Value')};
                    pvalc = GLAN.erp.pvalc{get(STA,'Value')};
                    cluster = GLAN.erp.cluster{get(STA,'Value')};
                    ifhhc = true;
                else
                    ifhhc = false;
                end
            else
                 ifh =0;
            end
            %%%-------------------------------
        if isfield(GLAN, 'chanlocs')
            
            X = time;
            
            t = fix((X*GLAN.srate) - (GLAN.time(1)*GLAN.srate));
            if length(t)==1
                t(2) = t(1);
            end
          
          clear gp
          if ifmat
            cont = 0;
            for c = difind %[cond1 cond2];
                cont = cont + 1;
                gp{cont} = mean(GLAN.erp.datadif{c}(:,t(1):t(2)),2);
            end
            else
                cont = 0;
             for   c = condM
                  cont = cont + 1;
                   g = congM(cont) ;
                gp{cont} = mean(GLAN.erp.data{g,c}(:,t(1):t(2)),2);
             end
          end
            
            
            
            if isnumeric(roi)&&~isempty(roi)
                ifroi = 1;
                rroi = arreglaroi(roi,GLAN.chanlocs);
            else
                ifroi = 0;
            end
            
            if length(gp) > 2
                switch FUN_type
                    case 'Dif'
                        ddd = std(cat(4,gp{:}),0,4);
                        cca = [0 max(max(ddd))];
                    case 'Mean'
                         ddd = mean(cat(4,gp{:}),4);
                        cca = [-1*max(max(abs(ddd))) max(max(abs(ddd)))];
                 end
                
                %cca = [0 max(max(ddd))];
                ifdiv = false;
            else
                switch FUN_type
                    case 'Dif'
                    ddd = gp{1}-gp{2};
                    cca = c_axis/2;
                    case 'Mean'
                     ddd = mean(cat(4,gp{:}),4);
                     cca = [-1*max(max(abs(ddd))) max(max(abs(ddd)))]; 
                end
                ifdiv = true;
            end
            
            % DIF TOPOPLOT
            subplot(2,1,1)
            [gx gy] = topoplot_lan(ddd,GLAN.chanlocs,'shading' ,'interp' , 'style' , 'map');
            caxis(cca);
            hold on;
            switch FUN_type
                    case 'Dif'           
                    colormap(hot(100));
                    titulo = 'std';
                    case 'Mean'           
                    colormap(jet(100));
                    titulo = 'mean'
            end
            colorbar %%%otro cambio FZ
            clear ddd
            try 
                if ~ifdiv
                   title({titulo ;['at ' num2str(fix(X*1000)) ' ms'] });
              
                else
                if ~ifmat                    
                    title({[ GLAN.cond{condM(1)} ' - ' GLAN.cond{condM(2)} ] ;['at ' num2str(fix(X*1000)) ' ms'] });
                else
                    title({[ GLAN.conddif{difind(1)} ' - ' GLAN.conddif{difind(2)} ] ;['at ' num2str(fix(X*1000)) ' ms'] });
                end
                end
            end
            
            %
            if ifroi
                plot(gy(rroi),gx(rroi),...
                    'ko','LineStyle','none',...
                    'MarkerFaceColor',[1 0.8 0.8],...'g',...
                    'MarkerSize',8);
            end
            hold off; 
            % cluster
            
            subplot(2,1,2)
            [gx gy] = topoplot_lan(zeros(size(gp{1})),GLAN.chanlocs,'style'  ,'blank','electrodes','labelpoint','emarker',{'.','k',[],0.5});
            caxis(c_axis/2);hold on;
            
            
            if  isfield(GLAN.erp,'cluster') && ifroi
                nr = round(Y);
                try 
                    if isempty(roi(nr))
                        nr=1;
                    end
                catch
                    nr=1;
                end
                pvc = pvalc(roi(nr),t(1));
                c = cluster(roi(nr),t(1));
                if (c == 0)&&(pvc==0)
                    pvc='no cluster';
                end
                %try
                
                
                % c=1
                if c ~= 0
                    %%% a lo largo del tiempo
                    ci = zeros(size(cluster));
                    ci(cluster==c) =1;
                    ci = find(any(ci,2));
                    for cl = 1:size(ci,1)
                        cli = arreglaroi(ci(cl),GLAN.chanlocs);
                        if cli == 0,continue,end
                        plot(gy(cli),gx(cli),...  %%
                            'ro','LineStyle','none',...
                            ...'MarkerFaceColor',[1 0 0],...'g',...
                            'MarkerSize',10);
                    end
                    %%% en tiempo t
                    ci = [];
                    for ce = 1:size(cluster,1)
                        if any(c==cluster(ce,t(1):t(2)))
                        ci = cat(1,ci,ce)  ;  
                        end
                    end
                    %c==cluster(:,t(1):t(2))
                    %ci = find(c==cluster(:,t(1)));
                    for cl = 1:size(ci,1)
                        cli = arreglaroi(ci(cl),GLAN.chanlocs);
                        if cli == 0,continue,end
                        plot(gy(cli),gx(cli),...  %%
                            'ro', ...
                            'LineStyle','none',...
                            'MarkerFaceColor',[1 0 0],...'g',...
                            'MarkerSize',10);
                    end
                    
                    %%%%
                    %title({ ['Clusters # '  num2str(c) ''  ] ; ['at ' num2str(fix(X(1)*1000)) ' ms'] ; [ 'p=' num2str(pvc) '(corrected)'] });
                    %hold off
                end
                    if ~ischar(pvc), pvc = [num2str(pvc) '(corrected)' ]; end
                    title({ ['Clusters # '  num2str(c) ''  ] ; ['at ' num2str(fix(X(1)*1000)) ' ms'] ; [ 'p=' pvc ] });
                    hold off               
                %end
                
            %end
        end
        %%%%%%
        end 
    end






    function ep_button_Callback(source,eventdata)
        if exist([figname '.pdf'],'file')==2 || exist([figname '.ps'],'file')==2
            figname = [figname '1'];
            ep_button_Callback
            return
        end
        display([ 'Save a graphic as a file: ' figname ' with: '])
        try
            %saveas(ERP, figname,'pdf')
            strcmp('on',get(ERP,'Visible'))
            if strcmp('on',get(ERP,'Visible'))
                print(ERP, '-dpsc',   [figname ]) %pdf
                display('ERP,')
            end
            
        end
        try
            if strcmp('on',get(ERP_ALL,'Visible'))
                print(ERP_ALL, '-dpsc', '-append' ,[figname ] )
                display('ERP_ALL,')
            end
        end
        try
            if strcmp('on',get(TOPOS,'Visible'))
                %print(TOPOS, '-djpeg','-r300','-zbuffer',  [figname ])
                %%% )
                print(TOPOS, '-dpsc', '-r300', '-zbuffer','-append', [figname ] )
                display('TOPOPLOT,')
            end
        end
        try
            if strcmp('on',get(TOPODIF,'Visible'))
                %%%print(TOPODIF, '-dpsc','-append',[figname]  )
                print(TOPODIF, '-djpeg','-r600','-zbuffer',  [figname ])
                %print(TOPODIF, '-dpsc','-r600', '-zbuffer','-append', [figname]  )
               %  print(TOPODIF, '-dpsc','-append', [figname]  )
                display('TOPOPLOT(DIF),')
                
                
                
            end
        end
        
        try
            un = ps2pdf([ figname '.ps' ]);
        catch
            disp('ONLY .ps ... Have you ghostscript in the path ?')
            un = 1;
        end
        
        if un ~= 0
            disp('ONLY .ps ... Have you ghostscript in the path ?')
        end
        disp('ok')
    end


    function close_button_Callback(source,eventdata)
        n=2;
        warning off
        %try close gcf , end;
        try close(ERP); end
        try close(CONTROLES);end
        try close(TOPOS);end
        try close(TOPODIF);end
        try close(ERP_ALL);end
        
        try close(gcf) , end
        if iflantoolbox
        lantoolbox(GLAN)    
        else
        disp('....')
        disp('Thank you for using LAN toolbox')
        end
        %disp('DONE')
        
        clear
        warning on
    end

    function fun_B_table_r(source,eventdata)
   stre = get(source, 'String');
        switch stre
            case 'mean'   
            set(source, 'String','min');
            fun_erp = 'min';
            case 'min'   
            set(source, 'String','max');
            fun_erp = 'max';
             case 'max'   
            set(source, 'String','mean');
            fun_erp = 'mean';
        end
    end





    function B_table_r(source,eventdata)
        
        % tiempo

        stre = get(guitiempo, 'String');
        time = eval(['[' stre ']' ]);
        disp(['set new time:' stre])

        X = time; 
            t = fix((X*GLAN.srate) - (GLAN.time(1)*GLAN.srate));
            if length(t)==1
                t(2) = t(1);
            end
        % roi
        cont = 0;
            for c = unique(condM) %[cond1 cond2];               
            for g = unique(congM(condM==c));

        
        
        paso = GLAN.erp.subdata{g,c}(roi,:,:);
        if ifbl
           paso = paso - repmat(mean(paso(:,plb(1):plb(2),:),2),[1,size(paso,2),1]);
        end
        
       % for e =1:length(roi)
            cont = cont + 1;
            switch fun_erp
                case 'mean'
                     DATA{cont} =  squeeze(mean(mean(paso(:,t(1):t(2),:),1),2));
                case 'min'
                     DATA{cont} =  squeeze(min(mean(paso(:,t(1):t(2),:),1),[],2));
                case 'max'
                    DATA{cont} =  squeeze(max(mean(paso(:,t(1):t(2),:),1),[],2));
            end
            G{cont} = repmat(g,size(DATA{cont}));
            E{cont} = repmat({['Chanenl_index:' num2str(roi)]},size(DATA{cont}));
            C{cont} = repmat(c,size(DATA{cont}));
            S{cont} = GLAN.subject{g}(:);
        %end
        
        end
            end
        DATA_R = table(cat(1,DATA{:}), cat(1,G{:}) , cat(1,C{:}) , cat(1,E{:}), cat(1,S{:}) , 'VariableNames' , {'ERP', 'Group','Condition','Electrode', 'Subject'} )    
        clear DATA G E C S 
        if evalin('base','exist(''DATA_R'')==1')
           paso =  evalin('base','DATA_R');
           DATA_R = cat(1, paso, DATA_R);
        end
        
        assignin('base', 'DATA_R',DATA_R)
    end

    function edit_menu_Callback(source,eventdata)
        stre = get(source, 'String');
        try
        roi = eval(['[' stre ']' ]);
        catch
            nss=1;
            while ~sempty(stre)
                if isempty(find(stre==' ',1))
                   fin=length(stre);
                else
                    fin=find(stre==' ',1)-1;
                end
                paso{nss}= stre(  find(stre~=' ',1):fin);
                stre(1:fin)=[];
                nss=nss+1;
            end
            roi=[];
          for ne = length(paso):-1:1  
          roi =  cat(2, find(ifcellis({GLAN.chanlocs.labels},paso{ne})), []);
          end
          
        end
        hold off;
    end
% %-- edit figures
%     function editF(source,eventdata)
%         stre = get(source, 'String');
%         switch stre
%             case 'E'
%                 set(gcf,'MenuBar','figure');
%             case 'S'
%                 [file,path,type] = uiputfile({'*.eps';'*.jpg';'*.pdf'},'Save figure','figure');
%                 if type==1
%                 print(gcf,'-depsc2',[path file]);
%                 elseif type==3
%                 print(gcf,'-dpdf',[path file]);
%                 else
%                 print(gcf,'-opengl','-djpeg','-r600',[path file])    
%                 end         
%         end;
%         
%         
%     end



    function edit_caxis_menu_Callback(source,eventdata)
        stre = get(source, 'String');
        c_axis = eval(['[' stre ']' ]);
        
    end
    function edit_time_menu_Callback(source,eventdata)
        stre = get(source, 'String');
        time = eval(['[' stre ']' ]);
        t = time; X = [];
        
        disp(['set new time:' stre])
    end

    function rroi = arreglaroi(roi, chanlocs)
        rroi = zeros(1,length(roi));
        for nroi = 1:length(roi)
            for ccda = 1:roi(nroi)
                if ~isempty(chanlocs(ccda).X)
                    rroi(nroi) = rroi(nroi) +1;
                end
            end
        end
    end

%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%-----------COMP
%%%%%%%%%%%%%%%%%%%%%%%%%%

    function COMP_CONTROL
        if exist('CONTROLES')==1
            try Pc=get(CONTROLES,'Position'); close( CONTROLES);catch , Pc = [1 5*(scrsz(4)/6) scrsz(3) scrsz(4)/6]; end
        else
            Pc = [1 5*(scrsz(4)/6) scrsz(3) scrsz(4)/6];
        end
        CONTROLES = figure('Position',Pc,...
            'Name',[ 'ERP - Controles en LAN v.' lanversion ],'NumberTitle','off','MenuBar', 'none');%,'Color','k');
        set(CONTROLES,'CloseRequestFcn',@close_button_Callback)
    end
%------------------------------
    function COMP_ERP_ALL
        if exist('ERP_ALL')==1
            try  Pea=get(ERP_ALL,'Position'); close(ERP_ALL) ; end
        else
            %Pe =[1   fix(1.3*scrsz(4)/6)       fix(scrsz(3)/2) fix(3*scrsz(4)/6) ];
        end
        ERP_ALL = figure('Visible','on','Position',Pea,...
            'Name','ERP all','NumberTitle','off','MenuBar', 'none');
    end
%------------------------------
    function COMP_ERP
        if  ishandle(ERP)
            try  Pe=get(ERP,'Position'); close(ERP) ; end
        else
            %Pe =[1   fix(1.3*scrsz(4)/6)       fix(scrsz(3)/2) fix(3*scrsz(4)/6) ];
        end
        ifaxh=0;ifaxerp=0;
        ERP = figure('Visible','on','Position',Pe,...
            'Name','ERP','NumberTitle','off','MenuBar', 'none');
    end
%------------------------------
    function COMP_TOPOPLOT
        if exist('TOPOS')==1
            try  Pt=get(TOPOS,'Position'); close(TOPOS) ; catch ; end
        else
            % Pt =[1+fix(3*scrsz(3)/6)    fix(1.3*scrsz(4)/6)     fix(scrsz(3)/6)  fix(3*scrsz(4)/6) ];
        end
        TOPOS = figure('Visible','on','Position',Pt,...
            'Name','Topoplot','NumberTitle','off','MenuBar', 'none');
    end
%------------------------------
    function COMP_TOPODIF
        if exist('TOPODIF')==1
            try  Pd=get(TOPODIF,'Position'); close(TOPODIF) ; catch ; end
        else
            %Pt =[1+fix(3*scrsz(3)/6)    fix(1.3*scrsz(4)/6)     fix(scrsz(3)/6)  fix(3*scrsz(4)/6) ];
        end
        TOPODIF = figure('Visible','on','Position',Pd,...
            'Name','TopoplotDif','NumberTitle','off','MenuBar', 'none');   
    end
%------------------------------

function COMP_ICA_cal
  
    if ifGUI_ica
       set(GUI_ICA_cal,'Visible','on');
    else
       
       GUI_ICA_cal = figure('Visible','on','Units','normalized',...
               'Position',p_ica,...
               'Name','ICA calulate','NumberTitle','off','MenuBar', 'none',...
               'CloseRequestFcn',@close_ica...
               );
        ifGUI_ica=1;
        
        nica = [];
        if isfield(GLAN.erp, 'ICAerp' )
            for nn = 1:length(GLAN.erp.ICAerp)
                nica{nn} = num2str(nn);
            end
        end
        nica{length(nica)+1} = 'NEW';
        uicontrol(GUI_ICA_cal ,'Units','normalized','Style','text','String','Select',...
          'Position',[0.01,0.8,0.23,0.15] ...%'BackgroundColor',cf,'ForegroundColor',fc
           );
        uicontrol(GUI_ICA_cal ,'Units','normalized','Style','popupmenu','String',nica,...
          'Position',[0.25,0.8,0.75,0.15],'Callback',{ @ICA_fun } ...%'BackgroundColor',cf,'ForegroundColor',fc
           ); 
       
           uicontrol(GUI_ICA_cal ,'Units','normalized','Style','text','String','conditions included',...
          'Position',[0.01,0.6,0.23,0.15] ...%'BackgroundColor',cf,'ForegroundColor',fc
           );
       global ICA_COND
           ICA_COND = uicontrol(GUI_ICA_cal ,'Units','normalized','Style','edit','String','',...
          'Position',[0.25,0.6,0.75,0.15]...,'Callback',{ @ICA_fun_d } ...%'BackgroundColor',cf,'ForegroundColor',fc
           ); 
       uicontrol(GUI_ICA_cal ,'Units','normalized','Style','text','String','groups included',...
          'Position',[0.01,0.4,0.23,0.15] ...%'BackgroundColor',cf,'ForegroundColor',fc
           );
       global ICA_GROUP
           ICA_GROUP = uicontrol(GUI_ICA_cal ,'Units','normalized','Style','edit','String','',...
          'Position',[0.25,0.4,0.75,0.15]...,'Callback',{ @ICA_fun_d } ...%'BackgroundColor',cf,'ForegroundColor',fc
           ); 
       
        uicontrol(GUI_ICA_cal ,'Units','normalized','Style','text','String','numb components',...
          'Position',[0.01,0.2,0.23,0.15] ...%'BackgroundColor',cf,'ForegroundColor',fc
           );
       global ICA_nc
           ICA_nc = uicontrol(GUI_ICA_cal ,'Units','normalized','Style','edit','String','',...
          'Position',[0.25,0.2,0.75,0.15]...,'Callback',{ @ICA_fun_d } ...%'BackgroundColor',cf,'ForegroundColor',fc
           ); 
       
       global ICA_BP
           if strcmp(nica{1},'NEW')
               TX='Calculate';
           else
               TX='See';
           end
       
       
           ICA_BP = uicontrol(GUI_ICA_cal ,'Units','normalized','Style','pushbutton','String',TX,...
          'Position',[0.25,0.025,0.5,0.15],'Callback',{ @ICA_fun_bp } ...%'BackgroundColor',cf,'ForegroundColor',fc
           ); 
       
 
    end
    

    
        function ICA_fun(s,ss) 
            stre = get(s, 'String');
            val = get(s, 'Value');
            disp(['setting ' stre{val} ' ICA'])
        switch stre{val}
            case 'NEW'
               set(ICA_GROUP,'String','select new') ;
               set(ICA_COND,'String','select new') ;
               set(ICA_nc,'String','select new (-1 is posible)') ;
               set(ICA_BP,'String','Calculate');
               
            otherwise 
               set(ICA_GROUP,'String',num2str(GLAN.erp.ICAerp(str2num(stre{val})).group)) 
               set(ICA_COND,'String',num2str(GLAN.erp.ICAerp(str2num(stre{val})).cond)) 
               set(ICA_nc,'String',num2str(GLAN.erp.ICAerp(str2num(stre{val})).nb_components)) 
               set(ICA_BP,'String','See');
               
               ica_W = GLAN.erp.ICAerp(str2num(stre{val})).ica_weights*GLAN.erp.ICAerp(str2num(stre{val})).ica_sphere  ; 
               ica_iW = pinv(ica_W);
                
                
               
               
            end
        end
        
        function ICA_fun_bp(s,ss) 
            stre = get(s, 'String');
           
            switch stre
                case 'Calculate'
                    icag = eval([ '[' get(ICA_GROUP,'String') ']' ]);
                    icac = eval([ '[' get(ICA_COND,'String') ']' ]);
                    ican = eval([ '[' get(ICA_nc,'String') ']' ]);
                    
                    % special case of -1 componentes
                    if ican <1
                        ican = size(GLAN.erp.data{icag(1),icac(1)},1)+ican;
                    end
                    
                    DATA = GLAN.erp.subdata{icag(1),icac(1)};
                    for ii = 2:length(icag)
                        DATA = cat(3,DATA, GLAN.erp.subdata{icag(ii),icac(ii)}) ;
                    end
                        DATA = reshape(DATA,[size(DATA,1) ,size(DATA,2)*size(DATA,3) ]);
                        [weights,sphere] = runica(DATA,'extended', 1,'pca',ican);

                        if isfield(GLAN.erp, 'ICAerp')
                            nnn = length(GLAN.erp.ICAerp)+1;
                        else
                            nnn=1;
                        end
                        GLAN.erp.ICAerp(nnn).group = icag;
                        GLAN.erp.ICAerp(nnn).cond = icac;
                        GLAN.erp.ICAerp(nnn).nb_components =ican;
                        GLAN.erp.ICAerp(nnn).ica_weights = weights;
                        GLAN.erp.ICAerp(nnn).ica_sphere = sphere;
                set(see_ACI,'ForegroundColor',[0 0 0] ) ;       
                close(GUI_ICA_cal);
            case 'See'
                see_ica=true;
                close(GUI_ICA_cal);
                set(see_ACI,'String','Electrodes' ) ; 
            end
        end
        
    
    
    end
    function close_ica(b, bb, bbb)
        p_ica=get(GUI_ICA_cal,'Position');
        delete(GUI_ICA_cal)
        ifGUI_ica =  0;
    end


% active currect value
set(STA,'Value', 1)
STA_fun(STA); 
lb_Callback(GUIbl);
GUI_s(GUIS);
%nor_Callback();

end % function