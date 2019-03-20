clear all; %#ok<CLALL>
fprintf('>\tMODELO_TAREA4\n');

% Creamos el modelo
modeloObj = Modelo(2, 6);

% Creamos los nodos
nodos = cell(3, 1);
nodos{1} = Nodo('N1', 3, [0, 8]');
nodos{2} = Nodo('N2', 3, [6, 0]');
nodos{3} = Nodo('N3', 3, [18, 0]');

% Agregamos los nodos al modelo
modeloObj.agregarNodos(nodos);

% Creamos los elementos
Ao = 0.013;
Eo = 200000000;
Io = 0.000762;
elementos = cell(2, 1);
elementos{1} = VigaColumna2D('Viga-Columna 1', nodos{1}, nodos{2}, Io, Eo, Ao);
elementos{2} = VigaColumna2D('Viga-Columna 2', nodos{2}, nodos{3}, Io, Eo, Ao);

% Agregamos los elementos al modelo
modeloObj.agregarElementos(elementos);

% Creamos las restricciones
restricciones = cell(3, 1);
restricciones{1} = RestriccionNodo('R1', nodos{1}, [1, 2, 3]');
restricciones{2} = RestriccionNodo('R2', nodos{2}, [1, 2]');
restricciones{3} = RestriccionNodo('R3', nodos{3}, [1, 2]');

% Agregamos las restricciones al modelo
modeloObj.agregarRestricciones(restricciones);

% Creamos la carga
cargas = cell(3, 1);
cargas{1} = CargaNodo('Momento nodo 2', nodos{2}, [0, 0, -150]');
cargas{2} = CargaVigaColumnaPuntual('Carga elem 1 @125[kN]', elementos{1}, -125, 0.5, 0);
cargas{3} = CargaVigaColumnaDistribuida('Carga dist elem 2 @24[kN/m]', elementos{2}, -24, 0, -24, 1, 0);

% Creamos el patron de cargas
PatronesDeCargas = cell(1, 1);
PatronesDeCargas{1} = PatronDeCargasConstante('CargaConstante', cargas);

% Agregamos las cargas al modelo
modeloObj.agregarPatronesDeCargas(PatronesDeCargas);

% Creamos el analisis
analisisObj = AnalisisEstatico(modeloObj);
analisisObj.analizar();
modeloObj.guardarResultados('test/out/Modelo_Tarea4.txt');