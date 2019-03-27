clear all; %#ok<CLALL>
fprintf('>\tEJEMPLOCLASE_ENREJADO3D\n');

% Creamos el modelo
modeloObj = Modelo(3, 1);

% Creamos los nodos
nodos = cell(4, 1);
nodos{1} = Nodo('N1', 3, [-200, 0, 0]');
nodos{2} = Nodo('N2', 3, [200, -200, 0]');
nodos{3} = Nodo('N3', 3, [0, 200, 0]');
nodos{4} = Nodo('N4', 3, [0, 0, 300]');

% Agregamos los nodos al modelo
modeloObj.agregarNodos(nodos);

% Creamos los elementos
Ao = 10; % [cm2]
Eo = 1000; % [Tonf/cm2]
elementos = cell(3, 1);
elementos{1} = Biela3D('E1', nodos{1}, nodos{4}, Ao, Eo);
elementos{2} = Biela3D('E2', nodos{2}, nodos{4}, Ao, Eo);
elementos{3} = Biela3D('E3', nodos{3}, nodos{4}, Ao, Eo);

% Agregamos los elementos al modelo
modeloObj.agregarElementos(elementos);

% Creamos las restricciones
restricciones = cell(3, 1);
restricciones{1} = RestriccionNodo('R1', nodos{1}, [1, 2, 3]');
restricciones{2} = RestriccionNodo('R2', nodos{2}, [1, 2, 3]');
restricciones{3} = RestriccionNodo('R3', nodos{3}, [1, 2, 3]');

% Agregamos las restricciones al modelo
modeloObj.agregarRestricciones(restricciones);

% Creamos la carga
cargas = cell(1, 1);
cargas{1} = CargaNodo('Carga nodo 4', nodos{4}, [50, 0, -30]');

% Creamos el patron de cargas
PatronesDeCargas = cell(1, 1);
PatronesDeCargas{1} = PatronDeCargasConstante('CargaConstante', cargas);

% Agregamos las cargas al modelo
modeloObj.agregarPatronesDeCargas(PatronesDeCargas);

% Creamos el analisis
analisisObj = AnalisisEstatico(modeloObj);
analisisObj.analizar();
analisisObj.plot(true);
modeloObj.guardarResultados('test/estatico/out/EjemploClase_Enrejado3D.txt');