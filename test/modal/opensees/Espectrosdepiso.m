%|______________________________________________________________________|
%|                                                                      |
%|          TEFAME - Toolbox para Elementos Finitos y Analisis          |
%|                  Matricial de Estructuras en MATLAB                  |
%|                                                                      |
%|                   Area  de Estructuras y Geotecnia                   |
%|                   Departamento de Ingenieria Civil                   |
%|              Facultad de Ciencias Fisicas y Matematicas              |
%|                         Universidad de Chile                         |
%|                                                                      |
%| TEFAME es una  plataforma en base a objetos para modelar, analizar y |
%| visualizar  la respuesta de sistemas  estructurales usando el metodo |
%| de elementos finitos y analisis matricial de estructuras en MATLAB.  |
%| Repositorio: https://github.com/ppizarror/TEFAME                     |
%|______________________________________________________________________|
%|                                                                      |
%| MIT License                                                          |
%| Copyright (c) 2018-2019 Pablo Pizarro R @ppizarror.com.              |
%|                                                                      |
%| Permission is hereby granted, free of charge, to any person obtai-   |
%| ning a copy of this software and associated documentation files (the |
%| "Software"), to deal in the Software without restriction, including  |
%| without limitation the rights to use, copy, modify, merge, publish,  |
%| distribute, sublicense, and/or sell copies of the Software, and to   |
%| permit persons to whom the Software is furnished to do so, subject   |
%| to the following conditions:                                         |
%|                                                                      |
%| The above copyright notice and this permission notice shall be       |
%| included in all copies or substantial portions of the Software.      |
%|                                                                      |
%| THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,      |
%| EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF   |
%| MERCHANTABILITY,FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.|
%| IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY |
%| CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, |
%| TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE    |
%| SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.               |
%|______________________________________________________________________|

tic;
clear all; close all; clc; %#ok<*CLALL>

% 1:Angol
% 2:Concepcion
% 3:Constitucion
% 4:Curico
% 5:Matanzas
% 6:Mirador
% 7:Vina

Data = {'Data\Angol', 'Data\Concepcion', 'Data\Constitucion', 'Data\Curico', 'Data\Matanzas', 'Data\Mirador', 'Data\Vina'}; %nombre de directorio de data
Lugares_Tex = {'Angol', 'Concepci\''on', 'Constituci\''on', 'Curic\''o', 'Matanzas', 'Mirador', 'Vi\~na del Mar'}; %nombres de registros
n_reg = length(Data); %cantidad de registros

%% Construccion de espectros

T = 0.01:0.01:3.6;
beta = [0.05, 0.1, 0.2];
Sa_techo5 = zeros(length(T), n_reg);
Sa_techo10 = zeros(length(T), n_reg);
Sa_techo20 = zeros(length(T), n_reg);
for i = 1:n_reg
    NodesAcel = importdata(fullfile(Data{1, i}, 'Nodes_AbsAcel.out'));
    TimeAcel = NodesAcel(:, 1);
    deltat = TimeAcel(length(TimeAcel)) - TimeAcel(length(TimeAcel)-1);
    AcelTecho = NodesAcel(:, 82) ./ 981; %pasar a g nodo82 es el techo
    for j = 1:length(T) %Cantidad de periodos
        %Espectro de Techo 5% 10% y 20%
        [~, ~, accel] = accelprom(AcelTecho, 2*pi/T(j), beta(1), deltat);
        Sa_techo5(j, i) = max(abs(accel+AcelTecho'));
        
        [~, ~, accel] = accelprom(AcelTecho, 2*pi/T(j), beta(2), deltat);
        Sa_techo10(j, i) = max(abs(accel+AcelTecho'));
        
        [~, ~, accel] = accelprom(AcelTecho, 2*pi/T(j), beta(3), deltat);
        Sa_techo20(j, i) = max(abs(accel+AcelTecho'));
    end
    
end

%% Ploteo espectro de piso
Sa5pc = figure();
plot(T, Sa_techo5);
grid on; hold on;
xlabel('Periodo T [s]', 'Interpreter', 'LaTex')
ylabel('S$_a$ [g]', 'Interpreter', 'LaTex')
title(['Espectro de aceleraciones de Techo. $\beta= $', num2str(beta(1)*100), '\%.'], 'Interpreter', 'LaTex')
set(legend(Lugares_Tex, 'Location', 'northeast'), 'Interpreter', 'LaTex')
xlim([0, 3.5]);
saveas(Sa5pc, fullfile('Data', 'Espectro de techo 5%'))

Sa10pc = figure();
plot(T, Sa_techo10);
grid on; hold on;
xlabel('Periodo T [s]', 'Interpreter', 'LaTex')
ylabel('S$_a$ [g]', 'Interpreter', 'LaTex')
title(['Espectro de aceleraciones de Techo. $\beta= $', num2str(beta(2)*100), '\%.'], 'Interpreter', 'LaTex')
set(legend(Lugares_Tex, 'Location', 'northeast'), 'Interpreter', 'LaTex')
xlim([0, 3.5]);
saveas(Sa10pc, fullfile('Data', ['Espectro de techo 10%'])) %#ok<*NBRAK>

Sa20pc = figure();
plot(T, Sa_techo20);
grid on; hold on;
xlabel('Periodo T [s]', 'Interpreter', 'LaTex')
ylabel('S$_a$ [g]', 'Interpreter', 'LaTex')
title(['Espectro de aceleraciones de Techo. $\beta= $', num2str(beta(3)*100), '\%.'], 'Interpreter', 'LaTex')
set(legend(Lugares_Tex, 'Location', 'northeast'), 'Interpreter', 'LaTex')
xlim([0, 3.5]);
saveas(Sa20pc, fullfile('Data', 'Espectro de techo 20%'))

toc