function lan_freq_event_plot(LAN_file,RT_file,freq)
%  <°LAN)<]    
%  v.0.0.8
%  ... en proceso!!!
%
%  Marcelo Stockle
%  Pablo Billeke

%  24.05.2013 
%     - Funciona para cualquier rango de frecuencias
%     - Enfasar condicional
%  07.05.2013
%  09.04.2013
%  05.04.2013
%  02.04.2013
%  17.01.2013
%  16.01.2013 

%------DEPENDENCIES------
% - lan_getdatafile.m
% - lan_smooth.m
% - rt_del.m
% - filter_hilbert.m

%% Figures

LAN = LAN_file;
RT = RT_file;
clear LAN_file RT_file;

randseed = fix(1000*rand());
lag = fix(0.1*LAN.srate);
e = 1;
sum_time_max = false;
all_events = false;
disp_fs = true;
evoked = false;

if nargin < 3
    freq = [];
    disp_fs = false;
end

% electrode position
try 
    pos = LAN.chanlocs(1).locations(e);
catch
    pos = LAN.chanlocs(e).labels;  
end

figure('name',['Sujeto: ' LAN.name ],...
       'CloseRequestFcn',{@close_fig})  % name

uicontrol('style', 'Frame', 'units', 'norm','position', [.71 .4 .28 .17]);
tf_frame.textA = uicontrol('style', 'text','units', 'norm',...
    'position', [.72 .41 .26 .15], 'string', pos);
tf_frame.textB = uicontrol('style', 'text','units', 'norm',...
    'position', [.71 .35 .28 .05], 'string', ' ');

%-------------------------BUTTONS-----------------------------------
tf_frame.btnA = uicontrol('style', 'pushbutton', 'string', 'Save matrix',...
    'units', 'norm', 'position', [.72 .78 .26 .06], 'callback',...
    @cb_save, 'enable', 'off');
uicontrol('style', 'pushbutton', 'string', 'Plot!',...
    'units', 'norm', 'position', [.72 .92 .26 .06], 'callback',...
    {@cb_plotbutton, tf_frame});
uicontrol('style', 'pushbutton', 'string', 'New window',...
    'units', 'norm', 'position', [.72 .85 .26 .06], 'callback',...
    {@cb_newbutton, tf_frame});

%---------------------------EDIT-------------------------------------
uicontrol('style', 'text', 'string', 'Channel: ',...
    'units', 'norm','position', [.72 .65 .18 .05]);
uicontrol('style', 'edit', 'string', num2str(e),...
    'units', 'norm','position', [.9 .65 .08 .05], 'callback',...
    {@cb_changechan, tf_frame});
uicontrol('style', 'text', 'string', 'Lag (msec): ',...
    'units', 'norm','position', [.72 .58 .18 .05]);
uicontrol('style', 'Edit', 'string', num2str(ceil(lag*1000/LAN.srate)),...
    'units', 'norm','position', [.9 .58 .08 .05], 'callback',...
    {@cb_setlag});

%------------------------CHECKBOXES----------------------------------
uicontrol('style', 'checkbox', 'string', 'use time max',...
    'units', 'norm','position', [.72 .24 .25 .05], 'callback',...
    {@cb_checkbox}, 'value', sum_time_max, 'tag', 'tm');
uicontrol('style', 'checkbox', 'string', 'single events set',...
    'units', 'norm','position', [.72 .18 .25 .05], 'callback',...
    {@cb_checkbox}, 'value', all_events, 'tag', 'ses');
if nargin < 3
    uicontrol('style', 'checkbox', 'string', 'display filt signal',...
    'units', 'norm','position', [.72 .12 .25 .05], 'callback',...
    {@cb_checkbox}, 'value', disp_fs, 'enable', 'off', 'tag', 'fs');
else
    uicontrol('style', 'checkbox', 'string', 'display filt signal',...
    'units', 'norm','position', [.72 .12 .25 .05], 'callback',...
    {@cb_checkbox}, 'value', disp_fs, 'enable', 'on', 'tag', 'fs');
