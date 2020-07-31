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
%| Clase CargaVigaColumna2DDistribuida                                  |
%|                                                                      |
%| Este archivo contiene la definicion de la Clase CargaVigaColumnaDist |
%| ribuida, CargaViga2DDistribuida es una subclase de la clase Carga y  |
%| corresponde a la representacion de una carga distribuida en un       |
%| elemento tipo Viga. La clase CargaViga2DDistribuida es una clase que |
%| contiene el elemento, al que se le va a aplicar la carga, las cargas |
%| en cada punto, las distancias de las dos cargas y el angulo con      |
%| respecto a la normal.                                                |
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
%       obj = CargaVigaColumna2DDistribuida(etiquetaCarga,elemObjeto,carga1,carga2,theta)
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

classdef CargaVigaColumna2DDistribuida < CargaEstatica
    
    properties(Access = private)
        carga1 % Valor de la carga 1
        carga2 % Valor de la carga 2
        elemObj % Variable que guarda el elemento que se le va a aplicar la carga
        theta % Angulo de la carga
    end % private properties CargaVigaColumna2DDistribuida
    
    methods(Access = public)
        
        function obj = CargaVigaColumna2DDistribuida(etiquetaCarga, ...
                elemObjeto, carga1, carga2, theta)
            % CargaVigaColumna2DDistribuida: es el constructor de la clase CargaVigaColumna2DDistribuida
            %
            % Crea un objeto de la clase Carga, en donde toma como atributo
            % el objeto a aplicar la carga, las cargas en el inicio y fin del elemento,
            % y el angulo de la carga con respecto a la normal
            % (0=Completamente normal, pi/2=Carga axial a la viga)
            
            % Si no se pasan argumentos se crea una carga vacia
            if nargin == 0
                carga1 = 0;
                carga2 = 0;
                elemObjeto = [];
                etiquetaCarga = '';
                theta = 0;
            end
            if ~exist('theta', 'var')
                theta = 0;
            end
            
            if ~isa(elemObjeto, 'VigaColumna2D')
                error('Objeto de la carga no es una VigaColumna2D @CargaVigaColumna2DDistribuida %s', etiquetaCarga);
            end
            
            % Llamamos al constructor de la SuperClass que es la clase
            % CargaEstatica
            obj = obj@CargaEstatica(etiquetaCarga);
            
            % Guarda los valores
            obj.carga1 = carga1;
            obj.carga2 = carga2;
            obj.elemObj = elemObjeto;
            obj.nodosCarga = elemObjeto.obtenerNodos();
            obj.theta = theta;
            
        end % CargaVigaColumna2DDistribuida constructor
        
        function [u1, u2, v1, v2, theta1, theta2] = calcularCarga(obj)
            % calcularCarga: Calcula la carga
            
            % Largo de la viga
            L = obj.elemObj.obtenerLargo();   
            
            % Angulo de la carga
            ang = obj.theta;
            
            % Cargas normales
            P1 = obj.carga1 * cos(ang);
            P2 = obj.carga2 * cos(ang);
            
            % Cargas axiales
            H1 = obj.carga1 * sin(ang);
            H2 = obj.carga2 * sin(ang);
            
            % Crea funcion de carga distribuida normal y axial
            rhoV = @(x) P1 + x * ((P2 - P1) / L);
            rhoH = @(x) H1 + x * ((H2 - H1) / L);
            
            % Funciones de interpolacion
            Nu1 = @(x) (1 - x / L);
            Nu2 = @(x) x / L;
            Nv1 = @(x) 1 - 3 * (x / L).^2 + 2 * (x / L).^3;
            Nv2 = @(x) x .* (1 - x / L).^2;
            Nv3 = @(x) 3 * (x / L).^2 - 2 * (x / L).^3;
            Nv4 = @(x) ((x.^2) / L) .* (x / L - 1);
            
            % Calcula cada valor
            u1 = integral(@(x) rhoH(x).*Nu1(x), 0, L);
            u2 = integral(@(x) rhoH(x).*Nu2(x), 0, L);
            v1 = integral(@(x) rhoV(x).*Nv1(x), 0, L);
            v2 = integral(@(x) rhoV(x).*Nv3(x), 0, L);
            theta1 = integral(@(x) rhoV(x).*Nv2(x), 0, L);
            theta2 = integral(@(x) rhoV(x).*Nv4(x), 0, L);
            
        end % calcularCarga function
        
        function masa = obtenerMasa(obj)
            % obtenerMasa: Obtiene la masa asociada a la carga
            
            [u1, u2, v1, v2, ~, ~] = obj.calcularCarga();
            masa = abs(u1+u2+v1+v2) .* (obj.factorCargaMasa * obj.factorUnidadMasa);
            
        end % obtenerMasa function
        
        function aplicarCarga(obj, factorDeCarga)
            % aplicarCarga: es un metodo de la clase obj
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
            % disp: es un metodo de la clase Carga que se usa para imprimir en
            % command Window la informacion de la carga aplicada sobre el
            % elemento
            %
            % Imprime la informacion guardada en la carga viga-columna distribuida
            % (obj) en pantalla
            
            fprintf('Propiedades carga viga-columna distribuida 2D:\n');
            disp@CargaEstatica(obj);
            
            % Obtiene la etiqueta del elemento
            etiqueta = obj.elemObj.obtenerEtiqueta();
            
            % Obtiene la etiqueta del primer nodo
            nodosetiqueta = obj.elemObj.obtenerNodos();
            nodo1etiqueta = nodosetiqueta{1}.obtenerEtiqueta();
            nodo2etiqueta = nodosetiqueta{2}.obtenerEtiqueta();
            
            % Obtiene cargas horizontales y verticales
            ang = obj.theta;
            P1 = obj.carga1 * cos(ang);
            P2 = obj.carga2 * cos(ang);
            H1 = obj.carga1 * sin(ang);
            H2 = obj.carga2 * sin(ang);
            
            fprintf('\tCarga distribuida entre los Nodos: %s y %s del Elemento: %s\n', ...
                nodo1etiqueta, nodo2etiqueta, etiqueta);
            fprintf('\t\tComponente NORMAL:\t%.3f hasta %.3f\n', P1, P2);
            fprintf('\t\tComponente AXIAL:\t%.3f hasta %.3f\n', H1, H2);
            [u1, u2, v1, v2, t1, t2] = obj.calcularCarga();
            fprintf('\tCarga (u1,v1,t1,u2,v2,t2):\t[%.3f, %.3f, %.3f, %.3f, %.3f, %.3f]\n', ...
                u1, v1, t1, u2, v2, t2);
            dispMetodoTEFAME();
            
        end % disp function
        
    end % public methods CargaVigaColumna2DDistribuida
    
end % class CargaVigaColumna2DDistribuida