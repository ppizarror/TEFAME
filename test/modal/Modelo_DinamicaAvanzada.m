clear all; %#ok<CLALL>
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

%% Creamos la carga
cargas = cell(1, 103);
for i = 1:103
    cargas{i} = CargaVigaColumnaDistribuida('Carga distribuida piso', ...
        elementos{i}, -1, 0, -1, 1, 0);
end

%% Creamos el analisis
analisisObj = ModalEspectral(modeloObj);
analisisObj.activarPlotDeformadaInicial();
analisisObj.activarCargaAnimacion();

%% Creamos el patron de cargas
PatronesDeCargas = cell(1, 1);
PatronesDeCargas{1} = PatronDeCargasConstante('CargaConstante', cargas);

% Agregamos las cargas al modelo
modeloObj.agregarPatronesDeCargas(PatronesDeCargas);

%% Resuelve el sistema
analisisObj.analizar(50, [0.02, 0.05], [0.05, 0.02, 0]);
analisisObj.disp();
pt = analisisObj.plot('modo', 8, 'factor', 10, 'numcuadros', 25, ...
    'gif', 'test/modal/out/Modelo_DinamicaAvanzada_%d.gif', 'defelem', true);