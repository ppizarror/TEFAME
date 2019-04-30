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
%| Clase Disipador2D                                             |
%|                                                                      |
%| Este archivo contiene la definicion de la Clase DisipadorViscoso 2D  |
%|  es una  subclase de la clase Elemento y  corresponde a              |
%| la representacion de un disipador viscoso en 2D.                     |
%|                                                                      |
%| Programado: Pablo Pizarro @ppizarror.com                             |
%| Fecha: 29/04/2019                                                    |
%|______________________________________________________________________|
%
%  Properties (Access=private):
%  Methods:
%       disipador2DObj = Disipador2D(etiquetaDisipador)
%       numeroNodos = obtenerNumeroNodos(disipador2DObj)
%       numeroGDL = obtenerNumeroGDL(disipador2DObj)
%       gdlIDDisipador = obtenerGDLID(disipador2DObj)
%       k_global = obtenerMatrizRigidezCoordGlobal(disipador2DObj)
%       k_local = obtenerMatrizRigidezCoordLocal(disipador2DObj)
%       fr_global = obtenerFuerzaResistenteCoordGlobal(disipador2DObj)
%       fr_local = obtenerFuerzaResistenteCoordLocal(disipador2DObj)
%       T = obtenerMatrizTransformacion(disipador2DObj)
%       definirGDLID(disipador2DObj)
%       disp(disipador2DObj)
%       plot(disipador2DObj,tipoLinea,grosorLinea)
%  Methods SuperClass (ComponenteModelo):
%       etiqueta = obtenerEtiqueta(componenteModeloObj)

classdef Disipador2D < ComponenteModelo
    
    properties(Access = private)
    end % properties Disipador2D
    
    methods
        
        function disipador2DObj = Disipador2D(etiquetaDisipador)
            % Disipador2D: es el constructor de la clase Disipador2D
            %
            % disipador2DObj = Disipador2D(etiquetaDisipador)
            % Crea un objeto de la clase Disipador2D, con un identificador unico
            % (etiquetaDisipador)
            
            % Si no se pasan argumentos se crean vacios
            if nargin == 0
                etiquetaDisipador = '';
            end % if
            
            %Llamamos al constructor de la SuperClass que es la clase ComponenteModelo
            disipador2DObj = disipador2DObj@ComponenteModelo(etiquetaDisipador);
            
        end % Disipador2D constructor
        
        function numeroNodos = obtenerNumeroNodos(disipador2DObj) %#ok<MANU>
            
            numeroNodos = 2;
            
        end % obtenerNumeroNodos function
        
        function nodosDisipador = obtenerNodos(disipador2DObj) %#ok<MANU>
            
            nodosDisipador = [];
            
        end % obtenerNodos function
        
        function numeroGDL = obtenerNumeroGDL(disipador2DObj) %#ok<MANU>
            
            numeroGDL = 6;
            
        end % obtenerNumeroGDL function
        
        function gdlIDDisipador = obtenerGDLID(disipador2DObj) %#ok<MANU>
            
            gdlIDDisipador = [];
            
        end % obtenerNumeroGDL function
        
        function T = obtenerMatrizTransformacion(disipador2DObj) %#ok<MANU>
            
            T = [];
            
        end % obtenerNumeroGDL function
        
        function k_global = obtenerMatrizRigidezCoordGlobal(disipador2DObj) %#ok<MANU>
            
            k_global = [];
            
        end % obtenerMatrizRigidezGlobal function
        
        function k_local = obtenerMatrizRigidezCoordLocal(disipador2DObj) %#ok<MANU>
            
            k_local = [];
            
        end % obtenerMatrizRigidezLocal function
        
        function c_local = obtenerMatrizAmortiguamientoCoordLocal(disipador2DObj) %#ok<MANU>
            
            c_local = [];
            
        end % obtenerMatrizRigidezLocal function
        
        function c_global = obtenerMatrizAmortiguamientoCoordGlobal(disipador2DObj) %#ok<MANU>
            
            % Multiplica por la matriz de transformacion
            c_global = [];
            
        end % obtenerMatrizRigidezLocal function
        
        function definirGDLID(disipador2D) %#ok<MANU>
            
        end % definirGDLID function
        
        function plot(disipador2DObj, tipoLinea, grosorLinea) %#ok<INUSD>
            % plot: Grafica el disipador
            %
            % plot(disipador2DObj,tipoLinea,grosorLinea)
            
        end % plot function
        
        function disp(disipador2DObj)
            % Imprime propiedades del disipador
            
            disp@ComponenteModelo(disipador2DObj);
            
        end % disp function
        
    end % methods Disipador2D
    
end % class Disipador2D