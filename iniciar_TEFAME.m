% ______________________________________________________________________
%|                                                                      |
%|               Iniciar_TEFAME - Inicia la libreria TEFAME             |
%|                                                                      |
%|                   Area  de Estructuras y Geotecnia                   |
%|                   Departamento de Ingenieria Civil                   |
%|              Facultad de Ciencias Fisicas y Matematicas              |
%|                         Universidad de Chile                         |
%|                                                                      |
%| Desarrollado por:                                                    |
%|       Pablo Pizarro R. @ppizarror.com                                |
%|       Estudiante de Magister en Ingenieria Civil Estructural         |
%|       Universidad de Chile                                           |
%|______________________________________________________________________|

TEFAME_ver = 'v0.50';

% Agrega las carpetas de la plataforma TEFAME al PATH
addpath('Programa_TEFAME');
addpath('Programa_TEFAME/Analisis_Lib');
addpath('Programa_TEFAME/Modelo_Lib');
addpath('Programa_TEFAME/Modelo_Lib/Base_Lib');
addpath('Programa_TEFAME/Modelo_Lib/Cargas_Lib');
addpath('Programa_TEFAME/Modelo_Lib/Elementos_Lib');
addpath('Programa_TEFAME/Modelo_Lib/Nodo_Lib');
addpath('Programa_TEFAME/Modelo_Lib/Restricciones_Lib');

% Agrega los test al path
addpath('test');
addpath('test/estatico');
addpath('test/modal');