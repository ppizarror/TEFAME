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
%| Clase CargaViga2DDistribuida                                         |
%|                                                                      |
%| Este archivo contiene la definicion de la ClaseCargaViga2DDistribuida|
%| CargaViga2DDistribuida es una subclase de la clase Carga ycorresponde|
%| a la representacion de una carga distribuida en un elemento tipo Viga|
%|                                                                      |
%| La clase CargaViga2DDistribuida es una clase que contiene el elemento|
%| al que se le va a aplicar la carga, las cargas en cada punto y las   |
%| distancias de las dos cargas.                                        |
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
%       obj = CargaViga2DDistribuida(etiquetaCarga,elemObjeto,carga1,distancia1,carga2,distancia2)
%       aplicarCarga(obj,factorDeCarga)
%       disp(obj)
%  Methods SuperClass (Carga):
%       masa = obtenerMasa(obj)
%       definirFactorUnidadMasa(obj,factor)
%       definirFactorCargaMasa(obj,factor)
%       nodos = obtenerNodos(obj)
%  Methods SuperClass (ComponenteModelo):
%       etiqueta = obtenerEtiqueta(obj)
%       e = equals(obj,obj)
%       objID = obtenerIDObjeto(obj)

classdef CargaViga2DDistribuida < CargaEstatica
    
    properties(Access = private)
        carga1 % Valor de la carga 1
        carga2 % Valor de la carga 2
        dist1 % Distancia de la carga 1 al primer nodo del elemento
        dist2 % Distancia de la carga 2 al primer nodo del elemento
        elemObj % Variable que guarda el elemento que se le va a aplicar la carga
    end % private properties CargaViga2DDistribuida
    
    methods(Access = public)
        
        function obj = CargaViga2DDistribuida(etiquetaCarga, ...
                elemObjeto, carga1, distancia1, carga2, distancia2)
            % CargaViga2DDistribuida: es el constructor de la clase CargaViga2DDistribuida
            %
            % Crea un objeto de la clase Carga, en donde toma como atributo
            % el objeto a aplicar la carga, las cargas y las distancias de
            % aplicacion (en porcentaje con respecto al largo)
            
            if nargin == 0
                etiquetaCarga = '';
                elemObjeto = [];
                carga1 = 0;
                distancia1 = 0;
                carga2 = 0;
                distancia2 = 0;
            end
            
            % Llamamos al constructor de la SuperClass que es la clase Carga
            obj = obj@CargaEstatica(etiquetaCarga);
            
            if ~isa(elemObjeto, 'Viga2D')
                error('Objeto de la carga no es una Viga2D @CargaViga2DDistribuida %s', etiquetaCarga);
            end
            
            % Aplica limites al minimo y maximo
            if (distancia1 < 0 || distancia1 > 1 || distancia2 > 1 || distancia2 < 0)
                error('Distancias deben estar dentro del rango [0, 1] @CargaViga2DDistribuida %s', etiquetaCarga);
            end
            if (distancia1 == distancia2)
                error('Distancias son iguales @CargaViga2DDistribuida %s', etiquetaCarga);
            end
            distancia1 = max(0, min(distancia1, 1));
            distancia2 = min(1, max(distancia2, 0));
            
            % Guarda los valores
            obj.carga1 = carga1;
            obj.carga2 = carga2;
            obj.dist1 = distancia1 * elemObjeto.obtenerLargo();
            obj.dist2 = distancia2 * elemObjeto.obtenerLargo();
            obj.elemObj = elemObjeto;
            obj.nodosCarga = elemObjeto.obtenerNodos();
            
        end % CargaViga2DDistribuida constructor
        
        function [v1, v2, theta1, theta2] = calcularCarga(obj)
            % calcularCarga: Calcula la carga
            
            % Largo de la viga
            L = obj.elemObj.obtenerLargo();
            
            % Limites de las cargas
            d1 = obj.dist1;
            d2 = obj.dist2;
            
            % Cargas
            P1 = obj.carga1;
            P2 = obj.carga2;
            
            % Crea funcion de carga distribuida
            rho = @(x) P1 + (x - d1) * ((P2 - P1) / d2);
            
            % Funciones de interpolacion
            N1 = @(x) 1 - 3 * (x / L).^2 + 2 * (x / L).^3;
            N2 = @(x) x .* (1 - x / L).^2;
            N3 = @(x) 3 * (x / L).^2 - 2 * (x / L).^3;
            N4 = @(x) ((x.^2) / L) .* (x / L - 1);
            
            % Calcula cada valor
            v1 = integral(@(x) rho(x).*N1(x), d1, d2);
            theta1 = integral(@(x) rho(x).*N2(x), d1, d2);
            v2 = integral(@(x) rho(x).*N3(x), d1, d2);
            theta2 = integral(@(x) rho(x).*N4(x), d1, d2);
            
        end % calcularCarga function
        
        function masa = obtenerMasa(obj)
            % obtenerMasa: Obtiene la masa asociada a la carga
            
            [v1, v2, ~, ~] = obj.calcularCarga();
            masa = abs(v1+v2) .* (obj.factorCargaMasa * obj.factorUnidadMasa);
            
        end % obtenerMasa function
        
        function aplicarCarga(obj, factorDeCarga)
            % aplicarCarga: es un metodo de la clase obj que se usa para aplicar
            % la carga sobre los dos nodos del elemento
            
            % Calcula la carga
            [v1, v2, theta1, theta2] = obj.calcularCarga();
            vectorCarga1 = factorDeCarga * [0, v1, theta1]';
            vectorCarga2 = factorDeCarga * [0, v2, theta2]';
            obj.elemObj.sumarFuerzaEquivalente( ...
                [vectorCarga1(2), vectorCarga1(3), vectorCarga2(2), vectorCarga2(3)]');
            
            % Aplica vectores de carga
            nodos = obj.elemObj.obtenerNodos();
            nodos{1}.agregarCarga(vectorCarga1);
            nodos{2}.agregarCarga(vectorCarga2);
            
        end % aplicarCarga function
        
        function disp(obj)
            % disp: es un metodo de la clase CargaViga2DDistribuida que se usa para
            % imprimir en el command Window la informacion de la carga aplicada
            % sobre el elemento
            %
            % Imprime la informacion guardada en la carga distribuida de la
            % Viga (obj) en pantalla
            
            fprintf('Propiedades carga viga distribuida 2D:\n');
            disp@CargaEstatica(obj);
            
            % Obtiene la etiqueta del elemento
            etiqueta = obj.elemObj.obtenerEtiqueta();
            
            % Obtiene la etiqueta del primer nodo
            nodosetiqueta = obj.elemObj.obtenerNodos();
            nodo1etiqueta = nodosetiqueta{1}.obtenerEtiqueta();
            nodo2etiqueta = nodosetiqueta{2}.obtenerEtiqueta();
            
            fprintf('\tCarga distribuida: %.3f en %.3f hasta %.3f en %.3f entre los Nodos: %s y %s del Elemento: %s\n', ...
                obj.carga1, obj.dist1, obj.carga2, ...
                obj.dist2, nodo1etiqueta, nodo2etiqueta, etiqueta);
            [v1, v2, t1, t2] = obj.calcularCarga();
            fprintf('\tCarga (v1, t1, v2, t2):\t[%.3f, %.3f, %.3f, %.3f]\n', ...
                v1, t1, v2, t2);
            dispMetodoTEFAME();
            
        end % disp function
        
    end % public methods CargaViga2DDistribuida
    
end % class CargaViga2DDistribuida