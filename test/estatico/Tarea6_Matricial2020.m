fprintf('>\tTAREA6 MATRICIAL 2020\n');

% Creamos el modelo
modeloObj = Modelo(3, 6);
modeloObj.definirNombre('Tarea 6');

% Creamos los nodos
nodos = cell(7, 1);
a = 100 * 150 / 250;
nodos{1} = Nodo('p1', 3, [100, 0, 0]');
nodos{2} = Nodo('p2', 3, [0, 100, 0]');
nodos{3} = Nodo('p3', 3, [-100, 0, 0]');
nodos{4} = Nodo('p4', 3, [a, 0, 100]');
nodos{5} = Nodo('p5', 3, [0, a, 100]');
nodos{6} = Nodo('p6', 3, [-a, 0, 100]');
nodos{7} = Nodo('p7', 3, [0, 0, 250]');

% Agregamos los nodos al modelo
modeloObj.agregarNodos(nodos);

% Creamos los elementos
Ao = 3; % [m2]
Eo = 2141404.047; % [kgf/cm2]
elementos = cell(12, 1);
elementos{1} = Biela3D('E1', nodos{1}, nodos{4}, Ao, Eo); % p1-p5
elementos{2} = Biela3D('E2', nodos{2}, nodos{4}, Ao, Eo); % p2-p6
elementos{3} = Biela3D('E3', nodos{2}, nodos{6}, Ao, Eo); % p3-p7
elementos{4} = Biela3D('E4', nodos{2}, nodos{5}, Ao, Eo); % p4-p8
elementos{5} = Biela3D('E5', nodos{1}, nodos{6}, Ao, Eo); % p1-p6
elementos{6} = Biela3D('E6', nodos{3}, nodos{6}, Ao, Eo); % p2-p7
elementos{7} = Biela3D('E7', nodos{5}, nodos{6}, Ao, Eo); % p3-p8
elementos{8} = Biela3D('E8', nodos{4}, nodos{6}, Ao, Eo); % p4-p5
elementos{9} = Biela3D('E9', nodos{4}, nodos{5}, Ao, Eo); % p5-p6
elementos{10} = Biela3D('E10', nodos{5}, nodos{7}, Ao, Eo); % p6-p7
elementos{11} = Biela3D('E11', nodos{6}, nodos{7}, Ao, Eo); % p7-p8
elementos{12} = Biela3D('E12', nodos{4}, nodos{7}, Ao, Eo); % p8-p5

% Agregamos los elementos al modelo
modeloObj.agregarElementos(elementos);

% Creamos las restricciones
restricciones = cell(3, 1);
restricciones{1} = RestriccionNodo('R1', nodos{1}, [1, 2, 3]'); % p1
restricciones{2} = RestriccionNodo('R2', nodos{2}, [1, 2, 3]'); % p2
restricciones{3} = RestriccionNodo('R3', nodos{3}, [1, 2, 3]'); % p3

% Agregamos las restricciones al modelo
modeloObj.agregarRestricciones(restricciones);

% Creamos la carga
cargas = cell(1, 1);
cargas{1} = CargaNodo('Carga nodo p7', nodos{7}, [-300, -500, 0]'); % kgf

% Creamos el patron de cargas
PatronesDeCargas = cell(1, 1);
PatronesDeCargas{1} = PatronDeCargasConstante('CargaConstante', cargas);

% Agregamos las cargas al modelo
modeloObj.agregarPatronesDeCargas(PatronesDeCargas);

% Creamos el analisis
analisisObj = AnalisisEstatico(modeloObj);
analisisObj.analizar();
analisisObj.plot('deformada', true, 'factor', 100, 'angAz', 150, 'angPol', 30);
modeloObj.guardarResultados('test/personal/out/Tarea6_Matricial2020.txt');