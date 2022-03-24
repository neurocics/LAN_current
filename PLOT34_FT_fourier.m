function PLOT34_FT_fourier(LAN,EjeF,EjeX)
bs = 60;


h2=figure;

if ~isfield(LAN, 'freq_m') 
    freq = LAN.freq;
    LAN = mean_freq(LAN,3);
end
    AA = LAN.freq_m;
    


[fil3 col3 tri3] = size(AA);



for e=1:34

    % NORMALIZATION %
    for frec3 = 1:fil3
        MeanMatTF2 = mean(squeeze(AA(frec3,1:bs,e))');%*ones(1,timepoints);
        StdMatTF2 = std(squeeze(AA(frec3,1:bs,e))');%*ones(1,timepoints);
        NF2(frec3,:) = (squeeze(AA(frec3,:,e)) - MeanMatTF2)./ StdMatTF2;
    end
    
    
    if e==1
        ee=4;
    end
    if e==2
        ee=6;
    end
    if e==3
        ee=12;
    end
    if e==4
        ee=13;
    end
    if e==5
        ee=14;
    end
    if e==6
        ee=15;
    end
    if e==7
        ee=16;
    end
    if e==8
        ee=20;
    end
    if e==9
        ee=22;
    end
    if e==10
        ee=23;
    end
    if e==11
        ee=24;
    end
    if e==12
        ee=26;
    end
    if e==13
        ee=29;
    end
    if e==14
        ee=31;
    end
    if e==15
        ee=32;
    end
    if e==16
        ee=33;
    end
    if e==17
        ee=35;
    end
    if e==18
        ee=47;
    end
    if e==19
        ee=40;
    end
    if e==20
        ee=41;
    end
    if e==21
        ee=42;
    end
    if e==22
        ee=53;
    end
    if e==23
        ee=56;
    end
    if e==24
        ee=49;
    end
    if e==25
        ee=50;
    end
    if e==26
        ee=51;
    end
    if e==27
        ee=62;
    end
    if e==28
        ee=66;
    end
    if e==29
        ee=68;
    end
    if e==30
        ee=70;
    end
    if e==31
        ee=28;
    end
    if e==32
        ee=36;
    end
    if e==33
        ee=58;
    end
    if e==34
        ee=60;
    end


    subplot(8,9,ee)
    hold on
    %     imagesc(flipud(squeeze(MA(:,:,e))));
    pcolor(EjeX,EjeF, NF2);
    shading interp
    %title([textdata(e,5)],'FontSize',8)
    %title(num2str(e),'FontSize',8)
    
    set(gca,'XLim',[min(EjeX) max(EjeX)]);
    set(gca,'YLim',[min(EjeF) max(EjeF)]);
    caxis([-15 20])
    %     curpos =
    %     set(gca,'XTicklabel',[,'-200';'0';'';'200';])
    %     set(gca,'YTicklabel',['','','',''])


    % allow popup window of single map with mouse click
end
hold off
%maximize(h2);
axcopy(gcf);

clear e
clear ee

end





%%WHOLE POWER%%%%%%%%%
% 
% h=figure;
% [fil col tri] = size(MA)
% for e=1:34
% 
%     % NORMALIZATION %
%     for frec = 1:fil
%         MeanMatTF = mean(squeeze(MA(frec,1:bs,e))');%*ones(1,timepoints);
%         StdMatTF = std(squeeze(MA(frec,1:bs,e))');%*ones(1,timepoints);
%         NF(frec,:) = (squeeze(MA(frec,:,e)) - MeanMatTF)./ StdMatTF;
%     end
%     if e==1
%         ee=4;
%     end
%     if e==2
%         ee=6;
%     end
%     if e==3
%         ee=12;
%     end
%     if e==4
%         ee=13;
%     end
%     if e==5
%         ee=14;
%     end
%     if e==6
%         ee=15;
%     end
%     if e==7
%         ee=16;
%     end
%     if e==8
%         ee=20;
%     end
%     if e==9
%         ee=22;
%     end
%     if e==10
%         ee=23;
%     end
%     if e==11
%         ee=24;
%     end
%     if e==12
%         ee=26;
%     end
%     if e==13
%         ee=29;
%     end
%     if e==14
%         ee=31;
%     end
%     if e==15
%         ee=32;
%     end
%     if e==16
%         ee=33;
%     end
%     if e==17
%         ee=35;
%     end
%     if e==18
%         ee=47;
%     end
%     if e==19
%         ee=40;
%     end
%     if e==20
%         ee=41;
%     end
%     if e==21
%         ee=42;
%     end
%     if e==22MA
%         ee=53;
%     end
%     if e==23
%         ee=56;
%     end
%     if e==24
%         ee=49;
%     end
%     if e==25
%         ee=50;
%     end
%     if e==26
%         ee=51;
%     end
%     if e==27
%         ee=62;
%     end
%     if e==28
%         ee=66;
%     end
%     if e==29
%         ee=68;
%     end
%     if e==30
%         ee=70;
%     end
%     if e==31
%         ee=28;
%     end
%     if e==32
%         ee=36;
%     end
%     if e==33
%         ee=58;
%     end
%     if e==34
%         ee=60;
%     end
% 
% 
%     subplot(8,9,ee)
%     hold on
%     %     imagesc(flipud(squeeze(MA(:,:,e))));
%     pcolor(EjeX,EjeF,(NF2 - flipud(NF)));
%     shading interp
%     title([textdata(e,5)],'FontSize',8)
%     %title(num2str(e),'FontSize',8)
%     
%     set(gca,'XLim',[min(EjeX) max(EjeX)]);
%     set(gca,'YLim',[min(EjeF) max(EjeF)]);
%     caxis([-15 20])
%     %     curpos =
%     %     set(gca,'XTicklabel',[,'-200';'0';'';'200';])
%     %     set(gca,'YTicklabel',['','','',''])
% 
% 
%     % allow popup window of single map with mouse click
% end
% hold off
% maximize(h);
% axcopy(gcf);
% 
% clc