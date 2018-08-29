% ______________________________________________________________________
%|                                                                      |
%|        Tests - Ejecuta todos los tests de la plataforma TEFAME       |
%|                                                                      |
%|                   Area  de Estructuras y Geotecnia                   |
%|                   Departamento de Ingenieria Civil                   |
%|              Facultad de Ciencias Fisicas y Matematicas              |
%|                         Universidad de Chile                         |
%|                                                                      |
%| Correr_Tests ejecuta cada uno de los tests implementados en la pla-  |
%| taforma TEFAME en el contexto de las tareas computacionales del cur- |
%| so de Analisis Matricial de Estructuras CI5211-1 semestre Otono 2018 |
%|                                                                      |
%| Los tests implementados hasta la fecha exploran las tareas numericas |
%| y los ejemplos vistos en clase (material docente) con el fin de eva- |
%| luar los resultados numericos entregados por las funciones implemen- |
%| tadas.                                                               |
%|                                                                      |
%| Desarrollado por:                                                    |
%|       Pablo Pizarro R. @ppizarror.com                                |
%|       Estudiante de Ingenieria Civil en Construccion-Estructuras     |
%|       Universidad de Chile                                           |
%|______________________________________________________________________|
%|                                                                      |
%| Para ejecutar la tarea se debe anadir la carpeta 'Programa_TEFAME'   |
%| al PATH de Matlab. Luego se debe ejecutar este script. Automatica-   |
%| mente se anadira la carpeta 'test' al path para poder correr cada    |
%| uno de los tests. Los resultados son almacenados en la carpeta       |
%| 'output' ubicada en directorio raiz.                                 |
%|______________________________________________________________________|

% Anade carpetas al PATH
addpath('test');
iniciar_TEFAME;

% Inicia los tests
clc;
fprintf('CORRIENDO TESTS\n');

% Tarea computacional 5
Modelo_TareaComputacional5;

% Test de membranas
Test_Membrana1;
Test_Membrana2;
Test_MembranaCargaDistribuidaHor;
Test_MembranaCargaDistribuidaVer;

% Ejemplos clase
EjemploClase_Enrejado3D;
EjemploClase_Enrejado2D;
EjemploClase_Viga2D;
EjemploClase_VigaCargaDistribuida2D;

% Otros
Modelo_Tarea2;
Modelo_Tarea3;
Modelo_Tarea4;
Modelo_Tarea5;
Modelo_TareaComputacionalAntiguo4;
Modelo_TareaComputacional4;
Test_Viga2D;

% Elimina espacio en memoria
clear all; %#ok<CLALL>