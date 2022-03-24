function lan_erpplot(LAN,roi,comp)
%    v.0.0.1
%    <*LAN)<]
%    from erp_glan  (PB, FZ, RH)
%    
%     
% lan_erpplot
% plotea erp por electrodo o grupos de electrodos (roi)
% roi = electrodos
% comp = indice de comparacion a graficar
%
% 03.04.2012

% Pablo Billeke
% Rodrigo Henriquez
% Francisco Zamorano




if nargin == 0
    if strcmp(lanversion('t'),'devel')
    edit lan_erpplot.m
    end
    help lan_erpplot
    return
end


if nargin<3
     comp=1;
end

if nargin<2
     roi=7;
end

dif = 0;
c_axis=[-10 10];
color =[{'blue'},{'red'},{'yellow'},{'green'},{'cyan'},...
       {'magenta'},{'yellow'},{'black'}];...

   
% for compatibilty only  FIX ME
       ifh=0; 
       bll=0;




GLAN = LAN{1};
%
for nn = comp
data{nn} = mean(cat(3,LAN{nn}.data{:}),3);
end

% if size(data,1)<10 % why? FIX ME
figure('Visible','on','Position',[360,300,700,500],'Color',[0 0 0 ],'MenuBar', 'none','DockControls','off');
hold on,

time(1) = 0;
time(2) = size(data{comp},2) /LAN{1}.srate;
time = time + LAN{1}.time(1);

ltime = linspace(time(1),time(2),size(data{comp},2));
cont = 0;
%     if ifh
%     plot(ltime(find(hh{comp}(roi,:)==1)),ones(1,length(find(hh{comp}(roi,:)==1))),...
%                     '--rs','LineStyle','none',...
%                     'MarkerFaceColor',[1 0.8 0.8],...'g',...
%                     'MarkerSize',3);
%                 d =diff(hh{comp}(roi,:));
%                 for pp = find(d==1)
%                 text(ltime(pp),-2,['pval=' num2str(pvalc{comp}(roi,pp+1)) ]);
%                 end
%     end
if bll==1
line([bl(1) bl(2)],[-0 -0],'LineWidth',10,'Color',[.5 .5 .5]);
end


for c = comp
cont = cont + 1;

plot(ltime,data{c}(roi,:),'Color',color{cont},...
    'Interruptible','off');hold on;

if bll ==1
    text( (bl(1,1) ), (-1* cont ),[ LAN{c}.cond ],'Color',color{cont} );  
    xlim([bl(1,1)  time(1,2)]);  
else
    xlim([ltime(1)  ltime(length(ltime))]);  
end
end



% else %%%% for group 
% 
% if isfield(LAN.erp, 'time')
% ltime = LAN.erp.time;
% else
% time(1) = 0;
% time(2) = size(GLAN.erp.data{comp},2) /GLAN.srate;
% time = time + GLAN.time(1);
% ltime = linspace(time(1),time(2),size(GLAN.erp.data{comp},2));
% end
% cont = 0;
% 
% %stat = plot(ltime,GLAN.erp.hh{1}(roi,:),'Color',...
% %    'Interruptible','off'),hold on;
% for cc = 1:length(GLAN.erp.data)
% figure, hold on,
% %plot(erp_mean{1}(65,:))
% %plot(erp_mean{2}(65,:),'color','red')
%         if ifh
%         plot(ltime(find(hh{cc}(roi,:)==1)),ones(1,length(find(hh{cc}(roi,:)==1))),...
%                         '--rs','LineStyle','none',...
%                         'MarkerFaceColor',[1 0.8 0.8],...'g',...
%                         'MarkerSize',3);
%                     d =diff(hh{cc}(roi,:));
%                     for pp = find(d==1)
%                     text(ltime(pp),-2,['pval=' num2str(pvalc{cc}(roi,pp+1)) ]);
%                     end
%         end
% line([bl(1) bl(2)],[-0 -0],'LineWidth',10,'Color',[.5 .5 .5]);
% 
% 
% cont = 0;
% for g = 1:size(GLAN.erp.data,1)
% cont = cont + 1;    
% bll=0;
% plot(ltime,GLAN.erp.data{g,cc}(roi,:),'Color',color{cont},...
%     'Interruptible','off');hold on;
%     if bll ==1
%     xlim([bl(1,1)  time(1,2)]); 
%     else
%     xlim([ltime(1)  ltime(length(ltime))]);  
%     end
% end
% end   
%     
%     
%      
%     
%     
%     
% end
%%%%%%%%%%%%%%%%%%
%%%
%%%  WITH TOPOPLOT 
%%%
%%%%%%%%%%%%%%%%%%
n=-1;
scalp = -1; 
texto = plus_text('Please select a point for topographic plot');
disp_lan(texto);
if isfield(LAN{1}, 'chanlocs')
   
