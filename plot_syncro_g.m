function synchrot = plot_syncro_g(LANs)

LAN = LANs{1};
cond = length(LAN);
chanlocs = LAN{1}.chanlocs;

for l = 1:cond
p_val{l} = LAN{l}.phase.alpha;
end

for  lan = 2:length(LANs) 
    LAN = LANs{lan}
    for l = 1:cond
    p_val{l} = cat(2,LAN{l}.phase.alpha) 
    end
end

%%%%%%%%%%%%%%%%
alpha =p_val{1} ;
for i = 2:cond
alpha = cat(2,alpha,alpha{i});
%alpha_m = mean(cat(3,alpha{1,:}),3);
%correc = mean(mean(alpha_m)) - 2*mean(std(alpha_m));
end
%alpha = cat(a,alpha{1,:})
alpha_m = mean(cat(3,alpha{1,:}),3);
stt = alpha_m(:,1);
for i = 2:size(alpha_m,2)
   stt = cat(1,stt,alpha_m(:,i)) ;
end

correc = mean(mean(alpha_m)) + 3*(std(stt));
clear alpha_m_p alpha_m alpha

for i = 1:cond
%chanlocs = LAN{i}.chanlocs;
alpha = p_val{i};
alpha_m = mean(cat(3,alpha{1,:}),3);
%correc = mean(mean(alpha_m)) - 2*mean(std(alpha_m));
    
    
alpha_m_p =(alpha_m>correc);

%figure,
synchrot = plot_syncro(alpha_m_p, chanlocs, 1:32,LAN{i}.name);

clear alpha_m_p alpha_m alpha
end