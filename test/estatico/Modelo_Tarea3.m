clear all; %#ok<CLALL>
fprintf('>\tMODELO_TAREA3\n');

% Test tarea 3

% Creamos el modelo
modeloObj = Modelo(2, 4);

% Creamos los nodos
nodos = cell(4, 1);
nodos{1} = Nodo('N1', 3, [0, 0]');
nodos{2} = Nodo('N2', 3, [15, 0]');
nodos{3} = Nodo('N3', 3, [30, 0]');
nodos{4} = Nodo('N4', 3, [45, 0]');

% Agregamos los nodos al modelo
modeloObj.agregarNodos(nodos);

% Creamos los elementos
Eo = 200000000;
Io = 0.0004;
elementos = cell(3, 1);
elementos{1} = Viga2D('V1', nodos{1}, nodos{2}, Io, Eo);
elementos{2} = Viga2D('V2', nodos{2}, nodos{3}, Io, Eo);
elementos{3} = Viga2D('V3', nodos{3}, nodos{4}, Io, Eo);

% Agregamos los elementos al modelo
modeloObj.agregarElementos(elementos);

% Creamos las restricciones, cada eje x,y en los 4 nodos
restricciones = cell(4, 1);
restricciones{1} = RestriccionNodo('R1', nodos{1}, [1, 2]');
restricciones{2} = RestriccionNodo('R2', nodos{2}, [1, 2]');
restricciones{3} = RestriccionNodo('R3', nodos{3}, [1, 2]');
restricciones{4} = RestriccionNodo('R4', nodos{4}, [1, 2]');

% Agregamos las restricciones al modelo
modeloObj.agregarRestricciones(restricciones);

% Creamos la carga
cargas = cell(5, 1);
cargas{1} = CargaVigaDistribuida('Distribuida 18kN/m', elementos{1}, -18, 0.0, -18, 1.0);
cargas{2} = CargaVigaPuntual('Puntual 90kN @5m', elementos{2}, -90, 1/3);
cargas{3} = CargaVigaPuntual('Puntual 90kN @10m', elementos{2}, -90, 2/3);
cargas{4} = CargaVigaDistribuida('Triangular 25kN', elementos{3}, -25, 0.0, 0, 1.0);
cargas{5} = CargaNodo('Momento 120kN-m', nodos{4}, [0, 0, 120])';

% Creamos el patron de cargas
PatronesDeCargas = cell(1, 1);
PatronesDeCargas{1} = PatronDeCargasConstante('CargaConstante', cargas);

% Agregamos las cargas al modelo
modeloObj.agregarPatronesDeCargas(PatronesDeCargas);

% Creamos el analisis
analisisObj = AnalisisEstatico(modeloObj);
analisisObj.analizar();
modeloObj.guardarResultados('test/estatico/out/Modelo_Tarea3.txt');