end
uicontrol('style', 'checkbox', 'string', 'evoked',...
    'units', 'norm','position', [.72 .06 .25 .05], 'callback',...
    {@cb_checkbox}, 'value', evoked, 'tag', 'ev');


% sub_FUNCTIONS
%---------------------

    function do_plots(data, full)
        if full
            delete(subplot(3, 1, [1 2]));
            subplot(3, 1, [1 2]);
        else
            delete(subplot(3, 4, [1 2 3 5 6 7]));
            subplot(3, 4, [1 2 3 5 6 7]);
        end
        
        if evoked
            nyq = LAN.srate/2;
            len = length(data.RR);
            semilogy((1:len)*nyq/len, data.RR); clear nyq len;
        else
            pcolor((-lag:1:lag)*(1000/LAN.srate),LAN.freq.freq,data.RR);
            shading interp,hold on
            colorbar([.01 .45 .04 .45]);
        end
        
        if full
            subplot(3, 1, 3);
        else
            subplot(3, 4, [9 10 11]);
        end
        
        plot((-lag:1:lag)*(1000/LAN.srate),data.RRs,'k')
        xlim([-lag*1000/LAN.srate lag*1000/LAN.srate])
        if disp_fs
            hold on; plot((-lag:1:lag)*(1000/LAN.srate),data.RRf,'c')
            plot((-lag:1:lag)*(1000/LAN.srate),data.RRe,'c--'); hold off;
        end
        disp('Done!');
    end

%-----------------
    function cb_plotbutton (hObj, event, tf_frame)
        
        disp('Making figures...');
        pow = calc_power(e);
        
        if all_events
            mRT = rt_del(RT,(RT.good==0));
        else
            mRT = rt_del(RT,(RT.est~=e)|(RT.good==0));
        end
        time_max = 0;
        if sum_time_max
            time_max = mRT.OTHER.time_max;
        end
        mRT = fix(mRT.laten*LAN.srate/1000) + time_max;
        
        set(tf_frame.textB, 'string', ['Número de eventos: ' num2str(length(mRT))]);
        set(tf_frame.btnA, 'enable', 'on');
        
        if evoked
            [data.RR, data.RRs, data.RRe, data.RRf] = evoked_TFC(mRT);
        else
            [data.RR, data.RRs, data.RRe, data.RRf] = induced_TFC(mRT, pow);
        end
        save(['cb_changechan' num2str(randseed) '.mat'], 'data');
        disp(['Features stored at cb_changechan' num2str(randseed) '.mat ...'])
        do_plots(data, false);
    end

%-----------------
    function cb_newbutton (hObj, event, tf_frame)
        
        disp('Making figures...');
        data = importdata(['cb_changechan' num2str(randseed) '.mat']);
        figure('name', get(tf_frame.textB, 'string'));
        do_plots(data, true);
    end

%-----------------
    function cb_save (hObj, event)
        [filename, path] = uiputfile('*.mat', 'Save as');
        if ~isempty(filename)
            data = importdata(['cb_changechan' num2str(randseed) '.mat']);
            data = data.RR;
            save(fullfile(path, filename), 'data');
            clear data;
        else
            disp('Aborted');
        end
    end

%-----------------
    function cb_changechan(hObj, event, tf_frame)
        if hObj ~=-1
            e = str2double(get(hObj,'string'));
        end
        if (isfield(LAN, 'chanlocs'))
            if isfield(LAN.chanlocs(1), 'locations')
                pos = LAN.chanlocs(1).locations(e);
            elseif isfield(LAN.chanlocs(e), 'labels')
                pos = LAN.chanlocs(e).labels;
            else
                pos = '';
            end
        else
            pos = '';
        end
        set(tf_frame.textA, 'string', pos);
        
    end

%-----------------
    function cb_setlag (hObj, event)
        lag = eval(get(hObj,'string')) * LAN.srate / 1000;
        lag = fix(lag);
    end


