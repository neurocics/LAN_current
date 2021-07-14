function lan_master_gui_spks(LAN_var, mainfig, parent_)

LAN = LAN_var;

if nargin < 2
    mainfig = figure;
end
figure(mainfig);
cfg_control(1) = uicontrol('style', 'text', 'units', 'norm',...
    'position', [.35 .92 .3 .05], 'string', 'DETECTION : ');
cfg_control(2) = uicontrol('style', 'text', 'units', 'norm',...
    'position', [.04 .86 .6 .05], 'string', 'method : ',...
    'horizontalalignment', 'right');
cfg_control(3) = uicontrol('style', 'text', 'units', 'norm',...
    'position', [.65 .86 .3 .05], 'string', 'quiroga');
cfg_control(4) = uicontrol('style', 'text', 'units', 'norm',...
    'position', [.04 .80 .6 .05], 'string', 'channel(s) : ',...
    'horizontalalignment', 'right');
cfg_control(5) = uicontrol('style', 'edit', 'units', 'norm',...
    'position', [.65 .80 .3 .05], 'string', ['1:' mat2str(LAN.nbchan)]);
cfg_control(6) = uicontrol('style', 'text', 'units', 'norm',...
    'position', [.04 .74 .6 .05],'string', 'frequency range : ',...
    'horizontalalignment', 'right');
cfg_control(7) = uicontrol('style', 'edit', 'units', 'norm',...
    'position', [.65 .74 .3 .05], 'string', '300 4000');
cfg_control(8) = uicontrol('style', 'text', 'units', 'norm',...
    'position', [.04 .68 .6 .05], 'string', 'window (pre post) (ms) : ',...
    'horizontalalignment', 'right');
cfg_control(9) = uicontrol('style', 'edit', 'units', 'norm',...
    'position', [.65 .68 .3 .05], 'string', '2 2');
cfg_control(10) = uicontrol('style', 'text', 'units', 'norm',...
    'position', [.04 .62 .6 .05], 'string', 'spacing (ms) : ',...
    'horizontalalignment', 'right');
cfg_control(11) = uicontrol('style', 'edit', 'units', 'norm',...
    'position', [.65 .62 .3 .05], 'string', '2');
cfg_control(12) = uicontrol('style', 'text', 'units', 'norm',...
    'position', [.04 .56 .6 .05], 'string', 'power threshold : ',...
    'horizontalalignment', 'right');
cfg_control(13) = uicontrol('style', 'edit', 'units', 'norm',...
    'position', [.65 .56 .3 .05], 'string', '5 50');
cfg_control(14) = uicontrol('style', 'text', 'units', 'norm',...
    'position', [.04 .50 .6 .05], 'string', 'detection : ',...
    'horizontalalignment', 'right');
cfg_control(15) = uicontrol('style', 'popup', 'units', 'norm',...
    'position', [.65 .50 .3 .05], 'string', 'both|pos|neg');

cfg_control(16) = uicontrol('style', 'pushbutton', 'units', 'norm',...
    'position', [.66 .05 .3 .06], 'string', 'Start',...
    'callback', {@cb_done, mainfig}, 'tag', 'done');
cfg_control(17) = uicontrol('style', 'pushbutton', 'units', 'norm', ...
    'position', [.35 .05 .3 .06], 'string', 'Help',...
    'callback', {@cb_done, mainfig}, 'tag', 'help');
cfg_control(18) = uicontrol('style', 'pushbutton', 'units', 'norm', ...
    'position', [.04 .05 .3 .06], 'string', 'Cancel',...
    'callback', {@cb_done, mainfig}, 'tag', 'cancel');
cfg_control(19) = uicontrol('style', 'pushbutton', 'units', 'norm',...
    'position', [.3 .44 .44 .05], 'string', 'Use previous',...
    'callback', {@cb_done, mainfig}, 'tag', 'pre');

for a = 1:numel(cfg_control)
    set(cfg_control(a), 'parent', parent_);
