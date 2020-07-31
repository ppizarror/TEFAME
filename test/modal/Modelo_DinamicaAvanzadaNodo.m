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

% Nodos Modelo

v = 8; % Vanos
h1 = 3; % Altura primer piso
h = 2.5; % Altura resto de los pisos

% Piso 0
nodos{1} = Nodo('N01', 3, [0, 0]');
nodos{2} = Nodo('N02', 3, [v, 0]');
nodos{3} = Nodo('N03', 3, [2*v, 0]');
nodos{4} = Nodo('N04', 3, [3*v, 0]');
nodos{5} = Nodo('N05', 3, [4*v, 0]');
nodos{6} = Nodo('N06', 3, [5*v, 0]');
nodos{7} = Nodo('N07', 3, [6*v, 0]');
nodos{8} = Nodo('N08', 3, [7*v, 0]');
nodos{9} = Nodo('N09', 3, [8*v, 0]');
nodos{10} = Nodo('N010', 3, [9*v, 0]');

% Piso 1
nodos{11} = Nodo('N11', 3, [0, h1]');
nodos{12} = Nodo('N12', 3, [v, h1]');
nodos{13} = Nodo('N13', 3, [2*v, h1]');
nodos{14} = Nodo('N14', 3, [3*v, h1]');
nodos{15} = Nodo('N15', 3, [4*v, h1]');
nodos{16} = Nodo('N16', 3, [5*v, h1]');
nodos{17} = Nodo('N17', 3, [6*v, h1]');
nodos{18} = Nodo('N18', 3, [7*v, h1]');
nodos{19} = Nodo('N19', 3, [8*v, h1]');
nodos{20} = Nodo('N110', 3, [9*v, h1]');

% Piso 2
nodos{21} = Nodo('N21', 3, [0, (h1+h)]');
nodos{22} = Nodo('N22', 3, [v, (h1+h)]');
nodos{23} = Nodo('N23', 3, [2*v, (h1+h)]');
nodos{24} = Nodo('N24', 3, [3*v, (h1+h)]');
nodos{25} = Nodo('N25', 3, [4*v, (h1+h)]');
nodos{26} = Nodo('N26', 3, [5*v, (h1+h)]');
nodos{27} = Nodo('N27', 3, [6*v, (h1+h)]');
nodos{28} = Nodo('N28', 3, [7*v, (h1+h)]');
nodos{29} = Nodo('N29', 3, [8*v, (h1+h)]');
nodos{30} = Nodo('N210', 3, [9*v, (h1+h)]');

% Piso 3
nodos{31} = Nodo('N31', 3, [0, (h1+2*h)]');
nodos{32} = Nodo('N32', 3, [v, (h1+2*h)]');
nodos{33} = Nodo('N33', 3, [2*v, (h1+2*h)]');
nodos{34} = Nodo('N34', 3, [3*v, (h1+2*h)]');
nodos{35} = Nodo('N35', 3, [4*v, (h1+2*h)]');
nodos{36} = Nodo('N36', 3, [5*v, (h1+2*h)]');
nodos{37} = Nodo('N37', 3, [6*v, (h1+2*h)]');
nodos{38} = Nodo('N38', 3, [7*v, (h1+2*h)]');
nodos{39} = Nodo('N39', 3, [8*v, (h1+2*h)]');
nodos{40} = Nodo('N310', 3, [9*v, (h1+2*h)]');

% Piso 4
nodos{41} = Nodo('N41', 3, [v, (h1+3*h)]');
nodos{42} = Nodo('N42', 3, [2*v, (h1+3*h)]');
nodos{43} = Nodo('N43', 3, [3*v, (h1+3*h)]');
nodos{44} = Nodo('N44', 3, [4*v, (h1+3*h)]');
nodos{45} = Nodo('N45', 3, [5*v, (h1+3*h)]');
nodos{46} = Nodo('N46', 3, [6*v, (h1+3*h)]');
nodos{47} = Nodo('N47', 3, [7*v, (h1+3*h)]');
nodos{48} = Nodo('N48', 3, [8*v, (h1+3*h)]');

% Piso 5
nodos{49} = Nodo('N51', 3, [v, (h1+4*h)]');
nodos{50} = Nodo('N52', 3, [2*v, (h1+4*h)]');
nodos{51} = Nodo('N53', 3, [3*v, (h1+4*h)]');
nodos{52} = Nodo('N54', 3, [4*v, (h1+4*h)]');
nodos{53} = Nodo('N55', 3, [5*v, (h1+4*h)]');
nodos{54} = Nodo('N56', 3, [6*v, (h1+4*h)]');
nodos{55} = Nodo('N57', 3, [7*v, (h1+4*h)]');
nodos{56} = Nodo('N58', 3, [8*v, (h1+4*h)]');

% Piso 6
nodos{57} = Nodo('N61', 3, [2*v, (h1+5*h)]');
nodos{58} = Nodo('N62', 3, [3*v, (h1+5*h)]');
nodos{59} = Nodo('N63', 3, [4*v, (h1+5*h)]');
nodos{60} = Nodo('N64', 3, [5*v, (h1+5*h)]');
nodos{61} = Nodo('N65', 3, [6*v, (h1+5*h)]');
nodos{62} = Nodo('N66', 3, [7*v, (h1+5*h)]');

% Piso 7
nodos{63} = Nodo('N71', 3, [2*v, (h1+6*h)]');
nodos{64} = Nodo('N72', 3, [3*v, (h1+6*h)]');
nodos{65} = Nodo('N73', 3, [4*v, (h1+6*h)]');
nodos{66} = Nodo('N74', 3, [5*v, (h1+6*h)]');
nodos{67} = Nodo('N75', 3, [6*v, (h1+6*h)]');
nodos{68} = Nodo('N76', 3, [7*v, (h1+6*h)]');

% Piso 8
nodos{69} = Nodo('N81', 3, [3*v, (h1+7*h)]');
nodos{70} = Nodo('N82', 3, [4*v, (h1+7*h)]');
nodos{71} = Nodo('N83', 3, [5*v, (h1+7*h)]');
nodos{72} = Nodo('N84', 3, [6*v, (h1+7*h)]');

% Piso 9
nodos{73} = Nodo('N91', 3, [3*v, (h1+8*h)]');
nodos{74} = Nodo('N92', 3, [4*v, (h1+8*h)]');
nodos{75} = Nodo('N93', 3, [5*v, (h1+8*h)]');
nodos{76} = Nodo('N94', 3, [6*v, (h1+8*h)]');

% Piso 10
nodos{77} = Nodo('N101', 3, [3*v, (h1+9*h)]');
nodos{78} = Nodo('N102', 3, [4*v, (h1+9*h)]');
nodos{79} = Nodo('N103', 3, [5*v, (h1+9*h)]');
nodos{80} = Nodo('N104', 3, [6*v, (h1+9*h)]');

% Piso 11
nodos{81} = Nodo('N111', 3, [3*v, (h1+10*h)]');
nodos{82} = Nodo('N112', 3, [4*v, (h1+10*h)]');
nodos{83} = Nodo('N113', 3, [5*v, (h1+10*h)]');
nodos{84} = Nodo('N114', 3, [6*v, (h1+10*h)]');

% Piso 12
nodos{85} = Nodo('N121', 3, [3*v, (h1+11*h)]');
nodos{86} = Nodo('N122', 3, [4*v, (h1+11*h)]');
nodos{87} = Nodo('N123', 3, [5*v, (h1+11*h)]');
nodos{88} = Nodo('N124', 3, [6*v, (h1+11*h)]');

% Piso 13
nodos{89} = Nodo('N131', 3, [3*v, (h1+12*h)]');
nodos{90} = Nodo('N132', 3, [4*v, (h1+12*h)]');
nodos{91} = Nodo('N133', 3, [5*v, (h1+12*h)]');
nodos{92} = Nodo('N134', 3, [6*v, (h1+12*h)]');

% Piso 14
nodos{93} = Nodo('N141', 3, [3*v, (h1+13*h)]');
nodos{94} = Nodo('N142', 3, [4*v, (h1+13*h)]');
nodos{95} = Nodo('N143', 3, [5*v, (h1+13*h)]');
nodos{96} = Nodo('N144', 3, [6*v, (h1+13*h)]');

% Piso 15
nodos{97} = Nodo('N151', 3, [3*v, (h1+14*h)]');
nodos{98} = Nodo('N152', 3, [4*v, (h1+14*h)]');
nodos{99} = Nodo('N153', 3, [5*v, (h1+14*h)]');
nodos{100} = Nodo('N154', 3, [6*v, (h1+14*h)]');

% Piso 16
nodos{101} = Nodo('N161', 3, [3*v, (h1+15*h)]');
nodos{102} = Nodo('N162', 3, [4*v, (h1+15*h)]');
nodos{103} = Nodo('N163', 3, [5*v, (h1+15*h)]');
nodos{104} = Nodo('N164', 3, [6*v, (h1+15*h)]');

% Piso 17
nodos{105} = Nodo('N171', 3, [3*v, (h1+16*h)]');
nodos{106} = Nodo('N172', 3, [4*v, (h1+16*h)]');
nodos{107} = Nodo('N173', 3, [5*v, (h1+16*h)]');
nodos{108} = Nodo('N174', 3, [6*v, (h1+16*h)]');

% Piso 18
nodos{109} = Nodo('N181', 3, [3*v, (h1+17*h)]');
nodos{110} = Nodo('N182', 3, [4*v, (h1+17*h)]');
nodos{111} = Nodo('N183', 3, [5*v, (h1+17*h)]');
nodos{112} = Nodo('N184', 3, [6*v, (h1+17*h)]');

% Piso 19
nodos{113} = Nodo('N191', 3, [3*v, (h1+18*h)]');
nodos{114} = Nodo('N192', 3, [4*v, (h1+18*h)]');
nodos{115} = Nodo('N193', 3, [5*v, (h1+18*h)]');
nodos{116} = Nodo('N194', 3, [6*v, (h1+18*h)]');

% Piso 20
nodos{117} = Nodo('N201', 3, [3*v, (h1+19*h)]');
nodos{118} = Nodo('N202', 3, [4*v, (h1+19*h)]');
nodos{119} = Nodo('N203', 3, [5*v, (h1+19*h)]');
nodos{120} = Nodo('N204', 3, [6*v, (h1+19*h)]');

% Piso 21
nodos{121} = Nodo('N211', 3, [3*v, (h1+20*h)]');
nodos{122} = Nodo('N212', 3, [4*v, (h1+20*h)]');
nodos{123} = Nodo('N213', 3, [5*v, (h1+20*h)]');
nodos{124} = Nodo('N214', 3, [6*v, (h1+20*h)]');

% Piso 22
nodos{125} = Nodo('N221', 3, [3*v, (h1+21*h)]');
nodos{126} = Nodo('N222', 3, [4*v, (h1+21*h)]');
nodos{127} = Nodo('N223', 3, [5*v, (h1+21*h)]');
nodos{128} = Nodo('N224', 3, [6*v, (h1+21*h)]');

% Piso 23
nodos{129} = Nodo('N231', 3, [3*v, (h1+22*h)]');
nodos{130} = Nodo('N232', 3, [4*v, (h1+22*h)]');
nodos{131} = Nodo('N233', 3, [5*v, (h1+22*h)]');
nodos{132} = Nodo('N234', 3, [6*v, (h1+22*h)]');

% Piso 24
nodos{133} = Nodo('N241', 3, [3*v, (h1+23*h)]');
nodos{134} = Nodo('N242', 3, [4*v, (h1+23*h)]');
nodos{135} = Nodo('N243', 3, [5*v, (h1+23*h)]');
nodos{136} = Nodo('N244', 3, [6*v, (h1+23*h)]');

% Piso 25
nodos{137} = Nodo('N251', 3, [3*v, (h1+24*h)]');
nodos{138} = Nodo('N252', 3, [4*v, (h1+24*h)]');
nodos{139} = Nodo('N253', 3, [5*v, (h1+24*h)]');
nodos{140} = Nodo('N254', 3, [6*v, (h1+24*h)]');

% Piso 26
nodos{141} = Nodo('N261', 3, [4*v, (h1+25*h)]');
nodos{142} = Nodo('N262', 3, [5*v, (h1+25*h)]');

% Piso 27
nodos{143} = Nodo('N271', 3, [4*v, (h1+26*h)]');
nodos{144} = Nodo('N272', 3, [5*v, (h1+26*h)]');

% Agrega nodo de fundacion
if modelarFundacion
    nodos{145} = Nodo('Aux', 3, [9 * v + 8, 0]); % 2 metros alejado del ultimo nodo 
end