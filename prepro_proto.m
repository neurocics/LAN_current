function prepro_proto(LAN)

global fig_eeg;
global fig_chan;
global fig_control;
global fig_tsm;

time_win = 1;
time_start = 0;
time_trial = 1;
chansel = 1:LAN.nbchan;
chansel_ts = 1:LAN.nbchan;
str_chan = cat(2,'1:',num2str(LAN.nbchan));
chanhighlight = 0;
gapsize = 3* mean( std(LAN.data{1},[],2) , 1);
resizefact = 1;
nav_trials = false;

selplot_hold = false;
selplot_val = NaN;
selplot_ts = false;

hil_do = false;
hil_data = [];
hil_f1 = 2;
hil_f2 = 4;

cspec_do = false;
cspec_data = [];
cspec_fax = [];
cspec_tax = [];
cspec_flim = [];
cspec_clim = [0 5];

tsm_cdata = [];
tsm_lfpdata = [];
tsm_phasing = false;
tsm_pfreq = [80 180];
tsm_maxlag = 100;
tsm_lagax = [];
tsm_rej = false;
tsm_any = false;
tsm_timemax = true;

if isfield(LAN, 'RT')
    if isfield(LAN.RT,'OTHER') && isfield(LAN.RT.OTHER,'names')
        ts_txt = LAN.RT.OTHER.names;
    else
        ts_txt = cell(size(LAN.RT.est));
        for a = 1:numel(ts_txt)
            ts_txt{a} = num2str(LAN.RT.est(a));
        end
    end
else
    ts_txt = {};
end

fig_eeg = figure('name', 'Data', 'units', 'norm', 'position', [.0 .1 .6 .67],...
    'numbertitle', 'off', 'menubar', 'none','closerequestfcn', @cb_closefalse);
fig_chan = figure('name', 'Channels', 'units', 'norm', 'position', [.6 .1 .4 .67],...
    'numbertitle', 'off', 'menubar', 'none','closerequestfcn', @cb_closefalse);
fig_control = figure('name', 'Controls', 'units', 'norm', 'position', [.0 .8 1 .15],...
    'numbertitle', 'off', 'menubar', 'none','closerequestfcn', @cb_close);
subh_eegA = NaN;
subh_eegB = NaN;
subh_eegC = NaN;
subpos_eegA = [.06 .13 .88 .80];
subpos_eegB = [.06 .00 .88 .10];
subpos_eegAUXA = [.06 .13 .88 .38];
subpos_eegAUXC = [.06 .53 .88 .40];
eeg_chancontrol = [];

% controls: CONTROLS
figure(fig_control);
uicontrol('style','pushbutton','units','norm','position',[.9 .1 .1 .2],...
    'string','Close','callback',@cb_close);
uicontrol('style','pushbutton','units','norm','position',[.9 .3 .05 .2],...
    'string','Data','callback',@cb_showeeg);
uicontrol('style','pushbutton','units','norm','position',[.95 .3 .05 .2],...
    'string','Channels','callback',@cb_showchan);
uicontrol('style','pushbutton','units','norm','position',[.9 .5 .05 .2],...
    'string','Save (V)','callback',@cb_savevar, 'tag', 'save');
control_varname = uicontrol('style','edit','units','norm','position',[.95 .5 .05 .2],...
    'string','varname');

control_panelA = uipanel('title','Hilbert filter','units','norm',...
    'position',[.68 .05 .2 .9]);
uicontrol('parent', control_panelA, 'style','pushbutton','units','norm',...
    'position',[.1 .7 .8 .25],'string','Show','callback',@cb_ctrlhilbert);
uicontrol('parent', control_panelA, 'style','text','units','norm'...
    ,'position',[.1 .45 .6 .25],'string','Bandpass, low freq');
control_hf1 = uicontrol('parent', control_panelA, 'style','edit',...
    'units','norm','position',[.7 .45 .1 .25],'string','2');
uicontrol('parent', control_panelA, 'style','text','units','norm',...
    'position',[.8 .45 .1 .25],'string','Hz');
