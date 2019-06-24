function [f, psd, fft, fftcomp, envFormaModal, tlocMean, tlocStd, locMean, ...
    locStd, locFreq, maxlocs, pks, betaNodo, betaFreqNodo, fftmean, fftstd, ...
    psdmean, psdstd] = PSD(a, fs, gdl, varargin)
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
%   betaFFT         Realiza el calculo del amortiguamiento con FFT o PSD
%   betaFFTMax      El amortiguamiento se calcula con el maximo FFT de todos los nodos
%   peakFFT         Realiza el calculo de peaks con FFT o PSD
%   peakMinDistance Distancia minima entre peaks requerida
%   tukeywinr       Factor de la ventana de tukey
%   zerofill        Indica relleno de ceros para FFT
%
% Output:
%   f               Vector de frecuencias
%   psd             Cell PSD de cada registro de los nodos
%   fft             Cell FFT de cada registro de los nodos
%   fftcomp         Registro completo (Re+Im)
%   envFormaModal   Cell con formas modales para cada periodo
%   tlocMean        Periodos medios de cada modo obtenidos de los peaks
%   tlocStd         Desviacion estandar de cada modo obtenido de los peaks
%   locMean         Frecuencia media de cada modo obtenido en los peaks
%   locStd          Desviacion estandar de la frecuencia de cada modo
%   locFreq         Posicion en el vector de frecuencias de cada modo
%   maxlocs         Numero de modos encontrados en los peaks
%   pks             Vector de peaks
%   betaNodo        Vector de amortiguamientos por cada modo
%   betaFreqNodo    Valor del FFT objetivo por cada amortiguamiento modal
%   fftmean         Promedios FFT
%   fftstd          Desviacion estandar FFT
%   psdmean         Promedios PSD
%   psdstd          Desviacion estandar PSD

%% Parametros opcionales
p = inputParser;
p.KeepUnmatched = true;
addOptional(p, 'betaFFT', true);
addOptional(p, 'betaFFTMax', false); % Calcula el amortiguamiento con el maximo
addOptional(p, 'peakFFT', true);
addOptional(p, 'peakMinDistance', 0.5); % Requerido para el calculo
addOptional(p, 'tmax', -1);
addOptional(p, 'tmin', 0);
addOptional(p, 'tukeywinr', 0.01);
addOptional(p, 'zerofill', 0);
parse(p, varargin{:});
r = p.Results;

if r.betaFFT
    fprintf('\tSe calculan amortiguamientos con FFT\n');
else
    fprintf('\tSe calculan amortiguamientos con PSD\n');
end
if r.peakFFT
    fprintf('\tSe calculan peaks periodos con FFT\n');
else
    fprintf('\tSe calculan peaks periodos con PSD\n');
end

% Numero de grados de libertad
ng = length(gdl);

% Se obtiene la ventana de tiempo
c1 = 1;
if r.tmin ~= 0
    if r.tmin < 0
        error('El tiempo inferior no puede ser cero');
    end
    c1 = fix(r.tmin*fs);
end
cend = false;
if r.tmax ~= -1
    if r.tmin >= r.tmax
        error('El tiempo inferior tmin no puede ser mayor a tmax');
    end
    c2 = fix(r.tmax*fs);
else
    c2 = -1;
    cend = true;
end

%% Calcula la FFT
fft = cell(1, ng);
psd = cell(1, ng);
for k = 1:ng
    
    % Obtiene la aceleracion del grado de libertad analizado
    acc = a(gdl(k), :);
    
    % Limita la ventana
    if cend
        c2 = length(acc);
    end
    if c1 > length(acc)
        error('El tiempo inferior excede el largo del vector de aceleracion');
    end
    if c2 > length(acc)
        error('El tiempo superior excede el largo del vector de aceleracion');
    end
    acc = acc(c1:c2);
    
    % Rellena con ceros
    acc = [acc, zeros(1, floor(r.zerofill*length(acc)))]; %#ok<AGROW>
    tuck = tukeywin(length(acc), r.tukeywinr)';
    acctuck = acc .* tuck;
    [f, fftt, ~] = DFT(fs, acctuck);
    
    % Solo conservo la mitad
    tf = find(f == 0);
    f = f(tf:end);
    fftt = fftt(tf:end);
    fftcomp{k} = fftt; %#ok<AGROW> % Guarda el registro complejo
    fftt = abs(fftt); % O si no plot reclama
    fft{k} = fftt; % Guarda el registro
    
    % Calcula el PSD
    psd{k} = fftt.^2 / 2;
    
end % for k

