function var = choise_var(file)
% v.0.0.2
% Pablo Billeke

% 03.09.2012
% 16.05.2012 

if (nargin ==0) || (isempty(file))
 w=evalin('base','who');  
 ifws=true;
else
 w = who('-file',file);
 ifws=false;
end

 n = (numel(w(:)));
 
 if n ==1
    var = w{1} ;
    return
 end
 %ifcellis(w,'ans')
% vt=[]
for i = n:-1:1
    if ifws==1
    [T tipo v] = is_lan(w{i});
    else
        paso = load(file,w{i});
        paso = eval([ 'paso .' w{i} ]);
        [T tipo v] = is_lan(paso);    
    end
    if ~T
        w(i) = [];
 %   else
 %       vt = cat(2,v,vt);     
    end
end

n = (numel(w(:))); 
 
 cho = figure('Visible','on','Position',[0 0 400 50+25*n],...
     'Name','xLAN variable','NumberTitle','off','MenuBar', 'none','Color','Black');
 movegui(cho,'center')
 uicontrol('Style','text',...
     'String', 'Choise LAN variable from these options','Position',[40,25*(n+1),300,25]...
     ,'ForegroundColor',[0 , 1, 0],'backgroundColor',[0 , 0, 0])


 
if isempty(w)
    var = [];
    close(cho);
    return
end

for i =1:n
   uicontrol('Style','pushbutton',...
     'String', w{i},'Position',[40,25+(25*(i-1)),150,25],...
     'Callback',{@vf}),%,'ForegroundColor',[0 , 1, 0],'backgroundColor',[0 , 0, 0]) 
   
      [T tipo v] = is_lan(w{i});
      uicontrol('Style','text',...
     'String', tipo,'Position',[200,25+25*(i-1),50,25],...
     'ForegroundColor',[0 , 1, 0],'backgroundColor',[0 , 0, 0]) 

 
       
      uicontrol('Style','text',...
     'String', v,'Position',[251,25+25*(i-1),100,25],...
     'ForegroundColor',[0 , 1, 0],'backgroundColor',[0 , 0, 0]) 

 
end
uiwait(cho)

    function vf(e,rr,r)
        var = get(e, 'String');
        uiresume(cho)
        close(cho)
    end
end