function T = lan_export_PSD_tsv_other(LAN, cfg)
% lan_export_PSD_tsv  Exporta espectros de potencia trial-by-trial a .tsv para R/JAGS
%
% Uso:
%   T = lan_export_PSD_tsv(LAN, cfg)
%
% Requiere:
%   LAN.freq.fourierp.data  -> matriz con espectros
%   LAN.freq.fourierp.freq  -> vector de frecuencias (Hz)
%   LAN.chanlocs            -> con campo .labels (opcional)
%   LAN.name                -> identificador del sujeto (opcional)
%
% cfg:
%   cfg.fmin      = frecuencia mínima (Hz)
%   cfg.fmax      = frecuencia máxima (Hz)
%   cfg.outdir    = carpeta donde guardar el archivo (opcional, default: pwd)
%   cfg.filename  = nombre del archivo (opcional)
%
% NUEVO (columnas opcionales desde LAN.RT.OTHER):
%   cfg.add_other        = true/false (default: false)
%   cfg.other_fields     = {'pupil','ppe',...} (default: {}).
%                          Si vacío y add_other=true -> agrega todos los fields disponibles.
%
% Salida:
%   Archivo .tsv con columnas:
%     subject, trial, accepted, chan, chan_label, [other...], f_XX_X ...
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

    % NUEVO: configuración de columnas OTHER
    if ~isfield(cfg, 'add_other') || isempty(cfg.add_other)
        cfg.add_other = false;
    end
    if ~isfield(cfg, 'other_fields') || isempty(cfg.other_fields)
        cfg.other_fields = {};
    end
    if isstring(cfg.other_fields), cfg.other_fields = cellstr(cfg.other_fields); end

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
    % 4) Reorganizar datos (trial x chan x freq => filas = trial*chan)
    %-----------------------------
    data_perm = permute(data_sel, [2 1 3]);  % [nTrials x nChan x nFreq_sel]
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
    % 5) columna accepted (por trial -> repetir por canal)
    %-----------------------------
    if isfield(LAN, 'accept') && numel(LAN.accept) == nTrials
        accepted_trial = LAN.accept(:);
    else
        warning('LAN.accept no existe o tiene tamaño incorrecto → se asume todos aceptados.');
        accepted_trial = ones(nTrials, 1);
    end
    accepted_col = repelem(accepted_trial, nChan);

    %-----------------------------
    % 6) Crear tabla base
    %-----------------------------
    freq_varnames = cell(1, nFreq_sel);
    for k = 1:nFreq_sel
        freq_varnames{k} = sprintf('f_%g', freq_sel(k));
        freq_varnames{k} = strrep(freq_varnames{k}, '.', '_');
    end
    T_freq = array2table(data_2D, 'VariableNames', freq_varnames);

    T = table(subject_col, trial_idx, accepted_col, chan_idx, chan_labels, ...
              'VariableNames', {'subject', 'trial', 'accepted', 'chan', 'chan_label'});

    %-----------------------------
    % 6b) NUEVO: agregar columnas opcionales desde LAN.RT.OTHER
    %-----------------------------
    added_other = {};  % para metadata

    if cfg.add_other
        if isfield(LAN, 'RT') && isfield(LAN.RT, 'OTHER') && isstruct(LAN.RT.OTHER)
            other_struct = LAN.RT.OTHER;
            available = fieldnames(other_struct);

            if isempty(cfg.other_fields)
                fields_to_add = available; % agrega todas
            else
                fields_to_add = cfg.other_fields(:);
                % filtrar las que existan
                missing = setdiff(fields_to_add, available);
                if ~isempty(missing)
                    warning('Campos en cfg.other_fields no existen en LAN.RT.OTHER: %s', strjoin(missing, ', '));
                end
                fields_to_add = intersect(fields_to_add, available, 'stable');
            end

            for iF = 1:numel(fields_to_add)
                fname = fields_to_add{iF};
                v = other_struct.(fname);

                try
                    col = local_other_to_column(v, nTrials, nChan, nRows);
                catch ME
                    warning('No se pudo agregar LAN.RT.OTHER.%s (%s). Se omite.', fname, ME.message);
                    continue;
                end

                % nombre válido de variable
                vname = matlab.lang.makeValidName(fname);
                if ismember(vname, T.Properties.VariableNames)
                    vname = matlab.lang.makeUniqueStrings(vname, T.Properties.VariableNames);
                end

                T.(vname) = col;
                added_other{end+1} = vname; %#ok<AGROW>
            end
        else
            warning('cfg.add_other=true pero LAN.RT.OTHER no existe o no es struct. No se agregan columnas.');
        end
    end

    % Añadir frecuencias al final
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
    fprintf('lan_export_PSD_tsv: archivo guardado en:\n  %s\n', outfile);

    %-----------------------------
    % 8) Generar archivo .json con descripción de columnas
    %-----------------------------
    meta = struct();
    meta.description = 'Power spectral density export (trial x channel) for R/JAGS';
    meta.freq_range_hz = [cfg.fmin, cfg.fmax];

    meta.subject = struct('column','subject','description','Subject identifier taken from LAN.name','type','string');
    meta.trial   = struct('column','trial','description','Trial index (1-based)','type','integer');
    meta.accepted= struct('column','accepted','description','Trial acceptance flag from LAN.accept (1=accepted, 0=rejected)','type','integer');
    meta.chan    = struct('column','chan','description','Channel index (1-based, position in LAN.chanlocs)','type','integer');
    meta.chan_label = struct('column','chan_label','description','Channel name from LAN.chanlocs.labels','type','string');

    % NUEVO: registrar columnas OTHER agregadas
    other_cols = struct('column', {}, 'source', {}, 'description', {}, 'type', {});
    for k = 1:numel(added_other)
        other_cols(k).column = added_other{k};
        other_cols(k).source = ['LAN.RT.OTHER.' added_other{k}];
        other_cols(k).description = 'Optional trial-varying column exported from LAN.RT.OTHER';
        other_cols(k).type = 'mixed';
    end
    meta.other_columns = other_cols;

    % Info de columnas de frecuencia
    freq_cols = struct('column', {}, 'frequency_hz', {}, 'description', {});
    for k = 1:nFreq_sel
        freq_cols(k).column = freq_varnames{k};
        freq_cols(k).frequency_hz = freq_sel(k);
        freq_cols(k).description = 'Power spectral density value at this frequency';
    end
    meta.frequency_columns = freq_cols;

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

