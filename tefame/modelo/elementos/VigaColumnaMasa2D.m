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
%| Clase VigaColumnaMasa2D                                              |
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
%
%  Methods:
%       vigaColumnaMasa2DObj = VigaColumnaMasa2D(etiquetaViga,nodo1Obj,nodo2Obj,Imaterial,Ematerial)
%       numeroNodos = obtenerNumeroNodos(vigaColumnaMasa2DObj)
%       nodosBiela = obtenerNodos(vigaColumnaMasa2DObj)
%       numeroGDL = obtenerNumeroGDL(vigaColumnaMasa2DObj)
%       gdlIDBiela = obtenerGDLID(vigaColumnaMasa2DObj)
%       k_global = obtenerMatrizRigidezCoordGlobal(vigaColumnaMasa2DObj)
%       k_local = obtenerMatrizRigidezCoordLocal(vigaColumnaMasa2DObj)
%       m_masa = obtenerMatrizMasa(vigaColumnaMasa2DObj)
%       m = obtenerMasa(vigaColumnaMasa2DObj)
%       fr_global = obtenerFuerzaResistenteCoordGlobal(vigaColumnaMasa2DObj)
%       fr_local = obtenerFuerzaResistenteCoordLocal(vigaColumnaMasa2DObj)
%       l = obtenerLargo(vigaColumnaMasa2DObj)
%       T = obtenerMatrizTransformacion(vigaColumnaMasa2DObj)
%       theta = obtenerAngulo(vigaColumnaMasa2DObj)
%       definirGDLID(vigaColumnaMasa2DObj)
%       agregarFuerzaResistenteAReacciones(vigaColumnaMasa2DObj)
%       guardarPropiedades(vigaColumnaMasa2DObj,archivoSalidaHandle)
%       guardarEsfuerzosInternos(vigaColumnaMasa2DObj,archivoSalidaHandle)
%       disp(vigaColumnaMasa2DObj)
%  Methods SuperClass (ComponenteModelo):
%       etiqueta = obtenerEtiqueta(componenteModeloObj)
%       e = equals(componenteModeloObj,obj)

