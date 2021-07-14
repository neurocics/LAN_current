function synchrot = plot_syncro(synchro, chanlocs,cha,title,power)
% head plot, sincronia entre electrodos
%   synchro = matriz de sincronia
%   chanlocs = loacalizacionde electrodos
%   chan = electrodos para plotear
%
xxx = 1%5;
yyy = 1%12;
if iscell(synchro)
    meansyn = zeros(size(synchro{1}));
    for i = 1:length(synchro)
        meansyn = meansyn  + synchro{i};
    end
    synchrom = meansyn./size(synchro,2);
else
    synchrom = synchro;
end
clear synchro


%----
h = figure('Position',[100,100,800,800]);

for plo = 1:size(synchrom,2);%
synchro = synchrom(:,plo);
if nargin < 5, power = zeros(size(synchro));end
%--- 
subplot(xxx,yyy,plo),
[x,y] = topoplot_eeglab(power,chanlocs);%,'electrodes','labels','style','both');
%---

if nargin < 4, title = 'Sincronia';end
if nargin < 3, cha = length(x);end
%--- ver canales extra en synchro
extrachan = floor((2*size(synchro,1))^(1/2))+1 - cha;
char = cha + extrachan;
cont = 0;

%--- promedio sincronia
synchro = synchro>0.15;
%
%
for m = 2:1:char
    for n =1:m-1
        cont = cont +1;
          if synchro(cont) ~= 0
                try
                hold on, line([y(m) y(n)],[x(m) x(n)], 'color','k','LineWidth',(synchro(cont) * 1)); 
                catch 
                disp(['imposible electrodo '  num2str(m)  ' con ' num2str(n) ]);
                end
          end
    end
end



synchrot(:,plo)=synchro;
end
try
   set(h,'Name', title) 
end

try
    
    uicontrol('Style','text', 'String', title,...
        'Position',[300,600,200,20] );
end

movegui(h,'center');

end