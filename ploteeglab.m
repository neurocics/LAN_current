function ploteeglab(LAN, marca)
% v.0.0.1
% 
% 
% Herramienta para graficar formato LAN
% Usando EEGLAB
% 
% 
% 
% 
%        7.4.2009


if nargin < 2
    marca = [];
end

    EEG = LAN;
    if iscell(LAN.data)
        try 
            a = cat(3,EEG.data{:});
            epo = 1;
            EEG.trials = length(EEG.data);
        catch
            epo = 0;
            a = cell2mat(LAN.data);
            EEG.trials = 1;
        end
            
    
    EEG = rmfield(EEG,'data');
    EEG.data = a;
    clear a,
    end
    [ch time trial ] = size(EEG.data);
    EEG.nbchan = ch;
    EEG.reject = [];
    EEG.trials = 1;
    EEG.chanlocs = [];
    EEG.xmin = 0;
    if epo == 1
       EEG.xmax = fix(length(EEG.data)/EEG.srate);
 
    else
         EEG.xmax = fix(length(EEG.data)/EEG.srate);
    end
    
    if ~isempty(marca)
       type = cell2mat({EEG.event.type});
       latency = cell2mat({EEG.event.latency});
       duration = cell2mat({EEG.event.duration});
       cont = 1;
       for i =1:length(type)
           if type(i) == marca;
              type(i) = 1000 + cont;
              cont = cont +1;
           end
       end
        levent = length(type);
        EEG.event = [];

        for i=1:levent
           EEG.event(i).type    = type(i);
           EEG.event(i).duration = duration(i);
           EEG.event(i).latency = latency(i);
        end
       
        
    end
    
    a = pop_eegplot(EEG,1,1,1);
    disp(a);
end
