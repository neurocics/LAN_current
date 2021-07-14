function RR = lan_tfmatrix(LAN, RT, chan, lag)
% args
% * lag in miliseconds
if nargin < 2
    RR = [];
    return;
end
if nargin < 3
    chan = 1:LAN.nbchan;
end
if nargin < 4
    lag = 200;
end
lag = ceil(lag*LAN.srate/1000); % lag ms -> points

if iscell(RT)
    len = length(RT);
else
    len = 1;
end
RR = cell(len, 1);
pow = calc_power(chan);
for i = 1:len
    if iscell(RT),
        mRT = rt_del(RT{i}, RT{i}.est~=chan | ~RT{i}.good);
    else
        mRT = rt_del(RT, RT.est~=chan | ~RT.good);
    end
    mRT = fix(mRT.laten*LAN.srate/1000) + mRT.OTHER.time_max;
    
    for r = 1:length(mRT)
        p = mRT(r);
        if (p >lag) && (p< LAN.pnts-lag)
            RR{i} = cat(3, pow(:,p-lag:1:p+lag), RR{i});
        end
    end
%     RR{i} = double(mean_nonan(RR{i},3));
end
if length(RR) == 1
    RR = RR{1};
end

    function pow = calc_power(chan)
        % open time-freq file; smooth; transform to z-val
        pow = lan_getdatafile(LAN.freq.powspctrm(chan).filename,...
            LAN.freq.powspctrm(chan).path, LAN.freq.powspctrm(chan).trials);
        pow = lan_smooth2d(squeeze(pow{1}(:,:,:)),4,.4,3);
        N = pow;
        N(:,~LAN.selected{1}) = NaN;
        pow = squeeze(normal_z(pow,N));
        clear N
    end

end