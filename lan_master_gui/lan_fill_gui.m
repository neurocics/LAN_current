function lan_fill_gui(LAN)

% LAN.nbchan = size(LAN.data{1}, 1); % static
% LAN.pnts = size(LAN.data{1}, 2); % static
% LAN.trials = 1; % static
% LAN.name = '';
% LAN.cond = '';
% LAN.group = 'iEEG';
% LAN.srate = 512;
% LAN.unit = 'uV';
figure('name', 'Fill specifications', 'position', [450 400 300 450]);
str = mat2str(LAN.nbchan);
uicontrol('style', 'text', 'string', '# channels : ', 'units', 'norm',...
    'position', [.1 .92 .5 .05], 'horizontalalignment', 'right');
uicontrol('style', 'text', 'string', str, 'units', 'norm',...
    'position', [.7 .92 .2 .05]);
uicontrol('style', 'text', 'string', 'points : ', 'units', 'norm',...
    'position', [.1 .84 .5 .05], 'horizontalalignment', 'right');
if length(LAN.pnts) > 1; str = 'multiple'; else str = mat2str(LAN.pnts); end
uicontrol('style', 'text', 'string', str, 'units', 'norm',...
    'position', [.7 .84 .2 .05]);
uicontrol('style', 'text', 'string', 'trials : ', 'units', 'norm',...
    'position', [.1 .76 .5 .05], 'horizontalalignment', 'right');
str = mat2str(LAN.trials);
uicontrol('style', 'text', 'string', str, 'units', 'norm',...
    'position', [.7 .76 .2 .05]);
uicontrol('style', 'text', 'string', 'name : ', 'units', 'norm',...
    'position', [.1 .68 .5 .05], 'horizontalalignment', 'right');
uicontrol('style', 'edit', 'string', LAN.name, 'units', 'norm',...
    'position', [.7 .68 .2 .05], 'callback', {@cb_fill}, 'tag', 'name');
uicontrol('style', 'text', 'string', 'condition : ', 'units', 'norm',...
    'position', [.1 .60 .5 .05], 'horizontalalignment', 'right');
uicontrol('style', 'edit', 'string', LAN.cond, 'units', 'norm',...
    'position', [.7 .60 .2 .05], 'callback', {@cb_fill}, 'tag', 'cond');
uicontrol('style', 'text', 'string', 'group : ', 'units', 'norm',...
    'position', [.1 .52 .5 .05], 'horizontalalignment', 'right');
uicontrol('style', 'edit', 'string', LAN.group, 'units', 'norm',...
    'position', [.7 .52 .2 .05], 'callback', {@cb_fill}, 'tag', 'group');
uicontrol('style', 'text', 'string', 'sample rate : ', 'units', 'norm',...
    'position', [.1 .44 .5 .05], 'horizontalalignment', 'right');
uicontrol('style', 'edit', 'string', mat2str(LAN.srate), 'units', 'norm',...
    'position', [.7 .44 .2 .05], 'callback', {@cb_fill}, 'tag', 'srate');
uicontrol('style', 'text', 'string', 'units : ', 'units', 'norm',...
    'position', [.1 .36 .5 .05], 'horizontalalignment', 'right');
uicontrol('style', 'edit', 'string', LAN.unit, 'units', 'norm',...
    'position', [.7 .36 .2 .05], 'callback', {@cb_fill}, 'tag', 'unit');
uicontrol('style', 'pushbutton', 'string', 'Done!', 'units', 'norm',...
    'position', [.55 .05 .35 .1], 'callback', {@cb_fill}, 'tag', 'done');

    function cb_fill(hObj, event)
        tag = get(hObj, 'tag');
        str = get(hObj, 'string');
        switch tag
            case 'name'
                evalin('base', ['LAN.name = ' char(39) str char(39) ';']);
            case 'cond'
                evalin('base', ['LAN.cond = ' char(39) str char(39) ';']);
            case 'group'
                evalin('base', ['LAN.group = ' char(39) str char(39) ';']);
            case 'srate'
                evalin('base', ['LAN.srate = ' str ';']);
            case 'unit'
                evalin('base', ['LAN.unit = ' char(39) str char(39) ';']);
            case 'done'
                close();
        end
    end
end