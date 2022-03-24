function RT = rt_del(RT,ind,inv)
% v.0.0.4
% <*LAN)<]
%

% 31.03.2014 PB: (Descomete lan_check, puse opsion para no ordenar, REVISAR!!)
% 26.04.2013 (agregue condiciones para que no se caiga)
% 07.01.2013
% 08.08.2012
% 03.04.2012

if islogical(ind)
    ind=find(ind==1);
end

if nargin == 3 && inv==-1
x = true(size(RT.est));
x(ind) = false;
ind = x;
clear x
end

% check the structur
cfg.ifsort = false;
RT = rt_check(RT,cfg);
            % COMENTADO : el sorting DEJA LA CAGADA
            %      R: No debeira, en que tipo de datos no funciona?


% delete 
if ~isempty(RT.rt); RT.rt(ind) = []; end
if ~isempty(RT.est); RT.est(ind) = []; end
if ~isempty(RT.resp); RT.resp(ind) = []; end
%RT.chan(ind) = [];
if ~isempty(RT.laten); RT.laten(ind) = []; end
if ~isempty(RT.good); RT.good(ind) = []; end

RT.latency = RT.laten;
if isfield(RT,'correct')
RT.correct(ind) = [];
end
if isfield(RT,'trial')
RT.trial(ind) = [];
end
if isfield(RT,'tlatency')
RT.tlatency(ind) = [];
end

    %%% in OTHER
    if isfield(RT,'OTHER')
        campos = sort(fields(RT.OTHER))';

        for ncm = 1:length(campos)
            %nh = nh +1;
            %HEADER{nh} = campos{ncm};
            eval(['  RT.OTHER.' campos{ncm} '(ind) = [] ;']);
        end
    end