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
%| Clase Membrana                                                       |
%|                                                                      |
%| Este archivo contiene la definicion de la Clase Membrana             |
%| Membrana es una subclase de la clase Elemento y  corresponde a  la   |
%| representacion del elemento membrana bidimensional sencilla de secc- |
%| ion rectangular de cuatro nodos sometida a un estado de fuerzas.     |
%|                                                                      |
%| Programado: Pablo Pizarro @ppizarror.com                             |
%| Fecha: 27/08/2018                                                    |
%|______________________________________________________________________|
%
%  Properties (Access=private):
%       nodosObj
%       gdlID
%       E
%       nu
%       D
%       t
%       h
%       b
%       Feq
%       NPOINTS
%       rho
%  Methods:
%       obj = Membrana(etiquetaMembrana,nodo1Obj,nodo2Obj,nodo3Obj,nodo4Obj,E,nu,t,densidad)
%       numeroNodos = obtenerNumeroNodos(obj)
%       nodosMembrana = obtenerNodos(obj)
%       numeroGDL = obtenerNumeroGDL(obj)
%       gdlIDMembrana = obtenerGDLID(obj)
%       k_global = obtenerMatrizRigidezCoordGlobal(obj)
%       k_local = obtenerMatrizRigidezCoordLocal(obj)
%       fr_global = obtenerFuerzaResistenteCoordGlobal(obj)
%       fr_local = obtenerFuerzaResistenteCoordLocal(obj)
%       b = obtenerAncho(obj)
%       h = obtenerAlto(obj)
%       u = obtenerDesplazamiento(obj, x, y)
%       e = obtenerDeformaciones(obj, x, y)
%       sigma = obtenerTensiones(obj, x, y)
%       lista = crearListaTensiones(obj)
%       validarXY(obj, x, y)
%       definirGDLID(obj)
%       agregarFuerzaResistenteAReacciones(obj)
%       guardarPropiedades(obj,archivoSalidaHandle)
%       guardarEsfuerzosInternos(obj,archivoSalidaHandle)
%       disp(obj)
%  Methods SuperClass (ComponenteModelo):
%       etiqueta = obtenerEtiqueta(obj)
%       e = equals(obj,obj)
%       objID = obtenerIDObjeto(obj)

