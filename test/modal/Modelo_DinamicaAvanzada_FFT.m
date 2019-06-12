fprintf('>\tMODELO_DINAMICA_AVANZADA_FFT\n');

%% Creamos el modelo
modeloObj = Modelo(2, 3);
modeloObj.definirNombre('Modelo Dinamica Avanzada FFT');

% Configuraciones del modelamiento
modelarFundacion = false;

%% Nodos modelo
nodos = {};
Modelo_DinamicaAvanzadaNodo();

% Agregamos los nodos al modelo
modeloObj.agregarNodos(nodos);

%% Creamos los elementos
elementos = {};
disipadores = {};
Modelo_DinamicaAvanzadaElementos();
Modelo_DinamicaAvanzadaDisipadores();

% Agregamos los elementos al modelo
modeloObj.agregarElementos(elementos);

%% Creamos las restricciones
if modelarFundacion
    restricciones = cell(11, 1);
    restricciones{11} = RestriccionNodo('R11', nodos{145}, [1, 2, 3]');
    restHor = 0;
else
    restricciones = cell(10, 1); %#ok<*UNRCH>
    restHor = 1;
end
restricciones{1} = RestriccionNodo('R1', nodos{1}, [restHor, 2, 3]');
restricciones{2} = RestriccionNodo('R2', nodos{2}, [restHor, 2, 3]');
restricciones{3} = RestriccionNodo('R3', nodos{3}, [restHor, 2, 3]');
restricciones{4} = RestriccionNodo('R4', nodos{4}, [restHor, 2, 3]');
restricciones{5} = RestriccionNodo('R5', nodos{5}, [restHor, 2, 3]');
restricciones{6} = RestriccionNodo('R6', nodos{6}, [restHor, 2, 3]');
restricciones{7} = RestriccionNodo('R7', nodos{7}, [restHor, 2, 3]');
restricciones{8} = RestriccionNodo('R8', nodos{8}, [restHor, 2, 3]');
restricciones{9} = RestriccionNodo('R9', nodos{9}, [restHor, 2, 3]');
restricciones{10} = RestriccionNodo('R10', nodos{10}, [restHor, 2, 3]');

% Agregamos las restricciones al modelo
modeloObj.agregarRestricciones(restricciones);

%% Creamos las cargas estaticas
cargasEstaticas = cell(103, 1);
for i = 1:103
    cargasEstaticas{i} = CargaVigaColumnaDistribuida('Carga distribuida piso', ...
        elementos{i}, -4, 0, -4, 1, 0);
    cargasEstaticas{i}.definirFactorCargaMasa(1);
    cargasEstaticas{i}.definirFactorUnidadMasa(1/9.80665);
end % for i

%% Creamos las cargas dinamicas
cargasDinamicas = {};

pulsoNodo = [11, 21, 31, 41, 49, 57, 63, 69, 73, 77, 81, 85, 89, 93, 97, ...
    101, 105, 109, 113, 117, 121, 125, 129, 133, 137, 141, 143];
pulsoNodos = cell(length(pulsoNodo), 1);
for i = 1:length(pulsoNodo)
    pulsoNodos{i} = nodos{pulsoNodo(i)};
end % for i
cargasDinamicas{1} = CargaPulso('Pulso', pulsoNodos, [1, 0], 1, 0.1, 0.005, 0, 20);

%% Creamos el analisis
analisisObj = ModalEspectral(modeloObj);

%% Creamos el patron de cargas
patronesDeCargas = cell(2, 1);
patronesDeCargas{1} = PatronDeCargasConstante('CargaConstante', cargasEstaticas);
patronesDeCargas{2} = PatronDeCargasDinamico('CargaDinamica', cargasDinamicas, analisisObj, ...
    'desmodal', true, 'metodo', 'newmark');

% Agregamos las cargas al modelo
modeloObj.agregarPatronesDeCargas(patronesDeCargas);

%% Analiza el sistema y resuelve para cargas estaticas
analisisObj.analizar('nModos', 50, 'rayleighBeta', [0.02, 0.05], 'rayleighModo', [1, 8], ...
    'rayleighDir', ['h', 'h'], 'cpenzienBeta', [0.02, 0.02, 0], 'condensar', true);
analisisObj.disp();

%% Calcula y grafica las cargas dinamicas
analisisObj.resolverCargasDinamicas();

analisisObj.calcularFFTCarga(cargasDinamicas{1}, pulsoNodos, [1, 0, 0], [0, 1, 0], ...
    'fftlim', 10, 'tukeywinr', 0.01, 'zerofill', 10, 'fftpeaks', true, ...
    'maxpeaks', 5, 'peakMinDistance', 0.7, 'formaModal', [1, 2, 3]);
% analisisObj.plotTrayectoriaNodos(cargasDinamicas{1}, pulsoNodos, [1, 0, 0]);

%% Finaliza el analisis
clear h h1 i v pulsoNodo;