fprintf('>\tTAREA4 MATRICIAL 2020\n');

% Creamos el modelo
modeloObj = Modelo(2, 3); % 3 grados de libertad
modeloObj.definirNombre('Tarea 4');

% Creamos los nodos
nodos = cell(6, 1);
nodos{1} = Nodo('N1', 2, [0, 0]');
nodos{2} = Nodo('N2', 2, [300, 0]');
nodos{3} = Nodo('N3', 2, [300, 450]');
nodos{4} = Nodo('N4', 2, [600, 450]');
nodos{5} = Nodo('N5', 2, [600, 0]');
nodos{6} = Nodo('N6', 2, [900, 0]');

% Agregamos los nodos al modelo
modeloObj.agregarNodos(nodos);

% Creamos los elementos
Ao_i = 32; % [cm2] impar
Ao_p = 27; % [cm2] par
Eo = 2100; % [tonf/cm2]
elementos = cell(9, 1);
elementos{1} = Biela2D('E1', nodos{1}, nodos{3}, Ao_i, Eo);
elementos{2} = Biela2D('E2', nodos{1}, nodos{2}, Ao_p, Eo);
elementos{3} = Biela2D('E3', nodos{2}, nodos{3}, Ao_i, Eo);
elementos{4} = Biela2D('E4', nodos{2}, nodos{5}, Ao_p, Eo);
elementos{5} = Biela2D('E5', nodos{3}, nodos{5}, Ao_i, Eo);
elementos{6} = Biela2D('E6', nodos{3}, nodos{4}, Ao_p, Eo);
elementos{7} = Biela2D('E7', nodos{4}, nodos{5}, Ao_i, Eo);
elementos{8} = Biela2D('E8', nodos{5}, nodos{6}, Ao_p, Eo);
elementos{9} = Biela2D('E9', nodos{4}, nodos{6}, Ao_i, Eo);

% Agregamos los elementos al modelo
modeloObj.agregarElementos(elementos);

% Creamos las restricciones
restricciones = cell(3, 1);
restricciones{1} = RestriccionNodo('R1', nodos{1}, [1, 2]');
restricciones{2} = RestriccionNodo('R4', nodos{4}, [2]');
restricciones{3} = RestriccionNodo('R6', nodos{6}, [2]'); %#ok<NBRAK>

% Agregamos las restricciones al modelo
modeloObj.agregarRestricciones(restricciones);

% Creamos la carga
cargas = cell(3, 1);
cargas{1} = CargaNodo('C2', nodos{2}, [0, -25]');
cargas{2} = CargaNodo('C3', nodos{3}, [4, 0]');
cargas{3} = CargaNodo('C5', nodos{5}, [0, -20]');

% Creamos el patron de cargas
PatronesDeCargas = cell(1, 1);
PatronesDeCargas{1} = PatronDeCargasConstante('CargaConstante', cargas);

% Agregamos las cargas al modelo
modeloObj.agregarPatronesDeCargas(PatronesDeCargas);

% Creamos el analisis
analisisObj = AnalisisEstatico(modeloObj);
analisisObj.analizar();
analisisObj.plot('deformada', true, 'factor', 20, 'unidad', 'cm');
modeloObj.guardarResultados('test/personal/out/Tarea4_Matricial2020.txt');