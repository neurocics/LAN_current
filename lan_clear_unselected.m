function LAN = lan_clear_unselected(LAN,cfg)
if nargin==1, cfg=[];end

getcfg(cfg,'win','hann');
getcfg(cfg,'width',10);
getcfg(cfg,'border',20);
getcfg(cfg,'iffig',1)
if iffig
H = figure;
end
% only trial with unselected areas!
T = find(ifcellis(LAN.selected,'any(~@)'));

for nt = T
    % nt = T(1)
DIF = find(abs(diff(LAN.selected{nt})));

% first or last event unselected
if (LAN.selected{nt}(1,1)==0)&&(DIF(1)~=1); DIF = cat(2,1,DIF);end  
if (LAN.selected{nt}(end)==0)&&(DIF(end)~=LAN.pnts(nt)-1); DIF = cat(2,DIF,LAN.pnts(nt)-1);end  

% check unselected areas near to the borders 
if DIF(1) <= border;  DIF(1)=1;  end;
if DIF(end) >= LAN.pnts(nt)-border-1;  DIF(end)=LAN.pnts(nt);end;

for pp = 1:2:length(DIF)
    
    %n = length(DIF(pp):DIF(pp+1));
    %if (pp==1)||(pp==LAN.pnts(nt));
    %w = 1-hann((n-1)*2+1) ;
    %else
    %w =  1-hann(n);   
    %end
    
    %pp = 1
  
    S = ones(size(LAN.selected{nt}));
    S((DIF(pp):DIF(pp+1))) = 0;
    if (DIF(pp)==1)
        S = cat(2,zeros(1,width),S);
    elseif (DIF(pp+1)==LAN.pnts(nt));
        S = cat(2,S,zeros(1,width));
    end
    
    switch win
        case 'hann'
        W = conv(S,double(hann(width))','same');    
        case 'hamming'
        W = conv(S,double(hamming(width))','same');      
    end
    
   % W(W>=max(W)/1.1) =  max(W)/1.1;
    W = W./max(W);
    
   if (DIF(pp)==1)
        W(1:width) =[];
    elseif (DIF(pp+1)==LAN.pnts(nt));
        W(LAN.pnts(nt)+1:end)  = [];
   end
   
   if iffig
       figure(H)
       plot(W,'r'), hold on, plot(S,'k'), hold off
       ylim([-1 2])
   end
    % clear bad segement
    % nt
    LAN.data{nt} =  LAN.data{nt} .* repmat(W,[LAN.nbchan,1]);
     
end

close(H)
end



end