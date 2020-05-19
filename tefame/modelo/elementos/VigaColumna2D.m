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
%| Clase VigaColumna2D                                                  |
%|                                                                      |
%| Este archivo contiene la definicion de la Clase VigaColumna 2D       |
%| ColumnaViga2D es una  subclase de la clase Elemento y  corresponde a |
%| la representacion del elemento viga-columna que transmite esfuerzos  |
%| axiales y de corte.                                                  |
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
%       obj = VigaColumna2D(etiquetaViga,nodo1Obj,nodo2Obj,Imaterial,Ematerial,densidad)
%       numeroNodos = obtenerNumeroNodos(obj)
%       nodosBiela = obtenerNodos(obj)
%       numeroGDL = obtenerNumeroGDL(obj)
%       gdlIDBiela = obtenerGDLID(obj)
%       k_global = obtenerMatrizRigidezCoordGlobal(obj)
%       k_local = obtenerMatrizRigidezCoordLocal(obj)
%       m_masa = obtenerVectorMasa(obj)
%       m = obtenerMasa(obj)
%       fr_global = obtenerFuerzaResistenteCoordGlobal(obj)
%       fr_local = obtenerFuerzaResistenteCoordLocal(obj)
%       l = obtenerLargo(obj)
%       T = obtenerMatrizTransformacion(obj)
%       theta = obtenerAngulo(obj)
%       definirGDLID(obj)
%       agregarFuerzaResistenteAReacciones(obj)
%       guardarPropiedades(obj,archivoSalidaHandle)
%       guardarEsfuerzosInternos(obj,archivoSalidaHandle)
%       disp(obj)
%  Methods SuperClass (ComponenteModelo):
%       etiqueta = obtenerEtiqueta(obj)
%       e = equals(obj,obj)
%       objID = obtenerIDObjeto(obj)