while n <1
    
    
    if scalp ~=0
     [X Y butt]=ginput(1);
    scalp = 0;
    end
    clc,
    texto = plus_text('Close de figure with CLOSE button');
    texto = plus_text(texto,'Use SCALP button to change the time of the topographic plot');
    texto = plus_text(texto,'Use DIF button to plot the scalp of the diferences and cluster   '); 
     texto = plus_text(texto,'Use the ''electrode:'' field and the OK button to change the  electrode '); 
    disp_lan(texto);
if ~isempty(X)    
t = fix((X*LAN{1}.srate) - (LAN{1}.time(1)*LAN{1}.srate));
end
if length(t)==1
    t(2) = t(1);
end

% n1 = comp(1);
% try n2 = comp(2); end
% gp = mean(GLAN.erp.data{n1}(:,t(1):t(2)),2);
% try gp2 = mean(GLAN.erp.data{n2}(:,t(1):t(2)),2); end


if butt==3
    figure%('Visible','on','Position',[360,500,700,1000],'MenuBar', 'none','DockControls','off');

else
    %close all
    %figure
end
rroi = arreglaroi(roi,LAN{1}.chanlocs);

%%% TOPOPLOT
if dif==0;
    
% n1 = comp(1);
% try n2 = comp(2); end
% gp = mean(GLAN.erp.data{n1}(:,t(1):t(2)),2);
% try gp2 = mean(GLAN.erp.data{n2}(:,t(1):t(2)),2); end    
%     
 for nn = 1:length(comp)   
    
    
subplot(2,length(comp),nn)
gp = mean(data{comp(nn)}(:,t(1):t(2)),2);
[gx gy] = topoplot_lan(gp,LAN{1}.chanlocs,'emarker' , {'.','k',5,1}  ,'emarker2' , {rroi,'*','k'},'shading' ,'interp' , 'style' , 'map' );
colormap('jet');
caxis([c_axis]);hold on;
try title({LAN{comp(nn)}.cond ; ['at ' num2str(fix(X*1000)) ' ms'] }); end
plot(gy(rroi),gx(rroi),...
                'ko','LineStyle','none',...
                'MarkerFaceColor',[1 0.8 0.8],...'g',...
                'MarkerSize',8);
hold off;
% subplot(2,2,2)
% try
%     [gx gy]=topoplot_lan(gp2,GLAN.chanlocs,'emarker' , {'.','k',5,1}  ,'emarker2' , {rroi,'*','k'} ,'shading' ,'interp' , 'style' , 'map' );
% colormap('jet');
% end
% try title({GLAN.cond{n2};['at ' num2str(fix(X*1000)) ' ms'] }); end
% caxis(c_axis);
% hold on;
% plot(gy(rroi),gx(rroi),...
%                 'ko','LineStyle','none',...
%                 'MarkerFaceColor',[1 0.8 0.8],...'g',...
%                 'MarkerSize',8);
% hold off;
 end
elseif dif ==1
    %%% DIF TOPOPLOT
