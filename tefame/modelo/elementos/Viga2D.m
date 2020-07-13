%|______________________________________________________________________|
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
%| Repositorio: https://github.com/ppizarror/TEFAME                     |
%|______________________________________________________________________|
%|                                                                      |
%| Clase Viga2D                                                         |
%|                                                                      |
%| Este archivo contiene la definicion de la Clase Viga 2D              |
%| Viga2D  es una  subclase de la  clase Elemento y  corresponde a  la  |
%| representacion del elemento viga que solo transmite esfuerzo de      |
%| corte.                                                               |
%|______________________________________________________________________|
%|                                                                      |
%| MIT License                                                          |
%| Copyright (c) 2018-2019 Pablo Pizarro R @ppizarror.com.              |
%|                                                                      |
%| Permission is hereby granted, free of charge, to any person obtai-   |
%| ning a copy of this software and associated documentation files (the |
%| "Software"), to deal in the Software without restriction, including  |
%| without limitation the rights to use, copy, modify, merge, publish,  |
%| distribute, sublicense, and/or sell copies of the Software, and to   |
%| permit persons to whom the Software is furnished to do so, subject   |
%| to the following conditions:                                         |
%|                                                                      |
%| The above copyright notice and this permission notice shall be       |
%| included in all copies or substantial portions of the Software.      |
%|                                                                      |
%| THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,      |
%| EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF   |
%| MERCHANTABILITY,FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.|
%| IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY |
%| CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, |
%| TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE    |
%| SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.               |
%|______________________________________________________________________|
%
%  Methods(Access=public):
%       obj = Viga2D(etiquetaViga,nodo1Obj,nodo2Obj,Imaterial,Ematerial,densidad)
%       fr_global = obtenerFuerzaResistenteCoordGlobal(obj)
%       fr_local = obtenerFuerzaResistenteCoordLocal(obj)
%       gdlIDViga = obtenerGDLID(obj)
%       k_global = obtenerMatrizRigidezCoordGlobal(obj)
%       k_local = obtenerMatrizRigidezCoordLocal(obj)
%       l = obtenerLargo(obj)
%       nodosViga = obtenerNodos(obj)
%       numeroGDL = obtenerNumeroGDL(obj)
%       numeroNodos = obtenerNumeroNodos(obj)
%       agregarFuerzaResistenteAReacciones(obj)
%       definirGDLID(obj)
%       disp(obj)
%       guardarEsfuerzosInternos(obj,archivoSalidaHandle)
%       guardarPropiedades(obj,archivoSalidaHandle)
%  Methods SuperClass (ComponenteModelo):
%       etiqueta = obtenerEtiqueta(obj)
%       e = equals(obj,obj)
%       objID = obtenerIDObjeto(obj)