uicontrol('parent', control_panelA, 'style','text','units','norm'...
    ,'position',[.1 .2 .6 .25],'string','Bandpass, high freq');
control_hf2 = uicontrol('parent', control_panelA, 'style','edit',...
    'units','norm','position',[.7 .2 .1 .25],'string','4');
uicontrol('parent', control_panelA, 'style','text','units','norm',...
    'position',[.8 .2 .1 .25],'string','Hz');

control_panelB = uipanel('title','Time stamps','units','norm',...
    'position',[.46 .05 .2 .9]);
uicontrol('parent', control_panelB, 'style','pushbutton','units','norm',...
    'position',[.1 .7 .8 .25],'string','Time stamps','callback',@cb_ctrlts);
uicontrol('parent', control_panelB, 'style','text','units','norm',...
    'position',[.1 .45 .6 .25],'string','Channel(s) of interest : ',...
    'horizontalalignment', 'right');
uicontrol('parent', control_panelB, 'style','edit','units','norm',...
    'position',[.7 .45 .2 .25],'string',str_chan,'callback',@cb_ctrltschan);
uicontrol('parent', control_panelB, 'style','pushbutton','units','norm',...
    'position',[.1 .1 .6 .25],'string','TS reject','callback',@cb_ctrltsrej);
control_rejms = uicontrol('parent', control_panelB, 'style','edit',...
    'units','norm','position',[.7 .1 .1 .25],'string','100','callback',@cb_ctrltsrej);
uicontrol('parent', control_panelB, 'style','text','units','norm',...
    'position',[.8 .1 .1 .25],'string','msec');

control_panelC = uipanel('title','Continuous spectrogram','units','norm',...
    'position',[.24 .05 .2 .9]);
uicontrol('parent', control_panelC, 'style','pushbutton','units','norm',...
    'position',[.1 .7 .8 .25],'string','Show','callback',@cb_ctrlcspec,...
    'tag','toggle');
uicontrol('parent', control_panelC, 'style','text','units','norm',...
    'position',[.3 .45 .3 .25],'string','Freq. axis');
control_flim = uicontrol('parent', control_panelC, 'style','edit','units','norm',...
    'position',[.6 .45 .3 .25],'string','',...
    'callback',@cb_ctrlcspec,'tag','flim');
uicontrol('parent', control_panelC, 'style','text','units','norm',...
    'position',[.3 .2 .3 .25],'string','Color axis');
uicontrol('parent', control_panelC, 'style','edit','units','norm',...
    'position',[.6 .2 .3 .25],'string',num2str(cspec_clim),...
    'callback',@cb_ctrlcspec,'tag','clim');

control_panelD = uipanel('title', 'Time stamps mean', 'units', 'norm',...
    'position', [.02 .05 .2 .9]);
uicontrol('parent', control_panelD, 'style','pushbutton','units','norm',...
    'position',[.1 .8 .8 .18],'string','Start ',...
    'horizontalalignment', 'center', 'callback', @cb_meants);
control_tsm_phasing = uicontrol('parent', control_panelD, 'style','checkbox','units','norm',...
    'position',[.1 .6 .6 .18],'string','Phasing freq. range',...
    'value', tsm_phasing);
control_tsm_pfreq = uicontrol('parent', control_panelD, 'style','edit','units','norm',...
    'position',[.7 .6 .2 .18],'string',num2str(tsm_pfreq));
uicontrol('parent', control_panelD, 'style','text','units','norm',...
    'position',[.1 .4 .58 .18],'string','max lag (ms) ',...
    'horizontalalignment', 'right');
control_tsm_maxlag = uicontrol('parent', control_panelD, 'style','edit','units','norm',...
    'position',[.7 .4 .2 .18],'string',num2str(tsm_maxlag));
control_tsm_rej = uicontrol('parent', control_panelD, 'style', 'checkbox', 'units', 'norm',...
    'position', [.1 .2 .38, .18], 'string', 'include rejected',...
    'value', tsm_rej);
control_tsm_any = uicontrol('parent', control_panelD, 'style', 'checkbox', 'units', 'norm',...
    'position', [.5 .2 .38, .18], 'string', 'from any channel',...
    'value', tsm_any);
