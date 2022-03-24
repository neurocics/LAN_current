function [ color_v ]= fill_mesh_ind(vertices,P,w,r,value)

if nargin<5
    value = [];
end

color_v = zeros(length(vertices),1);
maxc = (cdf('Normal',[ r/w]))*2;

for n = 1:size(P,1)
    x = vertices(:,:) - repmat(P(n,:),[size(vertices,1) 1]);
    x = sqrt(sum(x.^2,2));
    ind_c = (x<(2*w));
    colorx = (1-cdf('Normal',x/w))*2*maxc;
    colorx(colorx>1)=1;
    colorx(colorx<0)=0;
    if ~isempty(value)
       colorx = colorx*value(n) ;
    end
    color_v(ind_c) = color_v(ind_c) + colorx(ind_c);
end

   %pos = vertices(ind_c,:);

end