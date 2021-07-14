function lan_master_gui_spks_plot(spikes, clu, xax)

figure

check(1) = uicontrol('style', 'checkbox', 'string', 'c1',...
    'units', 'norm', 'position', [.1 .01 .08 .05], 'value', true,...
    'callback', @cb_checkbox);
check(2) = uicontrol('style', 'checkbox', 'string', 'c2',...
    'units', 'norm', 'position', [.2 .01 .08 .05], 'value', true,...
    'callback', @cb_checkbox);
check(3) = uicontrol('style', 'checkbox', 'string', 'c3',...
    'units', 'norm', 'position', [.3 .01 .08 .05], 'value', false,...
    'callback', @cb_checkbox);
uibg = uibuttongroup('units', 'norm', 'position', [.55 .0 .45 .08]);
uicontrol('style', 'radiobutton', 'string', 'c1',...
    'units', 'norm', 'position', [.1 .1 .2 .5], 'parent', uibg);
uicontrol('style', 'radiobutton', 'string', 'c2',...
    'units', 'norm', 'position', [.4 .1 .2 .5], 'parent', uibg);
uicontrol('style', 'radiobutton', 'string', 'c3',...
    'units', 'norm', 'position', [.7 .1 .2 .5], 'parent', uibg);
set(uibg,'SelectionChangeFcn',@cb_uibg);
doplotA();
doplotB(1);

    function doplotA()
        seq = 1:length(clu);
        
        subplot(1, 2, 1, 'replace'); hold on;
        if get(check(1), 'value'); plot(xax, mean(spikes(seq(clu==1), :), 1), 'b' ); end;
        if get(check(2), 'value'); plot(xax, mean(spikes(seq(clu==2), :), 1), 'r' ); end;
        if get(check(3), 'value'); plot(xax, mean(spikes(seq(clu==3), :), 1), 'k' ); end;
        hold off;
    end

    function doplotB(c)
        subplot(1, 2, 2, 'replace');
        plot(xax, spikes(clu==c, :)', 'b' );
    end

    function cb_checkbox(hObj, event)
        doplotA();
    end

    function cb_uibg(hObj, event)
        str = get(event.NewValue, 'string');
        switch str
            case 'c1'
                doplotB(1);
            case 'c2'
                doplotB(2);
            case 'c3'
                doplotB(3);
        end
    end
end