subplot(2,2,1)
for nn = 1:length(comp)
gp(:,nn) = mean(data{comp(nn)}(:,t(1):t(2)),2);
end
if length(comp)==2
    gp = gp(:,1)-gp(:,2);
else
    gp = std(gp,[],2);
end
[gx gy] = topoplot_lan(gp,LAN{1}.chanlocs,'shading' ,'interp' , 'style' , 'map');
caxis(c_axis/2);hold on;
colormap('hot');
try title({[ LAN{cmp(1)}.cond ' - ' LAN{cmp(2)}.cond] ;['at ' num2str(fix(X*1000)) ' ms'] });end
%
plot(gy(rroi),gx(rroi),...
                'ko','LineStyle','none',...
                'MarkerFaceColor',[1 0.8 0.8],...'g',...
                'MarkerSize',8);
hold off;  
        %%% cluster
        
subplot(2,2,2)
[gx gy] = topoplot_lan(zeros(size(gp)),LAN{1}.chanlocs,'style'  ,'blank','electrodes','labelpoint','emarker',{'.','k',[],0.5});  
caxis(c_axis/2);hold on;

% plot(gy(rroi),gx(rroi),...
%                 'ro',...'MarkerFaceColor',[0 0 0],'LineStyle','none',...
%                'Interruptible','off',... ,...'g',...
%                 'MarkerSize',8);
% plot(gy(rroi),gx(rroi),...
%                 'ro','LineStyle','none',...
%                ... 'MarkerFaceColor',[1 0.8 0.8],...'g',...
%                 'MarkerSize',8);
% hold off;  

%         if  isfield(GLAN.erp,'cluster')
%         try
%             c = GLAN.erp.cluster{comp}(roi,t(1));
%            if c ~= 0 
%             %%% a lo largo del tiempo
%             ci = zeros(size(GLAN.erp.cluster{comp}));
%             ci(GLAN.erp.cluster{comp}==c) =1;
%             ci = find(any(ci,2));
%             for cl = 1:size(ci,1)
%                 cli = arreglaroi(ci(cl),GLAN.chanlocs);
%                 if cli == 0,continue,end
%                 plot(gy(cli),gx(cli),...  %% 
%                 'ro','LineStyle','none',...
%                 ...'MarkerFaceColor',[1 0 0],...'g',...
%                 'MarkerSize',10);    
%             end
%              %%% en tiempo t
%             ci = find(c==GLAN.erp.cluster{comp}(:,t(1)));
%             for cl = 1:size(ci,1)
%                 cli = arreglaroi(ci(cl),GLAN.chanlocs);
%                 if cli == 0,continue,end
%                 plot(gy(cli),gx(cli),...  %% 
%                'ro', ...
%                 'LineStyle','none',...
%                  'MarkerFaceColor',[1 0 0],...'g',...
%                 'MarkerSize',10);    
%             end
%             
%             %%%%
%             title({ ['Clusters # '  num2str(c) ''  ] ; ['at ' num2str(fix(X(1)*1000)) ' ms'] });
%             hold off
%            end
%         end
%         end
%end
%%%%%%

%if size(GLAN.erp.data,1)<10
%    if isfield(GLAN.erp, 'time')
%ltime = GLAN.erp.time;
%else   
time(1) = 0;
time(2) = size(GLAN.erp.data{comp(1)},2) /GLAN.srate;
time = time + GLAN.time(1);

linspace(time(1),time(2),size(GLAN.erp.data{comp(1)},2));

%end
    
 
cont = 0;

subplot(2,2,[3 4])
hold off
plot(0,0)
hold on
%%% significant bin
if ifh
    if butt==3
         plot(ltime,any(hh{comp}(roi,:),1),'k');  
    else

        plot(ltime(any(hh{comp}(roi,:),1)==1),ones(1,length(find(any(hh{comp}(roi,:),1)==1))),...
                    '--rs','LineStyle','none',...%'LineWidth',5,...
                    'MarkerFaceColor',[1 0.8 0.8],...'g',...
                    'MarkerSize',3);
    end            
                d =diff(any(hh{comp}(roi,:),1));

                for pp = find(d==1)
                text(ltime(pp),-2,['pval=' num2str(pvalc{comp}(roi(1),pp+1)) ]);
                end
