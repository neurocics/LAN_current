function LAN = vol_thr_lan(LAN,thr,type,tagname,elec)
%       <*LAN)<
%       v.1
%
%       Detect voltange variations, in voltages, zscore, or corre
%   thr :    threshold 
%   type:    v : voltage
%            z : voltage (zscore)
%            c : between-electrode correlation (zscore)
%   
% 15.06.2023 fix zscore threshold and add 
%                corr threshold (decrease of increas corretion between electrodes in z-score)
% 21.03.2022 fix empty trials 
% 27.08.2021
% 16.06.2011
% Pablo Billeke
%
if nargin <3
    ifz=0;
    ifc=0;
else
    ifz = strcmp(type,'z');
    ifc = strcmp(type,'c');
end
if nargin <4
    tagname = 'bad';
end
if nargin <5
    elec = 1:LAN.nbchan;
end
fprintf( 'Voltage threshold \n')


LAN = lan_check(LAN);




if iscell(LAN)
    for lan =1:length(LAN)
        LAN{lan} = vol_thr_lan_str(LAN{lan},thr,ifz,tagname,elec,ifc);
    end
else
    LAN = vol_thr_lan_str(LAN,thr,ifz,tagname,elec,ifc);
end

            fprintf( '\n DONE \n')
end

function LAN = vol_thr_lan_str(LAN,thr,ifz,tagname,elec,ifc)

%
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

tt = 1:LAN.trials;
%tt(LAN.accept)=[];% no interpolar trial no aceptados
for nt = tt
    dt(:,nt) =  max(LAN.data{nt},[],2) - min(LAN.data{nt},[],2) ;
    zcorr(elec,nt) = mean(corr(LAN.data{nt}(elec,:)')) ;
    %cat(2,LAN.data{LAN.accept});
    %zmean = mean(DATA,2);
    %zsd = std(DATA,[],2);
end
    
    
    zmean = mean(dt,2);
    zmeancorr = mean(zcorr,2);
    zsd = std(dt,[],2);
    zsdcorr = std(zcorr,[],2);
    zsc = (dt - repmat(zmean,[ 1 LAN.trials]))./ repmat(zsd,[ 1 LAN.trials]) ;
    zsccorr = (zcorr - repmat(zmeancorr,[ 1 LAN.trials]))./ repmat(zsdcorr,[ 1 LAN.trials]) ;

for nt = tt
    if isempty(LAN.data{nt}); continue;end
    for nch = elec% ONLY IN SELECTED ELECTRODES  1:LAN.nbchan 
        %d = LAN.data{nt}(nch,:);
        if ifz
            %d=(d-zmean(nch))./zsd(nch);
            zd= any((zsc(nch,nt))>(thr));
            vd=0;
            zc=0;
        elseif ifc 
            zd=0;
            vd=0;
            zc=any(abs(zsccorr(nch,nt))>(thr));            
        else
            vd=(abs(dt(nch,nt))>thr);
            zd=0;
            zc=0;
        end
        %d = d - mean(d)


        if vd || zd || zc
            LAN.tag.mat(nch,nt) = ntag;
            fprintf('o')
            c=c+1;
            if mod(50,c)>1
               c = c-50;
               fprintf('\n') 
            end
        end  
    end
end
end