%% Calcula el promedio y la desviacion estandar de los fft
fftmean = zeros(1, length(f));
fftstd = zeros(1, length(f));
fftdata = zeros(1, ng);
fftmax = zeros(1, ng);
for i = 1:length(f)
    for j = 1:ng % Recorre cada grado de libertad
        fftdata(j) = fft{j}(i);
    end % for j
    fftmean(i) = mean(fftdata);
    fftstd(i) = std(fftdata);
    fftmax(i) = max(fftdata);
end % for i

%% Calcula el promedio y la desviacion estandar de los psd
psdmean = zeros(1, length(f));
psdstd = zeros(1, length(f));
psddata = zeros(1, ng);
psdmax = zeros(1, ng);
for i = 1:length(f)
    for j = 1:ng % Recorre cada grado de libertad
        psddata(j) = psd{j}(i);
    end % for j
    psdmean(i) = mean(psddata);
    psdstd(i) = std(psddata);
    psdmax(i) = max(psddata);
end % for i

%% Calcula los peaks
locs = cell(1, ng);
maxlocs = 0;
for i = 1:ng
    if r.peakFFT
        [~, ploc] = findpeaks(fft{i}, f, ...
            'MinPeakDistance', r.peakMinDistance);
    else
        [~, ploc] = findpeaks(psd{i}, f, ...
            'MinPeakDistance', r.peakMinDistance);
    end
    % [maxtab, mintab] = peakdet(fft{i}, r.peakMinDistance, f);
    locs{i} = ploc;
    maxlocs = max(length(ploc), maxlocs);
end % for i

%% Calcula el promedio y la desviacion estandar de las frecuencias
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

%% Busca las posiciones de la frecuencia para locMean
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

% Peaks periodos
if r.peakFFT
    pks = fftmax(locFreq);
else
    pks = psdmax(locFreq);
end

%% Calcula los amortiguamientos por cada periodo de cada nodo registrado
if r.betaFFT
    pksBeta = fftmax(locFreq);
else
    pksBeta = psdmax(locFreq);
end

betaNodo = cell(1, ng);
betaFreqNodo = cell(1, ng);

% Recorre cada registro
for k = 1:ng
    
    if ~r.betaFFTMax % Si se usan todos los registros
        if r.betaFFT
            ftNodo = fft{k};
        else
            ftNodo = psd{k};
        end
        pksNodo = ftNodo(locFreq);
        pksObj = pksNodo ./ sqrt(2);
    else % Si se usa solo el maximo
        if r.betaFFT
            ftNodo = fftmax;
        else
            ftNodo = psdmax;
        end
        pksObj = pksBeta ./ sqrt(2);
    end
    beta = zeros(1, maxlocs);
    betaFreq = cell(1, maxlocs);
    lastj = 1;
    
    % Recorre cada peak del nodo registrado
    for i = 1:length(pks)
        for j = lastj:length(f) - 1 % Al comenzar desde el punto anterior asegura que no se repitan frecuencias
            if (ftNodo(j) - pksObj(i)) * (ftNodo(j+1) - pksObj(i)) < 0 % Cruzo el objetivo en i              
                % Si el ultimo que cruzo fue superior a la frecuencia del peak
                % objetivo entonces este corresponde a la frecuencia derecha, y
                % el anterior a la izquierda
                if j > locFreq(i)
                    izq = f(lastj);
                    der = f(j);
                    lastj = j;
                    if r.betaFFT
                        beta(i) = (der - izq) / (der + izq);
                    else
                        beta(i) = (der^2 - izq^2) / (der^2 + izq^2);
                    end
                    betaFreq{i} = [izq, der, f(locFreq(i)), pksObj(i)];
                    break;
                end
                lastj = j + 1; % Ultimo en atravesar
            end
        end % for j
    end % for i
    
    % Guarda el resultado
    betaNodo{k} = beta;
    betaFreqNodo{k} = betaFreq;
    
    % Termina la ejecucion (k==1)
    if r.betaFFTMax
        betaNodo = betaNodo{1};
        betaFreqNodo = betaFreqNodo{1};
        break;
    end
    
end % for k

%% Calcula la envolvente de los peaks por cada una de las formas modales, usa FFT
envFormaModal = cell(1, maxlocs);
for k = 1:maxlocs
    envModo = zeros(1, ng);
    for i = 1:ng % Recorre cada nodo
        % Obtiene la fft asociada al periodo k del registro i
        envModo(i) = fft{i}(locFreq(k));
    end % for i
    envModo = envModo ./ max(envModo);
    envFormaModal{k} = envModo;
end % for k

end % PSD function