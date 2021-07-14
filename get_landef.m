function def = get_landef(r,newr)
%
%   LAN def function 
%    
%    v.0.1
%
%   Documentation in  \tex\lan.pdf 
%   only in spanish
%
%  14.03.2012
%  Pablo Billeke


%path
path = mfilename('fullpath');
path((end-10):end) = [];


% lan def
try
load landef def

        if nargin ==2
        eval(['def.' r ' = newr;'])
        save([ path '/landef'],'def','-append') 
        disp(['new lan_def .' r ' =  ' num2str(newr)]);    
        elseif nargin ==1
        eval(['def = def.' r ';' ]);
        end  
        
catch
            

switch  r  
    case 'fc'
    def = [0 1 0];
    case 'bc'
    def = [0 0 0];
    otherwise
        def.fc = [0 1 0];
        def.bc = [0 0 0];
 
end
end
end