end

if bll ==1
line([bl(1) bl(2)],[-0 -0],'LineWidth',10,'Color',[.5 .5 .5]);
end

title( [ 'ERP of electrode ' GLAN.chanlocs(roi).labels  '(' num2str(roi) ')']);
xlabel('Seconds');
ylabel('\mu V');
Div = 0;
for c = comp
cont = cont + 1;
Div = GLAN.erp.data{c}(roi,:) - Div;

plot(ltime,mean(GLAN.erp.data{c}(roi,:),1),'Color',color{cont},'LineWidth',2......
    );%,'Interruptible','off'); 
hold on;

if bll ==1

    xlim([bl(1,1)  time(1,2)]);  
   try text( (bl(1,1) ), (-0.8 * cont ),[ GLAN.cond{c} ],'Color',color{cont} );end
else
    xlim([ltime(1)  ltime(length(ltime))]);  
   try  text( (ltime(1) ), (-0.5 * cont ),[ GLAN.cond{c} ],'Color',color{cont} );end

end
end
plot(ltime,mean(Div,1),'--','Color',[0.5 0.5 0.5]...
    );%,'Interruptible','off'); 
hold on;
if isfield(GLAN.erp,'time')
 set(gca,'XTick',GLAN.erp.time.tick)   
set(gca,'XTickLabel',GLAN.erp.time.label)
end

% else%%%% for group 
% 
% time(1) = 0;
% time(2) = size(GLAN.erp.data{comp},2) /GLAN.srate;
% time = time + GLAN.time(1);
% 
% linspace(time(1),time(2),size(GLAN.erp.data{comp},2));
% cont = 0;
% 
% 
% for cc = 1:length(GLAN.erp.data)
% %figure, 
% %hold on,
% 
% plot(ltime(find(hh{cc}(roi,:)==1)),ones(1,length(find(hh{cc}(roi,:)==1))),...
%                 '--rs','LineStyle','none',...
%                 'MarkerFaceColor',[1 0.8 0.8],...'g',...
%                 'MarkerSize',3);
%             d =diff(hh{cc}(roi,:));
%             for pp = find(d==1)
%             text(ltime(pp),-2,['pval=' num2str(pvalc{cc}(roi,pp+1)) ]);
%             end
% if ~isempty(bl)
% line([bl(1) bl(2)],[-0 -0],'LineWidth',10,'Color',[.5 .5 .5]);
% end
% if cc == length(GLAN.erp.data)
%     hold off;
% else
%     hold on;
% end
% 
% 
% cont = 0;
% 
% 
% 
% for g = 1:size(GLAN.erp.data,1)
% cont = cont + 1;    
% bll=0;
% plot(ltime,GLAN.erp.data{g,cc}(roi,:),'Color',color{cont}...
%     );%hold on;,'Interruptible','off'
% 
%             
%     if bll ==1
%     xlim([bl(1,1)  time(1,2)]); 
%     text( bl(1,1)+0.3 ,-1*cont ,[ GLAN.cond{cc} ],'Color',color{cont} );
%     else
%      xlim([ltime(1)  ltime(length(ltime))]);
%     end
% end
% end      
 end


    uicontrol('Style','pushbutton','String','Close',...
          'Position',[0,0,100,25],... 'BackgroundColor',cf,... 'ForegroundColor',fc,...
         'Callback',{@close_button_Callback});
     uicontrol('Style','pushbutton','String','Scalp',...
          'Position',[0,25,100,25],... 'BackgroundColor',cf,... 'ForegroundColor',fc,...
         'Callback',{@scalp_button_Callback});
      uicontrol('Style','pushbutton','String','Dif',...
          'Position',[470,0,50,25],... 'BackgroundColor',cf,... 'ForegroundColor',fc,...
         'Callback',{@dif_button_Callback});
     
         uicontrol('Style','text','String','comp:',...
          'Position',[0,450,50,25]...%'BackgroundColor',cf,'ForegroundColor',fc
           );

    uicontrol('Style','edit',...
           'String', num2str(comp) ,...opciones{pp,1},...
           'Position',[50,450,50,25],...'BackgroundColor',cf,...'ForegroundColor',fc,...
           'Callback',{ @comp_menu_Callback} )
     
     uicontrol('Style','pushbutton','String','Scalp',...
          'Position',[0,25,100,25],... 'BackgroundColor',cf,... 'ForegroundColor',fc,...
         'Callback',{@scalp_button_Callback});  
    uicontrol('Style','text','String','Electrode:',...
          'Position',[150,0,100,25]...%'BackgroundColor',cf,'ForegroundColor',fc
           );

    uicontrol('Style','edit',...
           'String', num2str(roi) ,...opciones{pp,1},...
           'Position',[250,0,50,25],...'BackgroundColor',cf,...'ForegroundColor',fc,...
           'Callback',{ @edit_menu_Callback} );
    uicontrol('Style','pushbutton','String','OK',...
          'Position',[300,0,25,25],... 'BackgroundColor',cf,... 'ForegroundColor',fc,...
         'Callback',{@ok_button_Callback});
    uicontrol('Style','text','String','C Axis:',...
          'Position',[350,0,60,25]...%'BackgroundColor',cf,'ForegroundColor',fc
           );

    uicontrol('Style','edit',...
           'String', num2str(c_axis) ,...opciones{pp,1},...
           'Position',[410,0,50,25],...'BackgroundColor',cf,...'ForegroundColor',fc,...
           'Callback',{ @edit_caxis_menu_Callback} ); 
  
  uicontrol('Style','text','String','Time:',...
          'Position',[520,0,47,25]...%'BackgroundColor',cf,'ForegroundColor',fc
           );
 uicontrol('Style','edit',...
           'String', num2str(X(1)) ,...opciones{pp,1},...
           'Position',[570,0,100,25],...'BackgroundColor',cf,...'ForegroundColor',fc,...
           'Callback',{ @edit_time_menu_Callback} ); 
       
       
    if n ==2
    close all
    return
    
    else   
    uiwait(gcf);       
    end
    

