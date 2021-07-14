% cor_freq_lan.m
% v1.0
% 
% calcula la estadistica de las correlaciones, y grafica
% de cada individuo.
%
% 22.11.2009
% Pablo Billeke
%
function [ bs,mbs,p,hc] = cor_freq_lan(LAN,e)

% 
for com = 1:length(LAN{1}.freq.cfg.corfr1)

if iscell(LAN)
    disp('Chequeando estructura LAN')
else
    warning('Solo para LAN con celdas para comparar condiciones')
    r = LAN;
    clear LAN;
    LAN{1} = r;
    clear r;
end


try
   % nbchan = LAN{1}.nbchan;
   nbchan = length(LAN{1}.freq.corfre_b{1});
catch
    nbchan = length(LAN{1}.freq.corfre_b{1});
   % LAN = add_field(LAN,['nbchan = ' num2str(nbchan) ]);
end


for lan = 1:length(LAN)
for elec = 1:nbchan

    
    try
        for i= 1:LAN{lan}.trials, 
            b{lan}(i,elec)=LAN{lan}.freq.corfre_b{com,i}(elec ); 
        end
    catch 
        LAN{lan}.trials = length(LAN{lan}.freq.corfre_b);
        for i= 1:LAN{lan}.trials, 
            b{lan}(i,elec)=LAN{lan}.freq.corfre_b{com,i}(elec ); end
    end



end

%respu(ie,:) = [ ele mean(b1) mean(b2) mean(b3) ranksum(b1,b2) ranksum(b3,b2) ranksum(b3,b1)]
%bs1(length(bs1)+1:length(bs1)+length(b1))=b1;
%bs2(length(bs2)+1:length(bs2)+length(b2))=b2;
%bs2(elec,:) = b2;
%bs3(length(bs3)+1:length(bs3)+length(b3))=b3;
%bs3(elec,:) = b3;
end

for lan = 1:length(LAN)

bs{com,lan}(:,:) = b{lan};
bs{com,lan} = mean(bs{com,lan}',1);
mbs{com,lan} = mean(bs{com,lan},2);
sbs{com,lan} = std(bs{com,lan});
ebs{com,lan} = sbs{com,lan}/sqrt(length(bs{com,lan}));
end


barra = mbs{com,1};
for lan = 2:length(LAN)
barra = cat(2,barra,mbs{com,lan}); 
end

figure,bar(barra), hold on,
for lan = 1:length(LAN)
line([lan,lan],[ mbs{com,lan}-ebs{com,lan} , mbs{com,lan}+ebs{com,lan} ],'Color','red','LineWidth',3)
end

comp = 0;
for n = 1:length(LAN)
    for m = (n+1):length(LAN)
p{com}(n,m) = ranksum(bs{com,n},bs{com,m});
p{com}(m,n) = p{com}(n,m);

    comp = comp + 1;
    end
    p{com}(n,n) = 1;
end
%
% correcci?n por comparaciones multiples de significancia
%
alfa = (0.05/comp);
hc{com} = p{com}<=alfa;
disp( [ 'se considero alfa = ' num2str(alfa) ] )
disp( [ 'por correcion por comparaciones multiples'] )
%
clear b
end