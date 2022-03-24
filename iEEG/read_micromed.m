function out = read_micromed(action, varargin)
% function out = read_micromed(action, varargin),
% 
% case 'data', 
%  read data with calibration
%   read_micromed('data', fullfilename, header, iSample, nSamplesToRead)
%  same as dataNC ? 
% 
% case 'data_t1_t2', 
%  read calibrated data from t1 to t2 
%
% case 'dataNC', 
%  read non calibrated data
%
% case 'dataNC_t1_t2', 
%  read non calibrated data from t1 to t2 
%
% case 'header',
%  read header of the file
%  out = header;
%
% case 'info', 
%  display information about the recording. 
%  out = header; 
%
% case 'marker', 
%
%
% case 'readChannels', 
%
%
% case 'visu', 
%
%
% Author : Guillaume BECQ
% Date : 20100113 
% Rev : 20090407 - 200603

if (nargin == 0), 
    action = 'caseTest'; 
end

switch action, 
    case 'data', 
        out = read_data(varargin{1}, varargin{2}, varargin{3}, varargin{4}); 
    case 'data_t1_t2', 
        out = read_data_t1_t2(varargin{1}, varargin{2}, varargin{3}, varargin{4}); 
    case 'dataNC', 
        out = read_dataNC(varargin{1}, varargin{2}, varargin{3}, varargin{4}); 
    case 'dataNC_t1_t2', 
        out = read_dataNC_t1_t2(varargin{1}, varargin{2}, varargin{3}, varargin{4}); 
    case 'header',
        out = getHeader(varargin{1});
    case 'info', 
        out = getInfo(varargin{1}); 
    case 'marker', 
        out = findMarker(varargin{1}, varargin{2}); 
    case 'readChannels', 
        out = readChannels(varargin{1}, varargin{2}, varargin{3}, varargin{4}); 
    case 'visu', 
        out = visu(varargin{1});        
    otherwise,
        out = 0; 
        disp('check function parameters please')
end
return

function out = findMarker(fullfilename, stringChannelMarker) 
fid = fopen(fullfilename); 
disp(['Reading ' TeXFullfile(fullfilename) '... '])
header = read_header(fid, fullfilename); 
iCode = find(header.code > 0); 
PIL = cell(1, length(iCode)); 
for i = 1 : length(iCode), 
    PIL{i} = deblank(header.electrode(header.code(iCode(i)) + 1).PIL); 
end
indexChannelMarker = (strcmp(PIL, stringChannelMarker) == 1); 
fseek(fid, header.offsetData, -1);
f1 = ftell(fid);
fseek(fid, 0, 1); 
f2 = ftell(fid); 
nBlocks = (f2 - f1) / header.multiplexer; 
fseek(fid, header.offsetData, -1); 
k1 = 0; 
marker.index = []; 
marker.time = []; 
kBloc = floor(header.Fs * 100); % 100 s default 
% using a smaller size of the window does not change anything in the detection
% Verify on 20100201
hWaitbar = waitbar(0, ['Reading ' TeXFullfile(fullfilename) ' ...']); 
while k1 < nBlocks,
    k0 = k1;
    k1 = k0 + kBloc;
    A = fread(fid, [header.nChannels, kBloc], 'uint16'); 
    signal = A(indexChannelMarker, :);
    signalToPlot = A(indexChannelMarker, :); 
    iTUp = find(signal == (2^16 - 1)); 
    if ~isempty(iTUp), 
        marker.index = [marker.index, k0 + iTUp]; 
        figure(0510311733)
        hold off
        plot(signalToPlot)
        hold on
        plot(iTUp, signalToPlot(iTUp), 'ro')
        axis([0 length(signalToPlot) -2^15 2^16 + 2^15])
        drawnow
        shg
        pause(1)
    end
    waitbar(k1 / nBlocks, hWaitbar);
end
close(hWaitbar)
NDtMarker = 1 * header.Fs; % 1 s entre 2 pics de marquage
marker.index = getFirstMarker(marker.index, NDtMarker); 
timeIndex = header.t0 + (marker.index - 1) / header.Fs / 86400; 
marker.time = [marker.time, timeIndex];
out = marker; 
return

function index2 = getFirstMarker(index1, NDtMarker) 
if length(index1) > 1, 
    condition_1 = diff(index1) > (NDtMarker - 5/100 * NDtMarker); 
    condition_2 = diff(index1) < (NDtMarker + 5/100 * NDtMarker); 
    iMarker = (condition_1 & condition_2); 
    indexMarker = index1(iMarker); 
    indexMarkerPlus0 = [0 indexMarker]; 
    condition_1 = diff(indexMarkerPlus0) < NDtMarker - 5/100 * NDtMarker; 
    condition_2 = diff(indexMarkerPlus0) > (NDtMarker + 5/100 * NDtMarker); 
    iPreviousUp = find(condition_1 | condition_2); 
    i1stUp = iPreviousUp + 1; 
    index2 = indexMarkerPlus0(i1stUp); 
else
    index2 = index1; 
end
return

