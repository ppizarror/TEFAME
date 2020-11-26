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
%| Clase VigaColumna3D                                                  |
%|                                                                      |
%| Este archivo contiene la definicion de la Clase VigaColumna 3D       |
%| ColumnaViga3D es una  subclase de la clase Elemento y  corresponde a |
%| la representacion del elemento viga-columna que transmite esfuerzos  |
%| axiales y de corte en tres dimensiones                               |
%|______________________________________________________________________|
%|                                                                      |
%| MIT License                                                          |
%| Copyright (c) 2018-2020 Pablo Pizarro R @ppizarror.com.              |
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
%       obj = VigaColumna3D(etiquetaViga,nodo1Obj,nodo2Obj,Imaterial,Ematerial,densidad)
%       fr_global = obtenerFuerzaResistenteCoordGlobal(obj)
%       fr_local = obtenerFuerzaResistenteCoordLocal(obj)
%       gdlIDBiela = obtenerGDLID(obj)
%       k_global = obtenerMatrizRigidezCoordGlobal(obj)
%       k_local = obtenerMatrizRigidezCoordLocal(obj)
%       l = obtenerLargo(obj)
%       m = obtenerMasa(obj)
%       m_masa = obtenerVectorMasa(obj)
%       nodosBiela = obtenerNodos(obj)
%       numeroGDL = obtenerNumeroGDL(obj)
%       numeroNodos = obtenerNumeroNodos(obj)
%       T = obtenerMatrizTransformacion(obj)
%       agregarFuerzaResistenteAReacciones(obj)
%       definirGDLID(obj)
%       disp(obj)
%       guardarEsfuerzosInternos(obj,archivoSalidaHandle)
%       guardarPropiedades(obj,archivoSalidaHandle)
%  Methods SuperClass (ComponenteModelo):
%       etiqueta = obtenerEtiqueta(obj)
%       e = equals(obj,obj)
%       objID = obtenerIDObjeto(obj)

