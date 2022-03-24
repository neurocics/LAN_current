function lan_master_gui_sthe(LAN_var, mainfig, parent_)

LAN = LAN_var;
if nargin < 2
    mainfig = figure;
end
figure(mainfig);

cfg_control(1) = uicontrol('style', 'text', 'units', 'norm',...
    'position', [.04 .92 .6 .05], 'string', 'channel : ',...
    'horizontalalignment', 'right');
cfg_control(2) = uicontrol('style', 'edit', 'units', 'norm',...
    'position', [.65 .92 .3 .05], 'string', '1');
cfg_control(3) = uicontrol('style', 'text', 'units', 'norm',...
    'position', [.04 .86 .6 .05], 'string', 'theta range (Hz) : ',...
    'horizontalalignment', 'right');
cfg_control(4) = uicontrol('style', 'edit', 'units', 'norm',...
    'position', [.65 .86 .3 .05], 'string', '4 8');
cfg_control(5) = uicontrol('style', 'text', 'units', 'norm',...
    'position', [.04 .8 .6 .05], 'string', 'delta range (Hz) : ',...
    'horizontalalignment', 'right');
cfg_control(6) = uicontrol('style', 'edit', 'units', 'norm',...
    'position', [.65 .8 .3 .05], 'string', '1 3');
cfg_control(7) = uicontrol('style', 'text', 'units', 'norm',...
    'position', [.04 .74 .6 .05], 'string', 'minimum period duration (sec) : ',...
    'horizontalalignment', 'right');
cfg_control(8) = uicontrol('style', 'edit', 'units', 'norm',...
    'position', [.65 .74 .3 .05], 'string', '1');
cfg_control(9) = uicontrol('style', 'text', 'units', 'norm',...
    'position', [.05 .68 .9 .05], 'string', 'THETA/DELTA coefficient',...
    'horizontalalignment', 'center');
cfg_control(10) = uicontrol('style', 'text', 'units', 'norm',...
    'position', [.04 .62 .6 .05], 'string', 'threshold (std) : ',...
    'horizontalalignment', 'right');
cfg_control(11) = uicontrol('style', 'edit', 'units', 'norm',...
    'position', [.65 .62 .3 .05], 'string', '2');
cfg_control(12) = uicontrol('style', 'text', 'units', 'norm',...
    'position', [.04 .56 .6 .05], 'string', 'window length (sec) : ',...
    'horizontalalignment', 'right');
cfg_control(13) = uicontrol('style', 'edit', 'units', 'norm',...
    'position', [.65 .56 .3 .05], 'string', '2');
cfg_control(14) = uicontrol('style', 'text', 'units', 'norm',...
    'position', [.04 .5 .6 .05], 'string', 'TWF : ',...
    'horizontalalignment', 'right');
cfg_control(15) = uicontrol('style', 'popup', 'units', 'norm',...
    'position', [.65 .5 .3 .05], 'string', 'hann|hamming');
cfg_control(16) = uicontrol('style', 'text', 'units', 'norm',...
    'position', [.04 .44 .6 .05], 'string', 'step (points) : ',...
    'horizontalalignment', 'right');
cfg_control(17) = uicontrol('style', 'edit', 'units', 'norm',...
    'position', [.65 .44 .3 .05], 'string', '50');
cfg_control(18) = uicontrol('style', 'text', 'units', 'norm',...
    'position', [.04 .38 .6 .05], 'string', 'output var. name : ',...
    'horizontalalignment', 'right');
cfg_control(19) = uicontrol('style', 'edit', 'units', 'norm',...
    'position', [.65 .38 .3 .05], 'string', 'LAN');
cfg_control(20) = uicontrol('style', 'pushbutton', 'units', 'norm',...
    'position', [.66 .05 .3 .06], 'string', 'Start',...
    'callback', {@cb_done, mainfig}, 'tag', 'done');
