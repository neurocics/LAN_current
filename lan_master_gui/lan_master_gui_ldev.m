function lan_master_gui_ldev(LAN_var, mainfig, parent_)

LAN = LAN_var;
if nargin < 2
    mainfig = figure;
end
figure(mainfig);

File = ''; Path = '';
cfg_control(1) = uicontrol('style', 'text', 'units', 'norm', 'position', [.04 .92 .2 .05],...
    'string', 'full path : ', 'horizontalalignment', 'right');
cfg_control(2) = uicontrol('style', 'edit', 'units', 'norm', 'position', [.25 .92 .39 .05],...
    'string', '');
cfg_control(3) = uicontrol('style', 'pushbutton', 'units', 'norm', 'position', [.65 .92 .3 .05],...
    'string', 'Browse', 'callback', {@cb_browse});
cfg_control(8) = uicontrol('style', 'text', 'units', 'norm', 'position', [.04 .86 .6 .05],...
    'string', 'units : ', 'horizontalalignment', 'right');
cfg_control(9) = uicontrol('style', 'popup', 'units', 'norm', 'position', [.65 .86 .3 .05],...
    'string', 'sec|msec|points', 'callback', @cb_units);
cfg_control(4) = uicontrol('style', 'text', 'units', 'norm', 'position', [.04 .8 .6 .05],...
    'string', 'format : ', 'horizontalalignment', 'right');
cfg_control(5) = uicontrol('style', 'popup', 'units', 'norm', 'position', [.65 .8 .3 .05],...
    'string', 'csv|mat', 'callback', @cb_format);
cfg_control(6) = uicontrol('style', 'text', 'units', 'norm', 'position', [.04 .74 .6 .05],...
    'string', 'column : ', 'horizontalalignment', 'right', 'visible', 'on');
cfg_control(7) = uicontrol('style', 'edit', 'units', 'norm', 'position', [.65 .74 .3 .05],...
    'string', 1, 'visible', 'on');
cfg_control(12) = uicontrol('style', 'text', 'units', 'norm', 'position', [.04 .68 .6 .05],...
    'string', 'channel : ', 'horizontalalignment', 'right', 'visible', 'on');
cfg_control(13) = uicontrol('style', 'edit', 'units', 'norm', 'position', [.65 .68 .3 .05],...
    'string', 1, 'visible', 'on');
cfg_control(10) = uicontrol('style', 'text', 'units', 'norm', 'position', [.04 .62 .6 .05],...
    'string', 'sampling rate : ', 'horizontalalignment', 'right', 'visible', 'off');
cfg_control(11) = uicontrol('style', 'edit', 'units', 'norm', 'position', [.65 .62 .3 .05],...
    'string', mat2str(LAN.srate), 'visible', 'off');
cfg_control(14) = uicontrol('style', 'pushbutton', 'units', 'norm', 'position', [.66 .05 .3 .06], ...
    'string', 'Load', 'callback', {@cb_done, mainfig}, 'tag', 'done');
cfg_control(15) = uicontrol('style', 'pushbutton', 'units', 'norm', 'position', [.35 .05 .3 .06], ...
    'string', 'Help', 'callback', {@cb_done, mainfig}, 'tag', 'help');
cfg_control(16) = uicontrol('style', 'pushbutton', 'units', 'norm', 'position', [.04 .05 .3 .06], ...
    'string', 'Cancel', 'callback', {@cb_done, mainfig}, 'tag', 'cancel');

for a = 1:numel(cfg_control)
    set(cfg_control(a), 'parent', parent_);
end


    function cb_browse(hObj,event)
        [File, Path, ~] = uigetfile({'*','any file'},...
            'Open events file','*', 'MultiSelect', 'off');
        set(cfg_control(2), 'string', [Path File]);
    end
    function cb_units(hObj,event)
        val = get(hObj, 'value');
        if val == 3
            set(cfg_control(10), 'visible', 'on');
            set(cfg_control(11), 'visible', 'on');
        else
            set(cfg_control(10), 'visible', 'off');
            set(cfg_control(11), 'visible', 'off');
        end
    end
    function cb_format(hObj,event)
        val = get(hObj, 'value');
        if val == 1
            set(cfg_control(12), 'visible', 'on');
            set(cfg_control(13), 'visible', 'on');
            set(cfg_control(6), 'visible', 'on');
            set(cfg_control(7), 'visible', 'on');
        else
            set(cfg_control(12), 'visible', 'off');
            set(cfg_control(13), 'visible', 'off');
            set(cfg_control(6), 'visible', 'off');
            set(cfg_control(7), 'visible', 'off');
        end
    end

    function cb_done(hObj,event,mainfig)
        tag = get(hObj, 'tag');
        if strcmp(tag, 'done')
            if ~isempty(File)
                val = get(cfg_control(5), 'value');
                units = get(cfg_control(9), 'value');
                if val == 1 % csv
                    column = eval( get(cfg_control(7), 'string') );
                    chan = eval( get(cfg_control(13), 'string') );
                    load_csv([Path File], column, chan, units);
                elseif val == 2 % mat
                    load_mat([Path File], units);
                end
                close(mainfig);
                msgbox('Success. Restart LAN master GUI to include the new data',...
                    'Notification', 'help');
            else
                msgbox('Choose a file','Notification', 'warn')
            end
        elseif strcmp(tag, 'help')
            browser('https://bitbucket.org/marcelostockle/lan-toolbox/wiki/Time_stamps', '-browser');
        else
            delete(cfg_control);
        end
    end

    function load_csv(fullpath, column, chan, units)
        data = importdata(fullpath, ',');
        RT.laten = data.data(:,column)';
        if units == 1 % sec
            RT.laten = RT.laten * 1000;
        elseif units == 3 % points
            srate = eval( get(cfg_control(11), 'string') );
            RT.laten = RT.laten * 1000/ srate;
        end
        RT.latency = RT.laten;
        RT.est = chan * ones(1,length(RT.laten));
        RT.OTHER.time_max = zeros(1,length(RT.laten));
        RT.good = true(1,length(RT.laten));
        RT = rt_check(RT);
        
        if isfield(LAN, 'RT')
            RT = rt_merge(LAN.RT, RT, 0);
        end
        
        assignin('base', 'temp', RT);
        evalin('base', 'LAN.RT = temp; clear temp;');
    end

    function load_mat(fullpath, units)
        RT = load(fullpath);
        if strcmp(units, 'msec')
            RT.laten = RT.laten / 1000;
        elseif strcmp(units, 'points')
            srate = eval( get(cfg_control(11), 'string') );
            RT.laten = RT.laten / srate;
        end
        if isfield(LAN, 'RT')
            RT = rt_merge(LAN.RT, RT, 0);
        end
        
        assignin('base', 'temp', RT);
        evalin('base', 'LAN.RT = temp; clear temp;');
    end
end