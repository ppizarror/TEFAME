%|______________________________________________________________________|
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

%% Inicia los tests
clc;
fprintf('CORRIENDO TESTS\n');

%% Test modal espectral
Modelo_DinamicaAvanzada;

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