classdef VigaColumna2D < Elemento
    
    properties(Access = private)
        Ao % Area de la seccion transversal
        dx % Distancia en el eje x entre los nodos
        dy % Distancia en el eje y entre los nodos
        Eo % Modulo de elasticidad
        Feq % Fuerza equivalente
        gdlID % Lista con los ID de los grados de libertad
        Io % Inercia de la seccion
        Klp % Matriz de rigidez local del elemento
        L % Largo del elemento
        nodosObj % Cell con los nodos
        PLOTNELEM % Numero de elementos en los que se discretiza para el grafico
        rho % Densidad
        T % Matriz de transformacion
        theta % Angulo de inclinacion de la viga
    end % private properties VigaColumna2D
    
    methods(Access = public)
        
        function obj = VigaColumna2D(etiquetaViga, nodo1Obj, nodo2Obj, Imaterial, Ematerial, Amaterial, densidad)
            
            % Completa con ceros si no hay argumentos
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
            obj.Ao = Amaterial;
            obj.Eo = Ematerial;
            obj.Io = Imaterial;
            obj.rho = densidad;
            obj.gdlID = [];
            
            % Calcula componentes geometricas
            coordNodo1 = nodo1Obj.obtenerCoordenadas();
            coordNodo2 = nodo2Obj.obtenerCoordenadas();
            obj.dx = abs(coordNodo2(1)-coordNodo1(1));
            obj.dy = abs(coordNodo2(2)-coordNodo1(2));
            obj.L = sqrt(obj.dx^2+obj.dy^2);
            theta = atan(obj.dy/obj.dx);
            obj.theta = theta;
            
            % Calcula matriz de transformacion dado el angulo
            T = [cos(theta), sin(theta), 0, 0, 0, 0; ...
                -sin(theta), cos(theta), 0, 0, 0, 0; ...
                0, 0, 1, 0, 0, 0; ...
                0, 0, 0, cos(theta), sin(theta), 0; ...
                0, 0, 0, -sin(theta), cos(theta), 0; ...
                0, 0, 0, 0, 0, 1];
            obj.T = T;
            
            % Calcula matriz de rigidez local
            A = Amaterial;
            E = Ematerial;
            I = Imaterial;
            L = obj.L;
            Klp = [A * E / L, 0, 0, -A * E / L, 0, 0; ...
                0, 12 * E * I / (L^3), 6 * E * I / (L^2), 0, - 12 * E * I / (L^3), 6 * E * I / (L^2); ...
                0, 6 * E * I / (L^2), 4 * E * I / L, 0, - 6 * E * I / (L^2), 2 * E * I / L; ...
                -A * E / L, 0, 0, A * E / L, 0, 0; ...
                0, -12 * E * I / (L^3), - 6 * E * I / (L^2), 0, 12 * E * I / (L^3), -6 * E * I / (L^2); ...
                0, 6 * E * I / (L^2), 2 * E * I / L, 0, - 6 * E * I / (L^2), 4 * E * I / L];
            obj.Klp = Klp;
            
            % Fuerza equivalente de la viga
            obj.Feq = [0, 0, 0, 0, 0, 0]';
            
            % Agrega el elemento a los nodos
            for i = 1:2
                obj.nodosObj{i}.agregarElementos(obj);
            end % for i
            
            % Otros
            obj.PLOTNELEM = 10;
            
        end % VigaColumna2D constructor
        
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
            
            numeroGDL = 6;
            
        end % obtenerNumeroGDL function
        
        function gdlIDViga = obtenerGDLID(obj)
            % obtenerGDLID: Obtiene los ID de los grados de libertad del
            % elemento
            
            gdlIDViga = obj.gdlID;
            
        end % obtenerGDLID function
        
        function T = obtenerMatrizTransformacion(obj)
            % obtenerMatrizTransformacion: Obtiene la matriz de
            % transformacion del elemento
            
            T = obj.T;
            
        end % obtenerMatrizTransformacion function
        
        function theta = obtenerAngulo(obj)
            % obtenerAngulo: Retorna el angulo de inclinacion del elemento
            
            theta = obj.theta;
            
        end % obtenerAngulo function
        
        function k_global = obtenerMatrizRigidezCoordGlobal(obj)
            % obtenerMatrizRigidezCoordGlobal: Retorna la matriz de rigidez
            % en coordenadas globales
            
            % Multiplica por la matriz de transformacion
            k_local = obj.obtenerMatrizRigidezCoordLocal();
            t_theta = obj.T;
            k_global = t_theta' * k_local * t_theta;
            
        end % obtenerMatrizRigidezCoordGlobal function
        
        function k_local = obtenerMatrizRigidezCoordLocal(obj)
            % obtenerMatrizRigidezCoordLocal: Retorna la matriz de rigidez
            % en coordenadas locales
            
            k_local = obj.Klp;
            
        end % obtenerMatrizRigidezCoordLocal function
        
        function m = obtenerMasa(obj)
            % obtenerMasa: Retorna la masa total del elemento
            
            m = obj.rho * obj.L * obj.Ao;
            
        end % obtenerMasa function
        
        function m_masa = obtenerVectorMasa(obj)
            % obtenerVectorMasa: Obtiene el vector de masa del elemento
            
            m_masa = zeros(6, 1);
            m = obj.obtenerMasa();
            m_masa(1) = m * 0.5;
            m_masa(2) = m * 0.5;
            m_masa(3) = 1e-12;
            m_masa(4) = m * 0.5;
            m_masa(5) = m * 0.5;
            m_masa(6) = 1e-12;
            
        end % obtenerMatrizMasa function
        
        function fr_global = obtenerFuerzaResistenteCoordGlobal(obj)
            % obtenerFuerzaResistenteCoordGlobal: Retorna la fuerza
            % resistente en coordenadas globales
            
            % Obtiene fr local
            fr_local = obj.obtenerFuerzaResistenteCoordLocal();
            
            % Resta a fuerza equivalente para obtener la fuerza global
            fr_global = obj.T' * (fr_local - obj.Feq);
            
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
            u = [u1(1), u1(2), u1(3), u2(1), u2(2), u2(3)]';
            
            % Obtiene K local
            k_local = obj.obtenerMatrizRigidezCoordLocal();
            
            % Obtiene u''
            u = obj.obtenerMatrizTransformacion() * u;
            
            % Calcula F
            fr_local = k_local * u;
            
        end % obtenerFuerzaResistenteCoordLocal function
        
        function definirGDLID(obj)
            % definirGDLID: Define los ID de los grados de libertad de la
            % viga columna
            
            % Se obtienen los nodos extremos
            nodo1 = obj.nodosObj{1};
            nodo2 = obj.nodosObj{2};
            
            % Se obtienen los gdl de los nodos
            gdlnodo1 = nodo1.obtenerGDLID();
            gdlnodo2 = nodo2.obtenerGDLID();
            
            % Se establecen gdl
            gdl = [0, 0, 0, 0, 0, 0];
            gdl(1) = gdlnodo1(1);
            gdl(2) = gdlnodo1(2);
            gdl(3) = gdlnodo1(3);
            gdl(4) = gdlnodo2(1);
            gdl(5) = gdlnodo2(2);
            gdl(6) = gdlnodo2(3);
            obj.gdlID = gdl;
            
        end % definirGDLID function
        
        function sumarFuerzaEquivalente(obj, f)
            % sumarFuerzaEquivalente: Suma fuerza equivalente de la viga
            
            for i = 1:length(f)
                obj.Feq(i) = obj.Feq(i) + f(i);
            end % for i
            
        end % sumarFuerzaEquivalente function
        
        function f = obtenerFuerzaEquivalente(obj)
            % obtenerFuerzaEquivalente: Obtiene la fuerza equivalente de la
            % viga columna
            
            f = obj.Feq;
            
        end % obtenerFuerzaEquivalente function
        
        function agregarFuerzaResistenteAReacciones(obj)
            % agregarFuerzaResistenteAReacciones: Agrega fuerza resistente
            % de la viga a las reacciones
            
            % Se calcula la fuerza resistente global
            fr_global = obj.obtenerFuerzaResistenteCoordGlobal();
            
            % Carga los nodos
            nodo1 = obj.nodosObj{1};
            nodo2 = obj.nodosObj{2};
            
            % Transforma la carga equivalente como carga puntual
            F_eq = obj.T' * obj.Feq;
            
            % Agrega fuerzas equivalentes como cargas
            nodo1.agregarCarga([-F_eq(1), -F_eq(2), -F_eq(3)]')
            nodo2.agregarCarga([-F_eq(4), -F_eq(5), -F_eq(6)]')
            
            % Agrega fuerzas resistentes como cargas
            nodo1.agregarEsfuerzosElementoAReaccion([fr_global(1), fr_global(2), fr_global(3)]');
            nodo2.agregarEsfuerzosElementoAReaccion([fr_global(4), fr_global(5), fr_global(6)]');
            
        end % agregarFuerzaResistenteAReacciones function
        
        function guardarPropiedades(obj, archivoSalidaHandle)
            % guardarPropiedades: Guarda las propiedades del elemento en un
            % archivo
            
            fprintf(archivoSalidaHandle, '\tViga-Columna 2D %s:\n\t\tLargo:\t\t%s\n\t\tInercia:\t%s\n\t\tEo:\t\t\t%s\n\t\tEI:\t\t\t%s\n\t\tMasa:\t\t%s\n', ...
                obj.obtenerEtiqueta(), num2str(obj.L), ...
                num2str(obj.Io), num2str(obj.Eo), ...
                num2str(obj.Eo*obj.Io), ...
                num2str(obj.obtenerMasa()));
            
        end % guardarPropiedades function
        
        function guardarEsfuerzosInternos(obj, archivoSalidaHandle)
            % guardarEsfuerzosInternos: Guarda los esfuerzos internos del
            % elemento
            
            fr = obj.obtenerFuerzaResistenteCoordGlobal();
            n1 = pad(num2str(fr(1), '%.04f'), 10);
            n2 = pad(num2str(fr(4), '%.04f'), 10);
            v1 = pad(num2str(fr(2), '%.04f'), 10);
            v2 = pad(num2str(fr(5), '%.04f'), 10);
            m1 = pad(num2str(fr(3), '%.04f'), 10);
            m2 = pad(num2str(fr(6), '%.04f'), 10);
            
            fprintf(archivoSalidaHandle, '\n\tViga-Columna 2D %s:\n\t\tAxial:\t\t%s %s\n\t\tCorte:\t\t%s %s\n\t\tMomento:\t%s %s', ...
                obj.obtenerEtiqueta(), n1, n2, v1, v2, m1, m2);
            
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
        
        function y = plotVigaDeformar(obj, deformadas) %#ok<INUSL>
            % plotVigaDeformar: Evalua si se grafica una viga con
            % deformacion
            
            y = length(deformadas{1}) == 3;
            
        end % plotVigaDeformar function
        
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
                if defElem && obj.plotVigaDeformar(deformadas) && obj.graficaDeformada
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
                            (coordy * n) * cos(tht) + (coord1(2) + ndy * p) * sin(tht)];
                        obj.graficarLinea(coordi, coordf, tipoLinea, grosorLinea);
                        coordi = coordf;
                    end
                    return;
                end
            end
            
            % Grafica en forma lineal
            obj.graficarLinea(coord1, coord2, tipoLinea, grosorLinea);
            
        end % plot function
        
        function disp(obj)
            % disp: Imprime propiedades en pantalla del objeto
            
            % Imprime propiedades de la Viga-Columna-2D
            fprintf('Propiedades viga columna 2D:\n');
            disp@ComponenteModelo(obj);
            fprintf('\tLargo: %s\n\tArea: %s\n\tI: %s\n\tE: %s\n\tMasa: %s\n', pad(num2str(obj.L), 12), ...
                pad(num2str(obj.Ao), 10), pad(num2str(obj.Io), 10), ...
                pad(num2str(obj.Eo), 10), pad(num2str(obj.obtenerMasa()), 10));
            
            % Se imprime matriz de rigidez local
            fprintf('\tMatriz de rigidez coordenadas locales:\n');
            disp(obj.obtenerMatrizRigidezCoordLocal());
            
            % Se imprime matriz de rigidez global
            fprintf('\tMatriz de rigidez coordenadas globales:\n');
            disp(obj.obtenerMatrizRigidezCoordGlobal());
            
            % Imprime vector de masa
            fprintf('\tVector de masa:\n');
            disp(obj.obtenerVectorMasa());
            
            dispMetodoTEFAME();
            
        end % disp function
        
    end % public methods VigaColumna2D
    
end % class VigaColumna2D