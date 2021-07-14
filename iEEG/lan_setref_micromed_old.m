function lan_setref_micromed(LAN)
%  <*LAN)<] toolbox 
%  v.0.0.3
%  
%  Pablo Billeke
%  Francisco Zamorano

%  09.10.2012
%  06.09.2012
%  03.09.2012
%  31.08.2012

 global nameLAN
 global h
 global ref
 global h2
 global ifview
 global ifsmp_cr
 %global LAN
nameLAN = inputname(1);
ifview = 2;
ifsmp_cr = false;
%LAN = LAN2;
%clear LAN2

h = figure('CloseRequestFcn',@MM,'Name',[ 'Set References Micromed :   LAN v.' lanversion ],'NumberTitle','off'...
    ,'MenuBar', 'none');
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
   
ll = LAN.chanlocs(1).electrodemat_names;%{'v','c','q','r','t','v''','c''','q''','r''','t'''}
mat = LAN.chanlocs(1).electrodemat;
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
   uicontrol('Parent',hp,'Style','pushbutton','String', num2str(mat(nc,ay))...
       ,'Units','normalized','Position',...,      
       [ nc*(1/(nn+1))-(0.5/(nn+1))  m_min+ay*m_n (0.5/(nn+1))   m_n  ],...
       'UserData',[nc , ay , mat(nc,ay)]...
       ,'Callback', @setLOC ... ...
       )
   
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
         [FileName,PathName,FilterIndex] = uigetfile({'*.lanref','lan ref-file'; '*.mat','MATLAB mat'},'open lan ref - file','LAN.lanref');
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
      'SPM:co_register','Nothing','SPM:co_register'); 
       switch selection, 
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
   selection = questdlg('Do you want save the references?',...
      'Close Request Function',...
      'Yes','No','Yes'); 
   switch selection, 
      case 'Yes',
         LAN.references = ref;
         LAN = ap_ref(LAN);
         assignin('base',nameLAN,LAN)
         save('LAN_temp.lantmp','LAN')
         delete(h)
         delete(h2)
         if ifsmp_cr
            spm_figure('Close','Graphics'); 
         end
      case 'No'
         delete(h) 
         delete(h2) 
         if ifsmp_cr
            spm_figure('Close','Graphics'); 
         end
         
      return 
   end
end

    function LAN = ap_ref(LAN)
        
        if isfield(LAN,'row_data');
            row_data = LAN.row_data{1};
        else
            LAN.row_data = LAN.data;
            row_data = LAN.data{1};
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
        
        LAN.data = {data};
        clear data row_data
    end

function setLOC(FF,e)
    
   D= get(FF,'UserData'); 
   set(CP,'UserData',D);
   set(Ps,'UserData',D);
   set(MNI,'UserData',D);
   pos(1) = LAN.chanlocs(D(3)).X;
   pos(2) = LAN.chanlocs(D(3)).Y;
   pos(3) = LAN.chanlocs(D(3)).Z;
   
   %   probecoords{D(1)}(D(2),:);
   %spm_orthviews('reposition', probecoords{6}(11,:))
   
   if ifview ==2
      selection = questdlg('What do you want to view MRI?',...
      'View options',...
      'SPM:co_register','Nothing','SPM:co_register'); 
       switch selection, 
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

end
