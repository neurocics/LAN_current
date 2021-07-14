function lantoolbox(LAN)
% 
%     <*LAN)<]
%     MAIN GUI
%
%     v.0.0.3
%     Pablo Billke

% 14.08.2015 add .set importation 
% 9.03.2012
% 6.03.2012

 global xLAN
 global nameLAN
 
 if (nargin == 0)
     xLAN =[];
     nameLAN='xLAN';
 else
      xLAN = LAN;      
       nameLAN = inputname(1);
 end
 
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
 
 clear LAN
%--- LOGO

fc = get_landef('fc');
bc = get_landef('bc');
global menu
menu = figure('Visible','on','Position',pp,...
    'Name',lanversion('l'),'NumberTitle','off','MenuBar', 'none','Color','Black');
%
letras = uicontrol('Units','normalized','Position',...
    [0.1 0.9 0.8 0.1],'Style','text','String',[  'LAN toolbox'],'FontSize',25,...
    'ForegroundColor',[0 1 0],...
     'BackgroundColor',[0 0 0]...
    );
       uicontrol('Style','text','Units','normalized','BackgroundColor',[0 0 0],...
            'ForegroundColor',fc,...
            'String', 'version:' ,...opciones{pp,1},...
            'Position',[0.1,0.85,0.8,0.05]...'BackgroundColor',cf,...
            );
        uicontrol('Style','text','Units','normalized','BackgroundColor',bc,'ForegroundColor',fc,......
            'String', lanversion ,...opciones{pp,1},...
            'Position',[0.1,0.8,0.8,0.05]...'BackgroundColor',cf,...
            );
 
 %--- Structure
 global STR
 global LANB
 guistr(xLAN)
 
 function guistr(xLAN)
     
       uicontrol('Style','pushbutton','String','Close','Units','normalized',...
             'Position',[0.67, 0.08 ,0.3,0.06],...
             ...'BackgroundColor',bc,'ForegroundColor',fc,...
             'Callback',{@bottonfunction});  
         
       uicontrol('Style','pushbutton','String','Clear','Units','normalized',...
             'Position',[0.67, 0.01 ,0.3,0.06],...
             ...'BackgroundColor',bc,'ForegroundColor',fc,...
             'Callback',{@bottonfunction});  
             
     
 if (nargin == 0)|| isempty(xLAN)

        STR =  uicontrol('Style','text','Units','normalized','BackgroundColor',bc+0.1,'ForegroundColor',fc,......
            'String', '...' ,...opciones{pp,1},...
            'Position',[0.1,0.75,0.8,0.05]...'BackgroundColor',cf,...
            ,'Callback',{@bottonfunction}); 
        LANB{1,1} =  uicontrol('Style','pushbutton','String',...
         'open file','Units','normalized',...
         'Position',[0.1, 0.6 ,0.39,0.09],... 'BackgroundColor',cf,... 'ForegroundColor',fc,...
         'Callback',{@bottonfunction}); 
        LANB{1,2} =  uicontrol('Style','pushbutton','String',...
         'open var','Units','normalized',...
         'Position',[0.51, 0.6 ,0.39,0.09],... 'BackgroundColor',cf,... 'ForegroundColor',fc,...
         'Callback',{@bottonfunction}); 
     LANB{2,2} =  uicontrol('Style','pushbutton','String',...
         'import fileIO','Units','normalized',...
         'Position',[0.51, 0.5 ,0.39,0.09],... 'BackgroundColor',cf,... 'ForegroundColor',fc,...
         'Callback',{@bottonfunction}); 
     LANB{2,1} =  uicontrol('Style','pushbutton','String',...
         'import file','Units','normalized',...
         'Position',[0.1, 0.5 ,0.39,0.09],... 'BackgroundColor',cf,... 'ForegroundColor',fc,...
         'Callback',{@bottonfunction}); 
     
 else
     
     uicontrol('Style','pushbutton','String','Save(F)','Units','normalized',...
             'Position',[0.03, 0.08 ,0.3,0.06],...
             ...'BackgroundColor',bc,'ForegroundColor',fc,...
             'Callback',{@bottonfunction});
         
      uicontrol('Style','pushbutton','String','Save(V)','Units','normalized',...
             'Position',[0.35, 0.08 ,0.3,0.06],...
             ...'BackgroundColor',bc,'ForegroundColor',fc,...
             'Callback',{@bottonfunction});  
         

         
     if iscell(xLAN) || isfield(xLAN,'data')
        nt =1;
        pasot{nt} = 'LAN structure';
        if iscell(xLAN) 
            nt=nt +1;
            pasot{nt} = ['Conditions:' num2str(length(xLAN))]; 
        end
         
        STR =   uicontrol('Style','text','Units','normalized','BackgroundColor',bc+0.1,'ForegroundColor',fc,......
            'String',pasot  ,...opciones{pp,1},...
            'Position',[0.1,0.75,0.8,0.05]...'BackgroundColor',cf,...
            );
        
        LANB{1,1} =  uicontrol('Style','pushbutton','String','preprocesing','Units','normalized',...
         'Position',[0.1, 0.6 ,0.39,0.1],... 'BackgroundColor',cf,... 'ForegroundColor',fc,...
         'Callback',{@bottonfunction});
     
        LANB{1,2} =  uicontrol('Style','pushbutton','String','set_references','Units','normalized',...
         'Position',[0.51, 0.6 ,0.39,0.1],... 'BackgroundColor',cf,... 'ForegroundColor',fc,...
         'Callback',{@bottonfunction}); 
        
     elseif isstruct(xLAN) || isfield(xLAN,'subject')
         STR =   uicontrol('Style','text','Units','normalized','BackgroundColor',bc+0.1,'ForegroundColor',fc,......
            'String', 'GLAN structure' ,...opciones{pp,1},...
            'Position',[0.1,0.75,0.8,0.05]...'BackgroundColor',cf,...
            );
        if isfield(xLAN,'erp')
            cc = [0 0 0];
        else
            cc = [0.5 0.5 0.5];
        end
        LANB{1,1} =  uicontrol('Style','pushbutton','String','ERP','Units','normalized',...
         'Position',[0.1, 0.6 ,0.39,0.1],'ForegroundColor',cc,...... 'BackgroundColor',cf,... 
         'Callback',{@bottonfunction});
        if isfield(xLAN,'timefreq')
            cc = [0 0 0];
        else
            cc = [0.5 0.5 0.5];
        end
        LANB{1,2} =  uicontrol('Style','pushbutton','String','TIME-FREQ','Units','normalized',...
         'Position',[0.51, 0.6 ,0.39,0.1],'ForegroundColor',cc,... 'BackgroundColor',cf,... 'ForegroundColor',fc,...
         'Callback',{@bottonfunction});     
     
     end
 end
 end

 
