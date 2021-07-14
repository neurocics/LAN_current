function LANs = only_interband(LAN)
% aisla solo lo relebante del estudio interbanda
%
%
 if isstruct(LAN)
        LANs = only_interband_struct(LAN);
 elseif iscell(LAN)
            for lan = 1:length(LAN)
            LANs{lan} = only_interband_struct(LAN{lan});
            end
end
end

function LANs = only_interband_struct(LAN)

%%% save only inter-band study
  LANs.freq.inter_a_a = LAN.freq.inter_a_a;
    LANs.freq.time.inter_a_a = LAN.freq.time.inter_a_a;
      LANs.freq.freq.inter_a_a = LAN.freq.freq.inter_a_a;
      
    LANs.freq.time.inter_ph_a = LAN.freq.time.inter_ph_a;
  LANs.freq.freq.inter_ph_a = LAN.freq.freq.inter_ph_a;
     LANs.freq.inter_ph_a = LAN.freq.inter_ph_a;
  
   
     
end