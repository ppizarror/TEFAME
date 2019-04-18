function plotRegistro(registro, titulo, unidady, tmin, tmax)
%plotRegistro: Es una funcion que grafica un registro sismico
%
% plotRegistro(registro,titulo,unidady,tmin,tmax)

% Obtiene el vector de tiempo y aceleracion
t = registro(:, 1);
a = registro(:, 2);
dt = t(2) - t(1);

% Tiempos limite
if ~exist('tmin', 'var')
    tmin = min(t);
end
if ~exist('tmax', 'var')
    tmax = max(t);
end

% Genera el grafico
plt = figure();
movegui(plt, 'center');
hold on;
grid on;
grid minor;
plot(t, a, 'k-', 'LineWidth', 0.8);
xlim([tmin, tmax]);

% Unidades
if exist('unidady', 'var')
    ylabel(sprintf('Aceleracion (%s)', unidady));
end
if exist('titulo', 'var')
    title(sprintf('%s - dt=%.2fs', titulo, dt));
end
xlabel('Tiempo (s)');

end