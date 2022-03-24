function lan_master_gui_spec_comp(LAN_var)

LAN = LAN_var;
comp_ax = figure();

cfg_control(1) = uicontrol('style', 'text', 'units', 'norm', 'position', [.3 .92 .44 .05],...
    'string', 'Test : ', 'horizontalalignment', 'right');
cfg_control(2) = uicontrol('style', 'text', 'units', 'norm', 'position', [.75 .92 .2 .05],...
    'string', 'rank');
cfg_control(3) = uicontrol('style', 'text', 'units', 'norm', 'position', [.3 .86 .44 .05],...
    'string', 'channel A : ', 'horizontalalignment', 'right');
cfg_control(4) = uicontrol('style', 'edit', 'units', 'norm', 'position', [.75 .86 .2 .05],...
    'string', '1');
cfg_control(5) = uicontrol('style', 'text', 'units', 'norm', 'position', [.3 .8 .44 .05],...
    'string', 'channel B : ', 'horizontalalignment', 'right');
cfg_control(6) = uicontrol('style', 'edit', 'units', 'norm', 'position', [.75 .8 .2 .05],...
    'string', '2');
cfg_control(7) = uicontrol('style', 'text', 'units', 'norm', 'position', [.3 .74 .44 .05],...
    'string', 'display (pval, 1-pval, zval) : ', 'horizontalalignment', 'right');
cfg_control(8) = uicontrol('style', 'popup', 'units', 'norm', 'position', [.75 .74 .2 .05],...
    'string', 'pval|1-pval|zval');
cfg_control(9) = uicontrol('style', 'text', 'units', 'norm', 'position', [.3 .68 .44 .05],...
    'string', 'confidence : ', 'horizontalalignment', 'right');
cfg_control(10) = uicontrol('style', 'edit', 'units', 'norm', 'position', [.75 .68 .2 .05],...
    'string', '0.95');
cfg_control(11) = uicontrol('style', 'pushbutton', 'units', 'norm', 'position', [.74 .05 .2 .06], ...
    'string', 'Start', 'callback', {@cb_done}, 'tag', 'done');
cfg_control(12) = uicontrol('style', 'pushbutton', 'units', 'norm', 'position', [.52 .05 .2 .06], ...
    'string', 'Help', 'callback', {@cb_done}, 'tag', 'help');
cfg_control(13) = uicontrol('style', 'pushbutton', 'units', 'norm', 'position', [.3 .05 .2 .06], ...
    'string', 'Cancel', 'callback', {@cb_done}, 'tag', 'cancel');

    function cb_done(hObj, event)
        tag = get(hObj, 'tag');
        switch tag
            case 'done'
                str = get(cfg_control(4), 'string');
                cfg.chn1 = eval(['[' str ']']);
                str = get(cfg_control(6), 'string');
                cfg.chn2 = eval(['[' str ']']);
                str = get(cfg_control(8), 'string');
                cfg.display = strtrim(str(get(cfg_control(8), 'value'),:));
                str = get(cfg_control(10), 'string');
                cfg.conf = eval(['[' str ']']);
                
                inp = {LAN.freq.fourierp.data(cfg.chn1,:,:), LAN.freq.fourierp.data(cfg.chn2,:,:)};
                [P St] = lan_nonparametric(inp);
                switch cfg.display
                    case 'pval'
                        plot(LAN.freq.fourierp.freq, P);
                        hold on;
                        plot(LAN.freq.fourierp.freq, (1-cfg.conf)*ones(length(P), 1), 'c--');
                        xlim([LAN.freq.fourierp.freq(1) LAN.freq.fourierp.freq(end)]);
                        xlabel('p value'); ylabel('frequency (Hz)');
                    case '1-pval'
                        plot(LAN.freq.fourierp.freq, 1-P);
                        hold on;
                        plot(LAN.freq.fourierp.freq, cfg.conf*ones(length(P), 1), 'c--');
                        xlim([LAN.freq.fourierp.freq(1) LAN.freq.fourierp.freq(end)]);
                        xlabel('p value'); ylabel('frequency (Hz)');
                    case 'zval'
                        plot(LAN.freq.fourierp.freq, St.zval);
                        xlim([LAN.freq.fourierp.freq(1) LAN.freq.fourierp.freq(end)]);
                        xlabel('z value'); ylabel('frequency (Hz)');
                end
                title(['channels [' cfg.chn1 ', ' cfg.chn2]);
                delete(cfg_control);
            case 'help'
                disp('Not implemented');
            case 'cancel'
                close(comp_ax);
        end
    end

end