function out = getHeader(fullfilename)
fclose all;
fid = fopen(fullfilename); 
disp(['Reading micromed file : ' TeXFullfile(fullfilename) '... '])
header = read_header(fid, fullfilename); 
out = header; 
return

function out = getInfo(fullfilename)
fclose all;
fid = fopen(fullfilename); 
disp(['Reading micromed file : ' TeXFullfile(fullfilename) '... '])
header = read_header(fid, fullfilename); 
disp(['Titre : ' header.title])
disp(['Laboratoire : ' header.laboratory]); 
disp('Patient : ')
disp([' Nom    : ' header.patient_data.surname]); 
disp([' Prnom : ' header.patient_data.firstname]);
disp([' Date de Naissance : ' , ...
        datestr(datenum(header.patient_data.birthDate.year, ...
        header.patient_data.birthDate.month, ...
        header.patient_data.birthDate.day))]); 
disp('Examen : ')
disp([' Date : ' datestr(datenum(header.date.year, ...
        header.date.month, header.date.day, header.date.hour, ...
        header.date.min, header.date.sec))]); 
disp([' Dbut de l''enregistrement : ' datestr(header.t0)]); 
disp([' Fin de l''enregistrement   : ' datestr(header.t1)]);
disp('Description de l''unit d''acquisition : '); 
disp([' Type de matriel : ' header.acquisition_unit.description]); 
disp([' Type des donnes : ' header.filetype.description]); 
disp(['Offset des donnes : ' num2str(header.offsetData)]); 
disp(['Taille du fichier  : ' num2str(header.size)]); 
disp(['Nombre de blocs    : ' num2str(header.nBlocks)]); 
disp(['Nombre de voies enregistres : ' num2str(header.nChannels)])
disp(['Muliplexeur : ' num2str(header.multiplexer)]); 
disp(['Frquence d''acquisition   : ' num2str(header.Fs)]); 
disp(['Compression (0 - non, 1 - oui) : ' num2str(header.compression)]); 
disp(['Nombre de montages utiliss : ' num2str(header.nMontages)]); 
disp(['Format du fichier : ' header.header_type.description]); 
% Notes
disp('Notes ');  
MAX_NOTE = 200; 
for i = 1 : MAX_NOTE, 
    disp([num2str(i) ' : ' datestr(sampleToTime(header.note(i).nSample, header.t0, header.Fs)) ' : ' header.note(i).text]); 
end
% DVIDEO
disp('DVideo ');  
MAX_FILE = 1024; 
for i = 1 : MAX_FILE, 
    fprintf('%4i : %20i : %10f;', i, header.dvideo(i).DV_Begin, header.dvideo(i).DV_Begin - header.dvideo(1).DV_Begin); 
    if (mod(i, 1) == 0), 
        fprintf('\n'); 
    end
end
% Electrodes
disp('Electrodes ');  
MAX_ELEC = 640; 
fprintf('nElec : status PIL    NIL    Reference : logical       ; physical              \n')
fprintf('      :                           min   - max   ; min        - max        \n')
for i = 1 : MAX_ELEC, 
    thisElec = header.electrode(i); 
    fprintf('%5i : %6i %6s %6s %9s : %5i - %5i ; %10.4f - %10.4f %10s \n', i, thisElec.status, thisElec.PIL, thisElec.NIL, thisElec.reference, thisElec.logicMin, thisElec.logicMax, thisElec.physicalMin, thisElec.physicalMax, thisElec.units); 
end
% Montage
displayMontageMicromed(header.montage, header);
out = header; 
return

function channels = readChannels(fullfilename, header, t0, t1)
lag1 = floor((t0 - header.t0 * 86400) * header.Fs); 
nSamplesToRead = floor((t1 - t0) * header.Fs); 
fid = fopen(fullfilename, 'r'); 
fseek(fid, header.offsetData + lag1 * header.nChannels * header.size, -1);
channels = fread(fid, [header.nChannels, nSamplesToRead], 'uint16'); 
fclose(fid);

