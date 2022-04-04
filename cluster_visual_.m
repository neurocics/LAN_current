

function cluster_visual_(GLAN,clus_ind,stat_ind, data_ind,para)
%GLAN = MODEL_l

%
if nargin <5
    para=[0 .1 4 10 1 50];
end
      tt1=para(1);
      tt2=para(2);
      ff1=para(3);
      ff2=para(4);
      th1=para(5);
      th2=para(6);
     
if nargin<4    
    stat_ind=1;
end

if nargin<3  | isempty(data_ind)
data_ind=GLAN.timefreq.comp{stat_ind};
end    

if nargin<2  
clus_ind = 1;
end  
      
t1 = find_approx(tt1,GLAN.timefreq.time);
t2 = find_approx(tt2,GLAN.timefreq.time);
f1 = find_approx(ff1,GLAN.timefreq.freq);
f2 = find_approx(ff2,GLAN.timefreq.freq);




figure_lan('Clusters Visualization')

uicontrol('Style','text','String', 'Time selec:' , 'Units','normalized',...
          'Position',[0.0, 0.4 ,0.15,0.1] )
NTT = uicontrol('Style','edit','String', ['[' num2str(tt1) ' ' num2str(tt2)   ']'] , 'Units','normalized',...
          'Position',[0.15, 0.4 ,0.15,0.1] );
  
uicontrol('Style','text','String', 'Freq selec:' , 'Units','normalized',...
          'Position',[0.0+.3, 0.4 ,0.15,0.1] )      
NFF = uicontrol('Style','edit','String', ['[' num2str(ff1) ' ' num2str(ff2)   ']'] , 'Units','normalized',...
          'Position',[0.15+.3, 0.4 ,0.15,0.1] );

uicontrol('Style','text','String', 'Treshold:' , 'Units','normalized',...
          'Position',[0.0+.6, 0.4 ,0.15,0.1] )      
NTH = uicontrol('Style','edit','String', ['[' num2str(th1) ' ' num2str(th2)   ']'] , 'Units','normalized',...
          'Position',[0.15+.6, 0.4 ,0.15,0.1] );
            
      
c_clu = GLAN.timefreq.clusig{stat_ind}==clus_ind;%196; %88;

Data(c_clu==0)=NaN;
%Data(c_clu==0)=NaN;
Data = c_clu;

subplot('Position',[ 0.1 0.55 0.60 0.4 ])

%time = GLAN.timefreq.GLAN.timefreq.timeGLAN.timefreq.freq



pcolor(...
    (squeeze(nansum(Data,2)))), shading flat
colormap(hot(1000))
caxis([0 GLAN.nbchan/2])


subplot('Position',[ 0.7 0.55 0.3 0.4 ])
ch=  GLAN.chanlocs;
El = squeeze(nansum(nansum(Data(f1:f2,:,t1:t2),1),3)) ;
ind1=find(El>=th1);
El = squeeze(nansum(nansum(Data(f1:f2,:,t1:t2),1),3)) ;
ind2=find(El>=th2);

% FREQ.timefreq.subdatadif

if isfield(GLAN.timefreq, 'stat') && iscell(GLAN.timefreq.stat)
    Data = nanmean(mean(GLAN.timefreq.stat{stat_ind}( f1:f2,:,t1:t2  ),3),1); 

elseif isfield(GLAN.timefreq, 'stat') && isstr(GLAN.timefreq.stat)
    Data = nanmean(mean(GLAN.timefreq.stat.t{GLAN.timefreq.cfg.RegressorOI}( f1:f2,:,t1:t2  ),3),1); 

elseif isfield(GLAN.timefreq, 'subdatadif')
    
Data = (mean(GLAN.timefreq.subdatadif{1},4) - mean(GLAN.timefreq.subdatadif{2},4));
Data = mean(mean(Data( f1:f2,:,t1:t2  ),3),1);   
else
    if size(data_ind(1,1),2)==2
    Data = (GLAN.timefreq.data{data_ind(2,1),data_ind(1,1)} - GLAN.timefreq.data{data_ind(2,2),data_ind(1,2)});
    elseif size(data_ind(1,1),2)==1
    Data = (GLAN.timefreq.data{data_ind(2,1),data_ind(1,1)});

    end
Data = mean(mean(Data( f1:f2,:,t1:t2  ),3),1);
end

topoplot_lan(squeeze(nansum(nansum(Data(:,:,:),1),3)) ,GLAN.chanlocs,...
    'shading' ,'interp','style' , 'map', 'conv','on',...
     'electrodes','off', 'emarker2', { [ind1], '.','k',10,1}),colormap(gca,jet(1000))
 caxis([-1 1]);
...
    
topoplot_lan([] ,GLAN.chanlocs,  'electrodes','off','hcolor','none',...
    'emarker2',{ [ind2], '.','k',30,1});...

%colormap(hot(1000))
%caxis([0 500])


p = unique(GLAN.timefreq.pvalc{stat_ind}(GLAN.timefreq.clusig{stat_ind}==clus_ind));
try
p2 = unique(GLAN.timefreq.pvalc_d{stat_ind}(GLAN.timefreq.clusig{stat_ind}==clus_ind));
catch
    NaN
end

uicontrol('Style','text','String',...
          {[],['******************************************'],...
           ...['                              '],...
           ['   Cluters ind:   ' num2str(clus_ind) ],...
           ['                        '],......
           ...['                              '],...
           ['   p (corr_mc)    ' num2str(p) '  '],......
['   p (corr_dist)    ' num2str(p2(1)) '  '],......
           ['                              '],...
           ['******************************************'],...
            } ...
          , 'Units','normalized',...
          'Position',[0.1, 0.1,0.4,0.25] )


