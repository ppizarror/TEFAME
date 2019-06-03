close all; clc; clear all; %#ok<*CLALL>
ug = load('Constitucion.txt');
beta = [0, 0.01, 0.05, 0.2]';
ug0 = [ug; zeros(length(ug), 1)];
T = 0.9;
m = 1;
FS = 200;
w = 2 * pi / T;
K = m * w^2;
C = 2 .* beta .* w .* m;
n = length(ug0);
dt = 1 / FS;
ts0 = linspace(0, dt*n, n);
for i = 1:length(beta)
    % Solucion en el espacio de la frecuencia
    [d{i}, v{i}, a{i}, f{i}, Pw{i}, FRF{i}] = respfrec(m, T, beta(i), -ug, FS); %#ok<*SAGROW>
    
    % Efecto de añadir 0 al registro
    [d0{i}, v0{i}, a0{i}, f0{i}, Pw0{i}, FRF0{i}] = respfrec(m, T, beta(i), ug0, FS);
    
    % Newmark
    [depl{i}, vell{i}, accl{i}, ts{i}] = Newmark(m, K, C(i), -m.*ug, FS, 'Average', 0, 0);
end

%% Plots
tmax = max(ts{1});

figure('name', 'Respuesta espacio de las frecuencias');
subplot(3, 1, 1);
plot(ts{1}, a{1}), hold on, plot(ts{1}, a{2}), plot(ts{1}, a{3}), plot(ts{1}, a{4});
title('Aceleracion')
legend({'\beta = 0%', '\beta = 1%', '\beta = 5%', '\beta = 20%'}, 'Location', 'eastoutside');
subplot(3, 1, 2);
plot(ts{1}, v{1}), hold on, plot(ts{1}, v{2}), plot(ts{1}, v{3}), plot(ts{1}, v{4});
title('Velocidad')
legend({'\beta = 0%', '\beta = 1%', '\beta = 5%', '\beta = 20%'}, 'Location', 'eastoutside');
subplot(3, 1, 3);
plot(ts{1}, d{1}), hold on, plot(ts{1}, d{2}), plot(ts{1}, d{3}), plot(ts{1}, d{4});
title('Desplazamiento');
legend({'\beta = 0%', '\beta = 1%', '\beta = 5%', '\beta = 20%'}, 'Location', 'eastoutside');
xlabel('Tiempo [s]');

figure('name', 'Respuesta espacio del tiempo');
subplot(3, 1, 1);
plot(ts{1}, accl{1}), hold on, plot(ts{1}, accl{2}), plot(ts{1}, accl{3}), plot(ts{1}, accl{4});
legend({'\beta = 0%', '\beta = 1%', '\beta = 5%', '\beta = 20%'}, 'Location', 'eastoutside');
subplot(3, 1, 2);
plot(ts{1}, vell{1}), hold on, plot(ts{1}, vell{2}), plot(ts{1}, vell{3}), plot(ts{1}, vell{4});
legend({'\beta = 0%', '\beta = 1%', '\beta = 5%', '\beta = 20%'}, 'Location', 'eastoutside');
subplot(3, 1, 3);
plot(ts{1}, depl{1}), hold on, plot(ts{1}, depl{2}), plot(ts{1}, depl{3}), plot(ts{1}, depl{4});
legend({'\beta = 0%', '\beta = 1%', '\beta = 5%', '\beta = 20%'}, 'Location', 'eastoutside');
xlabel('Tiempo [s]');

figure('name', 'Comparacion de resolucion con espacio de frecuencias y Newmark, beta = 0.2');
plot(ts{1}, a{4});
hold on;
plot(ts{1}, accl{4}, '--');

legend({'Dominio de frecuencia', 'Newmark'});
xlabel('Tiempo [s]');

%% Efecto de añadir ceros
figure('name', 'Comparacion de respuesta espacio de las frecuencias c/s ceros añadidos');
subplot(2, 1, 1);
plot(ts{1}, a{1}), hold on, plot(ts{1}, a{2}), plot(ts{1}, a{3}), plot(ts{1}, a{4});
legend({'\beta = 0%', '\beta = 1%', '\beta = 5%', '\beta = 20%'}, 'Location', 'eastoutside');
title('Respuesta en el espacio de frecuencias');
xlim([0, tmax]);
subplot(2, 1, 2);
plot(ts0, a0{1}), hold on, plot(ts0, a0{2}), plot(ts0, a0{3}), plot(ts0, a0{4});
legend({'\beta = 0%', '\beta = 1%', '\beta = 5%', '\beta = 20%'}, 'Location', 'eastoutside');
xlim([0, tmax]);
title('Respuesta en el espacio de frecuencias añadiendo ceros al registro');

figure('name', 'Registro con y sin ceros añadidos');
subplot(2, 1, 1);
plot(ts{1}, ug);
xlim([0, tmax]);
ylim([-max(ug), max(ug)]);
title('Registro sismico');
subplot(2, 1, 2);
plot(ts0, ug0);
xlim([0, max(ts0)]);
ylim([-max(ug), max(ug)]);
title('Registro sismico con ceros');