function [LAN] = lan_read_file(filename,type)
%  <*LAN)<] toolbox
%  v.0.3
%  read file usig Fieldtrip toolbox
%    -- addpting for reading micromed .trc file
%
%  Pablo Billeke

%  03.05.2017 add Brain Amp option 
%  12.04.2016 add CNT particular option to not use MEX file from FILEIO 
%                 use EEGLAB function instead!!
%  01.04.2016 fix some probele with trc file
%  14.08.2015 Add .set type='set'
%  30.12.2014 fix RT.est in char
%  08.04.2014 improve dot-case in .TRC file
%  02.04.2014 improve dot-case in .TRC file
%  16.11.2013 read all channel in .TRC file including EEG and periferical
%  07.01.2013
%  04.01,2013
%  22.10.2012
%  30.08.2012
  

if nargin == 0
    [file, path] = uigetfile('*.*', 'import file using IO');
    if isequal(file,0) || isequal(path,0)
                    disp('User selected Cancel')
                    LAN = 0;
                    return
    end
    filename = fullfile(path,file);
else
        if isstruct(filename)
        file = getcfg(filename,'filename');
        path = getcfg(filename,'filepath','');
        elseif ischar(filename)
        file= filename;
        path = '';
        end
        filename = fullfile(path,file);
end
if nargin < 2
type='';
%end
DATA = ft_read_data(filename);
HEADER = ft_read_header(filename);
try
EVENT = ft_read_event(filename);
%----------------------
si = ~ifcellis({EVENT.value},'isempty(@)');
if ischar( EVENT(find(si,1)).value)
    n = 1;
  for i = find(si)  
      RT.label{i} = (EVENT(i).value); 
  end
  for i = find(~si)  
      RT.label{i} = '_no_label';
      EVENT(i).value = '_no_label'; 
  end
  
  
%   paso = fun_in_cell(RT.label,'isempty(@)');
%   for ncell = find(paso)
%       RT.label{ncell} = '_no_label';
%   end
  
  cod = unique(RT.label);
  RT.est = zeros(size(RT.label));
  for i = 1:length(cod);
     RT.est(ifcellis(RT.label,cod{i})) = i; 
  end
else
RT.est = ({EVENT(si).value});
%RT.est = ({EVENT.value});
end
RT.laten = 1000*(cell2mat({EVENT(si).sample})/HEADER.Fs);
%RT.laten = 1000*(cell2mat({EVENT.sample})/HEADER.Fs);
LAN.RT = rt_check(RT);
catch
    disp('Not event')
end
%----------------------

LAN.srate = HEADER.Fs;
LAN.nbchan = HEADER.nChans;
LAN.pnts = HEADER.nSamples;
LAN.trials = HEADER.nTrials;
chtype = 'EEG';

end

