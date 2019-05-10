function [v, w, error] = calculoEigDirectaBarrido(M, K, nModos, tol)
% calculoEigIterDirecta: Calcula los valores y vectores propios del sistema
% usando el algoritmo de matriz de barrido
%
% [w,v,error] = calculoEigDirectaBarrido(M,K,nModos,tol)
%
% Parametros:
%   M, K        Matriz masa y rigidez
%   nModos      Numero de modos del analisis
%   tol         Tolerancia del calculo
%
% Salida:
%   w           Matriz vectores propios
%   v           Valores propios
%   error       Vector error de iteraciones

if nargin < 4 || isempty(tol)
    tol = 0.001;
end

% Matriz de iteracion directa
D = K^-1 * M;

% Iteracion para cada modo
for i = 1:nModos
    
    % Matriz de barrido
    if i == 1
        S = eye(size(M));
    else
        S = S - (v(:, i-1) * v(:, i-1)' * M) / (v(:, i-1)' * M * v(:, i-1));
    end
    D = D * S;
    
    % Vector inicial
    v0Temp = rand(size(M, 2));
    v0Temp = v0Temp(:, 1);
    w0Temp = sqrt((v0Temp' * K * v0Temp)/(v0Temp' * M * v0Temp));
    err = 1000 * tol;
    
    % Iteracion subsiguientes
    while err >= tol
        
        % Vector de iteracion
        vTemp = modonorm(D*v0Temp, M, 4);
        
        % Aproximacion al valor propio
        wTemp = sqrt((vTemp' * K * vTemp)/(vTemp' * M * vTemp));
        
        % Criterio de detencion basado en frecuencia
        err = abs(wTemp-w0Temp);
        
        % Actualiza
        v0Temp = vTemp;
        w0Temp = wTemp;
        
    end
    
    % Variables finales del proceso
    if i == 1
        w = wTemp;
        v = vTemp;
        error = err;
    else
        w = [w, w0Temp]; %#ok<*AGROW>
        v = [v, v0Temp];
        error = [error, err];
    end
    
end % for i

% Cambios finales
w = w';

end