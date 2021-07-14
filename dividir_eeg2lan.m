
function LAN = dividir_eeg2lan(EEG, epoch, name)
% function dividir
% v 2.0
% 18.11.2009
%
% v.1 en dividir_eeg2lan_old.m
%
% EEG   =  datos en estructura eeglab (EEG.data)
%          pero con campo EEG.time segun formato LAN
% epoch =  matriz con numero 
% name  =  celda con strig con los nombre de 
% e.g.:   EEG = dividir(EEG, [75 7],[{ 'DC_controles_ica'},{ 'DC_objetos_ica'}])
%
%
%
if nargin == 0
    edit dividir_eeg2lan
    help dividir_eeg2lan
    return
end



if iscell(EEG.data) %&& size(EEG.data,3)
    data = cat(3,EEG.data{:});
    EEG.data = data;
end

lar = length(epoch);
if sum(epoch) ~= size(EEG.data,3)
    error('number of epochs and  number of trails is diferent')
end
if nargin < 3
    for i = 1:lar
        name{i} = [ num2str(i) ' - '  EEG.filename ];
    end
end
try
filename = EEG.filename; end
try
filepath = EEG.filepath; end


time = arregla_time(EEG.time,EEG.srate);
time;
n_time{1} = time(1:epoch(1),:)';
n_fin{1} = time(epoch(1),3);
for i = 2:lar
    n_time{i} = time((epoch(i-1) + 1):(epoch(i-1) +epoch(i)),:)';
    n_fin{i} = time((epoch(i-1) +epoch(i)),3);
end


%pr_fin = time(pr,3);

%sg_fin = time(pr+1:pr+sg,3);




%if op==1 | op==3
    %for i = 1:lar
    pri = EEG.data(:,:,1:epoch(1));
try    
    priica = EEG.icaact(:,:,1:epoch(1));%(:,1:n_fin{1});
    LAN{1}.icaact = priica;
end
    %priepoch = EEG.epoch(1:pr);
    LAN{1} = EEG;    
    LAN{1}.data = pri;
    
    %LAN{1}.epoch = priepoch;
    LAN{1}.trials = epoch(1);
    LAN{1}.srate = EEG.srate;
    LAN{1}.time = n_time{1}';
    try
        LAN{1}.name = EEG.name;
        catch
        LAN{1}.name = name{1};   
    end
    LAN{1}.cond = name{1};
    
    % filename1 = 
    %    if op == 3
    %         EEG = pop_saveset( EEG,  'filename', filename1 , 'filepath', filepath);
    %    end
    clear pri priica priepoch;
   
    %LAN = epoch_lan(LAN, condition)
    
%end
    
%if op==2 | op ==3
ini = 0;
for i = 2:length(epoch)

%     if op ==3
%     EEG = pop_loadset( 'filename', filename , 'filepath', filepath);
%     end
    ini = ini + epoch(i-1);
    sgi = EEG.data(:,:,ini+1:ini+epoch(i));
try
    sgiica = EEG.icaact(:,:,ini+1:ini+epoch(i));%(:,n_fin{i-1}:n_fin{i});
    LAN{i}.icaact = sgiica;
end%priepoch = EEG.epoch(1:pr);
    LAN{i} = EEG;    
    LAN{i}.data = sgi;
    
    %LAN{i}.epoch = priepoch;
    LAN{i}.trials = epoch(i);
    LAN{i}.srate = EEG.srate;
    LAN{i}.time = n_time{i}';
        try
        LAN{i}.name = EEG.name;
        catch
        LAN{i}.name = name{i};   
        end
    LAN{i}.cond = name{i};
    
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

 
for i=1:lar
try
    LAN{i}.event = rmfield(LAN{i}.event, 'latency_aux');
end   
end

if size(LAN{1}.data,3) > 1;
   LAN = mat2cell_lan(LAN);
else
LAN = epoch_lan(LAN, 2);
end
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