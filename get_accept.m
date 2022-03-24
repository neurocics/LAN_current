function [ accept data ] =  get_accept(data,accept)
%    <*LAN)<]    
%    v.0.0.1
%
%   22.06.2012
%   Pablo Billeke

if nargin==1
    % get_accept(LAN) 
    accept = data.accept;
    data = data.data;
end

    % fix accept vector
    if any(accept>1)
        paso =  false(1,length(data));
        paso(accept);
        accept = paso; clear paso
    elseif length(data)==sum(accept)
       accept = true(1,length(data));
    elseif length(data) ~= length(accept)
        warning('not bad trials???')
        accept = true(1,length(data));
    end
    accept = logical(accept);
    
    % fix data vector
    data(~accept) = []; 
    
end

