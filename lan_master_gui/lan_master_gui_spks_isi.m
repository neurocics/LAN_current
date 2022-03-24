function lan_master_gui_spks_isi(ts, clu)


figure
maxlag = 500;
choice = 1;
bins = 500;

uibg = uibuttongroup('units', 'norm', 'position', [.55 .0 .45 .08]);
uicontrol('style', 'radiobutton', 'string', 'c1',...
    'units', 'norm', 'position', [.1 .1 .2 .5], 'parent', uibg);
uicontrol('style', 'radiobutton', 'string', 'c2',...
    'units', 'norm', 'position', [.4 .1 .2 .5], 'parent', uibg);
uicontrol('style', 'radiobutton', 'string', 'c3',...
    'units', 'norm', 'position', [.7 .1 .2 .5], 'parent', uibg);
set(uibg,'SelectionChangeFcn',@cb_uibg);
uicontrol('style', 'text', 'string', 'maxlag',...
    'units', 'norm', 'position', [.1 .0 .1 .07]);
uicontrol('style', 'edit', 'string', num2str(maxlag),...
    'units', 'norm', 'position', [.22 .0 .08 .07], 'callback', @cb_maxlag);
uicontrol('style', 'text', 'string', 'bins',...
    'units', 'norm', 'position', [.32 .0 .1 .07]);
uicontrol('style', 'edit', 'string', num2str(bins),...
    'units', 'norm', 'position', [.44 .0 .08 .07], 'callback', @cb_bins);
doplotB();

    function doplotB()
        ts1 = ts(clu==choice);

        isi = diff(ts1);
        isi = isi(isi>0 & isi < maxlag);
%         isi = [];
%         for c = 1:length(ts1)
%             auxts = ts1-ts1(c);
%             auxts = auxts(auxts>0 & auxts < maxlag);
%             isi = [isi auxts];
%         end
        n = ceil(maxlag / bins);
        xax = n:n:maxlag;
        xax = xax-n/2;
        hist(isi,xax);
    end

    function cb_maxlag(hObj, event)
        str = get(hObj, 'string');
        maxlag = eval(str);
        doplotB();
    end

    function cb_bins(hObj, event)
        str = get(hObj, 'string');
        bins = eval(str);
        set(hObj, 'string', num2str(bins));
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