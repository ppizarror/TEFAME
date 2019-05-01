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
%| Clase DisipadorFriccionalPuro2D                                             |
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
%       disipadorFriccionalPuro2DObj = DisipadorFriccionalPuro2D(etiquetaDisipador,nodo1Obj,nodo2Obj,Cd,alpha)
%       numeroNodos = obtenerNumeroNodos(disipadorFriccionalPuro2DObj)
%       nodosBiela = obtenerNodos(disipadorFriccionalPuro2DObj)
%       numeroGDL = obtenerNumeroGDL(disipadorFriccionalPuro2DObj)
%       gdlIDBiela = obtenerGDLID(disipadorFriccionalPuro2DObj)
%       k_global = obtenerMatrizRigidezCoordGlobal(disipadorFriccionalPuro2DObj)
%       k_local = obtenerMatrizRigidezCoordLocal(disipadorFriccionalPuro2DObj)
%       fr_global = obtenerFuerzaResistenteCoordGlobal(disipadorFriccionalPuro2DObj)
%       fr_local = obtenerFuerzaResistenteCoordLocal(disipadorFriccionalPuro2DObj)
%       l = obtenerLargo(disipadorFriccionalPuro2DObj)
%       T = obtenerMatrizTransformacion(disipadorFriccionalPuro2DObj)
%       actualizardDisipador(disipadorFriccionalPuro2DObj,w,carga)
%       definirGDLID(disipadorFriccionalPuro2DObj)
%       disp(disipadorFriccionalPuro2DObj)
%       plot(disipadorFriccionalPuro2DObj,tipoLinea,grosorLinea,colorLinea)
%  Methods SuperClass (ComponenteModelo):
%       etiqueta = obtenerEtiqueta(componenteModeloObj)

