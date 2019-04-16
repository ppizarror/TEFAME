fprintf('>\tEJEMPLOCLASE_VIGACOLUMNA_2D\n');

% Creamos el modelo
modeloObj = Modelo(2, 6);

% Creamos los nodos
nodos = cell(3, 1);
nodos{1} = Nodo('N1', 3, [0, 0]');
nodos{2} = Nodo('N2', 3, [4, 8]');
nodos{3} = Nodo('N3', 3, [10, 8]');

% Agregamos los nodos al modelo
modeloObj.agregarNodos(nodos);

% Creamos los elementos
Ao = 0.005;
Eo = 21000000;
Io = 0.0004;
elementos = cell(2, 1);
elementos{1} = VigaColumna2D('VC1', nodos{1}, nodos{2}, Io, Eo, Ao);
elementos{2} = VigaColumna2D('VC2', nodos{2}, nodos{3}, Io, Eo, Ao);

% Agregamos los elementos al modelo
modeloObj.agregarElementos(elementos);

% Creamos las restricciones
restricciones = cell(2, 1);
restricciones{1} = RestriccionNodo('R1', nodos{1}, [1, 2, 3]');
restricciones{2} = RestriccionNodo('R3', nodos{3}, [1, 2, 3]');

% Agregamos las restricciones al modelo
modeloObj.agregarRestricciones(restricciones);

% Creamos la carga
cargas = cell(5, 1);
cargas{1} = CargaNodo('Momento nodo 2', nodos{2}, [0, 0, -120]');
cargas{2} = CargaNodo('Carga vertical nodo 2', nodos{2}, [0, -40, 0]');
cargas{3} = CargaVigaColumnaPuntual('Carga elem 1 80[ton]', elementos{1}, -80, 0.5, pi/2-1.107);
cargas{4} = CargaVigaColumnaDistribuida('Carga dist elem 1 @15[ton]', elementos{1}, -15, 0, -15, 1, -1.107);
cargas{5} = CargaVigaColumnaDistribuida('Carga dist elem 2 @30[ton]', elementos{2}, -30, 0, -30, 1, 0);

% Creamos el patron de cargas
PatronesDeCargas = cell(1, 1);
PatronesDeCargas{1} = PatronDeCargasConstante('CargaConstante', cargas);

% Agregamos las cargas al modelo
modeloObj.agregarPatronesDeCargas(PatronesDeCargas);

% Creamos el analisis
analisisObj = AnalisisEstatico(modeloObj);
analisisObj.analizar();
analisisObj.plot(true);
modeloObj.guardarResultados('test/estatico/out/EjemploClase_VigaColumna2D.txt');