function lan_master_gui_spks_auto(ts, clu)

figure
maxlag = 300;
choice = 1;
bin = 3;

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
uicontrol('style', 'text', 'string', 'bin',...
    'units', 'norm', 'position', [.32 .0 .1 .07]);
uicontrol('style', 'edit', 'string', num2str(bin),...
    'units', 'norm', 'position', [.44 .0 .08 .07], 'callback', @cb_bin);
doplotB();

    function doplotB()
%         [c,lags] = xcorr(ts(clu==choice),maxlag,'coef');
        [c,lags] = autocorr_manual(ts(clu==choice),maxlag,bin);
        stem(lags, c,'fill','.');
%         ylim([0 1])
        set(gca,'ytick',[])
    end
    function [cc,lags] = autocorr_manual(ts,maxlag,bin)
        ts = ceil(ts);
        cc = zeros(1, 2*maxlag+1);
        for c = 1:length(ts)
            A = ts(c)-ts;
            A = A( A<=maxlag & A>=-maxlag ) + maxlag + 1;
            cc(A) = cc(A)+1;
        end
        phase = (length(cc)+1) / 2; % middle point
        cc(phase) = 0;
        phase = phase - (bin-1)/2; % middle point at the bin's center
        for c = bin:length(cc)
            aux = c - mod(c-phase,bin);
            if aux ~= c
                cc(aux) = cc(aux) + cc(c);
                cc(c) = 0;
            end
        end
        cc(1:bin-1) = 0;
        % centrar
        aux = (bin-1)/2;
        cc(1:end-aux) = cc(1+aux:end);
        lags = -maxlag:maxlag;
    end

    function cb_maxlag(hObj, event)
        str = get(hObj, 'string');
        maxlag = eval(str);
        doplotB();
    end

    function cb_bin(hObj, event)
        str = get(hObj, 'string');
        bin = eval(str);
        bin = bin + (rem(bin,2)-1);
        set(hObj, 'string', num2str(bin));
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