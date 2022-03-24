function [clu, tree] = run_cluster(features, cfg)
% NOTA: este script es un PLAGIO
% NO DISTRIBUIR BAJO NINGUNA CIRCUMSTANCIA
%
% ************************cfg************************
% - fname_in : input file name (doesn't have to exist, most like an output)
% - fname : output file
% - mintemp : minimum temperature
% - maxtemp : maximum temperature
% - tempstep
% - SWCycles : number of Montecarlo iterations
% - KNearNeighb : number of nearest neighbors
%

fname=cfg.fname;
fname_in=cfg.fname_in;

% DELETE PREVIOUS FILES
fileexist = exist([fname '.dg_01.lab'],'file');
if(fileexist~=0)
    delete([fname '.dg_01.lab']);
    delete([fname '.dg_01']);
end

n=size(features,1);
dim=size(features,2);
save(fname_in,'features','-ascii');

fid=fopen(sprintf('%s.run',fname),'wt');
fprintf(fid,'NumberOfPoints: %s\n',num2str(n));
fprintf(fid,'DataFile: %s\n',fname_in);
fprintf(fid,'OutFile: %s\n',fname);
fprintf(fid,'Dimensions: %s\n',num2str(dim));
fprintf(fid,'MinTemp: %s\n',num2str(cfg.mintemp));
fprintf(fid,'MaxTemp: %s\n',num2str(cfg.maxtemp));
fprintf(fid,'TempStep: %s\n',num2str(cfg.tempstep));
fprintf(fid,'SWCycles: %s\n',num2str(cfg.SWCycles));
fprintf(fid,'KNearestNeighbours: %s\n',num2str(cfg.KNearNeighb));
fprintf(fid,'MSTree|\n');
fprintf(fid,'DirectedGrowth|\n');
fprintf(fid,'SaveSuscept|\n');
fprintf(fid,'WriteLables|\n');
fprintf(fid,'WriteCorFile~\n');
% if cfg.randomseed ~= 0
%     fprintf(fid,'ForceRandomSeed: %s\n',num2str(cfg.randomseed));
% end    
fclose(fid);

[str,maxsize,endian]=computer;
cfg.system=str;
switch cfg.system
    case {'PCWIN','PCWIN64'}    
        if exist([pwd '\cluster.exe'])==0
            directory = which('cluster.exe');
            copyfile(directory,pwd);
        end
        dos(sprintf('cluster.exe %s.run',fname));
    case {'MAC'}
        if exist([pwd '/cluster_mac.exe'])==0
            directory = which('cluster_mac.exe');
            copyfile(directory,pwd);
        end
        run_mac = sprintf('./cluster_mac.exe %s.run',fname);
	    unix(run_mac);
   case {'MACI','MACI64'}
        if exist([pwd '/cluster_maci.exe'])==0
            directory = which('cluster_maci.exe');
            copyfile(directory,pwd);
        end
        run_maci = sprintf('./cluster_maci.exe %s.run',fname);
	    unix(run_maci);
   otherwise  %(GLNX86, GLNXA64, GLNXI64 correspond to linux)
        if exist([pwd '/cluster_linux.exe'])==0
            directory = which('cluster_linux.exe');
            copyfile(directory,pwd);
        end
        run_linux = sprintf('./cluster_linux.exe %s.run',fname);
	    unix(run_linux);
end

if exist([fname '.dg_01.lab'],'file')
    clu=load([fname '.dg_01.lab']);
    tree=load([fname '.dg_01']);
    delete(sprintf('%s.run',fname));
    delete *.mag
    delete *.edges
    delete *.param
    delete(fname_in);
else
    clu = zeros(1,3);
    tree = zeros(1,4);
end