function fprintf_cell(fid, cell,format )
% Easy loop for write a file
%
%
%

%---% parameter
if nargin < 3
    % for dfault each cell is a line
    format = ' %s \n ';
end

%---% loop
for i = 1:length(cell)
    fprintf(fid,format, cell{i} );  
end


    %fprintf(fid,' %s \n ',['ccc = 0'] );
    %fprintf(fid,' %s \n ',['for (ele in c( ' cne  '))'] );
    %fprintf(fid,' %s \n ',['{'] );
    %fprintf(fid,' %s \n ',['ccc = ccc + 1'] );
    %fprintf(fid,' %s \n ',['a = paste("borrame", as.character(ele),".txt",sep="")'] );
    %fprintf(fid,' %s \n ','D<-read.table(a,header=T)');
    %fprintf(fid,' %s \n ',' if (ccc==1) {attach(D)}');  
end
    