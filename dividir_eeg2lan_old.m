function LAN = dividir_eeg2lan_old(EEG, pr, sg, op, filename1, filename2)
% function dividir
% EEG = datos en estructura eeglab (EEG.data)
%         pero con campo EEG.time segun formato LAN
% pr = epocas de la primera divici??n
% sg = epocas de la segunda divici??n
% op == 1 separa la primera divici??n
%    == 2 separa la segunda divici??n
% e.g.:   EEG = dividir(EEG, 75, 7, 3, 'DC_controles_ica.set', 'DC_objetos_ica.set')
%
%
%

if nargin < 5 && op < 3
    filename1 = 'uno';
    filename2 = 'dos';
end
if nargin < 5 && op == 3
    filename1 = [ 'uno' EEG.filename ];
    filename2 = [ 'dos' EEG.filename ];
end


filename = EEG.filename;
filepath = EEG.filepath;


time = arregla_time(EEG.time,EEG.srate);

pr_time = time(1:pr,:)';
pr_fin = time(pr,3);
sg_time = time(pr+1:pr+sg,:)';
sg_fin = time(pr+1:pr+sg,3);




if op==1 | op==3
    
    %pri = EEG.data(:,1:pr_fin);
    priica = EEG.icaact(:,1:pr_fin);
    %priepoch = EEG.epoch(1:pr);
    LAN{1} = EEG;    
    %LAN{1}.data = pri;
    LAN{1}.icaact = priica;
    %LAN{1}.epoch = priepoch;
    LAN{1}.trials = pr;
    LAN{1}.srate = EEG.srate;
    LAN{1}.time = pr_time'
    LAN{1}.name = [filename1];
    
    % filename1 = 
    %    if op == 3
    %         EEG = pop_saveset( EEG,  'filename', filename1 , 'filepath', filepath);
    %    end
    clear pri priica priepoch;
   
    %LAN = epoch_lan(LAN, condition)
    
end
    
if op==2 | op ==3
%     if op ==3
%     EEG = pop_loadset( 'filename', filename , 'filepath', filepath);
%     end
    %sgi = EEG.data(:,1:sg_fin);
    sgiica = EEG.icaact(:,1:sg_fin);
    %priepoch = EEG.epoch(1:pr);
    LAN{2} = EEG;    
    %LAN{2}.data = sgi;
    LAN{2}.icaact = sgiica;
    %LAN{2}.epoch = priepoch;
    LAN{2}.trials = sg;
    LAN{2}.srate = EEG.srate;
    LAN{2}.time = sg_time'
    LAN{2}.name = [filename2];
    
%     aa = pr+1;
%     bb = pr+sg;
% 
%     seg = EEG.data(:,:,aa:bb);
%     sgica = EEG.icaact(:,:,aa:bb);
%     sgepoch = EEG.epoch(aa:bb);
%     
%     EEG.data = seg;
%     EEG.icaact = sgica;
%     EEG.epoch = sgepoch  ;
%     EEG.trials = sg;
%     
%     if op == 3
%     EEG = pop_saveset( EEG,  'filename', filename2 , 'filepath', filepath);
%     end
end
LAN{1}.event = rmfield(LAN{1}.event, 'latency_aux');
LAN{2}.event = rmfield(LAN{2}.event, 'latency_aux');
LAN = epoch_lan(LAN, 2);

end

function time = arregla_time(time,srate)

time1 = time(:,1)';
time2 = time(:,2)';

for i = 1:length(time1)
    time_fin(i) = fix((time2(i) - time1(i)) * srate)+1;
    if i > 1
        time_fin(i) = time_fin(i) + time_fin(i-1); 
    end
    time3(i) = time_fin(i) - (fix(time2(i)*srate));
end

time(:,3) = time3'; 


end