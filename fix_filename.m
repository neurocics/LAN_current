function f = fix_filename(f,es)

if nargin ==1
    es={'-','+',':','ñ'};
else
    if iscell(es)
        for ies = es
            %ies{1};
            f = fix_filename(f,ies{1});
        end
    return
    end
    
end

switch es
    % delete full path for   
    case {'/','\'}
        ind = strfind(f,es);
        if ~isempty(ind)
        f = f(ind(end)+1: end);
        end
    case {'-','+',':','ñ','.'}
        f = strrep(f,es,'_');
    case {'ext'}
        ind = strfind(f,es);
        f(ind(end):end) = [];
end