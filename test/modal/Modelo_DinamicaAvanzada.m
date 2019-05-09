fprintf('>\tMODELO_DINAMICA_AVANZADA\n');

%% Creamos el modelo
modeloObj = Modelo(2, 3);
modeloObj.definirNombre('Modelo Dinamica Avanzada');

%% Nodos modelo
nodos = {};
Modelo_DinamicaAvanzadaNodo;

% Agregamos los nodos al modelo
modeloObj.agregarNodos(nodos);

%% Creamos los elementos
elementos = {};
disipadores = {};
Modelo_DinamicaAvanzadaElementos;
Modelo_DinamicaAvanzadaDisipadores;

% Agregamos los elementos al modelo
modeloObj.agregarElementos(elementos);
modeloObj.agregarDisipadores(disipadores);

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
end % for i

%% Creamos las cargas dinamicas
cargasDinamicas = {};

% Carga los registros sismicos
if ~exist('regConstitucionL', 'var') % Carga el registro
    regConstitucionL = cargaRegistroSimple('test/modal/constitucion_ch1.sis', 0.005, 'factor', 0.01);
    regConstitucionV = cargaRegistroSimple('test/modal/constitucion_ch2.sis', 0.005, 'factor', 0.01);
    % plotRegistro(regConstitucionL, 'Registro Constitucion/Longitudinal', 'm/s^2');
end
cargasDinamicas{1} = CargaRegistroSismico('Registro Constitucion L+V', {regConstitucionL, regConstitucionV}, [1, 1], 0, 200);
% cargasDinamicas{2} = CargaPulso('Pulso', nodos{102}, [1, 0], 1000, 0.2, 0.005, 0, 20); % Horizontal
% cargasDinamicas{3} = CargaSinusoidal('Sinusoidal', nodos{102}, [1, 0], 300, 7, 30, 0.01, 0, 100); % Horizontal
% cargasDinamicas{1}.desactivarCarga();

%% Creamos el analisis
analisisObj = ModalEspectral(modeloObj);
analisisObj.activarPlotDeformadaInicial();
analisisObj.activarCargaAnimacion();

%% Creamos el patron de cargas
patronesDeCargas = cell(2, 1);
patronesDeCargas{1} = PatronDeCargasConstante('CargaConstante', cargasEstaticas);
patronesDeCargas{2} = PatronDeCargasDinamico('CargaDinamica', cargasDinamicas, analisisObj, 'desmodal', true);

% Agregamos las cargas al modelo
modeloObj.agregarPatronesDeCargas(patronesDeCargas);

%% Analiza el sistema
analisisObj.analizar(41, [0.02, 0.02], [0.02, 0.02, 0], 'condensar', true);
analisisObj.disp();
cargaEstatica = analisisObj.obtenerCargaEstatica();
% plt = analisisObj.plot('modo', 8, 'factor', 20, 'cuadros', 25, 'gif', 'test/modal/out/Modelo_DinamicaAvanzada_%d.gif', 'defElem', false);

%% Genera combinaciones de cargas
combinacionCargas = {};
combinacionCargas{1} = CombinacionCargas('E', {cargaEstatica});
combinacionCargas{2} = CombinacionCargas('E+SIS', {cargasDinamicas{1}, cargaEstatica});

%% Calcula y grafica las cargas dinamicas
analisisObj.resolverCargasDinamicas('cpenzien', false, 'disipadores', true, ...
    'cargaDisipador', cargasDinamicas{1}, 'betaObjetivo', 0.08, 'iterDisipador', 10);
% analisisObj.calcularCurvasEnergia(cargasDinamicas{1}, 'plotcarga', true, 'plot', 'all');
% analisisObj.calcularMomentoCorteBasal(cargasDinamicas{1});
% analisisObj.calcularDesplazamientoDrift(cargasDinamicas{1}, 32);
% analisisObj.plotEsfuerzosElemento(cargasDinamicas{1}, elementos{104}, [1, 0, 0]);
% plt = analisisObj.plot('carga', cargasDinamicas{1}, 'cuadros', 400, 'gif', 'test/modal/out/Modelo_DinamicaAvanzada_carga_constL.gif');
% analisisObj.plotTrayectoriaNodo(cargasDinamicas{1}, nodos{102}, [1, 0, 0]);

%% Finaliza el analisis
clear h h1 i v;