% -------------------------------------------------------------------------
% Helper: convierte LAN.RT.OTHER.(fname) a columna nRows x 1 (alineada a filas trial*chan)
% Orden de filas: trial 1 (chan 1..nChan), trial 2 (chan 1..nChan), ...
% -------------------------------------------------------------------------
function col = local_other_to_column(v, nTrials, nChan, nRows)

    % Normalizar string/cell
    if isstring(v)
        v = cellstr(v);
    end

    % Caso escalar -> replicar
    if isscalar(v)
        col = repmat(v, nRows, 1);
        return;
    end

    % Caso cellstr por trial
    if iscell(v) && numel(v) == nTrials && (ischar(v{1}) || isstring(v{1}))
        v = v(:);
        col = repelem(v, nChan);
        return;
    end

    % Caso vector por trial (numérico o lógico)
    if (isnumeric(v) || islogical(v)) && (isvector(v)) && numel(v) == nTrials
        v = v(:);
        col = repelem(v, nChan);
        return;
    end

    % Caso matriz [nTrials x nChan] (numérica/lógica)
    if (isnumeric(v) || islogical(v)) && ismatrix(v) && size(v,1) == nTrials && size(v,2) == nChan
        % Queremos vector con orden: trial1 chan1..nChan, trial2 chan1..nChan ...
        col = reshape(v.', [nRows, 1]);  % v' => [nChan x nTrials], stack por columnas
        return;
    end

    % Caso [nChan x nTrials] (a veces guardan al revés)
    if (isnumeric(v) || islogical(v)) && ismatrix(v) && size(v,1) == nChan && size(v,2) == nTrials
        % Reordenar a [nTrials x nChan]
        vv = v.'; % [nTrials x nChan]
        col = reshape(vv.', [nRows, 1]);
        return;
    end

    error('Formato no soportado. Se esperaba escalar, [nTrials], cellstr[nTrials], o [nTrials x nChan].');
end
