function [v, w] = calculoEigItSubespacio(M, K, nModos, tol)
% calculoEigItSubespacio: Calcula los valores y vectores propios del sistema
% usando el algoritmo de iteracion del subespacio
%
% [w,v] = calculoEigItSubespacio(M,K,nModos,tol)
%
% Parametros:
%   M, K        Matriz masa y rigidez
%   nModos      Numero de modos del analisis
%   tol         Tolerancia del calculo
%
% Salida:
%   w           Matriz vectores propios
%   v           Valores propios

if nargin < 4 || isempty(tol)
    tol = 0.001;
end

% Calculos iniciales
ngdl = length(K);

% Calcula matriz de rigidez triangular LU
[L, U] = lu(K);
U = U';
L = L';

% Genera vector a partir de numeros aleatorios
X = rand(ngdl, min(6, ngdl));
% X = eye(ngdl);

phi = X; % Matriz que contendra los vectores finales
wfinal = zeros(nModos, 1); % Contendra las frecuencias

% Primera estimacion de la frecuencia
Xo = X(:, 1);
wo = sqrt(Xo'*K*Xo) / (Xo' * M * Xo);

% Genera los vectores propios iterando
for i = 1:nModos
    
    err = 1000 * tol; % Reinicializa error
    while err >= tol
        
        % Resuelve el sistema de ecuaciones en dos etapas
        %   L*D*y=b y
        %   L'*u=y
        % donde L*D=U' (U de la descomposicion LU)
        y1 = U \ (M * X);
        X = L \ y1;
        
        % Genera bloque de vectores u_s, rigidez y masa ortogonal
        M_b = X' * M * X;
        K_b = X' * K * X;
        [Z] = eig(K_b, M_b);
        X = X * Z; % Vectores ortogonales
        
        % Calcula Gram-Schmidt para hacer X ortogonal a todos los
        % demas vectores
        if i ~= 1
            X = GSM(X, M, phi(:, 1:i-1));
        end
        X = modonorm(X, M); % Normalizacion modal
        
        % Verifico tolerancia con valores propios
        Xo = X(:, 1);
        w = sqrt(Xo'*K*Xo) / (Xo' * M * Xo);
        err = abs((wo - w)/wo);
        if err < tol
            wfinal(i) = w;
            phi(:, i) = X(:, 1);
            X = [X(:, 2:end), rand(ngdl, 1)];
        else
            wo = w;
        end
        
    end
    
end % for i

% Guarda valores
v = phi;
w = wfinal;

end