function [xo, x, dfit, J] = NLFIT(d, t, wo, betao, nmodos, rholim, thetalim, betalim, wlim, varargin)
% NLFIT: Non Linear Fit. Realiza un ajuste no lineal por el metodo de los
% minimos cuadrados para obtener las propiedades modales de una estructura
%
% Input:
%   d           Registro de desplazamientos, size(m,1)
%   wo          Vector de frecuencias angulares obtenidas con modal espectral, size(n,1)
%   betao       Vector de razones de amortiguamiento crítico obtenidas con Rayleigh, size(n,1)
%   nmodos      Numero de modos a considerar para ajuste no lineal
%   rholim      Valores limites de rho
%   thetalim    Valores limites de theta
%   betalim     Valores limites de beta
%   wlim        Valores limites de omega
%
% Parametros opcionales:
%   functionTolerance       Tolerancia maxima (lsqnonlin)
%   maxFunctionEvaluations  Numero maximo de evaluaciones (lsqnonlin)
%
% Output:
%   xo          Valores iniciales de (omga, beta, theta y rho) por cada modo
%   x           Valores iterados de (omga, beta, theta y rho) por cada modo
%   dfit        Registro de desplazamiento obtenido con ajuste no lineal
%   J           Error en el tiempo

%% Parametros opcionales
p = inputParser;
p.KeepUnmatched = true;
addOptional(p, 'functionTolerance', 1e-9);
addOptional(p, 'maxFunctionEvaluations', 3000);
parse(p, varargin{:});
r = p.Results;

%% Verificacion de inputs
if length(wo) < nmodos
    fprintf('\tVector de frecuencias iniciales menor al numero de modos de analisis\n');
    return
end
if length(betao) < nmodos
    fprintf('\tVector de amortiguamientos iniciales menor al numero de modos de analisis\n');
    return
end

%% Generacion de matriz de puntos iniciales
xo = zeros(nmodos, 4); % Columnas son w, beta, theta y rho respectivamente
xo(:, 1) = wo(1:nmodos);
xo(:, 2) = betao(1:nmodos);
xo(:, 3) = pi / 10;
xo(:, 4) = 0.1;

%% Generacion de matriz de limite superior e inferior
lb = zeros(nmodos, 4); % Matriz de limite inferior
lb(:, 1) = wlim(1);
lb(:, 2) = betalim(1);
lb(:, 3) = thetalim(1);
lb(:, 4) = rholim(1);

ub = zeros(nmodos, 4); % Matriz de limite superior
ub(:, 1) = wlim(2);
ub(:, 2) = betalim(2);
ub(:, 3) = thetalim(2);
ub(:, 4) = rholim(2);

%% Generacion de matriz de limite superior e inferior
options = optimoptions(@lsqnonlin, 'MaxFunctionEvaluations', r.maxFunctionEvaluations, ...
    'FunctionTolerance', r.functionTolerance);
f = @(x) FDESPL1M(d, t, nmodos, x);
x = lsqnonlin(f, xo, lb, ub, options);

%% Calcula la funcion del desplazamiento y el error para el fit realizado
dfit = FDESPL1M(0, t, nmodos, x);
J = sqrt(abs(d.^2-dfit.^2));

end % NLFIT function