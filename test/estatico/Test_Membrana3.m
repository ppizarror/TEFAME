fprintf('>\tTEST_MEMBRANA3\n');

% Testea cargas en un muro muy alto formado por varios elementos
% CARGA VERTICAL EN EL ULTIMO ELEMENTO
%
N = 11; % Numero de bloques
b = 100; % Ancho de cada bloque
h = 100; % Alto de cada bloque
%
% N = 2
%
%    3---6
%    |   |
%    2---5
%    |   |
%    1---4
% =============
%
% N = 3
%
%    4---8
%    |   |
%    3---7
%    |   |
%    2---6
%    |   |
%    1---5
% =============

t = 15; % cm
E = 300000; % Modulo de Elasticidad [kgf/cm^2]
nu = 0.15; % Modulo de Poisson

% Numero de grados de libertad
gdl = N * 2 + 2;

% Creamos el modelo
modeloObj = Modelo(2, gdl);
modeloObj.definirNombre('Membrana 3');

% Creamos los nodos
nodos = cell(gdl, 1);
for i = 1:(N + 1)
    j = N + 1 + i;
    nodos{i} = Nodo(sprintf('N%d', i), 2, [0, h * (i - 1)]');
    nodos{j} = Nodo(sprintf('N%d', j), 2, [b, h * (i - 1)]');
end

% Agregamos los nodos al modelo
modeloObj.agregarNodos(nodos);

% Creamos los elementos
elementos = cell(N, 1);
for i = 1:N
    % n4 ------------ n3     Esta es la notacion que se usa para crear los
    %  |              |      elementos
    %  |      (i)     |
    %  |              |
    % n1 ------------ n2
    n1 = i;
    n2 = N + i + 1;
    n3 = N + i + 2;
    n4 = i + 1;
    elementos{i} = Membrana(sprintf('MEM%d', i), nodos{n1}, nodos{n2}, nodos{n3}, nodos{n4}, E, nu, t);
end

% Agregamos los elementos al modelo
modeloObj.agregarElementos(elementos);

% Creamos las restricciones
restricciones = cell(2, 1);
restricciones{1} = RestriccionNodo('R1', nodos{1}, [1, 2]'); % Apoyo simple en ambos
restricciones{2} = RestriccionNodo('R2', nodos{N+2}, [1, 2]');

% Agregamos las restricciones al modelo
modeloObj.agregarRestricciones(restricciones);

% Creamos la carga
cargas = cell(1, 1);
cargas{1} = CargaMembranaDistribuida(sprintf('DV100KN V@%d', N), elementos{N}, 4, 3, -100, 0, -100, 1);

% Creamos el patron de cargas
PatronesDeCargas = cell(1, 1);
PatronesDeCargas{1} = PatronDeCargasConstante('CargaConstante', cargas);

% Agregamos las cargas al modelo
modeloObj.agregarPatronesDeCargas(PatronesDeCargas);

% Creamos el analisis
analisisObj = AnalisisEstatico(modeloObj);
analisisObj.analizar();
analisisObj.plot('deformada', true);
modeloObj.guardarResultados('test/estatico/out/Test_Membrana3.txt');