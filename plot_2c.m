function plot_2c(mat1, mat2,CHAN_LAB, EJEX,EJEF,normal,CAXIS,electrode,area,stata)
% 
% e.g. plot_2c(controles, obejtos, chanlocs, EjeX,EjeF,1,[-4 4],[1])
%
% mat1 y mat2 = signal in matrix 4d
% CHAN_LAB = estructure with channel labels (CHAN_LAB(x).labels) eeglab.
% EJEX = times
% EJEF = 
% normal = 1 -> z-score
% electrode = electrodos a graficar, si el m??s de uno lo promedia
% area = area de las caratas que enmarca,
% dando las cordeanas XY de esquinas en la diagonal:
%         [x1 y1 x2 y2; x1b y1b x2b y2b;....], por defecto [0]
%
% Big Induced TFs charts plotting
%
% big figure

if size(mat1)~=size(mat2)
    error('matrices tienen que ser de iguales dimenciones')
end
if nargin < 10, stata = 0;end
if nargin < 9, area = 0;end
if nargin < 8, electrode = 0;end
if nargin < 7, CAXIS = 0 ; 
 pregunta = input('Defin color axis (e.g [-4 4]) []: ');
    if isempty(pregunta)
        CAXIS = 0 ;
    else
        CAXIS = pregunta;
    end
    clear pregunta



end



if nargin < 6, 
   pregunta = input('Do you want normalize with z-score Y/N [N]: ', 's');
    if isempty(pregunta)
        pregunta = 'N';
    end
    if pregunta == 'N'
        normal = 0;
    elseif pregunta == 'Y'
        normal = 1;
    end
    clear pregunta
end



if nargin < 5, 
   pregunta = input('limit of frecuencies (e.g [1 100]) []: ');
    if isempty(pregunta)
        [x y z] = size(mat1);
        EJEF = 1:1:x;
        clear x y z 
    else
        [x y z] = size(mat1);
        EJEF = pregunta(1):((pregunta(2)-pregunta(1)+1)/x):pregunta(2); 
        clear x y z 
    end
    clear pregunta
end   
if nargin < 4,
    [x y z] = size(mat1);
    pregunta = input('Do you want re-build time line (Y/N)? : ','s');
    if pregunta == 'N'
        EJEX = 0:1:z
        
    elseif pregunta == 'Y'
          
        [x y z] = size(mat1);
        TRANGE = input('Initial time (e.g -2500): ');
        FE = input('Sampling frequency in Hz. (e.g 2048): ');
        WinSig = input('windows of signal (number of points) for fft: ');
        Step =input('number of time points between succesive computation windows: ');
        Nwins = z;
        EJEX = TRANGE + (1000/FE)* cumsum([fix(WinSig/2),repmat(Step,1,Nwins-1)]);
    end
    
    clear pregunta
    clear x y z 
end

hh = figure; set(hh, 'Position', [15 40 1138 763], 'Color', [0.9 0.8 1 ], 'Name', inputname(1)); 

chanlocs = CHAN_LAB;



if normal ==1
    
    datab1=mean(mat1,4);
    datab2=mean(mat2,4);%
    data_1 = normal_z(datab1);
    data_2 = normal_z(datab2);
else
    data_1 =mean(mat1,4);
    data_2 =mean(mat2,4);    
    datab1=data_1;
    datab2=data_2;
end 
if sum(sum(sum(stata))) ~= 0
stata = squeeze(stata(:,electrode,:));
end

if electrode == 0
[x y z ] = size(data_1);
if z > 1 && y == 1
    data_1 = squeeze(data_1);
    data_2 = squeeze(data_2);
    datab1 = squeeze(datab1);
    datab2 = squeeze(datab2);
    
elseif z > 1 && y > 1
    data_1 = squeeze(mean(data_1,2));
    data_2 = squeeze(mean(data_2,2));
    datab1 = squeeze(mean(datab1,2));
    datab2 = squeeze(mean(datab2,2));
end
else
    data_1 = squeeze(mean(data_1(:,electrode,:),2));
    data_2 = squeeze(mean(data_2(:,electrode,:),2));
    datab1 = squeeze(mean(datab1(:,electrode,:),2));
    datab2 = squeeze(mean(datab2(:,electrode,:),2));
    