%     if p<.5
%        disp([ 'Cl: ' num2str(c_) ' p: ' num2str(p(1))  'p_d: ' num2str(p2(1))]) 
%     end

CC = unique(GLAN.timefreq.clusig{stat_ind})';

nclu ={}; paso=0;
 for c_ = CC
     p = unique(GLAN.timefreq.pvalc{stat_ind}(GLAN.timefreq.clusig{stat_ind}==c_));
     p2 = unique(GLAN.timefreq.pvalc_d{stat_ind}(GLAN.timefreq.clusig{stat_ind}==c_));

     if p<.3
        paso = paso+1;
        nclu{paso} = c_; 
        disp([ 'Cl: ' num2str(c_) ' p: ' num2str(p(1))  'p_d: ' num2str(p2(1))]) 
     end
   
 end
 
 nst=[]; paso=0;
 for c = 1:length(GLAN.timefreq.clusig)
     if ~isempty(GLAN.timefreq.clusig)
         paso=paso+1;
         nst{paso}=c;
     end
 end

uicontrol('Style','text','String', 'For new figure',... 
           'Units','normalized',...
          'Position',[0.6, 0.3 ,0.4,0.05] )  
 uicontrol('Style','text','String', 'Cluter',... 
           'Units','normalized',...
          'Position',[0.6, 0.25 ,0.2,0.05] )   ;    
NCL = uicontrol('Style','popup','String', nclu,... 
           'Units','normalized',...
          'Position',[0.8, 0.25 ,0.2,0.05] ) ;
uicontrol('Style','text','String', 'Stat #',... 
           'Units','normalized',...
          'Position',[0.6, 0.2 ,0.2,0.05] )       
NST =uicontrol('Style','popup','String', nst,... 
           'Units','normalized',...
          'Position',[0.8, 0.2 ,0.2,0.05] )  ;
      
      
uicontrol('Style','pushbutton','String','New Figure',... 
           'Units','normalized',...
          'Position',[0.8, 0 ,0.2,0.05],'Callback',{@new_clu} )        
      

    function new_clu(p,pp,ppp)

       cluster_visual_(GLAN, nclu{get(NCL, 'Value')},...
                     nst{ get(NST, 'Value')},....
                    data_ind, ...  
                   eval(['[' get(NTT,'String') ' '  get(NFF,'String') ' ' get(NTH,'String') ']' ])...
                   );
               
    end
      
end

%%
% % cluater 2 
% 
% t1 = find_approx(1.5,GLAN.timefreq.time);
% t2 = find_approx(2.2,GLAN.timefreq.time);
% f1 = find_approx(9,GLAN.timefreq.freq);
% f2 = find_approx(13,GLAN.timefreq.freq);
% 
% Data = ( GLAN.timefreq.data{1,3} - GLAN.timefreq.data{2,3});
% c_clu = GLAN.timefreq.clusig{1}==219;%196; %88;
% Data(c_clu==0)=NaN;
% Data = c_clu;
% %figure
% subplot('Position',[ 0.1 0.1 0.60 0.4 ])
% pcolor(GLAN.timefreq.time, GLAN.timefreq.freq,...
%     squeeze(nansum(Data,2))), shading flat
% colormap(hot(1000))
% caxis([0 6])
% 
% 
% 
% subplot('Position',[ 0.7 0.05 0.3 0.4 ])
% 
% ch=  GLAN.chanlocs;
% El = squeeze(nansum(nansum(Data(:,:,:),1),3)) ;
% ind1=find(El>1)
% El = squeeze(nansum(nansum(Data(f1:f2,:,t1:t2),1),3)) ;
% ind2=find(El>20)
% 
% 
% Data = ( GLAN.timefreq.data{1,3} - GLAN.timefreq.data{2,3});
% Data = mean(mean(Data( f1:f2,:,t1:t2  ),3),1);
% 
% topoplot_lan(squeeze(nansum(nansum(Data(:,:,:),1),3)) ,GLAN.chanlocs,...
%     'shading' ,'interp','style' , 'map', 'conv','on',...
%      'electrodes','off', 'emarker2', { [ind2], '.','k',30,1}),
% 
% topoplot_lan([] ,GLAN.chanlocs,  'electrodes','off','hcolor','none',...
%     'emarker2',{ [ind1], '.','k',10,1});...
% 
% 
%  
%  colormap(gca,jet(1000))
%   caxis([-1.5 1.5]);
% ...
%     
% 
% 
% 
% %%
% topoplot_lan(squeeze(nansum(nansum(Data(:,:,:),1),3)) ,GLAN.chanlocs);
% colormap(hot(1000))
% caxis([0 500])
% 
% 
% %%
% GLAN = MODEL_l
% CC = unique(GLAN.timefreq.clusig{1})';
% 
% for c_ = CC
%    
%     p = unique(GLAN.timefreq.pvalc{1}(GLAN.timefreq.clusig{1}==c_));
%     p2 = unique(GLAN.timefreq.pvalc_d{1}(GLAN.timefreq.clusig{1}==c_));
%     if p<.5
%        disp([ 'Cl: ' num2str(c_) ' p: ' num2str(p(1))  'p_d: ' num2str(p2(1))]) 
%     end
%     
%     
% end
% 
% 
% end
% 
