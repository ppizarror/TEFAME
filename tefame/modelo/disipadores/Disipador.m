% ______________________________________________________________________
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
%  Methods(Access=public):
%       definirGDLID(obj)
%       obj = Disipador(etiquetaDisipador)
%       disp(obj)
%       fr_global = obtenerFuerzaResistenteCoordGlobal(obj)
%       fr_local = obtenerFuerzaResistenteCoordLocal(obj)
%       gdlIDDisipador = obtenerGDLID(obj)
%       k_global = obtenerMatrizRigidezCoordGlobal(obj)
%       k_local = obtenerMatrizRigidezCoordLocal(obj)
%       numeroGDL = obtenerNumeroGDL(obj)
%       numeroNodos = obtenerNumeroNodos(obj)
%       plot(obj,tipoLinea,grosorLinea,colorLinea)
%       T = obtenerMatrizTransformacion(obj)
%  Methods SuperClass (ComponenteModelo):
%       etiqueta = obtenerEtiqueta(obj)
%       e = equals(obj,obj)
%       objID = obtenerIDObjeto(obj)

classdef Disipador < ComponenteModelo
    
    properties(Access = private)
    end % private properties Disipador
    
    properties(Access = protected)
        gdlID % Lista con los ID de los grados de libertad
        nodosObj % Cell con los nodos
        T % Matriz de transformacion
    end % protected properties Disipador
    
    methods(Access = public)
        
        function obj = Disipador(etiquetaDisipador)
            % Disipador: es el constructor de la clase Disipador
            %
            % Crea un objeto de la clase Disipador, con un identificador unico
            % (etiquetaDisipador)
            
            % Si no se pasan argumentos se crean vacios
            if nargin == 0
                etiquetaDisipador = '';
            end
            
            % Llamamos al constructor de la SuperClass que es la clase ComponenteModelo
            obj = obj@ComponenteModelo(etiquetaDisipador);
            obj.gdlID = [];
            obj.T = [];
            
        end % Disipador constructor
        
        function inicializar(obj) %#ok<MANU>
            % inicializar: es un metodo de la clase Disipador que se usa para
            % inicializar las diferentes componentes que sean necesario en los
            % disipadores para realizar posteriormente el analisis
            %
            % Inicializa los diferentes componetes del Disipador (obj),
            % para poder preparar estos para realizar el analisis
            
        end % inicializar function
        
        function numeroNodos = obtenerNumeroNodos(obj) %#ok<MANU>
            % obtenerNumeroNodos: Obtiene el numero de nodos del disipador
            
            numeroNodos = 0;
            
        end % obtenerNumeroNodos function
        
        function nodosDisipador = obtenerNodos(obj)
            % nodosDisipador: Obtiene los nodos del disipador
            
            nodosDisipador = obj.nodosObj;
            
        end % obtenerNodos function
        
        function numeroGDL = obtenerNumeroGDL(obj) %#ok<MANU>
            % obtenerNumeroGDL: Retorna el numero de grados de libertad del
            % disipador
            
            numeroGDL = 0;
            
        end % obtenerNumeroGDL function
        
        function gdlIDDisipador = obtenerGDLID(obj)
            % obtenerGDLID: Obtiene los ID de los grados de libertad del
            % disipador
            
            gdlIDDisipador = obj.gdlID;
            
        end % obtenerGDLID function
        
        function T = obtenerMatrizTransformacion(obj)
            % obtenerMatrizTransformacion: Obtiene la matriz de
            % transformacion del disipador
            
            T = obj.T;
            
        end % obtenerMatrizTransformacion function
        
        function k_global = obtenerMatrizRigidezCoordGlobal(obj)
            % obtenerMatrizRigidezCoordGlobal: Obtiene la matriz de rigidez
            % en coordenadas globales
            
            % Multiplica por la matriz de transformacion
            k_local = obj.obtenerMatrizRigidezCoordLocal();
            t_theta = obj.obtenerMatrizTransformacion();
            k_global = t_theta' * k_local * t_theta;
            
        end % obtenerMatrizRigidezCoordGlobal function
        
        function k_local = obtenerMatrizRigidezCoordLocal(obj) %#ok<MANU>
            % obtenerMatrizRigidezCoordLocal: Obtiene la matriz de rigidez
            % en coordenadas locales
            
            k_local = [];
            
        end % obtenerMatrizRigidezCoordLocal function
        
        function c_local = obtenerMatrizAmortiguamientoCoordLocal(obj) %#ok<MANU>
            % obtenerMatrizAmortiguamientoCoordLocal: Obtiene la matriz de
            % armortiguamiento en coordenadas locales
            
            c_local = [];
            
        end % obtenerMatrizAmortiguamientoCoordLocal function
        
        function c_global = obtenerMatrizAmortiguamientoCoordGlobal(obj)
            % obtenerMatrizAmortiguamientoCoordGlobal: Obtiene la matriz de
            % amortiguamiento en coordenadas globales
            
            % Multiplica por la matriz de transformacion
            ceq_local = obj.obtenerMatrizAmortiguamientoCoordLocal();
            t_theta = obj.obtenerMatrizTransformacion();
            c_global = t_theta' * ceq_local * t_theta;
            
        end % obtenerMatrizAmortiguamientoCoordGlobal function
        
        function definirGDLID(obj) %#ok<MANU>
            % definirGDLID: Define los GDLID del disipador
            
        end % definirGDLID function
        
        function plot(obj, deformadas, tipoLinea, grosorLinea, colorLinea) %#ok<INUSD>
            % plot: Grafica el disipador
            
        end % plot function
        
        function dibujarDisipador(obj, coord1, coord2, tipoLinea, grosorLinea, colorLinea) %#ok<INUSL>
            % dibujarDisipador: Grafica una linea para un disipador
            
            if length(coord1) == 2
                plot(coord1(1), coord1(2), '.', 'Color', colorLinea);
                plot(coord2(1), coord2(2), '.', 'Color', colorLinea);
                plot([coord1(1), coord2(1)], [coord1(2), coord2(2)], tipoLinea, ...
                    'LineWidth', grosorLinea, 'Color', colorLinea);
            else
                plot3(coord1(1), coord1(2), coord1(3), '.', 'Color', colorLinea);
                plot3(coord2(1), coord2(2), coord2(3), '.', 'Color', colorLinea);
                plot3([coord1(1), coord2(1)], [coord1(2), coord2(2)], [coord1(3), coord2(3)], ...
                    tipoLinea, 'LineWidth', grosorLinea, 'Color', colorLinea);
            end
            
        end % dibujarDisipador function
        
        function disp(obj)
            % disp: Imprime propiedades del disipador
            
            disp@ComponenteModelo(obj);
            % No usar dispMetodoTEFAME()
            
        end % disp function
        
    end % public methods Disipador
    
end % class Disipador