clear all; %#ok<CLALL>
fprintf('>\tTEST_MEMBRANA_CARGADISTRIBUIDA_VER\n');

% Test Membrana Sencillo
% Corresponde al ejemplo 4.4 del libro modificado con carga distribuida
% rectangular
%   INTRODUCCION AL ANALISIS ESTRUCTURAL POR ELEMENTOS FINITOS
%   Autor: JORGE EDUARDO HURTADO GÓMEZ
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

% Creamos los Nodos
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
elementos{1} = Membrana('MEM1', nodos{1}, nodos{3}, nodos{4}, nodos{2}, E, nu, t); % OBS: Respetar orden CCW en nodo 1
elementos{2} = Membrana('MEM2', nodos{3}, nodos{5}, nodos{6}, nodos{4}, E, nu, t);

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
cargas{1} = CargaMembranaDistribuida('DV100KN V', elementos{1}, 4, 3, -100, 0, -100, 1);
cargas{2} = CargaMembranaDistribuida('DV100KN V', elementos{2}, 4, 3, -100, 0, -100, 1);

% Creamos el Patron de Cargas
PatronesDeCargas = cell(1, 1);
PatronesDeCargas{1} = PatronDeCargasConstante('CargaConstante', cargas);

% Agregamos las cargas al modelo
modeloObj.agregarPatronesDeCargas(PatronesDeCargas);

% Creamos el analisis
analisisObj = AnalisisEstatico(modeloObj);
analisisObj.analizar();
modeloObj.guardarResultados('test/out/Ejemplo_MembranaCargaDistribuidaHor.txt');