end

    function cb_done(hObj, event, mainfig)
        tag = get(hObj, 'tag');
        if strcmp(tag, 'done')
            str = get(cfg_control(5), 'string');
            chan = eval(['[' str ']']);
            str = get(cfg_control(7), 'string');
            freq = eval(['[' str ']']);
            str = get(cfg_control(9), 'string');
            win = eval(['[' str ']']);
            str = get(cfg_control(11), 'string');
            ref = eval(['[' str ']']);
            str = get(cfg_control(13), 'string');
            thr = eval(['[' str ']']);
            str = get(cfg_control(15), 'string');
            lan_master_gui_busyprompt(true, mainfig);
            detection = strtrim(str(get(cfg_control(15), 'value'),:));
            
            win = win * LAN.srate / 1000;
            ref = ref * LAN.srate / 1000;
            
            cfg = struct('sr', LAN.srate, 'w_pre', win(1), 'w_post', win(2),...
                'ref', ref, 'detection', detection, 'stdmin', thr(1),...
                'stdmax', thr(2), 'fmin', freq(1), 'fmax', freq(2),...
                'interpolation', 'y', 'int_factor', 2);
            qRT = detectionQ(cfg, chan);
            
            lan_master_gui_busyprompt(false, mainfig);
            assignin('base', 'qRT', qRT);
            evalin('base', 'LAN.qRT = qRT; clear qRT;');
        elseif strcmp(tag, 'pre')
            qRT = LAN.qRT;
        end
        if strcmp(tag, 'done') || strcmp(tag, 'pre')
            figure(mainfig);
            delete(cfg_control);
            str = num2str(qRT.chan(1));
            for c = 2:length(qRT.chan)
                str = [str '|' num2str(qRT.chan(c))];
            end
            
            plot_control(1) = uicontrol('style', 'text', 'units', 'norm', 'position',...
                [.92 .92 .07 .05], 'string', 'CHAN');
            plot_control(2) = uicontrol('style', 'popup', 'units', 'norm', 'position',...
                [.92 .86 .07 .05], 'string', str, 'callback', {@cb_chan, qRT});
            plot_control(3) = uicontrol('style', 'text', 'units', 'norm', 'position',...
                [.92 .74 .07 .05], 'string', 'OPT');
            plot_control(4) = uicontrol('style', 'pushbutton', 'units', 'norm', 'position',...
                [.92 .68 .07 .05], 'string', '<', 'tag', '<');
            plot_control(5) = uicontrol('style', 'edit', 'units', 'norm', 'position',...
                [.92 .62 .07 .05], 'string', '1', 'tag', 'e');
            plot_control(6) = uicontrol('style', 'pushbutton', 'units', 'norm', 'position',...
                [.92 .56 .07 .05], 'string', '>', 'tag', '>');
            plot_control(7) = uicontrol('style', 'pushbutton', 'units', 'norm', 'position',...
                [.92 .5 .07 .05], 'string', 'PLOT', 'tag', 'p');
            plot_control(8) = uicontrol('style', 'pushbutton', 'units', 'norm', 'position',...
                [.92 .44 .07 .05], 'string', 'AUTOCORR', 'tag', 'a');
            plot_control(9) = uicontrol('style', 'pushbutton', 'units', 'norm', 'position',...
                [.92 .38 .07 .05], 'string', 'ISI', 'tag', 'i');
            plot_control(10) = uicontrol('style', 'pushbutton', 'units', 'norm', 'position',...
                [.92 .32 .07 .05], 'string', 'CLUSTERS', 'tag', 'c');
            plot_control(11) = uicontrol('style', 'pushbutton', 'units', 'norm', 'position',...
                [.92 .01 .07 .05], 'string', 'Clear', 'callback', {@cb_clear, plot_control});
            set(plot_control(4), 'callback', {@cb_option, plot_control, qRT});
            set(plot_control(5), 'callback', {@cb_option, plot_control, qRT});
            set(plot_control(6), 'callback', {@cb_option, plot_control, qRT});
            set(plot_control(7), 'callback', {@cb_option, plot_control, qRT});
            set(plot_control(8), 'callback', {@cb_option, plot_control, qRT});
            set(plot_control(9), 'callback', {@cb_option, plot_control, qRT});
            set(plot_control(10), 'callback', {@cb_option, plot_control, qRT});
            
            plotresults(qRT, 1);
        elseif strcmp(tag, 'help')
            web('https://bitbucket.org/marcelostockle/lan-toolbox/wiki/Spike_detection-sorting', '-browser')
        else
            delete(cfg_control);
        end
        
    end

    function qRT = detectionQ(cfg, chan)
        qRT.cfg = cfg;
        ccfg = struct('feature', 'wav', 'scales', 4, 'inputs', 10,...
            'fname_in', 'inspk.tem', 'fname', 'clu', 'mintemp', 0,...
            'maxtemp', 0.301, 'tempstep', 0.01, 'SWCycles', 100,...
            'KNearNeighb', 11);
        do_filter = true;
        if cfg.fmin == 0 && cfg.fmax == 0
            do_filter = false;
        end
        
        qRT.chan = chan;
        qRT.cluster = [];
        for e = 1:length(chan)
            cluster = struct('thr', 0, 'T', [],...
                'nclus', [], 'clu', [], 'valid', false);
            
            [spikes, cluster.thr, TS] = amp_detect(double(LAN.data{1}(chan(e),:)), qRT.cfg, do_filter);
            qRT.laten{e} = TS*1000/qRT.cfg.sr;
            
            inspk = wave_features(spikes, ccfg);
            [clu, tree] = run_cluster(inspk, ccfg);
            
            cluster.T = tree(:,2);
            cluster.nclus = tree(:,4);
            cluster.clu = clu(:, 3:end)+1;
            if size(cluster.clu, 2) == length(TS)
                cluster.valid = true;
            end
            qRT.cluster = [qRT.cluster; cluster];
        end
    end
        
    function plotresults(qRT, e)
        subplot(1, 4, [2 3 4]);
        plot(0)
        if qRT.cluster(e).valid
            M = zeros(length(qRT.cluster(e).T), 3);
            for c = 1:size(M,1)
                M(c,1) = sum(qRT.cluster(e).clu(c,:)==1);
                M(c,2) = sum(qRT.cluster(e).clu(c,:)==2);
                M(c,3) = sum(qRT.cluster(e).clu(c,:)==3);
            end
            
            bar(1:length(qRT.cluster(e).T), M, 'stacked');
            set(gca,'xtick', 1:length(qRT.cluster(e).T));
            xlabel('Option', 'fontsize', 18);
            ylabel('Cluster size', 'fontsize', 14);
            title('Cluster options, three main clusters', 'fontsize', 16)
            
            text(1,sum(M(1,:)),'*','fontsize', 20,...
                'HorizontalAlignment','center', 'VerticalAlignment','bottom')
        end
    end

    function xf = qfilter(LAN, freq, chan, do_filter)
        if nargin < 4
            do_filter = true;
        end
        if do_filter
            xf=zeros(LAN.pnts,1);
            [b,a]=ellip(2,0.1,40,freq*2/LAN.srate);
            xf=filtfilt( b,a,double(LAN.data{1}(chan,:)') );
            xf = xf';
        else
            xf = double(LAN.data{1}(cfg.chan,:));
        end
    end
    function cb_chan(hObj, event, qRT)
        e = get(hObj, 'value');
        plotresults(qRT,e);
    end

    function cb_option(hObj, event, controls, qRT)
        H = subplot(1, 4, [2 3 4]);
        H = get(H, 'Children');
        X = get(H(2), 'xdata');
        Y = get(H(2), 'ydata') + get(H(3), 'ydata') + get(H(4), 'ydata');
        opt = eval( get(controls(5), 'string') );
        str = get(controls(2), 'string');
        chan = str2double(str(get(controls(2), 'value'),:));
        tag = get(hObj, 'tag');
        
        ind = find(qRT.chan == chan);
        switch tag
            case '<'
                opt = mod(opt-2, length(X))+1;
            case '>'
                opt = mod(opt, length(X))+1;
            case 'p'
                [spk, xax] = qrt_get_spikes(qRT, LAN, chan);
                lan_master_gui_spks_plot(spk, qRT.cluster(ind).clu(opt,:), xax);
            case 'a'
                lan_master_gui_spks_auto(qRT.laten{ind},...
                    qRT.cluster(ind).clu(opt,:));
            case 'i'
                lan_master_gui_spks_isi(qRT.laten{ind},...
                    qRT.cluster(ind).clu(opt,:));
            case 'c'
                [spk, ~] = qrt_get_spikes(qRT, LAN, chan);
                lan_master_gui_spks_clu(spk, qRT.cluster(ind).clu(opt,:));
        end
        set(controls(5), 'string', num2str(opt));
        set(H(1), 'position', [opt Y(opt) 0])
    end

    function cb_clear(hObj, event, controls)
        delete(controls);
        delete(subplot(1, 4, [2 3 4]));
        delete(hObj);
    end
end
