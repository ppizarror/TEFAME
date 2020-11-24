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
%| Copyright (c) 2018-2020 Pablo Pizarro R @ppizarror.com.              |
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

fprintf('>\tENREJADO_SIMPLE_2D\n');

% Creamos el modelo
modeloObj = Modelo(2, 3);
modeloObj.definirNombre('Enrejado 2D');

% Creamos los nodos
nodos = cell(6, 1);
nodos{1} = Nodo('A', 2, [0, 0]');
nodos{2} = Nodo('B', 2, [0, 1]');
nodos{3} = Nodo('C', 2, [1, 0]');
nodos{4} = Nodo('D', 2, [1, 1]');
nodos{5} = Nodo('E', 2, [2, 0]');
nodos{6} = Nodo('F', 2, [2, 1]');

% Agregamos los nodos al modelo
modeloObj.agregarNodos(nodos);

% Creamos los elementos
Ao = 20; % [cm2]
Eo = 2248.089; % [tonf/cm2]
elementos = cell(9, 1);
elementos{1} = Biela2D('AB', nodos{1}, nodos{2}, Ao, Eo);
elementos{2} = Biela2D('AC', nodos{1}, nodos{3}, Ao, Eo);
elementos{3} = Biela2D('BC', nodos{2}, nodos{3}, Ao, Eo);
elementos{4} = Biela2D('BD', nodos{2}, nodos{4}, Ao, Eo);
elementos{5} = Biela2D('DC', nodos{3}, nodos{4}, Ao, Eo);
elementos{6} = Biela2D('CE', nodos{3}, nodos{5}, Ao, Eo);
elementos{7} = Biela2D('CF', nodos{3}, nodos{6}, Ao, Eo);
elementos{8} = Biela2D('DF', nodos{4}, nodos{6}, Ao, Eo);
elementos{9} = Biela2D('EF', nodos{5}, nodos{6}, Ao, Eo);

% Agregamos los elementos al modelo
modeloObj.agregarElementos(elementos);

% Creamos las restricciones
restricciones = cell(2, 1);
restricciones{1} = RestriccionNodo('R1', nodos{1}, [1, 2]');
restricciones{2} = RestriccionNodo('R2', nodos{5}, [2]'); %#ok<NBRAK>

% Agregamos las restricciones al modelo
modeloObj.agregarRestricciones(restricciones);

% Creamos la carga
cargas = cell(3, 1);
cargas{1} = CargaNodo('C1', nodos{2}, [0, -1]');
cargas{2} = CargaNodo('C2', nodos{4}, [0, -1]');
cargas{3} = CargaNodo('C3', nodos{6}, [0, -1]');

% Creamos el patron de cargas
PatronesDeCargas = cell(1, 1);
PatronesDeCargas{1} = PatronDeCargasConstante('CargaConstante', cargas);

% Agregamos las cargas al modelo
modeloObj.agregarPatronesDeCargas(PatronesDeCargas);

% Creamos el analisis
analisisObj = AnalisisEstatico(modeloObj);
analisisObj.analizar();
analisisObj.plot('deformada', true, 'factor', 100);
modeloObj.guardarResultados('test/estatico/out/Enrejado_Simple_2D.txt');