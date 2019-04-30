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
%| Clase DisipadorViscoso2D                                             |
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
%       disipadorViscoso2DObj = DisipadorViscoso2D(etiquetaDisipador,nodo1Obj,nodo2Obj,Cd,alpha)
%       numeroNodos = obtenerNumeroNodos(disipadorViscoso2DObj)
%       nodosBiela = obtenerNodos(disipadorViscoso2DObj)
%       numeroGDL = obtenerNumeroGDL(disipadorViscoso2DObj)
%       gdlIDBiela = obtenerGDLID(disipadorViscoso2DObj)
%       k_global = obtenerMatrizRigidezCoordGlobal(disipadorViscoso2DObj)
%       k_local = obtenerMatrizRigidezCoordLocal(disipadorViscoso2DObj)
%       fr_global = obtenerFuerzaResistenteCoordGlobal(disipadorViscoso2DObj)
%       fr_local = obtenerFuerzaResistenteCoordLocal(disipadorViscoso2DObj)
%       l = obtenerLargo(disipadorViscoso2DObj)
%       T = obtenerMatrizTransformacion(disipadorViscoso2DObj)
%       definirGDLID(disipadorViscoso2DObj)
%       disp(disipadorViscoso2DObj)
%       plot(disipadorViscoso2DObj,tipoLinea,grosorLinea,colorLinea)
%  Methods SuperClass (ComponenteModelo):
%       etiqueta = obtenerEtiqueta(componenteModeloObj)

