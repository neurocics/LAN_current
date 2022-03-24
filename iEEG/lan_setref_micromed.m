function lan_setref_micromed(LAN)
%  <*LAN)<] toolbox 
%  v.0.0.8
%  
%  Pablo Billeke
%  Francisco Zamorano

%  12.12.2014   compatibility with lantoolbox.m GUI
%  10.01.2014   add "add coord" button (PB)
%  16.11.2013   add delete channles and aunto ref and  buttons, and add warning 
%               when there is no position of the electrode for view
%  09.10.2012
%  06.09.2012
%  03.09.2012
%  31.08.2012

 global iflantoolbox 
 global nameLAN
 global h
 global ref
 global h2
 global ifview
 global ifsmp_cr
 global dc_ac
 global for_delete 
 global niiH
 %global LAN
 if iscell(LAN)
     LAN = LAN{1};
 end
 
 
 
 if ~isfield(LAN.chanlocs, 'electrodemat_names')
 

HEADER.label = {LAN.chanlocs(:).labels};
ifdot=0;
  name_ag =[];
        llevo = length(name_ag);
for i = 1:LAN.nbchan
% i =1
fin =length(HEADER.label{i});
for ns = 1:length(HEADER.label{i})    
    try
        eval(HEADER.label{i}(ns))
        fin = ns;
        continue
    end
end
   name_a =  HEADER.label{i}(1);   
  
        
        
          for c =2:fin
                  if isempty(str2num(HEADER.label{i}(c)));
                      name_a = [name_a HEADER.label{i}(c)];
                     if c==fin % for eeg channels Cz Fz
                          if isempty(name_ag)||~strcmp(name_ag{llevo} , name_a);
                              llevo = llevo +1;
                              name_ag{llevo} = name_a; 
                          end
                          p = 1 ;
                          electrodemat(llevo, p ) = i;
                     end
                  else
                          if isempty(name_ag)||~strcmp(name_ag{llevo} , name_a);
                              llevo = llevo +1;
                              name_ag{llevo} = name_a; 
                          end
                          p=HEADER.label{i}(c:fin);
                          p(p=='+')=[];
                          p = str2num(p); 
                      electrodemat(llevo, p ) = i;
                      break
                   end

           end
           
           
end

 LAN.chanlocs(1).electrodemat = electrodemat;
        LAN.chanlocs(1).electrodemat_names = name_ag;
        
        
        
 
 
 end
 
 
 
 
 
 
 
 
 
 
try
iflantoolbox = evalin('caller', 'iflantoolbox');
catch
iflantoolbox = false;
end

if iflantoolbox
nameLAN = evalin('base','nameLAN_tempLAN') ;   
else
nameLAN = inputname(1);
end
ifview = 2;
ifsmp_cr = false;
%LAN = LAN2;
%clear LAN2
dc_ac=0;
% lenght of the GUI
ne = length(LAN.chanlocs(1).electrodemat);
scrsz = get(0,'ScreenSize');
if ne*55<scrsz(3)
    nx = 55;
else
    nx = (scrsz(3)/ne)-1;
end

h = figure('CloseRequestFcn',@MM,'Name',[ 'Set References Micromed :   LAN v.' lanversion ],'NumberTitle','off'...
    ,'MenuBar', 'none','Position',[(scrsz(3)-(ne*nx))/2   250   ne*nx   450]);


hp = uipanel('Title','references','Position',[0 .1 1 .85]);

   uicontrol(h,'Style','pushbutton','String', 'Save VAR'...
       ,'Units','normalized','Position',...
       [0.8 0.97 0.1 0.03 ] ,'Callback', @SAVE )
   
   uicontrol(h,'Style','pushbutton','String', 'View'...
       ,'Units','normalized','Position',...
       [0.7 0.97 0.1 0.03 ] ,'Callback', @View) 
   
      uicontrol(h,'Style','pushbutton','String', 'Save REF'...
       ,'Units','normalized','Position',...
       [0.9 0.97 0.1 0.03 ] ,'Callback', @SAVE_ref) 
   
   uicontrol(h,'Style','pushbutton','String', 'Load REF'...
       ,'Units','normalized','Position',...
       [0.6 0.97 0.1 0.03 ] ,'Callback', @LOAD_ref)    
  
   DC = uicontrol(h,'Style','pushbutton','String', 'Delete Chan'...
       ,'Units','normalized','Position',...
       [0.01 0.97 0.1 0.03 ] ,'Callback', @Delete_chan) ; 
      uicontrol(h,'Style','pushbutton','String', 'Auto Ref'...
       ,'Units','normalized','Position',...
       [0.101 0.97 0.1 0.03 ] ,'Callback', @auto_ref) ; 
   uicontrol(h,'Style','pushbutton','String', 'Add Coord'...
       ,'Units','normalized','Position',...
       [0.201 0.97 0.1 0.03 ] ,'Callback', @add_coord) 
