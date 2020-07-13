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
%| Clase CargaVigaColumna2DPuntual                                      |
%|                                                                      |
%| Este archivo contiene la definicion de CargaVigaColumna2DPuntual     |
%| CargaVigaColumna2DPuntual es una subclase de la clase Carga y        |
%| corresponde a la representacion de una carga puntual en un elemento  |
%| tipo Viga-Columna.                                                   |
%|                                                                      |
%| La clase CargaVigaColumna2DPuntual es una clase que contiene el      |
%| elemento al al que se le va a aplicar la carga, el valor de esta     |
%| carga, la distancia a uno de los nodos como porcentaje del largo y   |
%| el angulo de aplicacion.                                             |
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
%
%  Methods(Access=public):
%       obj = CargaVigaColumna2DPuntual(etiquetaCarga,elemObjeto,carga,distancia,theta)
%       aplicarCarga(obj,factorDeCarga)
%       disp(obj)
%  Methods SuperClass (CargaEstatica):
%       masa = obtenerMasa(obj)
%       definirFactorUnidadMasa(obj,factor)
%       definirFactorCargaMasa(obj,factor)
%       nodos = obtenerNodos(obj)
%  Methods SuperClass (ComponenteModelo):
%       etiqueta = obtenerEtiqueta(obj)
%       e = equals(obj,obj)
%       objID = obtenerIDObjeto(obj)

