clear all; %#ok<CLALL>
fprintf('>\tMODELO_TAREA5\n');

% Creamos el modelo
modeloObj = Modelo(2, 3);

% Creamos los nodos
nodos = cell(4, 1);
nodos{1} = Nodo('N1', 2, [0, 0]');
nodos{2} = Nodo('N2', 2, [8, 0]');
nodos{3} = Nodo('N3', 2, [4, 4]');
nodos{4} = Nodo('N4', 2, [4, 8]');

% Agregamos los nodos al modelo
modeloObj.agregarNodos(nodos);

% Creamos los elementos
Ao = 0.002; % [m2]
Eo = 200000000; % [kN/m2]
alpha = 1.2*10^-5; % Coeficiente de dilatacion termica
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
cargas = cell(3, 1);
cargas{1} = CargaBielaTemperatura('T BIELA 2 DT=30', elementos{2}, 30, alpha);
cargas{2} = CargaBielaTemperatura('T BIELA 3 DT=30', elementos{3}, 30, alpha);
cargas{3} = CargaBielaTemperatura('T BIELA 5 DT=20', elementos{5}, 20, alpha);

% Creamos el patron de cargas
PatronesDeCargas = cell(1, 1);
PatronesDeCargas{1} = PatronDeCargasConstante('CargaConstante', cargas);

% Agregamos las cargas al modelo
modeloObj.agregarPatronesDeCargas(PatronesDeCargas);

% Creamos el analisis
analisisObj = AnalisisEstatico(modeloObj);
analisisObj.analizar();
modeloObj.guardarResultados('test/out/Modelo_Tarea5.txt');