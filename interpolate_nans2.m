function Y = interpolate_nans2(X, varargin)
% INTERPOLATE_NANS Rellena NaNs en una señal unidimensional usando distintos métodos
%
% Y = interpolate_nans(X, 'method', METHOD, ...)
%
% MÉTODOS DISPONIBLES:
%   - 'linear' : Interpolación lineal
%   - 'pchip'  : Interpolación cúbica conservadora (recomendado para TMS-EEG)
%   - 'spline' : Interpolación spline cúbica
%   - 'polyfit': Ajuste polinomial cúbico local (usa muestras antes y después del hueco)
%   - 'idw'    : Ponderación inversa a la distancia (método original)
%
% OPCIONES PARA 'polyfit':
%   - 'window': número de muestras antes y después del hueco para el ajuste (default = 20)
%
% OPCIONES PARA 'idw':
%   - 'power' : potencia de la distancia (default = 2)
%   - 'radius': radio máximo a considerar (default = 0 → sin límite)

% ----------------- Opciones por defecto --------------------
method = 'idw';
power = 2;
radius = 0;
polyfit_window = 20;

% ----------------- Parseo de argumentos ---------------------
for k = 1:2:length(varargin)
    key = lower(varargin{k});
    val = varargin{k+1};
    switch key
        case 'method'
            method = lower(val);
        case 'power'
            power = val;
        case 'radius'
            radius = val;
        case 'window'
            polyfit_window = val;
        otherwise
            error(['Argumento desconocido: ', key]);
    end
end

% ----------------- Interpolación ---------------------
Y = X;
nan_idx = isnan(X);
if ~any(nan_idx)
    return; % No hay NaNs
end

valid_idx = find(~nan_idx);
nan_locs = find(nan_idx);

switch method

    case {'linear', 'pchip', 'spline'}
        Y(nan_idx) = interp1(valid_idx, X(valid_idx), nan_locs, method, 'extrap');

    case 'polyfit'
        Y = fill_nans_polyfit(X, polyfit_window);

    case 'idw'
        Y = fill_nans_idw(X, power, radius);

    otherwise
        error(['Método de interpolación no soportado: ', method]);
end
end

% ======== Función auxiliar: interpolación polyfit local =========
function Y = fill_nans_polyfit(X, win)
Y = X;
nan_runs = find_nan_segments(X);
for i = 1:size(nan_runs,1)
    idx1 = nan_runs(i,1) - win;
    idx2 = nan_runs(i,2) + win;
    idx1 = max(idx1, 1);
    idx2 = min(idx2, length(X));
    
    x_win = idx1:idx2;
    y_win = X(x_win);
    valid = ~isnan(y_win);
    
    if sum(valid) < 4
        warning('No hay suficientes puntos para polyfit, se omite.');
        continue;
    end
    
    p = polyfit(x_win(valid), y_win(valid), 3);
    x_interp = nan_runs(i,1):nan_runs(i,2);
    Y(x_interp) = polyval(p, x_interp);
end
end

% ======== Función auxiliar: interpolación IDW original =========
function Y = fill_nans_idw(X, n, d)
Y = X;
nan_idx = find(isnan(X));
valid_idx = find(~isnan(X));

for i = nan_idx(:)'
    D = abs(i - valid_idx);
    if d > 0
        D = D(D < d);
        idx = valid_idx(abs(i - valid_idx) < d);
    else
        idx = valid_idx;
    end
    if isempty(idx)
        continue;
    end
    weights = 1 ./ (D.^n);
    Y(i) = sum(X(idx) .* weights) / sum(weights);
end
end

% ======== Función auxiliar: detectar tramos de NaNs =========
function segments = find_nan_segments(X)
nan_idx = isnan(X);
d = diff([0, nan_idx, 0]);
starts = find(d == 1);
ends = find(d == -1) - 1;
segments = [starts(:), ends(:)];
end
