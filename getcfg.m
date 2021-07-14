function out = getcfg(cfg,field,default,posible)
%  <*LAN)<] 
%  v.0.0.4
%  get cfg field and set default parameter

% Pablo Billeke

% 30.03.2012 fix bug in logical default
% 20.03.2012 fix bug
% 01.02.2012 add posible = {'op1','op2','op3',...} 
% 25.11.2011 
% 21.11.2011


if nargin <4
    posible = [];
end


% get the format of default parameter
if nargin >= 3
    if  isnumeric(default)||islogical(default)
        default=num2str(default);
        cc = [];
        cc1= '[';
        cc2= ']';
    else
        cc= '''';
        cc1= '''';
        cc2= '''';
    end
end

ff=false;

if ~isempty(posible)&&isfield(cfg,field)
   %if ischar(posible), posible = {posible};end
   a = eval([ inputname(1)  '.' field ';' ]);
   if ~any(strcmp(a,posible))
       ff=true;
   end
end


if nargout==0
    if isfield(cfg,field)&&~ff
        evalin('caller', [ field ' = ' inputname(1)  '.' field ';' ])
    elseif (nargin >= 3)||(ff);
       evalin('caller', [ field ' = ' cc1  default cc2 ' ; ' ])
       evalin('caller', [   inputname(1)  '.' field ' = ' field ' ; ' ])
    end
else
    if isfield(cfg,field)&&~ff
        %out = eval([ inputname(1)  '.' field ';' ]);
        out = eval([  'cfg.' field ';' ]);
    elseif nargin >= 3;
        out = eval([ cc1  default cc2 ' ; ' ]);
        evalin('caller', [   inputname(1)  '.' field ' = ' cc1  default cc2  ' ; ' ])
    end    
end