% h2 = figure('Name',[ 'Location Micromed :   LAN v.' lanversion ],'NumberTitle','off'...
%     ,'MenuBar', 'none','Visible','off','CloseRequestFcn',@MM2);
CE = uicontrol(h,'Style','text','String', 'electrode'...
       ,'Units','normalized','Position',...
       [0 0 0.2 .09 ]);
   
CC = uicontrol(h,'Style','text','String', 'coordinates'...
       ,'Units','normalized','Position',...
       [0.2 0 0.2 .09 ]); 
CP = uicontrol(h,'Style','edit','String', 'place'...
       ,'Units','normalized','Callback', @f_CP ,...
       'Position',...
       [0.4 0 0.2 .09 ]);   
Ps = uicontrol(h,'Style','popup','String', 'places'...
       ,'Units','normalized','Position',...
       [0.6 0.045 0.2 .045 ],'Callback', @f_Ps );  
uicontrol(h,'Style','text','String', 'current location'...
       ,'Units','normalized','Position',...
       [0.6 0.0 0.2 .04 ]);     
   
MNI = uicontrol(h,'Style','popup','String', 'places'...
       ,'Units','normalized','Position',...
       [0.8 0.045 0.2 .045 ],'Callback', @f_Ps );     
uicontrol(h,'Style','text','String', 'MNI location'...
       ,'Units','normalized','Position',...
       [0.8 0.0 0.2 .04 ]); 

mat = LAN.chanlocs(1).electrodemat;
if isfield(LAN.chanlocs(1), 'electrodemat_names')
    ll = LAN.chanlocs(1).electrodemat_names;%{'v','c','q','r','t','v''','c''','q''','r''','t'''}
else
    for i = 1:size(mat,1)
        ll{i} = num2str([ 'l' i]);
    end
end

%mat(1,2:4) = 1:3;
%mat(2,10:16) = 4:10;
%mat(3,17) = 12;

try
    ref = LAN.references;
catch
    ref = zeros(size(mat));
end

nn = length(ll);
nny = size(mat,1);
m_min = 0.01;
m_max = 0.95;
m_n = (m_max-m_min)/(size(mat,2)+2);

for nc = 1:nn   

uicontrol('Parent',hp,'Style','text','String', ll{nc}...
       ,'Units','normalized','Position',...
       [ nc*(1/(nn+1))-(0.25/(nn+1))   m_max  (0.5/(nn+1)) 1-m_max ] )

if nc ==1
   for ay = 1:size(mat,2) 
   % cha 
   uicontrol('Parent',hp,'Style','text','String', num2str(ay)...
       ,'Units','normalized','Position',...
       [ 0  m_min+ay*m_n (0.5/(nn+1))   m_n  ] )
  
   end
end
   
   for ay =  find( mat(nc,:)>0 ) 
   
   % cha 
   GUI_CHA{mat(nc,ay)} = uicontrol('Parent',hp,'Style','pushbutton','String', num2str(mat(nc,ay))...
       ,'Units','normalized','Position',...,      
       [ nc*(1/(nn+1))-(0.5/(nn+1))  m_min+ay*m_n (0.5/(nn+1))   m_n  ],...
       'UserData',[nc , ay , mat(nc,ay)]...
       ,'Callback', @setLOC ... ...
       );
   
   % ref
   uicontrol('Parent',hp,'Style','edit','String', num2str(ref(nc,ay))...
       ,'Units','normalized','Position',...
       [ nc*(1/(nn+1))  m_min+ay*m_n (0.5/(nn+1))   m_n  ] ...
       ,'UserData',[nc , ay , mat(nc,ay)]...
       ,'Callback', @setREF...
       )
end

