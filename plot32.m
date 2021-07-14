function [EJEX, EJEF] = plot32(DATA, CHAN_LAB, EJEX, EJEF,normal,CAXIS,title)
% 
% e.g. plot32(controles, chanlocs, EjeX,EjeF,1,[-4 4])
%
% DATA = signal in matrix 3d
% CHAN_LAB = estructure with channel labels (CHAN_LAB(x).labels) eeglab.
% EJEX = times
% EJEF = 
% normal = 1 -> z-score
%
% Big Induced TFs charts plotting
%
% big figure
if nargin < 7, title = 'Figura' ;
end
if nargin < 6, CAXIS = 0 ; 
 pregunta = input('Defin color axis (e.g [-4 4]) []: ');
    if isempty(pregunta)
        CAXIS = 0 ;
    else
        CAXIS = pregunta;
    end
    clear pregunta



end



if nargin < 5, 
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



if nargin < 4, 
   pregunta = input('limit of frecuencies (e.g [1 100]) []: ');
    if isempty(pregunta)
        [x y z] = size(DATA);
        EJEF = 1:1:x;
        clear x y z 
    else
        [x y z] = size(DATA);
        EJEF = pregunta(1):((pregunta(2)-pregunta(1)+1)/x):pregunta(2); 
        clear x y z 
    end
    clear pregunta
end   
if nargin < 3,
    [x y z] = size(DATA);
    pregunta = input('Do you want re-build time line (Y/N)? : ','s');
    if pregunta == 'N'
        EJEX = 0:1:z
        
    elseif pregunta == 'Y'
          
        [x y z] = size(DATA);
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
data_all=DATA;

%%%%%%%%%%%%%%%%%%%%% setting up plot for all electrodes ~ in head position
% all subplots in normalized coordinates [0.0 1.0]: subplot('position',[left bottom width height])


% % T7

for s = 7
    num = num2str(s);
    hdl_a = strrep('sX = subplot(''position'',[0.002 Y 0.1 0.13]);','X', num);
    delta = 0.431;
    hdl_b = strrep(hdl_a,'Y', num2str(delta));
    eval(hdl_b)
end

% % P7, CP5, FC5, F7
ct = 0;
for s = [11 10 6 3]
    ct = ct+1;
    num = num2str(s);
    hdl_a = strrep('sX = subplot(''position'',[0.121 Y 0.1 0.13]);','X', num);
%   delta = 0.22:0.14:0.64;
    delta = 0.242:0.181:0.785;
    hdl_b = strrep(hdl_a,'Y', num2str(delta(ct)));
    eval(hdl_b)
end

% % Fp1, AF3, F3, C3, P3, PO3, O1
ct = 0;
for s = [1 2 4 8 12 14 15]
    ct = ct+1;
    num = num2str(s);
    hdl_a = strrep('sX = subplot(''position'',[0.232 Y 0.1 0.13]);','X', num);
    delta = linspace(0.852,0.012,7);
    hdl_b = strrep(hdl_a,'Y', num2str(delta(ct)));
    eval(hdl_b)
end

% % CP1, FC1
ct = 0;
for s = [9 5]
    ct = ct+1;
    num = num2str(s);
    hdl_a = strrep('sX = subplot(''position'',[0.343 Y 0.1 0.13]);','X', num);
%     delta = 0.15:0.14:0.71;
    delta = [0.3230 0.5040];
    hdl_b = strrep(hdl_a,'Y', num2str(delta(ct)));
    eval(hdl_b)
end

% % Oz, Pz, Cz, Fz
ct = 0;
for s = [16 13 32 31]
    ct = ct+1;
    num = num2str(s);
    hdl_a = strrep('sX = subplot(''position'',[0.454 Y 0.1 0.13]);','X', num);
    delta = 0.142:0.181:0.685;
    hdl_b = strrep(hdl_a,'Y', num2str(delta(ct)));
    eval(hdl_b)
end

% % FC2, CP2
ct = 0;
for s = [26 22]
    ct = ct+1;
    num = num2str(s);
    hdl_a = strrep('sX = subplot(''position'',[0.565 Y 0.1 0.13]);','X', num);
%     delta = 0.15:0.14:0.71;
    delta = [0.5040 0.3230];
    hdl_b = strrep(hdl_a,'Y', num2str(delta(ct)));
    eval(hdl_b)
