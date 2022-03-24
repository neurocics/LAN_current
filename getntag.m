function [n tag] = getntag(tag,lab) 
%  <*LAN)<]  
%  get the index of the label 'lab' in the TAG structure, is not exist,
%  add it to TEG structure
%
%   >>  [n tag] = getntag(tag,lab) 
%
%  v.0.0.1
%  23.07.2011 - Pablo Billeke



n = [];
%
if isempty(tag.labels)
    n=1;
    tag.labels{n} = char(lab); 
    return
end
%
for i = 1:length(tag.labels)
            if strcmp(tag.labels{i},lab)
                n=i;
                break
            end
end
if isempty(n)
    n = i +1;
    tag.labels{n} = char(lab);
end
end