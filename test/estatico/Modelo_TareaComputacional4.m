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

fprintf('>\tMODELO_TAREACOMPUTACIONAL4\n');

% Creamos el modelo
modeloObj = Modelo(3, 12);
modeloObj.definirNombre('Tarea computacional 4');

% Creamos los nodos
nodos = cell(8, 1);
nodos{1} = Nodo('p1', 3, [-4, 0, 4]');
nodos{2} = Nodo('p2', 3, [4, 0, 4]');
nodos{3} = Nodo('p3', 3, [4, 0, -4]');
nodos{4} = Nodo('p4', 3, [-4, 0, -4]');
nodos{5} = Nodo('p5', 3, [-2, 10, 2]');
nodos{6} = Nodo('p6', 3, [2, 10, 2]');
nodos{7} = Nodo('p7', 3, [2, 10, -2]');
nodos{8} = Nodo('p8', 3, [-2, 10, -2]');

% Agregamos los nodos al modelo
modeloObj.agregarNodos(nodos);

% Creamos los elementos
Ao = 0.004; % [m2]
Eo = 200000000; % [kN/m2]
elementos = cell(12, 1);
elementos{1} = Biela3D('E1', nodos{1}, nodos{5}, Ao, Eo); % p1-p5
elementos{2} = Biela3D('E2', nodos{2}, nodos{6}, Ao, Eo); % p2-p6
elementos{3} = Biela3D('E3', nodos{3}, nodos{7}, Ao, Eo); % p3-p7
elementos{4} = Biela3D('E4', nodos{4}, nodos{8}, Ao, Eo); % p4-p8
elementos{5} = Biela3D('E5', nodos{1}, nodos{6}, Ao, Eo); % p1-p6
elementos{6} = Biela3D('E6', nodos{2}, nodos{7}, Ao, Eo); % p2-p7
elementos{7} = Biela3D('E7', nodos{3}, nodos{8}, Ao, Eo); % p3-p8
elementos{8} = Biela3D('E8', nodos{4}, nodos{5}, Ao, Eo); % p4-p5
elementos{9} = Biela3D('E9', nodos{5}, nodos{6}, Ao, Eo); % p5-p6
elementos{10} = Biela3D('E10', nodos{6}, nodos{7}, Ao, Eo); % p6-p7
elementos{11} = Biela3D('E11', nodos{7}, nodos{8}, Ao, Eo); % p7-p8
elementos{12} = Biela3D('E12', nodos{8}, nodos{5}, Ao, Eo); % p8-p5

% Agregamos los elementos al modelo
modeloObj.agregarElementos(elementos);

% Creamos las restricciones
restricciones = cell(4, 1);
restricciones{1} = RestriccionNodo('R1', nodos{1}, [1, 2, 3]'); % p1
restricciones{2} = RestriccionNodo('R2', nodos{2}, [1, 2, 3]'); % p2
restricciones{3} = RestriccionNodo('R3', nodos{3}, [1, 2, 3]'); % p3
restricciones{4} = RestriccionNodo('R4', nodos{4}, [1, 2, 3]'); % p4

% Agregamos las restricciones al modelo
modeloObj.agregarRestricciones(restricciones);

% Creamos la carga
cargas = cell(4, 1);
cargas{1} = CargaNodo('Carga nodo p5', nodos{5}, [45, -90, 0]');
cargas{2} = CargaNodo('Carga nodo p6', nodos{6}, [0, -90, 0]');
cargas{3} = CargaNodo('Carga nodo p7', nodos{7}, [0, -90, 0]');
cargas{4} = CargaNodo('Carga nodo p8', nodos{8}, [45, -90, 0]');

% Creamos el patron de cargas
PatronesDeCargas = cell(1, 1);
PatronesDeCargas{1} = PatronDeCargasConstante('CargaConstante', cargas);

% Agregamos las cargas al modelo
modeloObj.agregarPatronesDeCargas(PatronesDeCargas);

% Creamos el analisis
analisisObj = AnalisisEstatico(modeloObj);
analisisObj.analizar();
analisisObj.plot('deformada', true, 'factor', 10, 'angAz', 180, 'angPol', -60);
modeloObj.guardarResultados('test/estatico/out/Modelo_TareaComputacional4.txt');