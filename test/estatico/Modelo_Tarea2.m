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

fprintf('>\tMODELO_TAREA2\n');

% Creamos el modelo
modeloObj = Modelo(2, 3);
modeloObj.definirNombre('Tarea 2');

% Creamos los nodos
nodos = cell(4, 1);
nodos{1} = Nodo('N1', 2, [0, 0]');
nodos{2} = Nodo('N2', 2, [800, 0]');
nodos{3} = Nodo('N3', 2, [400, 400]');
nodos{4} = Nodo('N4', 2, [400, 800]');

% Agregamos los nodos al modelo
modeloObj.agregarNodos(nodos);

% Creamos los elementos
Ao = 20; % [cm2]
Eo = 2248.089; % [tonf/cm2]
elementos = cell(6, 1);
elementos{1} = Biela2D('E1', nodos{1}, nodos{2}, Ao, Eo);
elementos{2} = Biela2D('E2', nodos{1}, nodos{3}, Ao, Eo);
elementos{3} = Biela2D('E3', nodos{3}, nodos{2}, Ao, Eo);
elementos{4} = Biela2D('E4', nodos{1}, nodos{4}, Ao, Eo);
elementos{5} = Biela2D('E5', nodos{3}, nodos{4}, Ao, Eo);
elementos{6} = Biela2D('E6', nodos{4}, nodos{2}, Ao, Eo);

% Agregamos los elementos al modelo
modeloObj.agregarElementos(elementos);

% Creamos las restricciones
restricciones = cell(2, 1);
restricciones{1} = RestriccionNodo('R1', nodos{1}, [1, 2]');
restricciones{2} = RestriccionNodo('R2', nodos{2}, [2]'); %#ok<NBRAK>

% Agregamos las restricciones al modelo
modeloObj.agregarRestricciones(restricciones);

% Creamos la carga
cargas = cell(1, 1);
cargas{1} = CargaNodo('C1', nodos{4}, [8.158, -12.237]');

% Creamos el patron de cargas
PatronesDeCargas = cell(1, 1);
PatronesDeCargas{1} = PatronDeCargasConstante('CargaConstante', cargas);

% Agregamos las cargas al modelo
modeloObj.agregarPatronesDeCargas(PatronesDeCargas);

% Creamos el analisis
analisisObj = AnalisisEstatico(modeloObj);
analisisObj.analizar();
analisisObj.plot('deformada', true, 'factor', 100);
modeloObj.guardarResultados('test/estatico/out/Modelo_Tarea2.txt');