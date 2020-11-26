fprintf('>\tTAREA5 MATRICIAL 2020\n');

% Creamos el modelo
modeloObj = Modelo(2, 3); % 3 grados de libertad
modeloObj.definirNombre('Tarea 5');

% Creamos los nodos
nodos = cell(5, 1);
nodos{1} = Nodo('N1', 3, [0, 0]');
nodos{2} = Nodo('N2', 3, [0, 4000]');
nodos{3} = Nodo('N3', 3, [4500, 5500]');
nodos{4} = Nodo('N4', 3, [9000, 4000]');
nodos{5} = Nodo('N5', 3, [9000, 0]');

% Agregamos los nodos al modelo
modeloObj.agregarNodos(nodos);

% Creamos los elementos
Eo = 210; % [kN/mm2]
Ac = 8750; % [mm]
Ic = 145*10^6; % [mm2]
Av = 8750; % [mm]
Iv = 280*10^6; % [mm2]
elementos = cell(5, 1);
elementos{1} = VigaColumna2D('E1', nodos{1}, nodos{2}, Ic, Eo, Ac);
elementos{2} = VigaColumna2D('E2', nodos{2}, nodos{3}, Iv, Eo, Av);
elementos{3} = VigaColumna2D('E3', nodos{2}, nodos{4}, Iv, Eo, Av);
elementos{4} = VigaColumna2D('E4', nodos{3}, nodos{4}, Iv, Eo, Av);
elementos{5} = VigaColumna2D('E5', nodos{4}, nodos{5}, Ic, Eo, Ac);

% Agregamos los elementos al modelo
modeloObj.agregarElementos(elementos);

% Creamos las restricciones
restricciones = cell(2, 1);
restricciones{1} = RestriccionNodo('R1', nodos{1}, [1, 2, 3]');
restricciones{2} = RestriccionNodo('R5', nodos{5}, [1, 2, 3]');

% Agregamos las restricciones al modelo
modeloObj.agregarRestricciones(restricciones);

% Creamos la carga
cargas = cell(5, 1);
cargas{1} = CargaNodo('Cn2', nodos{2}, [210, 0, 0]');
cargas{2} = CargaVigaColumna2DDistribuidaConstante('Cv2', elementos{2}, -0.026, 0);
cargas{3} = CargaVigaColumna2DDistribuidaConstante('Cv4', elementos{4}, 0.026, 0);
cargas{4} = CargaVigaColumna2DPuntual('Cv31', elementos{3}, -100, 2/9);
cargas{5} = CargaVigaColumna2DPuntual('Cv32', elementos{3}, -100, 7/9);

% Creamos el patron de cargas
PatronesDeCargas = cell(1, 1);
PatronesDeCargas{1} = PatronDeCargasConstante('CargaConstante', cargas);

% Agregamos las cargas al modelo
modeloObj.agregarPatronesDeCargas(PatronesDeCargas);

% Creamos el analisis
analisisObj = AnalisisEstatico(modeloObj);
analisisObj.analizar();
analisisObj.plot('deformada', true, 'defElem', false, 'factor', 20, 'unidad', 'mm');
modeloObj.guardarResultados('test/estatico/out/Tarea5_Matricial2020.txt');