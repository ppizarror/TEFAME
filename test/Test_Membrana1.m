clear all; %#ok<CLALL>
fprintf('>\tTEST_MEMBRANA1\n');

% Test Membrana Sencillo
% Corresponde al ejemplo 4.4 del libro
%   INTRODUCCION AL ANALISIS ESTRUCTURAL POR ELEMENTOS FINITOS
%   Autor: JORGE EDUARDO HURTADO GÓMEZ
%   http://bdigital.unal.edu.co/10002/6/958932276X.2002.pdf
%   Pagina 92
%
%           1000 kN
%             |
%             v
%    2 ------ 4 ------ 6
%    |        |        |
%    |   (1)  |   (2)  |  2m
%    |        |        |
%    1 ------ 3 ------ 5
%    ^   2m       2m   ^
% ==========================

% Espesor, en metros. En el enunciado sale 0.25m sin embargo los resultados
% que muestran son con t=1m. Se prefirio usar este valor para poder
% comparar mejor los resultados obtenidos.
t = 1.0;
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
cargas = cell(1, 1);
cargas{1} = CargaNodo('P', nodos{4}, [0, -1000]');

% Creamos el Patron de Cargas
PatronesDeCargas = cell(1, 1);
PatronesDeCargas{1} = PatronDeCargasConstante('CargaConstante', cargas);

% Agregamos las cargas al modelo
modeloObj.agregarPatronesDeCargas(PatronesDeCargas);

% Creamos el analisis
analisisObj = AnalisisEstatico(modeloObj);
analisisObj.analizar();
modeloObj.guardarResultados('output/Ejemplo_Membrana1.txt');

% Resultados esperados:
% u = [0.2691, -0.2130, 0, -0.7345, 0, -0.9476, -0.2691, -0.2130]