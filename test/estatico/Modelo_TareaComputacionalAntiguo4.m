fprintf('>\tMODELO_TAREACOMPUTACIONAL_ANTIGUO4\n');
% Implementa la estructura anterior antes de cambiarla, se utilizan 12
% barras para lograr el GIE=0. El caso original constaba de 9 barras por lo
% que era imposible resolver la estructura. El nuevo modelo de la tarea
% computacional se puede revisar en Modelo_TareaComputacional4.m

% Creamos el modelo
modeloObj = Modelo(3, 12);
modeloObj.definirNombre('Tarea computacional 4 antiguo');

% Unidad
un = 100.0;

% Creamos los nodos
nodos = cell(7, 1);
nodos{1} = Nodo('a1', 3, [-4, -4, 0]'*un);
nodos{2} = Nodo('a2', 3, [0, 0, 0]'*un);
nodos{3} = Nodo('b1', 3, [4, -4, 6]'*un);
nodos{4} = Nodo('b2', 3, [4, 0, 3]'*un);
nodos{5} = Nodo('c1', 3, [5, -4, 0]'*un);
nodos{6} = Nodo('c2', 3, [4.5, 0, 0]'*un);
nodos{7} = Nodo('d', 3, [4, 4, 0]'*un);

% Agregamos los nodos al modelo
modeloObj.agregarNodos(nodos);

% Creamos los elementos
Ao = 40 / (10000 / (un * un)); % [cm2]
Eo = 2100 * (10000 / (un * un)); % [Tonf/cm2]
elementos = cell(12, 1);
elementos{1} = Biela3D('E1', nodos{1}, nodos{2}, Ao, Eo); % a1-a2
elementos{2} = Biela3D('E2', nodos{3}, nodos{4}, Ao, Eo); % b1-b2
elementos{3} = Biela3D('E3', nodos{5}, nodos{6}, Ao, Eo); % c1-c2
elementos{4} = Biela3D('E4', nodos{2}, nodos{4}, Ao, Eo); % a2-b2
elementos{5} = Biela3D('E5', nodos{4}, nodos{6}, Ao, Eo); % b2-c2
elementos{6} = Biela3D('E6', nodos{2}, nodos{6}, Ao, Eo); % a2-c2
elementos{7} = Biela3D('E7', nodos{2}, nodos{7}, Ao, Eo); % a2-d
elementos{8} = Biela3D('E8', nodos{4}, nodos{7}, Ao, Eo); % b2-d
elementos{9} = Biela3D('E9', nodos{6}, nodos{7}, Ao, Eo); % c2-d
elementos{10} = Biela3D('E10', nodos{1}, nodos{4}, Ao, Eo); % a1-b2
elementos{11} = Biela3D('E11', nodos{3}, nodos{6}, Ao, Eo); % b1-c2
elementos{12} = Biela3D('E12', nodos{5}, nodos{2}, Ao, Eo); % c1-a2

% Agregamos los elementos al modelo
modeloObj.agregarElementos(elementos);

% Creamos las restricciones
restricciones = cell(3, 1);
restricciones{1} = RestriccionNodo('R1', nodos{1}, [1, 2, 3]'); % a1
restricciones{2} = RestriccionNodo('R2', nodos{3}, [1, 2, 3]'); % b1
restricciones{3} = RestriccionNodo('R3', nodos{5}, [1, 2, 3]'); % c1

% Agregamos las restricciones al modelo
modeloObj.agregarRestricciones(restricciones);

% Creamos la carga
cargas = cell(1, 1);
cargas{1} = CargaNodo('Carga nodo d', nodos{7}, [5, 0, 7]');

% Creamos el patron de cargas
PatronesDeCargas = cell(1, 1);
PatronesDeCargas{1} = PatronDeCargasConstante('CargaConstante', cargas);

% Agregamos las cargas al modelo
modeloObj.agregarPatronesDeCargas(PatronesDeCargas);

% Creamos el analisis
analisisObj = AnalisisEstatico(modeloObj);
analisisObj.analizar();
analisisObj.plot('deformada', true);
modeloObj.guardarResultados('test/estatico/out/Modelo_TareaComputacionalAntiguo4.txt');