switch type
    
    %%% SET file from EEGLAB
    case {'set','Set','SET','EEGLAB'}
        [EEG, command] = pop_loadset_lan( filename, '');
        LAN = eeglab2lan(EEG,1) ;
        DATA = LAN.data;
    %%% BrainAmp
    case {'BrainAmp', 'BrainVision','BA','BV'}
        type='';
        %end
        DATA = ft_read_data([filename '.eeg']);
        HEADER = ft_read_header([filename '.vhdr']);
        EVENT = ft_read_event([filename '.vmrk']);
        %----------------------
        si = ~ifcellis({EVENT.value},'isempty(@)');
        %if ischar( EVENT(find(si,1)).value)
            n = 1;
          for i =  find(si)  %1:length(EVENT)
              if isempty((EVENT(i).value))
                RT.label{n} = (EVENT(i).type);   
              else
                RT.label{n} = (EVENT(i).value); 
              end
              n=n+1;
          end
          cod = unique(RT.label);
          RT.est = zeros(size(RT.label));
          for i = 1:length(cod);
             RT.est(ifcellis(RT.label,cod{i})) = i; 
          end
        %else
        %RT.est = ({EVENT(si).value});
        %end
        RT.laten = 1000*(cell2mat({EVENT(si).sample})/HEADER.Fs);
        RT.OTHER.names=RT.label;
        LAN.RT = rt_check(RT);
        %----------------------

        LAN.srate = HEADER.Fs;
        LAN.nbchan = HEADER.nChans;
        LAN.pnts = HEADER.nSamples;
        LAN.trials = HEADER.nTrials;
        chtype = 'EEG';

    %%% TRC file from Micromed
    case {'micromed','Micromed','trc','TRC'}
    ifdot=1;    
    %  read header
    try
        HEADER = read_micromed_trc_sb([filename '.trc']);
    catch
        HEADER = read_micromed_trc_sb([filename ]);
    end
    LAN.srate = HEADER.Code_Area_Length;
    LAN.nbchan =  HEADER.Num_Chan;
    LAN.pnts = HEADER.Num_Samples;
    LAN.trials=1;
    
    % read data
    try
        DATA = read_micromed_trc_sb([filename '.trc'],1,LAN.pnts );
    catch
        DATA = read_micromed_trc_sb([filename ],1,LAN.pnts );
    end
    
    try
        try %
          %p = mfilename('fullpath') 
          %system([ strrep(p,'lan_read_file' , 'micromed2eeg   ') filename '  ' filename]) ;
          % system([ 'micromed2eeg   ' filename '  ' filename]) ;
        end
        try
            paso = read_micromed('header', filename );
            HEADER.label = {paso.chanInFile(:).PIL};
            for ii = 1:length(HEADER.label)
                HEADER.label{ii}(double( HEADER.label{ii})<=32) = [];
            end
            ifdot = 0;
        catch
        try
        HEADER.label = importdata([filename '.elec.out']);
        catch
        HEADER.label = importdata([strrep(strrep(filename,'.trc',''),'.TRC','') '.elec.out']);    
        end
        HEADER.label(1) = [];
        end
        
    
    end
    chtype = 'iEEG';
    name_ag =[];
        llevo = length(name_ag);
        %electrodemat=zeros(,20);
        for i = 1:LAN.nbchan
           LAN.chanlocs(i).labels = HEADER.label{i}; 
           LAN.chanlocs(i).type = chtype;
           LAN.chanlocs(i).X = [];
           LAN.chanlocs(i).Y = [];
           LAN.chanlocs(i).Z = [];
           % buscar agujas

           name_a =  HEADER.label{i}(1);
           HEADER.label{i}(HEADER.label{i}==',') = [];
           fin = findstr(HEADER.label{i},'.')-1;
              
           if ifdot
              %if isempty( str2num(HEADER.label{i}(fin(1))) );
              HEADER.label{i}(fin+1:end) = [];  
              fin = []; 
              %else
              %HEADER.label{i}(fin) = []; 
              %fin = []; 
              %end
           elseif ~isempty(fin)% 
              if isempty(str2num(HEADER.label{i}(fin(1))));
              HEADER.label{i}(fin+1:end) = [];  
              fin = []; 
              else
              HEADER.label{i}(fin+1) = []; 
              fin = []; 
              end 
           end
           %if fin >
           if isempty(fin)
              HEADER.label{i}(double(HEADER.label{i})<33)=[];
             
              if isempty(str2num(HEADER.label{i}(end)))
              HEADER.label{i}(end+1) = '1';
              end
              fin = numel(HEADER.label{i});
              HEADER.label{i}(fin+1:fin+2) = '.0';
           end    
           
           
           % FixME!!!
           if numel(fin) ==2
              HEADER.label{i}(fin(1)) = []; 
              fin = fin(2)-1;    
           end

           for c =2:fin
                  if isempty(str2num(HEADER.label{i}(c)));
                      name_a = [name_a HEADER.label{i}(c)];
                     if c==fin % for eeg channels Cz Fz
                          if isempty(name_ag)||~strcmp(name_ag{llevo} , name_a);
                              llevo = llevo +1;
                              name_ag{llevo} = name_a; 
                          end
                          p = 1 ;
                          electrodemat(llevo, p ) = i;
                     end
                  else
                          if isempty(name_ag)||~strcmp(name_ag{llevo} , name_a);
                              llevo = llevo +1;
                              name_ag{llevo} = name_a; 
                          end
                          p=HEADER.label{i}(c:fin);
                          p(p=='+')=[];
                          p = str2num(p); 
                      electrodemat(llevo, p ) = i;
                      break
                   end

           end
        end
        try   
        LAN.chanlocs(1).electrodemat = electrodemat;
        LAN.chanlocs(1).electrodemat_names = name_ag;
        end
        
       try  EVENT = ft_read_event([filename ]); catch EVENT = ft_read_event([filename '.trc']); end;
        %----------------------
        si = ~ifcellis({EVENT.value},'isempty(@)');
        %if ischar( EVENT(find(si,1)).value)
            n = 1;
          for i =  find(si)  %1:length(EVENT)
             % if isempty((EVENT(i).value))
             %   RT.label{n} = (EVENT(i).type);   
             % else
                RT.est(n) = (EVENT(i).value); 
             % end
              n=n+1;
          end
          %cod = unique(RT.label);
          %RT.est = zeros(size(RT.label));
          %for i = 1:length(cod);
          %   RT.est(ifcellis(RT.label,cod{i})) = i; 
          %end
        %else
        %RT.est = ({EVENT(si).value});
        %end
        RT.laten = 1000*(cell2mat({EVENT(si).sample})/LAN.srate);
        %RT.OTHER.names=RT.label;
        LAN.RT = rt_check(RT);
        
        
    %%% CNT file from Neuroscan   
    case {'cnt','Cnt','CNT'}
        LAN = cnt2lan( filename);  
        DATA = LAN.data;
    case {'edf','EDF'}
        
        [HEADER DATA] = edfread(filename);
        LAN.srate = HEADER.frequency(1);
        LAN.nbchan = size(DATA,1);
        LAN.pnts = size(DATA,2);
        for i = 1:LAN.nbchan
           LAN.chanlocs(i).labels = HEADER.label{i}; 
           LAN.chanlocs(i).type =  HEADER.transducer{i};
           LAN.chanlocs(i).X = [];
           LAN.chanlocs(i).Y = [];
           LAN.chanlocs(i).Z = []; 
           
           paso = resample(double(DATA(i,:)),LAN.srate,HEADER.frequency(i));
           if  length(paso)<LAN.pnts;
               DATA(i,1:length(paso)) = paso;
           else
               DATA(i,:) = paso(1:LAN.pnts);
           end
        end
    case  ''
        
    %%% OTHERs file    
    for i = 1:LAN.nbchan
           LAN.chanlocs(i).labels = HEADER.label{i}; 
           LAN.chanlocs(i).type = chtype;
           LAN.chanlocs(i).X = [];
           LAN.chanlocs(i).Y = [];
           LAN.chanlocs(i).Z = [];
    end
    if exist('RT')>0 &  isfield(RT,'labels')
     RT.OTHER.names=RT.label;    
    end
