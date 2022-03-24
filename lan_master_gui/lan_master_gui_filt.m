function lan_master_gui_filt(LAN_var, mainfig, parent_)

LAN = LAN_var;

if nargin < 2
    mainfig = figure;
end
figure(mainfig);
cfg_control(1) = uicontrol('style', 'text', 'units', 'norm',...
    'position', [.04 .92 .6 .05], 'string', 'channel(s) : ',...
    'horizontalalignment', 'right');
cfg_control(2) = uicontrol('style', 'edit', 'units', 'norm',...
    'position', [.65 .92 .3 .05], 'string', ['1:' mat2str(LAN.nbchan)]);
cfg_control(3) = uicontrol('style', 'text', 'units', 'norm',...
    'position', [.04 .86 .6 .05], 'string', 'method : ',...
    'horizontalalignment', 'right');
cfg_control(4) = uicontrol('style', 'popup', 'units', 'norm',...
    'position', [.65 .86 .3 .05], 'string', 'fir|butter',...
    'callback', @cb_methodpopup);
cfg_control(5) = uicontrol('style', 'text', 'units', 'norm',...
    'position', [.04 .80 .6 .05], 'string', 'min. frequency (Hz) : ',...
    'horizontalalignment', 'right');
cfg_control(6) = uicontrol('style', 'edit', 'units', 'norm',...
    'position', [.65 .80 .3 .05], 'string', '5');
cfg_control(7) = uicontrol('style', 'text', 'units', 'norm',...
    'position', [.04 .74 .6 .05], 'string', 'max. frequency (Hz) : ',...
    'horizontalalignment', 'right');
cfg_control(8) = uicontrol('style', 'edit', 'units', 'norm',...
    'position', [.65 .74 .3 .05], 'string', '20');
cfg_control(9) = uicontrol('style', 'text', 'units', 'norm',...
    'position', [.04 .68 .6 .05], 'string', 'poles (butterworth) : ',...
    'horizontalalignment', 'right', 'visible', 'off');
cfg_control(10) = uicontrol('style', 'edit', 'units', 'norm',...
    'position', [.65 .68 .3 .05], 'string', '4',...
    'visible', 'off');
cfg_control(11) = uicontrol('style', 'text', 'units', 'norm',...
    'position', [.04 .62 .6 .05], 'string', 'output var. name : ',...
    'horizontalalignment', 'right');
cfg_control(12) = uicontrol('style', 'edit', 'units', 'norm',...
    'position', [.65 .62 .3 .05], 'string', 'fLAN');
cfg_control(13) = uicontrol('style', 'pushbutton', 'units', 'norm',...
    'position', [.66 .05 .3 .06],  'string', 'Start',...
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
            str = get(cfg_control(2), 'string');
            chan = eval(['[' str ']']);
            str = get(cfg_control(6), 'string');
            if isempty(str); f_min = [];
            else f_min = eval(str); end
            str = get(cfg_control(8), 'string');
            if isempty(str); f_max = [];
            else f_max = eval(str); end
            str = get(cfg_control(10), 'string');
            poles = eval(['[' str ']']);
            
            if get(cfg_control(4), 'value') == 1
                filtsign = lan_fir2(LAN, f_min, f_max, chan);
            else
                filtsign = lan_butter(LAN, f_min, f_max, chan, poles);
            end
            fLAN = LAN;
            fLAN.data = filtsign;
            fLAN = lan_check(fLAN);
            
            varname = get(cfg_control(12), 'string');
            assignin('base', varname, fLAN);
            lan_master_gui_busyprompt(false, mainfig);
            msgbox(['A LAN variable with the requested filtered signals was created in'...
                'your workspace by the name "' varname '"']);
            delete(cfg_control);
        elseif strcmp(tag, 'help')
            web('https://bitbucket.org/marcelostockle/lan-toolbox/wiki/Filters', '-browser')
        else
            delete(cfg_control);
        end
    end

    function cb_methodpopup(hObj, event)
        if get(hObj, 'value') == 2
            set(cfg_control(9), 'visible', 'on');
            set(cfg_control(10), 'visible', 'on');
        else
            set(cfg_control(9), 'visible', 'off');
            set(cfg_control(10), 'visible', 'off');
        end
    end
end
