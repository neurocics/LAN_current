function lan_erp_plot(time,data,chanlocs,trial,chan,accept)
%    <*LAN)<]    
%    v.0.0.2
%
%   lan_erp_plot realiza un grafico del ensayo del erp de la condicion, con
%   la posibilidad de graficar el scalp.

%   22.06.2012
%   17.08.2011
%   Pablo Billeke

%global handle01
%global handle02

if nargin<6
    accept = true(1,length(data));
else
    if any(accept>1)
        paso =  false(1,length(data));
        paso(accept);
        accept = paso; clear paso
    elseif length(data)==sum(accept)
       accept = true(1,length(data));
    elseif length(data) ~= length(accept)
        warning('not bad trials???')
        accept = true(1,length(data));
    end
    accept = logical(accept);
end



if size(time,2)==3 || size(time,2)==2 
    time = linspace(time(1,1),time(1,2),length(data{trial}));
end

if ischar(chan)
chan = label2idx_elec(chanlocs,chan);
end

datapm= mean(cat(3, data{accept}),3);
datam=mean(datapm(chan,:),1);

datap= mean(cat(3,data{trial}),3);
datat=mean(datap(chan,:),1);


ERPPLOT = figure;
uicontrol('parent',ERPPLOT,'Units','normalized','Style','pushbutton',...
           'String', 'Scalp' ,...opciones{pp,1},...
           'Position',[0.75,0,0.25,0.1],'Callback',{@scalp_p}) ;
       
erpax = axes('Parent',ERPPLOT,...
    'Position',[0.05 0.1 0.6 0.85],...'CLim',[1 6],...
    'XLim',[time(1)  time(end)]...
    ...'YLim',[1 LAN{ncd}.nbchan ],...
    ...'YTickLabel', ytl,'YTick',yt...
    );

plot(time,datam,'parent',erpax,'color',[0.5 0.5 0.5]);hold on
plot(time,datat,'parent',erpax,'color','red');
set(erpax,'XLim',[time(1)  time(end)])


    function scalp_p(w,ww,www)
        clear w*
    %if scalp ~=0
     [X Y putt]=ginput(1);
    %scalp = 0;
    X = find(time>X,1,'first');

    subplot('Position',[0.65,0.1,0.2,0.4])
    %[x,y,handle01,Zi,grid,Xi,Yi] = 
    topoplot_lan(datap(:,X),chanlocs,'numcontour', 0);
    title('trial')
    
    subplot('Position',[0.65,0.5,0.2,0.4])
    %[x,y,handle02,Zi,grid,Xi,Yi] = 
    topoplot_lan(datapm(:,X),chanlocs,'numcontour', 0);
    title('ERP')
    end



end