classdef Membrana < Elemento
    
    properties(Access = private)
        nodosObj % Lista de nodos de la membrana
        gdlID % ID de los grados de libertad
        E % Constante elastica del material
        nu % Modulo de Poisson
        D % Matriz de constantes elasticas
        t % Ancho de la membrana
        h % Alto de la membrana desde el eje (r,s)
        b % Largo de la membrana desde el eje (r,s)
        Feq % Vector de fuerzas equivalentes en nodos
        NPOINTS % Numero de interpolaciones
        rho % Densidad de la membrana
    end % properties Membrana
    
    methods
        
        function obj = Membrana(etiquetaMembrana, nodo1Obj, nodo2Obj, nodo3Obj, nodo4Obj, E, nu, t, densidad)
            % Membrana: Constructor de clase, crea una membrana de 4
            % vertices planar
            
            % Si no se pasan argumentos se crean vacios
            if nargin == 0
                etiquetaMembrana = '';
            end % if
            if ~exist('densidad', 'var')
                densidad = 0;
            end
            
            % Llamamos al constructor de la SuperClass que es la clase Elemento
            obj = obj@Elemento(etiquetaMembrana);
            
            % Guarda material
            obj.nodosObj = {nodo1Obj; nodo2Obj; nodo3Obj; nodo4Obj};
            obj.E = E;
            obj.nu = nu;
            obj.rho = densidad;
            
            % ID de los grados de libertad (4 aristas)
            obj.gdlID = [];
            
            % Calcula matriz D de constantes elasticas (constitutiva)
            obj.D = E * [ ...
                1 / (1 - nu^2), nu / (1 - nu^2), 0; ...
                nu / (1 - nu^2), 1 / (1 - nu^2), 0; ...
                0, 0, 1 / (2 + 2 * nu)];
            
            % Calcula largo (2b) y alto (2h), se usa el siguiente orden:
            %
            %           4 ------------- 3
            %           |       y       |
            %        2h |       #x      |
            %           |               |
            %           1 ------------- 2
            %                  2b
            %
            coordNodo1 = nodo1Obj.obtenerCoordenadas();
            coordNodo2 = nodo2Obj.obtenerCoordenadas();
            coordNodo3 = nodo3Obj.obtenerCoordenadas();
            coordNodo4 = nodo4Obj.obtenerCoordenadas();
            
            db1 = abs(coordNodo1(1)-coordNodo2(1)) / 2;
            db2 = abs(coordNodo3(1)-coordNodo4(1)) / 2;
            dh1 = abs(coordNodo1(2)-coordNodo4(2)) / 2;
            dh2 = abs(coordNodo2(2)-coordNodo3(2)) / 2;
            if (db1 ~= db2)
                error('Dimensiones no correctas en @x Membrana ID %s', etiquetaMembrana);
            end
            if (dh1 ~= dh2)
                error('Dimensiones no correctas en @y Membrana ID %s', etiquetaMembrana);
            end
            
            obj.b = db1;
            obj.h = dh1;
            obj.t = t;
            
            % Fuerza equivalente de la membrana
            obj.Feq = [0, 0, 0, 0, 0, 0, 0, 0]'; % 8x1
            
            % Numero de puntos de la malla, itera segun alto y largo
            obj.NPOINTS = 15; % (NPOINTS+1)^2 puntos totales
            
        end % Membrana constructor
        
        function b = obtenerAncho(obj)
            % obtenerAncho: Retorna el ancho de la membrana
            
            b = 2 * obj.b;
            
        end % obtenerAncho function
        
        function h = obtenerAlto(obj)
            % obtenerAlto: Retorna el alto de la membrana
            
            h = 2 * obj.h;
            
        end % obtenerAlto function
        
        function numeroNodos = obtenerNumeroNodos(obj) %#ok<MANU>
            % obtenerNumeroNodos: Retorna el numero de nodos de la membrana
            
            numeroNodos = 4;
            
        end % obtenerNumeroNodos function
        
        function nodosMembrana = obtenerNodos(obj)
            % obtenerNodos: Retorna los nodos de la membrana
            
            nodosMembrana = obj.nodosObj;
            
        end % obtenerNodos function
        
        function numeroGDL = obtenerNumeroGDL(obj) %#ok<MANU>
            % obtenerNumeroGDL: Retorna el numero de grados de libertad de
            % la membrana
            
            numeroGDL = 8;
            
        end % obtenerNumeroGDL function
        
        function gdlIDMembrana = obtenerGDLID(obj)
            % obtenerGDLID: Retorna el ID de los grados de libertad de la
            % membrana
            
            gdlIDMembrana = obj.gdlID;
            
        end % obtenerGDLID function
        
        function m = obtenerMasa(obj)
            % obtenerMasa: Retorna la masa total del elemento
            
            m = obj.rho * obj.b * obj.h * obj.t;
            
        end % obtenerMasa function
        
        function m_masa = obtenerVectorMasa(obj)
            % obtenerVectorMasa: Obtiene el vector de masa del elemento
            
            m_masa = zeros(8, 1);
            m = obj.obtenerMasa();
            m_masa(1) = m * 0.25;
            m_masa(2) = m * 0.25;
            m_masa(3) = m * 0.25;
            m_masa(4) = m * 0.25;
            m_masa(5) = m * 0.25;
            m_masa(6) = m * 0.25;
            m_masa(7) = m * 0.25;
            m_masa(8) = m * 0.25;
            
        end % obtenerMatrizMasa function
        
        function k_global = obtenerMatrizRigidezCoordGlobal(obj)
            % obtenerMatrizRigidezCoordGlobal: Retorna la matriz de rigidez
            % de la membrana en coordenadas globales
            
            % Matriz global igual a la local, no hay rotacion
            k_global = obj.obtenerMatrizRigidezCoordLocal();
            
        end % obtenerMatrizRigidezCoordGlobal function
        
        function k_local = obtenerMatrizRigidezCoordLocal(obj)
            % obtenerMatrizRigidezCoordLocal: Retorna la matriz de rigidez
            % de la membrana en coordenadas locales
            
            % Crea la matriz vacia de 8x8
            k_local = zeros(8, 8);
            
            % Calcula valores iniciales
            a1 = (obj.t * obj.h * obj.D(1, 1)) / (6 * obj.b);
            a2 = (obj.t * obj.b * obj.D(2, 2)) / (6 * obj.h);
            a3 = (obj.t * obj.D(1, 2)) / (4);
            a4 = (obj.t * obj.b * obj.D(3, 3)) / (6 * obj.h);
            a5 = (obj.t * obj.h * obj.D(3, 3)) / (6 * obj.b);
            a6 = (obj.t * obj.D(3, 3)) / (4);
            A = [a1; a2; a3; a4; a5; a6];
            
            % Crea las funciones
            aij = @(i, j) (A(i) + A(j));
            bij = @(i, j) (A(i) - A(j));
            cij = @(i, j) (A(i) - 2 * A(j));
            
            % Aplica valores T supr
            k_local(1, 1) = 2 * aij(1, 4);
            k_local(1, 2) = aij(3, 6);
            k_local(1, 3) = cij(4, 1);
            k_local(1, 4) = bij(3, 6);
            k_local(1, 5) = -aij(1, 4);
            k_local(1, 6) = -aij(3, 6);
            k_local(1, 7) = cij(1, 4);
            k_local(1, 8) = bij(6, 3);
            
            k_local(2, 2) = 2 * aij(2, 4);
            k_local(2, 3) = bij(6, 3);
            k_local(2, 4) = cij(2, 5);
            k_local(2, 5) = -aij(3, 6);
            k_local(2, 6) = -aij(2, 5);
            k_local(2, 7) = bij(3, 6);
            k_local(2, 8) = cij(5, 2);
            
            k_local(3, 3) = 2 * aij(1, 4);
            k_local(3, 4) = -aij(3, 6);
            k_local(3, 5) = cij(1, 4);
            k_local(3, 6) = bij(3, 6);
            k_local(3, 7) = -aij(1, 4);
            k_local(3, 8) = aij(6, 3);
            
            k_local(4, 4) = 2 * aij(2, 4);
            k_local(4, 5) = bij(6, 3);
            k_local(4, 6) = cij(5, 2);
            k_local(4, 7) = aij(3, 6);
            k_local(4, 8) = -aij(5, 2);
            
            k_local(5, 5) = 2 * aij(1, 4);
            k_local(5, 6) = aij(3, 6);
            k_local(5, 7) = cij(4, 1);
            k_local(5, 8) = -bij(6, 3);
            
            k_local(6, 6) = 2 * aij(2, 4);
            k_local(6, 7) = bij(6, 3);
            k_local(6, 8) = cij(2, 5);
            
            k_local(7, 7) = 2 * aij(1, 4);
            k_local(7, 8) = -aij(3, 6);
            
            k_local(8, 8) = 2 * aij(2, 4);
            
            % Aplica traspuesta
            for i = 2:8 % fila
                for j = 1:8 % columna
                    if (j < i)
                        k_local(i, j) = k_local(j, i);
                    end
                end % for j
            end % for i
            
        end % obtenerMatrizRigidezCoordLocal function
        
        function validarXY(obj, x, y)
            % validarXY: Valida que un punto (x,y) pertenezca a la membrana
            
            if (abs(x) > obj.b || abs(y) > obj.h)
                error('Valores x e y exceden dimensiones permitidas');
            end
            
        end % validarXY function
        
        function u = obtenerDesplazamiento(obj, x, y)
            % obtenerDesplazamiento: Calcula el desplazamiento en cualquier
            % punto de la membrana
            
            % Verifica que x e y sean validos
            obj.validarXY(x, y);
            
            % Obtiene los factores N1, N2, N3, N4
            N1 = (obj.b - x) * (obj.h - y) / (4 * obj.b * obj.h);
            N2 = (obj.b + x) * (obj.h - y) / (4 * obj.b * obj.h);
            N3 = (obj.b + x) * (obj.h + y) / (4 * obj.b * obj.h);
            N4 = (obj.b - x) * (obj.h + y) / (4 * obj.b * obj.h);
            
            % Calcula la matriz N [2x8]
            N = [N1, 0, N2, 0, N3, 0, N4, 0; ...
                0, N1, 0, N2, 0, N3, 0, N4];
            
            % Obtiene los nodos
            nodo1 = obj.nodosObj{1};
            nodo2 = obj.nodosObj{2};
            nodo3 = obj.nodosObj{3};
            nodo4 = obj.nodosObj{4};
            
            % Obtiene los desplazamientos
            u1 = nodo1.obtenerDesplazamientos();
            u2 = nodo2.obtenerDesplazamientos();
            u3 = nodo3.obtenerDesplazamientos();
            u4 = nodo4.obtenerDesplazamientos();
            
            % Vector desplazamientos u'
            d = [u1(1), u1(2), u2(1), u2(2), u3(1), u3(2), u4(1), u4(2)]';
            
            % Multiplica por d [8x1] => vector u [2x8]x[8x1] => [2x1]
            u = N * d;
            
        end % obtenerDesplazamiento function
        
        function e = obtenerDeformaciones(obj, x, y)
            % obtenerDeformaciones: Obtiene el vector de deformaciones [3x1]
            % una vez se tiene el vector de desplazamientos
            
            % Verifica que x e y sean validos
            obj.validarXY(x, y);
            
            % Calcula los factores a1,a2,a3 y a4
            a1 = (obj.b + x) / (4 * obj.b * obj.h);
            a2 = (obj.b - x) / (4 * obj.b * obj.h);
            a3 = (obj.h + y) / (4 * obj.b * obj.h);
            a4 = (obj.h - y) / (4 * obj.b * obj.h);
            
            % Calcula el vector B [3x8]
            B = [-a4, 0, a4, 0, a3, 0, -a3, 0; ...
                0, -a2, 0, -a1, 0, a1, 0, a2; ...
                -a2, -a4, -a1, a4, a1, a3, a2, -a3];
            
            % Obtiene los nodos
            nodo1 = obj.nodosObj{1};
            nodo2 = obj.nodosObj{2};
            nodo3 = obj.nodosObj{3};
            nodo4 = obj.nodosObj{4};
            
            % Obtiene el vector de desplazamientos de los nodos
            u1 = nodo1.obtenerDesplazamientos();
            u2 = nodo2.obtenerDesplazamientos();
            u3 = nodo3.obtenerDesplazamientos();
            u4 = nodo4.obtenerDesplazamientos();
            
            % Vector desplazamientos u' [8x1]
            d = [u1(1), u1(2), u2(1), u2(2), u3(1), u3(2), u4(1), u4(2)]';
            
            % Calcula las deformaciones [3x8]x[8x1] = [3x1]
            e = B * d;
            
        end % obtenerDeformaciones function
        
        function sigma = obtenerTensiones(obj, x, y)
            % obtenerTensiones: Retorna las tensiones una vez se corre el analisis
            
            % Obtiene las deformaciones
            e = obj.obtenerDeformaciones(x, y);
            
            % Retorna las tensiones [3x3]x[3x1] = [3x1]
            sigma = obj.D * e;
            
        end % obtenerTensiones function
        
        function fr_global = obtenerFuerzaResistenteCoordGlobal(obj)
            % obtenerFuerzaResistenteCoordGlobal: Retorna la fuerza
            % resistente de la membrana en coordenadas globales
            
            % Obtiene fr local
            fr_local = obj.obtenerFuerzaResistenteCoordLocal();
            
            % Resta a fuerza equivalente para obtener la fuerza global
            fr_global = fr_local - obj.Feq;
            
        end % obtenerFuerzaResistenteCoordGlobal function
        
        function fr_local = obtenerFuerzaResistenteCoordLocal(obj)
            % obtenerFuerzaResistenteCoordLocal: Retorna la fuerza
            % resistente de la membrana en coordenadas locales
            
            % Obtiene los nodos
            nodo1 = obj.nodosObj{1};
            nodo2 = obj.nodosObj{2};
            nodo3 = obj.nodosObj{3};
            nodo4 = obj.nodosObj{4};
            
            % Obtiene los desplazamientos
            u1 = nodo1.obtenerDesplazamientos();
            u2 = nodo2.obtenerDesplazamientos();
            u3 = nodo3.obtenerDesplazamientos();
            u4 = nodo4.obtenerDesplazamientos();
            
            % Vector desplazamientos u'
            u = [u1(1), u1(2), u2(1), u2(2), u3(1), u3(2), u4(1), u4(2)]';
            
            % Obtiene K local
            k_local = obj.obtenerMatrizRigidezCoordLocal();
            
            % Calcula F
            fr_local = k_local * u;
            
        end % obtenerFuerzaResistenteCoordLocal function
        
        function definirGDLID(obj)
            % definirGDLID: Define los ID de los grados de libertad de la
            % membrana
            
            % Se obtienen los nodos extremos
            nodo1 = obj.nodosObj{1};
            nodo2 = obj.nodosObj{2};
            nodo3 = obj.nodosObj{3};
            nodo4 = obj.nodosObj{4};
            
            % Se obtienen los gdl de los nodos
            gdlnodo1 = nodo1.obtenerGDLID();
            gdlnodo2 = nodo2.obtenerGDLID();
            gdlnodo3 = nodo3.obtenerGDLID();
            gdlnodo4 = nodo4.obtenerGDLID();
            
            % Se establecen gdl
            gdl = [0, 0, 0, 0, 0, 0, 0, 0];
            gdl(1) = gdlnodo1(1);
            gdl(2) = gdlnodo1(2);
            gdl(3) = gdlnodo2(1);
            gdl(4) = gdlnodo2(2);
            gdl(5) = gdlnodo3(1);
            gdl(6) = gdlnodo3(2);
            gdl(7) = gdlnodo4(1);
            gdl(8) = gdlnodo4(2);
            obj.gdlID = gdl;
            
        end % definirGDLID function
        
        function sumarFuerzaEquivalente(obj, nodo, f)
            % sumarFuerzaEquivalente: Suma las fuerzas equivalentes de la
            % membrana
            
            fnodo = length(f); % Largo del vector
            nodo = floor(nodo); % Se redondea
            if (nodo < 0 || nodo > 4)
                error('Numero de nodo invalido @sumarFuerzaEquivalente Nodo %s', nodo);
            end
            pos = nodo * fnodo - 1; % Posicion de la fuerza
            for i = 1:fnodo
                obj.Feq(pos+i-1) = obj.Feq(pos+i-1) + f(i);
            end % for i
            
        end % sumarFuerzaEquivalente function
        
        function agregarFuerzaResistenteAReacciones(obj)
            % agregarFuerzaResistenteAReacciones: Agrega la fuerza
            % equivalente de la membrana a las reacciones
            
            % Se calcula la fuerza resistente global
            fr_global = obj.obtenerFuerzaResistenteCoordGlobal();
            
            % Carga los nodos
            nodo1 = obj.nodosObj{1};
            nodo2 = obj.nodosObj{2};
            nodo3 = obj.nodosObj{3};
            nodo4 = obj.nodosObj{4};
            
            % Agrega fuerzas equivalentes como cargas
            nodo1.agregarCarga(-[obj.Feq(1), obj.Feq(2)]');
            nodo2.agregarCarga(-[obj.Feq(3), obj.Feq(4)]');
            nodo3.agregarCarga(-[obj.Feq(5), obj.Feq(6)]');
            nodo4.agregarCarga(-[obj.Feq(7), obj.Feq(8)]');
            
            % Agrega fuerzas resistentes como cargas
            nodo1.agregarEsfuerzosElementoAReaccion([fr_global(1), fr_global(2)]');
            nodo2.agregarEsfuerzosElementoAReaccion([fr_global(3), fr_global(4)]');
            nodo3.agregarEsfuerzosElementoAReaccion([fr_global(5), fr_global(6)]');
            nodo4.agregarEsfuerzosElementoAReaccion([fr_global(7), fr_global(8)]');
            
        end % agregarFuerzaResistenteAReacciones function
        
        function guardarPropiedades(obj, archivoSalidaHandle)
            % guardarPropiedades: Guarda las propiedades de la membrana en
            % un archivo
            
            % Carga los nodos
            nodo1 = obj.nodosObj{1};
            nodo2 = obj.nodosObj{2};
            nodo3 = obj.nodosObj{3};
            nodo4 = obj.nodosObj{4};
            
            % Escribe la membrana en el archivo
            fprintf(archivoSalidaHandle, '\tMembrana %s:\n\t\tAncho (2b):\t\t%s\n\t\tAlto (2h):\t\t%s\n\t\tEspesor (t):\t%s\n\t\tE:\t\t\t\t%s\n\t\tv:\t\t\t\t%s\n\t\tMasa:\t\t\t%s\n\t\tNodos:\t\t\t%s %s %s %s\n', ...
                obj.obtenerEtiqueta(), num2str(2*obj.b), num2str(2*obj.h), ...
                num2str(obj.t), num2str(obj.E), num2str(obj.nu), ...
                num2str(obj.obtenerMasa()), nodo1.obtenerEtiqueta(), ...
                nodo2.obtenerEtiqueta(), nodo3.obtenerEtiqueta(), nodo4.obtenerEtiqueta());
            
        end % guardarPropiedades function
        
        function lista = crearListaTensiones(obj)
            % crearListaTensiones: Itera segun x e y
            
            % Elementos totales
            el = (obj.NPOINTS + 1)^2;
            lista = zeros(el, 7);
            
            % Calcula los dx y dy para avanzar segun NPOINTS
            dx = (2 * obj.b) / (obj.NPOINTS + 1);
            dy = (2 * obj.h) / (obj.NPOINTS + 1);
            
            % Obtiene las coordenadas del elemento con respecto al
            % global (0,0) asociado al nodo 1
            cglob = obj.nodosObj{1}.obtenerCoordenadas();
            
            % Avanza por cada NPOINT y obtiene tensiones
            k = 1;
            for i = 1:(obj.NPOINTS + 2) % Avanza en el ancho
                for j = 1:(obj.NPOINTS + 2) % Avanza en el alto
                    
                    % Obtiene coordenadas (x,y)
                    x = -obj.b + (i - 1) * dx;
                    y = -obj.h + (j - 1) * dy;
                    
                    % Obtiene tensiones y las guarda
                    ten = obj.obtenerTensiones(x, y);
                    lista(k, 1) = cglob(1) + x + obj.b;
                    lista(k, 2) = cglob(2) + y + obj.h;
                    lista(k, 3) = x;
                    lista(k, 4) = y;
                    lista(k, 5) = ten(1);
                    lista(k, 6) = ten(2);
                    lista(k, 7) = ten(3);
                    
                    % Aumenta el contador
                    k = k + 1;
                    
                end % for j
            end % for i
            
        end % crearListaTensiones function
        
        function guardarEsfuerzosInternos(obj, archivoSalidaHandle)
            % guardarEsfuerzosInternos: Guarda los esfuerzos internos de la
            % membrana en un archivo
            
            fr = obj.obtenerFuerzaResistenteCoordGlobal();
            
            % Indica si se guardan las tensiones
            GUARDAR_TENSIONES = true;
            
            % Obtiene las fuerzas para cada elemento
            n1x = pad(num2str(fr(1), '%.04f'), 10);
            n1y = pad(num2str(fr(2), '%.04f'), 10);
            n2x = pad(num2str(fr(3), '%.04f'), 10);
            n2y = pad(num2str(fr(4), '%.04f'), 10);
            n3x = pad(num2str(fr(5), '%.04f'), 10);
            n3y = pad(num2str(fr(6), '%.04f'), 10);
            n4x = pad(num2str(fr(7), '%.04f'), 10);
            n4y = pad(num2str(fr(8), '%.04f'), 10);
            
            % Dibuja las fuerzas (fx,fy) en cada nodo
            fprintf(archivoSalidaHandle, '\n\tMembrana %s:\n\t\tNodo 1 (-b, -h): %s\t%s\n\t\tNodo 2 (+b, -h): %s\t%s\n\t\tNodo 3 (+b, +h): %s\t%s\n\t\tNodo 4 (-b, +h): %s\t%s', ...
                obj.obtenerEtiqueta(), n1x, n1y, n2x, n2y, n3x, n3y, n4x, n4y);
            
            % Dibuja las tensiones
            fprintf(archivoSalidaHandle, '\n\t\tTensiones %s [GLOBALX GLOBALY X Y SIGMAX SIGMAY SIGMAXY DESPLX DESPLY]:', obj.obtenerEtiqueta());
            
            % Crea la lista de tensiones y las dibuja
            if GUARDAR_TENSIONES
                tension = obj.crearListaTensiones();
                for i = 1:length(tension)
                    globalx = pad(num2str(tension(i, 1), '%.04f'), 10);
                    globaly = pad(num2str(tension(i, 2), '%.04f'), 10);
                    x = pad(num2str(tension(i, 3), '%.04f'), 10);
                    y = pad(num2str(tension(i, 4), '%.04f'), 10);
                    sigmax = pad(num2str(tension(i, 5), '%.04f'), 10);
                    sigmay = pad(num2str(tension(i, 6), '%.04f'), 10);
                    sigmaxy = pad(num2str(tension(i, 7), '%.04f'), 10);
                    despl = obj.obtenerDesplazamiento(tension(i, 3), tension(i, 4));
                    desplx = pad(num2str(despl(1), '%.04f'), 10);
                    desply = pad(num2str(despl(2), '%.04f'), 10);
                    fprintf(archivoSalidaHandle, '\n\t\t\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s', ...
                        globalx, globaly, x, y, sigmax, sigmay, sigmaxy, desplx, desply);
                end % for i
            end
            
        end % guardarEsfuerzosInternos function
        
        function plot(obj, deformadas, tipoLinea, grosorLinea, ~)
            % plot: Grafica un elemento
            
            % Obtiene las coordenadas de los objetos
            coord1 = obj.nodosObj{1}.obtenerCoordenadas();
            coord2 = obj.nodosObj{2}.obtenerCoordenadas();
            coord3 = obj.nodosObj{3}.obtenerCoordenadas();
            coord4 = obj.nodosObj{4}.obtenerCoordenadas();
            
            % Si hay deformadas
            if ~isempty(deformadas)
                coord1 = coord1 + deformadas{1};
                coord2 = coord2 + deformadas{2};
                coord3 = coord3 + deformadas{3};
                coord4 = coord4 + deformadas{4};
            end
            
            % Grafica el elemento
            obj.graficarLinea(coord1, coord2, tipoLinea, grosorLinea);
            obj.graficarLinea(coord2, coord3, tipoLinea, grosorLinea);
            obj.graficarLinea(coord3, coord4, tipoLinea, grosorLinea);
            obj.graficarLinea(coord4, coord1, tipoLinea, grosorLinea);
            
        end % plot function
        
        function disp(obj)
            % disp: Imprime propiedades de la membrana en la consola
            
            fprintf('Propiedades membrana:\n\t');
            disp@ComponenteModelo(obj);
            
            fprintf('\t\tAncho (2b): %s\tAlto (2h): %s\tE: %s\tv: %s\n', pad(num2str(2*obj.b), 10), ...
                pad(num2str(2*obj.h), 10), pad(num2str(obj.E), 10), pad(num2str(obj.nu), 10));
            
            % Se imprime matriz de rigidez local
            fprintf('\tMatriz de rigidez coordenadas locales:\n');
            disp(obj.obtenerMatrizRigidezCoordLocal());
            
            % Se imprime matriz de rigidez global
            fprintf('\tMatriz de rigidez coordenadas globales:\n');
            disp(obj.obtenerMatrizRigidezCoordGlobal());
            
            dispMetodoTEFAME();
            
        end % disp function
        
    end % methods Membrana
    
end % class Membrana