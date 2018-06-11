clear all; %#ok<CLALL>
fprintf('>\tMODELO_TAREA4\n');

% Test viga con carga simple a distancia D (% del largo) del nodo 1,
% reacciones verticales R1,R3 y horizontales R2,R4. Teóricamente:
% R2=R4=0, R1+R3=P, R1=P*(L-D)/L, R2=P*D/L.
%
%   <-- D -->
%
%         P |
%           |
%           |
%   --------v--------
%   ^               ^
% R1,R2           R3,R4
%
%   <------ L ------>

P = 10;
D = 0.5;
L = 10;

% Creamos el modelo
modeloObj = Modelo(2, 2);

% Creamos los Nodos
nodos = cell(2, 1);
nodos{1} = Nodo('N1', 3, [0, 0]');
nodos{2} = Nodo('N2', 3, [L, 0]');

% Agregamos los nodos al modelo
modeloObj.agregarNodos(nodos);

% Creamos los elementos
Eo = 200000000;
Io = 0.0004;
elementos = cell(1, 1);
elementos{1} = Viga2D('V1', nodos{1}, nodos{2}, Io, Eo);

% Agregamos los elementos al modelo
modeloObj.agregarElementos(elementos);

% Creamos las restricciones
restricciones = cell(4, 1);
restricciones{1} = RestriccionNodo('R1', nodos{1}, [1, 2]');
restricciones{2} = RestriccionNodo('R2', nodos{1}, [1, 2]');
restricciones{3} = RestriccionNodo('R3', nodos{2}, [1, 2]');
restricciones{4} = RestriccionNodo('R4', nodos{2}, [1, 2]');

% Agregamos las restricciones al modelo
modeloObj.agregarRestricciones(restricciones);

% Creamos la carga
cargas = cell(1, 1);
cargas{1} = CargaVigaPuntual('P', elementos{1}, P, D);

% Creamos el Patron de Cargas
PatronesDeCargas = cell(1, 1);
PatronesDeCargas{1} = PatronDeCargasConstante('CargaConstante', cargas);

% Agregamos las cargas al modelo
modeloObj.agregarPatronesDeCargas(PatronesDeCargas);

% Creamos el Analsis
analisisObj = AnalisisEstatico(modeloObj);
analisisObj.analizar();

modeloObj.guardarResultados('output/Ejemplo_Viga2D.txt');