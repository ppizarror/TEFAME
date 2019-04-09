clear all; %#ok<CLALL>
fprintf('>\tEJEMPLOCLASE_ENREJADO2D\n');

% Creamos el modelo
modeloObj = Modelo(2, 2);

% Creamos los nodos
nodos = cell(4, 1);
nodos{1} = Nodo('N1', 2, [0, 600]');
nodos{2} = Nodo('N2', 2, [400, 600]');
nodos{3} = Nodo('N3', 2, [0, 0]');
nodos{4} = Nodo('N4', 2, [400, 300]');

% Agregamos los nodos al modelo
modeloObj.agregarNodos(nodos);

% Creamos los elementos
Ao = 25; % [cm2]
Eo = 850; % [tonf/cm2]
elementos = cell(5, 1);
elementos{1} = Biela2D('E1', nodos{1}, nodos{2}, Ao, Eo);
elementos{2} = Biela2D('E2', nodos{4}, nodos{2}, Ao, Eo);
elementos{3} = Biela2D('E3', nodos{1}, nodos{4}, Ao, Eo);
elementos{4} = Biela2D('E4', nodos{3}, nodos{2}, Ao, Eo);
elementos{5} = Biela2D('E5', nodos{3}, nodos{4}, Ao, Eo);

% Agregamos los elementos al modelo
modeloObj.agregarElementos(elementos);

% Creamos las restricciones
restricciones = cell(3, 1);
restricciones{1} = RestriccionNodo('R1', nodos{1}, [1, 2]');
restricciones{2} = RestriccionNodo('R2', nodos{3}, [1, 2]');
restricciones{3} = RestriccionNodo('R3', nodos{4}, [2]'); %#ok<NBRAK>

% Agregamos las restricciones al modelo
modeloObj.agregarRestricciones(restricciones);

% Creamos la carga
cargas = cell(2, 1);
cargas{1} = CargaNodo('C1', nodos{2}, [35, -80]');
cargas{2} = CargaNodo('C2', nodos{4}, [35, 0]');

% Creamos el patron de cargas
PatronesDeCargas = cell(1, 1);
PatronesDeCargas{1} = PatronDeCargasConstante('CargaConstante', cargas);

% Agregamos las cargas al modelo
modeloObj.agregarPatronesDeCargas(PatronesDeCargas);

% Creamos el analisis
analisisObj = AnalisisEstatico(modeloObj);
analisisObj.analizar();
analisisObj.plot(true, 50);
modeloObj.guardarResultados('test/estatico/out/EjemploClase_Enrejado2D.txt');