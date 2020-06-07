%|______________________________________________________________________|
%|                                                                      |
%|               Iniciar_TEFAME - Inicia la libreria TEFAME             |
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

TEFAME_ver = 'v2.00';

% Agrega las carpetas de la plataforma TEFAME al path
addpath('tefame');
addpath('tefame/analisis');
addpath('tefame/analisis/eig');
addpath('tefame/analisis/fft');
addpath('tefame/lib');
addpath('tefame/modelo');
addpath('tefame/modelo/base');
addpath('tefame/modelo/cargas');
addpath('tefame/modelo/cargas/dinamicas');
addpath('tefame/modelo/cargas/estaticas');
addpath('tefame/modelo/cargas/patrones');
addpath('tefame/modelo/disipadores');
addpath('tefame/modelo/elementos');
addpath('tefame/modelo/nodo');
addpath('tefame/modelo/restricciones');
addpath('tefame/utils');

% Agrega los test al path
addpath('test');
addpath('test/estatico');
addpath('test/modal');
addpath('test/personal');