% ______________________________________________________________________
%|                                                                      |
%|        Tests - Ejecuta todos los tests de la plataforma TEFAME       |
%|                                                                      |
%|                   Area  de Estructuras y Geotecnia                   |
%|                   Departamento de Ingenieria Civil                   |
%|              Facultad de Ciencias Fisicas y Matematicas              |
%|                         Universidad de Chile                         |
%|                                                                      |
%| Los tests implementados hasta la fecha exploran las tareas numericas |
%| y los ejemplos vistos en clase (material docente) con el fin de eva- |
%| luar los resultados numericos entregados por las funciones implemen- |
%| tadas.                                                               |
%|                                                                      |
%| Desarrollado por:                                                    |
%|       Pablo Pizarro R. @ppizarror.com                                |
%|       Estudiante de Magister en Ingenieria Civil Estructural         |
%|       Universidad de Chile                                           |
%|______________________________________________________________________|
%|                                                                      |
%| Para ejecutar la tarea se debe anadir la carpeta 'Programa_TEFAME'   |
%| al PATH de Matlab. Luego se debe ejecutar este script. Automatica-   |
%| mente se anadira la carpeta 'test' al path para poder correr cada    |
%| uno de los tests. Los resultados son almacenados en la carpeta       |
%| 'output' ubicada en directorio raiz.                                 |
%|______________________________________________________________________|

%% Inicia los tests
clc;
fprintf('CORRIENDO TESTS\n');

%% Test modal espectral
%Modelo_DinamicaAvanzada;

%% Test analisis estatico
Test_Membrana1;
Test_Membrana2;
Test_Membrana3;
Test_MembranaCargaDistribuidaHor;
Test_MembranaCargaDistribuidaVer;

EjemploClase_Enrejado3D;
EjemploClase_Enrejado2D;
EjemploClase_Viga2D;
EjemploClase_VigaCargaDistribuida2D;

Modelo_Tarea2;
Modelo_Tarea3;
Modelo_Tarea4;
Modelo_Tarea5;
Modelo_TareaComputacionalAntiguo4;
Modelo_TareaComputacional4;
Modelo_TareaComputacional5;
Test_Viga2D;