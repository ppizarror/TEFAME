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
%| Clase VigaColumna2D                                                  |
%|                                                                      |
%| Este archivo contiene la definicion de la Clase VigaColumna 2D       |
%| ColumnaViga2D es una  subclase de la clase Elemento y  corresponde a |
%| la representacion del elemento viga-columna que transmite esfuerzos  |
%| axiales y de corte.                                                  |
%|                                                                      |
%| Programado: Pablo Pizarro @ppizarror.com                             |
%| Fecha: 10/06/2018                                                    |
%|______________________________________________________________________|
%
%  Properties (Access=private):
%       nodosObj
%       gdlID
%       Eo
%       Ao
%       Io
%       dx
%       dy
%       L
%       Feq
%       T
%       Klp
%       PLOTNELEM
%  Methods:
%       vigaColumna2DObj = VigaColumna2D(etiquetaViga,nodo1Obj,nodo2Obj,Imaterial,Ematerial,densidad)
%       numeroNodos = obtenerNumeroNodos(vigaColumna2DObj)
%       nodosBiela = obtenerNodos(vigaColumna2DObj)
%       numeroGDL = obtenerNumeroGDL(vigaColumna2DObj)
%       gdlIDBiela = obtenerGDLID(vigaColumna2DObj)
%       k_global = obtenerMatrizRigidezCoordGlobal(vigaColumna2DObj)
%       k_local = obtenerMatrizRigidezCoordLocal(vigaColumna2DObj)
%       m_masa = obtenerVectorMasa(vigaColumna2DObj)
%       m = obtenerMasa(vigaColumna2DObj)
%       fr_global = obtenerFuerzaResistenteCoordGlobal(vigaColumna2DObj)
%       fr_local = obtenerFuerzaResistenteCoordLocal(vigaColumna2DObj)
%       l = obtenerLargo(vigaColumna2DObj)
%       T = obtenerMatrizTransformacion(vigaColumna2DObj)
%       theta = obtenerAngulo(vigaColumna2DObj)
%       definirGDLID(vigaColumna2DObj)
%       agregarFuerzaResistenteAReacciones(vigaColumna2DObj)
%       guardarPropiedades(vigaColumna2DObj,archivoSalidaHandle)
%       guardarEsfuerzosInternos(vigaColumna2DObj,archivoSalidaHandle)
%       disp(vigaColumna2DObj)
%  Methods SuperClass (ComponenteModelo):
%       etiqueta = obtenerEtiqueta(componenteModeloObj)
%       e = equals(componenteModeloObj,obj)
%       objID = obtenerIDObjeto(componenteModeloObj)

