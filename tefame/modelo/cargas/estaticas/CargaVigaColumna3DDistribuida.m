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
%| Clase CargaVigaColumna3DDistribuida                                  |
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
%       obj = CargaVigaColumna3DDistribuida(etiquetaCarga,elemObjeto,px1,px2,py1,py2,pz1,pz2)
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

classdef CargaVigaColumna3DDistribuida < CargaEstatica
    
    properties(Access = private)
        px1 % Valor de la carga distribuida eje x en el inicio del elemento
        py1 % Valor de la carga distribuida eje y en el inicio del elemento
        pz1 % Valor de la carga distribuida eje z en el inicio del elemento
        px2 % Valor de la carga distribuida eje x en el termino del elemento
        py2 % Valor de la carga distribuida eje y en el termino del elemento
        pz2 % Valor de la carga distribuida eje z en el termino del elemento
        elemObj % Variable que guarda el elemento que se le va a aplicar la carga
    end % private properties CargaVigaColumna3DDistribuida
    
    methods(Access = public)
        
        function obj = CargaVigaColumna3DDistribuida(etiquetaCarga, elemObjeto, px1, px2, py1, py2, pz1, pz2)
            % CargaVigaColumna3DDistribuida: es el constructor de la clase CargaVigaColumna3DDistribuida
            %
            % Crea un objeto de la clase Carga, en donde toma como atributo
            % el objeto a aplicar la carga, las cargas en los ejes x, y, z
            % globales.
            
            % Si no se pasan argumentos se crea una carga vacia
            if nargin == 0
                px1 = 0;
                py1 = 0;
                pz1 = 0;
                px2 = 0;
                py2 = 0;
                pz2 = 0;
                elemObjeto = [];
                etiquetaCarga = '';
            end
            
            if ~isa(elemObjeto, 'VigaColumna3D')
                error('Objeto de la carga no es una VigaColumna3D @CargaVigaColumna3DDistribuida %s', etiquetaCarga);
            end
            
            % Llamamos al constructor de la SuperClass que es la clase
            % CargaEstatica
            obj = obj@CargaEstatica(etiquetaCarga);
            
            % Guarda los valores
            obj.px1 = px1;
            obj.py1 = py1;
            obj.pz1 = pz1;
            obj.px2 = px2;
            obj.py2 = py2;
            obj.pz2 = pz2;
            obj.elemObj = elemObjeto;
            obj.nodosCarga = elemObjeto.obtenerNodos();
            
        end % CargaVigaColumna3DDistribuida constructor
        
        function [v11, v12, v13, v21, v22, v23, m11, m12, m13, m21, m22, m23] = calcularCarga(obj)
            % calcularCarga: Calcula la carga. Y retorna un vector con
            % cargas aplicadas en v (axial) 1,2,3 en el nodo 1/2. Y los
            % momentos.
            
            % Largo de la viga
            L = obj.elemObj.obtenerLargo();
            
            % Funciones de interpolacion
            Nu1 = @(x) (1 - x / L);
            Nu2 = @(x) x / L;
            Nv1 = @(x) 1 - 3 * (x / L).^2 + 2 * (x / L).^3;
            Nv2 = @(x) x .* (1 - x / L).^2;
            Nv3 = @(x) 3 * (x / L).^2 - 2 * (x / L).^3;
            Nv4 = @(x) ((x.^2) / L) .* (x / L - 1);
            
            px = @(x) obj.px1 + x * ((obj.px2 - obj.px1) / L);
            py = @(x) obj.py1 + x * ((obj.py2 - obj.py1) / L);
            pz = @(x) obj.pz1 + x * ((obj.pz2 - obj.pz1) / L);
            
            % Calcula cada valor
            v11 = integral(@(x) px(x).*Nu1(x), 0, L);
            v12 = integral(@(x) py(x).*Nv1(x), 0, L);
            v13 = integral(@(x) pz(x).*Nv1(x), 0, L);
            m11 = 0;
            m12 = -integral(@(x) pz(x).*Nv2(x), 0, L);
            m13 = integral(@(x) py(x).*Nv2(x), 0, L);
            v21 = integral(@(x) px(x).*Nu2(x), 0, L);
            v22 = integral(@(x) py(x).*Nv3(x), 0, L);
            v23 = integral(@(x) pz(x).*Nv3(x), 0, L);
            m21 = 0;
            m22 = -integral(@(x) pz(x).*Nv4(x), 0, L);
            m23 = integral(@(x) py(x).*Nv4(x), 0, L);
            
        end % calcularCarga function
        
        function masa = obtenerMasa(obj)
            % obtenerMasa: Obtiene la masa asociada a la carga
            
            [v11, v12, v13, v21, v22, v23, ~, ~, ~, ~, ~, ~] = obj.calcularCarga();
            masa = abs(v11+v12+v13+v21+v22+v23) .* (obj.factorCargaMasa * obj.factorUnidadMasa);
            
        end % obtenerMasa function
        
        function aplicarCarga(obj, factorDeCarga)
            % aplicarCarga: es un metodo de la clase obj
            % que se usa para aplicar la carga sobre los dos nodos del elemento
            
            % Calcula la carga
            [v11, v12, v13, v21, v22, v23, m11, m12, m13, m21, m22, m23] = obj.calcularCarga();
            vectorCarga = factorDeCarga * [v11, v12, v13, m11, m12, m13, v21, v22, v23, m21, m22, m23]';
            obj.elemObj.sumarFuerzaEquivalente(vectorCarga);
            
            % Aplica vectores de carga en coordenadas globales
            vectorCarga = obj.elemObj.obtenerMatrizTransformacion()' * vectorCarga;
            nodos = obj.elemObj.obtenerNodos();
            nodos{1}.agregarCarga([vectorCarga(1), vectorCarga(2), vectorCarga(3), vectorCarga(4), vectorCarga(5), vectorCarga(6)]');
            nodos{2}.agregarCarga([vectorCarga(7), vectorCarga(8), vectorCarga(9), vectorCarga(10), vectorCarga(11), vectorCarga(12)]');
            
        end % aplicarCarga function
        
        function disp(obj)
            % disp: es un metodo de la clase Carga que se usa para imprimir en
            % command Window la informacion de la carga aplicada sobre el
            % elemento
            %
            % Imprime la informacion guardada en la carga viga-columna distribuida
            % (obj) en pantalla
            
            fprintf('Propiedades carga viga-columna distribuida 3D:\n');
            disp@CargaEstatica(obj);
            
            % Obtiene la etiqueta del elemento
            etiqueta = obj.elemObj.obtenerEtiqueta();
            
            % Obtiene la etiqueta del primer nodo
            nodosetiqueta = obj.elemObj.obtenerNodos();
            nodo1etiqueta = nodosetiqueta{1}.obtenerEtiqueta();
            nodo2etiqueta = nodosetiqueta{2}.obtenerEtiqueta();
            
            % Obtiene cargas horizontales y verticales
            fprintf('\tCarga distribuida entre los Nodos: %s y %s del Elemento: %s\n', ...
                nodo1etiqueta, nodo2etiqueta, etiqueta);
            [v11, v12, v13, v21, v22, v23, m11, m12, m13, m21, m22, m23] = obj.calcularCarga();
            fprintf('\tCarga (v11, v12, v13, m11, m12, m13, v21, v22, v23, m21, m22, m23):\n\t\t[%.3f, %.3f, %.3f, %.3f, %.3f, %.3f, %.3f, %.3f, %.3f, %.3f, %.3f, %.3f]\n', ...
                v11, v12, v13, m11, m12, m13, v21, v22, v23, m21, m22, m23);
            dispMetodoTEFAME();
            
        end % disp function
        
    end % public methods CargaVigaColumna3DDistribuida
    
end % class CargaVigaColumna3DDistribuida