end %while




end %if is field




    function scalp_button_Callback(source,eventdata)
    uiresume(gcf);     
    scalp=1;
    end
    function ok_button_Callback(source,eventdata)
    uiresume(gcf);     
    end
    function close_button_Callback(source,eventdata) 
    n=2;
    close gcf
    disp('DONE')
    end
    function dif_button_Callback(source,eventdata) 
    if dif == 0
        dif = 1;
    else
        dif =0;
    end
    uiresume(gcf);  
    end


    function edit_menu_Callback(source,eventdata) 
          stre = get(source, 'String');
          roi = eval(['[' stre ']' ]);
          hold off;
    end
    function comp_menu_Callback(source,eventdata) 
          stre = get(source, 'String');
          comp = eval(['[' stre ']' ]);        
            for nnn = comp
            GLAN.erp.data{nnn} = mean(cat(3,LAN{nnn}.data{:}),3);
            end    
          hold off;
    end


    function edit_caxis_menu_Callback(source,eventdata) 
          stre = get(source, 'String');
          c_axis = eval(['[' stre ']' ]);
          hold off;
    end
 function edit_time_menu_Callback(source,eventdata) 
          stre = get(source, 'String');
          time = eval(['[' stre ']' ]);
          X =time;
          hold off;
    end

    function rroi = arreglaroi(roi, chanlocs)
        rroi = zeros(1,length(roi));
        for nroi = 1:length(roi)
        for ccda = 1:roi(nroi)
            if ~isempty(chanlocs(ccda).X)
                rroi(nroi) = rroi(nroi) +1;
            end
        end
        end
    end
end % function
