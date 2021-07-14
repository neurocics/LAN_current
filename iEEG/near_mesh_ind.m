function [ ind  pos ]= near_mesh_ind(vertices,P)


for n = 1:size(P,1)
    x = vertices(:,:) - repmat(P(n,:),[size(vertices,1) 1]);
    x = sqrt(sum(x.^2,2));
    [paso x] = min(x);
    ind(n) = x;
end

   pos = vertices(ind,:);

end