function header = read_header(fid, fullfilename)
MAX_CAN = 256; 
MAX_LAB = 640; 
MAX_MONT = 30; 
MAX_NOTE = 200; 
MAX_FLAG = 100; 
MAX_SEGM = 100; 
MAX_SAMPLE = 128; 
MAX_HISTORY = 30; 
MAX_EVENT = 100; 
% MAX_FILE = 1024; 
% MAX_TRIGGER = 8192; 
header.title = char(fread(fid, 32, 'char')');
header.laboratory = char(fread(fid, 32, 'char')');
header.patient_data.surname = char(fread(fid, 22, 'char')');
header.patient_data.firstname = char(fread(fid, 20, 'char')');
header.patient_data.birthDate.month = fread(fid, 1, 'uchar');
header.patient_data.birthDate.day = fread(fid, 1, 'uchar');
header.patient_data.birthDate.year = fread(fid, 1, 'uchar') + 1900;
header.patient_data.reserved = char(fread(fid, 19, 'uchar')');
header.date.day = fread(fid, 1, 'uchar');
header.date.month = fread(fid, 1, 'uchar');
header.date.year = fread(fid, 1, 'uchar') + 1900;
header.date.hour = fread(fid, 1, 'uchar');
header.date.min = fread(fid, 1, 'uchar');
header.date.sec = fread(fid, 1, 'uchar');
acquisition_unit.value = fread(fid, 1, 'short'); % see constant values
acquisition_unit.code = [...
        0, 2, 6, 7, 8, 9, 10, 11, ...
        12, 13, 14, 15, 16, 17, 18, ...
        19, 20, 21, 22, 23];
acquisition_unit.description = {...
        'BQ124 - 24 channels headbox, Internal Interface', ...
        'MS40 - Holter recorder', ...
        'BQ132S - 32 channels headbox, Internal Interface', ...
        'BQ124 - 24 channels headbox, BQ CARD Interface', ...
        'SAM32 - 32 channels headbox, BQ CARD Interface', ...
        'SAM25 - 25 channels headbox, BQ CARD Interface', ...
        'BQ132S R - 32 channels reverse headbox, Internal Interface', ...
        'SAM32 R - 32 channels reverse headbox, BQ CARD Interface', ...
        'SAM25 R - 25 channels reverse headbox, BQ CARD Interface', ...
        'SAM32 - 32 channels headbox, Internal Interface', ...
        'SAM25 - 25 channels headbox, Internal Interface', ...
        'SAM32 R - 32 channels reverse headbox, Internal Interface', ...
        'SAM25 R - 25 channels reverse headbox, Internal Interface', ...
        'SD - 32 channels headbox with jackbox, SD CARD Interface -- PCI Internal Interface', ...
        'SD128 - 128 channels headbox, SD CARD Interface -- PCI Internal Interface', ...
        'SD96 - 96 channels headbox, SD CARD Interface -- PCI Internal Interface', ...
        'SD64 - 64 channels headbox, SD CARD Interface -- PCI Internal Interface', ...
        'SD128c - 128 channels headbox with jackbox, SD CARD Interface -- PCI Internal Interface', ...
        'SD64c - 64 channels headbox with jackbox, SD CARD Interface -- PCI Internal Interface', ...
        'BQ132S - 32 channels headbox, PCI Internal Interface', ...
        'BQ132S R - 32 channels reverse headbox, PCI Internal Interface'}; 
acquisition_unit.index = find(acquisition_unit.value == acquisition_unit.code); 
header.acquisition_unit.description = acquisition_unit.description{acquisition_unit.index}; 
header.acquisition_unit.value = acquisition_unit.value; 
filetype.value = fread(fid, 1, 'ushort'); % see constant values
filetype.code = [40 42 44 46, 48, 50, 52, 54, 56, 58, ...
        60, 62, 64, 66, 68, 70, 72, 74, 76, 78, ...
        80, 82, 84, 86, 100, 101, 102, 103, 120, 121, ...
        122, 140, 141, 160, 161, 162, 180, 181, 182, ...
        183, 200, 201, 202, 203, 204, 205]; 
% CR = 'Common Reference'; 
% poly = 'polygraphy'; 
filetype.description = {...
        'C128 C.R., 128 EEG (headbox SD128 only)', ...
        'C84P C.R., 84 EEG, 44 poly (headbox SD128 only)', ...
        'C84 C.R., 84 EEG, 4 reference signals (named MKR,MKRB,MKRC,MKRD) (headbox SD128 only)', ...
        'C96 C.R., 96 EEG (headbox SD128 -- SD96 -- BQ123S(r))', ...
        'C63P C.R., 63 EEG, 33 poly', ...
        'C63 C.R., 63 EEG, 3 reference signals (named MKR,MKRB,MKRC)', ...
        'C64 C.R., 64 EEG', ...
        'C42P C.R., 42 EEG, 22 poly', ...
        'C42 C.R., 42 EEG, 2 reference signals (named MKR,MKRB)', ...
        'C32 C.R., 32 EEG',...
        'C21P C.R., 21 EEG, 11 poly', ...
        'C21 C.R., 21 EEG, 1 reference signal (named MKR)', ...
        'C19P C.R., 19 EEG, variable poly', ...
        'C19 C.R., 19 EEG, 1 reference signal (named MKR)', ...
        'C12 C.R., 12 EEG', ...
        'C8P C.R., 8 EEG, variable poly', ...
        'C8 C.R., 8 EEG',...
        'CFRE C.R., variable EEG, variable poly', ...
        'C25P C.R., 25 EEG (21 standard, 4 poly transformed to EEG channels), 7 poly -- headbox BQ132S(r) only', ...
        'C27P C.R., 27 EEG (21 standard, 6 poly transformed to EEG channels), 5 poly -- headbox BQ132S(r) only', ...
        'C24P C.R., 24 EEG (21 standard, 3 poly transformed to EEG channels), 8 poly -- headbox SAM32(r) only', ...
        'C25P C.R., 25 EEG (21 standard, 4 poly transformed to EEG channels), 7 poly -- headbox SD with headbox JB 21P', ...
        'C27P C.R., 27 EEG (21 standard, 6 poly transformed to EEG channels), 5 poly -- headbox SD with headbox JB 21P', ...
        'C31P C.R., 27 EEG (21 standard, 10 poly transformed to EEG channels), 1 poly -- headbox SD with headbox JB 21P6', ...
        'C26P C.R., 26 EEG, 6 poly (headbox SD, SD64c, SD128c with headbox JB Mini)', ...
        'C16P C.R., 16 EEG, 16 poly (headbox SD with headbox JB M12)', ...
        'C12P C.R., 12 EEG, 20 poly (headbox SD with headbox JB M12)', ...
        '32P 32 poly (headbox SD, SD64c, SD128c with headbox JB Bip)', ...
        'C48P C.R., 48 EEG, 16 poly (headbox SD64)', ...
        'C56P C.R., 56 EEG, 8 poly (headbox SD64)', ...
        'C24P C.R., 24 EEG, 8 poly (headbox SD64)', ...
        'C52P C.R., 52 EEG, 12 poly (headbox SD64c, SD128c with 2 headboxes JB Mini)', ...
        '64P 64 poly (headbox SD64c, SD128c with 2 headboxes JB Bip)', ...
        'C88P C.R., 88 EEG, 8 poly (headbox SD96)', ...
        'C80P C.R., 80 EEG, 16 poly (headbox SD96)', ...
        'C72P C.R., 72 EEG, 24 poly (headbox SD96)', ...
        'C120P C.R., 120 EEG, 8 poly (headbox SD128)', ...
        'C112P C.R., 112 EEG, 16 poly (headbox SD128)', ...
        'C104P C.R., 104 EEG, 24 poly (headbox SD128)', ...
        'C96P C.R., 96 EEG, 32 poly (headbox SD128)', ...
        'C122P C.R., 122 EEG, 6 poly (headbox SD128c with 4 headboxes JB Mini)', ...
        'C116P C.R., 116 EEG, 12 poly (headbox SD128c with 4 headboxes JB Mini)', ...
        'C110P C.R., 110 EEG, 18 poly (headbox SD128c with 4 headboxes JB Mini)', ...
        'C104P C.R., 104 EEG, 24 poly (headbox SD128c with 4 headboxes JB Mini)', ...
        '128P 128 poly (headbox SD128c with 4 headboxes JB Bip)', ...
        '96P 96 poly (headbox SD128c with 3 headboxes JB Bip)'};
filetype.index = find(filetype.value == filetype.code);
header.filetype.description = filetype.description{filetype.index};
header.filetype.value = filetype.value; 
header.offsetData = fread(fid, 1, 'ulong'); % data_start_offset
header.nChannels = fread(fid, 1, 'ushort'); % num_chan
% distance in bytes between successive samples
header.multiplexer = fread(fid, 1, 'ushort'); % distance between channel data
header.Fs = fread(fid, 1, 'ushort'); % Rate_min 64, 128, 256, 512, 1024
header.Ts = 1/header.Fs; 
% size of one data in bytes
header.size = fread(fid, 1, 'ushort'); % Bytes : number of bytes ; 1 : 1 byte, 2 : 2 bytes
header.compression = fread(fid, 1, 'ushort'); % 0 non compression, 1 compression. 
% nombre de montages
header.nMontages = fread(fid, 1, 'ushort'); % Montages : number of specific montages (0... 30)
% digital video start sample
header.Dvideo_Begin = fread(fid, 1, 'ulong'); % Starting sample of digital video
header.MPEG_Delay = fread(fid, 1, 'ushort'); % Number of frames per hour of de-synchronization in MPEG acq
header.Reserved_1 = fread(fid, 15, 'uchar');
header_type.value = fread(fid, 1, 'uchar'); 
header_type.code = [0, 1, 2, 3, 4]; 
header_type.description = {...
        'Micromed "System 1" Header type', ...
        'Micromed "System 1" Header type', ...
        'Micromed "System 2" Header type', ...
        'Micromed "System98" Header type', ...
        'Micromed "System98" Header type', ...
    };
header_type.index = find(header_type.value == header_type.code); 
header.header_type.description = header_type.description{header_type.index};
header.header_type.value = header_type.value; 
% order (code)
header.code_area.name = char(fread(fid, 8, 'char')');
header.code_area.startOffset = fread(fid, 1, 'ulong');
header.code_area.length = fread(fid, 1, 'ulong');
% labcode (elec)
header.electrode_area.name = char(fread(fid, 8, 'char')');
header.electrode_area.startOffset = fread(fid, 1, 'ulong');
header.electrode_area.length = fread(fid, 1, 'ulong');
% note
header.note_area.name = char(fread(fid, 8, 'char')');
header.note_area.startOffset = fread(fid, 1, 'ulong');
header.note_area.length = fread(fid, 1, 'ulong');
% flags
header.flag_area.name = char(fread(fid, 8, 'char')');
header.flag_area.startOffset = fread(fid, 1, 'ulong');
header.flag_area.length = fread(fid, 1, 'ulong');
% tronca (redu )
header.segment_area.name = char(fread(fid, 8, 'char')');
header.segment_area.startOffset = fread(fid, 1, 'ulong');
header.segment_area.length = fread(fid, 1, 'ulong');
% impedB (begi)
header.B_impedance_area.name = char(fread(fid, 8, 'char')');
header.B_impedance_area.startOffset = fread(fid, 1, 'ulong');
header.B_impedance_area.length = fread(fid, 1, 'ulong');
% impedE (endi)
header.E_impedance_area.name = char(fread(fid, 8, 'char')');
header.E_impedance_area.startOffset = fread(fid, 1, 'ulong');
header.E_impedance_area.length = fread(fid, 1, 'ulong');
% montage (mont)
header.montage_area.name = char(fread(fid, 8, 'char')');
header.montage_area.startOffset = fread(fid, 1, 'ulong');
header.montage_area.length = fread(fid, 1, 'ulong');
% Compress
header.compression_area.name = char(fread(fid, 8, 'char')');
header.compression_area.startOffset = fread(fid, 1, 'ulong');
header.compression_area.length = fread(fid, 1, 'ulong');
% average (res)
header.average_area.name = char(fread(fid, 8, 'char')');
header.average_area.startOffset = fread(fid, 1, 'ulong');
header.average_area.length = fread(fid, 1, 'ulong');
% history (hist)
header.history_area.name = char(fread(fid, 8, 'char')');
header.history_area.startOffset = fread(fid, 1, 'ulong');
header.history_area.length = fread(fid, 1, 'ulong');
% dvideo (res2)
header.dvideo_area.name = char(fread(fid, 8, 'char')');
header.dvideo_area.startOffset = fread(fid, 1, 'ulong');
header.dvideo_area.length = fread(fid, 1, 'ulong');
% event A (eva)
header.eventA_area.name = char(fread(fid, 8, 'char')');
header.eventA_area.startOffset = fread(fid, 1, 'ulong');
header.eventA_area.length = fread(fid, 1, 'ulong');
% event B (evb) 
header.eventB_area.name = char(fread(fid, 8, 'char')');
header.eventB_area.startOffset = fread(fid, 1, 'ulong');
header.eventB_area.length = fread(fid, 1, 'ulong');
% trigger (trig) 
header.trigger_area.name = char(fread(fid, 8, 'char')');
header.trigger_area.startOffset = fread(fid, 1, 'ulong');
header.trigger_area.length = fread(fid, 1, 'ulong');
header.Reserved_2 = fread(fid, 224, 'uchar'); 
% Code pour retrouver l'ordre des lectrodes
fseek(fid, header.code_area.startOffset, -1);
% for iChannel = 1 : header.nChannels, 
%    header.channel(iChannel).order = fread(fid, 1, 'ushort');
% end
for iChannel = 1 : MAX_CAN, 
   header.code(iChannel) = fread(fid, 1, 'ushort');
end
% electrode
for iChannel = 1 : MAX_LAB, 
   fseek(fid, header.electrode_area.startOffset + 128 * (iChannel - 1), -1);
   % Status of electrode for acquisition : 0 : not acquired, 1 : acquired
   header.electrode(iChannel).status = fread(fid, 1, 'uchar');
   % type   
   channelType = fread(fid, 1, 'uchar');
   header.electrode(iChannel).typeValue = channelType; 
   header.electrode(iChannel).reference = '';
   if bitget(channelType, 1), 
       header.electrode(iChannel).reference = [header.electrode(iChannel).reference ' Bipolar']; 
   else
       header.electrode(iChannel).reference = [header.electrode(iChannel).reference ' G2']; 
   end
   if bitget(channelType, 2), 
       header.electrode(iChannel).type = [header.electrode(iChannel).reference ' Marker']; 
   end
   if bitget(channelType, 3), 
       header.electrode(iChannel).type = [header.electrode(iChannel).reference ' Oxym']; 
   end
   if bitget(channelType, 4), 
       header.electrode(iChannel).type = [header.electrode(iChannel).reference ' 16DC']; 
   end
   if bitget(channelType, 5), 
       header.electrode(iChannel).type = [header.electrode(iChannel).reference 'bip2eeg']; 
   end
   % PIL : positive input label
   header.electrode(iChannel).PIL = char(fread(fid, 6, 'char')'); 
   % NIL : positive input label
   header.electrode(iChannel).NIL = char(fread(fid, 6, 'char')');
   % Logic minimum
   header.electrode(iChannel).logicMin = fread(fid, 1, 'long');
   % Logic maximum
   header.electrode(iChannel).logicMax = fread(fid, 1, 'long');
   % Logic ground
   header.electrode(iChannel).logicGround = fread(fid, 1, 'long');
   % Physic minimum
   header.electrode(iChannel).physicalMin = fread(fid, 1, 'long');
   % Physic maximum
   header.electrode(iChannel).physicalMax = fread(fid, 1, 'long');
   % Measurements Units
   channelUnit.code = [-1 0 1 2 100 101 102]; 
   channelUnit.description = {'nV', 'V', 'mV', 'V', '%', 'bpm', 'Adim'}; 
   channelUnit.value = fread(fid, 1, 'ushort');
   channelUnit.index = find(channelUnit.value == channelUnit.code);
   header.electrode(iChannel).unitsValue = channelUnit.value; 
   header.electrode(iChannel).units = channelUnit.description{channelUnit.index};
   % Prefiltering high pass limit
   header.electrode(iChannel).HiPass_Limit = fread(fid, 1, 'ushort'); % value in Hz * 1000
   % Prefiltering high type
   header.electrode(iChannel).HiPass_Type = fread(fid, 1, 'ushort'); 
   % Prefiltering low pass limit
   header.electrode(iChannel).LowPass_Limit = fread(fid, 1, 'ushort'); % value in Hz
   % Prefiltering low pass type
   header.electrode(iChannel).LowPass_Type = fread(fid, 1, 'ushort');
   % Rate coef
   header.electrode(iChannel).Rate_Coefficient = fread(fid, 1, 'ushort'); % 1, 2, 4 * min. Sampling Rate
   header.electrode(iChannel).Position = fread(fid, 1, 'ushort') + 1; % matlab index instead of C 
   header.electrode(iChannel).Latitude = fread(fid, 1, 'float');
   header.electrode(iChannel).Longitude = fread(fid, 1, 'float');
   header.electrode(iChannel).presentInMap = fread(fid, 1, 'uchar');
   header.electrode(iChannel).isInAvg = fread(fid, 1, 'uchar');
   header.electrode(iChannel).Description = char(fread(fid, 32, 'char')');
   header.electrode(iChannel).x =fread(fid, 1, 'float');
   header.electrode(iChannel).y =fread(fid, 1, 'float');
   header.electrode(iChannel).z =fread(fid, 1, 'float');
   header.electrode(iChannel).Coordinate_Type = fread(fid, 1, 'short'); 
   header.electrode(iChannel).Free = char(fread(fid, 24, 'char')'); 
end
% get and reorder the channels in the file
iChanInFile = 0; 
header.chanInFile = header.electrode;
chanPos = zeros(MAX_LAB, 1);
for iChannel = 1 : MAX_LAB, 
   if header.electrode(iChannel).status == 1,
       iChanInFile = iChanInFile + 1;
       header.chanInFile(iChanInFile) = header.electrode(iChannel);
       chanPos(iChanInFile) = header.chanInFile(iChanInFile).Position; 
%       chanPos(iChannel) = header.chanInFile(iChanInFile).Position; 
   end
end
nChanInFile = iChanInFile;
chanPos = chanPos(1:nChanInFile); % 
[~, IChanPos] = sort(chanPos); % 
header.chanInFile = header.chanInFile(IChanPos);
header.nChanInFile = nChanInFile; 
% Notes
fseek(fid, header.note_area.startOffset, -1);
for i = 1 : MAX_NOTE, 
    header.note(i).nSample = fread(fid, 1, 'ulong');
    header.note(i).text = char(fread(fid, 40, 'char')');
end
% Flags
fseek(fid, header.flag_area.startOffset, -1);
for i = 1 : MAX_FLAG, 
    header.flag(i).begin = fread(fid, 1, 'ulong');
    header.flag(i).end = fread(fid, 1, 'ulong');
end
% Segms
fseek(fid, header.segment_area.startOffset, -1);
for i = 1 : MAX_SEGM, 
    header.segment(i).time = fread(fid, 1, 'ulong'); % in samples 
    header.segment(i).sample = fread(fid, 1, 'ulong');
end
% Starting Impedance
fseek(fid, header.B_impedance_area.startOffset, -1);
for i = 1 : MAX_CAN, 
    header.B_impedance(i).positive = fread(fid, 1, 'uchar');
    header.B_impedance(i).negative = fread(fid, 1, 'uchar');
end
% Ending Impedance
fseek(fid, header.E_impedance_area.startOffset, -1);
for i = 1 : MAX_CAN, 
    header.E_impedance(i).positive = fread(fid, 1, 'uchar');
    header.E_impedance(i).negative = fread(fid, 1, 'uchar');
end
% Specific montages
fseek(fid, header.montage_area.startOffset, -1);
MAX_CAN_VIEW = 128; 
for i = 1 : MAX_MONT, 
    header.montage(i).lines = fread(fid, 1, 'ushort');
    header.montage(i).sectors = fread(fid, 1, 'ushort');
    header.montage(i).base_time = fread(fid, 1, 'ushort');
    header.montage(i).notch = fread(fid, 1, 'ushort');
    header.montage(i).colour = fread(fid, MAX_CAN_VIEW, 'uchar');
    header.montage(i).selection = fread(fid, MAX_CAN_VIEW, 'uchar');
    header.montage(i).description = fread(fid, 64, 'char');
    header.montage(i).inputsNonInv = fread(fid, MAX_CAN_VIEW, 'ushort'); % NonInv : non inverting input 
    header.montage(i).inputsInv = fread(fid, MAX_CAN_VIEW, 'ushort'); % Inv : inverting Input
    header.montage(i).HiPass_Filter = fread(fid, MAX_CAN_VIEW, 'ulong'); % value in Hz * 100
    header.montage(i).LowPass_Filter = fread(fid, MAX_CAN_VIEW, 'ulong'); % value in Hz
    header.montage(i).reference = fread(fid, MAX_CAN_VIEW, 'ulong'); 
    header.montage(i).free = fread(fid, 1720, 'uchar'); 
end
% Compression
fseek(fid, header.compression_area.startOffset, -1);
% Average (off-line average process)
fseek(fid, header.average_area.startOffset, -1);
header.average.Mean_Trace = fread(fid, 1, 'ulong');
header.average.Mean_File = fread(fid, 1, 'ulong');
header.average.Mean_Prestim = fread(fid, 1, 'ulong');
header.average.Mean_PostStim = fread(fid, 1, 'ulong');
header.average.Mean_Type = fread(fid, 1, 'ulong');
AVERAGE_FREE = 108; 
header.average.Free = fread(fid, AVERAGE_FREE, 'uchar');
% History
fseek(fid, header.history_area.startOffset, -1);
for i = 1 : MAX_HISTORY, 
    header.history(i).nSample = fread(fid, MAX_SAMPLE, 'ulong');
    header.history(i).lines = fread(fid, 1, 'ushort');
    header.history(i).sectors = fread(fid, 1, 'ushort');
    header.history(i).base_time = fread(fid, 1, 'ushort');
    header.history(i).notch = fread(fid, 1, 'ushort');
    header.history(i).colour = fread(fid, MAX_CAN_VIEW, 'uchar');
    header.history(i).selection = fread(fid, MAX_CAN_VIEW, 'uchar');
    header.history(i).description = fread(fid, 64, 'char');
    header.history(i).inputsNonInv = fread(fid, MAX_CAN_VIEW, 'ushort'); % NonInv : non inverting input 
    header.history(i).inputsInv = fread(fid, MAX_CAN_VIEW, 'ushort'); % Inv : inverting Input
    header.history(i).HiPass_Filter = fread(fid, MAX_CAN_VIEW, 'ulong'); % value in Hz * 100
    header.history(i).LowPass_Filter = fread(fid, MAX_CAN_VIEW, 'ulong'); % value in Hz
    header.history(i).reference = fread(fid, MAX_CAN_VIEW, 'ulong'); 
    header.history(i).free = fread(fid, 1720, 'uchar'); 
end
% DVIDEO
fseek(fid, header.dvideo_area.startOffset, -1);
MAX_FILE = 1024; 
for i = 1 : MAX_FILE, 
    thisReading= fread(fid, 1, 'int32');
    header.dvideo(i).DV_Begin = thisReading; 
    q = mod(i, 4); 
    k = floor((i - 1) / 4) + 1; 
    switch q, 
        case 1, 
            header.video.MS(k,1) = thisReading;  % delay
        case 2, 
            header.video.MS(k,2) = thisReading; % duration
        case 3, 
            header.video.MS(k,3) = thisReading; % filename ext
            extension = fullfilename(end-2:end); 
            switch extension, 
                case {'trc', 'TRC'}, 
                    pathstr = fileparts(fullfilename); 
                    header.video.fullfilename{k} = [pathstr, filesep , ...
                        'VID' ...
                        '_' sprintf('%i', thisReading) , '.avi']; 
                case {'vwr', 'VWR'}, 
                    header.video.fullfilename{k} = [fullfilename(1:end-4) ...
                        '_' sprintf('%i', thisReading) , '.avi']; 
            end
    end
end

% Event A
fseek(fid, header.eventA_area.startOffset, -1);
for i = 1 : MAX_EVENT, 
    header.eventA(i).Description = fread(fid, 1, 'ulong');
    header.eventA(i).pointer.begin = fread(fid, 1, 'ulong');    
    header.eventA(i).pointer.end = fread(fid, 1, 'ulong');    
end
% Event B
fseek(fid, header.eventB_area.startOffset, -1);
for i = 1 : MAX_EVENT, 
    header.eventB(i).description = fread(fid, 1, 'ulong');
    header.eventB(i).pointer.begin = fread(fid, 1, 'ulong');    
    header.eventB(i).pointer.end = fread(fid, 1, 'ulong');    
end
% Trigger
fseek(fid, header.trigger_area.startOffset, -1);
MAX_TRIGGER = 8192; 
for i = 1 : MAX_TRIGGER, 
    header.trigger(i).sample = fread(fid, 1, 'ulong');
    header.trigger(i).value = fread(fid, 1, 'ushort');    
end
header.t0 = datenum(header.date.year, header.date.month, header.date.day, ...
    header.date.hour, header.date.min, header.date.sec);
fseek(fid, header.offsetData, -1); 
i1 = ftell(fid); 
fseek(fid, 0, 1); 
i2 = ftell(fid);
header.nBlocks = (i2 - i1) / (header.size * header.nChannels);
DT = header.nBlocks / header.Fs;
header.t1 = header.t0 + DT / 86400; 
header = orderfields(header); 
return

function t = sampleToTime(iSample, t0, Fs) 
t = t0 + (iSample - 1) / Fs / 86400; 
return

function data = read_data(fullfilename, header, iSample, nSamplesToRead) 
fid = fopen(fullfilename); 
status = fseek(fid, header.offsetData + (iSample - 1) * header.nChannels * header.size, -1);
if (status == 0), 
    data = fread(fid, [header.nChannels, nSamplesToRead], 'uint16'); 
    for i = 1 : header.nChannels, 
        E = header.chanInFile(i); 
%        E = header.electrode(header.code(i)); 
        data(i, :) = (data(i, :) - E.logicGround) / ...
            (E.logicMax - E.logicMin + 1) * (E.physicalMax - E.physicalMin) ; 
    end
else
    data = zeros(header.nChannels, nSamplesToRead); 
end
fclose(fid); 

function data = read_data_t1_t2(fullfilename, header, t1, t2) 
i1 = timeToSample(header.t0, t1, header.Fs);
nSamplesToRead = timeToSample(t1, t2, header.Fs);
%nSamplesToRead = i2 - i1 + 1; 
data = read_data(fullfilename, header, i1, nSamplesToRead); 

function data = read_dataNC(fullfilename, header, iSample, nSamplesToRead) 
fid = fopen(fullfilename);
status = fseek(fid, header.offsetData + (iSample - 1) * header.nChannels * header.size, -1);
if (status == 0), 
    data = fread(fid, [header.nChannels, nSamplesToRead], 'uint16'); 
else
    data = zeros(header.nChannels, nSamplesToRead); 
end
fclose(fid); 

function data = read_dataNC_t1_t2(fullfilename, header, t1, t2) 
i1 = timeToSample(header.t0, t1, header.Fs);
nSamplesToRead = timeToSample(t1, t2, header.Fs);
data = read_dataNC(fullfilename, header, i1, nSamplesToRead); 

% function signal = read_signal(fid, header, params) 
% fseek(fid, header.offsetData, -1);
% f1 = ftell(fid);
% fseek(fid, 0, 1); 
% f2 = ftell(fid); 
% nBlocks = (f2 - f1) / header.multiplexer;
% A = zeros(header.nChannels, params.nPlot);
% fseek(fid, header.offsetData, -1);
% k = 0; 
% dT = 10; 
% while k < nBlocks,
%     kBloc = dT * header.Fs;
%     k = k + kBloc;
%     A = fread(fid, [header.nChannels, dT * header.Fs], 'uint16'); 
%     if mod(k, params.nPlot) > 1, 
%         figure(0510121604)
%         imagesc(A);
%         drawnow
%         shg
%         figure(0510121605)
%         plot(A(22, :) - A(21, :))
%         if any(abs(A(22, :) - A(21, :)) > 33000), 
%             pause
%         end
%         figure(0510181344)
%         plot(A(32, :) - A(31, :))
%         drawnow
%         shg
%     end
% end
% signal = A;
% return

function TeXFullfilename = TeXFullfile(fullfilename) 
TeXFullfilename = strrep(fullfilename, '\','\\'); 
TeXFullfilename = strrep(TeXFullfilename, '_','\_'); 
return

function iSample = timeToSample(t1, t2, Fs) 
iSample = 1 + fix((t2 - t1) * Fs * 86400); 
return

function signal = visu(fullfilename) 
header = read_micromed('header', fullfilename); 
fid = fopen(fullfilename, 'r'); 
fseek(fid, header.offsetData, -1);
params.nPlot = 10000; 
f1 = ftell(fid);
fseek(fid, 0, 1); 
f2 = ftell(fid); 
nBlocks = (f2 - f1) / header.multiplexer;
A = zeros(header.nChannels, params.nPlot);
fseek(fid, header.offsetData, -1);
k = 0; 
dT = 20; 
hWaitbar = waitbar(0, 'please wait...'); 
while k < nBlocks,
    kBloc = dT * header.Fs;
    k = k + kBloc;
    A = fread(fid, [header.nChannels, dT * header.Fs], 'uint16'); 
    if mod(k, params.nPlot) > 1, 
        figure(0510121604)
        imagesc(A);
        drawnow
        shg
        figure(0510121605)
        hold off
        stairs(A(18, :))
        hold on
        stairs(A(end, :), 'r')        
        axis([0 dT * header.Fs -2^16-1 2^16-1])
        figure(0510181344); 
        gain = 10; 
        dataPlot = 0 * transpose(A); 
        for iChan = 1 : header.nChannels, 
            if strcmp(header.electrode(iChan).reference, ' G2'), 
                dataPlot(:, iChan) = transpose(A(iChan, :)); 
            else
                dataPlot = A(iChan, :)'; 
            end
        end
        dataPlot = dataPlot ./ (2 ^ 16 - 1) .* gain + ...
            repmat((1 : header.nChannels), size(A, 2), 1); 
        stairs(dataPlot);
        axis([0 dT * header.Fs 0 (header.nChannels + 1)])
        text(zeros(1, header.nChannels), ...
            (1 : header.nChannels) * (2 ^ 16 - 1), ...
            char(header.electrode(header.code((1 : header.nChannels)) + 1).PIL));
        drawnow
        shg
        if any(any(A(1 : header.nChannels, :) - ...
                repmat(A(1, :), header.nChannels, 1) == (2^16 - 1))),
            pause  
        else
            pause
        end
        waitbar(k/nBlocks, hWaitbar)
    end
end
close(hWaitbar)
signal = A;
return