function R = gui_q(text,del)
    if nargin==1; del = {''};end;
    R = {};
    % text = 'prueba'; del=''
    if ischar(text); text = {text}; del={del};end;
    %global H
    H =  figure('Position',[300,300,300,100],'Menu','none');
    for e = 1:length(text)
    uicontrol(H,'Style','Text','String',text{e},'Position',[10,50,140,40]);
    paso{e} = uicontrol(H,'Style','Edit','String',del{e},'Position',[160,50,140,40]);
    end
    uicontrol(H,'Style','pushbutton','String','OK','Position',[200,10,100,40],'Callback','uiresume(gcbf)');
    uiwait(H)
    for e =1:length(text); 
        R{e} = get(paso{e},'String'); 
    end
    close(H)
    end