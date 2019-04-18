function reg = cargaRegistroSimple(archivo, dt, varargin)
%cargaRegistroSimple: Carga un registro simple de un archivo sin encabezado
%que tiene una sola columna con datos
%
% reg = cargaRegistroSimple(archivo,dt,varargin)
%
% Parametros opcionales:
%   'factor': Factor que multiplica al registro (1 por defecto)

p = inputParser;
p.KeepUnmatched = true;
addOptional(p, 'factor', 1);
parse(p, varargin{:});
r = p.Results;

reg = cargaRegistroArchivoGeneral(archivo, '\n', ' ', 0, 0, 1, dt, r.factor);

end