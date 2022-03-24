function [inspk] = wave_features(spikes, cfg)
% NOTA: este script es un PLAGIO
% NO DISTRIBUIR BAJO NINGUNA CIRCUMSTANCIA
%
% ************************cfg************************
% - scales
% - feature
% - inputs
%
% ********************DEPENDENCIAS********************
% - wavedec (Wavelet Toolbox)
%

scales = cfg.scales;
feature = cfg.feature;
inputs = cfg.inputs;
nspk = size(spikes, 1);
ls = size(spikes, 2);

switch feature
    case 'wav'
        cc=zeros(nspk,ls);
        for i=1:nspk % Wavelet decomposition
            [c,l]=wavedec(spikes(i,:),scales,'haar');
            cc(i,1:ls)=c(1:ls);
        end
        sd = zeros(1,ls);
        for i=1:ls % KS test for coefficient selection
            aux = cc(:,i);
            thr_dist = std(aux) * 3;
            thr_dist_min = mean(aux) - thr_dist;
            thr_dist_max = mean(aux) + thr_dist;
            
            aux = aux( aux>thr_dist_min & aux<thr_dist_max );
            if length(aux) > 10;
                [ksstat]=test_ks(aux);
                sd(i)=ksstat;
            else
                sd(i)=0;
            end
        end
        [max, ind]=sort(sd, 'descend');
        coeff=ind(1:inputs);
    case 'pca'
        [C,S,L] = princomp(spikes);
        cc = S;
        inputs = 3; 
        coeff(1:3)=[1 2 3];
end

inspk=zeros(nspk,inputs);
for i=1:nspk
    for j=1:inputs
        inspk(i,j)=cc(i,coeff(j));
    end
end
