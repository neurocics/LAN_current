function lan_master_gui_sfco(LAN_var, mainfig, parent_)

LAN = LAN_var;

figure(mainfig);
cfg_control(1) = uicontrol('style', 'text', 'units', 'norm',...
    'position', [.04 .92 .6 .05], 'string', 'output var. name : ',...
    'horizontalalignment', 'right');
cfg_control(2) = uicontrol('style', 'edit', 'units', 'norm',...
    'position', [.65 .92 .3 .05], 'string', 'sfc');
cfg_control(3) = uicontrol('style', 'text', 'units', 'norm',...
    'position', [.04 .86 .6 .05], 'string', 'channel : ',...
    'horizontalalignment', 'right');
cfg_control(4) = uicontrol('style', 'edit', 'units', 'norm',...
    'position', [.65 .86 .3 .05], 'string', '1');
cfg_control(5) = uicontrol('style', 'text', 'units', 'norm',...
    'position', [.04 .80 .6 .05], 'string', 'frequency range : ',...
    'horizontalalignment', 'right');
cfg_control(6) = uicontrol('style', 'edit', 'units', 'norm',...
    'position', [.65 .80 .3 .05], 'string', '2 4');
cfg_control(7) = uicontrol('style', 'text', 'units', 'norm',...
    'position', [.04 .74 .6 .05], 'string', 'filter : ',...
    'horizontalalignment', 'right');
cfg_control(8) = uicontrol('style', 'text', 'units', 'norm',...
    'position', [.65 .74 .3 .05], 'string', 'hilbert');
cfg_control(9) = uicontrol('style', 'checkbox', 'units', 'norm',...
    'position', [.04 .68 .6 .05], 'string', 'time reference: peak (onset)',...
    'value', true);
cfg_control(10) = uicontrol('style', 'checkbox', 'units', 'norm',...
    'position', [.04 .62 .6 .05], 'string', 'common events',...
    'value', false);
cfg_control(11) = uicontrol('style', 'checkbox', 'units', 'norm',...
    'position', [.04 .56 .6 .05], 'string', 'ignore rejected',...
    'value', false);
cfg_control(12) = uicontrol('style', 'pushbutton', 'units', 'norm',...
    'position', [.66 .05 .3 .06], 'string', 'Start',...
    'callback', {@cb_done, mainfig}, 'tag', 'done');
cfg_control(13) = uicontrol('style', 'pushbutton', 'units', 'norm',...
    'position', [.35 .05 .3 .06], 'string', 'Help',...
    'callback', {@cb_done, mainfig}, 'tag', 'help');
cfg_control(14) = uicontrol('style', 'pushbutton', 'units', 'norm',...
    'position', [.04 .05 .3 .06], 'string', 'Cancel',...
    'callback', {@cb_done, mainfig}, 'tag', 'cancel');

for a = 1:numel(cfg_control)
    set(cfg_control(a), 'parent', parent_);
end

if ~isfield(LAN, 'RT')
    msgbox('No events (LAN.RT) detected', 'Warning', 'help');
end
if (length(LAN.data) > 1 && ~iscell(LAN.RT)) || (iscell(LAN.RT) && length(LAN.data) ~= length(LAN.RT))
    msgbox('Use unsegmented signals for time-frequency plots', 'Warning', 'help');
end

    function cb_done(hObj, event, mainfig)
        tag = get(hObj, 'tag');
        if strcmp(tag, 'done')
            chan = eval(get(cfg_control(4), 'string'));
            if length(chan) == 1
                freq = eval(['[' get(cfg_control(6), 'string') ']']);
                if length(freq) == 2
                    lan_master_gui_busyprompt(true, mainfig);
                    if iscell(LAN.RT)
                        sfc = struct('indexes', [], 'phase', [], 'power', []);
                        for c = 1:length(LAN.RT)
                            aux = do_sfc(LAN.RT{c}, LAN.data{c}, LAN.srate, freq, chan);
                            sfc.indexes = [sfc.indexes aux.indexes];
                            sfc.phase = [sfc.phase aux.phase];
                            sfc.power = [sfc.power aux.power];
                        end
                    else
                        sfc = do_sfc(LAN.RT, LAN.data{1}, LAN.srate, freq, chan);
                    end
                    if exist('circ_rtest', 'file')
                        [sfc.P, sfc.Z] = circ_rtest(sfc.phase);
                    else
                        disp(['In order to get circular statistics estimations, '...
                            'please install Circular Statistics Toolbox']);
                        disp(['http://www.mathworks.com/matlabcentral/fileexchange/'...
                            '10676-circular-statistics-toolbox-directional-statistics'])
                    end
                    
                    varname = get(cfg_control(2), 'string');
                    assignin('base', varname, sfc);
                    plot_sfc(sfc);
                    lan_master_gui_busyprompt(false, mainfig);
                    delete(cfg_control);
                else
                    msgbox('Enter a valid frequency range.','Error: ','error');
                end
            else
                msgbox('Choose one and only one channel.','Error: ','error');
            end
        elseif strcmp(tag, 'help')
            web('https://bitbucket.org/marcelostockle/lan-toolbox/wiki/Spike-field_coherence', '-browser');
        else
            delete(cfg_control);
        end
    end

    function sfc = do_sfc(RT, data, srate, freq, chan)
        if ~get(cfg_control(9), 'value') % don't use time max
            RT.OTHER.time_max = zeros(1, length(RT.laten));
        end
        if ~get(cfg_control(10), 'value') % particular events
            RT = rt_del(RT, RT.est~=chan);
        end
        if get(cfg_control(11), 'value')
            RT = rt_del(RT, ~RT.good);
        end
        
        if size(data,1) == LAN.nbchan
            data = data(chan,:);
        else
            data = data(:,chan);
        end
        sfc = lan_spkfieldcoh(data', RT.laten/1000+RT.OTHER.time_max/srate, freq, srate);
    end

    function plot_sfc(sfc)
        subplot(1, 4, [2 3 4]);
        rose(sfc.phase);
        if ~isempty(sfc.phase)
            if exist('circ_rtest', 'file')
                xlabel(['p = ' mat2str(sfc.P, 3) '. z = ' mat2str(sfc.Z, 3)], 'fontweight', 'bold');
            end
        end
    end
end
