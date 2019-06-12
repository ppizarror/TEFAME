function [f, fft, envFormaModal, tlocMean, tlocStd, locMean, locStd, locFreq, ...
    maxlocs, pks, beta, betaFreq] = PSD(a, fs, gdl, varargin)
% PSD: Power Spectral Density. Calcula la FFT de un registro sismico
% analizado para varios nodos con distintos grados de libertad. La funcion
% permite calcular distintos tipos de periodos naturales, arrojando un
% vector. Adicionalmente se calcula una razon de amortiguamiento con cada
% modo.
%
% Input:
%   a               Registro de aceleracion
%   fs              Factor de muestreo del registro
%   gdl             Vector con los grados de libertad de los nodos en el analisis
%
% Parametros opcionales:
%   peakMinDistance Distancia minima entre peaks requerida
%   tukeywinr       Factor de la ventana de tukey
%   zerofill        Indica relleno de ceros para FFT
%
% Output:
%   f               Vector de frecuencias
%   fft             Cell FFT de cada registro de los nodos
%   envFormaModal   Cell con formas modales para cada periodo
%   tlocMean        Periodos medios de cada modo obtenidos de los peaks
%   tlocStd         Desviacion estandar de cada modo obtenido de los peaks
%   locMean         Frecuencia media de cada modo obtenido en los peaks
%   locStd          Desviacion estandar de la frecuencia de cada modo
%   locFreq         Posicion en el vector de frecuencias de cada modo
%   maxlocs         Numero de modos encontrados en los peaks
%   pks             Vector de peaks
%   beta            Vector de amortiguamientos por cada modo
%   betaFreq        Valor del FFT objetivo por cada amortiguamiento modal

%% Parametros opcionales
p = inputParser;
p.KeepUnmatched = true;
addOptional(p, 'peakMinDistance', 0.5); % Requerido para el calculo
addOptional(p, 'tukeywinr', 0.01);
addOptional(p, 'zerofill', 0);
parse(p, varargin{:});
r = p.Results;

% Numero de grados de libertad
ng = length(gdl);

%% Calcula la FFT
fft = cell(1, ng);
for k = 1:ng
    
    % Obtiene la aceleracion del grado de libertad analizado
    acc = a(gdl(k), :);
    
    % Rellena con ceros
    acc = [acc, zeros(1, ceil(r.zerofill*length(acc)))]; %#ok<AGROW>
    tuck = tukeywin(length(acc), r.tukeywinr)';
    [f, fftt, ~] = DFT(fs, acc.*tuck);
    
    % Solo conservo la mitad
    tf = find(f == 0);
    f = f(tf:end);
    fftt = fftt(tf:end);
    
    fftt = abs(fftt); % O si no plot reclama
    fft{k} = fftt; % Guarda el registro
    
end % for k

% Calcula el promedio y la desviacion estandar de los fft
ftmean = zeros(1, length(f));
ftstd = zeros(1, length(f));
ftdata = zeros(1, ng);
ftmax = zeros(1, ng);
for i = 1:length(f)
    for j = 1:ng % Recorre cada grado de libertad
        ftdata(j) = fft{j}(i);
    end % for j
    ftmean(i) = mean(ftdata);
    ftstd(i) = std(ftdata);
    ftmax(i) = max(ftdata);
end % for i

% Calcula los peaks
locs = cell(1, ng);
maxlocs = 0;
for i = 1:ng
    [~, ploc] = findpeaks(fft{i}, f, ...
        'MinPeakDistance', r.peakMinDistance);
    locs{i} = ploc;
    maxlocs = max(length(ploc), maxlocs);
end % for i

% Calcula el promedio y la desviacion estandar
locMean = zeros(1, maxlocs);
locStd = zeros(1, maxlocs);
locFreq = zeros(1, maxlocs); % Frecuencias (posicion)

% Calcula datos pero en periodos
tlocMean = zeros(1, maxlocs);
tlocStd = zeros(1, maxlocs);
for i = 1:maxlocs
    locData = []; % Datos para la posicion i
    tlocData = [];
    for k = 1:ng % Recorre cada nodo de analisis
        if i <= length(locs{k})
            locData = [locData, locs{k}(i)]; %#ok<AGROW>
            tlocData = [tlocData, 1 / locs{k}(i)]; %#ok<AGROW>
        end
    end % for k
    
    locMean(i) = mean(locData);
    locStd(i) = std(locData);
    
    % Estadistica para los periodos
    tlocMean(i) = mean(tlocData);
    tlocStd(i) = std(tlocData);
end % for i

% Busca las posiciones de la frecuencia para locMean
j = 1; % Indice a locMean
for i = 1:length(f)
    if f(i) >= locMean(j)
        locFreq(j) = i;
        j = j + 1; % Avanza
        if j > maxlocs
            break;
        end
    end
end % for i
pks = ftmax(locFreq);

% Calcula los amortiguamientos por cada periodo
beta = zeros(1, length(pks));
betaFreq = cell(1, length(pks));
pksObj = pks ./ sqrt(2);
lastj = 1;
for i=1:length(pks) % Recorre cada peak
    for j=lastj:length(f)-1 % Al comenzar desde el punto anterior asegura que no se repitan frecuencias
        if (ftmax(j) - pksObj(i))*(ftmax(j+1) - pksObj(i)) < 0 % Cruzo el objetivo en i
            
            % Si el ultimo que cruzo fue superior a la frecuencia del peak
            % objetivo entonces este corresponde a la frecuencia derecha, y
            % el anterior a la izquierda
            if j > locFreq(i)
                izq = f(lastj);
                der = f(j);
                lastj = j;
                beta(i) = (der - izq) / (der + izq);
                betaFreq{i} = [izq, der, f(locFreq(i)), pksObj(i)];
                break;
            end
            lastj = j; % Ultimo en atravezar
        end
    end % for j
end % for i

% Calcula la envolvente de los peaks por cada una de las formas
% modales
envFormaModal = cell(1, maxlocs);
for k = 1:maxlocs
    envModo = zeros(1, ng);
    for i = 1:ng % Recorre cada nodo
        envModo(i) = fft{i}(locFreq(k)); % Obtiene la fft asociada al periodo k del registro i
    end % for i
    envModo = envModo ./ max(envModo);
    envFormaModal{k} = envModo;
end % for k

end % PSD function