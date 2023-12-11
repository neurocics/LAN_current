function BVpoint2txt(puntos,np,fiduciales,filename,elec_name,del_elec) 
%    <*LAN)<] 
%    v.0.2
%
% BVpoint2txt write to  NAME_XYZ.txt  
%                       _coorsystem.json
%                       _electrodes.json    files 
% BVpoint2txt(cfg)
% BVpoint2txt(puntos,np,fiduciales,filename,elec_name)
%
% cfg.
%     elec_file  = 'file.tgp'
%     fidu_file  = 'file.fdp'
%     n_elec    =   n
%     filename  =  'NAME_XYZ.txt'
%     elec_name  = {'Cz'm, ...} default = [];
%
% P Billeke 
% 07.12.2023 add .json following BIDS eeg format 
% 02.06.2022

if nargin == 1 && isstruct(puntos)
    cfg=puntos;

    coor_json           = getcfg(cfg,'coor_json',true);
    coor_json_sys       = getcfg(cfg,'coor_json_sys','T1w');
    coor_json_uni       = getcfg(cfg,'coor_json_uni','mm');

    elec_json           = getcfg(cfg,'elec_json',true);
    %coor_json_sys       = getcfg(cfg,'coor_json_sys','T1w');
    %coor_json_uni       = getcfg(cfg,'coor_json_uni','mm');


    puntos          = getcfg(cfg,'elec_file');
    fiduciales      = getcfg(cfg,'fidu_file');
    np              = getcfg(cfg,'n_ele',[]);
    filename        = getcfg(cfg,'filename','NAME_XYZ.txt');
    elec_name       = getcfg(cfg,'elec_name',[]);
    elec_imp        = getcfg(cfg,'elec_imp',[]);
    del_elec        = getcfg(cfg,'del_elec',[]);
elseif nargin <6
    filename='NAME_XYZ';
    del_elec=[];
elseif nargin <4
    filename='NAME_XYZ';
end


    fid = fopen(puntos);
    %fid = fopen('electrodes.tgp');
    str = fread(fid, '*char')';

    fn = strfind(str, str(15));
    nl = strfind(str, str(16));
    
    Elec=[];
    
    if isempty(elec_name)
        Ename=[];
    else
        Ename = elec_name;
    end
    
    for n =6:length(fn)-1
        paso = str(nl(n)+1:fn(n+1));
        k = strfind(paso, '   ') ;
        Elec(n-5,:)= eval([ '[ ' paso(k(1):k(2)) ' ];']);
        if isempty(elec_name)
        Ename{n-5} = ['E' num2str(n-5)];
        end
    end
    
    if isempty(np)
        np = length(fn)-6;
    end
    
    
    if ~isempty(del_elec)
       Elec(del_elec,:) = [];
       Ename(del_elec) = [];
    end
    
    fid = fopen(fiduciales);
    %fid = fopen('T1w_acpc_Head.fdp');
    str = fread(fid, '*char')';
    fn = strfind(str, str(21));
    nl = strfind(str, str(22));
    
    
    Fidu=[];
    for n =3:length(fn)-1
        paso = str(nl(n)+1:fn(n+1));
        k = strfind(paso, ' ') ;
        Fidu(n-2,:)= eval([ '[ ' paso(k(end-2):end) ' ];']); 
    end    
    
    
    Elec = Elec(:,[1 3 2]);
    Fidu = Fidu(:,[1 3 2]);% nas NAS / L / R
    Nfidu = {'NAS','LPA','RPA'};
    
x = 0:.1:1;
A = [x; exp(x)];

%_coordsystem.json
if coor_json
  fileID_json = fopen([filename '_coordsystem.json'],'w');  
  fprintf(fileID_json,'%s', ...
       ['{' newline '"EEGCoordinateSystem": "' coor_json_sys '",' newline '"EEGCoordinateUnits": "' coor_json_uni '",' newline  ....
        '"EEGCoordinateSystemDescription": "Native space from acpc realigned T1w",' newline ...
        '"AnatomicalLandmarkCoordinates": { ' newline ....
        '"NAS": [' newline  ...
            num2str(Fidu(1,[1])) ',' newline  ...
            num2str(Fidu(2,[1])) ',' newline  ...
            num2str(Fidu(3,[1])) ',' newline  ...
        '],' newline  ...
        '"LPA": [' newline  ...
            num2str(Fidu(1,[2])) ',' newline  ...
            num2str(Fidu(2,[2])) ',' newline  ...
            num2str(Fidu(3,[2])) ',' newline  ...
        '],' newline  ...
        '"RPA": [' newline  ...
            num2str(Fidu(1,[3])) ',' newline  ...
            num2str(Fidu(2,[3])) ',' newline  ...
            num2str(Fidu(3,[3])) ',' newline  ...
        ']' newline  ...
    '},' newline  ...
    '"AnatomicalLandmarkCoordinateSystem": "' coor_json_sys ',' newline  ...
    '"AnatomicalLandmarkCoordinateUnits": "' coor_json_uni '"' newline  ...
'}'])
end

% name_xyz.txt
fileID = fopen([filename '.txt'],'w');
for n=1:length(Ename) % 
fprintf(fileID,'%s \t',Ename{n});    
fprintf(fileID,'%3.3f \t %3.3f \t %3.3f \n',Elec(n,:));
end
for n=1:3
fprintf(fileID,'%s \t',Nfidu{n});    
fprintf(fileID,'%3.3f \t %3.3f \t %3.3f \n',Fidu(n,:));
end
fclose(fileID);

% _electrodes.json
if elec_json
fileID_elecjson = fopen([filename '_electrodes.json'],'w');
fprintf(fileID_elecjson,'%s \n',['name' sprintf('\t') ...
                                'x' sprintf('\t') ....
                                'y' sprintf('\t') ...
                                'z' sprintf('\t') ...
                                'impedance' ]); 
for n=1:length(Ename) 
fprintf(fileID_elecjson,'%s \t',Ename{n});
fprintf(fileID_elecjson,'%3.3f \t %3.3f \t %3.3f \t',Elec(n,:));
if isempty(elec_imp)
fprintf(fileID_elecjson,'%s \n','<10');
elseif numel(elec_imp) < n
fprintf(fileID_elecjson,'%s \n','<10');    
else
    if isempty(elec_imp(n))
    fprintf(fileID_elecjson,'%s \n','>100');    
    else
    fprintf(fileID_elecjson,'%3f \n',elec_imp(n)); 
    end
end
end
fclose(fileID_elecjson);
end

end
    
    