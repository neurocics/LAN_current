function plot_inter_banda(LAN,elec,axis)
%            elec=[1:32];
%            
%
%


for i = 1:length(LAN)

f = figure('Position', [100,100,1000,500]);

%uicontrol('Style', 'text', 'String','hhhhhhh', 'Position', [0.1, 0.9, 0.8,0.1]);
try
annotation(f,'textbox',[0.135 0.744 0.687 0.22],...
    'String',...
    {'ESTUDIO INTERBANDA',...
    ['	banda de referencia alfa = ' num2str(8) '-' num2str(16) 'Hz'],...
    ['	banda ploteadas  = ' num2str(17) '-' num2str(60) ' Hz'],...
    '',...
    'CONDICION:',...
    LAN{i}.cond },...
    'FitBoxToText','off');
end

%uicontrol('Style','text','String','prueba',;
map = squeeze(mean(LAN{i}.freq.inter_ph_a(:,elec,:),2));
%m = mean(map,2);
%for w = 1:size(m,1)
%    mm(w,w) = m(w,1);
%end
%clear m
%m = mm *ones(size(map)) ;
m_m = map;% - m;

subplot('Position' , [0.1,0.2, 0.3,0.5]),%,),
e = pcolor(LAN{i}.freq.time.inter_ph_a,...
    LAN{i}.freq.freq.inter_ph_a+5,...
    m_m...squeeze(mean(LAN{i}.freq.inter_ph_a(:,elec,:),2)) ...
);

caxis(axis);
colorbar([0.4889 0.2064 0.0061 0.4915]);

x = -1*pi:0.0001:pi;
y = sin(x);
subplot('Position' , [0.1,0.1, 0.3,0.05]),%

plot(x,y);xlim([-pi,pi]);


map = squeeze(mean(LAN{i}.freq.inter_a_a(:,elec,:),2));
%m = mean(map,2);
%for w = 1:size(m,1)
%    mm(w,w) = m(w,1);
%end
%clear m
%m =  mm * ones(size(map));
m_m = map;% - m;


subplot('Position' , [0.6,0.2, 0.3,0.5]),%,),
pcolor(LAN{i}.freq.time.inter_a_a,...
    LAN{i}.freq.freq.inter_a_a,...
    m_m ...squeeze(mean(LAN{i}.freq.inter_a_a(:,elec,:),2)) ...
);

caxis(axis);

%
x = -2:0.0001:2;
y = x;
subplot('Position' , [0.6,0.1, 0.3,0.05]),%,),
%x = HO{1}.freq.time.inter_ph_a(1:length(y));
plot(x,y);xlim([-2,2]);

%subplot('Position' , [0.9,0.2, 0.1,0.5]),colorbar(e);
end
%
