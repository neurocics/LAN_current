function LAN = resample_lan(LAN,newsrate)
%      <*LAN)<] 
%      v.0.0.02
%  RESAMPLE_LAN change the sample rate. 
%  see also RESAMPLE
%
%  Pablo Billeke
%  
%  11.07.2011 fix double/single and n+1 temporal points
%  24.06.2011


%%% cell
if iscell(LAN)

    for lan = 1:length(LAN)
        LAN{lan} = resample_lan(LAN{lan},newsrate);
    end
    
%%%  function
elseif isstruct(LAN)
if LAN.srate~=newsrate
        for t =1:length(LAN.data)
            for n = 1:LAN.nbchan
            paso1 = double(LAN.data{t}(n,:));
            paso2 = paso1(LAN.pnts(t));
            paso1 = paso1(1:(LAN.pnts(t)-1));
            if n ==1
               paso(n,:) = single(resample(paso1,newsrate,LAN.srate));
               paso(n,(length(paso)+1))=paso2;
            else
               paso(n,1:(length(paso)-1)) = single(resample(paso1,newsrate,LAN.srate));
               paso(n,(length(paso)))=paso2;
            end
            
            clear paso1 paso2
            end  
            LAN.data{t} = paso;
            clear paso*
        end
        LAN.srate=newsrate;
        LAN = lan_check(LAN);
else
    disp('new srate is the same that old srate, CUAK!!! ')
end

%%% error
else
    error('unrecognacible LAN struct')
end  
end