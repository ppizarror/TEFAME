fprintf('>\tMODELO_DINAMICA_AVANZADA\n');

%% Creamos el modelo
modeloObj = Modelo(2, 3);

%% Nodos modelo
nodos = {};
Modelo_DinamicaAvanzadaNodo;

% Agregamos los nodos al modelo
modeloObj.agregarNodos(nodos);

%% Creamos los elementos
% Propiedades de la viga
Av = 0.65 * 0.4; % [m2]
Ev = 2625051; % [Tonf/m2]
Iv = (0.4 * 0.65^3) / 12;

% Propiedades de la columna
Ac = 1; % [m2]
Ec = 2625051; % [Tonf/m2]
Ic = 1 / 12;

% Densidad del material
Rhoh = 2.5; % [Tonf/m3]

%% Crea los elementos
elementos = {};
Modelo_DinamicaAvanzadaElementos;

% Agregamos los elementos al modelo
modeloObj.agregarElementos(elementos);

%% Creamos las restricciones
restricciones = cell(10, 1);
restricciones{1} = RestriccionNodo('R1', nodos{1}, [1, 2, 3]');
restricciones{2} = RestriccionNodo('R2', nodos{2}, [1, 2, 3]');
restricciones{3} = RestriccionNodo('R3', nodos{3}, [1, 2, 3]');
restricciones{4} = RestriccionNodo('R4', nodos{4}, [1, 2, 3]');
restricciones{5} = RestriccionNodo('R5', nodos{5}, [1, 2, 3]');
restricciones{6} = RestriccionNodo('R6', nodos{6}, [1, 2, 3]');
restricciones{7} = RestriccionNodo('R7', nodos{7}, [1, 2, 3]');
restricciones{8} = RestriccionNodo('R8', nodos{8}, [1, 2, 3]');
restricciones{9} = RestriccionNodo('R9', nodos{9}, [1, 2, 3]');
restricciones{10} = RestriccionNodo('R10', nodos{10}, [1, 2, 3]');

% Agregamos las restricciones al modelo
modeloObj.agregarRestricciones(restricciones);

%% Creamos las cargas estaticas
cargasEstaticas = cell(103, 1);
for i = 1:103
    cargasEstaticas{i} = CargaVigaColumnaDistribuida('Carga distribuida piso', ...
        elementos{i}, -1, 0, -1, 1, 0);
end

%% Creamos las cargas dinamicas
cargasDinamicas = cell(1, 1);

% Registro sismico
if ~exist('sis_reg', 'var') % Carga el registro
    sis_reg = cargaRegistroArchivo('test/modal/registro.txt', '\n', ' ', 0, 0, 1, 0.005);
end
% cargasDinamicas{1} = CargaPulso('Pulso', 1000, 0.2, [1, 0], 100, 102, 5); % Horizontal
% cargasDinamicas{1} = CargaSinusoidal('Sinusoidal', 300, 7, [1, 0], 0.05, 102, 30); % Horizontal
% cargasDinamicas{1} = CargaRegistroSismico('Registro Constitucion', {sis_reg, sis_reg.*0}, ...
%     [1, 0], 0.005, 100); % Horizontal

%% Creamos el analisis
analisisObj = ModalEspectral(modeloObj);
analisisObj.activarPlotDeformadaInicial();
analisisObj.activarCargaAnimacion();

%% Creamos el patron de cargas
PatronesDeCargas = cell(2, 1);
PatronesDeCargas{1} = PatronDeCargasConstante('CargaConstante', cargasEstaticas);
PatronesDeCargas{2} = PatronDeCargasDinamico('CargaDinamica', cargasDinamicas, analisisObj);

% Agregamos las cargas al modelo
modeloObj.agregarPatronesDeCargas(PatronesDeCargas);

%% Resuelve el sistema
analisisObj.analizar(50, [0.02, 0.05], [0.05, 0.02, 0], 1);
% analisisObj.resolverCargasDinamicas();
% analisisObj.disp();
% pt = analisisObj.plot('modo', 8, 'factor', 10, 'numcuadros', 25, ...
%     'gif', 'test/modal/out/Modelo_DinamicaAvanzada_%d.gif', 'defelem', true);

%% OBTENCIÓN DE ENVOLVENTES
% Se genera vector en que las filas contienen nodos en un mismo piso,
% rellenando con ceros la matriz en caso de diferencia de nodos por piso.
% Tambien se genera vector que contiene alturas de piso.
nnodos = length(nodos);
haux = 0;
hrel = zeros (1,1);
habs = zeros (1,1);
hNodos = zeros (1,1);
j = 1;
k = 1;
for i = 1:nnodos
CoordNodo = nodos{i}.obtenerCoordenadas;
yNodo = CoordNodo(2);
if yNodo ~= habs(j)
    k = 1;
    j = j + 1;
    habs(j,1) = yNodo;
    hNodos(j,k) = i;
elseif i == 1
    hNodos(j,k) = i;
else
    k = k + 1;
    hNodos(j,k) = i;
end
end