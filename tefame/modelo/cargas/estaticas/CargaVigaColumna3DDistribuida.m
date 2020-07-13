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
%| Clase CargaVigaColumna3DDistribuida                                    |
%|                                                                      |
%| Este archivo contiene la definicion de la Clase CargaVigaColumnaDist |
%| ribuida, CargaViga2DDistribuida es una subclase de la clase Carga y    |
%| corresponde a la representacion de una carga distribuida en un       |
%| elemento tipo Viga. La clase CargaViga2DDistribuida es una clase que   |
%| contiene el elemento, al que se le va a aplicar la carga, las cargas |
%| en cada punto, las distancias de las dos cargas y el angulo con      |
%| respecto a la normal.                                                |
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
%       obj = CargaVigaColumna3DDistribuida(etiquetaCarga,elemObjeto,carga1,
%                                        distancia1,carga2,distancia2,theta)
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
        carga1 % Valor de la carga 1
        carga2 % Valor de la carga 2
        dist1 % Distancia de la carga 1 al primer nodo del elemento (porcentaje del largo)
        dist2 % Distancia de la carga 2 al primer nodo del elemento (porcentaje del largo)
        elemObj % Variable que guarda el elemento que se le va a aplicar la carga
        plano % En que plano se aplica (XZ o XY)
        theta % Angulo de la carga
    end % private properties CargaVigaColumna3DDistribuida
    
    methods(Access = public)
        
        function obj = CargaVigaColumna3DDistribuida(etiquetaCarga, ...
                elemObjeto, plano, carga1, distancia1, carga2, distancia2, theta)
            % CargaVigaColumna3DDistribuida: es el constructor de la clase CargaVigaColumna3DDistribuida
            %
            % Crea un objeto de la clase Carga, en donde toma como atributo
            % el objeto a aplicar la carga, las cargas, las distancias de
            % aplicacion y el angulo de la carga con respecto a la normal
            % (0=Completamente normal, pi/2=Carga axial a la viga)
            %
            % Ademas requiere de la definicion del plano. Se aceptan cargas
            % en XZ o XY en coordenadas locales.
            
            % Si no se pasan argumentos se crea una carga vacia
            if nargin == 0
                carga1 = 0;
                carga2 = 0;
                distancia1 = 0;
                distancia2 = 0;
                elemObjeto = [];
                etiquetaCarga = '';
                plano = 'XZ';
                theta = 0;
            end
            if ~exist('theta', 'var')
                theta = 0;
            end
            if ~(strcmp(plano, 'XY') || strcmp(plano, 'XZ'))
                error('Plano debe ser XY o XZ')
            end
            
            if ~isa(elemObjeto, 'VigaColumna3D')
                error('Objeto de la carga no es una VigaColumna3D @CargaVigaColumna3DDistribuida %s', etiquetaCarga);
            end
            
            % Llamamos al constructor de la SuperClass que es la clase
            % CargaEstatica
            obj = obj@CargaEstatica(etiquetaCarga);
            
            % Aplica limites al minimo y maximo
            if (distancia1 < 0 || distancia1 > 1 || distancia2 > 1 || distancia2 < 0)
                error('Distancias deben estar dentro del rango [0, 1] @CargaVigaColumna3DDistribuida %s', etiquetaCarga);
            end
            if (distancia1 == distancia2)
                error('Distancias son iguales @CargaVigaColumna3DDistribuida %s', etiquetaCarga);
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
            obj.plano = plano;
            obj.theta = theta;
            
        end % CargaVigaColumna3DDistribuida constructor
        
        function [v11, v12, v13, v21, v22, v23, m11, m12, m13, m21, m22, m23] = calcularCarga(obj)
            % calcularCarga: Calcula la carga. Y retorna un vector con
            % cargas aplicadas en v (axial) 1,2,3 en el nodo 1/2. Y los
            % momentos.
            
            % Largo de la viga
            L = obj.elemObj.obtenerLargo();
            
            % Limites de las cargas
            d1 = obj.dist1;
            d2 = obj.dist2;
            
            % Angulo de la carga
            ang = obj.theta;
            
            % Cargas normales
            P1 = obj.carga1 * cos(ang);
            P2 = obj.carga2 * cos(ang);
            
            % Cargas axiales
            H1 = obj.carga1 * sin(ang);
            H2 = obj.carga2 * sin(ang);
            
            % Crea funcion de carga distribuida normal y axial
            rhoV = @(x) P1 + (x - d1) * ((P2 - P1) / d2);
            rhoH = @(x) H1 + (x - d1) * ((H2 - H1) / d2);
            
            % Funciones de interpolacion
            Nu1 = @(x) - (1 - x / L);
            Nu2 = @(x) - x / L;
            Nv1 = @(x) 1 - 3 * (x / L).^2 + 2 * (x / L).^3;
            Nv2 = @(x) x .* (1 - x / L).^2;
            Nv3 = @(x) 3 * (x / L).^2 - 2 * (x / L).^3;
            Nv4 = @(x) ((x.^2) / L) .* (x / L - 1);
            
            % Calcula cada valor
            u1 = integral(@(x) rhoH(x).*Nu1(x), d1, d2);
            u2 = integral(@(x) rhoH(x).*Nu2(x), d1, d2);
            v1 = integral(@(x) rhoV(x).*Nv1(x), d1, d2);
            v2 = integral(@(x) rhoV(x).*Nv3(x), d1, d2);
            theta1 = integral(@(x) rhoV(x).*Nv2(x), d1, d2);
            theta2 = integral(@(x) rhoV(x).*Nv4(x), d1, d2);
            
            v11 = u1;
            v21 = u2;
            if strcmp(obj.plano, 'XZ')
                % OBS: Esto puede refactorizarse y usar un angulo c/r al
                % eje x en vez de utilizar los planos XZ/XY
                v12 = 0;
                v13 = v1;
                v22 = 0;
                v23 = v2;
                m12 = theta1;
                m13 = 0;
                m22 = theta2;
                m23 = 0;
            elseif strcmp(obj.plano, 'XY')
                v12 = v1;
                v13 = 0;
                v22 = v2;
                v23 = 0;
                m12 = 0;
                m13 = theta1;
                m22 = 0;
                m23 = theta2;
            end
            m11 = 0;
            m21 = 0;
            
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
            ang = obj.theta;
            P1 = obj.carga1 * cos(ang);
            P2 = obj.carga2 * cos(ang);
            H1 = obj.carga1 * sin(ang);
            H2 = obj.carga2 * sin(ang);
            a = obj.dist1;
            b = obj.dist2;
            
            fprintf('\tCarga distribuida entre los Nodos: %s y %s del Elemento: %s\n', ...
                nodo1etiqueta, nodo2etiqueta, etiqueta);
            fprintf('\t\tCarga siendo aplicada en plano %s', obj.plano);
            fprintf('\t\tComponente NORMAL:\t%.3f en %.3f hasta %.3f en %.3f\n', P1, a, P2, b);
            fprintf('\t\tComponente AXIAL:\t%.3f en %.3f hasta %.3f en %.3f\n', H1, a, H2, b);
            [v11, v12, v13, v21, v22, v23, m11, m12, m13, m21, m22, m23] = obj.calcularCarga();
            fprintf('\tCarga (v11, v12, v13, m11, m12, m13, v21, v22, v23, m21, m22, m23):\n\t\t[%.3f, %.3f, %.3f, %.3f, %.3f, %.3f, %.3f, %.3f, %.3f, %.3f, %.3f, %.3f]\n', ...
                v11, v12, v13, m11, m12, m13, v21, v22, v23, m21, m22, m23);
            dispMetodoTEFAME();
            
        end % disp function
        
    end % public methods CargaVigaColumna3DDistribuida
    
end % class CargaVigaColumna3DDistribuida