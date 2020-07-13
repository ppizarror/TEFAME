%|______________________________________________________________________|
%|                                                                      |
%|          TEFAME - Toolbox para Elementos Finitos y Analisis          |
%|                  Matricial de Estructuras en MATLAB                  |
%|                                                                      |
%|                   Area  de Estructuras y Geotecnia                   |
%|                   Departamento de Ingenieria Civil                   |
%|              Facultad de Ciencias Fisicas y Matematicas              |
%|                         Universidad de Chile                         |
%|                                                                      |
%| TEFAME es una  plataforma en base a objetos para modelar, analizar y |
%| visualizar  la respuesta de sistemas  estructurales usando el metodo |
%| de elementos finitos y analisis matricial de estructuras en MATLAB.  |
%| Repositorio: https://github.com/ppizarror/TEFAME                     |
%|______________________________________________________________________|
%|                                                                      |
%| MIT License                                                          |
%| Copyright (c) 2018-2019 Pablo Pizarro R @ppizarror.com.              |
%|                                                                      |
%| Permission is hereby granted, free of charge, to any person obtai-   |
%| ning a copy of this software and associated documentation files (the |
%| "Software"), to deal in the Software without restriction, including  |
%| without limitation the rights to use, copy, modify, merge, publish,  |
%| distribute, sublicense, and/or sell copies of the Software, and to   |
%| permit persons to whom the Software is furnished to do so, subject   |
%| to the following conditions:                                         |
%|                                                                      |
%| The above copyright notice and this permission notice shall be       |
%| included in all copies or substantial portions of the Software.      |
%|                                                                      |
%| THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,      |
%| EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF   |
%| MERCHANTABILITY,FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.|
%| IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY |
%| CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, |
%| TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE    |
%| SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.               |
%|______________________________________________________________________|

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
modeloObj.definirNombre('Membrana2D 3');

% Creamos los nodos
nodos = cell(gdl, 1);
for i = 1:(N + 1)
    j = N + 1 + i;
    nodos{i} = Nodo(sprintf('N%d', i), 2, [0, h * (i - 1)]');
    nodos{j} = Nodo(sprintf('N%d', j), 2, [b, h * (i - 1)]');
end % for i

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
    elementos{i} = Membrana2D(sprintf('MEM%d', i), nodos{n1}, nodos{n2}, nodos{n3}, nodos{n4}, E, nu, t);
end % for i

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
cargas{1} = CargaMembrana2DDistribuida(sprintf('DV100KN V@%d', N), elementos{N}, 4, 3, -100, 0, -100, 1);

% Creamos el patron de cargas
PatronesDeCargas = cell(1, 1);
PatronesDeCargas{1} = PatronDeCargasConstante('CargaConstante', cargas);

% Agregamos las cargas al modelo
modeloObj.agregarPatronesDeCargas(PatronesDeCargas);

% Creamos el analisis
analisisObj = AnalisisEstatico(modeloObj);
analisisObj.analizar();
analisisObj.plot('deformada', true, 'factor', 1000);
modeloObj.guardarResultados('test/estatico/out/Test_Membrana3.txt');