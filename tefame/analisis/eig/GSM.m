function [V] = GSM(V, M, V_b)
% GSM: Gram - Shmidt Modificado
% Esta funcion deja normalizados y ortogonales entre si (en base a la
% matriz M) los vectores de entrada, mediante el metodo de Gram-Schmidt
% modificado, sistema mas estabe que Gram-Schmidt clasico dado que itera
% por bloques.
%
% [V] = GSM(V,M,V_b)
%
% Input:
%   V   Matriz cuyas columnas corresponden a los vectores a ortonormalizar
%   M   Matriz de base para ortonormalizacion
%   V_b Matriz cuyas columnas ya estan ortonormalizadas en M

% En una primera etapa, si se tiene la matriz V_b se ortogonalizan todos
% los vectores en V a los vectores en esta matriz
if nargin == 3
    [~, n1] = size(V_b);
    for k = 1:n1
        alpha = V_b(:, k)' * M * V;
        V = V - V_b(:, k) * alpha;
    end % for k
end
[~, n1] = size(V);

% El metodo de Gram-Schmidt modificado consiste en, asumiendo en cada
% iteracion que el vector considerado ya es ortogonal a los procesados
% anteriormente, se normaliza el vector y ortogonalizan a este con todos
% los vectores posteriores
for k = 1:n1 - 1
    V(:, k) = V(:, k) / (V(:, k)' * M * V(:, k))^0.5;
    alpha = V(:, k)' * M * V(:, (k + 1):n1);
    V(:, (k + 1):n1) = V(:, (k + 1):n1) - V(:, k) * alpha;
end % for k
V(:, n1) = V(:, n1) / (V(:, n1)' * M * V(:, n1))^0.5;

end