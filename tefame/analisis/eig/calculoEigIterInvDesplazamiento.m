function [v, w, error] = calculoEigIterInvDesplazamiento(M, K, mu, tol)
% calculoEigIterDirecta: Calcula los valores y vectores propios del sistema
% usando el algoritmo de iteracion directo
%
% [v,w,error] = calculoEigIterInvDesplazamiento(M,K,mu,tol)
%
% Parametros:
%   M, K        Matriz masa y rigidez
%   mu          Parametro externo que multiplica a K
%
% Salida:
%   v           Matriz vectores propios
%   w           Valores propios

% Parametros iniciales
err = tol * 10;
K_eff = K - mu .* M;
[L, D] = ldl(K_eff); % Descomposicion ldl'

% Primera iteracion
vo = rand(length(K), 1); % Primer desplazamiento
% vo = [1, 1, 1]';
w = sqrt(mu+sqrt((vo' * K * vo)/(vo' * M * vo))); % Primera aproximacion
w = w(1);
error = err;
v = vo;
b = M * vo;
contador = 2;

% Interaciones
while tol <= err
    yTemp = (L * D) \ b;
    vTemp = L' \ yTemp;
    vTemp = modonorm(vTemp, M, 3);
    wTemp = sqrt(mu+sqrt((vTemp' * K * vTemp)/(vTemp' * M * vTemp)));
    wTemp = wTemp(1);
    err = abs(wTemp-w(contador-1));
    b = M * vTemp;
    
    w = [w, wTemp]; %#ok<*AGROW>
    v = [v, vTemp];
    error = [error, err];
    contador = contador + 1;
end

error = error';
w = w';

v = v(:, 2:end);
w = w(2:end);

end