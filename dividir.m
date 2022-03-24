% function dividir
% EEG = datos en estructura eeglab (EEG.data)
% pr = epocas de la primera divición
% sg = epocas de la segunda divición
% op == 1 separa la primera divición
%    == 2 separa la segunda divición


% e.g.:   EEG = dividir(EEG, 75, 7, 3, 'DC_controles_ica.set', 'DC_objetos_ica.set')

function EEG = dividir(EEG, pr, sg, op, filename1, filename2)
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

if op==1 | op==3
    pri = EEG.data(:,:,1:pr);
    priica = EEG.icaact(:,:,1:pr);
    priepoch = EEG.epoch(1:pr);
    
    
    EEG.data = pri;
    EEG.icaact = priica;
    EEG.epoch = priepoch;
    EEG.trials = pr;
    
   %filename1 = 
   if op == 3
        EEG = pop_saveset( EEG,  'filename', filename1 , 'filepath', filepath);
   end
   clear pri priica priepoch;
   
end
    
if op==2 | op ==3
    if op ==3
    EEG = pop_loadset( 'filename', filename , 'filepath', filepath);
    end
    aa = pr+1;
    bb = pr+sg;

    seg = EEG.data(:,:,aa:bb);
    sgica = EEG.icaact(:,:,aa:bb);
    sgepoch = EEG.epoch(aa:bb);
    
    EEG.data = seg;
    EEG.icaact = sgica;
    EEG.epoch = sgepoch  ;
    EEG.trials = sg;
    
    if op == 3
    EEG = pop_saveset( EEG,  'filename', filename2 , 'filepath', filepath);
    end
end

    