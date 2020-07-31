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

fprintf('>\tTEST_MEMBRANA_CARGADISTRIBUIDA_VER\n');

% Test Membrana2D Sencillo
% Corresponde al ejemplo 4.4 del libro modificado con carga distribuida
% rectangular
%   INTRODUCCION AL ANALISIS ESTRUCTURAL POR ELEMENTOS FINITOS
%   Autor: JORGE EDUARDO HURTADO GOMEZ
%   http://bdigital.unal.edu.co/10002/6/958932276X.2002.pdf
%   Pagina 92
%
%           100 kN/m
%    |||||||||||||||||||         
%    vvvvvvvvvvvvvvvvvvv
%    2 ------ 4 ------ 6
%    |        |        |
%    |   (1)  |   (2)  |  2m
%    |        |        |
%    1 ------ 3 ------ 5
%    ^   2m       2m   ^
% ==========================

t = 0.25; % Espesor, en metros
E = 2 * 10^3; % kN/m^2
nu = 0.2; % Modulo de Poisson

% Creamos el modelo
modeloObj = Modelo(2, 6);
modeloObj.definirNombre('Membrana2D carga distribuida vertical');

% Creamos los nodos
nodos = cell(6, 1);
nodos{1} = Nodo('N1', 2, [0, 0]');
nodos{2} = Nodo('N2', 2, [0, 2]');
nodos{3} = Nodo('N3', 2, [2, 0]');
nodos{4} = Nodo('N4', 2, [2, 2]');
nodos{5} = Nodo('N5', 2, [4, 0]');
nodos{6} = Nodo('N6', 2, [4, 2]');

% Agregamos los nodos al modelo
modeloObj.agregarNodos(nodos);

% Creamos los elementos
elementos = cell(2, 1);
elementos{1} = Membrana2D('MEM1', nodos{1}, nodos{3}, nodos{4}, nodos{2}, E, nu, t); % OBS: Respetar orden CCW en nodo 1
elementos{2} = Membrana2D('MEM2', nodos{3}, nodos{5}, nodos{6}, nodos{4}, E, nu, t);

% Agregamos los elementos al modelo
modeloObj.agregarElementos(elementos);

% Creamos las restricciones
restricciones = cell(2, 1);
restricciones{1} = RestriccionNodo('R1', nodos{1}, [1, 2]'); % Apoyo simple en ambos
restricciones{2} = RestriccionNodo('R2', nodos{5}, [1, 2]');

% Agregamos las restricciones al modelo
modeloObj.agregarRestricciones(restricciones);

% Creamos la carga
cargas = cell(2, 1);
cargas{1} = CargaMembrana2DDistribuida('DV100KN V', elementos{1}, 4, 3, -100, 0, -100, 1);
cargas{2} = CargaMembrana2DDistribuida('DV100KN V', elementos{2}, 4, 3, -100, 0, -100, 1);

% Creamos el patron de cargas
PatronesDeCargas = cell(1, 1);
PatronesDeCargas{1} = PatronDeCargasConstante('CargaConstante', cargas);

% Agregamos las cargas al modelo
modeloObj.agregarPatronesDeCargas(PatronesDeCargas);

% Creamos el analisis
analisisObj = AnalisisEstatico(modeloObj);
analisisObj.analizar();
analisisObj.plot('deformada', true);
modeloObj.guardarResultados('test/estatico/out/Ejemplo_MembranaCargaDistribuidaHor.txt');