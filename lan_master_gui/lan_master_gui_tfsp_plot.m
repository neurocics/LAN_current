function lan_master_gui_tfsp_plot(LAN_var, mainfig, parent_)

LAN = LAN_var;

if nargin < 2
    mainfig = figure;
end
figure(mainfig)

sp1 = subplot(8,1,[2 3 4], 'parent', parent_);
sp2 = subplot(8,1,[5 6 7], 'parent', parent_);
sp2_queue = false;

chan = 1;
lfp = LAN.data{1}(chan,:);
cfs = lan_cspec_load(LAN, chan);

tparam = [0 1];
ptax = tparam(1)*LAN.srate+(1:tparam(2)*LAN.srate);
lfplim = [min(LAN.data{1}(chan,:)) max(LAN.data{1}(chan,:))];
if lfplim(1)==0 && lfplim(2)==0
    lfplim = [-1 1];
end
lfplim_fact = 1.5;
cax = [0 5];
fax = LAN.freq.freq;
freqind = 1:numel(fax);

cfg_control(1) = uicontrol('style', 'text', 'units', 'norm',...
    'position', [.10 .86 .2 .06], 'string', 'Channel : ',...
    'horizontalalignment', 'right');
cfg_control(2) = uicontrol('style', 'edit', 'units', 'norm',...
    'position', [.31 .86 .06 .06], 'string', '1',...
    'callback', @cb_edit, 'tag', 'ch');
cfg_control(3) = uicontrol('style', 'pushbutton', 'units', 'norm',...
    'position', [.45 .86 .06 .06], 'string', '<',...
    'callback', @cb_edit, 'tag', 't<');
cfg_control(4) = uicontrol('style', 'edit', 'units', 'norm',...
    'position', [.51 .86 .15 .06], 'string', '0 1',...
    'callback', @cb_edit, 'tag', 'te');
cfg_control(5) = uicontrol('style', 'pushbutton', 'units', 'norm',...
    'position', [.66 .86 .06 .06], 'string', '>',...
    'callback', @cb_edit, 'tag', 't>');
cfg_control(6) = uicontrol('style', 'pushbutton', 'units', 'norm',...
    'position', [.93 .70 .06 .06], 'string', '+',...
    'callback', @cb_edit, 'tag', 'a+');
cfg_control(7) = uicontrol('style', 'pushbutton', 'units', 'norm',...
    'position', [.93 .64 .06 .06], 'string', '-',...
    'callback', @cb_edit, 'tag', 'a-');
cfg_control(8) = uicontrol('style', 'edit', 'units', 'norm',...
    'position', [.75 .08 .20 .06], 'string', '0 5',...
    'callback', @cb_edit, 'tag', 'cax');
cfg_control(9) = uicontrol('style', 'text', 'units', 'norm',...
    'position', [.75 .01 .20 .06], 'string', 'Color axis');
cfg_control(10) = uicontrol('style', 'edit', 'units', 'norm',...
    'position', [.50 .08 .20 .06], 'string', num2str([fax(1) fax(end)]),...
    'callback', @cb_edit, 'tag', 'fr');
cfg_control(11) = uicontrol('style', 'text', 'units', 'norm',...
    'position', [.50 .01 .20 .06], 'string', 'Freq. range');
cfg_control(12) = uicontrol('style', 'pushbutton', 'units', 'norm',...
    'position', [.77 .86 .14 .06], 'string', 'Clear',...
    'callback', @cb_edit, 'tag', 'clear');

for a = 1:numel(cfg_control)
    set(cfg_control(a), 'parent', parent_);
end

do_plot()

%     function pow = calc_power(chan)
%         fullpath = cat(2, LAN.freq.powspctrm(chan).path,'/',LAN.freq.powspctrm(chan).filename);
%         if exist(fullpath, 'file') && ~isempty(LAN.freq.powspctrm(chan).filename)
%             % open time-freq file; smooth; transform to z-val
%             pow = lan_getdatafile(LAN.freq.powspctrm(chan).filename,...
%                 LAN.freq.powspctrm(chan).path, LAN.freq.powspctrm(chan).trials);
%             pow = lan_smooth2d(squeeze(pow{1}(:,:,:)),4,.4,3);
%             N = pow;
%             N(:,~LAN.selected{1}) = NaN;
%             pow = squeeze(normal_z(pow,N));
%             clear N;
%         else
%             pow = [];
%         end
%     end

    function cb_edit(hObj, event)
        tag = get(hObj, 'tag');
        lan_master_gui_busyprompt(true, mainfig);
        if strcmp(tag, 't<')
            tparam(1) = max([ tparam(1)-tparam(2), 0 ]);
            ptax = tparam(1)*LAN.srate+(1:tparam(2)*LAN.srate);
            set(cfg_control(4), 'string', num2str(tparam));
            do_plot();
        elseif strcmp(tag, 't>')
            tparam(1) = min([ tparam(1)+tparam(2), LAN.time(2)-tparam(2) ]);
            ptax = tparam(1)*LAN.srate+(1:tparam(2)*LAN.srate);
            set(cfg_control(4), 'string', num2str(tparam));
            do_plot();
        elseif strcmp(tag, 'te')
            tparam = eval(['[' get(hObj,'string') ']']);
            if sum(tparam) > LAN.time(2)
                tparam(1) = LAN.time(2)-tparam(2);
            end
            ptax = tparam(1)*LAN.srate+(1:tparam(2)*LAN.srate);
            set(cfg_control(4), 'string', num2str(tparam));
            do_plot();
        elseif strcmp(tag, 'a+')
            lfplim_fact = lfplim_fact+.1;
            do_plot();
        elseif strcmp(tag, 'a-')
            lfplim_fact = max(.1, lfplim_fact-.1);
            do_plot();
        elseif strcmp(tag, 'cax')
            cax = eval(['[' get(hObj,'string') ']']);
            do_plot();
        elseif strcmp(tag, 'ch')
            chan = eval(get(hObj,'string'));
            lfp = LAN.data{1}(chan,:);
            cfs = lan_cspec_load(LAN, chan);
            lfplim = [min(LAN.data{1}(chan,:)) max(LAN.data{1}(chan,:))];
            if lfplim(1)==0 && lfplim(2)==0
                lfplim = [-1 1];
            end
            do_plot();
        elseif strcmp(tag, 'fr')
            frange = eval(['[' get(hObj,'string') ']']);
            freqind = find(fax >= min(frange) & fax <= max(frange));
            do_plot();
        elseif strcmp(tag, 'clear')
            delete(cfg_control);
            subplot(1,1,1);
            delete(subplot(1,1,1));
        end
        lan_master_gui_busyprompt(false, mainfig);
    end

    function do_plot()
        
        subplot(sp1);
        plot(ptax/LAN.srate, lfp(ptax));
        xlim([0 tparam(2)] + tparam(1));
        ylim(lfplim*lfplim_fact);
        set(sp1, 'ytick', []);
        if isempty(cfs)
            delete(sp2);
            sp2_queue = true;
        else
            if sp2_queue
                sp2 = subplot(8,1,[5 6 7], 'parent', parent_);
            end
            subplot(sp2);
            imagesc(ptax/LAN.srate, fax(freqind), cfs(freqind,ptax));
            colormap(hot);
            set(gca, 'ydir', 'normal')
            colorbar('units', 'norm', 'position', [.92 .22 .05 .28])
            caxis(cax);
        end
    end
end