annotation(h,'arrow',[nc*(1/(nn+1)) nc*(1/(nn+1)) ],[ m_max m_min+0.09])
end



function setREF(FF,e)
    
D= get(FF,'UserData');    
ref(D(1),D(2)) = eval(get(FF,'String'));
    
end

function SAVE(src,evnt)
% User-defined close request function 
         LAN.references = ref;
         LAN = ap_ref(LAN);
         assignin('base',nameLAN,LAN);
         references = ref;
         chanlocs = LAN.chanlocs;
         %assignin('base',nameLAN,LAN);
         save([ nameLAN '.ref.lantmp'],'references','chanlocs','-mat')
         %save('LAN_temp.lantmp','LAN')

end

function SAVE_ref(src,evnt)
% User-defined close request function 
         [FileName,PathName,FilterIndex] = uiputfile({'*.lanref','lan ref-file';},'open lan ref - file','LAN.lanref');
                if isequal(FileName,0) || isequal(PathName,0)
                    disp('User selected Cancel')
                else                    
                    disp(['save ',fullfile(PathName,FileName)])
                    fprintf('Please wait ...')
                    references = ref;
                    chanlocs = LAN.chanlocs;
                    save([ PathName FileName ],'references','chanlocs','-mat')
                    fprintf([ '  ok  \n'])
                end  
end
function LOAD_ref(src,evnt)
% User-defined close request function 
         [FileName,PathName,FilterIndex] = uigetfile({'*.lanref','lan ref-file'; '*.mat','MATLAB mat'; '*.lantmp','lan temporal-file';},'open lan ref - file','LAN.lanref');
                if isequal(FileName,0) || isequal(PathName,0)
                    disp('User selected Cancel')
                else                    
                    disp(['load ',fullfile(PathName,FileName)])
                    fprintf('Please wait ...')
                    
                    load(fullfile(PathName,FileName),'references','chanlocs','-mat')
                    ref = references;
                    LAN.references = ref;
                    LAN.chanlocs = chanlocs;
                    LAN = ap_ref(LAN);
                    assignin('base',nameLAN,LAN);
                    delete(h)                   
                    evalin('base', [ ' lan_setref_micromed( ' nameLAN ')' ])
                    fprintf([ '  ok  \n'])%clear all
                end  
end

function View(src,evnt)

      selection = questdlg('What do you want to view MRI?',...
      'View options',...
      'SPM:co_register','Nifti_View','Nothing','Nifti_View'); 
       switch selection, 
          case 'Nifti_View',
              ifview = 3;
              ifsmp_cr =0;
              [file, path] = uigetfile('*.*', 'Open nii file');
                if isequal(file,0) || isequal(path,0)
                                disp('User selected Cancel')
                                ifview = 0;
                                return
                end
                nii = fullfile(path,file);
                view_nii(nii)
          case 'SPM:co_register',
             ifview = 1;
             ifsmp_cr =1;
             spm_check_registration
          case 'Nothing'
             ifview = 0;
             
          return 
       end      

end


function MM(src,evnt)
% User-defined close request function 
% to display a question dialog box 
   %selection = questdlg('Do you want save the references?',...
   %   'Close Request Function',...
   %   'Yes','No','Yes'); 
   selection = 'No'
   switch selection, 
      case 'Yes',
         LAN.references = ref;
         LAN = ap_ref(LAN);
         assignin('base',nameLAN,LAN)
         %save('LAN_temp.lantmp','LAN')
         try
            delete(h) 
            delete(h2)
         catch
             delete(gcf)
         end
         if ifsmp_cr
            spm_figure('Close','Graphics'); 
         end
          if iflantoolbox
            disp('Back to LANtoolbox ... remeber to save your work!!')
            close all
            %assignin('base','menuposition_tempLAN' , get(menu,'Position'));
            assignin('base',nameLAN ,LAN);
            close all
            %clear LAN
            evalin('base',['lantoolbox(' nameLAN  ');']);
            clear  
            %assignin('caller','xLAN',LAN)
          end
      case 'No'
         try
            delete(h) 
            delete(h2)
         catch
             delete(gcf)
         end
         if ifsmp_cr
            spm_figure('Close','Graphics'); 
         end
         if iflantoolbox
            disp('Back to LANtoolbox ... remeber to save your work!!')
            close all
            %assignin('base','menuposition_tempLAN' , get(menu,'Position'));
            assignin('base',nameLAN ,LAN);
            close all
            %clear LAN
            evalin('base',['lantoolbox(' nameLAN  ');']);
            clear  
            %assignin('caller','xLAN',LAN)
        else
            %disp('....')
            %disp('Thank you for using LAN toolbox')
         end
      %return 
   end
