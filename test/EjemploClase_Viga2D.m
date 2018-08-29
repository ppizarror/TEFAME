clear all; %#ok<CLALL>
fprintf('>\tEJEMPLOCLASE_VIGA2D\n');

% Creamos el modelo
modeloObj = Modelo(2, 4);

% Creamos los Nodos
nodos = cell(4, 1);
nodos{1} = Nodo('N1', 3, [0, 0]');
nodos{2} = Nodo('N2', 3, [400, 0]');
nodos{3} = Nodo('N3', 3, [800, 0]');
nodos{4} = Nodo('N4', 3, [1000, 0]');

% Agregamos los nodos al modelo
modeloObj.agregarNodos(nodos);

% Creamos los elementos
Eo = 2000;
Io = 20000;
elementos = cell(3, 1);
elementos{1} = Viga2D('V1', nodos{1}, nodos{2}, Io, Eo);
elementos{2} = Viga2D('V2', nodos{2}, nodos{3}, Io, Eo);
elementos{3} = Viga2D('V3', nodos{3}, nodos{4}, Io, Eo);

% Agregamos los elementos al modelo
modeloObj.agregarElementos(elementos);

% Creamos las restricciones
restricciones = cell(4, 1);
restricciones{1} = RestriccionNodo('R1', nodos{1}, [1, 2, 3]');
restricciones{2} = RestriccionNodo('R2', nodos{2}, [1, 2]');
restricciones{3} = RestriccionNodo('R3', nodos{3}, [1, 2]');
restricciones{4} = RestriccionNodo('R4', nodos{4}, [1]'); %#ok<NBRAK>

% Agregamos las restricciones al modelo
modeloObj.agregarRestricciones(restricciones);

% Creamos la carga
cargas = cell(2, 1);
cargas{1} = CargaNodo('Momento nodo 2', nodos{2}, [0, 0, -5000]');
cargas{2} = CargaNodo('Carga vertical', nodos{4}, [0, -25, 0]');

% Creamos el Patron de Cargas
PatronesDeCargas = cell(1, 1);
PatronesDeCargas{1} = PatronDeCargasConstante('CargaConstante', cargas);

% Agregamos las cargas al modelo
modeloObj.agregarPatronesDeCargas(PatronesDeCargas);

% Creamos el analisis
analisisObj = AnalisisEstatico(modeloObj);
analisisObj.analizar();
modeloObj.guardarResultados('test/out/EjemploClase_Viga2D.txt');