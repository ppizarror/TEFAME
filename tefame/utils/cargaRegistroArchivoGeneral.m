function reg = cargaRegistroArchivoGeneral(archivo, linedelim, coldelim, header, footer, ncol, dt, factor)
% cargaRegistroArchivoGeneral: Carga un archivo sismico y retorna una matriz del
% tipo [t1, a1; t2, a2; ...]
%
% reg = cargaRegistroSismico(archivo,linedelim,coldelim,header,ncol,dt,factor)

% Obtiene el archivo
fprintf('Cargando registro sismico %s ... ', archivo);
try
    C = textread(archivo, '%s', 'delimiter', linedelim); %#ok<*DTXTRD>
catch %#ok<*CTCH>
    error('Archivo no encontrado');
end
lc = length(C);

% Lineas utiles
lu = lc - footer - header;
lcol = length(ncol);

% Crea la matriz
reg = zeros(lu, 1+lcol);

% Comprueba que las columnas esten bien definidas
d = strsplit(C{1+header}, coldelim);
lcolr = length(d);

if lcol > lcolr
    error('El numero de columnas requerido excede el existente en el archivo');
end
if max(ncol) < lcolr
    error('Indice de columna invalido, excede las columnas existentes en el archivo');
end

% Recorre el archivo
t = 0; % Guarda el tiempo
for i = 1:lu
    d = strsplit(C{i+header}, coldelim);
    for j = 1:lcol
        reg(i, 1+j) = str2double(d{ncol(j)}) * factor;
    end % for j
    reg(i, 1) = t;
    t = t + dt;
end % for i

% Aplica correccion por linea base
for i = 1:lcol
    reg(:, 1+i) = detrend(reg(:, i+1), 0);
end % for i

fprintf('OK\n');

end