function f = fix_filename(f)

f = strrep(f,'-','_');
f = strrep(f,'+','_');
f = strrep(f,'*','_');
f = strrep(f,':','_');
f = strrep(f,'.','_');
f = strrep(f,'ñ','n');
end