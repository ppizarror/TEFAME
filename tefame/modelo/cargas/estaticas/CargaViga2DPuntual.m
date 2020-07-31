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
%| Clase CargaViga2DPuntual                                             |
%|                                                                      |
%| Este archivo contiene la definicion de la Clase CargaViga2DPuntual   |
%| CargaViga2DPuntual es una subclase de la clase CargaEstatica y       |
%| corresponde a la representacion de una carga puntual en un elemento  |
%| tipo Viga.                                                           |
%|                                                                      |
%| La clase CargaViga2DPuntual es una clase que contiene el elemento al |
%| al que se le va a aplicar la carga, el valor de esta carga y la      |
%| distancia a uno de los nodos como porcentaje del largo.              |
%|______________________________________________________________________|
%|                                                                      |
%| MIT License                                                          |
%| Copyright (c) 2018-2020 Pablo Pizarro R @ppizarror.com.              |
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
%       obj = CargaViga2DPuntual(etiquetaCarga,elemObjeto,carga,distancia)
%       aplicarCarga(obj,factorDeCarga)
%       disp(obj)
%  Methods SuperClass (CargaEsatica):
%       masa = obtenerMasa(obj)
%       definirFactorUnidadMasa(obj,factor)
%       definirFactorCargaMasa(obj,factor)
%       nodos = obtenerNodos(obj)
%  Methods SuperClass (ComponenteModelo):
%       etiqueta = obtenerEtiqueta(obj)
%       e = equals(obj,obj)
%       objID = obtenerIDObjeto(obj)

classdef CargaViga2DPuntual < CargaEstatica
    
    properties(Access = private)
        carga % Valor de la carga
        dist % Distancia de la carga al primer nodo del elemento
        elemObj % Variable que guarda el elemento que se le va a aplicar la carga
    end % private properties CargaViga2DPuntual
    
    methods(Access = public)
        
        function obj = CargaViga2DPuntual(etiquetaCarga, elemObjeto, carga, distancia)
            % CargaViga2DPuntual: es el constructor de la clase CargaViga2DPuntual
            %
            % Crea un objeto de la clase CargaViga2DPuntual, en donde toma como atributo
            % el objeto a aplicar la carga, la distancia como porcentaje
            % del largo del elemento con respecto al primer nodo y el
            % elemento tipo viga. En este caso no tiene sentido aplicar un
            % angulo debido a que el elemento en particular no admite
            % cargas horizontales
            
            if nargin == 0
                carga = 0;
                distancia = 0;
                elemObjeto = [];
                etiquetaCarga = '';
            end
            
            if ~isa(elemObjeto, 'Viga2D')
                error('Objeto de la carga no es una Viga2D @CargaViga2DPuntual %s', etiquetaCarga);
            end
            
            if distancia<0 || distancia>1
                error('Distancia de la carga debe estar dentro del rango [0, 1] @CargaViga2DPuntual %s', etiquetaCarga);
            end
            
            % Llamamos al constructor de la SuperClass que es la clase Carga
            obj = obj@CargaEstatica(etiquetaCarga);
            
            % Guarda los valores
            obj.carga = carga;
            obj.dist = distancia * elemObjeto.obtenerLargo();
            obj.elemObj = elemObjeto;
            obj.nodosCarga = elemObjeto.obtenerNodos();
            
        end % CargaViga2DPuntual constructor
        
        function [v1, v2, theta1, theta2] = calcularCarga(obj)
            % calcularCarga: Calcula la carga
            
            % Largo de la viga
            L = obj.elemObj.obtenerLargo();
            
            % Posicion de la carga
            d = obj.dist;
            
            % Carga
            P = obj.carga;
            
            % Se calculan apoyos y reacciones en un caso de viga empotrada
            % sometida a una carga P aplicada a (L-d) de un apoyo y d del
            % otro. Esto se hizo al no tener la funcion dirac(x) y
            % distintos errores fruto de la evaluacion de la integral. El
            % caso con las funciones de interpolacion N1..N4 se realizo
            % correctamente para el caso de la carga distribuida
            v1 = P * ((L - d)^2 / L^2) * (3 - 2 * (L - d) / L);
            v2 = P * (d^2 / L^2) * (3 - 2 * d / L);
            theta1 = P * d * (L - d)^2 / (L^2);
            theta2 = -P * (d^2) * (L - d) / (L^2);
            
        end % calcularCarga function
        
        function masa = obtenerMasa(obj)
            % obtenerMasa: Obtiene la masa asociada a la carga
            
            [v1, v2, ~, ~] = obj.calcularCarga();
            masa = abs(v1+v2) .* (obj.factorCargaMasa * obj.factorUnidadMasa);
            
        end % obtenerMasa function
        
        function aplicarCarga(obj, factorDeCarga)
            % aplicarCarga: es un metodo de la clase CargaViga2DPuntual que se usa para aplicar
            % la carga sobre los dos nodos del elemento
            
            % Calcula la carga
            [v1, v2, theta1, theta2] = obj.calcularCarga();
            vectorCarga1 = factorDeCarga * [0, v1, theta1]';
            vectorCarga2 = factorDeCarga * [0, v2, theta2]';
            obj.elemObj.sumarFuerzaEquivalente([ ...
                vectorCarga1(2), vectorCarga1(3), vectorCarga2(2), vectorCarga2(3)]');
            
            % Aplica vectores de carga
            nodos = obj.elemObj.obtenerNodos();
            nodos{1}.agregarCarga(vectorCarga1);
            nodos{2}.agregarCarga(vectorCarga2);
            
        end % aplicarCarga function
        
        function disp(obj)
            % disp: es un metodo de la clase CargaViga2DPuntual que se usa para imprimir en
            % command Window la informacion de la carga aplicada sobre el
            % elemento
            %
            % Imprime la informacion guardada en la carga puntual de la
            % Viga (obj) en pantalla
            
            fprintf('Propiedades carga viga puntual 2D:\n');
            disp@CargaEstatica(obj);
            
            % Obtiene la etiqueta del elemento
            etiqueta = obj.elemObj.obtenerEtiqueta();
            
            % Obtiene la etiqueta del primer nodo
            nodo1etiqueta = obj.elemObj.obtenerNodos();
            nodo1etiqueta = nodo1etiqueta{1}.obtenerEtiqueta();
            
            fprintf('\tCarga: %.3f aplicada en Elemento: %s a %.3f del Nodo: %s\n', ...
                obj.carga, etiqueta, obj.dist, nodo1etiqueta);
            [v1, v2, t1, t2] = obj.calcularCarga();
            fprintf('\tCarga (v1, t1, v2, t2):\t[%.3f, %.3f, %.3f, %.3f]\n', ...
                v1, t1, v2, t2);
            dispMetodoTEFAME();
            
        end % disp function
        
    end % public methods CargaViga2DPuntual
    
end % class CargaViga2DPuntual