cfg_control(21) = uicontrol('style', 'pushbutton', 'units', 'norm',...
    'position', [.35 .05 .3 .06], 'string', 'Help',...
    'callback', {@cb_done, mainfig}, 'tag', 'help');
cfg_control(22) = uicontrol('style', 'pushbutton', 'units', 'norm',...
    'position', [.04 .05 .3 .06], 'string', 'Cancel',...
    'callback', {@cb_done, mainfig}, 'tag', 'cancel');

for a = 1:numel(cfg_control)
    set(cfg_control(a), 'parent', parent_);
end

    function cb_done(hObj, event, mainfig)
        tag = get(hObj, 'tag');
        if strcmp(tag, 'done')
            str = get(cfg_control(2), 'string');
            cfg.chan = eval(str);
            str = get(cfg_control(4), 'string');
            cfg.th_freq = eval(['[' str ']']);
            str = get(cfg_control(6), 'string');
            cfg.de_freq = eval(['[' str ']']);
            str = get(cfg_control(13), 'string');
            cfg.win_len = eval(str);
            str = get(cfg_control(15), 'string');
            cfg.twin = strtrim(str(get(cfg_control(15), 'value'),:));
            str = get(cfg_control(17), 'string');
            cfg.step = eval(str);
            lan_master_gui_busyprompt(true, mainfig);
            % call lan_thetavsdelta
            coef = downsample( lan_thetavsdelta(LAN, cfg), cfg.step );
            nsrate = LAN.srate / cfg.step;
            % optimize minimum duration
            str = get(cfg_control(11), 'string');
            thr_std = eval(str);   
            str = get(cfg_control(8), 'string');
            min_dur = eval(str);
            sel = select_theta(coef, thr_std, min_dur, nsrate);
            sel = myupsample(sel, cfg.step);
            % update 'selected' and 'RT'
            for w = 1:LAN.trials
                LAN.selected{w} = sel(w, 1:LAN.pnts(w));
            end
            if isfield(LAN, 'RT')
                if iscell(LAN.RT) && length(LAN.RT) == LAN.trials
                    for w = 1:LAN.trials
                        LAN.RT{w} = rt_check(LAN.RT{w});
                    end
                else
                    LAN.RT = rt_check(LAN.RT, LAN);
                end
                LAN.RT = rt_check(LAN.RT, LAN);
            end
            
            varname = get(cfg_control(19), 'string');
            assignin('base', varname, LAN);
            lan_master_gui_busyprompt(false, mainfig);
            close(mainfig);
            msgbox('Success. Restart LAN master GUI to include the new results',...
                'Notification', 'help');
        elseif strcmp(tag, 'help')
            disp('Not implemented');
        else
            delete(cfg_control);
        end
    end
    function sel = select_theta(coef, thr_std, min_dur, srate)
        trials = size(coef,1);
        sel = false(size(coef));
        for w = 1:trials;
            thr = nanmedian(coef(w,:)) * thr_std * nanstd(coef(w,:));
            min_pnts = min_dur * srate;
            sel(w,:) = coef(w,:) >= thr;
            
            arr = 1:size(sel,2);
            arr = arr(sel(w,:));
            pnts = 1;
            for c = 2:length(arr)
                if arr(c)-1 == arr(c-1)
                    pnts = pnts + 1;
                else
                    if pnts < min_pnts
                        sel(w, arr(c-pnts):arr(c-1)) = false;
                    end
                    pnts = 1;
                end
            end
            arr = 1:size(sel,2);
            arr = arr(~sel(w,:));
            pnts = 1;
            for c = 2:length(arr)
                if arr(c)-1 == arr(c-1)
                    pnts = pnts + 1;
                else
                    if pnts < min_pnts
                        sel(w, arr(c-pnts):arr(c-1)) = true;
                    end
                    pnts = 1;
                end
            end
        end
    end
    function sig = myupsample(sig,n)
        seq = (1:length(sig)) - 1;
        sig = upsample(sig,n);
        for c = 1:n-1
            sig(seq*n + c + 1) = sig(seq*n + 1);
        end
    end
end
