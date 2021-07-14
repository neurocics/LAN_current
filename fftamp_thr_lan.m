function LAN = fftamp_thr_lan(LAN,cfg)
%       <*LAN)<
%       v.0.0.3
%       
%       Detec amplitud variation en fourier space 
%       cfg.thr    =    [1 0.1]           (sd %spectro)
%          .tagname=    'bad:A'
%          .frange=     [1 60]
%          .cat =
%          .method = 'f' or 'mt'
%          .nch = 'all'
% See also FOURIERP
% Pablo Billeke

% 05.04.2012 (PB) fix cat option
% 25.07.2011 (PB)
if nargin <2
    cfg.tagname = 'bad:A';
    cfg.frange=     [1 60];
    cfg.thr    =    [1 0.1]; 
    cfg.method = 'f' ; % simpole fourier transform
    cfg.chn = 'all';
end

    if isfield(cfg,'thr')
        thr=cfg.thr;
    else
        thr =[1 0.1];
    end
    if isfield(cfg,'frange')
        frange=cfg.frange;
    else
        frange=     [1 60];
    end  
    if isfield(cfg,'tagname')
        tagname=cfg.tagname;
    else
        tagname=  'bad:A';
    end  
    %%%
    if ~isfield(cfg,'method')
        cfg.method='f';
    end 
    if ~isfield(cfg,'chn')
        cfg.chn='all';
    end
fprintf( 'Fft amplitude threshold \n')

if ((isfield(cfg,'cat')&&cfg.cat==1)&&iscell(LAN))||(~isfield(cfg,'cat')&&iscell(LAN))
   oLAN = LAN;
   LAN = merge_lan(LAN);%% unir las condiciones
   ifolan=1;
else
   ifolan=0;     
end


LAN = lan_check(LAN);

if iscell(LAN)
    for lan =1:length(LAN)
        LAN{lan} =fftamp_thr_lan(LAN{lan},cfg);
    end
    
%%%%%%%%    
else %%% begin function
%%%%%%%%

if isempty(LAN.tag.labels)
    ntag = 1;
    LAN.tag.labels{1} = tagname;
else
    ntag = find(ifcellis(LAN.tag.labels,tagname));
    if isempty(ntag)
        ntag = length(LAN.tag.labels) + 1;
        LAN.tag.labels{ntag} = tagname;
    end
end

%
c=0;


LAN = fourierp_lan(LAN,cfg);
t1 = find(LAN.freq.fourierp.freq>=cfg.frange(1),1,'first');
t2 = find(LAN.freq.fourierp.freq<=cfg.frange(end),1,'last');
tt = 1:LAN.trials;
%tt(LAN.accept)=[];% no evaluar trial no aceptados
for nt = tt;
    
    for nch = 1:LAN.nbchan
        nfl= LAN.freq.fourierp.data(nch,t1:t2,nt); %data
        nf = nfl - LAN.freq.fourierp.mean(nch,t1:t2);%data-mean
        nf = ((nf-(thr(1).*LAN.freq.fourierp.std(nch,t1:t2)))>0);
            ...
            ...% + ((nf+thr(1).*LAN.freq.fourierp.std(nch,t1:t2))<0)...
            %+ (log10(nfl)>(thr(1).*LAN.freq.fourierp.lslog(nch,t1:t2)));...
           % + (log(nfl)<(thr(1).*LAN.freq.fourierp.lilog(nch,t1:t2)));...
        
        if sum((nf)>0) >= (length(nf)*thr(2)) 
            LAN.tag.mat(nch,nt) = ntag;
            fprintf('o')
            c=c+1;
            if mod(c,50)==0               
               fprintf('\n') 
            end
        end  
    end
end

%%%% re divide TAG
if ifolan
   ind=[];
   c=0;
   for lan = 1:length(oLAN)
   ind = [(c+1):(oLAN{lan}.trials+c)];
   c= oLAN{lan}.trials+c;
   %%% freq
    oLAN{lan}.freq = LAN.freq;
    oLAN{lan}.freq.fourierp.data = LAN.freq.fourierp.data(:,:,ind);
    %%%% tag
   oLAN{lan}.tag.mat =LAN.tag.mat(:,ind);
   oLAN{lan}.tag.labels =LAN.tag.labels;
   end
   LAN = oLAN; clear oLAN
end
%%%%%%%%%%%%
end , end %% END function
%%%%%%%%%%%%

