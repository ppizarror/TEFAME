% ______________________________________________________________________
%|                                                                      |
%|           TEFAME - Toolbox para Elemento Finitos y Analisis          |
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
%| La plataforma es desarrollada en  propagacion orientada a objetos en |
%| MATLAB.                                                              |
%|______________________________________________________________________|
% ______________________________________________________________________
%|                                                                      |
%| Clase DisipadorTriangular2D                                          |
%|                                                                      |
%| Este archivo contiene la definicion de la Clase DisipadorTriangular2D|
%| es una  subclase de la clase Disipador2D y corresponde a la represe- |
%| ntacion de un disipador triangular planar                            |
%|                                                                      |
%| Programado: Pablo Pizarro @ppizarror.com                             |
%| Fecha: 29/04/2019                                                    |
%|______________________________________________________________________|
%
%  Properties (Access=private):
%       nodosObj
%       gdlID
%       Keq
%       Ceq
%       dx
%       dy
%       L
%       theta
%       T
%       Klp
%       alpha
%       Cd
%  Methods:
%       disipadorTriangular2DObj = DisipadorTriangular2D(etiquetaDisipador,nodo1Obj,nodo2Obj,k1,k2)
%       numeroNodos = obtenerNumeroNodos(disipadorTriangular2DObj)
%       nodosBiela = obtenerNodos(disipadorTriangular2DObj)
%       numeroGDL = obtenerNumeroGDL(disipadorTriangular2DObj)
%       gdlIDBiela = obtenerGDLID(disipadorTriangular2DObj)
%       k_global = obtenerMatrizRigidezCoordGlobal(disipadorTriangular2DObj)
%       k_local = obtenerMatrizRigidezCoordLocal(disipadorTriangular2DObj)
%       fr_global = obtenerFuerzaResistenteCoordGlobal(disipadorTriangular2DObj)
%       fr_local = obtenerFuerzaResistenteCoordLocal(disipadorTriangular2DObj)
%       l = obtenerLargo(disipadorTriangular2DObj)
%       T = obtenerMatrizTransformacion(disipadorTriangular2DObj)
%       definirGDLID(disipadorTriangular2DObj)
%       disp(disipadorTriangular2DObj)
%       plot(disipadorTriangular2DObj,tipoLinea,grosorLinea,colorLinea)
%       actualizarDisipador(disipadorTriangular2DObj,w,carga)
%  Methods SuperClass (ComponenteModelo):
%       etiqueta = obtenerEtiqueta(componenteModeloObj)

