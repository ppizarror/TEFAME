function [w, v] = calculoEigEigs(M, K, nModos)
% calculoEigEigs: Calcula los valores y vectores propios del sistema usando
% la funcion eigs
%
% [w,v] = calculoEigEigs(M,K,nModos)
%
% Parametros:
%   M, K        Matriz masa y rigidez
%   nmodos      Numero de modos del analisis
%
% Salida:
%   w           Matriz vectores propios
%   v           Valores propios

ngdl = length(M);
nModos = min(nModos, ngdl);
invM = zeros(ngdl, ngdl);
for i = 1:ngdl
    invM(i, i) = 1 / M(i, i);
end % for i
sysMat = invM * K;
[w, v] = eigs(sysMat, nModos, 'sm');
v = sqrt(diag(v));

end