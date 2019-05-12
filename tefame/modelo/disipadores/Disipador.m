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
%       definirGDLID(disipadorObj)
%       disipadorObj = Disipador(etiquetaDisipador)
%       disp(disipadorObj)
%       fr_global = obtenerFuerzaResistenteCoordGlobal(disipadorObj)
%       fr_local = obtenerFuerzaResistenteCoordLocal(disipadorObj)
%       gdlIDDisipador = obtenerGDLID(disipadorObj)
%       k_global = obtenerMatrizRigidezCoordGlobal(disipadorObj)
%       k_local = obtenerMatrizRigidezCoordLocal(disipadorObj)
%       numeroGDL = obtenerNumeroGDL(disipadorObj)
%       numeroNodos = obtenerNumeroNodos(disipadorObj)
%       plot(disipadorObj,tipoLinea,grosorLinea,colorLinea)
%       T = obtenerMatrizTransformacion(disipadorObj)
%  Methods SuperClass (ComponenteModelo):
%       etiqueta = obtenerEtiqueta(componenteModeloObj)
%       e = equals(componenteModeloObj,obj)
%       objID = obtenerIDObjeto(componenteModeloObj)

classdef Disipador < ComponenteModelo
    
    properties(Access = private)
    end % properties Disipador
    
    properties(Access = protected)
        nodosObj % Cell con los nodos
        gdlID % Lista con los ID de los grados de libertad
        T % Matriz de transformacion
    end % properties Disipador2D
    
    methods
        
        function disipadorObj = Disipador(etiquetaDisipador)
            % Disipador: es el constructor de la clase Disipador
            %
            % disipadorObj = Disipador(etiquetaDisipador)
            %
            % Crea un objeto de la clase Disipador, con un identificador unico
            % (etiquetaDisipador)
            
            % Si no se pasan argumentos se crean vacios
            if nargin == 0
                etiquetaDisipador = '';
            end % if
            
            % Llamamos al constructor de la SuperClass que es la clase ComponenteModelo
            disipadorObj = disipadorObj@ComponenteModelo(etiquetaDisipador);
            disipadorObj.gdlID = [];
            disipadorObj.T = [];
            
        end % Disipador constructor

        function inicializar(disipadorObj)%#ok<MANU>
            % inicializar: es un metodo de la clase Disipador que se usa para
            % inicializar las diferentes componentes que sean necesario en los
            % disipadores para realizar posteriormente el analisis
            %
            % inicializar(elementoObj)
            % Inicializa los diferentes componetes del Disipador (disipadorObj),
            % para poder preparar estos para realizar el analisis

        end % inicializar function 
        
        function numeroNodos = obtenerNumeroNodos(disipadorObj) %#ok<MANU>
            % obtenerNumeroNodos: Obtiene el numero de nodos del disipador
            %
            % numeroNodos = obtenerNumeroNodos(disipadorObj)
            
            numeroNodos = 0;
            
        end % obtenerNumeroNodos function
        
        function nodosDisipador = obtenerNodos(disipadorObj)
            % nodosDisipador: Obtiene los nodos del disipador
            %
            % nodosDisipador = obtenerNodos(disipadorObj)
            
            nodosDisipador = disipadorObj.nodosObj;
            
        end % obtenerNodos function
        
        function numeroGDL = obtenerNumeroGDL(disipadorObj) %#ok<MANU>
            % obtenerNumeroGDL: Retorna el numero de grados de libertad del
            % disipador
            %
            % numeroGDL = obtenerNumeroGDL(disipadorObj)
            
            numeroGDL = 0;
            
        end % obtenerNumeroGDL function
        
        function gdlIDDisipador = obtenerGDLID(disipadorObj)
            % obtenerGDLID: Obtiene los ID de los grados de libertad del
            % disipador
            %
            % gdlIDDisipador = obtenerGDLID(disipadorObj)
            
            gdlIDDisipador = disipadorObj.gdlID;
            
        end % obtenerGDLID function
        
        function T = obtenerMatrizTransformacion(disipadorObj)
            % obtenerMatrizTransformacion: Obtiene la matriz de
            % transformacion del disipador
            %
            % T = obtenerMatrizTransformacion(disipadorObj)
            
            T = disipadorObj.T;
            
        end % obtenerMatrizTransformacion function
        
        function k_global = obtenerMatrizRigidezCoordGlobal(disipadorObj)
            % obtenerMatrizRigidezCoordGlobal: Obtiene la matriz de rigidez
            % en coordenadas globales
            %
            % k_global = obtenerMatrizRigidezCoordGlobal(disipadorObj)
            
            % Multiplica por la matriz de transformacion
            k_local = disipadorObj.obtenerMatrizRigidezCoordLocal();
            t_theta = disipadorObj.obtenerMatrizTransformacion();
            k_global = t_theta' * k_local * t_theta;
            
        end % obtenerMatrizRigidezCoordGlobal function
        
        function k_local = obtenerMatrizRigidezCoordLocal(disipadorObj) %#ok<MANU>
            % obtenerMatrizRigidezCoordLocal: Obtiene la matriz de rigidez
            % en coordenadas locales
            %
            % k_local = obtenerMatrizRigidezCoordLocal(disipadorObj)
            
            k_local = [];
            
        end % obtenerMatrizRigidezCoordLocal function
        
        function c_local = obtenerMatrizAmortiguamientoCoordLocal(disipadorObj) %#ok<MANU>
            % obtenerMatrizAmortiguamientoCoordLocal: Obtiene la matriz de
            % armortiguamiento en coordenadas locales
            %
            % c_local = obtenerMatrizAmortiguamientoCoordLocal(disipadorObj)
            
            c_local = [];
            
        end % obtenerMatrizAmortiguamientoCoordLocal function
        
        function c_global = obtenerMatrizAmortiguamientoCoordGlobal(disipadorObj)
            % obtenerMatrizAmortiguamientoCoordGlobal: Obtiene la matriz de
            % amortiguamiento en coordenadas globales
            %
            % c_global = obtenerMatrizAmortiguamientoCoordGlobal(disipadorObj)
            
            % Multiplica por la matriz de transformacion
            ceq_local = disipadorObj.obtenerMatrizAmortiguamientoCoordLocal();
            t_theta = disipadorObj.obtenerMatrizTransformacion();
            c_global = t_theta' * ceq_local * t_theta;
            
        end % obtenerMatrizAmortiguamientoCoordGlobal function
        
        function definirGDLID(disipadorObj) %#ok<MANU>
            % definirGDLID: Define los GDLID del disipador
            %
            % definirGDLID(disipadorObj)
            
        end % definirGDLID function
        
        function plot(disipadorObj, deformadas, tipoLinea, grosorLinea, colorLinea) %#ok<INUSD>
            % plot: Grafica el disipador
            %
            % plot(disipadorObj,deformadas,tipoLinea,grosorLinea,colorLinea)
            
        end % plot function
        
        function dibujarDisipador(disipadorObj, coord1, coord2, tipoLinea, grosorLinea, colorLinea) %#ok<INUSL>
            % dibujarDisipador: Grafica una linea para un disipador
            %
            % dibujarDisipador(elementoObj,coord1,coord2,tipoLinea,grosorLinea)
            
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
        
        function disp(disipadorObj)
            % disp: Imprime propiedades del disipador
            
            disp@ComponenteModelo(disipadorObj);
            % No usar dispMetodoTEFAME()
            
        end % disp function
        
    end % methods Disipador
    
end % class Disipador