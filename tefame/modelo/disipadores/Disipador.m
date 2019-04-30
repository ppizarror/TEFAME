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
%| Clase Disipador                                                      |
%|                                                                      |
%| Este archivo contiene la definicion general de la clase disipador.   |
%|                                                                      |
%| Programado: Pablo Pizarro @ppizarror.com                             |
%| Fecha: 29/04/2019                                                    |
%|______________________________________________________________________|
%
%  Properties (Access=private):
%  Methods:
%       disipadorObj = Disipador(etiquetaDisipador)
%       numeroNodos = obtenerNumeroNodos(disipadorObj)
%       numeroGDL = obtenerNumeroGDL(disipadorObj)
%       gdlIDDisipador = obtenerGDLID(disipadorObj)
%       k_global = obtenerMatrizRigidezCoordGlobal(disipadorObj)
%       k_local = obtenerMatrizRigidezCoordLocal(disipadorObj)
%       fr_global = obtenerFuerzaResistenteCoordGlobal(disipadorObj)
%       fr_local = obtenerFuerzaResistenteCoordLocal(disipadorObj)
%       T = obtenerMatrizTransformacion(disipadorObj)
%       definirGDLID(disipadorObj)
%       disp(disipadorObj)
%       plot(disipadorObj,tipoLinea,grosorLinea)
%  Methods SuperClass (ComponenteModelo):
%       etiqueta = obtenerEtiqueta(componenteModeloObj)

classdef Disipador < ComponenteModelo
    
    properties(Access = private)
    end % properties Disipador
    
    methods
        
        function disipadorObj = Disipador(etiquetaDisipador)
            % Disipador: es el constructor de la clase Disipador
            %
            % disipadorObj = Disipador(etiquetaDisipador)
            % Crea un objeto de la clase Disipador, con un identificador unico
            % (etiquetaDisipador)
            
            % Si no se pasan argumentos se crean vacios
            if nargin == 0
                etiquetaDisipador = '';
            end % if
            
            %Llamamos al constructor de la SuperClass que es la clase ComponenteModelo
            disipadorObj = disipadorObj@ComponenteModelo(etiquetaDisipador);
            
        end % Disipador constructor
        
        function numeroNodos = obtenerNumeroNodos(disipadorObj) %#ok<MANU>
            
            numeroNodos = 0;
            
        end % obtenerNumeroNodos function
        
        function nodosDisipador = obtenerNodos(disipadorObj) %#ok<MANU>
            
            nodosDisipador = [];
            
        end % obtenerNodos function
        
        function numeroGDL = obtenerNumeroGDL(disipadorObj) %#ok<MANU>
            
            numeroGDL = 0;
            
        end % obtenerNumeroGDL function
        
        function gdlIDDisipador = obtenerGDLID(disipadorObj) %#ok<MANU>
            
            gdlIDDisipador = [];
            
        end % obtenerNumeroGDL function
        
        function T = obtenerMatrizTransformacion(disipadorObj) %#ok<MANU>
            
            T = [];
            
        end % obtenerNumeroGDL function
        
        function k_global = obtenerMatrizRigidezCoordGlobal(disipadorObj) %#ok<MANU>
            
            k_global = [];
            
        end % obtenerMatrizRigidezGlobal function
        
        function k_local = obtenerMatrizRigidezCoordLocal(disipadorObj) %#ok<MANU>
            
            k_local = [];
            
        end % obtenerMatrizRigidezLocal function
        
        function c_local = obtenerMatrizAmortiguamientoCoordLocal(disipadorObj) %#ok<MANU>
            
            c_local = [];
            
        end % obtenerMatrizRigidezLocal function
        
        function c_global = obtenerMatrizAmortiguamientoCoordGlobal(disipadorObj) %#ok<MANU>
            
            % Multiplica por la matriz de transformacion
            c_global = [];
            
        end % obtenerMatrizRigidezLocal function
        
        function definirGDLID(disipador2D) %#ok<MANU>
            
        end % definirGDLID function
        
        function plot(disipadorObj, tipoLinea, grosorLinea) %#ok<INUSD>
            % plot: Grafica el disipador
            %
            % plot(disipadorObj,tipoLinea,grosorLinea)
            
        end % plot function
        
        function disp(disipadorObj)
            % Imprime propiedades del disipador
            
            disp@ComponenteModelo(disipadorObj);
            
        end % disp function
        
    end % methods Disipador
    
end % class Disipador