classdef VigaColumnaMasa2D < Elemento
    
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
    end % properties VigaColumnaMasa2D
    
    methods
        
        function vigaColumnaMasa2DObj = VigaColumnaMasa2D(etiquetaViga, nodo1Obj, nodo2Obj, Imaterial, Ematerial, Amaterial, Densidad)
            
            % Completa con ceros si no hay argumentos
            if nargin == 0
                etiquetaViga = '';
            end % if
            
            % Llamamos al constructor de la SuperClass que es la clase Elemento
            vigaColumnaMasa2DObj = vigaColumnaMasa2DObj@Elemento(etiquetaViga);
            
            % Guarda material
            vigaColumnaMasa2DObj.nodosObj = {nodo1Obj; nodo2Obj};
            vigaColumnaMasa2DObj.Ao = Amaterial;
            vigaColumnaMasa2DObj.Eo = Ematerial;
            vigaColumnaMasa2DObj.Io = Imaterial;
            vigaColumnaMasa2DObj.rho = Densidad;
            vigaColumnaMasa2DObj.gdlID = [];
            
            % Calcula componentes geometricas
            coordNodo1 = nodo1Obj.obtenerCoordenadas();
            coordNodo2 = nodo2Obj.obtenerCoordenadas();
            vigaColumnaMasa2DObj.dx = abs(coordNodo2(1)-coordNodo1(1));
            vigaColumnaMasa2DObj.dy = abs(coordNodo2(2)-coordNodo1(2));
            vigaColumnaMasa2DObj.L = sqrt(vigaColumnaMasa2DObj.dx^2+vigaColumnaMasa2DObj.dy^2);
            theta = atan(vigaColumnaMasa2DObj.dy/vigaColumnaMasa2DObj.dx);
            vigaColumnaMasa2DObj.theta = theta;
            
            % Calcula matriz de transformacion dado el angulo
            T = [cos(theta), sin(theta), 0, 0, 0, 0; ...
                -sin(theta), cos(theta), 0, 0, 0, 0; ...
                0, 0, 1, 0, 0, 0; ...
                0, 0, 0, cos(theta), sin(theta), 0; ...
                0, 0, 0, -sin(theta), cos(theta), 0; ...
                0, 0, 0, 0, 0, 1];
            vigaColumnaMasa2DObj.T = T;
            
            % Calcula matriz de rigidez local
            A = Amaterial;
            E = Ematerial;
            I = Imaterial;
            L = vigaColumnaMasa2DObj.L;
            Klp = [A * E / L, 0, 0, -A * E / L, 0, 0; ...
                0, 12 * E * I / (L^3), 6 * E * I / (L^2), 0, - 12 * E * I / (L^3), 6 * E * I / (L^2); ...
                0, 6 * E * I / (L^2), 4 * E * I / L, 0, - 6 * E * I / (L^2), 2 * E * I / L; ...
                -A * E / L, 0, 0, A * E / L, 0, 0; ...
                0, -12 * E * I / (L^3), - 6 * E * I / (L^2), 0, 12 * E * I / (L^3), -6 * E * I / (L^2); ...
                0, 6 * E * I / (L^2), 2 * E * I / L, 0, - 6 * E * I / (L^2), 4 * E * I / L];
            vigaColumnaMasa2DObj.Klp = Klp;
            
            % Fuerza equivalente de la viga
            vigaColumnaMasa2DObj.Feq = [0, 0, 0, 0, 0, 0]';
            
            % Agrega el elemento a los nodos
            nodo1Obj.agregarElementos(vigaColumnaMasa2DObj);
            nodo2Obj.agregarElementos(vigaColumnaMasa2DObj);
            
            % Otros
            vigaColumnaMasa2DObj.PLOTNELEM = 10;
            
        end % VigaColumnaMasa2D constructor
        
        function l = obtenerLargo(vigaColumnaMasa2DObj)
            
            l = vigaColumnaMasa2DObj.L;
            
        end % obtenerLargo function
        
        function numeroNodos = obtenerNumeroNodos(vigaColumnaMasa2DObj) %#ok<MANU>
            
            numeroNodos = 2;
            
        end % obtenerNumeroNodos function
        
        function nodosViga = obtenerNodos(vigaColumnaMasa2DObj)
            
            nodosViga = vigaColumnaMasa2DObj.nodosObj;
            
        end % obtenerNodos function
        
        function numeroGDL = obtenerNumeroGDL(vigaColumnaMasa2DObj) %#ok<MANU>
            
            numeroGDL = 6;
            
        end % obtenerNumeroGDL function
        
        function gdlIDViga = obtenerGDLID(vigaColumnaMasa2DObj)
            
            gdlIDViga = vigaColumnaMasa2DObj.gdlID;
            
        end % obtenerGDLID function
        
        function T = obtenerMatrizTransformacion(vigaColumnaMasa2DObj)
            
            T = vigaColumnaMasa2DObj.T;
            
        end % obtenerMatrizTransformacion function
        
        function theta = obtenerAngulo(vigaColumnaMasa2DObj)
            
            theta = vigaColumnaMasa2DObj.theta;
            
        end % obtenerAngulo function
        
        function k_global = obtenerMatrizRigidezCoordGlobal(vigaColumnaMasa2DObj)
            
            % Multiplica por la matriz de transformacion
            k_local = vigaColumnaMasa2DObj.obtenerMatrizRigidezCoordLocal();
            t_theta = vigaColumnaMasa2DObj.T;
            k_global = t_theta' * k_local * t_theta;
            
        end % obtenerMatrizRigidezCoordGlobal function
        
        function k_local = obtenerMatrizRigidezCoordLocal(vigaColumnaMasa2DObj)
            
            % Retorna la matriz calculada en el constructor
            k_local = vigaColumnaMasa2DObj.Klp;
            
        end % obtenerMatrizRigidezCoordLocal function
        
        function m_masa = obtenerMatrizMasa(vigaColumnaMasa2DObj)
            
            % Retorna la matriz calculada en el constructor
            m_masa = zeros(6, 1);
            
            % Inicializamos la masa de los grados
            elem_nodo1 = vigaColumnaMasa2DObj.nodosObj{1}.obtenerElementos();
            elem_nodo2 = vigaColumnaMasa2DObj.nodosObj{2}.obtenerElementos();
            
            % Agrega la tributacion de las masas
            % 1,4: horizontal | 2,5: vertical | 3,6: giro
            for i = 1:length(elem_nodo1)
                m_masa(1) = m_masa(1) + elem_nodo1{i}.obtenerMasa() * 0.5;
                m_masa(2) = m_masa(2) + elem_nodo1{i}.obtenerMasa() * 0.5;
                m_masa(3) = m_masa(3) + elem_nodo1{i}.obtenerMasa() * 0.5 * 0.0001;
                % m_masa(3) = 0;
            end
            for i = 1:length(elem_nodo2)
                m_masa(4) = m_masa(4) + elem_nodo2{i}.obtenerMasa() * 0.5;
                m_masa(5) = m_masa(5) + elem_nodo2{i}.obtenerMasa() * 0.5;
                m_masa(6) = m_masa(6) + elem_nodo2{i}.obtenerMasa() * 0.5 * 0.0001;
                % m_masa(6) = 0;
            end
            
        end % obtenerMatrizMasa function
        
        function m = obtenerMasa(vigaColumnaMasa2DObj)
            
            m = vigaColumnaMasa2DObj.rho * vigaColumnaMasa2DObj.L * vigaColumnaMasa2DObj.Ao;
            
        end % obtenerMasa function
        
        function fr_global = obtenerFuerzaResistenteCoordGlobal(vigaColumnaMasa2DObj)
            
            % Obtiene fr local
            fr_local = vigaColumnaMasa2DObj.obtenerFuerzaResistenteCoordLocal();
            
            % Resta a fuerza equivalente para obtener la fuerza global
            fr_global = vigaColumnaMasa2DObj.T' * (fr_local - vigaColumnaMasa2DObj.Feq);
            
        end % obtenerFuerzaResistenteCoordGlobal function
        
        function fr_local = obtenerFuerzaResistenteCoordLocal(vigaColumnaMasa2DObj)
            
            % Obtiene los nodos
            nodo1 = vigaColumnaMasa2DObj.nodosObj{1};
            nodo2 = vigaColumnaMasa2DObj.nodosObj{2};
            
            % Obtiene los desplazamientos
            u1 = nodo1.obtenerDesplazamientos();
            u2 = nodo2.obtenerDesplazamientos();
            
            % Vector desplazamientos u'
            u = [u1(1), u1(2), u1(3), u2(1), u2(2), u2(3)]';
            
            % Obtiene K local
            k_local = vigaColumnaMasa2DObj.obtenerMatrizRigidezCoordLocal();
            
            % Obtiene u''
            u = vigaColumnaMasa2DObj.obtenerMatrizTransformacion() * u;
            
            % Calcula F
            fr_local = k_local * u;
            
        end % obtenerFuerzaResistenteCoordLocal function
        
        function definirGDLID(vigaColumnaMasa2DObj)
            
            % Se obtienen los nodos extremos
            nodo1 = vigaColumnaMasa2DObj.nodosObj{1};
            nodo2 = vigaColumnaMasa2DObj.nodosObj{2};
            
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
            vigaColumnaMasa2DObj.gdlID = gdl;
            
        end % definirGDLID function
        
        function sumarFuerzaEquivalente(vigaColumnaMasa2DObj, f)
            
            for i = 1:length(f)
                vigaColumnaMasa2DObj.Feq(i) = vigaColumnaMasa2DObj.Feq(i) + f(i);
            end
            
        end % sumarFuerzaEquivalente function
        
        function f = obtenerFuerzaEquivalente(vigaColumnaMasa2DObj)
            
            f = vigaColumnaMasa2DObj.Feq;
            
        end % obtenerFuerzaEquivalente function
        
        function agregarFuerzaResistenteAReacciones(vigaColumnaMasa2DObj)
            
            % Se calcula la fuerza resistente global
            fr_global = vigaColumnaMasa2DObj.obtenerFuerzaResistenteCoordGlobal();
            
            % Carga los nodos
            nodo1 = vigaColumnaMasa2DObj.nodosObj{1};
            nodo2 = vigaColumnaMasa2DObj.nodosObj{2};
            
            % Transforma la carga equivalente como carga puntual
            F_eq = vigaColumnaMasa2DObj.T' * vigaColumnaMasa2DObj.Feq;
            
            % Agrega fuerzas equivalentes como cargas
            nodo1.agregarCarga([-F_eq(1), -F_eq(2), -F_eq(3)]')
            nodo2.agregarCarga([-F_eq(4), -F_eq(5), -F_eq(6)]')
            
            % Agrega fuerzas resistentes como cargas
            nodo1.agregarEsfuerzosElementoAReaccion([fr_global(1), fr_global(2), fr_global(3)]');
            nodo2.agregarEsfuerzosElementoAReaccion([fr_global(4), fr_global(5), fr_global(6)]');
            
        end % agregarFuerzaResistenteAReacciones function
        
        function guardarPropiedades(vigaColumnaMasa2DObj, archivoSalidaHandle)
            
            fprintf(archivoSalidaHandle, '\tViga-Columna-Masa 2D %s:\n\t\tLargo:\t\t%s\n\t\tInercia:\t%s\n\t\tEo:\t\t\t%s\n\t\tEI:\t\t\t%s\n', ...
                vigaColumnaMasa2DObj.obtenerEtiqueta(), num2str(vigaColumnaMasa2DObj.L), ...
                num2str(vigaColumnaMasa2DObj.Io), num2str(vigaColumnaMasa2DObj.Eo), num2str(vigaColumnaMasa2DObj.Eo*vigaColumnaMasa2DObj.Io));
            
        end % guardarPropiedades function
        
        function guardarEsfuerzosInternos(vigaColumnaMasa2DObj, archivoSalidaHandle)
            % guardarEsfuerzosInternos: Guarda los esfuerzos internos del
            % elemento
            
            fr = vigaColumnaMasa2DObj.obtenerFuerzaResistenteCoordGlobal();
            n1 = pad(num2str(fr(1), '%.04f'), 10);
            n2 = pad(num2str(fr(4), '%.04f'), 10);
            v1 = pad(num2str(fr(2), '%.04f'), 10);
            v2 = pad(num2str(fr(5), '%.04f'), 10);
            m1 = pad(num2str(fr(3), '%.04f'), 10);
            m2 = pad(num2str(fr(6), '%.04f'), 10);
            
            fprintf(archivoSalidaHandle, '\n\tViga-Columna 2D %s:\n\t\tAxial:\t\t%s %s\n\t\tCorte:\t\t%s %s\n\t\tMomento:\t%s %s', ...
                vigaColumnaMasa2DObj.obtenerEtiqueta(), n1, n2, v1, v2, m1, m2);
            
        end % guardarEsfuerzosInternos function
        
        function N = obtenerVectorN(elementoObj, x, l) %#ok<INUSL>
            % obtenerVectorN: Obtiene el vector de transformada N a partir
            % de x como porcentaje del largo
            
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
            % plotVigaDeformar(elementoObj, deformadas)
            
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
        
        function disp(vigaColumnaMasa2DObj)
            
            % Imprime propiedades de la Viga-Columna-Masa2D
            fprintf('Propiedades Viga-Columna-Masa 2D:\n\t');
            disp@ComponenteModelo(vigaColumnaMasa2DObj);
            fprintf('\t\tLargo: %s\tArea: %s\tI: %s\tE: %s\tMasa: %s\n', pad(num2str(vigaColumnaMasa2DObj.L), 12), ...
                pad(num2str(vigaColumnaMasa2DObj.Ao), 10), pad(num2str(vigaColumnaMasa2DObj.Io), 10), ...
                pad(num2str(vigaColumnaMasa2DObj.Eo), 10), pad(num2str(vigaColumnaMasa2DObj.obtenerMasa()), 10));
            
            % Se imprime matriz de rigidez local
            fprintf('\tMatriz de rigidez coordenadas locales:\n');
            disp(vigaColumnaMasa2DObj.obtenerMatrizRigidezCoordLocal());
            
            % Se imprime matriz de rigidez global
            fprintf('\tMatriz de rigidez coordenadas globales:\n');
            disp(vigaColumnaMasa2DObj.obtenerMatrizRigidezCoordGlobal());
            
            % Imprime vector de masa
            fprintf('\tVector de masa:\n');
            disp(vigaColumnaMasa2DObj.obtenerMatrizMasa());
            
            fprintf('-------------------------------------------------\n');
            fprintf('\n');
            
        end % disp function
        
    end % methods VigaColumnaMasa2D
    
end % class VigaColumnaMasa2D