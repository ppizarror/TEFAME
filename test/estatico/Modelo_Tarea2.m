clear all; %#ok<CLALL>
fprintf('>\tMODELO_TAREA2\n');

% Creamos el modelo
modeloObj = Modelo(2, 3);

% Creamos los nodos
nodos = cell(4, 1);
nodos{1} = Nodo('N1', 2, [0, 0]');
nodos{2} = Nodo('N2', 2, [800, 0]');
nodos{3} = Nodo('N3', 2, [400, 400]');
nodos{4} = Nodo('N4', 2, [400, 800]');

% Agregamos los nodos al modelo
modeloObj.agregarNodos(nodos);

% Creamos los elementos
Ao = 20; % [cm2]
Eo = 200000; % [tonf/cm2]
elementos = cell(6, 1);
elementos{1} = Biela2D('E1', nodos{1}, nodos{2}, Ao, Eo);
elementos{2} = Biela2D('E2', nodos{1}, nodos{3}, Ao, Eo);
elementos{3} = Biela2D('E3', nodos{3}, nodos{2}, Ao, Eo);
elementos{4} = Biela2D('E4', nodos{1}, nodos{4}, Ao, Eo);
elementos{5} = Biela2D('E5', nodos{3}, nodos{4}, Ao, Eo);
elementos{6} = Biela2D('E6', nodos{4}, nodos{2}, Ao, Eo);

% Agregamos los elementos al modelo
modeloObj.agregarElementos(elementos);

% Creamos las restricciones
restricciones = cell(2, 1);
restricciones{1} = RestriccionNodo('R1', nodos{1}, [1, 2]');
restricciones{2} = RestriccionNodo('R2', nodos{2}, [2]'); %#ok<NBRAK>

% Agregamos las restricciones al modelo
modeloObj.agregarRestricciones(restricciones);

% Creamos la carga
cargas = cell(1, 1);
cargas{1} = CargaNodo('C1', nodos{4}, [80, -120]');

% Creamos el patron de cargas
PatronesDeCargas = cell(1, 1);
PatronesDeCargas{1} = PatronDeCargasConstante('CargaConstante', cargas);

% Agregamos las cargas al modelo
modeloObj.agregarPatronesDeCargas(PatronesDeCargas);

% Creamos el analisis
analisisObj = AnalisisEstatico(modeloObj);
analisisObj.analizar();
analisisObj.plot(true);
modeloObj.guardarResultados('test/estatico/out/Modelo_Tarea2.txt');