classdef VigaColumna2D < Elemento
    
    properties(Access = private)
        nodosObj % Cell con los nodos
        gdlID % Lista con los ID de los grados de libertad
        Ao % Area de la seccion transversal
        rho % Densidad
        Eo % Modulo de elasticidad
        Io % Inercia de la seccion
        dx % Distancia en el eje x entre los nodos
        dy % Distancia en el eje y entre los nodos
        L % Largo del elemento
        theta % Angulo de inclinacion de la viga
        Feq % Fuerza equivalente
        T % Matriz de transformacion
        Klp % Matriz de rigidez local del elemento
        PLOTNELEM % Numero de elementos en los que se discretiza para el grafico
    end % properties VigaColumna2D
    
    methods
        
        function vigaColumna2DObj = VigaColumna2D(etiquetaViga, nodo1Obj, nodo2Obj, Imaterial, Ematerial, Amaterial, densidad)
            
            % Completa con ceros si no hay argumentos
            if nargin == 0
                etiquetaViga = '';
            end % if
            if ~exist('densidad', 'var')
                densidad = 0;
            end
            
            % Llamamos al constructor de la SuperClass que es la clase Elemento
            vigaColumna2DObj = vigaColumna2DObj@Elemento(etiquetaViga);
            
            % Guarda material
            vigaColumna2DObj.nodosObj = {nodo1Obj; nodo2Obj};
            vigaColumna2DObj.Ao = Amaterial;
            vigaColumna2DObj.Eo = Ematerial;
            vigaColumna2DObj.Io = Imaterial;
            vigaColumna2DObj.rho = densidad;
            vigaColumna2DObj.gdlID = [];
            
            % Calcula componentes geometricas
            coordNodo1 = nodo1Obj.obtenerCoordenadas();
            coordNodo2 = nodo2Obj.obtenerCoordenadas();
            vigaColumna2DObj.dx = abs(coordNodo2(1)-coordNodo1(1));
            vigaColumna2DObj.dy = abs(coordNodo2(2)-coordNodo1(2));
            vigaColumna2DObj.L = sqrt(vigaColumna2DObj.dx^2+vigaColumna2DObj.dy^2);
            theta = atan(vigaColumna2DObj.dy/vigaColumna2DObj.dx);
            vigaColumna2DObj.theta = theta;
            
            % Calcula matriz de transformacion dado el angulo
            T = [cos(theta), sin(theta), 0, 0, 0, 0; ...
                -sin(theta), cos(theta), 0, 0, 0, 0; ...
                0, 0, 1, 0, 0, 0; ...
                0, 0, 0, cos(theta), sin(theta), 0; ...
                0, 0, 0, -sin(theta), cos(theta), 0; ...
                0, 0, 0, 0, 0, 1];
            vigaColumna2DObj.T = T;
            
            % Calcula matriz de rigidez local
            A = Amaterial;
            E = Ematerial;
            I = Imaterial;
            L = vigaColumna2DObj.L;
            Klp = [A * E / L, 0, 0, -A * E / L, 0, 0; ...
                0, 12 * E * I / (L^3), 6 * E * I / (L^2), 0, - 12 * E * I / (L^3), 6 * E * I / (L^2); ...
                0, 6 * E * I / (L^2), 4 * E * I / L, 0, - 6 * E * I / (L^2), 2 * E * I / L; ...
                -A * E / L, 0, 0, A * E / L, 0, 0; ...
                0, -12 * E * I / (L^3), - 6 * E * I / (L^2), 0, 12 * E * I / (L^3), -6 * E * I / (L^2); ...
                0, 6 * E * I / (L^2), 2 * E * I / L, 0, - 6 * E * I / (L^2), 4 * E * I / L];
            vigaColumna2DObj.Klp = Klp;
            
            % Fuerza equivalente de la viga
            vigaColumna2DObj.Feq = [0, 0, 0, 0, 0, 0]';
            
            % Agrega el elemento a los nodos
            for i = 1:2
                vigaColumna2DObj.nodosObj{i}.agregarElementos(vigaColumna2DObj);
            end % for i
            
            % Otros
            vigaColumna2DObj.PLOTNELEM = 10;
            
        end % VigaColumna2D constructor
        
        function l = obtenerLargo(vigaColumna2DObj)
            % obtenerLargo: Retorna el largo del elemento
            %
            % l = obtenerLargo(vigaColumna2DObj)
            
            l = vigaColumna2DObj.L;
            
        end % obtenerLargo function
        
        function numeroNodos = obtenerNumeroNodos(vigaColumna2DObj) %#ok<MANU>
            % obtenerNumeroNodos: Retorna el numero de nodos del elemento
            %
            % numeroNodos = obtenerNumeroNodos(vigaColumna2DObj)
            
            numeroNodos = 2;
            
        end % obtenerNumeroNodos function
        
        function nodosViga = obtenerNodos(vigaColumna2DObj)
            % obtenerNodos: Retorna los nodos del elemento
            %
            % nodosViga = obtenerNodos(vigaColumna2DObj)
            
            nodosViga = vigaColumna2DObj.nodosObj;
            
        end % obtenerNodos function
        
        function numeroGDL = obtenerNumeroGDL(vigaColumna2DObj) %#ok<MANU>
            % obtenerNumeroGDL: Obtiene el numero de grados de libertad del
            % elemento
            %
            % numeroGDL = obtenerNumeroGDL(vigaColumna2DObj)
            
            numeroGDL = 6;
            
        end % obtenerNumeroGDL function
        
        function gdlIDViga = obtenerGDLID(vigaColumna2DObj)
            % obtenerGDLID: Obtiene los ID de los grados de libertad del
            % elemento
            %
            % gdlIDViga = obtenerGDLID(vigaColumna2DObj)
            
            gdlIDViga = vigaColumna2DObj.gdlID;
            
        end % obtenerGDLID function
        
        function T = obtenerMatrizTransformacion(vigaColumna2DObj)
            % obtenerMatrizTransformacion: Obtiene la matriz de
            % transformacion del elemento
            %
            % T = obtenerMatrizTransformacion(vigaColumna2DObj)
            
            T = vigaColumna2DObj.T;
            
        end % obtenerMatrizTransformacion function
        
        function theta = obtenerAngulo(vigaColumna2DObj)
            % obtenerAngulo: Retorna el angulo de inclinacion del elemento
            %
            % theta = obtenerAngulo(vigaColumna2DObj)
            
            theta = vigaColumna2DObj.theta;
            
        end % obtenerAngulo function
        
        function k_global = obtenerMatrizRigidezCoordGlobal(vigaColumna2DObj)
            % obtenerMatrizRigidezCoordGlobal: Retorna la matriz de rigidez
            % en coordenadas globales
            %
            % k_global = obtenerMatrizRigidezCoordGlobal(vigaColumna2DObj)
            
            % Multiplica por la matriz de transformacion
            k_local = vigaColumna2DObj.obtenerMatrizRigidezCoordLocal();
            t_theta = vigaColumna2DObj.T;
            k_global = t_theta' * k_local * t_theta;
            
        end % obtenerMatrizRigidezCoordGlobal function
        
        function k_local = obtenerMatrizRigidezCoordLocal(vigaColumna2DObj)
            % obtenerMatrizRigidezCoordLocal: Retorna la matriz de rigidez
            % en coordenadas locales
            %
            % k_local = obtenerMatrizRigidezCoordLocal(vigaColumna2DObj)
            
            k_local = vigaColumna2DObj.Klp;
            
        end % obtenerMatrizRigidezCoordLocal function
        
        function m = obtenerMasa(vigaColumna2DObj)
            % obtenerMasa: Retorna la masa total del elemento
            %
            % m = obtenerMasa(vigaColumna2DObj)
            
            m = vigaColumna2DObj.rho * vigaColumna2DObj.L * vigaColumna2DObj.Ao;
            
        end % obtenerMasa function
        
        function m_masa = obtenerVectorMasa(vigaColumna2DObj)
            % obtenerVectorMasa: Obtiene el vector de masa del elemento
            %
            % m_masa = obtenerVectorMasa(vigaColumna2DObj)
            
            m_masa = zeros(6, 1);
            m = vigaColumna2DObj.obtenerMasa();
            m_masa(1) = m * 0.5;
            m_masa(2) = m * 0.5;
            m_masa(3) = 0;
            m_masa(4) = m * 0.5;
            m_masa(5) = m * 0.5;
            m_masa(6) = 0;
            
        end % obtenerMatrizMasa function
        
        function fr_global = obtenerFuerzaResistenteCoordGlobal(vigaColumna2DObj)
            % obtenerFuerzaResistenteCoordGlobal: Retorna la fuerza
            % resistente en coordenadas globales
            %
            % fr_global = obtenerFuerzaResistenteCoordGlobal(vigaColumna2DObj)
            
            % Obtiene fr local
            fr_local = vigaColumna2DObj.obtenerFuerzaResistenteCoordLocal();
            
            % Resta a fuerza equivalente para obtener la fuerza global
            fr_global = vigaColumna2DObj.T' * (fr_local - vigaColumna2DObj.Feq);
            
        end % obtenerFuerzaResistenteCoordGlobal function
        
        function fr_local = obtenerFuerzaResistenteCoordLocal(vigaColumna2DObj)
            % obtenerFuerzaResistenteCoordLocal: Retorna la fuerza
            % resistente en coordenadas locales
            %
            % fr_local = obtenerFuerzaResistenteCoordLocal(vigaColumna2DObj)
            
            % Obtiene los nodos
            nodo1 = vigaColumna2DObj.nodosObj{1};
            nodo2 = vigaColumna2DObj.nodosObj{2};
            
            % Obtiene los desplazamientos
            u1 = nodo1.obtenerDesplazamientos();
            u2 = nodo2.obtenerDesplazamientos();
            
            % Vector desplazamientos u'
            u = [u1(1), u1(2), u1(3), u2(1), u2(2), u2(3)]';
            
            % Obtiene K local
            k_local = vigaColumna2DObj.obtenerMatrizRigidezCoordLocal();
            
            % Obtiene u''
            u = vigaColumna2DObj.obtenerMatrizTransformacion() * u;
            
            % Calcula F
            fr_local = k_local * u;
            
        end % obtenerFuerzaResistenteCoordLocal function
        
        function definirGDLID(vigaColumna2DObj)
            % definirGDLID: Define los ID de los grados de libertad de la
            % viga columna
            %
            % definirGDLID(vigaColumna2DObj)
            
            % Se obtienen los nodos extremos
            nodo1 = vigaColumna2DObj.nodosObj{1};
            nodo2 = vigaColumna2DObj.nodosObj{2};
            
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
            vigaColumna2DObj.gdlID = gdl;
            
        end % definirGDLID function
        
        function sumarFuerzaEquivalente(vigaColumna2DObj, f)
            % sumarFuerzaEquivalente: Suma fuerza equivalente a vigas
            %
            % sumarFuerzaEquivalente(vigaColumna2DObj,f)
            
            for i = 1:length(f)
                vigaColumna2DObj.Feq(i) = vigaColumna2DObj.Feq(i) + f(i);
            end % for i
            
        end % sumarFuerzaEquivalente function
        
        function f = obtenerFuerzaEquivalente(vigaColumna2DObj)
            % obtenerFuerzaEquivalente: Obtiene la fuerza equivalente de la
            % viga columna
            %
            % f = obtenerFuerzaEquivalente(vigaColumna2DObj)
            
            f = vigaColumna2DObj.Feq;
            
        end % obtenerFuerzaEquivalente function
        
        function agregarFuerzaResistenteAReacciones(vigaColumna2DObj)
            % agregarFuerzaResistenteAReacciones: Agrega fuerza resistente
            % de la viga a las reacciones
            %
            % agregarFuerzaResistenteAReacciones(vigaColumna2DObj)
            
            % Se calcula la fuerza resistente global
            fr_global = vigaColumna2DObj.obtenerFuerzaResistenteCoordGlobal();
            
            % Carga los nodos
            nodo1 = vigaColumna2DObj.nodosObj{1};
            nodo2 = vigaColumna2DObj.nodosObj{2};
            
            % Transforma la carga equivalente como carga puntual
            F_eq = vigaColumna2DObj.T' * vigaColumna2DObj.Feq;
            
            % Agrega fuerzas equivalentes como cargas
            nodo1.agregarCarga([-F_eq(1), -F_eq(2), -F_eq(3)]')
            nodo2.agregarCarga([-F_eq(4), -F_eq(5), -F_eq(6)]')
            
            % Agrega fuerzas resistentes como cargas
            nodo1.agregarEsfuerzosElementoAReaccion([fr_global(1), fr_global(2), fr_global(3)]');
            nodo2.agregarEsfuerzosElementoAReaccion([fr_global(4), fr_global(5), fr_global(6)]');
            
        end % agregarFuerzaResistenteAReacciones function
        
        function guardarPropiedades(vigaColumna2DObj, archivoSalidaHandle)
            % guardarPropiedades: Guarda las propiedades del elemento en un
            % archivo
            %
            % guardarPropiedades(vigaColumna2DObj,archivoSalidaHandle)
            
            fprintf(archivoSalidaHandle, '\tViga-Columna 2D %s:\n\t\tLargo:\t\t%s\n\t\tInercia:\t%s\n\t\tEo:\t\t\t%s\n\t\tEI:\t\t\t%s\n\t\tMasa:\t\t%s\n', ...
                vigaColumna2DObj.obtenerEtiqueta(), num2str(vigaColumna2DObj.L), ...
                num2str(vigaColumna2DObj.Io), num2str(vigaColumna2DObj.Eo), ...
                num2str(vigaColumna2DObj.Eo*vigaColumna2DObj.Io), ...
                num2str(vigaColumna2DObj.obtenerMasa()));
            
        end % guardarPropiedades function
        
        function guardarEsfuerzosInternos(vigaColumna2DObj, archivoSalidaHandle)
            % guardarEsfuerzosInternos: Guarda los esfuerzos internos del
            % elemento
            %
            % guardarEsfuerzosInternos(vigaColumna2DObj,archivoSalidaHandle)
            
            fr = vigaColumna2DObj.obtenerFuerzaResistenteCoordGlobal();
            n1 = pad(num2str(fr(1), '%.04f'), 10);
            n2 = pad(num2str(fr(4), '%.04f'), 10);
            v1 = pad(num2str(fr(2), '%.04f'), 10);
            v2 = pad(num2str(fr(5), '%.04f'), 10);
            m1 = pad(num2str(fr(3), '%.04f'), 10);
            m2 = pad(num2str(fr(6), '%.04f'), 10);
            
            fprintf(archivoSalidaHandle, '\n\tViga-Columna 2D %s:\n\t\tAxial:\t\t%s %s\n\t\tCorte:\t\t%s %s\n\t\tMomento:\t%s %s', ...
                vigaColumna2DObj.obtenerEtiqueta(), n1, n2, v1, v2, m1, m2);
            
        end % guardarEsfuerzosInternos function
        
        function N = obtenerVectorN(elementoObj, x, l) %#ok<INUSL>
            % obtenerVectorN: Obtiene el vector de transformada N a partir
            % de x como porcentaje del largo
            %
            % N = obtenerVectorN(elementoObj,x,l)
            
            x = x * l;
            N = zeros(4, 1);
            N(1) = 1 - 3 * (x / l)^2 + 2 * (x / l)^3;
            N(2) = x * (1 - x / l)^2;
            N(3) = 3 * (x / l)^2 - 2 * (x / l)^3;
            N(4) = (x^2 / l) * (x / l - 1);
            
        end % obtenerVectorN function
        
        function y = plotVigaDeformar(elementoObj, deformadas) %#ok<INUSL>
            % plotVigaDeformar: Evalua si se grafica una viga con
            % deformacion
            %
            % plotVigaDeformar(elementoObj,deformadas)
            
            y = length(deformadas{1}) == 3;
            
        end % plotVigaDeformar function
        
        function plot(elementoObj, deformadas, tipoLinea, grosorLinea, defElem)
            % plot: Grafica un elemento
            %
            % plot(elementoObj,deformadas,tipoLinea,grosorLinea,defElem)
            
            % Obtiene las coordenadas de los objetos
            coord1 = elementoObj.nodosObj{1}.obtenerCoordenadas();
            coord2 = elementoObj.nodosObj{2}.obtenerCoordenadas();
            
            % Si hay deformacion
            if ~isempty(deformadas)
                coord1 = coord1 + deformadas{1}(1:2);
                coord2 = coord2 + deformadas{2}(1:2);
                if defElem && elementoObj.plotVigaDeformar(deformadas) && elementoObj.graficaDeformada
                    ndx = abs(coord2(1)-coord1(1));
                    ndy = abs(coord2(2)-coord1(2));
                    nl = sqrt(ndx^2+ndy^2);
                    tht = elementoObj.theta;
                    coordx = [coord1(1), deformadas{1}(3), coord2(1), deformadas{2}(3)];
                    coordy = [coord1(2), deformadas{1}(3), coord2(2), deformadas{2}(3)];
                    coordi = coord1;
                    for i = 1:elementoObj.PLOTNELEM
                        p = i / elementoObj.PLOTNELEM;
                        n = elementoObj.obtenerVectorN(p, nl);
                        coordf = [(coord1(1) + ndx * p) * cos(tht) + (coordx * n) * sin(tht), ...
                            (coordy * n) * cos(tht) + (coord1(2) + ndy * p) * sin(tht)];
                        elementoObj.graficarLinea(coordi, coordf, tipoLinea, grosorLinea);
                        coordi = coordf;
                    end
                    return;
                end
            end
            
            % Grafica en forma lineal
            elementoObj.graficarLinea(coord1, coord2, tipoLinea, grosorLinea);
            
        end % plot function
        
        function disp(vigaColumna2DObj)
            % disp: Imprime propiedades en pantalla del objeto
            %
            % disp(vigaColumna2DObj)
            
            % Imprime propiedades de la Viga-Columna-2D
            fprintf('Propiedades viga columna 2D:\n');
            disp@ComponenteModelo(vigaColumna2DObj);
            fprintf('\tLargo: %s\n\tArea: %s\n\tI: %s\n\tE: %s\n\tMasa: %s\n', pad(num2str(vigaColumna2DObj.L), 12), ...
                pad(num2str(vigaColumna2DObj.Ao), 10), pad(num2str(vigaColumna2DObj.Io), 10), ...
                pad(num2str(vigaColumna2DObj.Eo), 10), pad(num2str(vigaColumna2DObj.obtenerMasa()), 10));
            
            % Se imprime matriz de rigidez local
            fprintf('\tMatriz de rigidez coordenadas locales:\n');
            disp(vigaColumna2DObj.obtenerMatrizRigidezCoordLocal());
            
            % Se imprime matriz de rigidez global
            fprintf('\tMatriz de rigidez coordenadas globales:\n');
            disp(vigaColumna2DObj.obtenerMatrizRigidezCoordGlobal());
            
            % Imprime vector de masa
            fprintf('\tVector de masa:\n');
            disp(vigaColumna2DObj.obtenerVectorMasa());
            
            dispMetodoTEFAME();
            
        end % disp function
        
    end % methods VigaColumna2D
    
end % class VigaColumna2D