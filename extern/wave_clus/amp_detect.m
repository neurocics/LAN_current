function [spikes,thr,index] = amp_detect(x,cfg, do_filter)
% Detect spikes with amplitude thresholding. Uses median estimation.
% Detection is done with filters set by fmin_detect and fmax_detect. Spikes
% are stored for sorting using fmin_sort and fmax_sort. This trick can
% eliminate noise in the detection but keeps the spikes shapes for sorting.
%
% ***************DEPENDENCIES***************
% - ellip (Digital Filters Toolbox)
% - int_spikes (interpolation)

if size(x,1) > 1
    ref = cfg.ref;
    
    N = size(x,1);
    spikes = [];
    thr = zeros(N,1);
    index = [];
    for c = 1:N
        [aux1,thr(c),aux3] = amp_detect(x(c,:), cfg, do_filter);
        spikes = [spikes; aux1];
        aux3 = [aux3; c*ones(1, length(aux3))];
        index = [index aux3];
    end
    [~, ind] = sort( index(1,:) );
    index = index(:,ind);
    spikes = spikes(ind,:);
    re = diff(index(1,:)) < ref/2;
    disp([num2str(sum(re)) ' ocurrences rejected'])
    index = index(:, ~re);
    spikes = spikes(~re, :);
else
    if nargin < 3
        do_filter = true;
    end
    
    sr=cfg.sr;
    w_pre=cfg.w_pre;
    w_post=cfg.w_post;
    ref=cfg.ref;
    detect = cfg.detection;
    stdmin = cfg.stdmin;
    stdmax = cfg.stdmax;
    fmin = cfg.fmin;
    fmax = cfg.fmax;
    interpolation = cfg.interpolation;
    
    % HIGH-PASS FILTER OF THE DATA
    if do_filter
        xf=zeros(length(x),1);
        [b,a]=ellip(2,0.1,40,[fmin fmax]*2/sr);
        xf=filtfilt(b,a,double(x));
        clear x;
    else
        xf = x;
        clear x;
    end
    
    noise_std = median(abs(xf))/0.6745;
    thr = stdmin * noise_std;
    thrmax = stdmax * noise_std;
    
    switch detect
        case 'pos'
            nspk = 0;
            xaux = find(xf(w_pre+2:end-w_post-2) > thr) +w_pre+1;
            xaux = xaux( xaux + floor(ref/2)-1 <= numel(xf) );
            xaux0 = 0;
            for i=1:length(xaux)
                if xaux(i) >= xaux0 + ref
                    [maxi iaux]=max((xf(xaux(i):xaux(i)+floor(ref/2)-1)));    %introduces alignment
                    nspk = nspk + 1;
                    index(nspk) = iaux + xaux(i) -1;
                    xaux0 = index(nspk);
                end
            end
        case 'neg'
            nspk = 0;
            xaux = find(xf(w_pre+2:end-w_post-2) < -thr) +w_pre+1;
            xaux = xaux( xaux + floor(ref/2)-1 <= numel(xf) );
            xaux0 = 0;
            for i=1:length(xaux)
                if xaux(i) >= xaux0 + ref
                    [maxi iaux]=min((xf(xaux(i):xaux(i)+floor(ref/2)-1)));    %introduces alignment
                    nspk = nspk + 1;
                    index(nspk) = iaux + xaux(i) -1;
                    xaux0 = index(nspk);
                end
            end
        case 'both'
            nspk = 0;
            xaux = find(abs(xf(w_pre+2:end-w_post-2)) > thr) +w_pre+1;
            xaux = xaux( xaux + floor(ref/2)-1 <= numel(xf) );
            xaux0 = 0;
            for i=1:length(xaux)
                if xaux(i) >= xaux0 + ref
                    %                 [maxi iaux]=max(abs(xf(xaux(i):xaux(i)+floor(ref/2)-1)));    %introduces alignment
                    [maxi iaux]=min(xf(xaux(i):xaux(i)+floor(ref/2)-1));    %introduces alignment
                    nspk = nspk + 1;
                    index(nspk) = iaux + xaux(i) -1;
                    xaux0 = index(nspk);
                end
            end
    end
    
    
    % SPIKE STORING (with or without interpolation)
    ls=w_pre+w_post;
    spikes=zeros(nspk,ls+4);
    xf=[xf zeros(1,w_post)];
    for i=1:nspk                          %Eliminates artifacts
        if max(abs( xf(index(i)-w_pre:index(i)+w_post) )) < thrmax
            spikes(i,:)=xf(index(i)-w_pre-1:index(i)+w_post+2);
        end
    end
    aux = find(spikes(:,w_pre)==0);       %erases indexes that were artifacts
    spikes(aux,:)=[];
    index(aux)=[];
    
    switch interpolation
        case 'n'
            spikes(:,end-1:end)=[];       %eliminates borders that were introduced for interpolation
            spikes(:,1:2)=[];
        case 'y'
            %Does interpolation
            spikes = int_spikes(spikes,cfg);
    end
end
