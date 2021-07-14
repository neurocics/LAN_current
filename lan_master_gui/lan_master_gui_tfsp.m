function lan_master_gui_tfsp(LAN_var, mainfig, parent_)

LAN = LAN_var;
outdir = '';

if nargin < 2
    mainfig = figure;
end
figure(mainfig);

%%%%%%%%%%%%%% CHOOSE FOLDER

cfg_control(1) = uicontrol('style', 'text', 'units', 'norm',...
    'position', [.04 .92 .6 .05], 'string', 'channel(s) : ',...
    'horizontalalignment', 'right');
str = cat(2, '1:', num2str(LAN.nbchan));
cfg_control(2) = uicontrol('style', 'edit', 'units', 'norm',...
    'position', [.65 .92 .3 .05], 'string', str);
cfg_control(3) = uicontrol('style', 'text', 'units', 'norm',...
    'position', [.04 .86 .6 .05],'string', 'method : ',...
    'horizontalalignment', 'right');
cfg_control(4) = uicontrol('style', 'text', 'units', 'norm',...
    'position', [.65 .86 .3 .05], 'string', 'wavelet');
cfg_control(5) = uicontrol('style', 'text', 'units', 'norm',...
    'position', [.04 .80 .6 .05],'string', 'freq. of interest : ',...
    'horizontalalignment', 'right');
str = cat(2, '1:1:', num2str(floor(LAN.srate/2)));
cfg_control(6) = uicontrol('style', 'edit', 'units', 'norm',...
    'position', [.65 .80 .3 .05], 'string', str);
cfg_control(7) = uicontrol('style', 'text', 'units', 'norm',...
    'position', [.04 .74 .6 .05], 'string', 'time of interest : ',...
    'horizontalalignment', 'right');
cfg_control(8) = uicontrol('style', 'edit', 'units', 'norm',...
    'position', [.65 .74 .3 .05], 'string', num2str([0 LAN.xmax]));
cfg_control(9) = uicontrol('style', 'text', 'units', 'norm',...
    'position', [.04 .68 .6 .05], 'string', 'output : ',...
    'horizontalalignment', 'right');
cfg_control(10) = uicontrol('style', 'popup', 'units', 'norm',...
    'position', [.65 .68 .3 .05], 'string', 'LAN|file|separate files',...
    'value', 1, 'callback', @cb_outpop);
cfg_control(11) = uicontrol('style', 'text', 'units', 'norm',...
    'position', [.04 .62 .6 .05], 'string', 'output directory : ',...
    'horizontalalignment', 'right', 'visible', 'off');
cfg_control(12) = uicontrol('style', 'edit', 'units', 'norm',...
    'position', [.65 .62 .15 .05], 'string', outdir,...
    'visible', 'off');
cfg_control(13) = uicontrol('style', 'pushbutton', 'units', 'norm',...
    'position', [.81 .62 .14 .05], 'string', 'Select...',...
    'visible', 'off', 'callback', @cb_outdir);
cfg_control(14) = uicontrol('style', 'pushbutton', 'units', 'norm',...
    'position', [.66 .05 .3 .06], 'string', 'Start',...
    'callback', {@cb_done, mainfig}, 'tag', 'done');
cfg_control(15) = uicontrol('style', 'pushbutton', 'units', 'norm',...
    'position', [.35 .05 .3 .06], 'string', 'Help',...
    'callback', {@cb_done, mainfig}, 'tag', 'help');
cfg_control(16) = uicontrol('style', 'pushbutton', 'units', 'norm',...
    'position', [.04 .05 .3 .06], 'string', 'Cancel',...
    'callback', {@cb_done, mainfig}, 'tag', 'cancel');

for a = 1:numel(cfg_control)
    set(cfg_control(a), 'parent', parent_);
end

try_plot();

    function cb_done(hObj, event, mainfig)
        tag = get(hObj, 'tag');
        if strcmp(tag, 'done')
            cfg.type = 'wavelet';
            cfg.outdir = outdir;
            
            str = get(cfg_control(2), 'string');
            cfg.chan = eval(['[' str ']']);
            str = get(cfg_control(4), 'string');
            cfg.method = str;
            str = get(cfg_control(6), 'string');
            cfg.freqoi = eval(['[' str ']']);
            
            str = get(cfg_control(8), 'string');
            tbound = eval(['[' str ']']);
            tbound(1) = max(tbound(1),0);
            tbound(2) = min(tbound(2),LAN.xmax);
            toi = (1:LAN.pnts(1)) /LAN.srate;
            toi = toi(toi>tbound(1) & toi<=tbound(2));
            cfg.timeoi = toi;
            
            val = get(cfg_control(10), 'value');
            switch val
                case 1
                    cfg.output = 'lan';
                case 2
                    cfg.output = 'file';
                case 3
                    cfg.output = 'file4chan';
            end
            
            str = get(cfg_control(12), 'string');
            cfg.outdir = str;
            
            disp('Making time-freq representations...');
            disp('This might take a long while. Consider yourself warned.');
            LAN = lan_cspec(LAN,cfg) ;
            assignin('base', 'LAN', LAN);
            
            close(mainfig);
            msgbox('Finished. Restart LAN master GUI to include the new results',...
                'Notification', 'help');
        elseif strcmp(tag, 'help')
            web('https://bitbucket.org/marcelostockle/lan-toolbox/wiki/Continuous_spectra', '-browser')
        else
            delete(cfg_control);
        end
    end

    function try_plot()
        if isfield(LAN, 'freq') && isfield(LAN.freq, 'powspctrm')
            btn = questdlg( cat(2,'An old set of continuous spectra',...
                'was detected. Do you wish to visualize these results?'),...
                'lan_master_gui continuous spectra : Suggestion', 'No');
            if strcmpi(btn, 'Yes')
                delete(cfg_control);
                lan_master_gui_tfsp_plot(LAN, mainfig, parent_);
            end
        end
    end

    function cb_outdir(hObj, event)
        opt = get(cfg_control(10), 'value');
        if opt == 1
            % output = LAN
            % invalid outcome
            disp('you should not see this');
        else
            % output = file
            outdir = uigetdir;
            set(cfg_control(12), 'string', outdir);
        end
    end

    function cb_outpop(hObj, event)
        opt = get(cfg_control(10), 'value');
        if opt == 1
            set(cfg_control(11), 'visible', 'off');
            set(cfg_control(12), 'visible', 'off');
            set(cfg_control(13), 'visible', 'off');
        else
            set(cfg_control(11), 'visible', 'on');
            set(cfg_control(12), 'visible', 'on');
            set(cfg_control(13), 'visible', 'on');
        end
    end
end