end

    %electrode = num2str(i);
    v_time = linspace(-2.5,0.1,0.5);
    v_time_plot= linspace(v_time(1), v_time(end), length(data_1));
    
for ii = 1:4
    if ii == 1
        DATA=data_1;
    elseif ii == 2
        DATA=data_2;
    elseif ii == 3
        DATA=(datab2-datab1);
    elseif ii ==4
        DATA=stata;
        %if normal == 1
         %   DATA = normal_z(DATA);
        %end
    end
    % plot tf map in corresponding subplot
    % s_temp = ['s' electrode];
    subplot(2,2,ii); %v_time_plot,
    imagesc(EJEX,EJEF, DATA); % set(eval(s_temp), 'ButtonDownFcn', 'plot_channel_tf(i,i_path,i_file,m_path,nrm,bsl)' );
    %set(eval(s_temp),'XTick', [], 'YTick', []) %, 'XColor', [1 1 1], 'YColor', [1 1 1]);
    shading interp;
    axis tight
    if ii < 3
    caxis(CAXIS);
    elseif ii ==3
        caxis([-100 100]);
    elseif ii ==4
        caxis([0 1]);
    end
    k = line([0 0], [0 100], [max(max(DATA)) max(max(DATA))], 'LineWidth', [1.2], 'Color', [0 0 0]);
%     l = line([-1100 -1100], [4 80], [max(max(data_resamp)) max(max(data_resamp))], 'LineWidth', [1.2], 'Color', [1 0 0]);
    
%%%%%%%%% area de interes%%%%%%%%%%%
[fil_a col_a] = size(area);
if length(area) == 4
    for c = 1:fil_a 
    line([area(c,1) area(c,3)], [area(c,2) area(c,2)], 'LineWidth', [2], 'Color', [1 0 0]);
    line([area(c,3) area(c,3)], [area(c,2) area(c,4)], 'LineWidth', [2], 'Color', [1 0 0]);
    line([area(c,1) area(c,3)], [area(c,4) area(c,4)], 'LineWidth', [2], 'Color', [1 0 0]);
    line([area(c,1) area(c,1)], [area(c,4) area(c,2)], 'LineWidth', [2], 'Color', [1 0 0]);
    %%%%%% OJO : arreglar 
        t1 = fix(area(c,1)*2048/1000);
        t2 = fix(area(c,3)*2048/1000);
        
    [W(c) Wh(c)] = wilcoxon(...
        mat1(area(c,2):area(c,4),electrode,...
        t1:t2,:)...
        ,mat2(area(c,2):area(c,4),electrode,...
        t1:t2,:)...
        ,0.05,1);
    
    
    
    end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
     
    %tt = text(0, 0, chanlocs(i).labels, 'FontSize', 15, 'FontWeight', 'bold');
    %%%%%%%%%%%%%%% eje F %%%%%%%%%%%%%%%%%%%%
%     a = EJEF(1);
%     b = EJEF(length(EJEF));
%     c = floor((b-a)/50);
%     c = 10 * c;
%     for xx = [a:c:b]%xx = [0:20:100]
%     text(-2500, xx, num2str(xx), 'FontSize', 9);
%     end
%     %%%%%%%%%%%%%%% eje T %%%%%%%%%%%%%%%%%%%%%%
%     a = EJEX(1);
%     b = EJEX(length(EJEX));
%     c = floor((b-a)/5000);
%     c = 10 * c;
%     for xx =[-2000:500:500]% [a:1000:b]%xx = 
%     text(xx, 0 , num2str(xx/1000), 'FontSize', 9);
%     end
%     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     clear data
end





% annotation(gcf,'textbox','String',['FIGURA: electrodo'...
%     num2str(electrode) 'area1 significancia =' ... num2str(Wh(1)) ...
%     'area2 significancia =' ... num2str(Wh(2))],...
%     'Position',[0.6 0.30 0.2 0.2], 'FitBoxToText','off',...
%     'LineStyle','none',...
%     'FontSize', 20, 'FontWeight', 'bold');
colorbar([0.9 0.01 0.02 0.4]);






