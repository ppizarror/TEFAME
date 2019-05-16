function [phi, wn] = calculoLDV(M, K, F , nritz)
% calculoLDV: Esta funcion genera los vectores de Ritz Dependientes de la
% carga
%
% [phi,T] = calculoLDV(M , K , F , nritz)
%
% Parametros:
%   M, K        Matriz masa y rigidez
%   F           Matriz cuyas columnas son vectores de forma de las cargas
%               externas
%   nritz       Numero de vectores de Ritz a obtener para cada condicion de
%               carga
% Salida:
%   w           Matriz vectores propios
%   v           Valores propios


% I.- INITIAL CALCULATIONS

[m , nConCarga] = size(F);
[L , U] = lu(K);
U = U';
L = L';
y1 = U \ F;
u_s = L \ y1;
V = zeros(m , nConCarga * nritz);
M_b = u_s' * M * u_s;
K_b = u_s' * K * u_s;
[Z] = eig(K_b , M_b);
V(: , 1:nConCarga) = u_s * Z; 
[V(: , 1:nConCarga)] = modonorm(V(: , 1:nConCarga) , M);

% II.- GENERATE BLOCKS OF RITZ VECTORS

for i = 1 : nritz - 1
   y1 = U \ (M * V(: , (i - 1) * nConCarga + 1 : i * nConCarga)); 
   X_i = L \ y1;
   M_b = X_i' * M * X_i;
   K_b = X_i' * K * X_i;
   [Z] = eig(K_b , M_b);
   V(: , i * nConCarga + 1 : (i + 1) * nConCarga) = X_i * Z;
   V(: , i * nConCarga + 1 : (i + 1) * nConCarga) = GSM(V(: , i * ...
       nConCarga + 1 : (i + 1) * nConCarga) , M , V(: , 1 : i * nConCarga));
   V(: , i * nConCarga + 1 : (i + 1) * nConCarga) = GSM(V(: , i * ...
       nConCarga + 1 : (i + 1) * nConCarga) , M , V(: , 1 : i * nConCarga));
end

% III.- GENERATE BLOCKS OF RITZ VECTORS

K_b = V' * K * V;
[Z , w2] = eig(K_b);
phi = V * Z;
T = 2 * pi ./ diag(w2).^0.5;
wn = 2 * pi ./ T;
end