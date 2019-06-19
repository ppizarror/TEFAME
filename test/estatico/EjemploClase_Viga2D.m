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

fprintf('>\tEJEMPLOCLASE_VIGA2D\n');

% Creamos el modelo
modeloObj = Modelo(2, 4);
modeloObj.definirNombre('Viga 2D');

% Creamos los nodos
nodos = cell(4, 1);
nodos{1} = Nodo('N1', 3, [0, 0]');
nodos{2} = Nodo('N2', 3, [400, 0]');
nodos{3} = Nodo('N3', 3, [800, 0]');
nodos{4} = Nodo('N4', 3, [1000, 0]');

% Agregamos los nodos al modelo
modeloObj.agregarNodos(nodos);

% Creamos los elementos
Eo = 2000;
Io = 20000;
elementos = cell(3, 1);
elementos{1} = Viga2D('V1', nodos{1}, nodos{2}, Io, Eo);
elementos{2} = Viga2D('V2', nodos{2}, nodos{3}, Io, Eo);
elementos{3} = Viga2D('V3', nodos{3}, nodos{4}, Io, Eo);

% Agregamos los elementos al modelo
modeloObj.agregarElementos(elementos);

% Creamos las restricciones
restricciones = cell(4, 1);
restricciones{1} = RestriccionNodo('R1', nodos{1}, [1, 2, 3]');
restricciones{2} = RestriccionNodo('R2', nodos{2}, [1, 2]');
restricciones{3} = RestriccionNodo('R3', nodos{3}, [1, 2]');
restricciones{4} = RestriccionNodo('R4', nodos{4}, [1]'); %#ok<NBRAK>

% Agregamos las restricciones al modelo
modeloObj.agregarRestricciones(restricciones);

% Creamos la carga
cargas = cell(2, 1);
cargas{1} = CargaNodo('Momento nodo 2', nodos{2}, [0, 0, -5000]');
cargas{2} = CargaNodo('Carga vertical', nodos{4}, [0, -25, 0]');

% Creamos el patron de cargas
PatronesDeCargas = cell(1, 1);
PatronesDeCargas{1} = PatronDeCargasConstante('CargaConstante', cargas);

% Agregamos las cargas al modelo
modeloObj.agregarPatronesDeCargas(PatronesDeCargas);

% Creamos el analisis
analisisObj = AnalisisEstatico(modeloObj);
analisisObj.analizar();
analisisObj.plot('deformada', true);
modeloObj.guardarResultados('test/estatico/out/EjemploClase_Viga2D.txt');