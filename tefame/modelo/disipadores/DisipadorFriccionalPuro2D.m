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
%| Clase DisipadorFriccionalPuro2D                                      |
%|                                                                      |
%| Este archivo contiene la definicion de la Clase DisipadorViscoso 2D  |
%| es una  subclase de la clase Disipador2D y  corresponde a            |
%| la representacion de un disipador viscoso en 2D.                     |
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
%       actualizardDisipador(obj,w,carga)
%       definirGDLID(obj)
%       obj = DisipadorFriccionalPuro2D(etiquetaDisipador,nodo1Obj,nodo2Obj,Cd,alpha)
%       disp(obj)
%       fr_global = obtenerFuerzaResistenteCoordGlobal(obj)
%       fr_local = obtenerFuerzaResistenteCoordLocal(obj)
%       gdlIDBiela = obtenerGDLID(obj)
%       k_global = obtenerMatrizRigidezCoordGlobal(obj)
%       k_local = obtenerMatrizRigidezCoordLocal(obj)
%       l = obtenerLargo(obj)
%       nodosBiela = obtenerNodos(obj)
%       numeroGDL = obtenerNumeroGDL(obj)
%       numeroNodos = obtenerNumeroNodos(obj)
%       plot(obj,tipoLinea,grosorLinea,colorLinea)
%       T = obtenerMatrizTransformacion(obj)
%  Methods SuperClass (ComponenteModelo):
%       etiqueta = obtenerEtiqueta(obj)
%       e = equals(obj,obj)
%       objID = obtenerIDObjeto(obj)

classdef DisipadorFriccionalPuro2D < Disipador2D
    
    properties(Access = private)
        Ce % Ponderacion matriz de amortiguamiento
        Ceq % Inercia de la seccion
        dx % Distancia en el eje x entre los nodos
        dy % Distancia en el eje y entre los nodos
        Fy % Paramatro de entrada del disipador
        Keq % Modulo de elasticidad
        L % Largo del elemento
        theta % Angulo de inclinacion del disipador
        v0 % Parametro del disipador
        Vo % Parametro del disipador
        w % Parametro del disipador
    end % private properties DisipadorFriccionalPuro2D
    
    methods(Access = public)
        
        function obj = DisipadorFriccionalPuro2D(etiquetaDisipador, nodo1Obj, nodo2Obj, Fy)
            % DisipadorFriccionalPuro2D: Constructor de la clase, genera un
            % disipador friccional puro en 2D
            
            % Completa con ceros si no hay argumentos
            if nargin == 0
                etiquetaDisipador = '';
            end
            
            % Llamamos al constructor de la SuperClass que es la clase Disipador2D
            obj = obj@Disipador2D(etiquetaDisipador);
            
            % Guarda material
            obj.Ce = [];
            obj.Fy = Fy;
            obj.nodosObj = {nodo1Obj; nodo2Obj};
            obj.v0 = 1;
            obj.w = 1;
            
            % Calcula componentes geometricas
            coordNodo1 = nodo1Obj.obtenerCoordenadas();
            coordNodo2 = nodo2Obj.obtenerCoordenadas();
            obj.dx = abs(coordNodo2(1)-coordNodo1(1));
            obj.dy = abs(coordNodo2(2)-coordNodo1(2));
            obj.L = sqrt(obj.dx^2+obj.dy^2);
            theta = atan(obj.dy/obj.dx);
            obj.theta = theta;
            
            % Calcula matriz de transformacion dado el angulo
            cosx = obj.dx / obj.L;
            cosy = obj.dy / obj.L;
            obj.T = [cosx, cosy, 0, 0, 0, 0; 0, 0, 0, cosx, cosy, 0];
            
        end % DisipadorFriccionalPuro2D constructor
        
        function actualizarDisipador(obj, w, carga)
            % actualizarDisipador: Actualiza el disipador con la carga y la
            % frecuencia
            
            obj.w = w;
            obj.v0 = obj.calcularv0(obj.nodosObj, carga);
            
        end % actualizarDisipador function
        
        function k_local = obtenerMatrizRigidezCoordLocal(obj) %#ok<MANU>
            % obtenerMatrizRigidezCoordLocal: Obtiene la matriz de rigidez
            % en coordenadas locales
            
            % Retorna la matriz calculada en el constructor
            k_local = 0 .* [1, -1; -1, 1];
            
        end % obtenerMatrizRigidezCoordLocal function
        
        function c_local = obtenerMatrizAmortiguamientoCoordLocal(obj)
            % obtenerMatrizAmortiguamientoCoordLocal: Obtiene la matriz de
            % armortiguamiento en coordenadas locales
            
            obj.Ce = 4 * obj.Fy / (pi() * obj.w * obj.v0);
            c_local = obj.Ce .* [1, -1; -1, 1];
            
        end % obtenerMatrizAmortiguamientoCoordLocal function
        
        function disp(obj)
            % disp: Imprime propiedades del disipador friccional puro
            
            fprintf('Propiedades disipador friccional puro 2D:\n\t');
            disp@ComponenteModelo(obj);
            
            dispMetodoTEFAME();
            
        end % disp function
        
    end % public methods DisipadorFriccionalPuro2D
    
end % class DisipadorFriccionalPuro2D