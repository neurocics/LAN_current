function synchrot = plot_syncro_s(LAN,algo);

% algo = 'PLV' - 'PLI' - 'BOTH'
if nargin == 1 
    Algo = 1; %
else
    if strcmp(algo,'PVL')
        Algo = 1;
    elseif strcmp(algo,'PLI')
        Algo = 2;
    elseif strcmp(algo,'BOTH')
        Algo = 3;
    else
        Algo = 1;
    end
end
%-----------------------
if Algo == 1
    alpha = LAN{1}.phase.p_val ;
elseif Algo == 2
    alpha = LAN{1}.phase.pli_p  ;
elseif Algo == 3
    for l = 1:length(LAN{1}.phase.p_val)
    alpha{l} = LAN{1}.phase.p_val{l} .* LAN{1}.phase.pli_p{l} ;
    end
end
%---------------------
for i = 2:length(LAN)
    
    
 if Algo == 1
    alpha = cat(2,alpha,LAN{i}.phase.p_val);
elseif Algo == 2
    alpha = cat(2,alpha,LAN{i}.phase.pli_p);
elseif Algo == 3
    for l = 1:length(LAN{i}.phase.p_val)
    r{l} = LAN{i}.phase.p_val{l} .* LAN{i}.phase.pli_p{l} ;
    end
    alpha = cat(2,alpha,r);
end   
    
    
    
%alpha = cat(2,alpha,LAN{i}.phase.p_val);
%alpha = cat(2,alpha,LAN{i}.phase.pli_p);
%alpha_m = mean(cat(3,alpha{1,:}),3);
%correc = mean(mean(alpha_m)) - 2*mean(std(alpha_m));
end
%alpha = cat(a,alpha{1,:})
alpha_m = mean(cat(3,alpha{1,:}),3);
stt = alpha_m(:,1);
for i = 2:size(alpha_m,2)
   stt = cat(1,stt,alpha_m(:,i)) ;
end

correc = mean(mean(alpha_m)) - 2*(std(stt));
clear alpha_m_p alpha_m alpha

for i = 1:length(LAN)
chanlocs = LAN{i}.chanlocs;

if Algo == 1
    alpha = LAN{i}.phase.p_val ;
elseif Algo == 2
    alpha = LAN{i}.phase.pli_p  ;
elseif Algo == 3
     for l = 1:length(LAN{i}.phase.p_val)
    alpha{l} = LAN{i}.phase.p_val{l} .* LAN{i}.phase.pli_p{l} ;
     end
end

%alpha = LAN{i}.phase.p_val;
%alpha = LAN{i}.phase.pli_p;
alpha_m = mean(cat(3,alpha{1,:}),3);
%correc = mean(mean(alpha_m)) - 2*mean(std(alpha_m));
    
    
alpha_m_p =(alpha_m<correc);

%figure,
synchrot = plot_syncro(alpha_m_p, chanlocs, 1:32,LAN{i}.cond);

clear alpha_m_p alpha_m alpha
end