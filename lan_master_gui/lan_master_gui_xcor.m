function lan_master_gui_xcor(LAN_var, mainfig)

LAN = LAN_var;

figure(mainfig);
cfg_control(1) = uicontrol('style', 'text', 'units', 'norm', 'position', [.3 .92 .44 .05],...
    'string', 'channel(s) : ', 'horizontalalignment', 'right');
cfg_control(2) = uicontrol('style', 'edit', 'units', 'norm', 'position', [.75 .92 .2 .05],...
    'string', ['1:' mat2str(LAN.nbchan)]);
cfg_control(3) = uicontrol('style', 'text', 'units', 'norm', 'position', [.3 .86 .44 .05],...
    'string', 'maximum lag : ', 'horizontalalignment', 'right');
cfg_control(4) = uicontrol('style', 'edit', 'units', 'norm', 'position', [.75 .86 .2 .05],...
    'string', '1000');
cfg_control(5) = uicontrol('style', 'checkbox', 'units', 'norm', 'position', [.3 .80 .44 .05],...
    'string', 'timemax (onset/peak)', 'value', true);
cfg_control(6) = uicontrol('style', 'pushbutton', 'units', 'norm', 'position', [.74 .05 .2 .06], ...
    'string', 'Start', 'callback', {@cb_done}, 'tag', 'done');
cfg_control(7) = uicontrol('style', 'pushbutton', 'units', 'norm', 'position', [.52 .05 .2 .06], ...
    'string', 'Help', 'callback', {@cb_done}, 'tag', 'help');
cfg_control(8) = uicontrol('style', 'pushbutton', 'units', 'norm', 'position', [.3 .05 .2 .06], ...
    'string', 'Cancel', 'callback', {@cb_done}, 'tag', 'cancel');

if ~isfield(LAN, 'RT')
    msgbox('No events (LAN.RT) detected', 'Warning', 'help');
end
if iscell(LAN.data) && length(LAN.data) > 1
    msgbox('Use unsegmented signals for time-frequency plots', 'Warning', 'help');
end

    function cb_done(hObj, event)
        tag = get(hObj, 'tag');
        if strcmp(tag, 'done')
            str = get(cfg_control(2), 'string');
            chan = eval(['[' str ']']);
            str = get(cfg_control(4), 'string');
            maxlag = eval(str);
            time_max = get(cfg_control(5), 'value');
            disp('Initializing...')
            ccor_matrix(LAN, LAN.RT, chan, maxlag, time_max);
            delete(cfg_control);
        elseif strcmp(tag, 'help')
            disp('Not implemented');
        else
            delete(cfg_control);
        end
    end
end