control_tsm_timemax = uicontrol('parent', control_panelD, 'style', 'checkbox', 'units', 'norm',...
    'position', [.1 .0 .38, .18], 'string', 'use time_max',...
    'value', tsm_timemax);



% controls: EEG
figure(fig_eeg);
plot(0,0)
uicontrol('style','edit','units','norm','position',[.0 .93 .06 .07],...
    'string',str_chan,'callback',@cb_eegchan);
uicontrol('style','text','units','norm','position',[.18 .93 .1 .07],...
    'string','Trial:');
control_eegtrial = uicontrol('style','edit','units','norm',...
    'position',[.28 .93 .05 .07],'string',num2str(time_trial),...
    'callback',@cb_eegtrial);
control_eegtime = uicontrol('style','edit','units','norm',...
    'position',[.33 .93 .5 .07],'string',num2str([time_start time_win]),...
    'callback',@cb_eegtime);
control_lnav = uicontrol('style','pushbutton','units','norm',...
    'position',[.86 .93 .05 .07],'string','<',...
    'callback',@cb_eegnav, 'tag', '<');
uicontrol('style','pushbutton','units','norm','position',[.91 .93 .04 .07],...
    'string','@','callback',@cb_eegnav, 'tag', '@');
control_rnav = uicontrol('style','pushbutton','units','norm',...
    'position',[.95 .93 .05 .07],'string','>',...
    'callback',@cb_eegnav, 'tag', '>');
uicontrol('style','pushbutton','units','norm','position',[.94 .54 .06 .07],...
    'string','+','callback',@cb_eegresize, 'tag', '+');
control_resize = uicontrol('style','edit','units','norm',...
    'position',[.94 .47 .06 .07],'string',num2str(resizefact),...
    'callback',@cb_eegresize, 'tag', 'e');
uicontrol('style','pushbutton','units','norm','position',[.94 .40 .06 .07],...
    'string','-','callback',@cb_eegresize, 'tag', '-');
eeg_chanbuttons();

% controls: CHANNELS
chan_labels();
chan_panelR = uipanel('title','TAGs','units','norm','position',[.51,.65,.44,.3]);