end

LAN.data = DATA;
fin = find(file=='.',1,'first')-1;
if isempty(fin)
  LAN.name = file;
else
  LAN.name = file(1:fin);  
end
    


LAN = lan_check(LAN);



%% subfunction 

function output = read_micromed_trc_sb(filename, begsample, endsample)

%--------------------------------------------------------------------------
% reads Micromed .TRC file into matlab, version Mariska
% input: filename
% output: datamatrix
%--------------------------------------------------------------------------

% ---------------- Opening File------------------
fid=fopen(filename,'rb');
if fid==-1
  error('Can''t open *.trc file')
end

%------------------reading patient & recording info----------
fseek(fid,64,-1);
header.surname=char(fread(fid,22,'char'))';
header.name=char(fread(fid,20,'char'))';

fseek(fid,128,-1);
day=fread(fid,1,'char');
if length(num2str(day))<2
  day=['0' num2str(day)];
else
  day=num2str(day);
end
month=fread(fid,1,'char');
switch month
  case 1
    month='JAN';
  case 2
    month='FEB';
  case 3
    month='MAR';
  case 4
    month='APR';
  case 5
    month='MAY';
  case 6
    month='JUN';
  case 7
    month='JUL';
  case 8
    month='AUG';
  case 9
    month='SEP';
  case 10
    month='OCT';
  case 11
    month='NOV';
  case 12
    month='DEC';
end
header.day=day;
header.month=month;
header.year=num2str(fread(fid,1,'char')+1900);

%------------------ Reading Header Info ---------
fseek(fid,175,-1);
header.Header_Type=fread(fid,1,'char');
if header.Header_Type ~= 4
  error('*.trc file is not Micromed System98 Header type 4')
end

fseek(fid,138,-1);
header.Data_Start_Offset=fread(fid,1,'uint32');
header.Num_Chan=fread(fid,1,'uint16');
header.Multiplexer=fread(fid,1,'uint16');
header.Rate_Min=fread(fid,1,'uint16');
header.Bytes=fread(fid,1,'uint16');

fseek(fid,176+8,-1);
header.Code_Area=fread(fid,1,'uint32');
header.Code_Area_Length=fread(fid,1,'uint32');

fseek(fid,192+8,-1);
header.Electrode_Area=fread(fid,1,'uint32');
header.Electrode_Area_Length=fread(fid,1,'uint32');

fseek(fid,400+8,-1);
header.Trigger_Area=fread(fid,1,'uint32');
header.Tigger_Area_Length=fread(fid,1,'uint32');

%----------------- Read Trace Data ----------

if nargin==1
  % determine the number of samples
  fseek(fid,header.Data_Start_Offset,-1);
  datbeg = ftell(fid);
  fseek(fid,0,1);
  datend = ftell(fid);
  header.Num_Samples = (datend-datbeg)/(header.Bytes*header.Num_Chan);
  if rem(header.Num_Samples, 1)~=0
    warning('rounding off the number of samples');
    header.Num_Samples = floor(header.Num_Samples);
  end
  % output the header
  output = header;
else
  % determine the selection of data to read
  if isempty(begsample)
    begsample = 1;
  end
  if isempty(endsample) || isinf(endsample)
    endsample = header.Num_Samples;
  end
  fseek(fid,header.Data_Start_Offset,-1);
  fseek(fid, header.Num_Chan*header.Bytes*(begsample-1), 0);
  switch header.Bytes
    case 1
      data = fread(fid, [header.Num_Chan endsample-begsample+1], 'uint8');
    case 2
      data = fread(fid, [header.Num_Chan endsample-begsample+1], 'uint16');
    case 4
      data = fread(fid, [header.Num_Chan endsample-begsample+1], 'uint32');
  end
  % output the data
  output = data-32768;
  % FIXME why is this value of -32768 subtracted?
  % FIXME some sort of calibration should be applied to get it into microvolt
end


end
end

