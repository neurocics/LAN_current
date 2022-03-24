function filtsign = lan_fir2(LAN, min_freq, max_freq, chan)
% lan_fir2 realiza de forma intuitiva un filtro FIR sobre todos los canales
% especificados 'chan' en un entorno LAN, para uno o multiples trials, con
% un rollover constante de 0.5

% Los parametros min_xfreq y max_freq pueden ser [] o un número real:
% - Band-pass: min_xfreq = a; max_xfreq = b;
% - Low-pass: min_xfreq = []; max_xfreq = b;
% - High-pass: min_xfreq = a; max_xfreq = [];

% filtsign: Arreglo de celdas. Cada celda contiene un trial filtrado en
% todos los canales seleccionados, y el resto de los canales es rellenado
% con ceros.


ro = min(0.5,mean([ min_freq 0])); % rollover
if ro==0, ro=0.5; end
if nargin < 4
    chan = 1:LAN.nbchan;
end

if isempty(min_freq)
    res_f = [0 max_freq max_freq+ro LAN.srate/2] / (LAN.srate/2);
    res = [1 1 0 0];
elseif isempty(max_freq)
    res_f = [0 min_freq-ro min_freq LAN.srate/2] / (LAN.srate/2);
    res = [0 0 1 1];
else
    res_f = [0 min_freq-ro min_freq max_freq max_freq+ro LAN.srate/2];
    res_f =  res_f / (LAN.srate/2);
    res = [0 0 1 1 0 0];
end



filtsign = cell(1, LAN.trials);
for i = 1:LAN.trials
    
    if isempty(LAN.data{i}), continue,end % escape empty trails!
    
    N = LAN.pnts(i) - (1-rem(LAN.pnts(i), 2));
    filtsign{i} = zeros(LAN.nbchan, N);
    
    F = fir2(N-1,res_f,res); % filter (time)
    xF = abs(fft(F)); % filter (freq)
    for c = chan
        sign = fft(double(LAN.data{i}(c, :)), N, 2);
        sign = sign .* xF;
        sign = ifft(sign);
        filtsign{i}(c,:) = sign;
    end
end