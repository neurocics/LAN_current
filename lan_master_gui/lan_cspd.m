function [f, xsp] = lan_cspd(LAN, chn1, chn2, twin, nomean)

L = max(LAN.pnts);
if nargin < 5
    nomean = false;
    if nargin < 4
        twin = hann(L);
    end
end

if LAN.trials == 1
    disp('Se requiere señales segmentadas')
    f = [];
    xsp = [];
else
    NFFT = 2^nextpow2(L);
    f = LAN.srate/2 * linspace(0,1,NFFT/2);
    
    if nomean; xsp = zeros(LAN.trials, NFFT);
    else xsp = zeros(1, NFFT); end
    for c = 1:LAN.trials
        signA = LAN.data{c}(chn1,:).*twin';
        signB = LAN.data{c}(chn2,:).*twin';
        xsignA = fft(signA, NFFT) / L;
        xsignB = fft(signB, NFFT) / L;
        xx = xsignA.*conj(xsignB);
        if nomean; xsp(c,:) = xx;
        else xsp = xsp + xx; end
    end
    if ~nomean; xsp = xsp ./ LAN.trials; end
end

