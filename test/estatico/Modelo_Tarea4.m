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

fprintf('>\tMODELO_TAREA4\n');

% Creamos el modelo
modeloObj = Modelo(2, 6);
modeloObj.definirNombre('Tarea 4');

% Creamos los nodos
nodos = cell(3, 1);
nodos{1} = Nodo('N1', 3, [0, 8]');
nodos{2} = Nodo('N2', 3, [6, 0]');
nodos{3} = Nodo('N3', 3, [18, 0]');

% Agregamos los nodos al modelo
modeloObj.agregarNodos(nodos);

% Creamos los elementos
Ao = 0.013;
Eo = 200000000;
Io = 0.000762;
elementos = cell(2, 1);
elementos{1} = VigaColumna2D('Viga-Columna 1', nodos{1}, nodos{2}, Io, Eo, Ao);
elementos{2} = VigaColumna2D('Viga-Columna 2', nodos{2}, nodos{3}, Io, Eo, Ao);

% Agregamos los elementos al modelo
modeloObj.agregarElementos(elementos);

% Creamos las restricciones
restricciones = cell(3, 1);
restricciones{1} = RestriccionNodo('R1', nodos{1}, [1, 2, 3]');
restricciones{2} = RestriccionNodo('R2', nodos{2}, [1, 2]');
restricciones{3} = RestriccionNodo('R3', nodos{3}, [1, 2]');

% Agregamos las restricciones al modelo
modeloObj.agregarRestricciones(restricciones);

% Creamos la carga
cargas = cell(3, 1);
cargas{1} = CargaNodo('Momento nodo 2', nodos{2}, [0, 0, -150]');
cargas{2} = CargaVigaColumnaPuntual('Carga elem 1 @125[kN]', elementos{1}, -125, 0.5, 0);
cargas{3} = CargaVigaColumnaDistribuida('Carga dist elem 2 @24[kN/m]', elementos{2}, -24, 0, -24, 1, 0);

% Creamos el patron de cargas
PatronesDeCargas = cell(1, 1);
PatronesDeCargas{1} = PatronDeCargasConstante('CargaConstante', cargas);

% Agregamos las cargas al modelo
modeloObj.agregarPatronesDeCargas(PatronesDeCargas);

% Creamos el analisis
analisisObj = AnalisisEstatico(modeloObj);
analisisObj.analizar();
analisisObj.plot('deformada', true, 'factor', 100);
modeloObj.guardarResultados('test/estatico/out/Modelo_Tarea4.txt');