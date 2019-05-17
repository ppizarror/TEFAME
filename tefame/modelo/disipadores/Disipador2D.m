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
%       definirGDLID(obj)
%       obj = Disipador2D(etiquetaDisipador)
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

classdef Disipador2D < Disipador
    
    properties(Access = private)
    end % properties Disipador2D
    
    methods
        
        function obj = Disipador2D(etiquetaDisipador)
            % Disipador2D: es el constructor de la clase Disipador2D
            %
            % Crea un objeto de la clase Disipador2D, con un identificador unico
            % (etiquetaDisipador)
            
            % Si no se pasan argumentos se crean vacios
            if nargin == 0
                etiquetaDisipador = '';
            end % if
            
            % Llamamos al constructor de la SuperClass que es la clase ComponenteModelo
            obj = obj@Disipador(etiquetaDisipador);
            
        end % Disipador2D constructor
        
        function numeroNodos = obtenerNumeroNodos(obj) %#ok<MANU>
            % obtenerNumeroNodos: Obtiene el numero de nodos del disipador
            
            numeroNodos = 2;
            
        end % obtenerNumeroNodos function
        
        function numeroGDL = obtenerNumeroGDL(obj) %#ok<MANU>
            % obtenerNumeroGDL: Retorna el numero de grados de libertad del
            % disipador
            
            numeroGDL = 4;
            
        end % obtenerNumeroGDL function
        
        function nodosDisipador = obtenerNodos(obj)
            % nodosDisipador: Obtiene los nodos del disipador
            
            nodosDisipador = obj.nodosObj;
            
        end % obtenerNodos function
        
        function actualizarDisipador(obj, w, carga) %#ok<INUSD>
            % actualizarDisipador: Actualiza el disipador con la carga y la
            % frecuencia
            
        end % actualizarDisipador function
        
        function v0 = calcularv0(obj, nodos, carga) %#ok<INUSL>
            % calcularv0: Calcula v0 a partir de una carga
            
            % Calcula v0
            u = carga.obtenerDesplazamiento();
            gdl1 = nodos{1}.obtenerGDLIDCondensado();
            gdl2 = nodos{2}.obtenerGDLIDCondensado();
            
            % Recorre cada tiempo y calcula v0
            v0 = 0;
            for i = 1:length(u) % Recorre los tiempos
                d11 = 0; % Obtiene los desplazamientos
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
                v0 = max(v0, sqrt((d21 - d11)^2+(d22 - d12)^2));
            end % for i
            
        end % calcularv0 function
        
        function definirGDLID(obj)
            % definirGDLID: Define los GDLID del disipador
            
            % Se obtienen los nodos extremos
            nodo1 = obj.nodosObj{1};
            nodo2 = obj.nodosObj{2};
            
            % Se obtienen los gdl de los nodos
            gdlnodo1 = nodo1.obtenerGDLID();
            gdlnodo2 = nodo2.obtenerGDLID();
            
            % Se establecen gdl
            gdl = [0, 0, 0, 0];
            gdl(1) = gdlnodo1(1);
            gdl(2) = gdlnodo1(2);
            gdl(3) = gdlnodo2(1);
            gdl(4) = gdlnodo2(2);
            obj.gdlID = gdl;
            
        end % definirGDLID function
        
        function gdl = obtenerGDLIDCondensado(obj)
            % obtenerGDLIDCondensado: Obtiene los GDLID condensados del
            % disipador
            
            % Se obtienen los nodos extremos
            nodo1 = obj.nodosObj{1};
            nodo2 = obj.nodosObj{2};
            
            % Se obtienen los gdl de los nodos
            gdlnodo1 = nodo1.obtenerGDLIDCondensado();
            gdlnodo2 = nodo2.obtenerGDLIDCondensado();
            
            % Se establecen gdl
            gdl = [0, 0, 0, 0];
            gdl(1) = gdlnodo1(1);
            gdl(2) = gdlnodo1(2);
            gdl(3) = gdlnodo2(1);
            gdl(4) = gdlnodo2(2);
            
        end % obtenerGDLIDCondensado function
        
        function plot(obj, deformadas, tipoLinea, grosorLinea, colorLinea)
            % plot: Grafica el disipador
            
            coord1 = obj.nodosObj{1}.obtenerCoordenadas();
            coord2 = obj.nodosObj{2}.obtenerCoordenadas();
            coord1 = coord1 + deformadas{1}(1:2);
            coord2 = coord2 + deformadas{2}(1:2);
            dibujarDisipador(obj, coord1, coord2, tipoLinea, grosorLinea, colorLinea)
            
        end % plot function
        
    end % methods Disipador2D
    
end % class Disipador2D