function RT = event2RT(event,srate,time,other)
% <*LAN)<] toolbox
% v.0.1
%
% convert event structure (EEGLAB) to RT structure (LAN)
%
% Pablo Billeke

% 17.10.2012


RT.latency = cell2mat({event(:).latency}   )*(1000/srate);

RT.OTHER.names = ({event(:).type});

n=1;
est = zeros(size(RT.OTHER.names));
mequedan = RT.OTHER.names;
while n>0
      est(ifcellis(RT.OTHER.names,mequedan{1})) = n; % numero del estimulo; 
      mequedan(ifcellis(mequedan,mequedan{1})) = [];
      if isempty(mequedan)
          n = 0;
      else
          n = n +1;
      end

end
RT.est = est;

dtime = time(:,2)-time(:,1);
dtime = cat(1,0,cumsum(dtime(1:end)));
RT.trial = zeros(size(RT.est));
RT.tlatency = zeros(size(RT.est));
for t = 1:size(time,1)
    RT.trial( (RT.latency>=1000*dtime(t)) &(RT.latency<1000*dtime(t+1)) ) = t;
    RT.tlatency( (RT.latency>=1000*dtime(t)) &(RT.latency<1000*dtime(t+1)) ) = RT.latency( (RT.latency>=1000*dtime(t)) &(RT.latency<1000*dtime(t+1)) ) - (1000*dtime(t));
end

RT.resp = ones(size(est))*-99;

if nargin < 4
    other = 'all';
end
   if strcmp(other,'all')
      other = fieldnames(event);
      other(ifcellis(other,'type')) = [];
      other(ifcellis(other,'latency')) = [];
   end
   for oo = 1:length(other)
   eval(['RT.OTHER.' other{oo} '  =  {event(:).' other{oo}  '} ;'  ])    
   end
   
   
   % add check
   RT =rt_check(RT);
end



