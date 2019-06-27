function [x] = NLFIT(d, t, wo, betao, nmodos, rholim, thetalim, betalim, wlim)
% NLFIT: Non Linear Fit. Realiza un ajuste no lineal por el metodo de los
% minimos cuadrados para obtener las propiedades modales de una estructura
%
% Input:
%   d               Registro de desplazamientos size(m, 1)
%   wo              Vector de frecuencias angulares obtenidas con modal espectral, size(n, 1)
%   betao           Vector de razones de amortiguamiento crítico obtenidas con Rayleigh, size(n, 1)
%   nmodos          Numero de modos a considerar para ajuste no lineal
%
%
% Output:
%   dfit            Registro de desplazamiento obtenido con ajuste no lineal

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

xo = zeros(nmodos, 4); %Columnas son w, beta, theta y rho respectivamente
xo(:, 1) = wo(1:nmodos);
xo(:, 2) = betao(1:nmodos);
xo(:, 3) = pi / 10;
xo(:, 4) = 0.1;

xo

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

% dfit = FDESPL1M(d, t, nmodos, xo)
% size(dfit)


%% Generacion de matriz de limite superior e inferior

d2 = d(1:4000);
t2 = t(1:4000);
options = optimoptions(@lsqnonlin, 'MaxFunctionEvaluations', 3000, 'FunctionTolerance', 10^-9);
f = @(x) FDESPL1M(d2, t2, nmodos, x);

x = lsqnonlin(f, xo, lb, ub, options);

x

%%
dfit = FDESPL1M(0, t, nmodos, x);
J = sqrt(abs(d.^2 - dfit.^2));
figure()
hold on
plot(t, d, 'b')
plot(t, dfit, 'r')
title('Historial de Desplazamiento')
xlabel('Tiempo (s)')
ylabel('Desplazamiento (m)')
legend('Real', 'Ajustado')
grid on
grid minor

figure()
hold on
plot(t, J, 'b')
title('Historial de Error')
xlabel('Tiempo (s)')
ylabel('Función de Error (m)')
grid on
grid minor


    
end % NLFIT function