end

    function LAN = ap_ref(LAN)
        
        for t=1:LAN.trials;
        if isfield(LAN,'row_data');
            row_data = LAN.row_data{t};
        else
            LAN.row_data = LAN.data;
            row_data = LAN.data{t};
        end
        
        data = row_data;
        
        
        for e = 1:LAN.nbchan;
            ind = LAN.references(LAN.chanlocs(1).electrodemat==e);
            if ind >0
            data(e,:) = row_data(e,:) - row_data(ind,:);
            elseif ind <0
            data(e,:) = 0;
            end
        end
        
        LAN.data{t} = data;
        end
        clear data row_data
    end

function setLOC(FF,e)
   D= get(FF,'UserData');
   
        if dc_ac
        b= get(FF,'Background');
        if sum(b==[1 0 0])==3;
            set(FF,'Background',[0.9294    0.9294    0.9294 ])
            for_delete(for_delete==D(3))=[];
            
            %dc_ac=false;
        else
           set(FF,'Background',[1 0 0 ]) 
           for_delete = [for_delete D(3)];
            %dc_ac=true;
        end
        return
        end
    
   set(CP,'UserData',D);
   set(Ps,'UserData',D);
   set(MNI,'UserData',D);
   try
        pos(1) = LAN.chanlocs(D(3)).X;
        pos(2) = LAN.chanlocs(D(3)).Y;
        pos(3) = LAN.chanlocs(D(3)).Z;
   catch
       warning(['Not posotion defined for ' LAN.chanlocs(D(3)).labels ' channel' ])
       return
   end
   %   probecoords{D(1)}(D(2),:);
   %spm_orthviews('reposition', probecoords{6}(11,:))
   
   if ifview ==2
      selection = questdlg('What do you want to view MRI?',...
      'View options',...
       'SPM:co_register','Nifti_View','Nothing','Nifti_View'); 
       switch selection, 
          case 'Nifti_View',
             ifview = 3;
             ifsmp_cr =0;    
                [file, path] = uigetfile('*.*', 'Open nii file');
                if isequal(file,0) || isequal(path,0)
                                disp('User selected Cancel')
                                ifview = 0;
                                return
                end
                nii = fullfile(path,file);
                nii = load_untouch_nii(nii);
                niiH = figure('unit','normal','pos', [0.18 0.08 0.64 0.85]);
                niio.setarea = [0.05 0.05 0.9 0.9];
                niio.setunit='mm'
                niio.command='init';
                view_nii(niiH,nii,niio)
          case 'SPM:co_register',
             ifview = 1;
             ifsmp_cr =1;
             try
                spm_check_registration
             catch
                 warning(' SPM must be in your path !!! ');
                 ifview = 2;
                 ifsmp_cr =0;
             end
          case 'Nothing'
             ifview = 0;
          return 
       end      
   end
   
   if (ifview==1)&&(ifsmp_cr)  
   int = [' spm_orthviews(''reposition'', [' num2str(pos)  '] ) '];
   try evalin('base',int); end
   end 
   if (ifview==3)
       niio = [];
       niio.command='update';
       niio.setunit='mm'
       niio.setviewpoint=pos;
       view_nii(niiH,niio);
   end
