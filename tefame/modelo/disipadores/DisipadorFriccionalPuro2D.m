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
%| Clase DisipadorFriccionalPuro2D                                      |
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
%       T
%       Klp
%       alpha
%       Cd
%  Methods:
%       actualizardDisipador(disipadorFriccionalPuro2DObj,w,carga)
%       definirGDLID(disipadorFriccionalPuro2DObj)
%       disipadorFriccionalPuro2DObj = DisipadorFriccionalPuro2D(etiquetaDisipador,nodo1Obj,nodo2Obj,Cd,alpha)
%       disp(disipadorFriccionalPuro2DObj)
%       fr_global = obtenerFuerzaResistenteCoordGlobal(disipadorFriccionalPuro2DObj)
%       fr_local = obtenerFuerzaResistenteCoordLocal(disipadorFriccionalPuro2DObj)
%       gdlIDBiela = obtenerGDLID(disipadorFriccionalPuro2DObj)
%       k_global = obtenerMatrizRigidezCoordGlobal(disipadorFriccionalPuro2DObj)
%       k_local = obtenerMatrizRigidezCoordLocal(disipadorFriccionalPuro2DObj)
%       l = obtenerLargo(disipadorFriccionalPuro2DObj)
%       nodosBiela = obtenerNodos(disipadorFriccionalPuro2DObj)
%       numeroGDL = obtenerNumeroGDL(disipadorFriccionalPuro2DObj)
%       numeroNodos = obtenerNumeroNodos(disipadorFriccionalPuro2DObj)
%       plot(disipadorFriccionalPuro2DObj,tipoLinea,grosorLinea,colorLinea)
%       T = obtenerMatrizTransformacion(disipadorFriccionalPuro2DObj)
%  Methods SuperClass (ComponenteModelo):
%       etiqueta = obtenerEtiqueta(componenteModeloObj)
%       e = equals(componenteModeloObj,obj)
%       objID = obtenerIDObjeto(componenteModeloObj)

classdef DisipadorFriccionalPuro2D < Disipador2D
    
    properties(Access = private)
        Keq % Modulo de elasticidad
        Ceq % Inercia de la seccion
        Ce % Ponderacion matriz de amortiguamiento
        dx % Distancia en el eje x entre los nodos
        dy % Distancia en el eje y entre los nodos
        L % Largo del elemento
        theta % Angulo de inclinacion del disipador
        Fy % Paramatro de entrada del disipador
        v0 % Parametro del disipador
        Vo % Parametro del disipador
        w % Parametro del disipador
    end % properties DisipadorFriccionalPuro2D
    
    methods
        
        function disipadorFriccionalPuro2DObj = DisipadorFriccionalPuro2D(etiquetaDisipador, nodo1Obj, nodo2Obj, Fy)
            % DisipadorFriccionalPuro2D: Constructor de la clase, genera un
            % disipador friccional puro en 2D
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
            disipadorFriccionalPuro2DObj.Ce = [];
            disipadorFriccionalPuro2DObj.Fy = Fy;
            disipadorFriccionalPuro2DObj.w = 1;
            disipadorFriccionalPuro2DObj.v0 = 1;
            
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
        
        function actualizarDisipador(disipadorFriccionalPuro2DObj, w, carga)
            % actualizarDisipador: Actualiza el disipador con la carga y la
            % frecuencia
            %
            % actualizarDisipador(disipadorFriccionalPuro2DObj,w,carga)
            
            disipadorFriccionalPuro2DObj.w = w;
            disipadorFriccionalPuro2DObj.v0 = disipadorFriccionalPuro2DObj.calcularv0(disipadorFriccionalPuro2DObj.nodosObj, carga);
            
        end % actualizarDisipador function
        
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
        
        function disp(disipadorFriccionalPuro2DObj)
            % disp: Imprime propiedades del disipador friccional puro
            %
            % disp(disipadorFriccionalPuro2DObj)
            
            fprintf('Propiedades disipador friccional puro 2D:\n\t');
            disp@ComponenteModelo(disipadorFriccionalPuro2DObj);
            
            dispMetodoTEFAME();
            
        end % disp function
        
    end % methods DisipadorFriccionalPuro2D
    
end % class DisipadorFriccionalPuro2D