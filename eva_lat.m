function [Num, Laten, Position, Percentil ] = eva_lat(Sujeto, Win_duration, eeg_rate)
%%% evalaute duration of windows
% Sujeto = DR; % number og subject
% Win_duration = 2; % duration of windows
% eeg_rate = 4092; % frecuency of sample


Log = (Sujeto >= (Win_duration * eeg_rate));
NLog = 0;
Position = find(Log);

for i = 1:length(Log)
    NLog = NLog + Log(i);
end
Num = NLog;
Laten = zeros(1,Num);
NLog = 0;
for i = 1:length(Log)
    if Log(i) == 1
       NLog = NLog + Log(i);
       Laten(NLog) = Sujeto(i);
    end
end

Percentil = 100 * Num / length(Sujeto);


