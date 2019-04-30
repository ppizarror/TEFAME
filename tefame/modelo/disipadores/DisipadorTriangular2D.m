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
%| Clase DisipadorTriangular2D                                             |
%|                                                                      |
%| Este archivo contiene la definicion de la Clase DisipadorViscoso 2D  |
%|  es una  subclase de la clase Disipador2D y  corresponde a           |
%| la representacion de un disipador viscoso en 2D.                     |
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
%       disipadorTriangular2DObj = DisipadorTriangular2D(etiquetaDisipador,nodo1Obj,nodo2Obj,Cd,alpha)
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
%  Methods SuperClass (ComponenteModelo):
%       etiqueta = obtenerEtiqueta(componenteModeloObj)

classdef DisipadorTriangular2D < Disipador2D
    
    properties(Access = private)
        nodosObj % Cell con los nodos
        gdlID % Lista con los ID de los grados de libertad
        Keq % Modulo de elasticidad
        Ceq % Inercia de la seccion
        Ce % Ponderacion matriz de amortiguamiento
        dx % Distancia en el eje x entre los nodos
        dy % Distancia en el eje y entre los nodos
        L % Largo del elemento
        theta % Angulo de inclinacion del disipador
        T % Matriz de transformacion
        k1 % Paramatro de rigidez del disipador
        k2 % Paramatro de rigidez del disipador
        ke
        w
    end % properties DisipadorTriangular2D
    
    methods
        
        function disipadorTriangular2DObj = DisipadorTriangular2D(etiquetaDisipador, nodo1Obj, nodo2Obj, k1, k2)
            % DisipadorTriangular2D: Constructor de la clase, genera un
            % disipador viscoso en 2D
            %
            % disipadorTriangular2DObj = DisipadorTriangular2D(etiquetaDisipador,nodo1Obj,nodo2Obj,Cd,alpha)
            
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
            disipadorTriangular2DObj.gdlID = [];
            
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
        
        function numeroNodos = obtenerNumeroNodos(disipadorTriangular2DObj) %#ok<MANU>
            % obtenerNumeroNodos: Obtiene el numero de modos del disipador
            %
            % numeroNodos = obtenerNumeroNodos(disipadorTriangular2DObj)
            
            numeroNodos = 2;
            
        end % obtenerNumeroNodos function
        
        function nodosDisipador = obtenerNodos(disipadorTriangular2DObj)
            % nodosDisipador: Obtiene los nodos del disipador
            %
            % nodosDisipador = obtenerNodos(disipadorTriangular2DObj)
            
            nodosDisipador = disipadorTriangular2DObj.nodosObj;
            
        end % obtenerNodos function
        
        function numeroGDL = obtenerNumeroGDL(disipadorTriangular2DObj) %#ok<MANU>
            % obtenerNumeroGDL: Retorna el numero de grados de libertad del
            % disipador
            %
            % numeroGDL = obtenerNumeroGDL(disipadorTriangular2DObj)
            
            numeroGDL = 4;
            
        end % obtenerNumeroGDL function
        
        function gdlIDDisipador = obtenerGDLID(disipadorTriangular2DObj)
            % obtenerGDLID: Obtiene los ID de los grados de libertad del
            % disipador
            %
            % gdlIDDisipador = obtenerGDLID(disipadorTriangular2DObj)
            
            gdlIDDisipador = disipadorTriangular2DObj.gdlID;
            
        end % obtenerNumeroGDL function
        
        function T = obtenerMatrizTransformacion(disipadorTriangular2DObj)
            % obtenerMatrizTransformacion: Obtiene la matriz de
            % transformacion del disipador
            %
            % T = obtenerMatrizTransformacion(disipadorTriangular2DObj)
            
            T = disipadorTriangular2DObj.T;
            
        end % obtenerMatrizTransformacion function
        
        function actualizardisipador(disipadorTriangular2DObj, w, ~)
            
            disipadorTriangular2DObj.w = w;
            
        end
        
        function k_global = obtenerMatrizRigidezCoordGlobal(disipadorTriangular2DObj)
            % obtenerMatrizRigidezCoordGlobal: Obtiene la matriz de rigidez
            % en coordenadas globales
            %
            % k_global = obtenerMatrizRigidezCoordGlobal(disipadorTriangular2DObj)
            
            % Multiplica por la matriz de transformacion
            k_local = disipadorTriangular2DObj.obtenerMatrizRigidezCoordLocal();
            t_theta = disipadorTriangular2DObj.obtenerMatrizTransformacion();
            k_global = t_theta' * k_local * t_theta;
            
        end % obtenerMatrizRigidezCoordGlobal function
        
        function k_local = obtenerMatrizRigidezCoordLocal(disipadorTriangular2DObj)
            % obtenerMatrizRigidezCoordLocal: Obtiene la matriz de rigidez
            % en coordenadas locales
            %
            % k_local = obtenerMatrizRigidezCoordLocal(disipadorTriangular2DObj)
            
            disipadorTriangular2DObj.ke = (disipadorTriangular2DObj.k1 + disipadorTriangular2DObj.k2)/2;
            
            % Retorna la matriz calculada en el constructor
            k_local = disipadorTriangular2DObj.ke .* [1 -1; -1 1];
            
        end % obtenerMatrizRigidezCoordLocal function
        
        function c_local = obtenerMatrizAmortiguamientoCoordLocal(disipadorTriangular2DObj)
            % obtenerMatrizAmortiguamientoCoordLocal: Obtiene la matriz de
            % armortiguamiento en coordenadas locales
            %
            % c_local = obtenerMatrizAmortiguamientoCoordLocal(disipadorTriangular2DObj)
            
            disipadorTriangular2DObj.Ce = (disipadorTriangular2DObj.k1 - disipadorTriangular2DObj.k2)/...
                (pi()*disipadorTriangular2DObj.w);
            
            c_local = disipadorTriangular2DObj.Ce .* [1, -1; -1, 1];
            
            
        end % obtenerMatrizAmortiguamientoCoordLocal function
        
        function c_global = obtenerMatrizAmortiguamientoCoordGlobal(disipadorTriangular2DObj)
            % obtenerMatrizAmortiguamientoCoordGlobal: Obtiene la matriz de
            % amortiguamiento en coordenadas globales
            %
            % c_global = obtenerMatrizAmortiguamientoCoordGlobal(disipadorTriangular2DObj)
            
            % Multiplica por la matriz de transformacion
            ceq_local = disipadorTriangular2DObj.obtenerMatrizAmortiguamientoCoordLocal();
            t_theta = disipadorTriangular2DObj.obtenerMatrizTransformacion();
            c_global = t_theta' * ceq_local * t_theta;
            
        end % obtenerMatrizAmortiguamientoCoordGlobal function
        
        function definirGDLID(disipadorTriangular2DObj)
            % definirGDLID: Define los GDLID del disipador
            %
            % definirGDLID(disipadorTriangular2DObj)
            
            % Se obtienen los nodos extremos
            nodo1 = disipadorTriangular2DObj.nodosObj{1};
            nodo2 = disipadorTriangular2DObj.nodosObj{2};
            
            % Se obtienen los gdl de los nodos
            gdlnodo1 = nodo1.obtenerGDLID();
            gdlnodo2 = nodo2.obtenerGDLID();
            
            % Se establecen gdl
            gdl = [0, 0, 0, 0];
            gdl(1) = gdlnodo1(1);
            gdl(2) = gdlnodo1(2);
            gdl(3) = gdlnodo2(1);
            gdl(4) = gdlnodo2(2);
            disipadorTriangular2DObj.gdlID = gdl;
            
        end % definirGDLID function
        
        function plot(disipadorTriangular2DObj, deformadas, tipoLinea, grosorLinea, colorLinea)
            % plot: Grafica el disipador
            %
            % plot(disipadorTriangular2DObj,deformadas,tipoLinea,grosorLinea,colorLinea)
            
            coord1 = disipadorTriangular2DObj.nodosObj{1}.obtenerCoordenadas();
            coord2 = disipadorTriangular2DObj.nodosObj{2}.obtenerCoordenadas();
            coord1 = coord1 + deformadas{1}(1:2);
            coord2 = coord2 + deformadas{2}(1:2);
            dibujarDisipador(disipadorTriangular2DObj, coord1, coord2, tipoLinea, grosorLinea, colorLinea)
            
        end % plot function
        
        function disp(disipadorTriangular2DObj)
            
            % Imprime propiedades del disipador viscoso
            fprintf('Propiedades Disipador Viscoso 2D:\n\t');
            disp@ComponenteModelo(disipadorTriangular2DObj);
            
            fprintf('-------------------------------------------------\n');
            fprintf('\n');
            
        end % disp function
        
    end % methods DisipadorTriangular2D
    
end % class DisipadorTriangular2D