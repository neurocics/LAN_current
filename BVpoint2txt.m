function BVpoint2txt(puntos,np,fiduciales,filename) 
%    <*LAN)<] 
%    v.0.1
%
% BVpoint2txt write a NAME_XYZ.txt file  
%
% BVpoint2txt(puntos,np,fiduciales,filename)
%

if nargin <4
    filename='NAME_XYZ.txt'
end


    fid = fopen(puntos);
    %fid = fopen('electrodes.tgp');
    str = fread(fid, '*char')';

    fn = strfind(str, str(15));
    nl = strfind(str, str(16));
    
    Elec=[];
    Ename=[];
    for n =6:length(fn)-1
        paso = str(nl(n)+1:fn(n+1));
        k = strfind(paso, '   ') ;
        Elec(n-5,:)= eval([ '[ ' paso(k(1):k(2)) ' ];']);
        Ename{n-5} = ['E' num2str(n-5)];
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

fileID = fopen(filename,'w');
%fileID = fopen('Name_XYZ.txt','w');


for n=1:np % 
fprintf(fileID,'%s\t',Ename{n});    
fprintf(fileID,'%3.3f\t%3.3f\t%3.3f\n',Elec(n,:));
end
for n=1:3
fprintf(fileID,'%s\t',Nfidu{n});    
fprintf(fileID,'%3.3f\t%3.3f\t%3.3f\n',Fidu(n,:));
end

fclose(fileID);

end
    
    