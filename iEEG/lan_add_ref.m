function LAN =  lan_add_ref(LAN,references,chanlocs)
% <*LAN)<] toolbox
% v.0.0.1
% Read coordinates for iEEG electrodes


% 09.10.2012


if nargin == 1
    realk= [];
   [FileName,PathName,FilterIndex] = uigetfile({'*.reflan','ref-file';},'open ref - file','LAN.reflan');
   if isequal(FileName,0) || isequal(PathName,0)
                    disp('User selected Cancel')
                else                    
                    disp(['open ',fullfile(PathName,FileName)])
                    fprintf('Please wait ...')
                    load(fullfile(PathName,FileName),'-mat')
                     LAN.chanlocs= chanlocs; 
                     LAN.references= references;
                    %nameLAN = choise_var(fullfile(PathName,FileName));
                    %assignin('base','nameLAN_tempLAN',nameLAN);
                    %evalin('base',[ ' load(  ''' PathName FileName ''' , ''' nameLAN ''' )' ]);
                    %close(menu)
                    %evalin('base',[ 'lantoolbox( ' nameLAN ' )' ]);
                    %clear
                    fprintf([ '  ok  \n'])
                end           
else
 LAN.references= references;    
try
    LAN.chanlocs= chanlocs;  
end
    
end



LAN = ap_ref(LAN);


end
    function LAN = ap_ref(LAN)
        
        if isfield(LAN,'row_data');
            row_data = LAN.row_data{1};
        else
            LAN.row_data = LAN.data;
            row_data = LAN.data{1};
        end
        
        data = row_data;
        
        for e = 1:LAN.nbchan;
            ind = LAN.references(LAN.chanlocs(1).electrodemat==e);
            if ind >0
            data(e,:) = row_data(e,:) - row_data(ind,:);
            elseif ind <0
            data(e,:) = 0;
            end
        end
        
        LAN.data = {data};
        clear data row_data
    end