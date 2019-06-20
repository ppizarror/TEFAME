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
cargasDinamicas{1} = CargaPulso('Pulso', pulsoNodos, [1, 0], 1, 0.1, 0.005, 0, 100);

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

analisisObj.calcularFFTCarga(cargasDinamicas{1}, pulsoNodos, [1, 0, 0], ...
    'fftLim', 10, 'tukeywinr', 0.01, 'zeroFill', 10, 'fftPlot', false, ...
    'fftPeaks', true, 'maxPeaks', 5, 'peakMinDistance', 0.7, 'betaPlot', false, ...
    'tmin', 0.15, 'tmax', 55, 'formaModal', [1, 2, 3], 'formaModalDir', [0, 1, 0], ...
    'filtMod', [1, 2, 3, 4, 5], 'filtNodo', nodos{11}, 'filtTlim', [0, 6], ...
    'fase', true, 'faseNodo', [13, 27], 'faseTLim', [0, 10]);
% analisisObj.plotTrayectoriaNodos(cargasDinamicas{1}, pulsoNodos, [1, 0, 0]);

%% Finaliza el analisis
clear h h1 i v pulsoNodo;