close all; clc;
ug = load('Constitucion.sis').*9.81;
[frec, ff, ts] = DFT(200, ug);
ff = fftshift(ff);
a = length(ug);
b = length(ts);
ug = [ug; zeros(b-a, 1)];
figure('name', 'Registro Sismico');
subplot(2, 1, 1);
plot(ts, ug);
xlabel('t (s)');
ylabel('Aceleracion (m/s^2)')
title(['Registro Sismico']);
grid on
grid minor
subplot(2, 1, 2);
stem(frec, abs(ff), 'r');
hold on;
plot(frec, imag(ff), 'b');
plot(frec, real(ff), 'y');
title(['Tranformada de Fourier de Registro Sismico FS = ', num2str(200), ' (Hz)']);
legend({'|X|', 'Im(X)', 'Re(X)'}, 'Location', 'best');
xlabel('f (Hz)');
ylabel('Amplitud (-)')
grid on
grid minor
hold off;


% Para una ventana de 30 seg
FS = [200, 50, 10]'; % Hz
dt = 1 ./ FS;
t1 = 0:dt(1):30 - dt(1);
t2 = 0:dt(2):30 - dt(2);
t3 = 0:dt(3):30 - dt(3);
t = {t1, t2, t3}';

% Tipo de senales
sen = cell(length(t), 1);
coss = cell(length(t), 1);
diracc = cell(length(t), 1);
const = cell(length(t), 1);

%% Plot de Funciones
figure('name', 'Fourier, funcion seno');
for i = 1:length(t) % Funcion sen
    sen{i} = 5 .* sin(20.*pi.*t{i})';
    [senfrec{i}, senff{i}, ~] = DFT(FS(i), sen{i}); %#ok<*SAGROW>
    senff{i} = fftshift(senff{i});
    subplot(3, 2, 2*(i)-1);
    stem(t{i}, sen{i});
    xlabel('t (s)');
    ylabel('Amplitud (-)')
    title(['Funcion Seno FS = ', num2str(FS(i)), ' (Hz)']);
    grid on
    grid minor
    subplot(3, 2, 2*i);
    stem(senfrec{i}, abs(senff{i}), 'r');
    hold on;
    plot(senfrec{i}, imag(senff{i}), 'b');
    plot(senfrec{i}, real(senff{i}), 'y');
    legend({'|X|', 'Im(X)', 'Re(X)'}, 'Location', 'northeast');
    xlabel('f (Hz)');
    ylabel('Amplitud (-)')
    grid on
    grid minor
    hold off;
    title(['Transformada de Fourier Funcion Seno FS = ', num2str(FS(i)), ' (Hz)']);
end % for i
%%
figure('name', 'Fourier, funcion coseno');
for i = 1:length(t) % Funcion cos
    coss{i} = 5 .* cos(20.*pi.*t{i})';
    [cossfrec{i}, cossff{i}, ~] = DFT(FS(i), coss{i});
    cossff{i} = fftshift(cossff{i});
    subplot(3, 2, 2*(i)-1);
    plot(t{i}, coss{i});
    xlabel('t (s)');
    ylabel('Amplitud (-)')
    title(['Funcion Coseno FS = ', num2str(FS(i)), ' (Hz)']);
    grid on
    grid minor
    subplot(3, 2, 2*i);
    stem(cossfrec{i}, abs(cossff{i}), 'r');
    hold on;
    plot(cossfrec{i}, imag(cossff{i}), 'b');
    plot(cossfrec{i}, real(cossff{i}), 'y');
    legend({'|X|', 'Im(X)', 'Re(X)'}, 'Location', 'northeast');
    xlabel('f (Hz)');
    ylabel('Amplitud (-)')
    title(['Transformada de Fourier Funcion Coseno FS = ', num2str(FS(i)), ' (Hz)']);
    grid on
    grid minor
    hold off;
    title(['FS = ', num2str(FS(i)), ' (Hz)']);
end % for i

%%
figure('name', 'Fourier, funcion dirac');
for i = 1:length(t) % Funcion dirac
    for j = 1:length(t{i})
        tj = t{i};
        if tj(j) == 0
            dir(j) = 5;
        else
            dir(j) = 0;
        end
    end % for j
    diracc{i} = dir';
    [diraccfrec{i}, diraccff{i}, ~] = DFT(FS(i), diracc{i});
    diraccff{i} = fftshift(diraccff{i});
    subplot(3, 2, 2*(i)-1);
    stem(t{i}, diracc{i});
    xlabel('t (s)');
    ylabel('Amplitud (-)')
    title(['Funcion Dirac FS = ', num2str(FS(i)), ' (Hz)']);
    grid on
    grid minor
    subplot(3, 2, 2*i);
    stem(diraccfrec{i}, abs(diraccff{i}), 'r');
    hold on;
    plot(diraccfrec{i}, imag(diraccff{i}), 'b');
    plot(diraccfrec{i}, real(diraccff{i}), 'y');
    legend({'|X|', 'Im(X)', 'Re(X)'}, 'Location', 'northeast');
    xlabel('f (Hz)');
    ylabel('Amplitud (-)')
    title(['Transformada de Fourier Funcion Dirac FS = ', num2str(FS(i)), ' (Hz)']);
    grid on
    grid minor
    hold off;
    title(['FS = ', num2str(FS(i)), ' (Hz)']);
    clear dir tj;
end % for i
%%

