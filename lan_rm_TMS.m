function LAN = lan_rm_TMS(LAN,cfg)
%  v.0.3 en prueba 
%
% cfg.events  = [x1 x2 ... ] % evente labels that indicated TMS pusle
% cfg.times  = [s1 s2]      % time to interpolated betweeen TMS pulse  
% cfg.npulse = n            % number o oulse to be remove togetehr (number of pulse of a tren)
% cfg.edge = s3;
% cfg.time_lim = s4;         % limit of time to the segmetation, that is, if
%                             there no n pulse in s4 seg,  cut the segemtation with less that n pulses  

EV = getcfg(cfg,'events');     % EV = find(ifcellis(LAN.RT.OTHER.names,{'S 80','S 81','S 82','S 83','S 84'}));
P.remp = getcfg(cfg,'times');  %  [-0.0025 0.015];
npulse = getcfg(cfg,'npulse',5); 
rm = getcfg(cfg,'rm',true); 
seg = getcfg(cfg,'seg',false); 
edge = getcfg(cfg,'edge',0.1);
time_lim = getcfg(cfg,'time_lim',[]);


LAN = lan_check(LAN);
edge = edge*LAN.srate;

if isempty(time_lim)
    time_lim=Inf;
else
    time_lim=time_lim*1000;
end

%
for e = 1:LAN.nbchan;
    %e=50
    disp(e)
    %nmod = fix(n_mod*(0.5 + rand(1)/2));
    data = (LAN.data{1}(e,:));
    

laten_r = P.remp * LAN.srate;
n_ica = 1;
nfix=0;
%uno_laten = LAN.RT.laten(EV(1));
%dosf=0;
 for  evs_l = 1:length(EV);%
     evs=EV(evs_l);
    
     laten_e = fix( laten_r + (LAN.RT.laten(evs)) * (LAN.srate/1000));
     
     data( laten_e(1):laten_e(2) ) = NaN;
     

     if ( mod(evs_l+nfix,npulse)==0 )   || evs_l==length(EV)   || ((LAN.RT.laten(EV(evs_l+1)) - LAN.RT.laten(evs))>time_lim)
        
        % if ((LAN.RT.laten(evs) - uno_laten)>time_lim)
          if mod(evs_l+nfix,npulse)>0;
             nnpulse = npulse - (npulse-mod(evs_l+nfix,npulse));
             nfix = nfix + (npulse-mod(evs_l+nfix,npulse));
             %dosf=1;
             %uno_laten = LAN.RT.laten(EV(evs_l));

         else
             
             nnpulse=npulse;
             %dosf=0; 
             %if evs_l<length(EV)
             %   uno_laten = LAN.RT.laten(EV(evs_l-1));
            %end
          end
         
         
          
         tmp =  fix(    LAN.RT.laten(EV(evs_l-(nnpulse-1))).*(LAN.srate/1000)  - edge  ): fix((LAN.RT.laten(evs).*(LAN.srate/1000)+edge));
         
         
         % PARAica{n_ica}(e,:) =  
         
         
         dt = data(tmp);
         if seg
         PARAica{n_ica}(e,:) = dt(~isnan(dt));
         end
         n_ica=n_ica+1;
         if rm
         dt = interpolate_nans(dt);
         end
         data(tmp)=dt;
         if mod(evs_l,npulse*4)==0
         fprintf('.');
         end
         
         
         
         
         
     end
     
 end
    
 %data = interpolate_nans(data);
 
LAN.data{1}(e,:) = (data);
disp([ 'elec'  num2str(e) ' -> OK'])




clear data
end 
 
LAN.tms_out.P=P;

if seg && ~rm 
   LAN.data= PARAica;
end

LAN = rmfield(LAN,'tag');
LAN = lan_check(LAN);

end
%
%save LAN_tms_out_nans LAN -v7.3
% 
% LAN.data = PARAica;
% LAN = lan_check(LAN);
% 
% %
%  
%     LAN = rmfield(LAN,'tag');
% LAN = lan_check(LAN);
% LAN = vol_thr_lan(LAN,200,'bad:V');
%     cfga.thr    =    [2.5 0.3] ;%       %   (sd %spectro)
%     cfga.tagname=    'bad:A';%
%     cfga.frange=     [1 45];%
%     %cfga.cat =1;%
%     cfga.method =  'f';%'f';% orLAN
%     cfga          .nch = 'all';%
% LAN = fftamp_thr_lan(LAN,cfga);  
% 
% % marcarmalos todos los que tengan dos o mas canales detectados 
%     n=1; 
%     LAN.accept = sum(LAN.tag.mat(3:end,:),1)<=n;
%     
%     while sum(LAN.accept)<170;
%         n=n+1;
%         LAN.accept = sum(LAN.tag.mat(3:end,:),1)<=n;
%     end
% 
%  
%     disp(' ')
%     disp('******************************')
%     disp([' Esayos para el ICA::  ' num2str(sum( LAN.accept)) '   '])
%     disp('******************************')
%     
%     [weights,sphere] = runica(cat(2,LAN.data{logical(LAN.accept)}),'extended', 1,'pca',LAN.nbchan-1);
%     LAN.ica_weights = weights;
%     LAN.ica_sphere = sphere;
%       disp('processing...  OK')
%     %save LANtms_ica LAN
