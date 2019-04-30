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
%       DisipadorFriccionalPuro2DObj = DisipadorFriccionalPuro2D(etiquetaDisipador,nodo1Obj,nodo2Obj,Cd,alpha)
%       numeroNodos = obtenerNumeroNodos(DisipadorFriccionalPuro2DObj)
%       nodosBiela = obtenerNodos(DisipadorFriccionalPuro2DObj)
%       numeroGDL = obtenerNumeroGDL(DisipadorFriccionalPuro2DObj)
%       gdlIDBiela = obtenerGDLID(DisipadorFriccionalPuro2DObj)
%       k_global = obtenerMatrizRigidezCoordGlobal(DisipadorFriccionalPuro2DObj)
%       k_local = obtenerMatrizRigidezCoordLocal(DisipadorFriccionalPuro2DObj)
%       fr_global = obtenerFuerzaResistenteCoordGlobal(DisipadorFriccionalPuro2DObj)
%       fr_local = obtenerFuerzaResistenteCoordLocal(DisipadorFriccionalPuro2DObj)
%       l = obtenerLargo(DisipadorFriccionalPuro2DObj)
%       T = obtenerMatrizTransformacion(DisipadorFriccionalPuro2DObj)
%       definirGDLID(DisipadorFriccionalPuro2DObj)
%       disp(DisipadorFriccionalPuro2DObj)
%       plot(DisipadorFriccionalPuro2DObj,tipoLinea,grosorLinea,colorLinea)
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
        Vo
        w
    end % properties DisipadorFriccionalPuro2D
    
    methods
        
        function DisipadorFriccionalPuro2DObj = DisipadorFriccionalPuro2D(etiquetaDisipador, nodo1Obj, nodo2Obj, Fy)
            % DisipadorFriccionalPuro2D: Constructor de la clase, genera un
            % disipador viscoso en 2D
            %
            % DisipadorFriccionalPuro2DObj = DisipadorFriccionalPuro2D(etiquetaDisipador,nodo1Obj,nodo2Obj,Cd,alpha)
            
            % Completa con ceros si no hay argumentos
            if nargin == 0
                etiquetaDisipador = '';
            end % if
            
            % Llamamos al constructor de la SuperClass que es la clase Disipador2D
            DisipadorFriccionalPuro2DObj = DisipadorFriccionalPuro2DObj@Disipador2D(etiquetaDisipador);
            
            % Guarda material
            DisipadorFriccionalPuro2DObj.nodosObj = {nodo1Obj; nodo2Obj};
            DisipadorFriccionalPuro2DObj.Fy = Fy;
            DisipadorFriccionalPuro2DObj.gdlID = [];
            DisipadorFriccionalPuro2DObj.w = [];
            DisipadorFriccionalPuro2DObj.Vo = [];
            
            % Calcula componentes geometricas
            coordNodo1 = nodo1Obj.obtenerCoordenadas();
            coordNodo2 = nodo2Obj.obtenerCoordenadas();
            DisipadorFriccionalPuro2DObj.dx = abs(coordNodo2(1)-coordNodo1(1));
            DisipadorFriccionalPuro2DObj.dy = abs(coordNodo2(2)-coordNodo1(2));
            DisipadorFriccionalPuro2DObj.L = sqrt(DisipadorFriccionalPuro2DObj.dx^2+DisipadorFriccionalPuro2DObj.dy^2);
            theta = atan(DisipadorFriccionalPuro2DObj.dy/DisipadorFriccionalPuro2DObj.dx);
            DisipadorFriccionalPuro2DObj.theta = theta;
            
            % Calcula matriz de transformacion dado el angulo
            cosx = DisipadorFriccionalPuro2DObj.dx / DisipadorFriccionalPuro2DObj.L;
            cosy = DisipadorFriccionalPuro2DObj.dy / DisipadorFriccionalPuro2DObj.L;
            DisipadorFriccionalPuro2DObj.T = [cosx, cosy, 0, 0, 0, 0; 0, 0, 0, cosx, cosy, 0];
            
           
        end % DisipadorFriccionalPuro2D constructor
        
        function numeroNodos = obtenerNumeroNodos(DisipadorFriccionalPuro2DObj) %#ok<MANU>
            % obtenerNumeroNodos: Obtiene el numero de modos del disipador
            %
            % numeroNodos = obtenerNumeroNodos(DisipadorFriccionalPuro2DObj)
            
            numeroNodos = 2;
            
        end % obtenerNumeroNodos function
        
        function nodosDisipador = obtenerNodos(DisipadorFriccionalPuro2DObj)
            % nodosDisipador: Obtiene los nodos del disipador
            %
            % nodosDisipador = obtenerNodos(DisipadorFriccionalPuro2DObj)
            
            nodosDisipador = DisipadorFriccionalPuro2DObj.nodosObj;
            
        end % obtenerNodos function
        
        function numeroGDL = obtenerNumeroGDL(DisipadorFriccionalPuro2DObj) %#ok<MANU>
            % obtenerNumeroGDL: Retorna el numero de grados de libertad del
            % disipador
            %
            % numeroGDL = obtenerNumeroGDL(DisipadorFriccionalPuro2DObj)
            
            numeroGDL = 4;
            
        end % obtenerNumeroGDL function
        
        function gdlIDDisipador = obtenerGDLID(DisipadorFriccionalPuro2DObj)
            % obtenerGDLID: Obtiene los ID de los grados de libertad del
            % disipador
            %
            % gdlIDDisipador = obtenerGDLID(DisipadorFriccionalPuro2DObj)
            
            gdlIDDisipador = DisipadorFriccionalPuro2DObj.gdlID;
            
        end % obtenerNumeroGDL function
        
        function T = obtenerMatrizTransformacion(DisipadorFriccionalPuro2DObj)
            % obtenerMatrizTransformacion: Obtiene la matriz de
            % transformacion del disipador
            %
            % T = obtenerMatrizTransformacion(DisipadorFriccionalPuro2DObj)
            
            T = DisipadorFriccionalPuro2DObj.T;
            
        end % obtenerMatrizTransformacion function
        
        function actualizardisipador(DisipadorFriccionalPuro2DObj, w, Vo)
            
            DisipadorFriccionalPuro2DObj.w = w;
            DisipadorFriccionalPuro2DObj.Vo = Vo;

            
        end
        
        function k_global = obtenerMatrizRigidezCoordGlobal(DisipadorFriccionalPuro2DObj)
            % obtenerMatrizRigidezCoordGlobal: Obtiene la matriz de rigidez
            % en coordenadas globales
            %
            % k_global = obtenerMatrizRigidezCoordGlobal(DisipadorFriccionalPuro2DObj)
            
            % Multiplica por la matriz de transformacion
            k_local = DisipadorFriccionalPuro2DObj.obtenerMatrizRigidezCoordLocal();
            t_theta = DisipadorFriccionalPuro2DObj.obtenerMatrizTransformacion();
            k_global = t_theta' * k_local * t_theta;
            
        end % obtenerMatrizRigidezCoordGlobal function
        
        function k_local = obtenerMatrizRigidezCoordLocal(DisipadorFriccionalPuro2DObj)
            % obtenerMatrizRigidezCoordLocal: Obtiene la matriz de rigidez
            % en coordenadas locales
            %
            % k_local = obtenerMatrizRigidezCoordLocal(DisipadorFriccionalPuro2DObj)
            
           
            % Retorna la matriz calculada en el constructor
            k_local = 0 .* [1 -1; -1 1];
            
        end % obtenerMatrizRigidezCoordLocal function
        
        function c_local = obtenerMatrizAmortiguamientoCoordLocal(DisipadorFriccionalPuro2DObj)
            % obtenerMatrizAmortiguamientoCoordLocal: Obtiene la matriz de
            % armortiguamiento en coordenadas locales
            %
            % c_local = obtenerMatrizAmortiguamientoCoordLocal(DisipadorFriccionalPuro2DObj)
            
            DisipadorFriccionalPuro2DObj.Ce = 4 * DisipadorFriccionalPuro2DObj.Fy /(pi() * w * Vo);
            
            c_local = DisipadorFriccionalPuro2DObj.Ce .* [1, -1; -1, 1];
            
            
        end % obtenerMatrizAmortiguamientoCoordLocal function
        
        function c_global = obtenerMatrizAmortiguamientoCoordGlobal(DisipadorFriccionalPuro2DObj)
            % obtenerMatrizAmortiguamientoCoordGlobal: Obtiene la matriz de
            % amortiguamiento en coordenadas globales
            %
            % c_global = obtenerMatrizAmortiguamientoCoordGlobal(DisipadorFriccionalPuro2DObj)
            
            % Multiplica por la matriz de transformacion
            c_local = DisipadorFriccionalPuro2DObj.obtenerMatrizAmortiguamientoCoordLocal();
            t_theta = DisipadorFriccionalPuro2DObj.obtenerMatrizTransformacion();
            c_global = t_theta' * c_local * t_theta;
            
        end % obtenerMatrizAmortiguamientoCoordGlobal function
        
        function definirGDLID(DisipadorFriccionalPuro2DObj)
            % definirGDLID: Define los GDLID del disipador
            %
            % definirGDLID(DisipadorFriccionalPuro2DObj)
            
            % Se obtienen los nodos extremos
            nodo1 = DisipadorFriccionalPuro2DObj.nodosObj{1};
            nodo2 = DisipadorFriccionalPuro2DObj.nodosObj{2};
            
            % Se obtienen los gdl de los nodos
            gdlnodo1 = nodo1.obtenerGDLID();
            gdlnodo2 = nodo2.obtenerGDLID();
            
            % Se establecen gdl
            gdl = [0, 0, 0, 0];
            gdl(1) = gdlnodo1(1);
            gdl(2) = gdlnodo1(2);
            gdl(3) = gdlnodo2(1);
            gdl(4) = gdlnodo2(2);
            DisipadorFriccionalPuro2DObj.gdlID = gdl;
            
        end % definirGDLID function
        
        function plot(DisipadorFriccionalPuro2DObj, deformadas, tipoLinea, grosorLinea, colorLinea)
            % plot: Grafica el disipador
            %
            % plot(DisipadorFriccionalPuro2DObj,deformadas,tipoLinea,grosorLinea,colorLinea)
            
            coord1 = DisipadorFriccionalPuro2DObj.nodosObj{1}.obtenerCoordenadas();
            coord2 = DisipadorFriccionalPuro2DObj.nodosObj{2}.obtenerCoordenadas();
            coord1 = coord1 + deformadas{1}(1:2);
            coord2 = coord2 + deformadas{2}(1:2);
            dibujarDisipador(DisipadorFriccionalPuro2DObj, coord1, coord2, tipoLinea, grosorLinea, colorLinea)
            
        end % plot function
        
        function disp(DisipadorFriccionalPuro2DObj)
            
            % Imprime propiedades del disipador viscoso
            fprintf('Propiedades Disipador Viscoso 2D:\n\t');
            disp@ComponenteModelo(DisipadorFriccionalPuro2DObj);
            
            fprintf('-------------------------------------------------\n');
            fprintf('\n');
            
        end % disp function
        
    end % methods DisipadorFriccionalPuro2D
    
end % class DisipadorFriccionalPuro2D