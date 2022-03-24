function LAN = lan_load_ref(LAN,REF)

if nargin ==1
    
             [FileName,PathName,FilterIndex] = uigetfile({'*.lanref','lan ref-file'; '*.mat','MATLAB mat'},'open lan ref - file','LAN.lanref');
                if isequal(FileName,0) || isequal(PathName,0)
                    disp('User selected Cancel')
                else                    
                    disp(['load ',fullfile(PathName,FileName)])
                    fprintf('Please wait ...')
                    
                    load(fullfile(PathName,FileName),'references','chanlocs','-mat')
                    REF = references;
                    %LAN.references = ref;
                    %LAN.chanlocs = chanlocs;
                    %LAN = ap_ref(LAN);
                    %assignin('base',nameLAN,LAN);
                    %delete(h)                   
                    %evalin('base', [ ' lan_setref_micromed( ' nameLAN ')' ])
                    fprintf([ '  ok  \n'])%clear all
                end  
end
if isstr(REF)
                    disp(['load ', REF])
                    fprintf('Please wait ...')
        load(REF,'references','chanlocs','-mat')
        REF = references;
    
end


LAN.references = REF;


        
        for t=1:LAN.trials;
        if isfield(LAN,'row_data');
            row_data = LAN.row_data{t};
        else
            LAN.row_data = LAN.data;
            row_data = LAN.data{t};
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
        
        LAN.data{t} = data;
        end
        clear data row_data
        
        
    end