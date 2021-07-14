function lan_master_gui_segm(LAN_var, mainfig, parent_)

LAN = LAN_var;

if nargin < 2
    mainfig = figure;
end
figure(mainfig);

radiogroup = uibuttongroup(parent_, 'units', 'norm', 'position', [0 0 1 1]);
uicontrol(radiogroup, 'style', 'radiobutton', 'units', 'norm',...
    'position', [.04 .86 .6 .05], 'string', 'segment', 'tag', 's');
cfg_control(1) = uicontrol('style', 'text', 'units', 'norm',...
    'position', [.04 .80 .6 .05], 'string', 'segment length (seconds) : ',...
    'horizontalalignment', 'right');
cfg_control(2) = uicontrol('style', 'edit', 'units', 'norm', ...
    'position', [.65 .80 .3 .05], 'string', '4');
cfg_control(3) = uicontrol('style', 'checkbox', 'units', 'norm',...
    'position', [.04 .74 .6 .05], 'string', 'inducted (LAN.RT) : ',...
    'value', false, 'callback', {@cb_checkbox}, 'tag', 'in');
cfg_control(4) = uicontrol('style', 'checkbox', 'units', 'norm',...
    'position', [.04 .66 .6 .05], 'string', 'common events : ',...
    'value', false, 'enable', 'off', 'callback', {@cb_checkbox}, 'tag', 'ce');
cfg_control(5) = uicontrol('style', 'text', 'units', 'norm',...
     'position', [.04 .60 .6 .05], 'string', 'channel (events) : ',...
     'horizontalalignment', 'right');
cfg_control(6) = uicontrol('style', 'edit', 'units', 'norm',...
    'position', [.65 .60 .3 .05], 'string', '1',...
    'enable', 'off');

uicontrol(radiogroup, 'style', 'radiobutton', 'units', 'norm',...
    'position', [.04 .44 .6 .05], 'string', 'trim', 'tag', 't');
cfg_control(7) = uicontrol('style', 'text', 'units', 'norm',...
     'position', [.04 .38 .6 .05], 'string', 'trim start (seconds) : ',...
     'horizontalalignment', 'right');
cfg_control(8) = uicontrol('style', 'edit', 'units', 'norm',...
    'position', [.65 .38 .3 .05], 'string', '0');
cfg_control(9) = uicontrol('style', 'text', 'units', 'norm',...
     'position', [.04 .32 .6 .05], 'string', 'trim end (seconds) : ',...
     'horizontalalignment', 'right');
cfg_control(10) = uicontrol('style', 'edit', 'units', 'norm',...
    'position', [.65 .32 .3 .05], 'string', num2str( LAN.time(1,2) ));

cfg_control(11) = uicontrol('style', 'text', 'units', 'norm',...
     'position', [.04 .92 .6 .05], 'string', 'output variable name : ',...
     'horizontalalignment', 'right');
cfg_control(12) = uicontrol('style', 'edit', 'units', 'norm',...
    'position', [.65 .92 .3 .05], 'string', 'LAN');

cfg_control(13) = uicontrol('style', 'pushbutton', 'units', 'norm',...
    'position', [.66 .05 .3 .06], 'string', 'Start',...
    'callback', {@cb_done, mainfig}, 'tag', 'done');
cfg_control(14) = uicontrol('style', 'pushbutton', 'units', 'norm',...
    'position', [.35 .05 .3 .06], 'string', 'Help',...
    'callback', {@cb_done, mainfig}, 'tag', 'help');
cfg_control(15) = uicontrol('style', 'pushbutton', 'units', 'norm',...
    'position', [.04 .05 .3 .06], 'string', 'Cancel',...
    'callback', {@cb_done, mainfig}, 'tag', 'cancel');

for a = 1:numel(cfg_control)
    set(cfg_control(a), 'parent', parent_);
end

    function cb_done(hObj, event, mainfig)
        tag = get(hObj, 'tag');
        if strcmp(tag, 'done')
            lan_master_gui_busyprompt(true, mainfig);
            aux = get(radiogroup,'SelectedObject');
            aux = get(aux, 'tag');
            if strcmp(aux, 's')
                str = get(cfg_control(2), 'string');
                len = eval(str);
                if get(cfg_control(3), 'value')
                    str = get(cfg_control(2), 'string');
                    if get(cfg_control(4), 'value')
                        LAN = lan_rt_segmentation(LAN, LAN.RT, [], [-len*500 len*500]);
                    else
                        LAN = lan_rt_segmentation(LAN, LAN.RT, eval(['[' str ']']), [-len*500 len*500]);
                    end
                else
                    LAN = lan_segment_selected(LAN, len);
                end
                assignin('base', get(cfg_control(12), 'string'), LAN);
                
            elseif strcmp(aux,'t')
                str = get(cfg_control(8), 'string');
                trim_start = eval(str);
                str = get(cfg_control(10), 'string');
                trim_end = eval(str);
                ind = floor([trim_start trim_end] * LAN.srate) + 1;
                if ind(1) > 0 && ind(2) < LAN.pnts(1);
                    LAN.data{1} = LAN.data{1}(:, ind(1):ind(2));
                    LAN.selected{1} = LAN.selected{1}(:, ind(1):ind(2));
                    LAN = rmfield(LAN, 'pnts');
                    LAN = rmfield(LAN, 'xmax');
                    LAN = rmfield(LAN, 'time');
                    LAN = lan_check(LAN);
                    assignin('base', get(cfg_control(12), 'string'), LAN);
                else
                    msgbox(['Trimming parameters out of bound. Output was'...
                        ' omitted.'])
                end
            else
                disp('radiogroup error')
            end
            lan_master_gui_busyprompt(false, mainfig);            
            close(mainfig);
            msgbox('Segmentation is complete. Restart LAN master GUI to include the new results',...
                'Notification', 'help');
        elseif strcmp(tag, 'help')
            disp('Not implemented');
        else
            delete(cfg_control);
        end
    end
    function cb_checkbox(hObj, event)
        tag = get(hObj, 'tag');
        switch tag
            case 'in'
                if get(hObj, 'value')
                    set(cfg_control(4), 'enable', 'on');
                    set(cfg_control(6), 'enable', 'on');
                else
                    set(cfg_control(4), 'enable', 'off');
                    set(cfg_control(6), 'enable', 'off');
                end
            case 'ce'
                if get(hObj, 'value')
                    set(cfg_control(6), 'enable', 'off');
                else
                    set(cfg_control(6), 'enable', 'on');
                end
        end
    end
end
