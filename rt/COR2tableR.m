function COR2tableR(COR,cfg) 
%    <*LAN)<] 
%    v.0.5
%
% COR2TABLER write a table for R in a .txt file (one file per electrode)
% COR2TABLER(COR,cfg) 
%       cfg.where           carpeta
%       cfg.filename        nombre del archivo
%       cfg.electrode       indice del electrodo
%       cfg.format  =  'txt', 'mat','tsv'[BIDS]
%       cfg.delimiter = '\t'  (';' ',' )
%       cfg.units = 's'
%
%       if COR is empty, is necesary defined:
%
%       cfg.subject = {} {} ; nombre de sujetos
%       cfg.namefile = '%S\COR'
%       cfg.namemat  = 'COR' 
%  Pablo Billeke

%   28.12.2023  (PB) add compatibility to BIDS format 
%   24.12.2012  (PB)
%   10.01.2012  (PB FZ) add correct
%   09.12.2011  (PB)  fix bug
%   10.11.2011  (PB)  add perfile options
%   08.06.2011  (PB)  
%   04.04.2011  (PB)

%  AGREGAR CORRECT !!!!!


if nargin == 0
   help COR2tableR
   if strcmp(lanversion('t'),'devel')
   edit COR2tableR
   end
   return
elseif nargin == 1;
cfg.format = 'tsv';
%cfg.name = 'TABLE.cvs'
end

units = getcfg(cfg,'units','s');
switch units
    case 's'
        unitst=0.001;
    case 'ms'
        unitst=1;
    otherwise
        unitst=1;
end
format = getcfg(cfg,'format','tsv');

if nargin == 1, cfg=[];end

if isfield(cfg,'where')
    where = cfg.where;
else
    where = [];
end

if isfield(cfg,'filename')
    filename = cfg.filename;
else
    filename = [ inputname(1)  '.' format];
end

if isfield(cfg,'electrode')
    electrode = cfg.electrode;
else
    electrode = 1;%
end

if isfield(cfg,'subject') && isempty(COR)
    perfile=true;
else
    perfile=false;
end


getcfg(cfg,'delimiter','\t')

%%% searching header and body
nh = 0;

if isfield(COR,'RT') &&  isfield(COR.RT,'OTHER')
   COR.OTHER=COR.RT.OTHER; 
end


