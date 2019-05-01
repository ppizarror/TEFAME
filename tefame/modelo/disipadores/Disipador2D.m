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
%| Clase Disipador2D                                                    |
%|                                                                      |
%| Este archivo contiene la definicion de la Clase DisipadorViscoso 2D  |
%| es una  subclase de la clase Disipador y  corresponde a la           |
%| representacion de un disipador viscoso en 2D.                        |
%|                                                                      |
%| Programado: Pablo Pizarro @ppizarror.com                             |
%| Fecha: 30/04/2019                                                    |
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
%       plot(disipador2DObj,tipoLinea,grosorLinea,colorLinea)
%  Methods SuperClass (ComponenteModelo):
%       etiqueta = obtenerEtiqueta(componenteModeloObj)
%       e = equals(componenteModeloObj,obj)

classdef Disipador2D < Disipador
    
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
            disipador2DObj = disipador2DObj@Disipador(etiquetaDisipador);
            
        end % Disipador2D constructor
        
        function numeroNodos = obtenerNumeroNodos(disipador2DObj) %#ok<MANU>
            % obtenerNumeroNodos: Obtiene el numero de modos del disipador
            %
            % numeroNodos = obtenerNumeroNodos(disipador2DObj)
            
            numeroNodos = 2;
            
        end % obtenerNumeroNodos function
        
        function numeroGDL = obtenerNumeroGDL(disipador2DObj) %#ok<MANU>
            % obtenerNumeroGDL: Retorna el numero de grados de libertad del
            % disipador
            %
            % numeroGDL = obtenerNumeroGDL(disipador2DObj)
            
            numeroGDL = 4;
            
        end % obtenerNumeroGDL function
        
        function actualizarDisipador(disipador2DObj, w, carga) %#ok<INUSD>
            % actualizarDisipador: Actualiza el disipador con la carga y la
            % frecuencia
            %
            % actualizarDisipador(disipador2DObj,w,carga)
            
        end % actualizarDisipador function
        
        function v0 = calcularv0(disipador2DObj, nodos, carga) %#ok<INUSL>
            % calcularv0: Calcula v0 a partir de una carga
            %
            % v0 = calcularv0(disipador2DObj, nodos, carga)
            
            % Calcula v0
            u = carga.obtenerDesplazamiento();
            gdl1 = nodos{1}.obtenerGDLIDCondensado();
            gdl2 = nodos{2}.obtenerGDLIDCondensado();
            
            % Recorre cada tiempo y calcula v0
            v0 = 0;
            for i=1:length(u) % Recorre los tiempos
                % Obtiene los desplazamientos
                d11 = 0;
                d12 = 0;
                d21 = 0;
                d22 = 0;
                if gdl1(1) ~= 0
                    d11 = u(gdl1(1), i);
                end
                if gdl1(2) ~= 0
                    d12 = u(gdl1(2), i);
                end
                if gdl2(1) ~= 0
                    d21 = u(gdl2(1), i);
                end
                if gdl2(2) ~= 0
                    d22 = u(gdl2(2), i);
                end
                v0 = max(v0, sqrt((d21-d11)^2 + (d22-d12)^2));
            end
            
        end
        
    end % methods Disipador2D
    
end % class Disipador2D