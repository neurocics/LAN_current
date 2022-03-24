function H = figure_lan(name,ops)
if nargin<2
ops={'E','S','C','X','Y','Jet'};
end
if nargin <1
    name=[];
end
    

H = figure('Menu','None','Name',['Figure Lan: ' name ],'NumberTitle','off');

n=0;

for  OP = ops
    
 uicontrol('Style','pushbutton','Position',[0,n,20,20],'String',OP{1},'Callback',{@editF})
 n=n+20;
end

end