%%%
if perfile
   
   
   for s = 1:length(cfg.subject); 
   nf = strrep(cfg.namefile,'%S',cfg.subject{s});
   nm = strrep(cfg.namemat,'%S',cfg.subject{s});
   %
   fprintf('\n')
   fprintf(cfg.subject{s})
   %
   load(nf,nm);
   if ~strcmp('COR',nm)
   eval(['COR = ' nm ' ;']);
   eval(['clear ' nm ' ;']);
   end
   ne = 0;
   te=length(electrode);
   
   for ee = electrode;
       ne=ne+1;
       
   %%% create file
   %if isempty()
   filename2 = strrep(filename ,'%E' , num2str(ee) );
   switch format
       case {'txt', 'tsv'}
           if s==1
           fid{ee} = fopen([ where filename2 ],'wt');
           else
           fid{ee} = fopen([ where filename2 ],'a');    
           end
       case 'mat'
           if s==1
           fid{ee} = [];
           else
           %load([ where filename2 ],'data_MAT_R')    
           %fid{ee} = data_MAT_R;
           %clear data_MAT_R
           end           
   end
   
   if (( mod((20*ne/te),1)-mod((20*(ne+1)/te),1) )>=0 )||ne==1;
       p=round((100*ne/te));
   fprintf(['.' num2str(p) '%%' ])
   end
   if isfield(cfg,'nofield')
       if iscell(cfg.nofield)
          for f = 1:length(cfg.nofield)
             try  
                 COR = rmfield(COR,cfg.nofield{f});
             end
          end 
       else
           try
           COR = rmfield(COR,cfg.nofield);
           end
       end

   end
      clear HEADER body
      nh = 0;
   
   %%% in RT
   if isfield(COR,'rt')
    COR.RT = COR;
    end
    if isfield(COR,'RT')
        % onset 
        if isfield(COR.RT,'laten')
            nh = nh +1;
            HEADER{nh} = 'onset';
            body{nh} = COR.RT.laten*unitst;

            nh = nh +1;
            HEADER{nh} = 'duration';
            if isfield(COR, 'OTHER') && isfield(COR.OTHER, 'duration')
            body{nh} = COR.OTHER.duration;
            else
            body{nh} = ones(size(COR.RT.laten));    
            end
        end  


        if isfield(COR.RT,'est')
            nh = nh +1;
            HEADER{nh} = 'value';
            body{nh} = COR.RT.est;
        end
        if isfield(COR.RT,'rt')
            nh = nh +1;
            HEADER{nh} = 'rt';
            body{nh} = COR.RT.rt;
        end

        if isfield(COR.RT,'resp')
            nh = nh +1;
            HEADER{nh} = 'response';
            body{nh} = COR.RT.resp;
        end
  
        if isfield(COR.RT,'correct')
            nh = nh +1;
            HEADER{nh} = 'correct';
            body{nh} = COR.RT.correct;
        end  
        if isfield(COR.RT,'good')
            nh = nh +1;
            HEADER{nh} = 'good';
            body{nh} = COR.RT.good;
        end  

    end
        %%% in OTHER
    if isfield(COR,'OTHER')
        campos = sort(fields(COR.OTHER))';

        for ncm = 1:length(campos)
            nh = nh +1;
            HEADER{nh} = campos{ncm};
            eval([' body{nh} = COR.OTHER.' campos{ncm} ' ;']);
        end
    end

    %%% in FREQ
    if isfield(COR,'FREQ')
        nfreq = size(COR.FREQ,2);

        for ncm = 1:nfreq
            nh = nh +1;
            HEADER{nh} = COR.FREQ(ncm).name;
            pow = [];
            for ix = 1:length(COR.FREQ(ncm).powspctrm)
                if isempty(COR.FREQ(ncm).powspctrm{ix})
                    np = -99;
                elseif (sum(size(COR.FREQ(ncm).powspctrm{ix}))==2)&&(COR.FREQ(ncm).powspctrm{ix}==-99)
                    np = -99; 
                else
                    np = squeeze(COR.FREQ(ncm).powspctrm{ix}(:,ee,:));
                end
            pow = cat(1,pow,np);
            end
            body{nh} =   pow;
        end
    end

    %%%% writing the file

       %%% header only once
       %%% only txt
       if strcmp(format,'txt') || strcmp(format,'tsv')
       if s==1
           EF = ['%s' delimiter ];
           for  f = 1:[size(HEADER,2)-1]
                fprintf(fid{ee},EF,HEADER{f}); 
           end
           fprintf(fid{ee},'%s\n',HEADER{size(HEADER,2)});
       end
       end
       
       
       %%% body
       
       ntrail = max(size(body{1}));
       ncoef = max(size(body));
       cellbody = cell(ntrail,ncoef);
       
       %case format
       switch format
           case {'txt','tsv'}
               %format
               for nb = 1:ncoef;
                  cellbody(:,nb) = mat_t_cell(body{nb});
                  if ischar(cellbody{1,nb})
                     dformat{nb} = ['%s'];
                  else
                     % optimizar escritura
                        p = body{nb};
                        p(p<=0)=[];
                        sobre =   fix(max(log10(p)) + 1);
                        if sobre<1; sobre=1; end
                        bajo  =    abs(fix(min(log10(abs(p))) - 6));
                        dformat{nb} = ['%' num2str(sobre)  '.' num2str(bajo)  'f'];
                  end
                  if nb == ncoef
                     dformat{nb} = [ dformat{nb} '\n'];
                  else
                     dformat{nb} = [ dformat{nb} delimiter ];
                  end
               end




               for nt = 1:ntrail
                   for nc = 1:ncoef
                   fprintf(fid{ee},dformat{nc},cellbody{nt,nc}); 
                   end
               end

               %fclose(fid);
               fclose(fid{ee});
               %
           case 'mat'
               %format
               for nb = 1:ncoef;
                  cellbody(:,nb) = mat_t_cell(body{nb});
                  if ischar(cellbody{1,nb})
                     dformat{nb} = ['%s'];
                  else
                     % optimizar escritura
                      dformat{nb} = ['%f'];
                  end
               end




               %for nt = 1:ntrail
               %    for nc = 1:ncoef
                   
               %    end
               %end
                if s ==1
                       data_MAT_R{ee} = cellbody;
                elseif s ~=length(cfg.subject)
                   %load([ where filename2 ],'data_MAT_R')
                      data_MAT_R{ee} = cat(1,data_MAT_R{ee},cellbody);
                elseif s ==length(cfg.subject)
                    data = cat(1,data_MAT_R{ee},cellbody);
                    data_MAT_R{ee} = [];
                    save([ where filename2 ],'data','-V6')    
                    clear data 
                end
                
                %if s == 
                %    %% FixME!!!!!!
                %data_MAT_R = cell2mat(data_MAT_R);
                %end
                
                clear data_MAT_R
               %fclose(fid);
               %fclose(fid{ee});
       end
   end% loop ee
   
   
   end% loop s
   
   %for ee = electrode
   %    
   %end
