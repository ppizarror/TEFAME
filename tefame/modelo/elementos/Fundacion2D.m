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
%| Clase Fundacion2D                                                  |
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
%       Fundacion2DObj = Fundacion2D(etiquetaViga,nodo1Obj,nodo2Obj,Imaterial,Ematerial,densidad)
%       numeroNodos = obtenerNumeroNodos(Fundacion2DObj)
%       nodosBiela = obtenerNodos(Fundacion2DObj)
%       numeroGDL = obtenerNumeroGDL(Fundacion2DObj)
%       gdlIDBiela = obtenerGDLID(Fundacion2DObj)
%       k_global = obtenerMatrizRigidezCoordGlobal(Fundacion2DObj)
%       k_local = obtenerMatrizRigidezCoordLocal(Fundacion2DObj)
%       m_masa = obtenerVectorMasa(Fundacion2DObj)
%       m = obtenerMasa(Fundacion2DObj)
%       fr_global = obtenerFuerzaResistenteCoordGlobal(Fundacion2DObj)
%       fr_local = obtenerFuerzaResistenteCoordLocal(Fundacion2DObj)
%       l = obtenerLargo(Fundacion2DObj)
%       T = obtenerMatrizTransformacion(Fundacion2DObj)
%       theta = obtenerAngulo(Fundacion2DObj)
%       definirGDLID(Fundacion2DObj)
%       agregarFuerzaResistenteAReacciones(Fundacion2DObj)
%       guardarPropiedades(Fundacion2DObj,archivoSalidaHandle)
%       guardarEsfuerzosInternos(Fundacion2DObj,archivoSalidaHandle)
%       disp(Fundacion2DObj)
%  Methods SuperClass (ComponenteModelo):
%       etiqueta = obtenerEtiqueta(componenteModeloObj)
%       e = equals(componenteModeloObj,obj)
%       objID = obtenerIDObjeto(componenteModeloObj)

