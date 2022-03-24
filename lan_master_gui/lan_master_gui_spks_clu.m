function lan_master_gui_spks_clu(spikes, clu)


figure
choice = 1;
dimx = 1;
dimy = 2;

ccfg = struct('feature', 'wav', 'scales', 4, 'inputs', 10);
inspk = wave_features(spikes, ccfg);

uicontrol('style', 'text', 'string', 'dim x',...
    'units', 'norm', 'position', [.1 .0 .1 .07]);
uicontrol('style', 'edit', 'string', num2str(dimx),...
    'units', 'norm', 'position', [.22 .0 .08 .07], 'callback', @cb_dimx);
uicontrol('style', 'text', 'string', 'dim y',...
    'units', 'norm', 'position', [.32 .0 .1 .07]);
uicontrol('style', 'edit', 'string', num2str(dimy),...
    'units', 'norm', 'position', [.44 .0 .08 .07], 'callback', @cb_dimy);
doplotB();

    function doplotB()
        plot(inspk(clu==1,dimx), inspk(clu==1,dimy), '.'); hold on
        plot(inspk(clu==2,dimx), inspk(clu==2,dimy), 'r.'); hold off
    end

    function cb_dimx(hObj, event)
        val = eval(get(hObj, 'string'));
        if val > 0 && val <= size(inspk,2) 
            dimx = val;
        end
        doplotB();
    end

    function cb_dimy(hObj, event)
        val = eval(get(hObj, 'string'));
        if val > 0 && val <= size(inspk,2) 
            dimy = val;
        end
        doplotB();
    end

    function cb_uibg(hObj, event)
        str = get(event.NewValue, 'string');
        switch str
            case 'c1'
                choice = 1;
            case 'c2'
                choice = 2;
            case 'c3'
                choice = 3;
        end
        doplotB();
    end

end