%    if strcmp(get(h2,'Visible'),'off')
%    set(h2,'Visible','on');
%    end

   if ~isfield(LAN.chanlocs(1), 'locations')
      for cc = 1:LAN.nbchan 
          LAN.chanlocs(1).locations{cc} = '?'; 
      end 
   else
      for cc = 1:LAN.nbchan 
          if isempty(LAN.chanlocs(1).locations{cc}) 
          LAN.chanlocs(1).locations{cc} = '?'; 
          end
      end 
   end
   %a = [ num2str(D(3)) LAN.chanlocs(1).electrodemat_names{D(1)} ':' num2str(D(2))    ]
   set(CE,'String',[ num2str(D(3)) ' ' LAN.chanlocs(1).electrodemat_names{D(1)} ':' num2str(D(2))    ])
   set(CC,'String', num2str(pos)   );
   set(CP,'String', LAN.chanlocs(1).locations{D(3)});
   set(Ps,'String',unique(LAN.chanlocs(1).locations));
   
   %try
      mni_co(1) =   LAN.chanlocs(D(3)).X_mni;
      mni_co(2) =   LAN.chanlocs(D(3)).Y_mni;
      mni_co(3) =   LAN.chanlocs(D(3)).Z_mni;
      if any(mni_co)
          try
      load('TDdatabase','DB')
      [onelinestructure, cellarraystructure] = cuixuFindStructure(mni_co, DB);
      clear DB  onelinestructure
      set(MNI,'String',cellarraystructure);
      set(MNI,'Value',length(cellarraystructure));
          catch
              disp([ ' not datbase (e.g. TDdatabase) in your path' ])
              disp([ ' see http://www.alivelearn.net/xjview8/blog/download/' ])       
          end
      end
   %end
   
end

function f_CP(FF,e)
  str = get(FF,'String');
  loc = get(FF,'UserData');
  LAN.chanlocs(1).locations{loc(3)} = str;
  setLOC(FF,e)
end

function f_Ps(FF,e)
  str = get(FF,'String');
  loc = get(FF,'UserData');
  v= get(FF,'Value');
  LAN.chanlocs(1).locations{loc(3)} = str{v};
  setLOC(FF,e)
end

    function Delete_chan(src,evnt)
        b= get(src,'Background');
        if sum(b==[1 0 0])==3;
            if isempty(for_delete)
            set(src,'Background',[0.9294    0.9294    0.9294 ])
            dc_ac=false;
            else
              naC = ''  ;
              for nG = for_delete
                  naC = [naC LAN.chanlocs(nG).labels ' '] ;
              end
                  selection = questdlg({'Do you want to delete the following channels?', ...
                  naC },...
                 'Delete channels',...
                 'Yes','No','Yes and save ind','Yes'); 
               switch selection, 
                  case 'Yes'
                     delete(h)
                     delete(h2)
                     LAN.references = ref;
                     LAN = ap_ref(LAN);
                     LAN = electrode_lan(LAN,for_delete);
                     assignin('base',nameLAN,LAN)
                     if ifsmp_cr
                        spm_figure('Close','Graphics'); 
                     end
                     evalin('base',[ 'lan_setref_micromed(' nameLAN   ')' ])
                     return
                  case 'Yes and save ind'
                     delete(h)
                     delete(h2)
                     LAN.references = ref;
                     LAN = ap_ref(LAN);
                     LAN = electrode_lan(LAN,for_delete);
                     assignin('base',nameLAN,LAN)
                     if ifsmp_cr
                        spm_figure('Close','Graphics'); 
                     end
                     evalin('base',[ 'deleted_electrode_tempLAN = [' num2str(for_delete)  ']' ])
                     evalin('base',[ 'lan_setref_micromed(' nameLAN   ')' ])
                     return   
                  case 'No'
                      for nG = for_delete
                         set(GUI_CHA{nG},'Background',[0.9294    0.9294    0.9294 ] );       
                      end
                      set(src,'Background',[0.9294    0.9294    0.9294 ])
                      dc_ac=false; 
                      for_delete = []; 
               end    
            end
        else
            set(src,'Background',[1 0 0 ]) 
            dc_ac=true;
            for_delete=[];
        end
    end

    function auto_ref(src,evnt)
       if dc_ac 
          warning('Desactive the delection of channel before to apply auto reference');
          return
       end
      selection = questdlg('Select the tolerece of local reference?',...
                 'Delete channels',...
                 'adjacent','1','2','adjacent'); 
      switch selection
          case 'adjacent'
              tol = 0;
          case '1'
              tol=1;
          case '2'
              tol=2;
      end
      
      LAN = lan_autoref(LAN,tol);
                     delete(h)
                     delete(h2)
                     LAN = ap_ref(LAN);
                     assignin('base',nameLAN,LAN)
                     if ifsmp_cr
                        spm_figure('Close','Graphics'); 
                     end
                     evalin('base',[ 'lan_setref_micromed(' nameLAN   ')' ])
                     return  
    end

    function add_coord(src,evnt)
        LAN = lan_add_coord(LAN);
    end

end