classdef Fundacion2D < Elemento
    
    properties(Access = private)
        nodosObj % Cell con los nodos
        gdlID % Lista con los ID de los grados de libertad
        meq % Masa del elemento
        keq % Rigidez de la fundacion
        dx % Distancia en el eje x entre los nodos
        dy % Distancia en el eje y entre los nodos
        L % Largo del elemento
        theta 
        Feq % Fuerza equivalente
        T % Matriz de transformacion
        Klp % Matriz de rigidez local del elemento
        PLOTNELEM % Numero de elementos en los que se discretiza para el grafico
    end % properties Fundacion2D
    
    methods
        
        function Fundacion2DObj = Fundacion2D(etiquetaViga, nodo1Obj, nodo2Obj, Masaelemento, Kelemento)
            
            % Completa con ceros si no hay argumentos
            if nargin == 0
                etiquetaViga = '';
            end % if
            
            % Llamamos al constructor de la SuperClass que es la clase Elemento
            Fundacion2DObj = Fundacion2DObj@Elemento(etiquetaViga);
            
            % Guarda material
            Fundacion2DObj.nodosObj = {nodo1Obj; nodo2Obj};
            Fundacion2DObj.meq = Masaelemento;
            Fundacion2DObj.keq = Kelemento;
            Fundacion2DObj.gdlID = [];
            
            
            % Calcula componentes geometricas
            coordNodo1 = nodo1Obj.obtenerCoordenadas();
            coordNodo2 = nodo2Obj.obtenerCoordenadas();
            Fundacion2DObj.dx = abs(coordNodo2(1)-coordNodo1(1));
            Fundacion2DObj.dy = abs(coordNodo2(2)-coordNodo1(2));
            Fundacion2DObj.L = sqrt(Fundacion2DObj.dx^2+Fundacion2DObj.dy^2);
            theta = atan(Fundacion2DObj.dy/Fundacion2DObj.dx);
            Fundacion2DObj.theta = theta;
            
            T = [cos(theta), sin(theta), 0, 0, 0, 0; ...
                -sin(theta), cos(theta), 0, 0, 0, 0; ...
                0, 0, 1, 0, 0, 0; ...
                0, 0, 0, cos(theta), sin(theta), 0; ...
                0, 0, 0, -sin(theta), cos(theta), 0; ...
                0, 0, 0, 0, 0, 1];
            Fundacion2DObj.T = T;
            
            % Fuerza equivalente de la viga
            Fundacion2DObj.Feq = [0, 0, 0, 0, 0, 0]';
            
            % Agrega el elemento a los nodos
            for i = 1:2
                Fundacion2DObj.nodosObj{i}.agregarElementos(Fundacion2DObj);
            end % for i
            
            % Otros
            Fundacion2DObj.PLOTNELEM = 10;
            
        end % Fundacion2D constructor
        
        function l = obtenerLargo(Fundacion2DObj)
            % obtenerLargo: Retorna el largo del elemento
            %
            % l = obtenerLargo(Fundacion2DObj)
            
            l = Fundacion2DObj.L;
            
        end % obtenerLargo function
        
        function numeroNodos = obtenerNumeroNodos(Fundacion2DObj) %#ok<MANU>
            % obtenerNumeroNodos: Retorna el numero de nodos del elemento
            %
            % numeroNodos = obtenerNumeroNodos(Fundacion2DObj)
            
            numeroNodos = 2;
            
        end % obtenerNumeroNodos function
        
        function nodosViga = obtenerNodos(Fundacion2DObj)
            % obtenerNodos: Retorna los nodos del elemento
            %
            % nodosViga = obtenerNodos(Fundacion2DObj)
            
            nodosViga = Fundacion2DObj.nodosObj;
            
        end % obtenerNodos function
        
        function numeroGDL = obtenerNumeroGDL(Fundacion2DObj) %#ok<MANU>
            % obtenerNumeroGDL: Obtiene el numero de grados de libertad del
            % elemento
            %
            % numeroGDL = obtenerNumeroGDL(Fundacion2DObj)
            
            numeroGDL = 6;
            
        end % obtenerNumeroGDL function
        
        function gdlIDViga = obtenerGDLID(Fundacion2DObj)
            % obtenerGDLID: Obtiene los ID de los grados de libertad del
            % elemento
            %
            % gdlIDViga = obtenerGDLID(Fundacion2DObj)
            
            gdlIDViga = Fundacion2DObj.gdlID;
            
        end % obtenerGDLID function
        
        function T = obtenerMatrizTransformacion(Fundacion2DObj)
            % obtenerMatrizTransformacion: Obtiene la matriz de
            % transformacion del elemento
            %
            % T = obtenerMatrizTransformacion(Fundacion2DObj)
            
            T = Fundacion2DObj.T;
            
        end % obtenerMatrizTransformacion function
           
        function k_global = obtenerMatrizRigidezCoordGlobal(Fundacion2DObj)
            % obtenerMatrizRigidezCoordGlobal: Retorna la matriz de rigidez
            % en coordenadas globales
            %
            % k_global = obtenerMatrizRigidezCoordGlobal(Fundacion2DObj)
            
            % Multiplica por la matriz de transformacion
            k_local = Fundacion2DObj.obtenerMatrizRigidezCoordLocal();
            t_theta = Fundacion2DObj.T;
            k_global = t_theta' * k_local * t_theta;
            
        end % obtenerMatrizRigidezCoordGlobal function
        
        function k_local = obtenerMatrizRigidezCoordLocal(Fundacion2DObj)
            % obtenerMatrizRigidezCoordLocal: Retorna la matriz de rigidez
            % en coordenadas locales
            %
            % k_local = obtenerMatrizRigidezCoordLocal(Fundacion2DObj)
            
            k_local = Fundacion2DObj.keq .* [1, 0, 0, -1, 0, 0; ...
                0, 1, 1, 0, -1, 1; ...
                0, 1, 1, 0, - 1, 1; ...
                -1, 0, 0, 1, 0, 0; ...
                0, -1, - 1, 0, 1, -1; ...
                0, 1, 1, 0, - 1, 1];
            
        end % obtenerMatrizRigidezCoordLocal function
        
        function m = obtenerMasa(Fundacion2DObj)
            % obtenerMasa: Retorna la masa total del elemento
            %
            % m = obtenerMasa(Fundacion2DObj)
            
            m = Fundacion2DObj.meq;
            
        end % obtenerMasa function
        
        function m_masa = obtenerVectorMasa(Fundacion2DObj)
            % obtenerVectorMasa: Obtiene el vector de masa del elemento
            %
            % m_masa = obtenerVectorMasa(vigaColumna2DObj)
            
            m_masa = zeros(6, 1);
            m = Fundacion2DObj.obtenerMasa();
            m_masa(1) = m * 0.5;
            m_masa(2) = m * 0.5;
            m_masa(3) = 1e-6;
            m_masa(4) = m * 0.5;
            m_masa(5) = m * 0.5;
            m_masa(6) = 1e-6;
            
        end % obtenerMatrizMasa function
        
        function fr_global = obtenerFuerzaResistenteCoordGlobal(Fundacion2DObj)
            % obtenerFuerzaResistenteCoordGlobal: Retorna la fuerza
            % resistente en coordenadas globales
            %
            % fr_global = obtenerFuerzaResistenteCoordGlobal(Fundacion2DObj)
            
            % Obtiene fr local
            fr_local = Fundacion2DObj.obtenerFuerzaResistenteCoordLocal();
            
            % Resta a fuerza equivalente para obtener la fuerza global
            fr_global = Fundacion2DObj.T' * (fr_local - Fundacion2DObj.Feq);
            
        end % obtenerFuerzaResistenteCoordGlobal function
        
        function fr_local = obtenerFuerzaResistenteCoordLocal(Fundacion2DObj)
            % obtenerFuerzaResistenteCoordLocal: Retorna la fuerza
            % resistente en coordenadas locales
            %
            % fr_local = obtenerFuerzaResistenteCoordLocal(Fundacion2DObj)
            
            % Obtiene los nodos
            nodo1 = Fundacion2DObj.nodosObj{1};
            nodo2 = Fundacion2DObj.nodosObj{2};
            
            % Obtiene los desplazamientos
            u1 = nodo1.obtenerDesplazamientos();
            u2 = nodo2.obtenerDesplazamientos();
            
            % Vector desplazamientos u'
            u = [u1(1), u1(2), u1(3), u2(1), u2(2), u2(3)]';
            
            % Obtiene K local
            k_local = Fundacion2DObj.obtenerMatrizRigidezCoordLocal();
            
            % Obtiene u''
            u = Fundacion2DObj.obtenerMatrizTransformacion() * u;
            
            % Calcula F
            fr_local = k_local * u;
            
        end % obtenerFuerzaResistenteCoordLocal function
        
        function definirGDLID(Fundacion2DObj)
            % definirGDLID: Define los ID de los grados de libertad de la
            % viga columna
            %
            % definirGDLID(Fundacion2DObj)
            
            % Se obtienen los nodos extremos
            nodo1 = Fundacion2DObj.nodosObj{1};
            nodo2 = Fundacion2DObj.nodosObj{2};
            
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
            Fundacion2DObj.gdlID = gdl;
            
        end % definirGDLID function
        
        function sumarFuerzaEquivalente(Fundacion2DObj, f)
            % sumarFuerzaEquivalente: Suma fuerza equivalente a vigas
            %
            % sumarFuerzaEquivalente(Fundacion2DObj,f)
            
            for i = 1:length(f)
                Fundacion2DObj.Feq(i) = Fundacion2DObj.Feq(i) + f(i);
            end % for i
            
        end % sumarFuerzaEquivalente function
        
        function f = obtenerFuerzaEquivalente(Fundacion2DObj)
            % obtenerFuerzaEquivalente: Obtiene la fuerza equivalente de la
            % viga columna
            %
            % f = obtenerFuerzaEquivalente(Fundacion2DObj)
            
            f = Fundacion2DObj.Feq;
            
        end % obtenerFuerzaEquivalente function
        
        function agregarFuerzaResistenteAReacciones(Fundacion2DObj)
            % agregarFuerzaResistenteAReacciones: Agrega fuerza resistente
            % de la viga a las reacciones
            %
            % agregarFuerzaResistenteAReacciones(Fundacion2DObj)
            
            % Se calcula la fuerza resistente global
            fr_global = Fundacion2DObj.obtenerFuerzaResistenteCoordGlobal();
            
            % Carga los nodos
            nodo1 = Fundacion2DObj.nodosObj{1};
            nodo2 = Fundacion2DObj.nodosObj{2};
            
            % Transforma la carga equivalente como carga puntual
            F_eq = Fundacion2DObj.T' * Fundacion2DObj.Feq;
            
            % Agrega fuerzas equivalentes como cargas
            nodo1.agregarCarga([-F_eq(1), -F_eq(2), -F_eq(3)]')
            nodo2.agregarCarga([-F_eq(4), -F_eq(5), -F_eq(6)]')
            
            % Agrega fuerzas resistentes como cargas
            nodo1.agregarEsfuerzosElementoAReaccion([fr_global(1), fr_global(2), fr_global(3)]');
            nodo2.agregarEsfuerzosElementoAReaccion([fr_global(4), fr_global(5), fr_global(6)]');
            
        end % agregarFuerzaResistenteAReacciones function
        
        function guardarPropiedades(Fundacion2DObj, archivoSalidaHandle)
            % guardarPropiedades: Guarda las propiedades del elemento en un
            % archivo
            %
            % guardarPropiedades(Fundacion2DObj,archivoSalidaHandle)
            
            fprintf(archivoSalidaHandle, '\tFundacion 2D %s:\n\tMasa:\t\t%s\n', ...
                Fundacion2DObj.obtenerEtiqueta(), num2str(Fundacion2DObj.obtenerMasa()));
            
        end % guardarPropiedades function
        
        function guardarEsfuerzosInternos(Fundacion2DObj, archivoSalidaHandle)
            % guardarEsfuerzosInternos: Guarda los esfuerzos internos del
            % elemento
            %
            % guardarEsfuerzosInternos(Fundacion2DObj,archivoSalidaHandle)
            
            fr = Fundacion2DObj.obtenerFuerzaResistenteCoordGlobal();
            n1 = pad(num2str(fr(1), '%.04f'), 10);
            n2 = pad(num2str(fr(4), '%.04f'), 10);
            v1 = pad(num2str(fr(2), '%.04f'), 10);
            v2 = pad(num2str(fr(5), '%.04f'), 10);
            m1 = pad(num2str(fr(3), '%.04f'), 10);
            m2 = pad(num2str(fr(6), '%.04f'), 10);
            
            fprintf(archivoSalidaHandle, '\n\tViga-Columna 2D %s:\n\t\tAxial:\t\t%s %s\n\t\tCorte:\t\t%s %s\n\t\tMomento:\t%s %s', ...
                Fundacion2DObj.obtenerEtiqueta(), n1, n2, v1, v2, m1, m2);
            
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
        
        function disp(Fundacion2DObj)
            % disp: Imprime propiedades en pantalla del objeto
            %
            % disp(Fundacion2DObj)
            
            % Imprime propiedades de la Viga-Columna-2D
            fprintf('Propiedades viga columna 2D:\n');
            disp@ComponenteModelo(Fundacion2DObj);
            fprintf('\tLargo: %s\n\tArea: %s\n\tI: %s\n\tE: %s\n\tMasa: %s\n', pad(num2str(Fundacion2DObj.L), 12), ...
                pad(num2str(Fundacion2DObj.Ao), 10), pad(num2str(Fundacion2DObj.Io), 10), ...
                pad(num2str(Fundacion2DObj.Eo), 10), pad(num2str(Fundacion2DObj.obtenerMasa()), 10));
            
            % Se imprime matriz de rigidez local
            fprintf('\tMatriz de rigidez coordenadas locales:\n');
            disp(Fundacion2DObj.obtenerMatrizRigidezCoordLocal());
            
            % Se imprime matriz de rigidez global
            fprintf('\tMatriz de rigidez coordenadas globales:\n');
            disp(Fundacion2DObj.obtenerMatrizRigidezCoordGlobal());
            
            % Imprime vector de masa
            fprintf('\tVector de masa:\n');
            disp(Fundacion2DObj.obtenerVectorMasa());
            
            dispMetodoTEFAME();
            
        end % disp function
        
    end % methods Fundacion2D
    
end % class Fundacion2D