end

% % Fp2, AF4, F4, C4, P4, PO4, O2
ct = 0;
for s = [30 29 27 23 19 18 17]
    ct = ct+1;
    num = num2str(s);
    hdl_a = strrep('sX = subplot(''position'',[0.676 Y 0.1 0.13]);','X', num);
    delta = linspace(0.852,0.012,7);
    hdl_b = strrep(hdl_a,'Y', num2str(delta(ct)));
    eval(hdl_b)
end

% % P8, CP6, FC6, F8
ct = 0;
for s = [20 21 25 28]
    ct = ct+1;
    num = num2str(s);
    hdl_a = strrep('sX = subplot(''position'',[0.787 Y 0.1 0.13]);','X', num);
%     delta = 0.22:0.14:0.64;
    delta = 0.242:0.181:0.785;
    hdl_b = strrep(hdl_a,'Y', num2str(delta(ct)));
    eval(hdl_b)
end

% % T8
ct = 0;
for s = 24
    num = num2str(s);
    hdl_a = strrep('sX = subplot(''position'',[0.898 Y 0.1 0.13]);','X', num);
    delta = 0.431;
    hdl_b = strrep(hdl_a,'Y', num2str(delta));
    eval(hdl_b)
end



%%%%%%%%%%%%%%%%% load charts, normalize and plot in corresponding location
%baseline = [1 1024];
%load chanlocs % load electrode name



chanlocs = CHAN_LAB;

if normal ==1
data_all = normal_z(data_all);
end 
if normal ==2
data_all = normal_m(data_all);
end 



for i = 1:32
   
    data = squeeze(data_all(:,i,:));
    % loading
     electrode = num2str(i);
%     data_file = ['G:\ExploResults\Ind_aver_elec_' electrode '.mat'];
%     load(data_file, 'ind_aver_elec', 'v_freq_out');
    v_time = linspace(-2.5,0.1,0.5);
    
    % Normalization (in z-score) and packing
    if normal == 1
               %  data = normal_z(data)      
%         for k = 1:s_Nvoice
%             data_plot(k,:) = ((ind_aver_elec(k,:)-mean(ind_aver_elec(k, baseline(1):baseline(2))))/std(ind_aver_elec(k, baseline(1):baseline(2))));
%         end
%     else
%         data_plot = ind_aver_elec;
    end
    
    % resampling for plotting purposes
%     for r = 1:size(ind_aver_elec,1)
%         data_resamp(r,:) = resample(data_plot(r,:),1,20); % originally 10
%     end
     v_time_plot= linspace(v_time(1), v_time(end), length(data));

    
%     clear ind_aver_elec
    
    % plot tf map in corresponding subplot
    s_temp = ['s' electrode];
    subplot(eval(s_temp)); %v_time_plot,
    %imagesc(EJEX,EJEF, data); % set(eval(s_temp), 'ButtonDownFcn', 'plot_channel_tf(i,i_path,i_file,m_path,nrm,bsl)' );
    pcolor(EJEX,EJEF,double(data));
    %set(eval(s_temp),'XTick', [], 'YTick', []) %, 'XColor', [1 1 1], 'YColor', [1 1 1]);
    shading interp;
    %axis tight
    if sum(CAXIS) ~= 0
    caxis(CAXIS)
    end
    k = line([0 0], [0 100], [max(max(data)) max(max(data))], 'LineWidth', [1.2], 'Color', [0 0 0]);
%     l = line([-1100 -1100], [4 80], [max(max(data_resamp)) max(max(data_resamp))], 'LineWidth', [1.2], 'Color', [1 0 0]);
    
%%% area de interes   
    %line([-2000 5], [0 5], [max(max(data)) max(max(data))], 'LineWidth', [1.2], 'Color', [0 0 0]);



    tt = text(0, 0, chanlocs(i).labels, 'FontSize', 15, 'FontWeight', 'bold');
%     %%%%%%%%%%%%%%% eje F %%%%%%%%%%%%%%%%%%%%
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
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    clear data
    
end

annotation(gcf,'textbox','String',[ title ],...
    'Position',[0.35 0.9 0.3 0.1], 'FitBoxToText','off',...
    'LineStyle','none',...
    'FontSize', 20, 'FontWeight', 'bold');
colorbar([0.9 0.01 0.02 0.4]);

axcopy(gcf);