classdef DisipadorTriangular2D < Disipador2D
    
    properties(Access = private)
        Keq % Modulo de elasticidad
        Ceq % Inercia de la seccion
        Ce % Ponderacion matriz de amortiguamiento
        dx % Distancia en el eje x entre los nodos
        dy % Distancia en el eje y entre los nodos
        L % Largo del elemento
        theta % Angulo de inclinacion del disipador
        k1 % Paramatro de rigidez del disipador
        k2 % Paramatro de rigidez del disipador
        ke % Parametro del disipador
        w % Frecuencia que mas mueve energia en la estructura
        v0 % Desplazamiento relativo del disipador
    end % properties DisipadorTriangular2D
    
    methods
        
        function disipadorTriangular2DObj = DisipadorTriangular2D(etiquetaDisipador, nodo1Obj, nodo2Obj, k1, k2)
            % DisipadorTriangular2D: Constructor de la clase, genera un
            % disipador triangular en 2D
            %
            % disipadorTriangular2DObj = DisipadorTriangular2D(etiquetaDisipador,nodo1Obj,nodo2Obj,k1,k2)
            
            % Completa con ceros si no hay argumentos
            if nargin == 0
                etiquetaDisipador = '';
            end % if
            
            % Llamamos al constructor de la SuperClass que es la clase Disipador2D
            disipadorTriangular2DObj = disipadorTriangular2DObj@Disipador2D(etiquetaDisipador);
            
            % Guarda material
            disipadorTriangular2DObj.nodosObj = {nodo1Obj; nodo2Obj};
            disipadorTriangular2DObj.k1 = k1;
            disipadorTriangular2DObj.k2 = k2;
            disipadorTriangular2DObj.v0 = 1;
            disipadorTriangular2DObj.w = 1;
            
            % Calcula componentes geometricas
            coordNodo1 = nodo1Obj.obtenerCoordenadas();
            coordNodo2 = nodo2Obj.obtenerCoordenadas();
            disipadorTriangular2DObj.dx = abs(coordNodo2(1)-coordNodo1(1));
            disipadorTriangular2DObj.dy = abs(coordNodo2(2)-coordNodo1(2));
            disipadorTriangular2DObj.L = sqrt(disipadorTriangular2DObj.dx^2+disipadorTriangular2DObj.dy^2);
            theta = atan(disipadorTriangular2DObj.dy/disipadorTriangular2DObj.dx);
            disipadorTriangular2DObj.theta = theta;
            
            % Calcula matriz de transformacion dado el angulo
            cosx = disipadorTriangular2DObj.dx / disipadorTriangular2DObj.L;
            cosy = disipadorTriangular2DObj.dy / disipadorTriangular2DObj.L;
            disipadorTriangular2DObj.T = [cosx, cosy, 0, 0, 0, 0; 0, 0, 0, cosx, cosy, 0];
            
        end % DisipadorTriangular2D constructor
        
        function actualizarDisipador(disipadorTriangular2DObj, w, carga)
            % actualizarDisipador: Actualiza el disipador con la carga y la
            % frecuencia
            %
            % actualizarDisipador(disipadorTriangular2DObj,w,carga)
            
            disipadorTriangular2DObj.w = w;
            disipadorTriangular2DObj.v0 = disipadorTriangular2DObj.calcularv0(disipadorTriangular2DObj.nodosObj, carga);
            
        end % actualizarDisipador function
        
        function k_local = obtenerMatrizRigidezCoordLocal(disipadorTriangular2DObj)
            % obtenerMatrizRigidezCoordLocal: Obtiene la matriz de rigidez
            % en coordenadas locales
            %
            % k_local = obtenerMatrizRigidezCoordLocal(disipadorTriangular2DObj)
            
            disipadorTriangular2DObj.ke = (disipadorTriangular2DObj.k1 + disipadorTriangular2DObj.k2) / 2;
            k_local = disipadorTriangular2DObj.ke .* [1, -1; -1, 1];
            
        end % obtenerMatrizRigidezCoordLocal function
        
        function c_local = obtenerMatrizAmortiguamientoCoordLocal(disipadorTriangular2DObj)
            % obtenerMatrizAmortiguamientoCoordLocal: Obtiene la matriz de
            % armortiguamiento en coordenadas locales
            %
            % c_local = obtenerMatrizAmortiguamientoCoordLocal(disipadorTriangular2DObj)
            
            disipadorTriangular2DObj.Ce = (disipadorTriangular2DObj.k1 - disipadorTriangular2DObj.k2) / ...
                (pi() * disipadorTriangular2DObj.w);
            c_local = disipadorTriangular2DObj.Ce .* [1, -1; -1, 1];
            
        end % obtenerMatrizAmortiguamientoCoordLocal function
        
        function disp(disipadorTriangular2DObj)
            % disp: Imprime propiedades del disipador triangular
            %
            % disp(disipadorTriangular2DObj)
            
            fprintf('Propiedades Disipador Triangular 2D:\n\t');
            disp@ComponenteModelo(disipadorTriangular2DObj);
            
            fprintf('-------------------------------------------------\n');
            fprintf('\n');
            
        end % disp function
        
    end % methods DisipadorTriangular2D
    
end % class DisipadorTriangular2D