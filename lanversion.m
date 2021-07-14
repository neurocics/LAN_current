function v = lanversion(r,newr)
%
%   LAN version function 
%    
%    v.0.1.2 -->  10.01.2012
%    v.0.1.1 -->  20.06.2011
%    v.0.1.0 -->  11.01.2011 
%
%   Documentation in  \tex\lan.pdf 
%   only in spanish
%
%  04.11.2011
%  Pablo Billeke


%path
path = mfilename('fullpath');
path((end-10):end) = [];


% lan version
if (nargin == 0) || (  ~strcmp(r,'l')&&~strcmp(r,'li')&&~strcmp(r,'d')&&~strcmp(r,'t') )
    if nargin ~=2
    load landef Version
    v = Version;
    else
        Version = newr;
        save([ path '/landef'],'Version','-append') 
        disp(['new lan version ' newr]);
    end


% last update
elseif strcmp(r,'d')
    if nargin ~=2
    load landef Lastupdate
    v = Lastupdate ;
    else
        Lastupdate = newr;
        save([ path '/landef'],'Lastupdate','-append') 
        disp(['last lan update ' newr]);
    end
    
% logo    
elseif strcmp(r,'l')
	  if strcmp(computer, 'GLNX86')||strcmp(computer, 'GLNXA64')
	  v = '<°LAN)<]';
	  else
	  v = '<*LAN)<]';
	  end
elseif strcmp(r,'li')
	  if strcmp(computer, 'GLNX86')||strcmp(computer, 'GLNXA64')
	  v = '[>(LAN°>'; 
	  else
	  v = '[>(LAN*>'; 
      end
      
% type of version      
elseif strcmp(r,'t')
    if nargin ~=2
    load landef Type
    v = Type;
    else
        Type = newr;
        save([ path '/landef'],'Type','-append') 
        disp(['new lan type version: ' newr]);
    end

	

end
end