classdef DisipadorViscoso2D < Disipador2D
    
    properties(Access = private)
        nodosObj % Cell con los nodos
        gdlID % Lista con los ID de los grados de libertad
        Keq % Modulo de elasticidad
        Ceq % Inercia de la seccion
        dx % Distancia en el eje x entre los nodos
        dy % Distancia en el eje y entre los nodos
        L % Largo del elemento
        theta % Angulo de inclinacion del disipador
        T % Matriz de transformacion
        Klp % Matriz de rigidez local del elemento
        alpha % Paramatro del disipador
        Cd % Parametro del disipador
    end % properties DisipadorViscoso2D
    
    methods
        
        function disipadorViscoso2DObj = DisipadorViscoso2D(etiquetaDisipador, nodo1Obj, nodo2Obj, Cd, alpha)
            
            % Completa con ceros si no hay argumentos
            if nargin == 0
                etiquetaDisipador = '';
            end % if
            
            % Llamamos al constructor de la SuperClass que es la clase Disipador2D
            disipadorViscoso2DObj = disipadorViscoso2DObj@Disipador2D(etiquetaDisipador);
            
            % Guarda material
            disipadorViscoso2DObj.nodosObj = {nodo1Obj; nodo2Obj};
            disipadorViscoso2DObj.alpha = alpha;
            disipadorViscoso2DObj.Cd = Cd;
            disipadorViscoso2DObj.gdlID = [];
            
            % Calcula componentes geometricas
            coordNodo1 = nodo1Obj.obtenerCoordenadas();
            coordNodo2 = nodo2Obj.obtenerCoordenadas();
            disipadorViscoso2DObj.dx = abs(coordNodo2(1)-coordNodo1(1));
            disipadorViscoso2DObj.dy = abs(coordNodo2(2)-coordNodo1(2));
            disipadorViscoso2DObj.L = sqrt(disipadorViscoso2DObj.dx^2+disipadorViscoso2DObj.dy^2);
            theta = atan(disipadorViscoso2DObj.dy/disipadorViscoso2DObj.dx);
            disipadorViscoso2DObj.theta = theta;
            
            % Calcula matriz de transformacion dado el angulo
            cosx = disipadorViscoso2DObj.dx / disipadorViscoso2DObj.L;
            cosy = disipadorViscoso2DObj.dy / disipadorViscoso2DObj.L;
            disipadorViscoso2DObj.T = [cosx, cosy, 0, 0, 0, 0; 0, 0, 0, cosx, cosy, 0];
            
            % Calcula matriz de rigidez local
            Klp = 0.001 .* eye(2);
            disipadorViscoso2DObj.Klp = Klp;
            
        end % DisipadorViscoso2D constructor
        
        function numeroNodos = obtenerNumeroNodos(disipadorViscoso2DObj) %#ok<MANU>
            
            numeroNodos = 2;
            
        end % obtenerNumeroNodos function
        
        function nodosDisipador = obtenerNodos(disipadorViscoso2DObj)
            
            nodosDisipador = disipadorViscoso2DObj.nodosObj;
            
        end % obtenerNodos function
        
        function numeroGDL = obtenerNumeroGDL(disipadorViscoso2DObj) %#ok<MANU>
            
            numeroGDL = 4;
            
        end % obtenerNumeroGDL function
        
        function gdlIDDisipador = obtenerGDLID(disipadorViscoso2DObj)
            
            gdlIDDisipador = disipadorViscoso2DObj.gdlID;
            
        end % obtenerNumeroGDL function
        
        function T = obtenerMatrizTransformacion(disipadorViscoso2DObj)
            
            T = disipadorViscoso2DObj.T;
            
        end % obtenerNumeroGDL function
        
        function k_global = obtenerMatrizRigidezCoordGlobal(disipadorViscoso2DObj)
            
            % Multiplica por la matriz de transformacion
            k_local = disipadorViscoso2DObj.obtenerMatrizRigidezCoordLocal();
            t_theta = disipadorViscoso2DObj.obtenerMatrizTransformacion();
            k_global = t_theta' * k_local * t_theta;
            
        end % obtenerMatrizRigidezGlobal function
        
        function k_local = obtenerMatrizRigidezCoordLocal(disipadorViscoso2DObj)
            
            % Retorna la matriz calculada en el constructor
            k_local = disipadorViscoso2DObj.Klp;
            
        end % obtenerMatrizRigidezLocal function
        
        function c_local = obtenerMatrizAmortiguamientoCoordLocal(disipadorViscoso2DObj)
            
            c_local = disipadorViscoso2DObj.Cd .* [1, -1; -1, 1];
            
        end % obtenerMatrizRigidezLocal function
        
        function c_global = obtenerMatrizAmortiguamientoCoordGlobal(disipadorViscoso2DObj)
            
            % Multiplica por la matriz de transformacion
            ceq_local = disipadorViscoso2DObj.obtenerMatrizAmortiguamientoCoordLocal();
            t_theta = disipadorViscoso2DObj.obtenerMatrizTransformacion();
            c_global = t_theta' * ceq_local * t_theta;
            
        end % obtenerMatrizRigidezLocal function
        
        function definirGDLID(disipadorViscoso2DObj)
            
            % Se obtienen los nodos extremos
            nodo1 = disipadorViscoso2DObj.nodosObj{1};
            nodo2 = disipadorViscoso2DObj.nodosObj{2};
            
            % Se obtienen los gdl de los nodos
            gdlnodo1 = nodo1.obtenerGDLID();
            gdlnodo2 = nodo2.obtenerGDLID();
            
            % Se establecen gdl
            gdl = [0, 0, 0, 0];
            gdl(1) = gdlnodo1(1);
            gdl(2) = gdlnodo1(2);
            gdl(3) = gdlnodo2(1);
            gdl(4) = gdlnodo2(2);
            disipadorViscoso2DObj.gdlID = gdl;
            
        end % definirGDLID function
        
        function plot(disipadorViscoso2DObj, deformadas, tipoLinea, grosorLinea, colorLinea)
            % plot: Grafica el disipador
            %
            % plot(disipadorViscoso2DObj,deformadas,tipoLinea,grosorLinea,colorLinea)
            
            coord1 = disipadorViscoso2DObj.nodosObj{1}.obtenerCoordenadas();
            coord2 = disipadorViscoso2DObj.nodosObj{2}.obtenerCoordenadas();
            coord1 = coord1 + deformadas{1}(1:2);
            coord2 = coord2 + deformadas{2}(1:2);
            dibujarDisipador(disipadorViscoso2DObj, coord1, coord2, tipoLinea, grosorLinea, colorLinea)
            
        end % plot function
        
        function disp(disipadorViscoso2DObj)
            
            % Imprime propiedades del disipador viscoso
            fprintf('Propiedades disipador viscoso 2D:\n\t');
            disp@ComponenteModelo(disipadorViscoso2DObj);
            
            fprintf('-------------------------------------------------\n');
            fprintf('\n');
            
        end % disp function
        
    end % methods DisipadorViscoso2D
    
end % class DisipadorViscoso2D