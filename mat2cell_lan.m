function LAN = mat2cell_lan(LAN)
% v.0.1 
%
% 27.07.2012
% 02.04.2012
% 14.4.2009
if iscell(LAN)
    for lan = 1:length(LAN)
        LAN{lan} = mat2cell_lan(LAN{lan});
    end
elseif isstruct(LAN)

if ~iscell(LAN.data)
    paso = LAN.data;
    tr = size(paso,3);
    LAN = rmfield(LAN,'data');
    if tr>1 
        % improve memory use,
        %for i = 1:tr
        %    LAN.data{i}(:,:) = paso(:,:,1);
        %    paso(:,:,1) = [];
        %end
        LAN.data = mat2cell(paso,size(paso,1),size(paso,2),ones(1,size(paso,3)));
        LAN.data = permute(LAN.data,[1,3,2]);
    else
        LAN.data{1} = paso;
    end
    clear paso
    
    LAN.trials=tr;
end

else
    error('not LAN format')
end
end