figure('name', 'Fourier, funcion constante');
for i = 1:length(t) % Funcion constante
    const{i} = 5 .* (diag(eye(length(t{i}))))';
    [constfrec{i}, constff{i}, ~] = DFT(FS(i), const{i});
    constff{i} = fftshift(constff{i});
    subplot(3, 2, 2*(i)-1);
    plot(t{i}, const{i});
    xlabel('t (s)');
    ylabel('Amplitud (-)')
    title(['Funcion Constante FS = ', num2str(FS(i)), ' (Hz)']);
    grid on
    grid minor
    subplot(3, 2, 2*i);
    stem(constfrec{i}, abs(constff{i}), 'r');
    hold on;
    plot(constfrec{i}, imag(constff{i}), 'b');
    plot(constfrec{i}, real(constff{i}), 'y');
    legend({'|X|', 'Im(X)', 'Re(X)'}, 'Location', 'northeast');
    xlabel('f (Hz)');
    ylabel('Amplitud (-)')
    title(['Transformada de Funcion Constante FS = ', num2str(FS(i)), ' (Hz)']);
    grid on
    grid minor
    hold off;
end % for i

%%
figure('name', 'Fourier, Cajon ancho To = 5[s]');
for i = 1:length(t) % Funcion constante
    for j = 1:length(t{i})
        tj = t{i};
        if tj(j) <= 5
            Ca05aux(j) = 5;
        else
            Ca05aux(j) = 0;
        end
    end % for j
    Ca05{i} = Ca05aux';
    [Ca05frec{i}, Ca05ff{i}, ~] = DFT(FS(i), Ca05{i});
    Ca05ff{i} = fftshift(Ca05ff{i});
    subplot(3, 2, 2*(i)-1);
    plot(t{i}, Ca05{i});
    xlabel('t (s)');
    ylabel('Amplitud (-)')
    title(['Funcion Cajon To = 5 (s) FS = ', num2str(FS(i)), ' (Hz)']);
    grid on
    grid minor
    subplot(3, 2, 2*i);
    stem(Ca05frec{i}, abs(Ca05ff{i}), 'r');
    hold on;
    plot(Ca05frec{i}, imag(Ca05ff{i}), 'b');
    plot(Ca05frec{i}, real(Ca05ff{i}), 'y');
    legend({'|X|', 'Im(X)', 'Re(X)'}, 'Location', 'northeast');
    xlabel('f (Hz)');
    ylabel('Amplitud (-)')
    hold off;
    title(['Transformada de Fourier Funcion Cajon To = 5 (s) FS = ', num2str(FS(i)), ' (Hz)']);
    grid on
    grid minor
    clear tj Ca05aux;
end % for i

%%
figure('name', 'Fourier, Cajon ancho To = 10[s]');
for i = 1:length(t) % Funcion constante
    for j = 1:length(t{i})
        tj = t{i};
        if tj(j) <= 10
            Ca10aux(j) = 5;
        else
            Ca10aux(j) = 0;
        end
    end % for j
    Ca10{i} = Ca10aux';
    [Ca10frec{i}, Ca10ff{i}, ~] = DFT(FS(i), Ca10{i});
    Ca10ff{i} = fftshift(Ca10ff{i});
    subplot(3, 2, 2*(i)-1);
    plot(t{i}, Ca10{i});
    xlabel('t (s)');
    ylabel('Amplitud (-)')
    title(['Funcion Cajon To = 10 (s) FS = ', num2str(FS(i)), ' (Hz)']);
    grid on
    grid minor
    subplot(3, 2, 2*i);
    stem(Ca10frec{i}, abs(Ca10ff{i}), 'r');
    hold on;
    plot(Ca10frec{i}, imag(Ca10ff{i}), 'b');
    plot(Ca10frec{i}, real(Ca10ff{i}), 'y');
    legend({'|X|', 'Im(X)', 'Re(X)'}, 'Location', 'northeast');
    xlabel('f (Hz)');
    ylabel('Amplitud (-)')
    title(['Transformada de Fourier Funcion Cajon To = 10 (s) FS = ', num2str(FS(i)), ' (Hz)']);
    grid on
    grid minor
    hold off;
    clear tj Ca10aux;
end % for i

%%
figure('name', 'Fourier, Cajon ancho To = 20[s]');
for i = 1:length(t) % Funcion constante
    for j = 1:length(t{i})
        tj = t{i};
        if tj(j) <= 20
            Ca20aux(j) = 5;
        else
            Ca20aux(j) = 0;
        end
    end
    Ca20{i} = Ca20aux';
    [Ca20frec{i}, Ca20ff{i}, ~] = DFT(FS(i), Ca20{i});
    Ca20ff{i} = fftshift(Ca20ff{i});
    subplot(3, 2, 2*(i)-1);
    plot(t{i}, Ca20{i});
    xlabel('t (s)');
    ylabel('Amplitud (-)')
    title(['Transformada de Fourier Funcion Cajon To = 20 (s) FS = ', num2str(FS(i)), ' (Hz)']);
    grid on
    grid minor
    subplot(3, 2, 2*i);
    stem(Ca20frec{i}, abs(Ca20ff{i}), 'r');
    hold on;
    plot(Ca20frec{i}, imag(Ca20ff{i}), 'b');
    plot(Ca20frec{i}, real(Ca20ff{i}), 'y');
    legend({'|X|', 'Im(X)', 'Re(X)'}, 'Location', 'northeast');
    xlabel('f (Hz)');
    ylabel('Amplitud (-)')
    title(['Transformada de Fourier Funcion Cajon To = 20 (s) FS = ', num2str(FS(i)), ' (Hz)']);
    grid on
    grid minor
    hold off;
    clear tj Ca20aux;
end % for i