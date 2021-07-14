function LAN =  lan_add_coord(LAN,real,mni,tal)
% <*LAN)<] toolbox
% v.0.0.3
% Read coordinates for iEEG electrodes

% 02.04.2014 Add option to read from 3 text files (Name, Pos and MNI).
% 14.12.2012
% 03.09.2012

if nargin<4
    tal = [];
end
if nargin >3
    mni=[];
end
if nargin == 1
    realk= [];
   [FileName,PathName,FilterIndex] = uigetfile({'*.mat','coord-file';...
                                                '*.txt','name-file';...
                                                ...'*.xls','coord-table';...
               },'open coord-file or name_file','xx_coords.mat');
   if isequal(FileName,0) || isequal(PathName,0)
                    disp('User selected Cancel')
   elseif FilterIndex==1                    
                    disp(['open ',fullfile(PathName,FileName)])
                    fprintf('Please wait ...')
                    load(fullfile(PathName,FileName))
                    try real= probecoords; end
                    try mni= probecoords_mni; end 
                    try tal= probecoords_tal; 
                    catch
                        try
                            for ni = 1:length(mni)
                            tal{ni} = mni2tal(mni{ni});   
                            end
                        end
                    end 
                    %nameLAN = choise_var(fullfile(PathName,FileName));
                    %assignin('base','nameLAN_tempLAN',nameLAN);
                    %evalin('base',[ ' load(  ''' PathName FileName ''' , ''' nameLAN ''' )' ]);
                    %close(menu)
                    %evalin('base',[ 'lantoolbox( ' nameLAN ' )' ]);
                    %clear
                    fprintf([ '  ok  \n'])
   elseif FilterIndex==3 
       filename = fullfile(PathName,FileName);
       [num,txt,raw] = xlsread(filename);
   else
       name = fullfile(PathName,FileName);
       disp(['open ',name])
       
       % pos !!!!
       realk= [];
       [FileName,PathName,FilterIndex] = uigetfile({'*.txt; *.pts','electrode Position ';},'open electrode poition (patient space) file','xx_Pos.txt');
       if isequal(FileName,0) || isequal(PathName,0)
                        disp('User selected Cancel')
                        return
       else

                        pos = fullfile(PathName,FileName);
                        disp(['open ',name])
       end 
       
       % NMI !!!!
       realk= [];
       [FileName,PathName,FilterIndex] = uigetfile({'*.txt; *.pts','electrode Position MNI';},'open electrode poition (MNI space) file','xx_MNI.txt');
       if isequal(FileName,0) || isequal(PathName,0)
                        disp('User selected Cancel')
                        return
       else

                        mni = fullfile(PathName,FileName);
                        disp(['open ',name])
       end
       
       coor = coords_txt2coords_mat(name,pos,mni);
       probename = coor.probename;
       try real= coor.probecoords; end
       try mni= coor.probecoords_mni; end 
       try tal= coor.probecoords_tal; end 
   end           
    
end
    



if isfield(LAN,'chanlocs')
   %electrodemat = ;
   %[ag ne] = find(LAN.chanlocs(1).electrodemat);


for e = 1: LAN.nbchan

   if ~isfield(LAN.chanlocs(1),'electrodemat')
     
       
   end
    
    
    
    
    
   [p ne] = find(LAN.chanlocs(1).electrodemat==e);
   
   if ~isempty(p)
   ag = find(ifcellis(probename, lower(LAN.chanlocs(1).electrodemat_names{p})));
   
   if ~isempty(real) && ~isempty(ag) && (ag <= length(real))
      try
      LAN.chanlocs(e).X = real{ag}(ne,1);
      LAN.chanlocs(e).Y = real{ag}(ne,2);
      LAN.chanlocs(e).Z = real{ag}(ne,3); 
      catch
      LAN.chanlocs(e).X = [];
      LAN.chanlocs(e).Y = [];
      LAN.chanlocs(e).Z = []; 
      warning([ ' No location for ' LAN.chanlocs(e).labels  ' electrode'])
      end
   if ~isempty(mni)
       try
      LAN.chanlocs(e).X_mni = mni{ag}(ne,1);
      LAN.chanlocs(e).Y_mni = mni{ag}(ne,2);
      LAN.chanlocs(e).Z_mni = mni{ag}(ne,3); 
       catch
      LAN.chanlocs(e).X_mni =[];
      LAN.chanlocs(e).Y_mni = [];
      LAN.chanlocs(e).Z_mni = [];     
       end
   end
   if ~isempty(tal)
       try
      LAN.chanlocs(e).X_tal = tal{ag}(ne,1);
      LAN.chanlocs(e).Y_tal = tal{ag}(ne,2);
      LAN.chanlocs(e).Z_tal = tal{ag}(ne,3);  
       catch
      LAN.chanlocs(e).X_tal = [];
      LAN.chanlocs(e).Y_tal = [];
      LAN.chanlocs(e).Z_tal = [];             
       end
   end
   else
      LAN.chanlocs(e).X = [];
      LAN.chanlocs(e).Y = [];
      LAN.chanlocs(e).Z = []; 
      warning([ ' No location for ' LAN.chanlocs(e).labels  ' electrode'])
   end
   else
      LAN.chanlocs(e).X = [];
      LAN.chanlocs(e).Y = [];
      LAN.chanlocs(e).Z = []; 
      warning([ ' No location for ' LAN.chanlocs(e).labels  ' electrode'])
   end
   end
end
end

%LAN.probecoords = probecoords;
%LAN.probecoords_mni = probecoords_mni;