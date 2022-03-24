function [f, xsp] = lan_cspd_mt(LAN, chn1, chn2, tapers, nomean)
%***************DEPENDENCIES***************
% - mtfftc (chronux toolbox)
% - dpsschk (chronux toolbox)

if nargin < 5
    nomean = false;
end

if LAN.trials == 1
    disp('Se requiere señales segmentadas')
    f = [];
    xsp = [];
else
    N = LAN.pnts(1);
    NFFT = max(2^(nextpow2(N)),N);
    f = LAN.srate/2 * linspace(0,1,NFFT/2);
    tapers = dpsschk(tapers,N,LAN.srate);
    
    if nomean; xsp = zeros(LAN.trials, NFFT);
    else xsp = zeros(1, NFFT); end
    for c = 1:LAN.trials
        xsignA = mtfftc(LAN.data{c}(chn1,:),tapers,NFFT,LAN.srate);
        xsignB = mtfftc(LAN.data{c}(chn2,:),tapers,NFFT,LAN.srate);
        xx = mean(xsignA.*conj(xsignB), 2)';
        if nomean; xsp(c,:) = xx;
        else xsp = xsp + xx; end
    end
    if ~nomean; xsp = xsp ./ LAN.trials; end
end