doplot();




    function eeg_chanbuttons()
        figure(fig_eeg);
        for a = 1:numel(eeg_chancontrol)
            delete(eeg_chancontrol(a));
        end
        eeg_chancontrol = [];
        
        x_init = 0.0;
        y_init = subpos_eegA(2)+subpos_eegA(4);
        width = subpos_eegA(1);
        height = subpos_eegA(4)/numel(chansel);
        
        % backwards iteration: last channel first
        for a = 1:numel(chansel)
            name = num2str(chansel(a));
            if isfield(LAN, 'chanlocs')
                name = LAN.chanlocs(chansel(a)).labels;
            end
            pos = [x_init y_init-a*height width height];
            eeg_chancontrol(a) = uicontrol('style','pushbutton',...
                'units','norm','position',pos,'string',name,...
                'callback',@cb_chanbutton,'tag',num2str(chansel(a)));
        end
    end
    function chan_labels()
        figure(fig_chan);
        height = 1/numel(chansel);
        for a = 1:numel(chansel)
            c = chansel(a);
            str1 = '';
            str2 = '';
            str3 = '';
            if isfield(LAN, 'chanlocs')
                str1 = LAN.chanlocs(c).labels;
                if isfield(LAN.chanlocs(1), 'locations') &&...
                        numel(LAN.chanlocs(1).locations)>=c
                    str2 = LAN.chanlocs(1).locations{c};
                end
                str3 = cat(2,...
                    num2str(LAN.chanlocs(c).X),' ',...
                    num2str(LAN.chanlocs(c).Y),' ',...
                    num2str(LAN.chanlocs(c).Z));
            end
            str = cat(2,num2str(c),' ',str1,' : ',str3,' ',str2);
            uicontrol('style','text', 'string',str,...
                'units','norm','position',[.05 (1-a*height)*.9+.05 .44 height*.9]);
        end
    end
    function doplot()
        figure(fig_eeg);
        tax = (1:LAN.pnts(time_trial))/LAN.srate;
        tax_ind = find(tax >= time_start & tax < time_start+time_win);
        tax = tax(tax_ind);
        
        gap = repmat(0:numel(chansel)-1, numel(tax_ind), 1)';
        gap = gap*gapsize;
        ylim_aux = [-numel(chansel)*gapsize gapsize];
        
        % index requested data
        data = LAN.data{time_trial}(chansel,tax_ind);
        data = detrend(data')';
        data = data * resizefact - gap;
        cdata = [];
        if chanhighlight~=0
            if hil_do
                data = LAN.data{time_trial}(chanhighlight,tax_ind);
                data = detrend(data')';
                data = data * resizefact;
                hil_win = hil_data(tax_ind);
                
                data = cat(2, data',...
                    angle(hil_win)*gapsize/15 -2*gapsize,...
                    3*real(conj(hil_win).*hil_win)./abs(hil_win)*resizefact -1*gapsize,...
                    3*real(hil_win)*resizefact -1*gapsize)';
                ylim_aux = [-3*gapsize gapsize];
            elseif cspec_do
                data = LAN.data{time_trial}(chanhighlight,tax_ind);
                data = detrend(data')';
                data = data * resizefact;
                ylim_aux = [-1*gapsize gapsize];
            end
            if cspec_do
                
                ctax_ind = find(cspec_tax >= time_start & cspec_tax < time_start+time_win);
                if isempty(cspec_data)
                    cdata = nan();
                else
                    cdata = cspec_data(:,ctax_ind);
                end
            end
        end
        
        % print plots
        if ~isempty(cdata)
            subh_eegA = subplot('position', subpos_eegAUXA);
        else
            subh_eegA = subplot('position', subpos_eegA);
        end
        plot(tax,data);
        if ~hil_do && ~cspec_do && chanhighlight~=0
            hold on;
            plot(tax, data(chansel==chanhighlight,:),...
                'linewidth', 3);
            hold off;
        end
        xlim_aux = [0 time_win]+time_start;
        xlim(xlim_aux);
        ylim(ylim_aux);
        set(gca,'ytick',[]);
        
        diff_aux = diff(LAN.selected{time_trial});
        diff_start = find(diff_aux==1)+1;
        diff_end = find(diff_aux==-1);
        if numel(diff_start)==numel(diff_end)-1
            diff_start = [1 diff_start];
        end
        if numel(diff_end)==numel(diff_start)-1
            diff_end = [diff_end LAN.pnts(time_trial)];
        end
        
        % cspec subplot
        if ~isempty(cdata)
            subh_eegC = subplot('position', subpos_eegAUXC);
            imagesc(cspec_tax(ctax_ind),cspec_fax,cdata);
            colormap(hot);
            caxis(cspec_clim);
            set(gca, 'ydir', 'normal');
            set(gca,'xtick',[]);
            ylim(cspec_flim);
            colorbar('peer',subh_eegC,'units','norm',...
                'position',[.95 .65 .03 .25]);
        else
            colorbar('off');
        end
        
        % selection bar
        subh_eegB = subplot('position', subpos_eegB);
        plot(0,0);
        hold on;
        for a = 1:numel(diff_end)
            plot([diff_start(a) diff_end(a)]/LAN.srate, zeros(1,2),...
                '-or', 'linewidth', 3);
        end
        if selplot_ts
            ts = LAN.RT.laten/1000;
            
            sel = false(size(ts));
            for a = 1:numel(chansel_ts)
                sel(LAN.RT.est==chansel_ts(a)) = true;
            end
            sel = sel & ts>time_start & ts<time_start+time_win;
            ts = ts(sel);
            text_aux = ts_txt(sel);
            if ~isempty(ts)
                tsx = ts( [floor(1:.5:numel(ts)) numel(ts)] );
                tsy = ones(2*numel(ts),1);
                tsy(1:4:end) = -1;
                if numel(tsy>2)
                    tsy(4:4:end) = -1;
                end
                tsy = tsy*1.1;
                plot(tsx, tsy)
                
                for a = 1:numel(ts)
                    text(ts(a),.9,text_aux(a), 'color', [.5 .5 .5]);
                end
            end
        end
        hold off
        ylim([-1 1]);
        xlim(xlim_aux)
        set(gca,'ytick',[]);
        set(gca,'xtick',[]);
        set(gca,'buttondownfcn',@cb_selplot);
    end
    function doplot_mean()
        if ishandle(fig_tsm)
            delete(fig_tsm);
        end
        fig_tsm = figure('name', 'Time stamps mean');
        
        subplot(4,1,[1 2 3])
        imagesc(tsm_lagax,cspec_fax,tsm_cdata);
        colormap(hot);
        caxis(cspec_clim);
        set(gca, 'ydir', 'normal');
        xlim([-1 1]*tsm_maxlag);
        ylim(cspec_flim);
        colorbar('units', 'norm', 'position', [.93 .5 .04 .4]);
        
        subplot(4,1,4)
        plot(tsm_lagax, tsm_lfpdata);
        xlim([-1 1]*tsm_maxlag);
    end

    function hil_data_calc()
        if chanhighlight~=0
            hil_f1 = eval(get(control_hf1, 'string'));
            hil_f2 = eval(get(control_hf2, 'string'));
            hil_data = filter_hilbert(LAN.data{time_trial}(chanhighlight,:)',...
                LAN.srate,hil_f1, hil_f2);
        end
    end
    function cspec_data_calc()
        cspec_data = [];
        if chanhighlight~=0
            cspec_data = lan_cspec_load(LAN, chanhighlight, time_trial);
            cspec_fax = LAN.freq.freq;
            cspec_tax = (1:LAN.pnts(time_trial)) / LAN.srate;
            cspec_flim = [cspec_fax(1) cspec_fax(end)];
            set(control_flim, 'string', num2str(cspec_flim));
        end
    end
    function cspec_mean_calc()
%       tsm_cdata = [];
        ts = LAN.RT.laten * LAN.srate / 1000;
        if tsm_timemax
            ts = ts+LAN.RT.OTHER.time_max;
        end
        sel = true(size(ts));
        if ~tsm_any
            sel = sel & LAN.RT.est==chanhighlight;
        end
        if ~tsm_rej
            sel = sel & LAN.RT.good;
        end
        ts = ts(sel);
        
        win_pts = ceil(tsm_maxlag * LAN.srate / 1000);
        win = -win_pts:1:win_pts;
        tsm_lagax = win*1000/LAN.srate;
        ts = ts( ts+win(1)>5 );
        ts = ts( ts+win(end)<=LAN.pnts(time_trial)-5 );
        % 5 samples margin to avoid phasing exceptions
        
        if tsm_phasing
            phase = filter_hilbert(LAN.data{time_trial}(chanhighlight,:)',...
                LAN.srate, min(tsm_pfreq), max(tsm_pfreq), 0)';
            phase = abs( angle(phase) );
        end
        
        tsm_cdata = zeros(numel(cspec_fax), numel(win));
        tsm_lfpdata = zeros(1, numel(win));
        count = zeros(size(tsm_cdata));
        for t = 1:numel(ts)
            ind = ts(t);
            if tsm_phasing
                dif = ind+(-3:3);
                [~,aux] = min( phase(dif) );
                ind = dif(aux);
            end
            aux = cspec_data(:,ind+win);
            count = count + ~isnan(aux);
            aux(isnan(aux)) = 0;
            tsm_cdata = tsm_cdata + aux;
            tsm_lfpdata = tsm_lfpdata + LAN.data{time_trial}(chanhighlight,ind+win);
            
        end
        tsm_cdata = tsm_cdata ./ count;
    end

    function cb_close(hObj, event)
        % invoked by closing the controls panel
        if ishandle(fig_eeg); delete(fig_eeg); end
        if ishandle(fig_chan); delete(fig_chan); end
        delete(gcf);
    end
    function cb_closefalse(hObj, event)
        % invoked by manually closing a panel other than the control panel
        set(gcf, 'visible', 'off')
    end
    function cb_showeeg(hObj, event)
        % invoked by pushing the EEG button on the control panel
        set(fig_eeg, 'visible', 'on');
    end
    function cb_showchan(hObj, event)
        % invoked by pushing the Channels button on the control panel
        set(fig_chan, 'visible', 'on');
    end
    function cb_savevar(hObj, event)
        % invoked by pushing the Save (V) button on the control panel
        varname = get(control_varname, 'string');
        assignin('base',varname, LAN);
    end

    function cb_eegchan(hObj, event)
        % invoked by entering a new set of channels to plot
        str = get(hObj, 'string');
        chansel = eval(['[' str ']']);
        chansel = chansel(chansel>0 & chansel<=LAN.nbchan);
        doplot();
        eeg_chanbuttons();
        chan_labels();
    end
    function cb_eegtime(hObj, event)
        % invoked by entering a new time period or trial to plot
        str = get(hObj, 'string');
        val = eval(['[' str ']']);
        if numel(val) == 2;
            time_start = val(1);
            time_win = val(2);
            if time_win > LAN.time(time_trial,2)
                time_win = LAN.time(time_trial,2);
            end
            if time_start < 0
                time_start = 0;
            end
            if time_start+time_win > LAN.time(time_trial,2)
                time_start = LAN.time(time_trial,2) - time_win;
            end
        else
            disp('EEG: incorrect input')
        end
        doplot();
    end
    function cb_eegnav(hObj, event)
        % invoked by using the navigation buttons on the EEG panel
        tag = get(hObj, 'tag');
        if strcmp(tag, '<')
            if nav_trials
                time_trial = max([time_trial-1,1]);
                time_start = 0;
            else
                time_start = max([time_start-time_win, 0]);
            end
        elseif strcmp(tag, '>')
            if nav_trials
                time_trial = min([time_trial+1,LAN.trials]);
                time_start = 0;
            else
                time_start = min([time_start+time_win, LAN.time(time_trial,2)-time_win]);
            end
            
        elseif strcmp(tag, '@')
            nav_trials = ~nav_trials;
            if nav_trials
                set(control_lnav,'string','<t');
                set(control_rnav,'string','t>');
            else
                set(control_lnav,'string','<');
                set(control_rnav,'string','>');
            end
        end
        set(control_eegtime,'string',num2str([time_start time_win]));
        set(control_eegtrial,'string',num2str(time_trial));
        doplot();
    end
    function cb_eegtrial(hObj, event)
        % invoked by entering a new trial number to plot
        e = eval(get(hObj, 'string'));
        if e > 0 && e <= LAN.trials
            time_trial = e;
            if hil_do
                hil_data_calc();
            end
            if cspec_do
                cspec_data_calc();
            end
        else
            set(hObj, 'string', num2str(time_trial));
        end
        doplot();
    end
    function cb_eegresize(hObj, event)
        % invoked by using the resize controls on the EEG panel
        figure(fig_eeg);
%         subplot('position', subpos_eegA);
%         ylim_aux = get(gca, 'ylim');
        ylim_aux = get(subh_eegA, 'ylim');
        tag = get(hObj, 'tag');
        if strcmp(tag, '+')
            resizefact = resizefact*1.2;
        elseif strcmp(tag, '-')
            resizefact = resizefact/1.2;
        elseif strcmp(tag, 'e')
            resizefact = eval(get(hObj, 'string'));
        end
        
        doplot();
        figure(fig_eeg);
%         subplot('position', subpos_eegA);
%         ylim(ylim_aux);
        set(subh_eegA, 'ylim', ylim_aux);
        
        set(control_resize,'string',num2str(resizefact));
    end
    function cb_chanbutton(hObj, event)
        % invoked by pushing a channel highlight button on the EEG panel
        aux = eval(get(hObj, 'tag'));
        if chanhighlight==aux
            chanhighlight=0;
        else
            chanhighlight=aux;
        end
        
        if hil_do
            hil_data_calc();
        end
        if cspec_do
            cspec_data_calc();
        end
        doplot();
        
    end
    function cb_ctrlts(hObj, event)
        if selplot_ts
            selplot_ts = false;
        else
            if isfield(LAN, 'RT')
                selplot_ts = true;
                doplot();
            else
                errordlg(['No timestamp data found. If your LAN environment'...
                    ' does not include the RT field, try the help site,'...
                    ' linked in the command window']);
                disp(['For help, enter '...
                    'https://bitbucket.org/marcelostockle/lan-toolbox/wiki/Time_stamps'])
            end
        end
    end
    function cb_ctrltsrej(hObj, event)
        win = eval( get(control_rejms, 'string') );
        win = win * LAN.srate / 1000;
        win = floor(win / 2); % half win
        laten = LAN.RT.laten * LAN.srate / 1000;
        for c = 1:length(laten)
            seq = laten(c)-win:laten(c)+win;
            seq = seq( seq>0 & seq<=LAN.pnts(time_trial,1) );
            LAN.selected{time_trial}(seq) = false;
        end
        do_plot();
    end
    function cb_ctrltschan(hObj, event)
        chansel_ts = eval( ['[' get(hObj, 'string') ']'] );
        do_plot();
    end
    function cb_ctrlhilbert(hObj, event)
        % hil_do is later picked up by [cb_chanbutton], recalculating
        % hil_data, and [do_plot] when appropriate
        if hil_do
            hil_do = false;
            set(hObj, 'string', 'Show')
            doplot();
        else
            hil_do = true;
            set(hObj, 'string', 'Hide')
            if chanhighlight~=0
                hil_data_calc();
                doplot();
            else
                disp(['Hilbert data not processed. To calculate and display'...
                ' hilbert data, choose a channel using the toolbar on the left'])
            end
        end
    end
    function cb_ctrlcspec(hObj, event)
        % cspec_do is later picked up by [cb_chanbutton], recalculating
        % cspec_data, and [do_plot] when appropriate
        tag = get(hObj, 'tag');
        str = get(hObj, 'string');
        str = cat(2,'[',str,']');
        if strcmp(tag, 'toggle')
            if cspec_do
                cspec_do = false;
                set(hObj, 'string', 'Show')
                doplot();
            else
                cspec_do = true;
                set(hObj, 'string', 'Hide')
                if chanhighlight~=0
                    cspec_data_calc();
                    doplot();
                else
                    disp(['Continuous spectrogram display unsuccessful.'...
                        ' Choose a channel using the toolbar on the left'])
                end
            end
        elseif strcmp(tag, 'clim')
            arr = eval(str);
            cspec_clim = arr;
            doplot();
        elseif strcmp(tag, 'flim')
            arr = eval(str);
            cspec_flim = arr;
            doplot();
        end
    end
    function cb_selplot(hObj, event)
        % invoked by pushing the smaller panel below on the EEG panel
        xval = get(hObj, 'currentpoint');
        xval = xval(1);
        if selplot_hold
            selplot_hold = false;
            selplot_val = [selplot_val ceil(xval*LAN.srate)];
            selplot_val = sort(selplot_val, 'ascend');
            sel_aux = LAN.selected{time_trial}(selplot_val(1):selplot_val(2));
            if any(~sel_aux)
                LAN.selected{time_trial}(selplot_val(1):selplot_val(2)) = true;
            else
                LAN.selected{time_trial}(selplot_val(1):selplot_val(2)) = false;
            end
            selplot_val = NaN;
            doplot();
        else
            selplot_hold = true;
            selplot_val = ceil(xval*LAN.srate);
        end
    end
    function cb_meants(hObj, event)
        if ~isempty(cspec_data)
            tsm_phasing = get(control_tsm_phasing, 'value');
            tsm_rej = get(control_tsm_rej, 'value');
            tsm_any = get(control_tsm_any, 'value');
            tsm_timemax = get(control_tsm_timemax, 'value');
            str = get(control_tsm_pfreq, 'string');
            tsm_pfreq = eval(['[' str ']']);
            str = get(control_tsm_maxlag, 'string');
            tsm_maxlag = eval(str);
            
            cspec_mean_calc();
%             lfp_mean_calc();
            doplot_mean();
        else
            errordlg(['No spectral data found. Please use the "Continuous'...
                    ' spectrogram" tab to load your data.']);
        end
    end
end