function bottonfunction(source,eventdata,handles) 
    iflantoolbox = true;
    bt_name = get(source,'String');
    clear eventdata handles
    bt_cc = get(source,'ForegroundColor');
    if sum(bt_cc == 0.5)==3
        disp('function not abiable')
    else
    switch bt_name
        case 'preprocesing'            
            assignin('base','menuposition_tempLAN' , get(menu,'Position'));
            close all
            prepro_plot(xLAN)
            clear
        case 'set_references'            
            assignin('base','menuposition_tempLAN' , get(menu,'Position'));
            assignin('base',nameLAN ,xLAN);
            close all
            lan_setref_micromed(xLAN);
            %evalin('base',['lan_setref_micromed(' nameLAN  ');']);
            clear    
        case 'ERP'
            assignin('base','menuposition_tempLAN' , get(menu,'Position'));
            close all
            erp_plot(xLAN)
            clear
         case 'TIME-FREQ'
            assignin('base','menuposition_tempLAN' , get(menu,'Position')); 
            close all
            timefreq_plot(xLAN)
            clear
                       
        case 'Save(F)'
               assignin('base',  nameLAN  , xLAN);
                   [FileName,PathName,FilterIndex] = uiputfile('.mat','Save LAN variable',[nameLAN]);
                   if isequal(FileName,0) || isequal(PathName,0)
                       disp('User selected Cancel')
                    else
                       disp(['Saving ',fullfile(PathName,FileName)])
                       fprintf('Please wait ...')
                       evalin('base',[ ' save(  ''' PathName FileName ''' , ''' nameLAN ''' )' ]);
                       fprintf([ '  ok  \n'])
                   end
        case 'Save(V)'
            assignin('base',  nameLAN  , xLAN);
            disp(['Save variable as '''  nameLAN ''''])
        case 'Close'
            close(menu)
            evalin('base','clear *_tempLAN')
            disp('....')
            disp('Thank you for using LAN toolbox')
        case 'Clear'
            assignin('base','menuposition_tempLAN' , get(menu,'Position'));
            close(menu)
            evalin('base','clear nameLAN_tempLAN') 
            clear 
            lantoolbox
        case '...'
            disp('Choose an action')
        case 'open file'
            assignin('base','menuposition_tempLAN' , get(menu,'Position'));
            [FileName,PathName,FilterIndex] = uigetfile({'*.mat','MATLAB-file'; '*.lan','LAN-file'},'open LAN file',[nameLAN]);
                if isequal(FileName,0) || isequal(PathName,0)
                    disp('User selected Cancel')
                else                    
                    disp(['open ',fullfile(PathName,FileName)])
                    fprintf('Please wait ...')
                    nameLAN = choise_var(fullfile(PathName,FileName));
                    assignin('base','nameLAN_tempLAN',nameLAN);
                    evalin('base',[ ' load(  ''' PathName FileName ''' , ''' nameLAN ''' )' ]);
                    close(menu)
                    evalin('base',[ 'lantoolbox( ' nameLAN ' )' ]);
                    clear
                    fprintf([ '  ok  \n'])
                end  
        case 'open var'
            assignin('base','menuposition_tempLAN' , get(menu,'Position'));
            nameLAN = choise_var;
            if isempty(nameLAN)
                disp('there is no LAN variable in the workspace')
                return
            end
            assignin('base','nameLAN_tempLAN',nameLAN);
            %evalin('base',[ ' load(  ''' PathName FileName ''' , ''' nameLAN ''' )' ]);
            close(menu)
            evalin('base',[ 'lantoolbox( ' nameLAN ' )' ]);
            clear
            fprintf([ '  ok  \n'])
        case 'import file'
        [file, path, ind] = uigetfile({...
            '*.eeg', '.eeg - Neuroscan'; ...
            '*.cnt','.cnt - Neuroscan'; ...
            '*.TRC','.TRC - Micromed'; ...
            '*.trc','.trc - Micromed';
            '*.set','.set - EEGLAB'},...   
         'import file');
          if isequal(file,0) || isequal(path,0)
                    disp('User selected Cancel')
                else                    
                    disp(['open ',fullfile(file,path)])
                    fprintf('Please wait ...')
                       cc.filename = file;
                     cc.where = path;
                     cc.filepath = path;
                     if ind==1
                        LAN = eeg2lan(cc); 
                     elseif ind ==2
                        LAN = cnt2lan(cc); 
                     elseif ind ==3 || ind ==4
                        LAN =lan_read_file([ cc ],'trc'); 
                     elseif ind==5
                        LAN =lan_read_file([ cc ],'set'); 
                     end 
                    %nameLAN = choise_var(fullfile(PathName,FileName));
                    file = fix_filename(file(1:(end-4)));
                    assignin('base','nameLAN_tempLAN',file);
                    assignin('base', file, LAN);
                    %evalin('base',[ ' load(  ''' PathName FileName ''' , ''' nameLAN ''' )' ]);
                    close(menu)
                    evalin('base',[ 'lantoolbox( ' file ' )' ]);
                    clear
                    fprintf([ '  ok  \n'])
                end 
     
     
        
            
        case 'import fileIO'    
                   
                    LAN = lan_read_file();
                    if isnumeric(LAN)&&LAN ==0, return, end
                    %nameLAN = choise_var(fullfile(PathName,FileName));
                    file = fix_filename(LAN.name);
                    if isempty(file)
                        file = 'LAN';
                    end
                    assignin('base','nameLAN_tempLAN',file);
                    assignin('base', file, LAN);
                    %evalin('base',[ ' load(  ''' PathName FileName ''' , ''' nameLAN ''' )' ]);
                    close(menu)
                    evalin('base',[ 'lantoolbox( ' file ' )' ]);
                    clear
                    fprintf([ '  ok  \n'])
            
    end
    
end
end

%uiwait(menu)

end