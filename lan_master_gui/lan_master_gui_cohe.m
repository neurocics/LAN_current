function lan_master_gui_cohe(LAN_var, mainfig, parent_)

LAN = LAN_var;
newwin = false;
dosave = false;

if nargin < 2
    mainfig = figure;
end
figure(mainfig);
cfg_control(1) = uicontrol('style', 'text', 'units', 'norm',...
    'position', [.04 .94 .3 .05], 'string', 'TWF : ',...
    'horizontalalignment', 'right');
cfg_control(2) = uicontrol('style', 'popup', 'units', 'norm',...
    'position', [.35 .94 .3 .05], 'string', 'hann|hamming');
cfg_control(3) = uicontrol('style', 'text', 'units', 'norm',...
    'position', [.04 .88 .3 .05], 'string', 'method : ',...
    'horizontalalignment', 'right');
cfg_control(4) = uicontrol('style', 'popup', 'units', 'norm',...
    'position', [.35 .88 .3 .05], 'string', 'fourier|multitapers',...
    'callback', @cb_method);
cfg_control(5) = uicontrol('style', 'text', 'units', 'norm',...
    'position', [.04 .82 .3 .05], 'string', '[tapers] TW : ',...
    'horizontalalignment', 'right', 'visible', 'off');
cfg_control(6) = uicontrol('style', 'edit', 'units', 'norm',...
    'position', [.35 .82 .3 .05], 'string', [mat2str(LAN.pnts(1)/LAN.srate) ' * 0.5'],...
    'callback', @cb_edit, 'visible', 'off');
cfg_control(7) = uicontrol('style', 'text', 'units', 'norm',...
    'position', [.04 .76 .3 .05], 'string', '[tapers] K : ',...
    'horizontalalignment', 'right', 'visible', 'off');
cfg_control(8) = uicontrol('style', 'text', 'units', 'norm',...
    'position', [.35 .76 .3 .05], 'string', mat2str((LAN.pnts(1)/LAN.srate)-1),...
    'visible', 'off');
cfg_control(9) = uicontrol('style', 'pushbutton', 'units', 'norm',...
    'position', [.66 .82 .3 .05], 'string', 'clear',...
    'callback', @cb_done, 'tag', 'cl');
cfg_control(13) = uicontrol('style', 'checkbox', 'units', 'norm',...
    'position', [.66 .88 .3 .05], 'string', 'save',...
    'value', false, 'callback', @cb_save);
cfg_control(10) = uicontrol('style', 'checkbox', 'units', 'norm',...
    'position', [.66 .94 .3 .05], 'string', 'new window',...
    'value', false);
cfg_control(11) = uicontrol('style', 'checkbox', 'units', 'norm',...
    'position', [.04 .7 .5 .05], 'string', 'shuffling p95 | #samples : ',...
    'value', false);
cfg_control(12) = uicontrol('style', 'edit', 'units', 'norm',...
    'position', [.55 .7 .1 .05], 'string', '500',...
    'callback', @cb_done);
nav_control(1) = uicontrol('style', 'pushbutton', 'units', 'norm',...
    'position', [.66 .76 .09 .05], 'string', '<<',...
    'callback', @cb_done, 'tag', 'b1');
nav_control(2) = uicontrol('style', 'edit', 'units', 'norm',...
    'position', [.76 .76 .09 .05], 'string', '1',...
    'callback', @cb_done);
nav_control(3) = uicontrol('style', 'pushbutton', 'units', 'norm',...
    'position', [.86 .76 .09 .05], 'string', '>>',...
    'callback', @cb_done, 'tag', 'f1');
nav_control(4) = uicontrol('style', 'pushbutton', 'units', 'norm',...
    'position', [.66 .7 .09 .05], 'string', '<<',...
    'callback', @cb_done, 'tag', 'b2');
nav_control(5) = uicontrol('style', 'edit', 'units', 'norm',...
    'position', [.76 .7 .09 .05], 'string', '2',...
    'callback', @cb_done);
nav_control(6) = uicontrol('style', 'pushbutton', 'units', 'norm',...
    'position', [.86 .7 .09 .05], 'string', '>>',...
    'callback', @cb_done, 'tag', 'f2');

for a = 1:numel(cfg_control)
    set(cfg_control(a), 'parent', parent_);
end
for a = 1:numel(nav_control)
    set(nav_control(a), 'parent', parent_);
end

    function cb_done(hObj, event)
        tag = get(hObj, 'tag');
        if strcmp(tag, 'cl')
            delete(cfg_control);
            delete(nav_control);
        else
            fprintf('working...');
            str = get(nav_control(2), 'string');
            cfg.chn1 = eval(str);
            str = get(nav_control(5), 'string');
            cfg.chn2 = eval(str);
            [cfg.chn1, cfg.chn2] = change_chan(tag, cfg.chn1, cfg.chn2);
            
            str = get(cfg_control(2), 'string');
            cfg.twin = strtrim( str(get(cfg_control(2), 'value'),:) );
            str = get(cfg_control(4), 'string');
            cfg.method = strtrim( str(get(cfg_control(4), 'value'),:) );
            str = get(cfg_control(6), 'string');
            cfg.tapers = eval(str);
            str = get(cfg_control(8), 'string');
            cfg.tapers(2) = eval(str);
            newwin = get(cfg_control(10), 'value');
            shuffle = get(cfg_control(11), 'value');
            str = get(cfg_control(12), 'string');
            samples = eval(str);
            
            str = ['coherence_' LAN.name '_' LAN.cond '_'...
                num2str(cfg.chn1) '_' num2str(cfg.chn2) '.mat'];
            if shuffle
                [f, cxy, scxy95] = lan_coherence_shuffle(LAN,cfg,samples);
                plot_cohe(f, [cxy;scxy95]);
                if dosave
                    save(str, 'f', 'cxy', 'scxy95');
                    disp(['Results saved to ' str])
                end
            else
                [f, cxy] = lan_coherence(LAN,cfg);
                plot_cohe(f, cxy);
                if dosave
                    save(str, 'f', 'cxy');
                    disp(['Results saved to ' str])
                end
            end
            disp(' done');
        end
    end

    function [chn1, chn2] = change_chan(tag, chn1, chn2)
        switch tag
            case 'b1'
                chn1 = 1 + mod(chn1-2, LAN.nbchan);
                set(nav_control(2), 'string', num2str(chn1));
            case 'f1'
                chn1 = 1 + mod(chn1, LAN.nbchan);
                set(nav_control(2), 'string', num2str(chn1));
            case 'b2'
                chn2 = 1 + mod(chn2-2, LAN.nbchan);
                set(nav_control(5), 'string', num2str(chn2));
            case 'f2'
                chn2 = 1 + mod(chn2, LAN.nbchan);
                set(nav_control(5), 'string', num2str(chn2));
        end
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

    function cb_edit(hObj, event)
        TW = eval(get(hObj, 'string'));
        set(cfg_control(8), 'string', mat2str(2*TW-1));
    end

    function cb_save(hObj, event)
        dosave = get(hObj, 'value');
    end

    function plot_cohe(f, cxy)
        if newwin
            figure();
        else
            subplot(3, 4, [6:8 10:12]);
        end
        plot(f, cxy);
        xlim([f(1) f(end)]);
        ylim([0 1]);
        xlabel('frequency (Hz)');
    end
end