classdef DisipadorFriccionalPuro2D < Disipador2D
    
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
        Fy % Paramatro de entrada del disipador
        v0 % Parametro del disipador
        w % Parametro del disipador
    end % properties DisipadorFriccionalPuro2D
    
    methods
        
        function disipadorFriccionalPuro2DObj = DisipadorFriccionalPuro2D(etiquetaDisipador, nodo1Obj, nodo2Obj, Fy)
            % DisipadorFriccionalPuro2D: Constructor de la clase, genera un
            % disipador viscoso en 2D
            %
            % disipadorFriccionalPuro2DObj = DisipadorFriccionalPuro2D(etiquetaDisipador,nodo1Obj,nodo2Obj,Cd,alpha)
            
            % Completa con ceros si no hay argumentos
            if nargin == 0
                etiquetaDisipador = '';
            end % if
            
            % Llamamos al constructor de la SuperClass que es la clase Disipador2D
            disipadorFriccionalPuro2DObj = disipadorFriccionalPuro2DObj@Disipador2D(etiquetaDisipador);
            
            % Guarda material
            disipadorFriccionalPuro2DObj.nodosObj = {nodo1Obj; nodo2Obj};
            disipadorFriccionalPuro2DObj.Fy = Fy;
            disipadorFriccionalPuro2DObj.gdlID = [];
            disipadorFriccionalPuro2DObj.w = 1;
            disipadorFriccionalPuro2DObj.Vo = 1;
            
            % Calcula componentes geometricas
            coordNodo1 = nodo1Obj.obtenerCoordenadas();
            coordNodo2 = nodo2Obj.obtenerCoordenadas();
            disipadorFriccionalPuro2DObj.dx = abs(coordNodo2(1)-coordNodo1(1));
            disipadorFriccionalPuro2DObj.dy = abs(coordNodo2(2)-coordNodo1(2));
            disipadorFriccionalPuro2DObj.L = sqrt(disipadorFriccionalPuro2DObj.dx^2+disipadorFriccionalPuro2DObj.dy^2);
            theta = atan(disipadorFriccionalPuro2DObj.dy/disipadorFriccionalPuro2DObj.dx);
            disipadorFriccionalPuro2DObj.theta = theta;
            
            % Calcula matriz de transformacion dado el angulo
            cosx = disipadorFriccionalPuro2DObj.dx / disipadorFriccionalPuro2DObj.L;
            cosy = disipadorFriccionalPuro2DObj.dy / disipadorFriccionalPuro2DObj.L;
            disipadorFriccionalPuro2DObj.T = [cosx, cosy, 0, 0, 0, 0; 0, 0, 0, cosx, cosy, 0];
            
        end % DisipadorFriccionalPuro2D constructor
        
        function nodosDisipador = obtenerNodos(disipadorFriccionalPuro2DObj)
            % nodosDisipador: Obtiene los nodos del disipador
            %
            % nodosDisipador = obtenerNodos(disipadorFriccionalPuro2DObj)
            
            nodosDisipador = disipadorFriccionalPuro2DObj.nodosObj;
            
        end % obtenerNodos function
        
        function gdlIDDisipador = obtenerGDLID(disipadorFriccionalPuro2DObj)
            % obtenerGDLID: Obtiene los ID de los grados de libertad del
            % disipador
            %
            % gdlIDDisipador = obtenerGDLID(disipadorFriccionalPuro2DObj)
            
            gdlIDDisipador = disipadorFriccionalPuro2DObj.gdlID;
            
        end % obtenerNumeroGDL function
        
        function T = obtenerMatrizTransformacion(disipadorFriccionalPuro2DObj)
            % obtenerMatrizTransformacion: Obtiene la matriz de
            % transformacion del disipador
            %
            % T = obtenerMatrizTransformacion(disipadorFriccionalPuro2DObj)
            
            T = disipadorFriccionalPuro2DObj.T;
            
        end % obtenerMatrizTransformacion function
        
        function actualizarDisipador(disipadorFriccionalPuro2DObj, w, carga)
            % actualizarDisipador: Actualiza el disipador con la carga y la
            % frecuencia
            %
            % actualizarDisipador(disipadorFriccionalPuro2DObj,w,carga)
            
            disipadorFriccionalPuro2DObj.w = w;
            disipadorFriccionalPuro2DObj.v0 = disipadorFriccionalPuro2DObj.calcularv0(disipadorFriccionalPuro2DObj.nodosObj, carga);
            
        end % actualizarDisipador function
        
        function k_global = obtenerMatrizRigidezCoordGlobal(disipadorFriccionalPuro2DObj)
            % obtenerMatrizRigidezCoordGlobal: Obtiene la matriz de rigidez
            % en coordenadas globales
            %
            % k_global = obtenerMatrizRigidezCoordGlobal(disipadorFriccionalPuro2DObj)
            
            % Multiplica por la matriz de transformacion
            k_local = disipadorFriccionalPuro2DObj.obtenerMatrizRigidezCoordLocal();
            t_theta = disipadorFriccionalPuro2DObj.obtenerMatrizTransformacion();
            k_global = t_theta' * k_local * t_theta;
            
        end % obtenerMatrizRigidezCoordGlobal function
        
        function k_local = obtenerMatrizRigidezCoordLocal(disipadorFriccionalPuro2DObj) %#ok<MANU>
            % obtenerMatrizRigidezCoordLocal: Obtiene la matriz de rigidez
            % en coordenadas locales
            %
            % k_local = obtenerMatrizRigidezCoordLocal(disipadorFriccionalPuro2DObj)
            
            % Retorna la matriz calculada en el constructor
            k_local = 0 .* [1, -1; -1, 1];
            
        end % obtenerMatrizRigidezCoordLocal function
        
        function c_local = obtenerMatrizAmortiguamientoCoordLocal(disipadorFriccionalPuro2DObj)
            % obtenerMatrizAmortiguamientoCoordLocal: Obtiene la matriz de
            % armortiguamiento en coordenadas locales
            %
            % c_local = obtenerMatrizAmortiguamientoCoordLocal(disipadorFriccionalPuro2DObj)
            
            disipadorFriccionalPuro2DObj.Ce = 4 * disipadorFriccionalPuro2DObj.Fy / (pi() * disipadorFriccionalPuro2DObj.w * disipadorFriccionalPuro2DObj.v0);
            c_local = disipadorFriccionalPuro2DObj.Ce .* [1, -1; -1, 1];
            
        end % obtenerMatrizAmortiguamientoCoordLocal function
        
        function c_global = obtenerMatrizAmortiguamientoCoordGlobal(disipadorFriccionalPuro2DObj)
            % obtenerMatrizAmortiguamientoCoordGlobal: Obtiene la matriz de
            % amortiguamiento en coordenadas globales
            %
            % c_global = obtenerMatrizAmortiguamientoCoordGlobal(disipadorFriccionalPuro2DObj)
            
            % Multiplica por la matriz de transformacion
            c_local = disipadorFriccionalPuro2DObj.obtenerMatrizAmortiguamientoCoordLocal();
            t_theta = disipadorFriccionalPuro2DObj.obtenerMatrizTransformacion();
            c_global = t_theta' * c_local * t_theta;
            
        end % obtenerMatrizAmortiguamientoCoordGlobal function
        
        function definirGDLID(disipadorFriccionalPuro2DObj)
            % definirGDLID: Define los GDLID del disipador
            %
            % definirGDLID(disipadorFriccionalPuro2DObj)
            
            % Se obtienen los nodos extremos
            nodo1 = disipadorFriccionalPuro2DObj.nodosObj{1};
            nodo2 = disipadorFriccionalPuro2DObj.nodosObj{2};
            
            % Se obtienen los gdl de los nodos
            gdlnodo1 = nodo1.obtenerGDLID();
            gdlnodo2 = nodo2.obtenerGDLID();
            
            % Se establecen gdl
            gdl = [0, 0, 0, 0];
            gdl(1) = gdlnodo1(1);
            gdl(2) = gdlnodo1(2);
            gdl(3) = gdlnodo2(1);
            gdl(4) = gdlnodo2(2);
            disipadorFriccionalPuro2DObj.gdlID = gdl;
            
        end % definirGDLID function
        
        function plot(disipadorFriccionalPuro2DObj, deformadas, tipoLinea, grosorLinea, colorLinea)
            % plot: Grafica el disipador
            %
            % plot(disipadorFriccionalPuro2DObj,deformadas,tipoLinea,grosorLinea,colorLinea)
            
            coord1 = disipadorFriccionalPuro2DObj.nodosObj{1}.obtenerCoordenadas();
            coord2 = disipadorFriccionalPuro2DObj.nodosObj{2}.obtenerCoordenadas();
            coord1 = coord1 + deformadas{1}(1:2);
            coord2 = coord2 + deformadas{2}(1:2);
            dibujarDisipador(disipadorFriccionalPuro2DObj, coord1, coord2, tipoLinea, grosorLinea, colorLinea)
            
        end % plot function
        
        function disp(disipadorFriccionalPuro2DObj)
            
            % Imprime propiedades del disipador viscoso
            fprintf('Propiedades Disipador Viscoso 2D:\n\t');
            disp@ComponenteModelo(disipadorFriccionalPuro2DObj);
            
            fprintf('-------------------------------------------------\n');
            fprintf('\n');
            
        end % disp function
        
    end % methods DisipadorFriccionalPuro2D
    
end % class DisipadorFriccionalPuro2D