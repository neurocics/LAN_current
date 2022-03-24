function LAN = lan_add_this_m(LAN,name)

if nargin==1
    name = [];
end


%save current version of this scrpt in the LAN strucutre
if isempty(name)
name = evalin('caller', 'matlab.desktop.editor.getActiveFilename');
end

if isfield(LAN,'m_files')
    LAN.m_files(end+1).name  = name;
    LAN.m_files(end).content  = fileread(name);
    LAN.m_files(end).date = date; 
else
    LAN.m_files(1).name  = name;
    LAN.m_files(1).content  = fileread(name);
    LAN.m_files(1).date = date; 
end






end