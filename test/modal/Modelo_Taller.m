fprintf('>\tMODELO_TALLER\n');

%% Creamos el modelo
modeloObj = Modelo(2, 3);
modeloObj.definirNombre('Modelo Taller');

%% Nodos modelo
nodos = {}; % Nodos Modelo

v = 8; % Vanos
h = 2.5; % Altura piso

% Piso 0
nodos{1} = Nodo('N01', 3, [0, 0]');
nodos{2} = Nodo('N02', 3, [v, 0]');
nodos{3} = Nodo('N03', 3, [2 * v, 0]');

% Piso 1
nodos{4} = Nodo('N11', 3, [0, h]');
nodos{5} = Nodo('N12', 3, [v, h]');
nodos{6} = Nodo('N13', 3, [2 * v, h]');

% Piso 2
nodos{7} = Nodo('N21', 3, [0, 2 * h]');
nodos{8} = Nodo('N22', 3, [v, 2 * h]');
nodos{9} = Nodo('N23', 3, [2 * v, 2 * h]');

% Piso 3
nodos{10} = Nodo('N31', 3, [0, 3 * h]');
nodos{11} = Nodo('N32', 3, [v, 3 * h]');
nodos{12} = Nodo('N33', 3, [2 * v, 3 * h]');

% Piso 4
nodos{13} = Nodo('N41', 3, [0, 4 * h]');
nodos{14} = Nodo('N42', 3, [v, 4 * h]');
nodos{15} = Nodo('N43', 3, [2 * v, 4 * h]');

% Agregamos los nodos al modelo
modeloObj.agregarNodos(nodos);

%% Creamos los elementos
elementos = {};

% Propiedades de la viga
Av = 0.65 * 0.4; % (m2)
Ev = 2625051; % (tonf/m2)
Iv = (0.4 * 0.65^3) / 12;

% Propiedades de la columna
Ac = 1; % (m2)
Ec = 2625051; % (tonf/m2)
Ic = 1 / 12;

% Densidad del material hormigon
Rhoh = 2.5 / 9.80665; % (ton/m3), se aplica factor carga masa

% Vigas
elementos{1} = VigaColumna2D('V4-5', nodos{4}, nodos{5}, Iv, Ev, Av, Rhoh);
elementos{2} = VigaColumna2D('V5-6', nodos{5}, nodos{6}, Iv, Ev, Av, Rhoh);
elementos{3} = VigaColumna2D('V7-8', nodos{7}, nodos{8}, Iv, Ev, Av, Rhoh);
elementos{4} = VigaColumna2D('V8-9', nodos{8}, nodos{9}, Iv, Ev, Av, Rhoh);
elementos{5} = VigaColumna2D('V10-11', nodos{10}, nodos{11}, Iv, Ev, Av, Rhoh);
elementos{6} = VigaColumna2D('V11-12', nodos{11}, nodos{12}, Iv, Ev, Av, Rhoh);
elementos{7} = VigaColumna2D('V13-14', nodos{13}, nodos{14}, Iv, Ev, Av, Rhoh);
elementos{8} = VigaColumna2D('V14-15', nodos{14}, nodos{15}, Iv, Ev, Av, Rhoh);

% Columnas
elementos{9} = VigaColumna2D('C1-4', nodos{1}, nodos{4}, Ic, Ec, Ac, Rhoh);
elementos{10} = VigaColumna2D('C2-5', nodos{2}, nodos{5}, Ic, Ec, Ac, Rhoh);
elementos{11} = VigaColumna2D('C3-6', nodos{3}, nodos{6}, Ic, Ec, Ac, Rhoh);
elementos{12} = VigaColumna2D('C4-7', nodos{4}, nodos{7}, Ic, Ec, Ac, Rhoh);
elementos{13} = VigaColumna2D('C5-8', nodos{5}, nodos{8}, Ic, Ec, Ac, Rhoh);
elementos{14} = VigaColumna2D('C6-9', nodos{6}, nodos{9}, Ic, Ec, Ac, Rhoh);
elementos{15} = VigaColumna2D('C7-10', nodos{7}, nodos{10}, Ic, Ec, Ac, Rhoh);
elementos{16} = VigaColumna2D('C8-11', nodos{8}, nodos{11}, Ic, Ec, Ac, Rhoh);
elementos{17} = VigaColumna2D('C9-12', nodos{9}, nodos{12}, Ic, Ec, Ac, Rhoh);
elementos{18} = VigaColumna2D('C10-13', nodos{10}, nodos{13}, Ic, Ec, Ac, Rhoh);
elementos{19} = VigaColumna2D('C11-14', nodos{11}, nodos{14}, Ic, Ec, Ac, Rhoh);
elementos{20} = VigaColumna2D('C12-15', nodos{12}, nodos{15}, Ic, Ec, Ac, Rhoh);

% Agregamos los elementos al modelo
modeloObj.agregarElementos(elementos);

%% Creamos las restricciones
restricciones = {};
restricciones{1} = RestriccionNodo('R1', nodos{1}, [1, 2, 3]');
restricciones{2} = RestriccionNodo('R2', nodos{2}, [1, 2, 3]');
restricciones{3} = RestriccionNodo('R3', nodos{3}, [1, 2, 3]');

% Agregamos las restricciones al modelo
modeloObj.agregarRestricciones(restricciones);

%% Creamos las cargas
cargasEstaticas = {};
cargasDinamicas = {};

cargaNodos = {nodos{4}, nodos{7}, nodos{10}, nodos{13}};
cargasDinamicas{1} = CargaPulso('Pulso', cargaNodos, [1, 0], 1, 0.1, 0.005, 0, 10);

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
analisisObj.plot();

%% Analiza el sistema y resuelve para cargas estaticas
analisisObj.analizar('nModos', 24, 'rayleighBeta', [0.02, 0.05], 'rayleighModo', [1, 2], ...
    'rayleighDir', ['h', 'h'], 'amortiguamiento', 'rayleigh', 'condensar', true);
analisisObj.disp();

%% Calcula y grafica las cargas dinamicas
analisisObj.resolverCargasDinamicas();

%% Grafica
% analisisObj.plot('carga', cargasDinamicas{1}, 'cuadros', 400, 'factor', 10);
analisisObj.plotTrayectoriaNodos(cargasDinamicas{1}, cargaNodos, [1, 0, 0], ...
    'plot', 'acel', 'fftacc', true);