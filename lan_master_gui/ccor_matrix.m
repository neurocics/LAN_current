function ccor_matrix(LAN_var, RT_var, W, maxlag, time_max)
% ---%DEPENDENCIAS%---
% - rt_del

global LAN;
LAN = LAN_var;

if nargin < 5
    time_max = true;
end

len = length(W);
RT = cell(1,len);
for w = 1:len
    RT{w} = rt_del(RT_var, RT_var.est~=W(w));
    if ~time_max
        RT{w}.OTHER.time_max = zeros(1, length(RT{w}.laten));
    end
end

xcm = cell(len);
raw = zeros(1, LAN.pnts);
for w1 = 1:len
    spikes1 = raw;
    spikes1(RT{w1}.OTHER.time_max + RT{w1}.laten * LAN.srate / 1000) = true;
    for w2 = 1:len
        spikes2 = raw;
        spikes2(RT{w2}.OTHER.time_max + RT{w2}.laten * LAN.srate / 1000) = true;
        [xcm{w1,w2}.cc, xcm{w1,w2}.lags] = xcorr(spikes1, spikes2, maxlag, 'unbiased');
    end
end
clear RT;

figure()

std = 3;
index = [W(1) W(1)];
% xcm_stat = update_xcm_stat();
plot_gauss(index);
plot_matrix();


uicontrol('style', 'edit', 'string', num2str(index),...
    'units', 'norm', 'position', [.85 .4 .11 .05],...
    'callback', {@cb_plot_gauss} , 'tag', 'index');
uicontrol('style', 'text', 'units', 'norm', 'position', [.85 .46 .11 .05],...
    'string', 'index');
uicontrol('style', 'edit', 'string', num2str(std),...
    'units', 'norm', 'position', [.85 .2 .11 .05],...
    'callback', {@cb_plot_matrix} , 'tag', 'std');
uicontrol('style', 'text', 'units', 'norm', 'position', [.85 .26 .11 .05],...
    'string', 'std');

    function cb_plot_matrix(hObj, event)
        std = str2num(get(hObj,'string'))
%         xcm_stat = update_xcm_stat();
        plot_matrix();
        plot_gauss(index);
    end

    function cb_plot_gauss(hObj, event)
        index = str2num(get(hObj,'string'))
        plot_gauss(index);
    end

    function plot_matrix()
        subplot(2, 3, 3);
        colormap(hot);
%         image(xcm_stat);
        set(gca,'xtick',1:len)
        set(gca,'ytick',1:len)
        set(gca,'layer','top');
        colorbar('units', 'norm', 'position', [.942 .622 .025 .3]);
    end

    function plot_gauss(indexes)
        if length(index) ~= 2
            disp('Incorrect input')
        else
            subplot(2, 3, [1 2 4 5]);
            idx1 = find(W==indexes(1),1);
            idx2 = find(W==indexes(2),1);
            lags = xcm{idx1, idx2}.lags;
            cc = xcm{idx1, idx2}.cc;
            handle = area(lags, conv(cc, normpdf(0:0.25:50,26, std),'same'));
            set(handle, 'facecolor', 'green');
            title(['Channels: [' mat2str(indexes(1)) ','...
                mat2str(indexes(2)) ']'])
            xlabel('lag (ms)');
        end
    end

%     function xcm_stat = update_xcm_stat()
%         xcm_stat = zeros(len);
%         
%         for i = 1:len
%             for j = 1:len
%                 if i == j
%                    xcm_stat(i,j) = 0; 
%                 else
%                     x = xcm{i,j}.cc;
%                     ksd = cumsum(x) ./ length(x);
%                     unif = ones(1, length(x));
%                     unif = unif .* (sum(x) / length(x));
%                     unif = cumsum(unif) ./ length(unif);
%                     % Kolmogorov-Smirnov statistic
%                     %xcm_stat(i,j) = max(abs(ksd-unif));
%                     % Cramér von Mises statistic
%                     xcm_stat(i,j) = max(2 * sum(abs(ksd-unif)) / (sum(x) * length(x)), 0);                    
%                 end
%             end
%         end
%         d = diag(ones(1, len)) .* min(xcm_stat(xcm_stat>0));
%         xcm_stat = xcm_stat + d;
%         
%         xcm_stat = xcm_stat-min(min(xcm_stat));
%         xcm_stat = xcm_stat ./ max(max(xcm_stat));
%         xcm_stat = fix(xcm_stat .* 60);
%     end
end