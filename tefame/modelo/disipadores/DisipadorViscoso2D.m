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
%       Keq
%       Ceq
%       dx
%       dy
%       L
%       theta
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
        Keq % Modulo de elasticidad
        Ce % Parametro
        Ceq % Inercia de la seccion
        dx % Distancia en el eje x entre los nodos
        dy % Distancia en el eje y entre los nodos
        L % Largo del elemento
        theta % Angulo de inclinacion del disipador
        Klp % Matriz de rigidez local del elemento
        alpha % Paramatro del disipador
        Cd % Parametro del disipador
        w % Frecuencia del modo que controla la estructura
        Vo % Desp
        v0 % Desp
    end % properties DisipadorViscoso2D
    
    methods
        
        function disipadorViscoso2DObj = DisipadorViscoso2D(etiquetaDisipador, nodo1Obj, nodo2Obj, Cd, alpha)
            % DisipadorViscoso2D: Constructor de la clase, genera un
            % disipador viscoso en 2D
            %
            % disipadorViscoso2DObj = DisipadorViscoso2D(etiquetaDisipador,nodo1Obj,nodo2Obj,Cd,alpha)
            
            % Completa con ceros si no hay argumentos
            if nargin == 0
                etiquetaDisipador = '';
            end % if
            
            % Llamamos al constructor de la SuperClass que es la clase Disipador2D
            disipadorViscoso2DObj = disipadorViscoso2DObj@Disipador2D(etiquetaDisipador);
            
            % Guarda material
            disipadorViscoso2DObj.nodosObj = {nodo1Obj; nodo2Obj};
            disipadorViscoso2DObj.alpha = alpha;
            disipadorViscoso2DObj.Ce = [];
            disipadorViscoso2DObj.Cd = Cd;
            disipadorViscoso2DObj.w = 1;
            disipadorViscoso2DObj.v0 = 1;
            
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
        
        function k_local = obtenerMatrizRigidezCoordLocal(disipadorViscoso2DObj)
            % obtenerMatrizRigidezCoordLocal: Obtiene la matriz de rigidez
            % en coordenadas locales
            %
            % k_local = obtenerMatrizRigidezCoordLocal(disipadorViscoso2DObj)
            
            % Retorna la matriz calculada en el constructor
            k_local = disipadorViscoso2DObj.Klp;
            
        end % obtenerMatrizRigidezCoordLocal function
        
        function c_local = obtenerMatrizAmortiguamientoCoordLocal(disipadorViscoso2DObj)
            % obtenerMatrizAmortiguamientoCoordLocal: Obtiene la matriz de
            % armortiguamiento en coordenadas locales
            %
            % c_local = obtenerMatrizAmortiguamientoCoordLocal(disipadorViscoso2DObj)
            
            alfa = disipadorViscoso2DObj.alpha;
            disipadorViscoso2DObj.Ce = disipadorViscoso2DObj.Cd .* (4 * gamma(alfa+2)) / ...
                (2^(alfa + 2) * (gamma(alfa/2+3/2))^2) * disipadorViscoso2DObj.w^(alfa - 1) * ...
                disipadorViscoso2DObj.v0^(alfa - 1);
            c_local = disipadorViscoso2DObj.Ce .* [1, -1; -1, 1];
            
        end % obtenerMatrizAmortiguamientoCoordLocal function
        
        function actualizarDisipador(disipadorViscoso2DObj, w, carga)
            % actualizarDisipador: Actualiza el disipador con la carga y la
            % frecuencia
            %
            % actualizarDisipador(disipadorViscoso2DObj,w,carga)
            
            disipadorViscoso2DObj.w = w;
            disipadorViscoso2DObj.v0 = disipadorViscoso2DObj.calcularv0(disipadorViscoso2DObj.nodosObj, carga);
            
        end % actualizarDisipador function
        
        function disp(disipadorViscoso2DObj)
            % disp: Imprime propiedades del disipador viscoso
            %
            % disp(disipadorViscoso2DObj)
            
            fprintf('Propiedades Disipador Viscoso 2D:\n\t');
            disp@ComponenteModelo(disipadorViscoso2DObj);
            
            fprintf('-------------------------------------------------\n');
            fprintf('\n');
            
        end % disp function
        
    end % methods DisipadorViscoso2D
    
end % class DisipadorViscoso2D