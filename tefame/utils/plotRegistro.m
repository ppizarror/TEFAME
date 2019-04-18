function plotRegistro(registro, titulo, unidady, tmin, tmax)
%plotRegistro: Es una funcion que grafica un registro sismico
%
% plotRegistro(registro,titulo,unidady,tmin,tmax)

% Obtiene el vector de tiempo y aceleracion
t = registro(:, 1);
a = registro(:, 2);

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
plot(t, a, 'k-', 'LineWidth', 1);
xlim([tmin, tmax]);

% Unidades
if exist('unidady', 'var')
    ylabel(sprintf('Aceleracion (%s)', unidady));
end
if exist('titulo', 'var')
    title(titulo);
end
xlabel('Tiempo (s)');

end