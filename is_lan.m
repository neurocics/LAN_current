function [T tipo v ] = is_lan(LAN,base)
%   <*LAN)<]  
%   v.0.0.4

%   22.10.2012
%   16.05.2012
%   20.03.2012
%   29.07.2011

       T = false;
       tipo = '';
       v = '';
       if nargin==1
           base = true;
       end
       
if ischar(LAN)&&base
   try 
   LAN = evalin('base',LAN);
   catch
       return
   end
end



if iscell(LAN)
    for lan = 1:length(LAN)
        [t{lan} tipop{lan} vp{lan} ]= is_lan(LAN{lan},false);
    end
        a = (cat(1,t{:})==1);
        if any(a)
            a = find(a);
            T = true;
            tipo = tipop{a(1)};
            v = vp{a(1)};
        end
        
elseif isstruct(LAN)
    if isfield(LAN,'data')&&isfield(LAN,'srate')
        T=true;
        tipo = 'lan';
        if isfield(LAN,'infolan')
            v = LAN.infolan.version;
        else
            v = '<0.1.2.3';
        end
    elseif (isfield(LAN,'subject')||isfield(LAN,'suject'))&&(isfield(LAN,'erp')||isfield(LAN,'timefreq')) %&&isfield(LAN,'srate')
        T=true;
        tipo = 'glan';
        if isfield(LAN,'infolan')
            v = LAN.infolan.version;
        else
            v = '<0.1.2.3';
        end        
    else
        T=false;
        tipo = '';
        v = '';
    end
    

end
    



end