function filtsign = lan_butter(LAN, min_freq, max_freq, chan, poles)
% lan_butter realiza de forma intuitiva un filtro Butterworth sobre todos
% los canales especificados 'chan' en un entorno LAN, para uno o multiples
% trials, con un rollover constante de 0.5
%
% Los parametros min_xfreq y max_freq pueden ser [] o un número real:
% - Band-pass: min_xfreq = a; max_xfreq = b;
% - Low-pass: min_xfreq = []; max_xfreq = b;
% - High-pass: min_xfreq = a; max_xfreq = [];
%
% filtsign: Arreglo de celdas. Cada celda contiene un trial filtrado en
% todos los canales seleccionados, y el resto de los canales es rellenado
% con ceros.


if nargin < 4
    chan = 1:LAN.nbchan;
end
if nargin < 5
    poles = 2;
end

if isempty(min_freq)
    filt_cfg = 'low';
    freq = max_freq;
elseif isempty(max_freq)
    filt_cfg = 'high';
    freq = min_freq;
else
    filt_cfg = 'bandpass';
    freq = [min_freq max_freq];
end
freq = freq / (LAN.srate / 2);
[z,p,k] = butter(poles,freq,filt_cfg);
[sos,g] = zp2sos(z,p,k);

filtsign = cell(1, LAN.trials);
for i = 1:LAN.trials
    filtsign{i} = zeros(LAN.nbchan, LAN.pnts(i));
    for c = chan
        filtsign{i}(c,:) = filtfilt(sos, g, double(LAN.data{i}(c, :)));
    end
end