classdef Viga2D < Elemento
    
    properties(Access = private)
        dx % Distancia en el eje x entre los nodos
        dy % Distancia en el eje y entre los nodos
        Eo % Modulo de elasticidad
        Feq % Fuerza equivalente
        gdlID % Lista con los ID de los grados de libertad
        Io % Inercia de la seccion
        L % Largo del elemento
        nodosObj % Cell con los nodos
        PLOTNELEM % Numero de elementos en los que se discretiza para el grafico
        rho % Densidad de la viga
        theta % Angulo de inclinacion de la viga
    end % private properties Viga2D
    
    methods(Access = public)
        
        function obj = Viga2D(etiquetaViga, nodo1Obj, nodo2Obj, Imaterial, Ematerial, densidad)
            % Viga2D: Constructor de clase
            
            % Si no se pasan argumentos se crean vacios
            if nargin == 0
                etiquetaViga = '';
            end
            if ~exist('densidad', 'var')
                densidad = 0;
            end
            
            % Llamamos al constructor de la SuperClass que es la clase Elemento
            obj = obj@Elemento(etiquetaViga);
            
            % Guarda material
            obj.nodosObj = {nodo1Obj; nodo2Obj};
            obj.Eo = Ematerial;
            obj.Io = Imaterial;
            obj.gdlID = [];
            obj.rho = densidad;
            
            % Calcula componentes geometricas
            coordNodo1 = nodo1Obj.obtenerCoordenadas();
            coordNodo2 = nodo2Obj.obtenerCoordenadas();
            obj.dx = coordNodo2(1)-coordNodo1(1);
            obj.dy = coordNodo2(2)-coordNodo1(2);
            obj.L = sqrt(obj.dx^2+obj.dy^2);
            obj.theta = atan(obj.dy/obj.dx);
            
            % Fuerza equivalente de la viga
            obj.Feq = [0, 0, 0, 0]';
            
            % Otros
            obj.PLOTNELEM = 10;
            
        end % Viga2D constructor
        
        function l = obtenerLargo(obj)
            % obtenerLargo: Retorna el largo del elemento
            
            l = obj.L;
            
        end % obtenerLargo function
        
        function numeroNodos = obtenerNumeroNodos(obj) %#ok<MANU>
            % obtenerNumeroNodos: Retorna el numero de nodos del elemento
            
            numeroNodos = 2;
            
        end % obtenerNumeroNodos function
        
        function nodosViga = obtenerNodos(obj)
            % obtenerNodos: Retorna los nodos del elemento
            
            nodosViga = obj.nodosObj;
            
        end % obtenerNodos function
        
        function numeroGDL = obtenerNumeroGDL(obj) %#ok<MANU>
            % obtenerNumeroGDL: Obtiene el numero de grados de libertad del
            % elemento
            
            numeroGDL = 4;
            
        end % obtenerNumeroGDL function
        
        function gdlIDViga = obtenerGDLID(obj)
            % obtenerGDLID: Obtiene los ID de los grados de libertad del
            % elemento
            
            gdlIDViga = obj.gdlID;
            
        end % obtenerGDLID function
        
        function m = obtenerMasa(obj)
            % obtenerMasa: Retorna la masa total del elemento
            
            m = obj.rho * obj.L;
            
        end % obtenerMasa function
        
        function m_masa = obtenerVectorMasa(obj)
            % obtenerVectorMasa: Obtiene el vector de masa del elemento
            
            m_masa = zeros(4, 1);
            m = obj.obtenerMasa();
            m_masa(1) = m * 0.5;
            m_masa(2) = m * 0.5;
            m_masa(3) = m * 0.5;
            m_masa(4) = m * 0.5;
            
        end % obtenerMatrizMasa function
        
        function k_global = obtenerMatrizRigidezCoordGlobal(obj)
            % obtenerMatrizRigidezCoordGlobal: Retorna la matriz de rigidez
            % en coordenadas globales
            
            % Matriz global igual a la local
            k_global = obj.obtenerMatrizRigidezCoordLocal();
            
        end % obtenerMatrizRigidezGlobal function
        
        function k_local = obtenerMatrizRigidezCoordLocal(obj)
            % obtenerMatrizRigidezCoordLocal: Retorna la matriz de rigidez
            % en coordenadas locales
            
            % Genera la matriz de rigidez local
            L1 = obj.L;
            L2 = L1.^2;
            k_local = [12, 6 * L1, -12, 6 * L1; ...
                6 * L1, 4 * L2, -6 * L1, 2 * L2; ...
                -12, -6 * L1, 12, -6 * L1; ...
                6 * L1, 2 * L2, -6 * L1, 4 * L2];
            
            % Multiplica por EoIo/L
            k_local = k_local .* (obj.Eo * obj.Io / (obj.L^3));
            
        end % obtenerMatrizRigidezLocal function
        
        function fr_global = obtenerFuerzaResistenteCoordGlobal(obj)
            % obtenerFuerzaResistenteCoordGlobal: Retorna la fuerza
            % resistente en coordenadas globales
            
            % Obtiene fr local
            fr_local = obj.obtenerFuerzaResistenteCoordLocal();
            
            % Resta a fuerza equivalente para obtener la fuerza global
            fr_global = fr_local - obj.Feq;
            
        end % obtenerFuerzaResistenteCoordGlobal function
        
        function fr_local = obtenerFuerzaResistenteCoordLocal(obj)
            % obtenerFuerzaResistenteCoordLocal: Retorna la fuerza
            % resistente en coordenadas locales
            
            % Obtiene los nodos
            nodo1 = obj.nodosObj{1};
            nodo2 = obj.nodosObj{2};
            
            % Obtiene los desplazamientos
            u1 = nodo1.obtenerDesplazamientos();
            u2 = nodo2.obtenerDesplazamientos();
            
            % Vector desplazamientos u'
            u = [u1(2), u1(3), u2(2), u2(3)]';
            
            % Obtiene K local
            k_local = obj.obtenerMatrizRigidezCoordLocal();
            
            % Calcula F
            fr_local = k_local * u;
            
        end % obtenerFuerzaResistenteCoordLocal function
        
        function definirGDLID(obj)
            % definirGDLID: Define los ID de los grados de libertad de la
            % viga
            
            % Se obtienen los nodos extremos
            nodo1 = obj.nodosObj{1};
            nodo2 = obj.nodosObj{2};
            
            % Se obtienen los gdl de los nodos
            gdlnodo1 = nodo1.obtenerGDLID();
            gdlnodo2 = nodo2.obtenerGDLID();
            
            % Se establecen gdl
            gdl = [0, 0, 0, 0];
            gdl(1) = gdlnodo1(2);
            gdl(2) = gdlnodo1(3);
            gdl(3) = gdlnodo2(2);
            gdl(4) = gdlnodo2(3);
            obj.gdlID = gdl;
            
        end % definirGDLID function
        
        function sumarFuerzaEquivalente(obj, f)
            % sumarFuerzaEquivalente: Suma fuerza equivalente de la viga
            
            for i = 1:length(f)
                obj.Feq(i) = obj.Feq(i) + f(i);
            end % for i
            
        end % sumarFuerzaEquivalente function
        
        function agregarFuerzaResistenteAReacciones(obj)
            % agregarFuerzaResistenteAReacciones: Agrega las fuerzas
            % resistentes de la viga a las reacciones
            
            % Se calcula la fuerza resistente global
            fr_global = obj.obtenerFuerzaResistenteCoordGlobal();
            
            % Carga los nodos
            nodo1 = obj.nodosObj{1};
            nodo2 = obj.nodosObj{2};
            
            % Agrega fuerzas equivalentes como cargas
            nodo1.agregarEsfuerzosElementoAReaccion([0, obj.Feq(1), obj.Feq(2)]');
            nodo2.agregarEsfuerzosElementoAReaccion([0, obj.Feq(3), obj.Feq(4)]');
            
            % Agrega fuerzas resistentes como cargas
            nodo1.agregarEsfuerzosElementoAReaccion([0, fr_global(1), fr_global(2)]');
            nodo2.agregarEsfuerzosElementoAReaccion([0, fr_global(3), fr_global(4)]');
            
        end % agregarFuerzaResistenteAReacciones function
        
        function guardarPropiedades(obj, archivoSalidaHandle)
            % guardarPropiedades: Guarda las propiedades de la viga en un
            % archivo
            
            fprintf(archivoSalidaHandle, '\tViga2D %s:\n\t\tLargo:\t\t%s\n\t\tInercia:\t%s\n\t\tEo:\t\t\t%s\n\t\tEI:\t\t\t%s\n\t\tMasa:\t\t%s\n', ...
                obj.obtenerEtiqueta(), num2str(obj.L), ...
                num2str(obj.Io), num2str(obj.Eo), ...
                num2str(obj.Eo*obj.Io), num2str(obj.obtenerMasa()));
            
        end % guardarPropiedades function
        
        function guardarEsfuerzosInternos(obj, archivoSalidaHandle)
            % guardarEsfuerzosInternos: Guarda los esfuerzos internos de la
            % viga en un archivo
            
            fr = obj.obtenerFuerzaResistenteCoordGlobal();
            m1 = pad(num2str(fr(2), '%.04f'), 10);
            m2 = pad(num2str(fr(4), '%.04f'), 10);
            v1 = pad(num2str(fr(1), '%.04f'), 10);
            v2 = pad(num2str(fr(3), '%.04f'), 10);
            
            fprintf(archivoSalidaHandle, '\n\tViga2D %s:\n\t\tMomento:\t%s %s\n\t\tCorte:\t\t%s %s', ...
                obj.obtenerEtiqueta(), m1, m2, v1, v2);
            
        end % guardarEsfuerzosInternos function
        
        function N = obtenerVectorN(obj, x, l) %#ok<INUSL>
            % obtenerVectorN: Obtiene el vector de transformada N a partir
            % de x como porcentaje del largo
            
            x = x * l;
            N = zeros(4, 1);
            N(1) = 1 - 3 * (x / l)^2 + 2 * (x / l)^3;
            N(2) = x * (1 - x / l)^2;
            N(3) = 3 * (x / l)^2 - 2 * (x / l)^3;
            N(4) = (x^2 / l) * (x / l - 1);
            
        end % obtenerVectorN function
        
        function plot(obj, deformadas, tipoLinea, grosorLinea, defElem)
            % plot: Grafica un elemento
            
            % Obtiene las coordenadas de los objetos
            coord1 = obj.nodosObj{1}.obtenerCoordenadas();
            coord2 = obj.nodosObj{2}.obtenerCoordenadas();
            
            % Si hay deformacion
            if ~isempty(deformadas)
                for i=1:length(coord1)
                    coord1(i) = coord1(i) + deformadas{1}(i);
                    coord2(i) = coord2(i) + deformadas{2}(i);
                end
                if length(deformadas{1}) == 3 && defElem && obj.graficaDeformada
                    ndx = abs(coord2(1)-coord1(1));
                    ndy = abs(coord2(2)-coord1(2));
                    nl = sqrt(ndx^2+ndy^2);
                    tht = obj.theta;
                    coordx = [coord1(1), deformadas{1}(3), coord2(1), deformadas{2}(3)];
                    coordy = [coord1(2), deformadas{1}(3), coord2(2), deformadas{2}(3)];
                    coordi = coord1;
                    for i = 1:obj.PLOTNELEM
                        p = i / obj.PLOTNELEM;
                        n = obj.obtenerVectorN(p, nl);
                        coordf = [(coord1(1) + ndx * p) * cos(tht) + (coordx * n) * sin(tht), ...
                            (coordy * n) * cos(tht) + (coord1(2) + ndy * p) * sin(obj.theta)];
                        obj.graficarLinea(coordi, coordf, tipoLinea, grosorLinea);
                        coordi = coordf;
                    end % for i
                    return;
                end
            end
            
            % Grafica en forma lineal
            obj.graficarLinea(coord1, coord2, tipoLinea, grosorLinea);
            
        end % plot function
        
        function disp(obj)
            % disp: Imprime propiedades de la viga 2D en consola
            
            fprintf('Propiedades viga 2D:\n\t');
            disp@ComponenteModelo(obj);
            
            fprintf('\t\tLargo: %s\tI: %s\tE: %s\n', pad(num2str(obj.L), 12), ...
                pad(num2str(obj.Io), 10), pad(num2str(obj.Eo), 10));
            
            % Se imprime matriz de rigidez local
            fprintf('\tMatriz de rigidez coordenadas locales:\n');
            disp(obj.obtenerMatrizRigidezCoordLocal());
            
            % Se imprime matriz de rigidez global
            fprintf('\tMatriz de rigidez coordenadas globales:\n');
            disp(obj.obtenerMatrizRigidezCoordGlobal());
            
            dispMetodoTEFAME();
            
        end % disp function
        
    end % public methods Viga2D
    
end % class Viga2D