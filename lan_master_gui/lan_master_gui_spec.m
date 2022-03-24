function lan_master_gui_spec(LAN_var, mainfig, parent_)

LAN = LAN_var;

current = 1;
sel = 1;
holdon = false;
logx = true;

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
    'position', [.65 .86 .3 .05], 'string', 'fourier|multitapers',...
    'callback', @cb_method);
cfg_control(5) = uicontrol('style', 'text', 'units', 'norm',...
    'position', [.04 .80 .6 .05], 'string', '[tapers] TW : ',...
    'horizontalalignment', 'right', 'visible', 'off');
cfg_control(6) = uicontrol('style', 'edit', 'units', 'norm',...
    'position', [.65 .80 .3 .05], 'string', [mat2str(LAN.pnts(1)/LAN.srate) ' * 0.5'],...
    'callback', {@cb_edit}, 'visible', 'off');
cfg_control(7) = uicontrol('style', 'text', 'units', 'norm',...
    'position', [.04 .74 .6 .05], 'string', '[tapers] K : ',...
    'horizontalalignment', 'right', 'visible', 'off');
cfg_control(8) = uicontrol('style', 'text', 'units', 'norm',...
    'position', [.65 .74 .3 .05], 'string', mat2str((LAN.pnts(1)/LAN.srate)-1),...
    'visible', 'off');
cfg_control(9) = uicontrol('style', 'checkbox', 'units', 'norm',...
    'position', [.04 .68 .6 .05], 'string', 'save after completion',...
    'value', false);
cfg_control(10) = uicontrol('style', 'text', 'units', 'norm',...
    'position', [.04 .62 .6 .05], 'string', 'output var. name : ',...
    'horizontalalignment', 'right');
cfg_control(11) = uicontrol('style', 'edit', 'units', 'norm',...
    'position', [.65 .62 .3 .05], 'string', 'freq');

cfg_control(12) = uicontrol('style', 'pushbutton', 'units', 'norm',...
    'position', [.66 .05 .3 .06], 'string', 'Start',...
    'callback', {@cb_done, mainfig}, 'tag', 'done');
cfg_control(13) = uicontrol('style', 'pushbutton', 'units', 'norm',...
    'position', [.35 .05 .3 .06], 'string', 'Help',...
    'callback', {@cb_done, mainfig}, 'tag', 'help');
cfg_control(14) = uicontrol('style', 'pushbutton', 'units', 'norm',...
    'position', [.04 .05 .3 .06], 'string', 'Cancel',...
    'callback', {@cb_done, mainfig}, 'tag', 'cancel');
plot_control(1) = uicontrol('style', 'checkbox', 'units', 'norm',...
    'position', [.3 .0 .13 .05], 'string', 'log freq',...
    'callback', {@cb_checkbox}, 'value', logx, 'visible', 'off', 'tag', 'lx');
plot_control(2) = uicontrol('style', 'checkbox', 'units', 'norm',...
    'position', [.44 .0 .13 .05], 'string', 'hold',...
    'callback', {@cb_checkbox}, 'value', holdon, 'visible', 'off', 'tag', 'ho');
plot_control(3) = uicontrol('style', 'text', 'units', 'norm',...
    'position', [.58 .0 .11 .05], 'string', 'Channel: ',...
    'visible', 'off');
plot_control(4) = uicontrol('style', 'edit', 'units', 'norm',...
    'position', [.69 .0 .07 .05], 'string', '1',...
    'callback', {@cb_changechan}, 'visible', 'off');
plot_control(5) = uicontrol('style', 'pushbutton', 'units', 'norm',...
    'position', [.78 .0 .11 .05], 'string', 'Compare',...
    'callback', {@cb_done, mainfig}, 'visible', 'off', 'tag', 'com');
plot_control(6) = uicontrol('style', 'pushbutton', 'units', 'norm', ...
    'position', [.89 .0 .11 .05], 'string', 'Clear',...
    'callback', {@cb_done, mainfig}, 'visible', 'off', 'tag', 'fin');

for a = 1:numel(cfg_control)
    set(cfg_control(a), 'parent', parent_);
end
for a = 1:numel(plot_control)
    set(plot_control(a), 'parent', parent_);
end


    function cb_done(hObj, event, mainfig)
        tag = get(hObj, 'tag');
        switch tag
            case 'done'
                lan_master_gui_busyprompt(true, mainfig);
                str = get(cfg_control(2), 'string');
                cfg.chn = eval(['[' str ']']);
                str = get(cfg_control(4), 'value');
                cfg.method = 'f';
                if str==2
                    cfg.method = 'mt';
                end
                str = get(cfg_control(6), 'string');
                cfg.tapers = [eval(['[' str ']']) 0];
                str = get(cfg_control(8), 'string');
                cfg.tapers(2) = eval(['[' str ']']);
                
                LAN = fourierp_lan(LAN, cfg);
                
                varname = get(cfg_control(11), 'string');
                assignin('base', varname, LAN.freq);
                if get(cfg_control(9), 'value')
                    [filename,pathname] = uiputfile(['spec_' LAN.name '_' LAN.cond '.mat'],...
                        'Save results as...');
                    if ~isequal(filename,0)
                        spectra_data = LAN.freq.fourierp;
                        save([pathname filename], 'spectra_data');
                    end
                    clear spectra_data;
                end
                lan_master_gui_busyprompt(false, mainfig);
                figure(mainfig);
                delete(cfg_control);
                plot_spectra();
                
                for c = plot_control
                    set(c, 'visible', 'on');
                end
            case 'help'
                web('https://bitbucket.org/marcelostockle/lan-toolbox/wiki/Fourier_spectra', '-browser')
            case 'cancel'
                delete(cfg_control);
            case 'com'
                lan_master_gui_spec_comp(LAN);
            case 'fin'
                delete(plot_control);
                delete(subplot(1, 4, [2 3 4]));
        end
    end

    function cb_edit(hObj, event)
        TW = eval(get(hObj, 'string'));
        set(cfg_control(8), 'string', mat2str(2*TW-1));
    end

    function cb_checkbox(hObj, event)
        tag = get(hObj, 'tag');
        switch tag
            case 'ho'
                holdon = get(hObj,'value');
            case 'lx'
                logx = get(hObj,'value');
        end
        plot_spectra();
    end

    function cb_changechan(hObj, event)
        current = str2double(get(hObj, 'string'));
        if holdon
            sel = [sel current];
        else
            sel = current;
        end
        plot_spectra();
    end

    function cb_method(hObj, event)
        if get(hObj, 'value') == 2
            set(cfg_control(5), 'visible', 'on');
            set(cfg_control(6), 'visible', 'on');
            set(cfg_control(7), 'visible', 'on');
            set(cfg_control(8), 'visible', 'on');
        else
            set(cfg_control(5), 'visible', 'off');
            set(cfg_control(6), 'visible', 'off');
            set(cfg_control(7), 'visible', 'off');
            set(cfg_control(8), 'visible', 'off');
        end
    end

    function plot_spectra()
        freq = LAN.freq.fourierp.freq;
        matrix_mean = [];
        for c = sel;
            matrix_mean = [matrix_mean; LAN.freq.fourierp.mean(c,:)];
        end
        subplot(1, 4, [2 3 4])
        if logx
            loglog(freq, matrix_mean)
        else
            semilogy(freq, matrix_mean)
        end
    end
end
