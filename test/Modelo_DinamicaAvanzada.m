clear all; %#ok<CLALL>
fprintf('>\tMODELO_DINAMICA_AVANZADA\n');

% Creamos el modelo
modeloObj = Modelo(2, 6);

% Nodos modelo
Modelo_DinamicaAvanzadaNodo;

% Agregamos los nodos al modelo
modeloObj.agregarNodos(nodos);

% Creamos los elementos
Av = 0.013; % Propiedades de la viga
Ev = 200000000;
Iv = 0.000762;

Ac = 0.013; % Propiedades de la columna
Ec = 200000000;
Ic = 0.000762;

% Densidad del material
Rhoh = 2.5;

% Crea los elementos
Modelo_DinamicaAvanzadaElementos;

% Agregamos los elementos al modelo
modeloObj.agregarElementos(elementos);

% Creamos las restricciones
restricciones = cell(10, 1);
restricciones{1} = RestriccionNodo('R1', nodos{1}, [1, 2, 3]');
restricciones{2} = RestriccionNodo('R2', nodos{2}, [1, 2, 3]');
restricciones{3} = RestriccionNodo('R3', nodos{3}, [1, 2, 3]');
restricciones{4} = RestriccionNodo('R4', nodos{4}, [1, 2, 3]');
restricciones{5} = RestriccionNodo('R5', nodos{5}, [1, 2, 3]');
restricciones{6} = RestriccionNodo('R6', nodos{6}, [1, 2, 3]');
restricciones{7} = RestriccionNodo('R7', nodos{7}, [1, 2, 3]');
restricciones{8} = RestriccionNodo('R8', nodos{8}, [1, 2, 3]');
restricciones{9} = RestriccionNodo('R9', nodos{9}, [1, 2, 3]');
restricciones{10} = RestriccionNodo('R10', nodos{10}, [1, 2, 3]');

% Agregamos las restricciones al modelo
modeloObj.agregarRestricciones(restricciones);

% Creamos la carga
cargas = cell(1, 103);
for i = 1:103
    cargas{i} = CargaVigaColumnaDistribuida('Carga distribuida piso', elementos{i}, -1000, 0, -1000, 1, 0);
end

% Creamos el patron de cargas
PatronesDeCargas = cell(1, 1);
PatronesDeCargas{1} = PatronDeCargasConstante('CargaConstante', cargas);

% Agregamos las cargas al modelo
modeloObj.agregarPatronesDeCargas(PatronesDeCargas);

% Creamos el analisis
analisisObj = ModalEspectral(modeloObj);
analisisObj.analizar();
k = analisisObj.obtenerMatrizRigidez();
analisisObj.disp();
analisisObj.plot(true, 10);