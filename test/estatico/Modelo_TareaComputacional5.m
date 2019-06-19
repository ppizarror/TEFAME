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

fprintf('>\tTEST_TAREACOMPUTACIONAL5\n');

% Modelo tarea computacional 5
%
%                    1 Tonf/m
%            |||||||||||||||||||||||||||           |
% 20 Tonf/m  vvvvvvvvvvvvvvvvvvvvvvvvvvv           v
%   -------> ---------------------------           _
%    ------> |           ________      | 150cm    | |
%     -----> |          |   _____|     | 150cm    | |
%       ---> |          | _|           | 100cm   >| |<- 20cm
%         -> |                         | 100cm    | |
% =====================================================
%                250    100  150   200
%                         cm

t = 20; % Espesor [cm]
E = 300000; % Modulo de Elasticidad [kgf/cm^2]
nu = 0.15; % Modulo de Poisson

% Creamos el modelo
modeloObj = Modelo(2, 25);
modeloObj.definirNombre('Tarea computacional 5');

% Creamos los nodos
m_cm = 100;
nodos = cell(25, 1);
nodos{1} = Nodo('N1', 2, [0, 0]'*m_cm);
nodos{2} = Nodo('N2', 2, [2.5, 0]'*m_cm);
nodos{3} = Nodo('N3', 2, [3.5, 0]'*m_cm);
nodos{4} = Nodo('N4', 2, [5, 0]'*m_cm);
nodos{5} = Nodo('N5', 2, [7, 0]'*m_cm);
nodos{6} = Nodo('N6', 2, [0, 1]'*m_cm);
nodos{7} = Nodo('N7', 2, [2.5, 1]'*m_cm);
nodos{8} = Nodo('N8', 2, [3.5, 1]'*m_cm);
nodos{9} = Nodo('N9', 2, [5, 1]'*m_cm);
nodos{10} = Nodo('N10', 2, [7, 1]'*m_cm);
nodos{11} = Nodo('N11', 2, [0, 2]'*m_cm);
nodos{12} = Nodo('N12', 2, [2.5, 2]'*m_cm);
nodos{13} = Nodo('N13', 2, [3.5, 2]'*m_cm);
nodos{14} = Nodo('N14', 2, [5, 2]'*m_cm);
nodos{15} = Nodo('N15', 2, [7, 2]'*m_cm);
nodos{16} = Nodo('N16', 2, [0, 3.5]'*m_cm);
nodos{17} = Nodo('N17', 2, [2.5, 3.5]'*m_cm);
nodos{18} = Nodo('N18', 2, [3.5, 3.5]'*m_cm);
nodos{19} = Nodo('N19', 2, [5, 3.5]'*m_cm);
nodos{20} = Nodo('N20', 2, [7, 3.5]'*m_cm);
nodos{21} = Nodo('N21', 2, [0, 5]'*m_cm);
nodos{22} = Nodo('N22', 2, [2.5, 5]'*m_cm);
nodos{23} = Nodo('N23', 2, [3.5, 5]'*m_cm);
nodos{24} = Nodo('N24', 2, [5, 5]'*m_cm);
nodos{25} = Nodo('N25', 2, [7, 5]'*m_cm);

% Agregamos los nodos al modelo
modeloObj.agregarNodos(nodos);

% Creamos los elementos
%
% 4 ------------- 3      Esta es la notacion que se usa para crear los
% |       y       |      elementos
% |       #x      |
% |               |
% 1 ------------- 2
%
elementos = cell(13, 1);
elementos{1} = Membrana('MEM1', nodos{1}, nodos{2}, nodos{7}, nodos{6}, E, nu, t);
elementos{2} = Membrana('MEM2', nodos{2}, nodos{3}, nodos{8}, nodos{7}, E, nu, t);
elementos{3} = Membrana('MEM3', nodos{3}, nodos{4}, nodos{9}, nodos{8}, E, nu, t);
elementos{4} = Membrana('MEM4', nodos{4}, nodos{5}, nodos{10}, nodos{9}, E, nu, t);
elementos{5} = Membrana('MEM5', nodos{6}, nodos{7}, nodos{12}, nodos{11}, E, nu, t);
elementos{6} = Membrana('MEM6', nodos{8}, nodos{9}, nodos{14}, nodos{13}, E, nu, t);
elementos{7} = Membrana('MEM7', nodos{9}, nodos{10}, nodos{15}, nodos{14}, E, nu, t);
elementos{8} = Membrana('MEM8', nodos{11}, nodos{12}, nodos{17}, nodos{16}, E, nu, t);
elementos{9} = Membrana('MEM9', nodos{14}, nodos{15}, nodos{20}, nodos{19}, E, nu, t);
elementos{10} = Membrana('MEM10', nodos{16}, nodos{17}, nodos{22}, nodos{21}, E, nu, t);
elementos{11} = Membrana('MEM11', nodos{17}, nodos{18}, nodos{23}, nodos{22}, E, nu, t);
elementos{12} = Membrana('MEM12', nodos{18}, nodos{19}, nodos{24}, nodos{23}, E, nu, t);
elementos{13} = Membrana('MEM13', nodos{19}, nodos{20}, nodos{25}, nodos{24}, E, nu, t);

% Agregamos los elementos al modelo
modeloObj.agregarElementos(elementos);

% Creamos las restricciones
restricciones = cell(5, 1);
restricciones{1} = RestriccionNodo('R1', nodos{1}, [1, 2]');
restricciones{2} = RestriccionNodo('R2', nodos{2}, [1, 2]');
restricciones{3} = RestriccionNodo('R3', nodos{3}, [1, 2]');
restricciones{4} = RestriccionNodo('R4', nodos{4}, [1, 2]');
restricciones{5} = RestriccionNodo('R5', nodos{5}, [1, 2]');

% Agregamos las restricciones al modelo
modeloObj.agregarRestricciones(restricciones);

% Creamos la carga
cargas = cell(8, 1);

% Cargas verticales
vmax = 10; % 1 tonf/m = 0.01 tonf/cm = 10 kgf/cm
cargas{1} = CargaMembranaDistribuida('V 1TONF/M @10', elementos{10}, 4, 3, -vmax, 0, -vmax, 1); % 1 tonf/m = 10 kgf/cm
cargas{2} = CargaMembranaDistribuida('V 1TONF/M @11', elementos{11}, 4, 3, -vmax, 0, -vmax, 1);
cargas{3} = CargaMembranaDistribuida('V 1TONF/M @12', elementos{12}, 4, 3, -vmax, 0, -vmax, 1);
cargas{4} = CargaMembranaDistribuida('V 1TONF/M @13', elementos{13}, 4, 3, -vmax, 0, -vmax, 1);

hmax = 200; % 20 tonf/m = 0.2tonf/cm = 200 kgf/cm
h = 5; % Altura maxima, asi calcula por tramos cuanto es el triangulo que corresponde

% Cargas horizontales, triangular
cargas{5} = CargaMembranaDistribuida('H 20TONF/M @1', elementos{1}, 1, 4, 0, 0, hmax*(1 / h), 1);
cargas{6} = CargaMembranaDistribuida('H 20TONF/M @5', elementos{5}, 1, 4, hmax*(1 / h), 0, hmax*(2 / h), 1);
cargas{7} = CargaMembranaDistribuida('H 20TONF/M @8', elementos{8}, 1, 4, hmax*(2 / h), 0, hmax*(3.5 / h), 1);
cargas{8} = CargaMembranaDistribuida('H 20TONF/M @10', elementos{10}, 1, 4, hmax*(3.5 / h), 0, hmax, 1);

% Creamos el patron de cargas
PatronesDeCargas = cell(1, 1);
PatronesDeCargas{1} = PatronDeCargasConstante('CargaConstante', cargas);

% Agregamos las cargas al modelo
modeloObj.agregarPatronesDeCargas(PatronesDeCargas);

% Creamos el analisis
analisisObj = AnalisisEstatico(modeloObj);
analisisObj.analizar();
analisisObj.plot('deformada', true, 'factor', 1000);

modeloObj.guardarResultados('test/estatico/out/Modelo_TareaComputacional5.txt');