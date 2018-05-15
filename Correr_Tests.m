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
%| so de An�lisis Matricial de Estructuras CI5211-1 semestre Oto�o 2018 |
%|                                                                      |
%| Los tests implementados hasta la fecha exploran las tareas num�ricas |
%| y los ejemplos vistos en clase (material docente) con el fin de eva- |
%| luar los resultados num�ricos entregados por las funciones implemen- |
%| tadas.                                                               |
%|                                                                      |
%| Desarrollado por:                                                    |
%|       Pablo Pizarro R. @ppizarror.com                                |
%|       Estudiante de Ingenier�a Civil en Construcci�n-Estructuras     |
%|       Estudiante Magister en Ciencias de la Computaci�n              |
%|       Universidad de Chile                                           |
%|______________________________________________________________________|
%|                                                                      |
%| Para ejecutar la tarea se debe a�adir la carpeta 'Programa_TEFAME'   |
%| al PATH de Matlab. Luego se debe ejecutar este script. Autom�tica-   |
%| mente se a�adir� la carpeta 'test' al path para poder correr cada    |
%| uno de los tests. Los resultados son almacenados en la carpeta       |
%| 'output' ubicada en directorio ra�z.                                 |
%|______________________________________________________________________|

% A�ade carpetas al PATH
iniciar_TEFAME;
addpath('test');

% Inicia los tests
clc;
fprintf('CORRIENDO TESTS\n');

% C�digo tarea 3
Modelo_Tarea3;

% Ejemplos clase
EjemploClase_Enrejado2D;
EjemploClase_Viga2D;
EjemploClase_VigaCargaDistribuida2D;

% Otros
Modelo_Tarea2;
Test_Viga2D;

% Elimina espacio en memoria
clear all; %#ok<CLALL>