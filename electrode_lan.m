function LAN = electrode_lan(LAN,electrode,only)
%       <*LAN)<]
%        v.1.2
% LAN = electrode_lan(LAN,electrode,only)
%                           Elemina electrodes
%                           electrode = [1 4 ...]     % numero del electrodo
%                           electrode = {'FP1'}         % nombre del eletrodo
%                           electrode = 'EOG'         % tipo de eletrodo
%
%           if only=true   Concerva solo los electrodos indicados              
% 
% Pablo Billeke

% 13.02.2019 (PB) delete field fixed...
% 02.04.2014 (PB) option only is abled 
% 07.01.2014 (PB) fix bug in references in no iEEG chanlocs
% 16.11.2013 (PB) fix delete of electrodemat_names and references
% 25.06.2013
% 15.06.2011 (PB) add electrode name, or type
% 11.11.2010 (PB) add powspctrm
% 07.08.2010 (PB) fix electrodemat
% 30.06.2010 (PB)
% 07.05.2010 (PB)
% 10.06.2009 (PB)
%
if nargin == 0
    edit electrode_lan.m
    help electrode_lan
    return
end
if nargin == 2
   only = 0; 
end
if nargin == 3
    %if ~(isempty(electrode)||electrode==0)
    %    error(['if exist ''only'' , electrode must be 0 or empty '])
    %end 
end




LAN = lan_check(LAN);

if iscell(LAN)
    cuantos = length(LAN);
    for lan = 1: cuantos
       LAN{lan} = electrode_lan_st(LAN{lan}, electrode,only);
    end
else
    
        if isfield(LAN, 'delete')
            LAN.delete_old = LAN.delete;
            LAN = rmfield(LAN,'delete');
        end
    
        LAN = electrode_lan_st(LAN, electrode,only); 
end

LAN = lan_check(LAN);
end

function LAN = electrode_lan_st(LAN,electrode,only)

if ischar(electrode)|| ischar(only) || iscell(electrode)
    p = 0;
    paso = [];

   for i = 1:LAN.nbchan
       if strcmp(electrode , LAN.chanlocs(i).type)
           p = p+1;
           paso(p) = i;
           disp([' del type ' electrode ' ('   LAN.chanlocs(i).labels     ') '])
       elseif strcmp(electrode , LAN.chanlocs(i).labels)           
           paso = i;
           disp([' del ' electrode])
           break
       elseif iscell(electrode) && ischar(electrode{1})
           for ee = 1:length(electrode)
              if strcmp(electrode{ee} , LAN.chanlocs(i).labels)
                 paso = [paso i] ;
                 disp([' del ' electrode{ee}])
                 break 
              end
           
           end
       end
   end
   electrode = paso;
elseif islogical(electrode)
    electrode = find(electrode);    
end  

electrode = sort(electrode,'descend');
%
if isempty(LAN)
    warning('LAN is empty')
    return
end
%
if only
paso = 1:LAN.nbchan;    
paso(electrode) = [];
electrode=paso;
electrode = sort(electrode,'descend');
end
    

%%%% data
if iscell(LAN.data)
    cuantos = length(LAN.data);
    for lan = 1: cuantos% loop por trail
        if isempty(LAN.data{lan}), continue,end
         LAN.delete.data{lan}(electrode,:) = LAN.data{lan}(electrode,:);
         LAN.data{lan}(electrode,:) = [];
         if isfield(LAN,'row_data')
         %LAN.delete.row_data{lan}(electrode,:) = single(LAN.row_data{lan}(electrode,:));
         LAN.row_data{lan}(electrode,:) = []; 
         end
                    if lan ==1
                    try
                            if isfield(LAN.chanlocs(1), 'electrodemat_names')
                                electrodemat_names= LAN.chanlocs(1).electrodemat_names;
                            end
                            if isfield(LAN.chanlocs(1), 'electrodemat')
                                electrodemat= LAN.chanlocs(1).electrodemat;
                            end                           
                            
                            
                            LAN.chanlocs(electrode) = [];
                    catch
                        disp('No se pudp  arreglar estructura LAN.chanlocs')
                    end
                    try
                    LAN.freq.powspctrm(:,electrode,:) = [];
                    end
                    try
                    LAN.delete.chanlocs(electrode) = LAN.chanlocs(electrode); 
                    end
                                        
                    end
        
 
        
    end%% lan
    LAN.delete.elect = electrode;
else
    
         LAN.delete.data(electrode,:,:) = LAN.data(electrode,:,:);
         LAN.data(electrode,:,:) = [];
                    try
                         LAN.delete.chanlocs(electrode) = LAN.chanlocs(electrode); 
                         LAN.chanlocs(electrode) = [];
                    catch
                        disp('No se pudo  arreglar estructura LAN.chanlocs')
                     end
    
    
    
     
      LAN.delete.elect = electrode;
end

%%% fix LAN.chanlocs.electrodemat and LAN.chanlocs.electrodemat_names

if  isfield(LAN, 'chanlocs') && isfield(LAN.chanlocs(1), 'electrodemat')
    electrodemat = LAN.chanlocs(1).electrodemat;
    try 
        references = LAN.references;
    catch
        references = zeros(size(electrodemat ));
    end

    for elec = electrode
         electrodemat(electrodemat==elec) = NaN;
         electrodemat(electrodemat>elec) = electrodemat(electrodemat>elec) -1 ;
         references(references==elec) = 0;
         references(references>elec) = references(references>elec) -1 ;
    end 
    
    if isfield(LAN.chanlocs(1), 'electrodemat_names')
         borra =  ~any(electrodemat>0,2);
           if any(borra)
              electrodemat(borra,:)=[]; 
              electrodemat_names(borra) = [];
           end
    for e = 1:length(LAN.chanlocs)
        LAN.chanlocs(e).electrodemat_names = electrodemat_names;
    end      
    
    
    % references!!!  Please CHECK ME
        LAN.references=references;
        LAN.references(borra,:) = [];
    end
    
    for e = 1:length(LAN.chanlocs)
        LAN.chanlocs(e).electrodemat = electrodemat;
    end
    
end


%%%% fix LAN.tag
if  isfield(LAN, 'tag')
            LAN.tag.mat(electrode,:,:)= [];
end



%%%% powerspectrum
if isfield(LAN, 'freq')
if isfield(LAN.freq,'powspctrm')
   if isstruct(LAN.freq.powspctrm)
    LAN.delete.powspctrm =  LAN.freq.powspctrm(electrode);
    LAN.freq.powspctrm(electrode)=[]; 
   %LAN.freq.label(electrode)=[];    
   elseif ~isempty(LAN.freq.powspctrm)
    LAN.delete.powspctrm(:,electrode,:) =  LAN.freq.powspctrm(:,electrode,:);
    LAN.freq.powspctrm(:,electrode,:)=[]; 
   %LAN.freq.label(electrode)=[];
   end
end
end
end





