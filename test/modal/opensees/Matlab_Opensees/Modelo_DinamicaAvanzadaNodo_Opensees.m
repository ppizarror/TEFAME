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

% Nodos Modelo

v = 8; % Vanos
h1 = 5.5; % Altura primer piso
h = 4; % Altura resto de los pisos

% Piso 0
nodos{1} = Nodo('N01', 3, [0, 0]');
nodos{2} = Nodo('N02', 3, [v, 0]');
nodos{3} = Nodo('N03', 3, [2 * v, 0]');
nodos{4} = Nodo('N04', 3, [3 * v, 0]');
nodos{5} = Nodo('N05', 3, [4 * v, 0]');
nodos{6} = Nodo('N06', 3, [5 * v, 0]');
nodos{7} = Nodo('N07', 3, [6 * v, 0]');
nodos{8} = Nodo('N08', 3, [7 * v, 0]');
nodos{9} = Nodo('N09', 3, [8 * v, 0]');
nodos{10} = Nodo('N010', 3, [9 * v, 0]');

% Piso 1
nodos{11} = Nodo('N11', 3, [0, h1]');
nodos{12} = Nodo('N12', 3, [v, h1]');
nodos{13} = Nodo('N13', 3, [2 * v, h1]');
nodos{14} = Nodo('N14', 3, [3 * v, h1]');
nodos{15} = Nodo('N15', 3, [4 * v, h1]');
nodos{16} = Nodo('N16', 3, [5 * v, h1]');
nodos{17} = Nodo('N17', 3, [6 * v, h1]');
nodos{18} = Nodo('N18', 3, [7 * v, h1]');
nodos{19} = Nodo('N19', 3, [8 * v, h1]');
nodos{20} = Nodo('N110', 3, [9 * v, h1]');

% Piso 2
nodos{21} = Nodo('N21', 3, [0, (h1 + h)]');
nodos{22} = Nodo('N22', 3, [v, (h1 + h)]');
nodos{23} = Nodo('N23', 3, [2 * v, (h1 + h)]');
nodos{24} = Nodo('N24', 3, [3 * v, (h1 + h)]');
nodos{25} = Nodo('N25', 3, [4 * v, (h1 + h)]');
nodos{26} = Nodo('N26', 3, [5 * v, (h1 + h)]');
nodos{27} = Nodo('N27', 3, [6 * v, (h1 + h)]');
nodos{28} = Nodo('N28', 3, [7 * v, (h1 + h)]');
nodos{29} = Nodo('N29', 3, [8 * v, (h1 + h)]');
nodos{30} = Nodo('N210', 3, [9 * v, (h1 + h)]');

% Piso 3
nodos{31} = Nodo('N31', 3, [0, (h1 + 2 * h)]');
nodos{32} = Nodo('N32', 3, [v, (h1 + 2 * h)]');
nodos{33} = Nodo('N33', 3, [2 * v, (h1 + 2 * h)]');
nodos{34} = Nodo('N34', 3, [3 * v, (h1 + 2 * h)]');
nodos{35} = Nodo('N35', 3, [4 * v, (h1 + 2 * h)]');
nodos{36} = Nodo('N36', 3, [5 * v, (h1 + 2 * h)]');
nodos{37} = Nodo('N37', 3, [6 * v, (h1 + 2 * h)]');
nodos{38} = Nodo('N38', 3, [7 * v, (h1 + 2 * h)]');
nodos{39} = Nodo('N39', 3, [8 * v, (h1 + 2 * h)]');
nodos{40} = Nodo('N310', 3, [9 * v, (h1 + 2 * h)]');

% Piso 4
nodos{41} = Nodo('N41', 3, [0, (h1 + 3 * h)]');
nodos{42} = Nodo('N42', 3, [v, (h1 + 3 * h)]');
nodos{43} = Nodo('N43', 3, [2 * v, (h1 + 3 * h)]');
nodos{44} = Nodo('N44', 3, [3 * v, (h1 + 3 * h)]');
nodos{45} = Nodo('N45', 3, [4 * v, (h1 + 3 * h)]');
nodos{46} = Nodo('N46', 3, [5 * v, (h1 + 3 * h)]');
nodos{47} = Nodo('N47', 3, [6 * v, (h1 + 3 * h)]');
nodos{48} = Nodo('N48', 3, [7 * v, (h1 + 3 * h)]');
nodos{49} = Nodo('N49', 3, [8 * v, (h1 + 3 * h)]');
nodos{50} = Nodo('N410', 3, [9 * v, (h1 + 3 * h)]');

% Piso 5
nodos{51} = Nodo('N51', 3, [0, (h1 + 4 * h)]');
nodos{52} = Nodo('N52', 3, [v, (h1 + 4 * h)]');
nodos{53} = Nodo('N53', 3, [2 * v, (h1 + 4 * h)]');
nodos{54} = Nodo('N54', 3, [3 * v, (h1 + 4 * h)]');
nodos{55} = Nodo('N55', 3, [4 * v, (h1 + 4 * h)]');
nodos{56} = Nodo('N56', 3, [5 * v, (h1 + 4 * h)]');
nodos{57} = Nodo('N57', 3, [6 * v, (h1 + 4 * h)]');
nodos{58} = Nodo('N58', 3, [7 * v, (h1 + 4 * h)]');
nodos{59} = Nodo('N59', 3, [8 * v, (h1 + 4 * h)]');
nodos{60} = Nodo('N510', 3, [9 * v, (h1 + 4 * h)]');