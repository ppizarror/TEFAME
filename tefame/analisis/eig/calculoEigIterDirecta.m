function [v, w, error] = calculoEigIterDirecta(M, K, tol)
% calculoEigIterDirecta: Calcula los valores y vectores propios del sistema
% usando el algoritmo de iteracion directo
%
% [w,v,error] = calculoEigIterDirecta(M,K,tol)
%
% Parametros:
%   M, K        Matriz masa y rigidez
%   tol         Tolerancia calculo
%
% Salida:
%   w           Matriz vectores propios
%   v           Valores propios
%   error       Vector error de iteraciones

if nargin < 3 || isempty(tol)
    tol = 0.001;
end

% Variables iniciales
err = 10 * tol;

% Matriz de iteracion directa
D = K^-1 * M;

% Primera iteracion
v0Temp = rand(size(M, 2));
v0Temp = v0Temp(:, 1);
w = sqrt((v0Temp' * K * v0Temp)/(v0Temp' * M * v0Temp));
error = err;
v = v0Temp;
k = 2;

% Iteracion subsiguientes
while err >= tol
    
    % Vector de iteracion
    vTemp = modonorm(D*v0Temp, M, 4);
    
    % Aproximacion al valor propio
    wTemp = sqrt((vTemp' * K * vTemp)/(vTemp' * M * vTemp));
    
    % Criterio de detencion basado en frecuencia
    err = abs(wTemp-w(k-1));
    v0Temp = vTemp;
    
    % Variables de convergencia
    w = [w, wTemp]; %#ok<*AGROW>
    v = [v, vTemp];
    error = [error, err];
    k = k + 1;
    
end

w = w';

end