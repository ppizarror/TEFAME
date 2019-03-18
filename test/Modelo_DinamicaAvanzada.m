clear all;  %#ok<CLALL>

% Creamos el modelo
modeloObj = Modelo(2, 6);

% Nodos Modelo
Modelo_DinamicaAvanzadaNodo

n = length(nodos);

for i = 1:n
    coord = nodos{i}.obtenerCoordenadas;
    x_plot(i) = coord(1);
    y_plot(i) = coord(2);
end
plot(x_plot,y_plot,'o')
% Agregamos los nodos al modelo
modeloObj.agregarNodos(nodos);



% Creamos los elementos
% Propiedades de la Viga
Av = 0.013;
Ev = 200000000;
Iv = 0.000762;
% Propiedades de la Columna
Ac = 0.013;
Ec = 200000000;
Ic = 0.000762;

Modelo_DinamicaAvanzadaElementos

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
ncol = 95;
cargas = cell(ncol, 1);
for i = 84:length(elementos)
    cargas{i-83} = CargaVigaColumnaDistribuida('Carga dist elem 2 @24[kN/m]', elementos{i}, -1, 0, -1, 1, 0);
end

% Creamos el Patron de Cargas
PatronesDeCargas = cell(1, 1);
PatronesDeCargas{1} = PatronDeCargasConstante('CargaConstante', cargas);

% Agregamos las cargas al modelo
modeloObj.agregarPatronesDeCargas(PatronesDeCargas);

% Creamos el analisis
analisisObj = AnalisisEstatico(modeloObj);
analisisObj.analizar();