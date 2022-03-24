function DATA = lan_getdatafile(filenames,filepath,varname)
% v.0.0.2
% DATA = lan_getdatafile(filenames,filepath,varname)
%
if nargin == 0
help lan_getdatafile
    if strcmp(lanversion('t'),'devel')
        edit lan_getdatafile
    end
return
end

if iscell(filenames)
    DATA = cell(size(filenames));
    for i = 1:length(DATA(:))
        if iscell(filepath)
            fp = filepath{i};
        else
            fp = filepath;
        end
        if iscell(varname)
            vn = varname{i};
        else
            vn = varname;
        end
        eval(['load( ''-mat'' , ''' fp '/' filenames{i} ''' , ''' vn ''' );'])
        DATA{i} = eval(vn);
    end
else
    try
    eval(['load( ''-mat'' , ''' filepath '/' filenames ''' , ''' varname ''' );'])
    catch
        try
        ee = findstr(filenames,'_');
        ee = ee(1)-1;
        eval(['load( ''-mat'' , ''./' filenames(1:ee) '/' filenames ''' , ''' varname ''' );']) 
        catch
            eval(['load( ''-mat'' , ''./' filenames ''' , ''' varname ''' );']) 
        end
    end
    DATA = eval(varname);
end


end