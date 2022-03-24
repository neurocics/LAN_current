function [RR, RRs, RRe, RRf, RRlg] = induced_TFC(Sig, mRT, power, freq)

if nargin > 3
    Ana = filter_hilbert(Sig',LAN.srate,min(freq),max(freq),0)';
    Env = abs(Ana);
    Fase = angle(Ana);
    Log = abs(real(Ana));
    [b,a] = butter(2,20/(LAN.srate/2));
    Log = filtfilt(b,a,double(Log));
end

RR=[];RRs = [];RRe=[];RRf=[];RRlg=[];
for r = 1:length(mRT)
    p = mRT(r);
    if (p >lag) && (p< LAN.pnts-lag)
        if nargin > 3
            % enfasar
            enf = find(abs(Fase(p-2:p+2))==min(abs(Fase(p-2:p+2))),1,'first');
            %enf = 6;
            p = p-3+enf;
        end
        RR = cat(3,power(:,p-lag:1:p+lag),RR); % se puede usar p ?
        RRs = cat(3,Sig(:,p-lag:p+lag),RRs);
        if nargin > 3
            RRe = cat(3,Env(:,p-lag:p+lag),RRe);
            RRlg = cat(3,Log(:,p-lag:p+lag),RRlg);
            RRf = cat(3,real(Ana(:,p-lag:p+lag)),RRf);
        end
    end
end
RRs = double(mean_nonan(data.RRs,3));
RRf = double(mean_nonan(data.RRf,3));
RRe = double(mean_nonan(data.RRe,3));
RRs = RRs - mean(RRs);
RRf = RRf - mean(RRf);
RRe = RRe - mean(RRe);