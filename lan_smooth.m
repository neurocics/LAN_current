function A = lan_smooth(A, span, fact, times)
% span = 0 : no change

if nargin<2
span=4;
end
if nargin<3
fact=0.5;
end


A = squeeze(A);
if nargin == 4
if size(A,3)>1
   for i3=1: size(A,3)    
    for i = 1:(times)
    A = lan_smooth(A, span, fact);
    end
    end
   return
end

end


if size(A,3)>1
   for i3=1: size(A,3)
   A(:,:,i3) = lan_smooth(A(:,:,i3), span, fact);
   end
   return
    
end


nn = isnan(A);
A(nn) = 0;

mid = span+1; % central point
base = zeros(2*span + 1, 2*span + 1); % base function spans 'span' points from the center
base(mid,mid) = 1; % peak at the center

ind = base;
for c = 1:2*span+1
ind(c,:) = 1:2*span+1;
end
ind = abs(ind-mid) + abs(ind'-mid);
                         %ind is a ... 3 2 1 0 1 2 3 ... matrix spanning in two dimensions
                         
                         for c = 1:span
                         base(ind == c) = base(mid-(c-1),mid) * fact;
                         end
                         
                         if size(A,1) == 1
                         base = base(mid,:) / sum(base(mid,:));
                         A = conv(A, base(mid,:));
                         A = A(span+1:end-span); % crop
                         elseif size(A,2) == 1
                         base = base(:,mid) / sum(base(:,mid));
                         A = conv(A, base(:,mid));
                         A = A(span+1:end-span); % crop
                         else
                         base = base / sum(sum(base));
                         A = conv2(A, base);
                         A = A(span+1:end-span, span+1:end-span); % crop
                         end
                         
                         A(nn) = NaN;
