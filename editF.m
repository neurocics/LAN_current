%    Function for editing figure options
%    <??LAN)<]
%
%   Call from GUI bottom, e.g.:
%
%       editF({'E','Jet'})
%               or
%       uicontrol('Style','pushbutton','Position',[0,0,20,20],'String','E','Callback',{@editF})
%
%   The string is the specifit function for the bottom
%
%   Avalable  options:   
%    E  :  on  figure Menu
%    !E :  off figure Menu
%    S  :  Save figure in diferent format 
%    C  :  Change the color-map limit
%    X  :  Change X axis limit
%    Y  :  Change Y axis limit
%    Jet Hot Cool Par : Colormaps 
%
%   Pablo Billeke
%   18.02.2018 


    function editF(source,eventdata)    
    
       if nargin==0
           n=0;
            for  OP = {'E','S','C','X','Y','Jet'};
             uicontrol('Style','pushbutton','Position',[0,n,20,20],'String',OP{1},'Callback',{@editF})
             n=n+20;
            end

       elseif nargin==1
            n=0;
            for  OP = source;
             uicontrol('Style','pushbutton','Position',[0,n,20,20],'String',OP{1},'Callback',{@editF})
             n=n+20;
            end
           
       else
    
    
    
        stre = get(source, 'String');
        switch stre
            case 'E'
                set(gcf,'MenuBar','figure');
                set(source,'String','!E')
            case '!E'
                set(gcf,'MenuBar','none');
                set(source,'String','E')
            case 'S'
                [file,path,type] = uiputfile({'*.eps';'*.jpg';'*.pdf';'*.svg'},'Save figure','figure');
                if type==1
                print(gcf,'-depsc2',[path file]);
                elseif type==3
                print(gcf,'-dpdf',[path file]);
                elseif type==2
                print(gcf,'-opengl','-djpeg','-r600',[path file])  
                elseif type==4
                print(gcf,'-svg',[path file])  
                end 
            case 'C'
               limC = get(gca,'Clim');
               R = gui_q({'Lim Color'},{ num2str(limC)});
               set(gca,'Clim',eval([ '[' R{1} ']' ]));
            case 'Y'
               limY = get(gca,'Ylim');
               R = gui_q({'Lim Y axis'},{ num2str(limY)});
               set(gca,'Ylim',eval([ '[' R{1} ']' ]));
            case 'X'
               limX = get(gca,'Xlim');
               R = gui_q({'Lim X axis'},{ num2str(limX)});
               set(gca,'Xlim',eval([ '[' R{1} ']' ]));
            case 'Jet'
                set(source,'String','Hot')
                colormap(gca,jet(1000))
            case 'Hot'
                set(source,'String','Cool')
                colormap(gca,hot(1000))
            case 'Cool'
                set(source,'String','Par')
                colormap(gca,cool(1000))
            case 'Par'
                set(source,'String','Jet')
                colormap(gca,parula(1000))
        end;
        
       end;
    end
    
    
    