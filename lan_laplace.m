function [ LAN H G ]= lan_laplace(LAN,cfg)
% v.0.0.4
% Compute laplace tranformation using CSD toolbox, 
%         see http://psychophysiology.cpmc.columbia.edu/Software/CSDtoolbox/
%
% cfg.H         = precalulate H matrix
% cfg.G         = precalulate G matrix
% cfg.head      = heade radius =10
% cfg.lambda    = smooth = 0.00001
% cfg.centred   = [ 0 0]

% 07.01.2013
% 06.07.2012 New segmetation compatibility
% 03.11.2011 Pablo Billeke

% cicle for lan cell
if iscell(LAN)
   for lan = 1:length(LAN)
	if ~isempty(LAN{lan})
	LAN{lan} = lan_laplace(LAN{lan},cfg);
	else
	warning(['LAN {' num2str(lan) '} is empty ' ]);
	end
   end


% real function
else

centred = getcfg(cfg, 'centred', [0 0]);
getcfg(cfg, 'Sy', 1);
getcfg(cfg, 'Sx', 1);
% parameters

%chanlocs
if isfield(cfg, 'chanlocs')
  chanlocs = cfg.chanlocs;
elseif isfield(LAN, 'chanlocs')
  chanlocs = LAN.chanlocs;
else
  error([' there is not channel loction '])
end

%---% tranform chanlocs unit
  %load chanlocs_40neuroscan_nuamp(40)
  %chanlocs([1 2 5 6  27 33 37 38]) = [];%

% % only in EEG channels
% inx = ifcellis({chanlocs(:).type},'EEG');
% if sum(~inx) < length(chanlocs)
%     % delete electrode no_EEG
%     chanlocs(~inx) = [];
%     if ~isempty(find(~inx, 1))
%         LAN = electrode_lan(LAN,find(~inx));
%     end
% else
%     warning('Posible error in  electrode type labels')
% end


% E = {chanlocs(:).labels}'
% M = ExtractMontage('10-5-System_Mastoids_EGI129.csd',E)
         % adjust theta if neccessary
         


 %---%


%---%Generate Transformation Matrices G and H
  % check if exist precalculated G and H matrix
  if isfield(cfg,'G') && isfield(cfg,'H') 
  G = cfg.G; H = cfg.H;
  else
  
          % create montage
        if ischar(centred)
        inxCz =  ifcellis({chanlocs(:).labels},centred);
        YCz=chanlocs(inxCz).Y;
        XCz=chanlocs(inxCz).X;
        elseif isnumeric(centred)

        XCz=centred(1);
        YCz=centred(2);

        end
        M.lab = {chanlocs(:).labels}';
        M.theta = cat(1,chanlocs(:).sph_theta);
            M.theta = M.theta + 90;
            if M.theta > 180
            M.theta = M.theta - 360; end; 
            %phi = 90 - (radius * 180);
        M.phi = cat(1,chanlocs(:).sph_phi);
         Sy =1;Sx =1;

        M.xy(:,1) = (-cat(1,chanlocs(:).Y) - YCz)*Sy; % center Cz electrode
        M.xy(:,2) = (cat(1,chanlocs(:).X) - XCz)*Sx ; % center Cz electrode
        mm = max(max(abs(M.xy))); % 200
        M.xy = ((M.xy) ./ (2 * (mm))) + 0.5;	% for tranfor a unit sphere !!!! OJO !!!!

       % MapMontage(M)
       % pause
   % calculated matrix
   % see GetGH.m
    [G,H] = GetGH (M, 4);
  end
%---%

%---% laplace tranformations

% smoothing constant lambda   
try
lambda = cfg.lambda;
catch
lambda = 0.00001;
end

% head radius  
try
head = cfg.head;
catch
head = 10;
end

% by trials
for t = 1:LAN.trials
    if ~isempty(LAN.data{t})
    LAN.data{t} = CSD(LAN.data{t},G,H,lambda, head);
    end
end
%---%


end