classdef VigaColumna3D < Elemento
    
    properties(Access = private)
        Ao % Area de la seccion transversal
        dx % Distancia en el eje x entre los nodos
        dy % Distancia en el eje y entre los nodos
        Eo % Modulo de elasticidad
        Feq % Fuerza equivalente
        gdlID % Lista con los ID de los grados de libertad
        Go % Modulo de corte
        Iyo % Inercia de la seccion en y
        Izo % Inercia en z
        Jo % Modulo de torsion
        Klp % Matriz de rigidez local del elemento
        L % Largo del elemento
        nodosObj % Cell con los nodos
        phi % Angulo de giro en el plano del eje neutro y las coordenadas inicial y final
        rho % Densidad
        T % Matriz de transformacion
        theta % Angulo de inclinacion de la viga
    end % private properties VigaColumna3D
    
    methods(Access = public)
        
        function obj = VigaColumna3D(etiquetaViga, nodo1Obj, nodo2Obj, r3, Iy, Iz, E, A, G, J, densidad)
            % Para definir el angulo de la viga se requiere de un vector de
            % 3 componentes que defina la posici�n de un punto en el eje y
            % de la viga. Debe esar dentro del plano (x,y) y no puede estar
            % en el eje x. (y==x) Se recomienda que se defina con respecto
            % al primer punto (x1).
            % Recordar que el eje x es el eje principal de la viga
            % El eje y es el segundo eje principal. Y z es el eje debil
            % fuera del plano.
            % Por lo mismo. Esta viga solo puede estar alineada con
            % respecto a los ejes principales. (X,Y,Z)
            %
            % y
            % |
            % z----->x ===================> VIGA
            if length(r3) ~= 3
                error('Vector r3 debe tener tres componentes');
            end
            sr3 = size(r3);
            if sr3(1) == 1
                r3 = r3';
            end
            
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
            obj.Ao = A;
            obj.Eo = E;
            obj.Iyo = Iy;
            obj.Izo = Iz;
            obj.Go = G;
            obj.Jo = J;
            obj.rho = densidad;
            obj.gdlID = [];
            
            % Calcula componentes geometricas
            n1 = nodo1Obj.obtenerCoordenadas();
            n2 = nodo2Obj.obtenerCoordenadas();
            dx = n2(1) - n1(1);
            dy = n2(2) - n1(2);
            dz = n2(3) - n1(3);
            obj.L = sqrt(dx^2+dy^2+dz^2);
            
            % Por el momento, las vigas solo pueden estar en un solo eje
            if ~((dx == 0 && dy == 0 && dz ~= 0) || (dx == 0 && dy ~= 0 && dz == 0) || (dx ~= 0 && dy == 0 && dz == 0))
                error('Como primera version, solo se puede tener vigas 3D en un solo eje principal X,Y,Z');
            end
            
            c1 = n2 - n1;
            if norm(c1) == 0
                error('Norma de N2-N1 es nula');
            end
            c2 = r3 - n1;
            if norm(c2) == 0
                error('R3 no puede ser igual al primer nodo');
            end
            c3 = cross(c1, c2);
            c4 = cross(c3, c1);
            if norm(c3) == 0 || norm(c4) == 0
                error('R3 no puede estar fuera del plano xy');
            end
            
            r1 = c1 ./ norm(c1);
            r2 = c4 ./ norm(c4);
            r3 = c3 ./ norm(c3);
            
            r = zeros(3, 3);
            r(1, 1) = r1(1);
            r(1, 2) = r1(2);
            r(1, 3) = r1(3);
            r(2, 1) = r2(1);
            r(2, 2) = r2(2);
            r(2, 3) = r2(3);
            r(3, 1) = r3(1);
            r(3, 2) = r3(2);
            r(3, 3) = r3(3);
            
            % Calcula matriz de transformacion dado el angulo
            T = zeros(12, 12);
            for i = 1:3
                for j = 1:3
                    T(i, j) = r(i, j);
                    T(3+i, 3+j) = r(i, j);
                    T(6+i, 6+j) = r(i, j);
                    T(9+i, 9+j) = r(i, j);
                end
            end
            obj.T = T;
            
            % Calcula matriz de rigidez local
            L = obj.L;
            Klp = zeros(12, 12);
            
            % Ensambla la matriz
            Klp(1, 1) = A * L^2;
            Klp(1, 7) = -A * L^2;
            Klp(2, 2) = 12 * Iz;
            Klp(2, 6) = 6 * L * Iz;
            Klp(2, 8) = -12 * Iz;
            Klp(2, 12) = 6 * L * Iz;
            Klp(3, 3) = 12 * Iy;
            Klp(3, 5) = -6 * L * Iy;
            Klp(3, 9) = -12 * Iy;
            Klp(3, 11) = -6 * L * Iy;
            Klp(4, 4) = G * J * L^2 / E;
            Klp(4, 10) = -G * J * L^2 / E;
            Klp(5, 3) = -6 * L * Iy;
            Klp(5, 5) = 4 * L^2 * Iy;
            Klp(5, 9) = 6 * L * Iy;
            Klp(5, 11) = 2 * L^2 * Iy;
            Klp(6, 2) = 6 * L * Iz;
            Klp(6, 6) = 4 * L^2 * Iz;
            Klp(6, 8) = -6 * L * Iz;
            Klp(6, 12) = 2 * L^2 * Iz;
            Klp(7, 1) = -A * L^2;
            Klp(7, 7) = A * L^2;
            Klp(8, 2) = -12 * Iz;
            Klp(8, 6) = -6 * L * Iz;
            Klp(8, 8) = 12 * Iz;
            Klp(8, 12) = -6 * L * Iz;
            Klp(9, 3) = -12 * Iy;
            Klp(9, 5) = 6 * L * Iy;
            Klp(9, 9) = 12 * Iy;
            Klp(9, 11) = 6 * L * Iy;
            Klp(10, 4) = -G * J * L^2 / E;
            Klp(10, 10) = G * J * L^2 / E;
            Klp(11, 3) = -6 * L * Iy;
            Klp(11, 5) = 2 * L^2 * Iy;
            Klp(11, 9) = 6 * L * Iy;
            Klp(11, 11) = 4 * L^2 * Iy;
            Klp(12, 2) = 6 * L * Iz;
            Klp(12, 6) = 2 * L^2 * Iz;
            Klp(12, 8) = -6 * L * Iz;
            Klp(12, 12) = 4 * L^2 * Iz;
            
            Klp = Klp .* (E / L^3);
            obj.Klp = Klp;
            
            % Fuerza equivalente de la viga
            obj.Feq = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]';
            
            % Agrega el elemento a los nodos
            for i = 1:2
                obj.nodosObj{i}.agregarElementos(obj);
            end % for i
            
        end % VigaColumna3D constructor
        
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
            
            numeroGDL = 12;
            
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
            
            m_masa = zeros(12, 1);
            m = obj.obtenerMasa();
            m_masa(1) = m * 0.333;
            m_masa(2) = m * 0.333;
            m_masa(3) = m * 0.333;
            m_masa(4) = 1e-12;
            m_masa(5) = 1e-12;
            m_masa(6) = 1e-12;
            m_masa(7) = m * 0.333;
            m_masa(8) = m * 0.333;
            m_masa(9) = m * 0.333;
            m_masa(10) = 1e-12;
            m_masa(11) = 1e-12;
            m_masa(12) = 1e-12;
            
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
            u = [u1(1), u1(2), u1(3), u1(4), u1(5), u1(6), ...
                u2(1), u2(2), u2(3), u2(4), u2(5), u2(6)]';
            
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
            gdl = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
            gdl(1) = gdlnodo1(1);
            gdl(2) = gdlnodo1(2);
            gdl(3) = gdlnodo1(3);
            gdl(4) = gdlnodo1(4);
            gdl(5) = gdlnodo1(5);
            gdl(6) = gdlnodo1(6);
            gdl(7) = gdlnodo2(1);
            gdl(8) = gdlnodo2(2);
            gdl(9) = gdlnodo2(3);
            gdl(10) = gdlnodo2(4);
            gdl(11) = gdlnodo2(5);
            gdl(12) = gdlnodo2(6);
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
            F_eq = obj.T' * obj.Feq; % 12
            
            % Agrega fuerzas equivalentes como cargas
            nodo1.agregarEsfuerzosElementoAReaccion([F_eq(1), F_eq(2), F_eq(3), F_eq(4), F_eq(5), F_eq(6)]')
            nodo2.agregarEsfuerzosElementoAReaccion([F_eq(7), F_eq(8), F_eq(9), F_eq(10), F_eq(11), F_eq(12)]')
            
            % Agrega fuerzas resistentes como cargas
            nodo1.agregarEsfuerzosElementoAReaccion([fr_global(1), fr_global(2), fr_global(3), fr_global(4), fr_global(5), fr_global(6)]');
            nodo2.agregarEsfuerzosElementoAReaccion([fr_global(7), fr_global(8), fr_global(9), fr_global(10), fr_global(11), fr_global(12)]');
            
        end % agregarFuerzaResistenteAReacciones function
        
        function guardarPropiedades(obj, archivoSalidaHandle)
            % guardarPropiedades: Guarda las propiedades del elemento en un
            % archivo
            
            fprintf(archivoSalidaHandle, '\tViga-Columna 3D %s:\n\t\tLargo:\t\t%s\n\t\tInercia y:\t%s\n\t\tInercia z:\t%s\n\t\tEo:\t\t\t%s\n\t\tMasa:\t\t%s\n', ...
                obj.obtenerEtiqueta(), num2str(obj.L), ...
                num2str(obj.Iyo), num2str(obj.Izo), num2str(obj.Eo), ...
                num2str(obj.obtenerMasa()));
            
        end % guardarPropiedades function
        
        function guardarEsfuerzosInternos(obj, archivoSalidaHandle)
            % guardarEsfuerzosInternos: Guarda los esfuerzos internos del
            % elemento
            
            fr = obj.obtenerFuerzaResistenteCoordLocal();
            v11 = pad(num2str(fr(1), '%.04f'), 10);
            v12 = pad(num2str(fr(2), '%.04f'), 10);
            v13 = pad(num2str(fr(3), '%.04f'), 10);
            m11 = pad(num2str(fr(4), '%.04f'), 10);
            m12 = pad(num2str(fr(5), '%.04f'), 10);
            m13 = pad(num2str(fr(6), '%.04f'), 10);
            v21 = pad(num2str(fr(7), '%.04f'), 10);
            v22 = pad(num2str(fr(8), '%.04f'), 10);
            v23 = pad(num2str(fr(9), '%.04f'), 10);
            m21 = pad(num2str(fr(10), '%.04f'), 10);
            m22 = pad(num2str(fr(11), '%.04f'), 10);
            m23 = pad(num2str(fr(12), '%.04f'), 10);
            
            fprintf(archivoSalidaHandle, '\n\tViga-Columna 3D %s:\n\t\tAxial:\t\t(%s %s %s) (%s %s %s)\n\t\tMomento:\t(%s %s %s) (%s %s %s)', ...
                obj.obtenerEtiqueta(), v11, v12, v13, v21, v22, v23, m11, m12, m13, m21, m22, m23);
            
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
            
            y = length(deformadas{1}) == 6;
            
        end % plotVigaDeformar function
        
        function plot(obj, deformadas, tipoLinea, grosorLinea, ~)
            % plot: Grafica un elemento
            
            % Obtiene las coordenadas de los objetos
            coord1 = obj.nodosObj{1}.obtenerCoordenadas();
            coord2 = obj.nodosObj{2}.obtenerCoordenadas();
            
            % Si hay deformacion
            if ~isempty(deformadas)
                for i = 1:length(coord1)
                    coord1(i) = coord1(i) + deformadas{1}(i);
                    coord2(i) = coord2(i) + deformadas{2}(i);
                end
            end
            
            % Grafica en forma lineal
            obj.graficarLinea(coord1, coord2, tipoLinea, grosorLinea);
            
        end % plot function
        
        function disp(obj)
            % disp: Imprime propiedades en pantalla del objeto
            
            % Imprime propiedades de la Viga-Columna-3D
            fprintf('Propiedades viga columna 3D:\n');
            disp@ComponenteModelo(obj);
            fprintf('\tLargo: %s\n\tArea: %s\n\tIy: %s\n\tIz: %s\n\tG: %s\n\tJ: %s\n\tE: %s\n\tMasa: %s\n', pad(num2str(obj.L), 12), ...
                pad(num2str(obj.Ao), 10), pad(num2str(obj.Iyo), 10), pad(num2str(obj.Izo), 10), ...
                pad(num2str(obj.Go), 10), pad(num2str(obj.Jo), 10), ...
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
            
            % Imprime matriz de transformacion
            fprintf('\tMatriz de transformacion geometrica:\n');
            disp(obj.obtenerMatrizTransformacion());
            
            dispMetodoTEFAME();
            
        end % disp function
        
    end % public methods VigaColumna3D
    
end % class VigaColumna3D