function lan_master_gui_busyprompt(busy, mainfig, mytitle)

if nargin < 3
    mytitle = 'Welcome to LAN MASTER GUI';
end
if nargin == 1
    mainfig = 1;
end

if busy
    set(mainfig, 'name', 'Working...');
else
    set(mainfig, 'name', mytitle);
end
drawnow;