classdef CargaVigaColumna2DPuntual < CargaEstatica
    
    properties(Access = private)
        carga % Valor de la carga
        dist % Distancia de la carga al primer nodo del elemento
        elemObj % Variable que guarda el elemento que se le va a aplicar la carga
        theta % Angulo de aplicacion de la carga con respecto a la normal
    end % private properties CargaVigaColumna2DPuntual
    
    methods(Access = public)
        
        function obj = CargaVigaColumna2DPuntual(etiquetaCarga, ...
                elemObjeto, carga, distancia, theta)
            % CargaVigaColumna2DPuntual: es el constructor de la clase CargaVigaColumna2DPuntual
            %
            % Crea un objeto de la clase CargaVigaColumna2DPuntual, en donde toma como atributo
            % el objeto a aplicar la carga, la distancia como porcentaje
            % del largo del elemento con respecto al primer nodo, el
            % elemento tipo viga y el angulo de aplicacion de la carga con respecto a la normal
            
            if nargin == 0
                carga = 0;
                distancia = 0;
                elemObjeto = [];
                etiquetaCarga = '';
                theta = 0;
            end
            
            if ~exist('theta', 'var')
                theta = 0;
            end
            
            if ~isa(elemObjeto, 'VigaColumna2D')
                error('Objeto de la carga no es una VigaColumna2D @CargaVigaColumna2DPuntual %s', etiquetaCarga);
            end
            
            if distancia<0 || distancia>1
                error('Distancia de la carga debe estar dentro del rango [0, 1] @CargaVigaColumna2DPuntual %s', etiquetaCarga);
            end
            
            % Llamamos al constructor de la SuperClass que es la clase Carga
            obj = obj@CargaEstatica(etiquetaCarga);
            
            % Guarda los valores
            obj.carga = carga;
            obj.dist = distancia * elemObjeto.obtenerLargo();
            obj.elemObj = elemObjeto;
            obj.nodosCarga = elemObjeto.obtenerNodos();
            obj.theta = theta;
            
        end % CargaVigaColumna2DPuntual constructor
        
        function [u1, u2, v1, v2, theta1, theta2] = calcularCarga(obj)
            % calcularCarga: Calcula la carga
            
            % Largo de la viga
            L = obj.elemObj.obtenerLargo();
            
            % Posicion de la carga
            d = obj.dist;
            
            % Carga normal
            P = obj.carga * cos(obj.theta);
            
            % Carga axial
            H = -obj.carga * sin(obj.theta);
            
            % Se calculan apoyos y reacciones en un caso de viga empotrada
            % sometida a una carga P aplicada a (L-d) de un apoyo y d del
            % otro. Esto se hizo al no tener la funcion dirac(x) y
            % distintos errores fruto de la evaluacion de la integral
            v1 = P * ((L - d)^2 / L^2) * (3 - 2 * (L - d) / L);
            v2 = P * (d^2 / L^2) * (3 - 2 * d / L);
            theta1 = P * d * (L - d)^2 / (L^2);
            theta2 = -P * (d^2) * (L - d) / (L^2);
            
            % Para el caso de las cargas normales se usan las funciones de
            % interpolacion
            Nu1 = @(x) (1 - x / L);
            Nu2 = @(x) x / L;
            u1 = H * Nu1(d);
            u2 = H * Nu2(d);
            
        end % calcularCarga function
        
        function masa = obtenerMasa(obj)
            % obtenerMasa: Obtiene la masa asociada a la carga
            
            [u1, u2, v1, v2, ~, ~] = obj.calcularCarga();
            masa = abs(u1+u2+v1+v2) .* (obj.factorCargaMasa * obj.factorUnidadMasa);
            
        end % obtenerMasa function
        
        function aplicarCarga(obj, factorDeCarga)
            % aplicarCarga: es un metodo de la clase CargaVigaColumna2DPuntual
            % que se usa para aplicar la carga sobre los dos nodos del elemento
            
            % Calcula la carga
            [u1, u2, v1, v2, theta1, theta2] = obj.calcularCarga();
            vectorCarga = factorDeCarga * [u1, v1, theta1, u2, v2, theta2]';
            obj.elemObj.sumarFuerzaEquivalente(vectorCarga);
            
            % Aplica vectores de carga en coordenadas globales
            vectorCarga = obj.elemObj.obtenerMatrizTransformacion()' * vectorCarga;
            nodos = obj.elemObj.obtenerNodos();
            nodos{1}.agregarCarga([vectorCarga(1), vectorCarga(2), vectorCarga(3)]');
            nodos{2}.agregarCarga([vectorCarga(4), vectorCarga(5), vectorCarga(6)]');
            
        end % aplicarCarga function
        
        function disp(obj)
            % disp: es un metodo de la clase CargaViga2DPuntual que se usa para imprimir en
            % command Window la informacion de la carga aplicada sobre el
            % elemento
            %
            % Imprime la informacion guardada en la carga puntual de la
            % Viga-Columna (obj) en pantalla
            
            fprintf('Propiedades carga viga-columna puntual 2D:\n');
            disp@CargaEstatica(obj);
            
            % Obtiene la etiqueta del elemento
            etiqueta = obj.elemObj.obtenerEtiqueta();
            
            % Obtiene la etiqueta del primer nodo
            nodo1etiqueta = obj.elemObj.obtenerNodos();
            nodo1etiqueta = nodo1etiqueta{1}.obtenerEtiqueta();
            
            % Obtiene cargas axiales y normales
            P = obj.carga * cos(obj.theta);
            H = obj.carga * sin(obj.theta);
            
            fprintf('\tCarga aplicada en Elemento: %s a %.3f del Nodo: %s\n', ...
                etiqueta, obj.dist, nodo1etiqueta);
            fprintf('\t\tComponente NORMAL:\t%.3f\n', P);
            fprintf('\t\tComponente AXIAL:\t%.3f\n', H);
            [u1, u2, v1, v2, t1, t2] = obj.calcularCarga();
            fprintf('\tCarga (u1,v1,t1,u2,v2,t2):\t[%.3f, %.3f, %.3f, %.3f, %.3f, %.3f]\n', ...
                u1, v1, t1, u2, v2, t2);
            dispMetodoTEFAME();
            
        end % disp function
        
    end % public methods CargaVigaColumna2DPuntual
    
end % class CargaVigaColumna2DPuntual