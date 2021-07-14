function timefreq_1level(LAN,cfg)
% LAN trabajando
% v.0.0.0
%

%

ntype = getcfg(cfg,'type','glm');
ncond = getcfg(cfg,'cond','all')

switch ntype
    case 'glm'
    if iscell(LAN)
       if any(isnumeric(ncond))
          LAN = LAN(ncond);
       end 
       for lan = 1:length(LAN)
          if lan == 1
              Nc = ones(1,LAN{lan}.trials);
              if isstruct(LAN{lan}.freq.powspctrm)
                  iffile = true;
                  paso = lan_getdatafile(LAN{lan}.freq.powspctrm.filename,...
                                         LAN{lan}.freq.powspctrm.path,...
                                         LAN{lan}.freq.powspctrm.trials);
                  data = cat(4,paso{:});
              elseif iscell(LAN{lan}.freq.powspctrm)
                  iffile = false;
              data = cat(4,LAN{lan}.freq.powspctrm{:});
              else
                  error('you need the information by trials!!!')
              end
          else
              Nc = cat(2,Nc,ones(1,LAN{lan}.trials)*lan);
              if iffile
                 paso = lan_getdatafile(LAN{lan}.freq.powspctrm.filename,...
                                         LAN{lan}.freq.powspctrm.path,...
                                         LAN{lan}.freq.powspctrm.trials);
              data = cat(4,data,cat(4,paso{:}));
              clear paso
              else
              data = cat(4,data,cat(4,LAN{lan}.freq.powspctrm{:}));
              end
          end
       end
       
    end
    
    regresors = getcfg(cfg,'regresors','cond');
    if ischar(regresors)
        regresors = {regresors};
    end
    for nr = 1:length()
    
    end
    
    
end
end

% names of file
%                     v_fn{g,c,s} = LAN{c}.freq.powspctrm.filename;     
%                     v_pn{g,c,s} = LAN{c}.freq.powspctrm.path;  
%                     v_vn_mean{g,c,s} = LAN{c}.freq.powspctrm.mean;
%                     v_vn_trials{g,c,s} = LAN{c}.freq.powspctrm.trials;
%                     % data
%                     try
%                             catch % por cambios de path desde la creacion del archivo
%                         pasoi = findstr(filenameA,'/');
%                         pasoi = pasoi(end)-1;
%                         paso = lan_getdatafile(v_fn{g,c,s},filenameA(1:pasoi),v_vn_mean{g,c,s});
%                         v_pn{g,c,s} = filenameA(1:pasoi);
%                         end
%                     v_freq{g,c}(:,:,:,s) = paso(fr,:,:);    
%                     clear paso*