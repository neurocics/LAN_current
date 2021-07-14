function cfg = pregunta_lan(cfg,campos, opciones,label)
% Para conficuraciones no explicitadas
% v.0.1.3
%
% Pablo Billeke
%
% 
% 26.08.2010
% 04.05.2010
% 26.11.2009
% function cfg = gui_cfg(cfg,text)
% 
% 
% 
% end









LAN = cfg;

if nargin < 4
    label = [' '];
else
    label = [ ' para ' label ];
end



%--------detecta configuraciones ya hechas
if isstruct(LAN) || isempty(LAN)
    for  i = 1:length(campos)
    uno = ['par{' num2str(i) '} = LAN.' campos{i} ';' ]    ;
    try
        eval(uno);
    catch
        par{i} = {'...'};
    end
    if isnumeric(par{i}), par{i} = {'...'}; end %num2str(par{i})
    end
    
elseif iscell(LAN)
     for  i = 1:length(campos)
    uno = [ 'par{' num2str(i) '}  = LAN{1}.' campos{i} ';' ]    ;
       try
        eval(uno);
       catch
        par{i} = {'...'};
       end 
       if isnumeric(par{i}), par{i} = {'...'} ; end%num2str(par{i})
     end
end
%-----------------------------------




   cf = [0,0,0];
   fc = [0,1,0];
   
   
   %  Create and then hide the GUI as it is being constructed.
  r = length(campos);
   f = figure('Visible','off','Position',[360,500,700,30*r+120],'Color',cf,'MenuBar', 'none','DockControls','off');
 
   %  Construct the components.
   hok = uicontrol('Style','pushbutton','String','OK',...
          'Position',[350,20,70,25],... 'BackgroundColor',cf,... 'ForegroundColor',fc,...
         'Callback',{@okbutton_Callback});
    titulo = uicontrol('Style','text','String', [ 'Configurando campo CFG' label ],'BackgroundColor',cf,'ForegroundColor',fc,...
          'Position',[80,(30*r)+70,600,15]); 
      
      
   %--------------------------
  for pp = 1:length(campos)
      campoA = campos{pp};
            htext = uicontrol('Style','text','String',campoA,...
          'Position',[30,(30*r+50)-(pp*30),250,25],'BackgroundColor',cf,'ForegroundColor',fc);
            hpopup{pp} = uicontrol('Style','popupmenu',...
          'String', opciones(pp,:),...
          'Position',[350,(30*r+50)-(pp*30),100,25],...'BackgroundColor',cf,...'ForegroundColor',fc,...
          'Callback',{ @popup_menu_Callback} );
           hedit{pp} = uicontrol('Style','edit',...
           'String', par{pp},...opciones{pp,1},...
           'Position',[500,(30*r+50)-(pp*30),100,25],...'BackgroundColor',cf,...'ForegroundColor',fc,...
           'Callback',{ @edit_menu_Callback} );

  end
      
  


   set(f,'Name','LAN : configuration GUI')
   % Move the GUI to the center of the screen.
   movegui(f,'center')
   % Make the GUI visible.
   set(f,'Visible','on');
   
   % espera las configuraciones
   uiwait(gcf);
   cfg = LAN;
   for y = 1:length(hedit)
                     a = get(hedit{y}, 'String' ) ;
                     if iscell(a), a = a{1}; end
                     if strcmp('...',a)
                          uno = [campos{y} '= []  ;' ] ;    
                     else
                     
                         if sum(opciones{y,1} == '#')

                             uno = [campos{y} '= ' a '  ;' ] ;   
                         elseif  (sum(opciones{y,1} == 'V') + sum(opciones{y,1} == ':'))==2
                            
                             %uno = evalin('base', a );    
                             uno = [campos{y} '= ' a '  ;' ] ;  
                         else
                            uno = [campos{y} '= ''' a ''' ;' ];
                         end
                     end
                     cfg = add_field(cfg,uno);
                     
   end

   
   close(gcf);

   
       
       
%--------------------------
    function popup_menu_Callback(source,eventdata) 
         % Determine the selected data set.
         str = get(source, 'String');
         val = get(source,'Value');
         % Set current data to the selected data set.
         for i = 1:size(opciones,1)
             for n = 1:size(opciones,2)
             switch str{val};
             case opciones{i,n}
                     set(hedit{i},'String',opciones{i,n} );
        
             end
             end
         end
    end

 
   function okbutton_Callback(source,eventdata) 
    uiresume(gcf);  
   end



    function edit_menu_Callback(source,eventdata) 
         stre = get(source, 'String');
%        vale = str2num(stre);
       
     end
         
        
end






%end 