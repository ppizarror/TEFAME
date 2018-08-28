clear all; %#ok<CLALL>
fprintf('>\tTEST_TAREACOMPUTACIONAL5\n');

% Test Tarea computacional 5
%
%                    1 Tonf/m
%            |||||||||||||||||||||||||||           |
% 20 Tonf/m  vvvvvvvvvvvvvvvvvvvvvvvvvvv           v
%   -------> ---------------------------           _
%    ------> |           ________      | 150cm    | |
%     -----> |          |   _____|     | 150cm    | |
%       ---> |          | _|           | 100cm   >| |<- 20cm
%         -> |                         | 100cm    | |
% =====================================================
%                250    100  150   200
%                         cm

t = 20; % Espesor [cm]
E = 300000; % Modulo de Elasticidad [kgf/cm^2]
nu = 0.15; % Modulo de Poisson

% Creamos el modelo
modeloObj = Modelo(2, 25);

% Creamos los Nodos
nodos = cell(25, 1);
nodos{1} = Nodo('N1', 2, [0, 0]');
nodos{2} = Nodo('N2', 2, [0, 2]');
nodos{3} = Nodo('N3', 2, [2, 0]');
nodos{4} = Nodo('N4', 2, [2, 2]');
nodos{5} = Nodo('N5', 2, [4, 0]');
nodos{6} = Nodo('N6', 2, [4, 2]');
nodos{7} = Nodo('N7', 2, [4, 2]');
nodos{8} = Nodo('N8', 2, [4, 2]');
nodos{9} = Nodo('N9', 2, [4, 2]');
nodos{10} = Nodo('N10', 2, [4, 2]');
nodos{11} = Nodo('N11', 2, [4, 2]');
nodos{12} = Nodo('N12', 2, [4, 2]');
nodos{13} = Nodo('N13', 2, [4, 2]');
nodos{14} = Nodo('N14', 2, [4, 2]');
nodos{15} = Nodo('N15', 2, [4, 2]');
nodos{16} = Nodo('N16', 2, [4, 2]');
nodos{17} = Nodo('N17', 2, [4, 2]');
nodos{18} = Nodo('N18', 2, [4, 2]');
nodos{19} = Nodo('N19', 2, [4, 2]');
nodos{20} = Nodo('N20', 2, [4, 2]');
nodos{21} = Nodo('N21', 2, [4, 2]');
nodos{22} = Nodo('N22', 2, [4, 2]');
nodos{23} = Nodo('N23', 2, [4, 2]');
nodos{24} = Nodo('N24', 2, [4, 2]');
nodos{25} = Nodo('N25', 2, [4, 2]');

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