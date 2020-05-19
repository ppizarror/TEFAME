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

fprintf('>\tMODELO_DINAMICA_AVANZADA\n');

%% Creamos el modelo
modeloObj = Modelo(2, 3);
modeloObj.definirNombre('Modelo Dinamica Avanzada');

% Configuraciones del modelamiento
modelarFundacion = false;
resolverCargasDinamicas = true;
usarDisipadores = false;

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

if usarDisipadores
    rayBeta = [0.02, 0.02];
    modeloObj.agregarDisipadores(disipadores);
else
    rayBeta = [0.02, 0.05];
end

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

% Carga los registros sismicos
if ~exist('regConstitucionL', 'var') % Carga el registro
    regConstitucionL = cargaRegistroSimple('test/modal/constitucion_ch1.sis', 0.005, 'factor', 0.01);
    regConstitucionV = cargaRegistroSimple('test/modal/constitucion_ch2.sis', 0.005, 'factor', 0.01);
    % plotRegistro(regConstitucionL, 'Registro Constitucion/Longitudinal', 'm/s^2');
end
cargasDinamicas{1} = CargaRegistroSismico('Registro Constitucion L+V', {regConstitucionL, regConstitucionV}, [1, 1], 0, 200);
cargasDinamicas{2} = CargaPulso('Pulso', nodos{102}, [1, 0], 1000, 0.2, 0.005, 0, 20); % Horizontal
cargasDinamicas{3} = CargaSinusoidal('Sinusoidal', nodos{102}, [1, 0], 300, 7, 30, 0.01, 0, 100); % Horizontal
cargasDinamicas{4} = CargaGenerica('Generica Random', {nodos{101}, nodos{105}}, [1, 1], rand(1, 1e4), 0.005); %#ok<*CCAT1>

cargasDinamicas{2}.desactivarCarga();
cargasDinamicas{3}.desactivarCarga();
cargasDinamicas{4}.desactivarCarga();

%% Creamos el analisis
analisisObj = ModalEspectral(modeloObj);
analisisObj.activarPlotDeformadaInicial();
analisisObj.activarCargaAnimacion();

%% Creamos el patron de cargas
patronesDeCargas = cell(2, 1);
patronesDeCargas{1} = PatronDeCargasConstante('CargaConstante', cargasEstaticas);
patronesDeCargas{2} = PatronDeCargasDinamico('CargaDinamica', cargasDinamicas, analisisObj, ...
    'desmodal', true, 'metodo', 'newmark');

% Agregamos las cargas al modelo
modeloObj.agregarPatronesDeCargas(patronesDeCargas);

%% Analiza el sistema y resuelve para cargas estaticas
analisisObj.analizar('nModos', 50, 'rayleighBeta', rayBeta, 'rayleighModo', [1, 8], ...
    'rayleighDir', ['h', 'h'], 'cpenzienBeta', [0.02, 0.02, 0], 'condensar', true, ...
    'valvecAlgoritmo', 'eigs', 'valvecTolerancia', 0.0001, ...
    'muIterDespl', wIterDespl, 'nRitz', 192);
analisisObj.disp();
w = analisisObj.obtenerValoresPropios();
cargaEstatica = analisisObj.obtenerCargaEstatica();
% plt = analisisObj.plot('modo', 1, 'factor', 20, 'cuadros', 25, 'defElem', true, 'gif', ...
%    'test/modal/out/Modelo_DinamicaAvanzada_%d.gif', 'mostrarEstatico', false);

%% Genera combinaciones de cargas
combinacionCargas = {};
combinacionCargas{1} = CombinacionCargas('E', {cargaEstatica});
combinacionCargas{2} = CombinacionCargas('E+SIS', {cargasDinamicas{1}, cargaEstatica});

%% Calcula y grafica las cargas dinamicas
analisisObj.resolverCargasDinamicas('cpenzien', false, 'disipadores', usarDisipadores, ...
    'cargaDisipador', cargasDinamicas{1}, 'betaObjetivo', 0.08, 'iterDisipador', 10, ...
    'betaGrafico', true, 'activado', resolverCargasDinamicas);

analisisObj.calcularCurvasEnergia(cargasDinamicas{1}, 'plotcarga', true, 'plot', 'all');
analisisObj.calcularMomentoCorteBasal(cargasDinamicas{1});
analisisObj.calcularDesplazamientoDrift(cargasDinamicas{1}, 32);
analisisObj.plotEsfuerzosElemento(cargasDinamicas{1}, elementos{104}, [1, 0, 0]);
analisisObj.plotTrayectoriaNodo(cargasDinamicas{1}, nodos{102}, [1, 0, 0]);
plt = analisisObj.plot('carga', cargasDinamicas{1}, 'cuadros', 400, ...
	'gif', 'test/modal/out/Modelo_DinamicaAvanzada_carga_sis.gif');

%% Finaliza el analisis
modeloObj.guardarResultados('test/modal/out/Modelo_DinamicaAvanzada.txt');
analisisObj.guardarResultados('test/modal/out/Modelo_DinamicaAvanzada.txt', cargasDinamicas);
clear h h1 i v;