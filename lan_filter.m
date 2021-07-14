function LAN = lan_filter(LAN,varargin)
%  <°LAN)<] toolbox
%  v.0.0.1
%
% LAN = lan_filter(LAN,fmin,fmax,chan,type)
%
% filter 
%
% type = 'FIR2'

if iscell(LAN)
   for lan=1:length(LAN)
       LAN{lan} = lan_filter(LAN,varargin{:});
   end
   return
end


if length(varargin)<4
    type='fir2';
else
    type=varargin{4};
end

if (length(varargin)<3)||(strcmp(varargin{3},'all'));
    chan = 1:LAN.nbchan;
else
    chan=varargin{3};
end



switch type
    case {'FIR2', 'fir2','Fir2'}   
     LAN.data = lan_fir2(LAN, varargin{1}, varargin{2}, chan);
end


end