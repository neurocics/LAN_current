function T = lan_export_PSD_tsv(LAN, cfg)
% lan_export_freq_tsv  Exporta espectros de potencia trial-by-trial a .tsv para R/JAGS
%
% Uso:
%   LAN = lan_export_PSD_tsv(LAN, cfg)
%
% Requiere:
%   LAN.freq.fourierp.data  -> matriz con espectros
%   LAN.freq.freq           -> vector de frecuencias (Hz)
%   LAN.chanlocs            -> con campo .labels
%   LAN.name                -> identificador del sujeto
%
% cfg:
%   cfg.fmin      = frecuencia mínima (Hz)
%   cfg.fmax      = frecuencia máxima (Hz)
%   cfg.outdir    = carpeta donde guardar el archivo (opcional, default: pwd)
%   cfg.filename  = nombre del archivo (opcional, default: [LAN.name '_freq_fmin-fmaxHz.tsv'])
%
% Salida:
%   Archivo .tsv con columnas:
%     subject   : LAN.name
%     trial     : índice de trial
%     chan      : índice de canal
%     chan_label: etiqueta de canal
%     f_XX.X    : una columna por frecuencia seleccionada (potencia)
%
%   Pablo Billeke (IA asistido)

   %-----------------------------
    % 1) Chequeos básicos
    %-----------------------------
    if ~isfield(LAN, 'freq') || ~isfield(LAN.freq, 'fourierp')
        error('LAN.freq.fourierp no existe en la estructura LAN.');
    end

    if ~isfield(cfg, 'fmin') || ~isfield(cfg, 'fmax')
        error('cfg.fmin y cfg.fmax son obligatorios.');
    end

    if cfg.fmin >= cfg.fmax
        error('cfg.fmin debe ser menor que cfg.fmax.');
    end

    if ~isfield(cfg, 'outdir') || isempty(cfg.outdir)
        cfg.outdir = pwd;
    end

    if ~exist(cfg.outdir, 'dir')
        mkdir(cfg.outdir);
    end

    if ~isfield(LAN, 'name') || isempty(LAN.name)
        LAN.name = 'unknown_subject';
    end

    %-----------------------------
    % 2) Datos de frecuencia
    %-----------------------------
    freq_vec = LAN.freq.fourierp.freq;
    data_all = LAN.freq.fourierp.data;

    sz = size(data_all);
    nFreq = numel(freq_vec);

    freq_dim = find(sz == nFreq, 1, 'first');
    if isempty(freq_dim)
        error('No se encontró dimensión de frecuencia compatible.');
    end

    if isfield(LAN, 'chanlocs') && ~isempty(LAN.chanlocs)
        nChan = numel(LAN.chanlocs);
    else
        warning('LAN.chanlocs no encontrado, se asume primera dimensión = canales.');
        nChan = sz(1);
    end

    if sz(1) ~= nChan
        warning('Tamaño inconsistente, se toma sz(1) como número de canales.');
        nChan = sz(1);
    end

    switch freq_dim
        case 2
            data = permute(data_all, [1 3 2]);
        case 3
            data = data_all;
        otherwise
            error('Dimensión de frecuencia incorrecta.');
    end

    nTrials = size(data, 2);

    %-----------------------------
    % 3) Selección de frecuencias
    %-----------------------------
    freq_mask = freq_vec >= cfg.fmin & freq_vec <= cfg.fmax;
    if ~any(freq_mask)
        error('No hay frecuencias en el rango solicitado.');
    end

    freq_sel = freq_vec(freq_mask);
    data_sel = data(:, :, freq_mask);
    nFreq_sel = numel(freq_sel);

    %-----------------------------
    % 4) Reorganizar datos
    %-----------------------------
    data_perm = permute(data_sel, [2 1 3]);
    nRows = nTrials * nChan;

    data_2D = reshape(data_perm, [nRows, nFreq_sel]);

    trial_idx = repelem((1:nTrials)', nChan);
    chan_idx  = repmat((1:nChan)', nTrials, 1);

    if isfield(LAN, 'chanlocs') && isfield(LAN.chanlocs, 'labels')
        chan_labels_all = {LAN.chanlocs.labels};
        chan_labels = repmat(chan_labels_all(:), nTrials, 1);
    else
        chan_labels = arrayfun(@(x) sprintf('Ch%d', x), chan_idx, 'UniformOutput', false);
    end

    subject_col = repmat({LAN.name}, nRows, 1);

    %-----------------------------
    % 5) columna accepted
    %-----------------------------
    if isfield(LAN, 'accept') && numel(LAN.accept) == nTrials
        accepted_trial = LAN.accept(:);   % vector columna [nTrials x 1]
    else
        warning('LAN.accept no existe o tiene tamaño incorrecto → se asume todos aceptados.');
        accepted_trial = ones(nTrials, 1);
    end

    % Repetir el estado del trial para cada canal
    accepted_col = repelem(accepted_trial, nChan);

    %-----------------------------
    % 6) Crear tabla
    %-----------------------------
    freq_varnames = cell(1, nFreq_sel);
    for k = 1:nFreq_sel
        freq_varnames{k} = sprintf('f_%g', freq_sel(k));
        freq_varnames{k} = strrep(freq_varnames{k}, '.', '_');
    end

    T_freq = array2table(data_2D, 'VariableNames', freq_varnames);

    T = table(subject_col, trial_idx, accepted_col, chan_idx, chan_labels, ...
              'VariableNames', {'subject', 'trial', 'accepted', 'chan', 'chan_label'});

    T = [T, T_freq];

    %-----------------------------
    % 7) Guardar archivo
    %-----------------------------
    if ~isfield(cfg, 'filename') || isempty(cfg.filename)
        cfg.filename = sprintf('%s_freq_%g-%gHz.tsv', LAN.name, cfg.fmin, cfg.fmax);
        cfg.filename = strrep(cfg.filename, ' ', '_');
    end

    outfile = fullfile(cfg.outdir, cfg.filename);

    writetable(T, outfile, 'FileType', 'text', 'Delimiter', '\t');

    fprintf('lan_export_freq_tsv: archivo guardado en:\n  %s\n', outfile);

    %-----------------------------
    % 8) Generar archivo .json con descripción de columnas
    %-----------------------------
    meta = struct();
    meta.description = 'Power spectral density export (trial x channel) for R/JAGS';
    meta.subject = struct( ...
        'column', 'subject', ...
        'description', 'Subject identifier taken from LAN.name', ...
        'type', 'string');

    meta.trial = struct( ...
        'column', 'trial', ...
        'description', 'Trial index (1-based)', ...
        'type', 'integer');

    meta.accepted = struct( ...
        'column', 'accepted', ...
        'description', 'Trial acceptance flag from LAN.accept (1=accepted, 0=rejected)', ...
        'type', 'integer');

    meta.chan = struct( ...
        'column', 'chan', ...
        'description', 'Channel index (1-based, position in LAN.chanlocs)', ...
        'type', 'integer');

    meta.chan_label = struct( ...
        'column', 'chan_label', ...
        'description', 'Channel name from LAN.chanlocs.labels', ...
        'type', 'string');

    % Información de las columnas de frecuencia
    freq_cols = struct('column', {}, 'frequency_hz', {}, 'description', {});
    for k = 1:nFreq_sel
        freq_cols(k).column = freq_varnames{k};
        freq_cols(k).frequency_hz = freq_sel(k);
        freq_cols(k).description = 'Power spectral density value at this frequency';
    end
    meta.frequency_columns = freq_cols;

    % Rango global de frecuencias
    meta.freq_range_hz = [cfg.fmin, cfg.fmax];

    % Nombre del .json (mismo base que el .tsv)
    [~, baseName, ~] = fileparts(outfile);
    json_file = fullfile(cfg.outdir, [baseName '.json']);

    json_str = jsonencode(meta);

    fid = fopen(json_file, 'w');
    if fid == -1
        warning('No se pudo crear el archivo JSON: %s', json_file);
    else
        fprintf(fid, '%s', json_str);
        fclose(fid);
        fprintf('Metadata JSON guardado en:\n  %s\n', json_file);
    end





end