else

    
   fid = fopen([ where filename ],'wt');
    
   if isfield(cfg,'nofield')
       if iscell(cfg.nofield)
          for f = 1:length(cfg.nofield)
               COR = rmfield(COR,cfg.nofield{1});
          end 
       else
           COR = rmfield(COR,cfg.nofield);
       end

   end
    
    
    
%%% in RT
if isfield(COR,'rt')
    COR.RT = COR;
end
nh = 0;
if isfield(COR,'RT')
        % onset 
        if isfield(COR.RT,'laten')
            nh = nh +1;
            HEADER{nh} = 'onset';
            body{nh} = COR.RT.laten*unitst;

            nh = nh +1;
            HEADER{nh} = 'duration';
            if isfield(COR, 'OTHER') && isfield(COR.OTHER, 'duration')
            body{nh} = COR.OTHER.duration;
            else
            body{nh} = ones(size(COR.RT.laten));    
            end
        end  

    if isfield(COR.RT,'est')
        nh = nh +1;
        HEADER{nh} = 'value';
        body{nh} = COR.RT.est;
    end

    if isfield(COR.RT,'resp')
        nh = nh +1;
        HEADER{nh} = 'response';
        body{nh} = COR.RT.resp;
    end

    if isfield(COR.RT,'rt')
        nh = nh +1;
        HEADER{nh} = 'rt';
        body{nh} = COR.RT.rt;
    end

  
    if isfield(COR.RT,'correct')
            nh = nh +1;
            HEADER{nh} = 'correct';
            body{nh} = COR.RT.correct;
    end

    if isfield(COR.RT,'good')
            nh = nh +1;
            HEADER{nh} = 'good';
            body{nh} = COR.RT.good;
    end 
end

%%% in OTHER
if isfield(COR,'OTHER')
    campos = sort(fields(COR.OTHER))';
  
    for ncm = 1:length(campos)
        nh = nh +1;
        HEADER{nh} = campos{ncm};
        eval([' body{nh} = COR.OTHER.' campos{ncm} ' ;']);
    end
end

%%% in FREQ
if isfield(COR,'FREQ')
    nfreq = size(COR.FREQ,2);
  
    for ncm = 1:nfreq
        nh = nh +1;
        HEADER{nh} = COR.FREQ(ncm).name;
        pow = [];
        for ix = 1:length(COR.FREQ(ncm).powspctrm)
            if isempty(COR.FREQ(ncm).powspctrm{ix})
                np = -99;
            elseif (sum(size(COR.FREQ(ncm).powspctrm{ix}))==2)&&(COR.FREQ(ncm).powspctrm{ix}==-99)
                np = -99; 
            else
                np = squeeze(COR.FREQ(ncm).powspctrm{ix}(:,electrode,:));
            end
        pow = cat(1,pow,np);
        end
        body{nh} =   pow;
    end
end

        



%%% .... agrgar otros



%%%% writing the file

       %%% header
       EF = ['%s' delimiter ];
       for  f = 1:[size(HEADER,2)-1]
            fprintf(fid,EF,HEADER{f}); 
       end
       fprintf(fid,'%s\n',HEADER{size(HEADER,2)});
       
       %%% body
       ntrail = max(size(body{1}));
       ncoef = max(size(body));
       cellbody = cell(ntrail,ncoef);
       %format
       
       for nb = 1:ncoef;
          cellbody(:,nb) = mat_t_cell(body{nb});
          if ischar(cellbody{1,nb})
             dformat{nb} = ['%s'];
          else
             % optimizar escritura
                p = body{nb};
                if islogical(p)
                dformat{nb} = ['%s'];    
                else % iscell{p}
                dformat{nb} = ['%s'];       
%                 else
%                 p(p<=0)=[];
%                 sobre =   fix(max(log10(p)) + 1);
%                 if sobre<1; sobre=1; end
%                 bajo  =    abs(fix(min(log10(abs(p))) - 6));
%                 dformat{nb} = [' %' num2str(sobre)  '.' num2str(bajo)  'f'];
                 end
          end
          if nb == ncoef
             dformat{nb} = [ dformat{nb} '\n'];
          else
             dformat{nb} = [ dformat{nb} delimiter ];
          end
       end
       
      
       

       for nt = 1:ntrail
           for nc = 1:ncoef
               if ischar(cellbody{nt,nc})
               fprintf(fid,dformat{nc},cellbody{nt,nc}); 
               elseif isstring(cellbody{nt,nc})
               fprintf(fid,dformat{nc},cellbody{nt,nc}); 
               else
               fprintf(fid,dformat{nc},num2str(cellbody{nt,nc}(1))); 
               end
           end
       end
       fclose(fid);

end % perfile

%fclose(fid);
end