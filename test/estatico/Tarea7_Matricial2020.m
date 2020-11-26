fprintf('>\tTAREA7 MATRICIAL 2020\n');

% Creamos el modelo
modeloObj = Modelo(3, 6);
modeloObj.definirNombre('Tarea 7');

% Creamos los nodos
nodos = cell(4, 1);
nodos{1} = Nodo('p1', 6, [0, 0, 0]');
nodos{2} = Nodo('p2', 6, [0, 5, 0]');
nodos{3} = Nodo('p3', 6, [3.5, 5, 0]');
nodos{4} = Nodo('p4', 6, [3.5, 5, -4]');

% Agregamos los nodos al modelo
modeloObj.agregarNodos(nodos);

% Creamos los elementos
Ao = 0.001; % [m2]
Eo = 22500000; % [Ton/m2]
Go = 8200000; % [Ton/m2]
Iz = 0.0004; % [m4]
Iy = 0.0002; % [m4]
Jo = 0.000005; % [m4]
elementos = cell(3, 1);
elementos{1} = VigaColumna3D('E1', nodos{1}, nodos{2}, [-1, 0, 0], Iy, Iz, Eo, Ao, Go, Jo);
elementos{2} = VigaColumna3D('E2', nodos{2}, nodos{3}, [0, 5, -1], Iy, Iz, Eo, Ao, Go, Jo);
elementos{3} = VigaColumna3D('E3', nodos{3}, nodos{4}, [3.5, 6, 0], Iy, Iz, Eo, Ao, Go, Jo);

% Agregamos los elementos al modelo
modeloObj.agregarElementos(elementos);

% Creamos las restricciones
restricciones = cell(2, 1);
restricciones{1} = RestriccionNodo('R1', nodos{1}, [1, 2, 3, 4, 5, 6]'); % p1
restricciones{2} = RestriccionNodo('R2', nodos{4}, [1, 2, 3, 4, 5, 6]'); % p2

% Agregamos las restricciones al modelo
modeloObj.agregarRestricciones(restricciones);

% Creamos la carga
cargas = cell(3, 1);
cargas{1} = CargaNodo('Carga nodo 2', nodos{2}, [0, 0, 0, 0, 0, -15]'); % Ton * m
cargas{2} = CargaVigaColumna3DDistribuidaConstante('Carga Distribuida E2', elementos{2}, 0, 0, -7);
cargas{3} = CargaVigaColumna3DDistribuidaConstante('Carga Distribuida E3', elementos{3}, 0, 0, -5);

% Creamos el patron de cargas
PatronesDeCargas = cell(1, 1);
PatronesDeCargas{1} = PatronDeCargasConstante('CargaConstante', cargas);

% Agregamos las cargas al modelo
modeloObj.agregarPatronesDeCargas(PatronesDeCargas);

% Creamos el analisis
analisisObj = AnalisisEstatico(modeloObj);
analisisObj.analizar();
analisisObj.plot('deformada', true, 'factor', 10, 'angAz', 150, 'angPol', 30);
modeloObj.guardarResultados('test/estatico/out/Tarea7_Matricial2020.txt');