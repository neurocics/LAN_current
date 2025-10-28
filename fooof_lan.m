

function LAN = fooof_lan(LAN,cfg)

% PAsar LAN a fieldtrip paso 1

clear datos

for i = 1:LAN.nbchan
    
    datos.label{1,i} =  LAN.chanlocs(i).labels;
    
end

for i = 1:LAN.trials
    
    datos.time{1,i} = linspace(LAN.time(1,1), LAN.time(1,2), size(LAN.data{1, 1},2));
    
end

datos.fsample = LAN.srate;
datos.trial = LAN.data;

datos.trialinfo = ones(LAN.trials, 1);

clear i

%% LAN2fieldtrip fooof
clear fractal original
%     cfg               = [];
%     cfg.foilim        = [1 40];
%     cfg.pad           = 8; %4
%     cfg.tapsmofrq     = 4; %2
cfg.method        = 'mtmfft';
cfg.output        = 'fooof';
fractal = ft_freqanalysis(cfg, datos);
cfg.output        = 'pow';
original = ft_freqanalysis(cfg, datos);


%% FT2LAN fooof

LAN.fooof =   fractal;
LAN.fooof.oripowspctrm = original.powspctrm;


end





