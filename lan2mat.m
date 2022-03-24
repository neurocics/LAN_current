function lan2mat(cfg)
% v.0.0.1
%
% breve funcion que exporta trials de cada condicion por sujeto. 
% Tambien elimina electrodos
%
%  cfg.subject    % Deben por empezar con letras y no numeros
%  cfg.cond        % Deben por empezar con letras y no numeros
%  cfg.indx
%  cfg.delelectrode
%
% Francisco Zamorano
%
% 01.02.2011

if nargin == 0
	help lan2mat
	if strcmp(lanversion('t'),'devel')
		edit lan2mat
	end
end

%
%%% Sujetos
try
	SSuj = cfg.subject;
catch
	error(['You must defined the subject names'])
end
% SSuj = {'PH','JB','FC','EP','AP','TO','DR','RH','SS','CO'};%	
%%% y condiciones	 
try
	CCond = cfg.cond;
catch
	error(['You must defined the subject names'])
end
%CCond = {'slow_go','fast_go','slow_nogo','fast_nogo'  };

if isfield(cfg,'delelectrode')
	elect = cfg.delelectrode;
	ifelec = 1;
else
	ifelec = 0;
end




%% pasar a LAN

for s = 1:length(SSuj)
    condi = [' '];
    
    for c  =1:length(CCond)
       eval([ ' load ' SSuj{s}  '.mat']);
        
        eval( [ CCond{c} ' = cat(3,  ' SSuj{s} '{' num2str(c)  '}.data{:} );']);
        if ifelec
        eval( [ CCond{c} ' ( [' elec '],:) = [];'])
		end
        condi = cat(2, condi , CCond{c}, ['  ']);
    end
    eval( [ ' save ' SSuj{s}  '_BS.mat  '  condi  '  '])     
    eval( [ ' clear ' SSuj{s}  ' condi   '  ]) 
end



disp_lan
disp(['...'])
disp(['Thank you for using LAN'])