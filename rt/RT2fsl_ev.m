function RT2fsl_ev(filename, RT,est,dur,w)

if nargin<4
    w= ones(size(RT.est));
elseif size(w)==1
    w= w .* ones(size(RT.est));
end

if nargin<3
   dur =RT.rt;   
end

if nargin<2
   est=(RT.est);
   ind = true(size(est));
else
    ind = false(size(RT.est));
    for i = 1:length(est)
        ind(RT.est==est(i))=true;%% fixed 5.8.2016
    end
    
    if length(dur)==1;
       dur = ones(size(ind)) .*dur; 
    end
    
end





fid = fopen(filename ,'wt');
for e =find(ind)
   fprintf(fid,[ num2str(RT.laten(e)) '\t' num2str(dur(e)) '\t'  num2str(w(e)) '\n' ]);
end
fclose(fid);

end

