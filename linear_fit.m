function linear_fit(X,Y,c,t,w)

if nargin <5
    w = 1;
end

if nargin <4
    t = '-';
end

if nargin <3
    c= [0 0 0];
end

[b] = glmfit(X,Y);
line ( [ min(X) max(X)],[ b(1)+b(2)*min(X) b(1)+b(2)*max(X) ], 'Color',c,'LineStyle', t , 'LineWidth',w);

