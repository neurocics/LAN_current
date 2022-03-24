function coor = coords_txt2coords_mat(name,pos,mni)

if nargin ==0
 
   % names !!!! 
   realk= [];
   [FileName,PathName,FilterIndex] = uigetfile({'*.txt','electrode names';},'open electrode names file','xx_Name.txt');
   if isequal(FileName,0) || isequal(PathName,0)
                    disp('User selected Cancel')
                    return
   else
                
                    name = fullfile(PathName,FileName);
                    disp(['open ',name])
   end
   
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
    
    
    
else
    if isempty(name)
    name = 'Electrode_Name.txt';
    end

    if isempty(pos)
    pos = 'Electrode_Pos.txt';
    end

    if isempty(mni)
    mni = 'Electrode_Pos_MNI.txt';
    end
    
end



%name = importdata(name);
name = fopen(name);
name = textscan(name, '%s');
name = name{1};
%pos = importdata(pos);
pos = fopen(pos);
pos = textscan(pos, '%f %f %f');
pos = [pos{1} pos{2} pos{3}];
%mni = importdata(mni);
mni = fopen(mni);
mni = textscan(mni, '%f %f %f');
mni = [mni{1} mni{2} mni{3}];


n_n = 1;
n_el = 0;
n_tx = 0;
new_name{1} = '';

for i = 1:length(name)
    % i = 1;
    n_tx = n_tx +1;
    n_el = n_el +1;
    
    %%% names
    ele_name = '';
    for l = 1:length(name{i})
        % l = 1;
        
    % extrad electrode name    
    if isempty(str2num(name{i}(l)))||name{i}(l)=='i'||name{i}(l)=='j'
       ele_name = [ ele_name name{i}(l) ]; 
    end
       % fix p x ' in left electrodes
       if (numel(ele_name)>1)&&(ele_name(end)=='p')
           ele_name(end) = [];
           ele_name = [ele_name  '''' ];
       end 
    end
    
    if isempty(new_name{n_n}) 
       new_name{n_n}=ele_name;
    elseif~strcmp(new_name{n_n},ele_name)
       n_n=n_n+1;
       new_name{n_n}=ele_name;
       n_el = 1;
    end
    
    
    %%% position 
    probecoords{n_n}(n_el,1:3) = pos(n_tx,:);
    probecoords_mni{n_n}(n_el,1:3) = mni(n_tx,:);
try
    probecoords_tal{n_n}(n_el,1:3) = mni2tal(mni(n_tx,:));
end

end

probename = new_name;

if nargout==1
coor.probecoords = probecoords ;
coor.probecoords_mni = probecoords_mni;
try
    coor.probecoords_tal = probecoords_tal;
end
coor.probename = probename ;
else
  
    save xx_coords.mat probecoords probecoords_mni probename probecoords_tal
    
end


end


