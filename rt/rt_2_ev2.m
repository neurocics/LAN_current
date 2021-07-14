function rt_2_ev2(RT,cfg)
% v.0.0.0
%     <*LAN)<|
% write ev2 file from reaction time (RT) structure
%
% cfg.filename =       'nombredearchivo.log'
% cfg.where
% cfg.srate =  n ; %
% cfg.first_laten = 45, % Corregi la priemra latencia 
% 

if isfield(cfg,'unit')
RTunit = cfg.unit;
elseif (isfield(RT,'cfg') && isfield(RT.cfg,'unit')) 
RTunit = RT.cfg.unit;  
else
RTunit = 'ms';
end

   switch RTunit
        case 'ms'
            unit = 1000;
        case 's'
            unit = 1;
   end
    
laten = fix(RT.laten .* (unit/1000));

getcfg(cfg,'first_laten','no')
if isnumeric(first_laten)
f_laten = fix(first_laten .* (unit/1000));
f_laten = f_laten - laten(1);
laten = laten + f_laten;
end

getcfg(cfg,'filename','ev2file.ev2')
getcfg(cfg,'where','')

fid = fopen([ where filename ],'wt');
maxx = fix(log10(max(laten)))+1;
 %EF = [' %s \t '];
       for  f = 1:length(RT.est)
            fprintf(fid,'%1.0f \t',f);
            fprintf(fid,'%3.0f \t',RT.est(f));
            fprintf(fid,'%1.0f \t',0);
            fprintf(fid,'%1.0f \t',0);
            fprintf(fid,'%1.0f \t',0);
            fprintf(fid,['%' num2str(maxx) '.0f \n'],laten(f));
       end
       
       

end