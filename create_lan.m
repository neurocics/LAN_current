function LAN = create_lan(chan,srate)
% v 1.0.0
% 
% 
% Pablo Billeke
% 
% 13.4.2009

if nargin < 2;srate = 1000;end
if nargin < 1;chan = 32;end

LAN = [];
LAN.srate = srate ;
LAN.data = zeros(chan,1);
LAN.time = [0 0 0];
LAN.trials = 1;
LAN.event(1).type = [1];
LAN.event(1).duration = [1];
LAN.event(1).latency = [1];
LAN.event(1).latency_aux = [1];

LAN = lan_check(LAN);