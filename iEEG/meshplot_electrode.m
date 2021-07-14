function meshplot_electrode(Elec,Color,cfg)
% <*LAN)<] toolbox  
% v.0.3
%
% meshplot_electrode
% meshplot_electrode(cfg)
% meshplot_electrode(Elec,Color)
% meshplot_electrode(Elec,Color,cfg)
%
% plot a surface of the brain and add electrodes
%
% Elec or cfg.Elec   = Position of the electrodes
%                      in gruops by a cells array
%                      {1 x n_gruops}
%                      in each cell a matrix n x 3
%                      [n_electros x xyz_coords]
% Color or cfg.Color = Color of each eletrode group
%                      in a cell {1 x n_gruops}
%                      e.g. {'red',[0.1 0.5 0.5]}
% cfg.brain_mesh     = a brain mesh in a structure
%                      brain_mesh.vertex
%                      brain_mesh.faces
%                      by defalut serach MNI_mesh.mat
%                      in the path
% cfg.smooth         = to smooth the surface [0 1] 
% cfg.Fcolor         = face color of the barin
%                      default [0.9, 0.9, 0.9]
% cfg.Ecolor         = edge color of the brain
%                      default 'none'
% cfg.background     = brackground color: 'white'
% cfg.Balpha.        = alpha of the brain: 0.08
% cfg.add_electrode  = only add electrode to a 
%                      figure : false 
% cfg.view_angle     = angle of view and light 
%                      :[0 0 1]
% cfg.Ealpha         = alpha of the elctrode: 1
% cfg.Esize          = size of teh electrode: 1
% cfg.Enfaces        = Number of faces of teh elctrode:10
% cfg.scale          = Factor to multiple dimension;
% cfg.nearest_vertice= If localize the electrode at the nearest vertex in the surface 
%                      (helpful in smoothed surfaces) 
%
%
% Pablo Billeke
% pbilleke@udd.cl

% Version 0.3
% 10.04.2014  (PB) add smooth surfaces and nearest vertice location  
% 19.12.2013  (PB) skip empty 
% 13.11.2013

% dependecies
% getcfg.m
% MNI_mesh.mat
% tess_vertconn_bs.m
% tess_smooth_bs.m

if nargin == 0
   Elec.brain_mesh='mni'; 
end

if nargin<=1
   cfg = Elec;
   getcfg(cfg,'Elec', '' );
   getcfg(cfg,'Color','red');
elseif nargin==2
   cfg.brain_mesh='mni'; 
end


getcfg(cfg,'brain_mesh','mni');

if ischar(brain_mesh)
if strcmp(brain_mesh,'mni')
   load MNI_mesh
elseif strcmp(brain_mesh,'bs')
   load mni_mesh_BS
elseif strcmp(brain_mesh,'bs300')
   load MNI_mesh_bs_300 
elseif strcmp(brain_mesh,'bs15')
   load MNI_mesh_bs_15 
elseif strcmp(brain_mesh,'mni_r')
   load MNI_mesh_r 
elseif strcmp(brain_mesh,'bs_r')
   load MNI_mesh_bs_r 
elseif strcmp(brain_mesh,'bs_l')
   load MNI_mesh_bs_l 
end
end


getcfg(cfg,'scale',[1])
getcfg(cfg,'Fcolor',[0.9, 0.9, 0.9])
getcfg(cfg,'Ecolor','none')
getcfg(cfg,'background','white')
getcfg(cfg,'Balpha',0.08)
getcfg(cfg,'add_electrode',false)
getcfg(cfg,'view_angle',[0 0 90])

getcfg(cfg,'Ealpha',1)
getcfg(cfg,'Esize',1)
getcfg(cfg,'Enfaces',10)
ss = getcfg(cfg,'smooth',0);
nearest_vertice = getcfg(cfg,'nearest_vertice',1);

% plot brain mesh

if ss>0
    if nearest_vertice, W = brain_mesh;end
    VertConn = tess_vertconn_bs(brain_mesh.vertices,brain_mesh.faces );
    SurfSmoothIterations = ceil(300 * ss* length(brain_mesh.vertices) / 100000);
    brain_mesh.vertices = tess_smooth_bs(brain_mesh.vertices, ss, SurfSmoothIterations , VertConn, 1); 
end
if  ~add_electrode
whitebg(gcf,background);
brain_mesh.vertices =  brain_mesh.vertices * scale; 

p=patch(brain_mesh);
set(p,'FaceColor',Fcolor,'EdgeColor',Ecolor);
daspect([1 1 1]); 
axis tight


set(gcf,'Color',background,'InvertHardcopy','off');
lighting phong
material shiny
alpha(p,Balpha);
end


% add electrode
if  ~isempty(Elec)
[x, y, z]=sphere(Enfaces);
x=x*Esize*scale;y=y*Esize*scale;z=z*Esize*scale;

if ~iscell(Elec); Elec={Elec};end
if ~iscell(Color); Color={Color};end
n = 0;
for re = 1:length(Elec)
    if isempty(Elec{re}); continue,end; % skip empty positions
    if nearest_vertice
        if ss>0
            paso = near_mesh_ind(W.vertices,Elec{re}*scale );
            Elec{re} = brain_mesh.vertices(paso,:);
        else
            [ borrar  Elec{re}] = near_mesh_ind(brain_mesh.vertices,Elec{re}*scale );
        end
    else
        Elec{re} = Elec{re}*scale;
    end
    % Color index
    if  length(Color)==1; rc=1;else rc=re;end 
    % add each electrodo
	for e = 1:size(Elec{re},1)
        n = n+1;
        po=Elec{re}(e,:);
        fvc = surf2patch((x+po(1)),(y+po(2)),(z+po(3))); 
        d{n} = patch(fvc,'FaceColor',Color{rc},'EdgeColor','none');
        alpha(d{n},Ealpha);
    end
end


end


if  ~add_electrode
view(view_angle); 
light('Position',view_angle,'Style','infinite');
axis off
camlight;
end
 
end