%-----------------
    function cb_checkbox (hObj, event)
        tag = get(hObj, 'tag');
        switch tag
            case 'tm'
                sum_time_max = get(hObj,'value');
            case 'ses'
                all_events = get(hObj,'value');
            case 'fs'
                disp_fs = get(hObj,'value');
                filename = ['cb_changechan' num2str(randseed) '.mat'];
                if exist(filename, 'file')
                    data = importdata(filename);
                    do_plots(data, false);
                end
            case 'ev'
                evoked = get(hObj,'value');
        end
    end

%-----------------
    function pow = calc_power(chan)
        if isstruct(LAN.freq.powspctrm(chan))
            pow = lan_getdatafile(LAN.freq.powspctrm(chan).filename,LAN.freq.powspctrm(chan).path,LAN.freq.powspctrm(chan).trials);
            pow = pow{1};
        else
            pow = LAN.freq.powspctrm(:,chan,:);
        end
        pow = lan_smooth2d(squeeze(pow),5,.4);
        tic
        N = pow;
        N(:,~LAN.selected{1}) = NaN;
        pow = squeeze(normal_z(pow,N));
        clear N
        toc;
    end

%--------------------
    function [RR, RRs, RRe, RRf] = induced_TFC(mRT, pow)
        
        Sig = LAN.data{1}(e,:);
        if ~isempty(freq)
            Ana = filter_hilbert(Sig',LAN.srate,min(freq),max(freq),0)';
            Env = abs(Ana);
            Fase = angle(Ana);
        end
        
        RR=[];RRs = [];RRe=[];RRf=[];
        for r = 1:length(mRT)
            p = mRT(r);
            if (p >lag) && (p< LAN.pnts-lag)
                if ~isempty(freq)
                    % enfasar
                    enf = find(abs(Fase(p-2:p+2))==min(abs(Fase(p-2:p+2))),1,'first');
                    %enf = 6;
                    p = p-3+enf;
                end
                RR = cat(3,pow(:,p-lag:1:p+lag),RR); % se puede usar p ?
                RRs = cat(3,Sig(:,p-lag:p+lag),RRs);
                if ~isempty(freq)
                    RRe = cat(3,Env(:,p-lag:p+lag),RRe);
                    RRf = cat(3,real(Ana(:,p-lag:p+lag)),RRf);
                end
            end
        end
        RR = double(mean_nonan(RR,3));
        RRs = double(mean_nonan(RRs,3));
        RRf = double(mean_nonan(RRf,3));
        RRe = double(mean_nonan(RRe,3));
        RRs = RRs - mean(RRs);
        RRf = RRf - mean(RRf);
        RRe = RRe - mean(RRe);

    end

%--------------------
    function [RR, RRs, RRe, RRf] = evoked_TFC(mRT)
        Sig = LAN.data{1}(e,:);
        if ~isempty(freq)
            Ana = filter_hilbert(Sig', LAN.srate, freq(1), freq(2), 0);
            Fase = angle(Ana);
        end
        
        eSig = zeros(1,2*lag+1);
        for r = 1:length(mRT)
            p = mRT(r);
            if (p >lag) && (p< LAN.pnts-lag)
                if ~isempty(freq)
                    % enfasar
                    enf = find(abs(Fase(p-2:p+2))==min(abs(Fase(p-2:p+2))),1,'first');
                    %enf = 6;
                    p = p-3+enf;
                end
                eSig = eSig + Sig(:,p-lag:p+lag);
            end
        end;
        if ~isempty(freq)
            Ana = filter_hilbert(eSig', LAN.srate, freq(1), freq(2), 0);
            if mod(length(Ana), 2) == 0
                Ana = Ana(2:end);
            end
            RRe = abs(Ana);
            RRf = real(Ana);
        else
            RRe = [];
            RRf = [];
        end
        RR = fft(eSig);
        len = floor( length(RR) / 2);
        RR = abs( RR(1:len) ).^2;
        
        RRs = eSig;
    end
%--------------------
    function close_fig(A,B)
        delete(A)
        if isunix
            system([' rm cb_changechan' num2str(randseed) '.mat']);
        else
            system([' del cb_changechan' num2str(randseed) '.mat']);
        end
        disp(['Delete temporal file:  cb_changechan' num2str(randseed) '.mat ...'])
    end

%%%%%
end

