% ______________________________________________________________________
%|                                                                      |
%|           TEFAME - Toolbox para Elementos Finitos y Analisis         |
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
%| Clase Viga2D                                                         |
%|                                                                      |
%| Este archivo contiene la definicion de la Clase Viga 2D              |
%| Viga2D  es una  subclase de la  clase Elemento y  corresponde a  la  |
%| representacion del elemento viga que solo transmite esfuerzo de      |
%| corte.                                                               |
%|                                                                      |
%| Programado: Pablo Pizarro @ppizarror.com                             |
%| Fecha: 14/05/2018                                                    |
%|______________________________________________________________________|
%
%  Properties (Access=private):
%       nodosObj
%       gdlID
%       Io
%       Eo
%       dx
%       dy
%       L
%       theta
%       Feq
%       PLOTNELEM
%       rho
%  Methods:
%       viga2DObj = Viga2D(etiquetaViga,nodo1Obj,nodo2Obj,Imaterial,Ematerial,densidad)
%       numeroNodos = obtenerNumeroNodos(viga2DObj)
%       nodosBiela = obtenerNodos(viga2DObj)
%       numeroGDL = obtenerNumeroGDL(viga2DObj)
%       gdlIDViga = obtenerGDLID(viga2DObj)
%       k_global = obtenerMatrizRigidezCoordGlobal(viga2DObj)
%       k_local = obtenerMatrizRigidezCoordLocal(viga2DObj)
%       fr_global = obtenerFuerzaResistenteCoordGlobal(viga2DObj)
%       fr_local = obtenerFuerzaResistenteCoordLocal(viga2DObj)
%       l = obtenerLargo(viga2DObj)
%       definirGDLID(viga2DObj)
%       agregarFuerzaResistenteAReacciones(viga2DObj)
%       guardarPropiedades(viga2DObj,archivoSalidaHandle)
%       guardarEsfuerzosInternos(viga2DObj,archivoSalidaHandle)
%       disp(viga2DObj)
%  Methods SuperClass (ComponenteModelo):
%       etiqueta = obtenerEtiqueta(componenteModeloObj)
%       e = equals(componenteModeloObj,obj)
%       objID = obtenerIDObjeto(componenteModeloObj)

classdef Viga2D < Elemento
    
    properties(Access = private)
        nodosObj % Cell con los nodos
        gdlID % Lista con los ID de los grados de libertad
        Eo % Modulo de elasticidad
        Io % Inercia de la seccion
        dx % Distancia en el eje x entre los nodos
        dy % Distancia en el eje y entre los nodos
        L % Largo del elemento
        theta % Angulo de inclinacion de la viga
        Feq % Fuerza equivalente
        PLOTNELEM % Numero de elementos en los que se discretiza para el grafico
        rho % Densidad de la viga
    end % properties Viga2D
    
    methods
        
        function viga2DObj = Viga2D(etiquetaViga, nodo1Obj, nodo2Obj, Imaterial, Ematerial, densidad)
            
            % Si no se pasan argumentos se crean vacios
            if nargin == 0
                etiquetaViga = '';
            end % if
            if ~exist('densidad', 'var')
                densidad = 0;
            end
            
            % Llamamos al constructor de la SuperClass que es la clase Elemento
            viga2DObj = viga2DObj@Elemento(etiquetaViga);
            
            % Guarda material
            viga2DObj.nodosObj = {nodo1Obj; nodo2Obj};
            viga2DObj.Eo = Ematerial;
            viga2DObj.Io = Imaterial;
            viga2DObj.gdlID = [];
            viga2DObj.rho = densidad;
            
            % Calcula componentes geometricas
            coordNodo1 = nodo1Obj.obtenerCoordenadas();
            coordNodo2 = nodo2Obj.obtenerCoordenadas();
            viga2DObj.dx = abs(coordNodo2(1)-coordNodo1(1));
            viga2DObj.dy = abs(coordNodo2(2)-coordNodo1(2));
            viga2DObj.L = sqrt(viga2DObj.dx^2+viga2DObj.dy^2);
            viga2DObj.theta = atan(viga2DObj.dy/viga2DObj.dx);
            
            % Fuerza equivalente de la viga
            viga2DObj.Feq = [0, 0, 0, 0]';
            
            % Otros
            viga2DObj.PLOTNELEM = 10;
            
        end % Viga2D constructor
        
        function l = obtenerLargo(viga2DObj)
            
            l = viga2DObj.L;
            
        end % obtenerLargo function
        
        function numeroNodos = obtenerNumeroNodos(viga2DObj) %#ok<MANU>
            
            numeroNodos = 2;
            
        end % obtenerNumeroNodos function
        
        function nodosViga = obtenerNodos(viga2DObj)
            
            nodosViga = viga2DObj.nodosObj;
            
        end % obtenerNodos function
        
        function numeroGDL = obtenerNumeroGDL(viga2DObj) %#ok<MANU>
            
            numeroGDL = 4;
            
        end % obtenerNumeroGDL function
        
        function gdlIDViga = obtenerGDLID(viga2DObj)
            
            gdlIDViga = viga2DObj.gdlID;
            
        end % obtenerGDLID function
        
        function m = obtenerMasa(viga2DObj)
            % obtenerMasa: Retorna la masa total del elemento
            %
            % m = obtenerMasa(viga2DObj)
            
            m = viga2DObj.rho * viga2DObj.L;
            
        end % obtenerMasa function
        
        function m_masa = obtenerVectorMasa(viga2DObj)
            % obtenerVectorMasa: Obtiene el vector de masa del elemento
            %
            % m_masa = obtenerVectorMasa(viga2DObj)
            
            m_masa = zeros(4, 1);
            m = viga2DObj.obtenerMasa();
            m_masa(1) = m * 0.5;
            m_masa(2) = m * 0.5;
            m_masa(3) = m * 0.5;
            m_masa(4) = m * 0.5;
            
        end % obtenerMatrizMasa function
        
        function k_global = obtenerMatrizRigidezCoordGlobal(viga2DObj)
            
            % Matriz global igual a la local
            k_global = viga2DObj.obtenerMatrizRigidezCoordLocal();
            
        end % obtenerMatrizRigidezGlobal function
        
        function k_local = obtenerMatrizRigidezCoordLocal(viga2DObj)
            
            % Genera la matriz de rigidez local
            L1 = viga2DObj.L;
            L2 = L1.^2;
            k_local = [12, 6 * L1, -12, 6 * L1; ...
                6 * L1, 4 * L2, -6 * L1, 2 * L2; ...
                -12, -6 * L1, 12, -6 * L1; ...
                6 * L1, 2 * L2, -6 * L1, 4 * L2];
            
            % Multiplica por EoIo/L
            k_local = k_local .* (viga2DObj.Eo * viga2DObj.Io / (viga2DObj.L^3));
            
        end % obtenerMatrizRigidezLocal function
        
        function fr_global = obtenerFuerzaResistenteCoordGlobal(viga2DObj)
            
            % Obtiene fr local
            fr_local = viga2DObj.obtenerFuerzaResistenteCoordLocal();
            
            % Resta a fuerza equivalente para obtener la fuerza global
            fr_global = fr_local - viga2DObj.Feq;
            
        end % obtenerFuerzaResistenteCoordGlobal function
        
        function fr_local = obtenerFuerzaResistenteCoordLocal(viga2DObj)
            
            % Obtiene los nodos
            nodo1 = viga2DObj.nodosObj{1};
            nodo2 = viga2DObj.nodosObj{2};
            
            % Obtiene los desplazamientos
            u1 = nodo1.obtenerDesplazamientos();
            u2 = nodo2.obtenerDesplazamientos();
            
            % Vector desplazamientos u'
            u = [u1(2), u1(3), u2(2), u2(3)]';
            
            % Obtiene K local
            k_local = viga2DObj.obtenerMatrizRigidezCoordLocal();
            
            % Calcula F
            fr_local = k_local * u;
            
        end % obtenerFuerzaResistenteCoordLocal function
        
        function definirGDLID(viga2DObj)
            
            % Se obtienen los nodos extremos
            nodo1 = viga2DObj.nodosObj{1};
            nodo2 = viga2DObj.nodosObj{2};
            
            % Se obtienen los gdl de los nodos
            gdlnodo1 = nodo1.obtenerGDLID();
            gdlnodo2 = nodo2.obtenerGDLID();
            
            % Se establecen gdl
            gdl = [0, 0, 0, 0];
            gdl(1) = gdlnodo1(2);
            gdl(2) = gdlnodo1(3);
            gdl(3) = gdlnodo2(2);
            gdl(4) = gdlnodo2(3);
            viga2DObj.gdlID = gdl;
            
        end % definirGDLID function
        
        function sumarFuerzaEquivalente(viga2DObj, f)
            
            for i = 1:length(f)
                viga2DObj.Feq(i) = viga2DObj.Feq(i) + f(i);
            end % for i
            
        end % sumarFuerzaEquivalente function
        
        function agregarFuerzaResistenteAReacciones(viga2DObj)
            
            % Se calcula la fuerza resistente global
            fr_global = viga2DObj.obtenerFuerzaResistenteCoordGlobal();
            
            % Carga los nodos
            nodo1 = viga2DObj.nodosObj{1};
            nodo2 = viga2DObj.nodosObj{2};
            
            % Agrega fuerzas equivalentes como cargas
            nodo1.agregarCarga([0, -viga2DObj.Feq(1), -viga2DObj.Feq(2)]');
            nodo2.agregarCarga([0, -viga2DObj.Feq(3), -viga2DObj.Feq(4)]');
            
            % Agrega fuerzas resistentes como cargas
            nodo1.agregarEsfuerzosElementoAReaccion([0, fr_global(1), fr_global(2)]');
            nodo2.agregarEsfuerzosElementoAReaccion([0, fr_global(3), fr_global(4)]');
            
        end % agregarFuerzaResistenteAReacciones function
        
        function guardarPropiedades(viga2DObj, archivoSalidaHandle)
            
            fprintf(archivoSalidaHandle, '\tViga2D %s:\n\t\tLargo:\t\t%s\n\t\tInercia:\t%s\n\t\tEo:\t\t\t%s\n\t\tEI:\t\t\t%s\n\t\tMasa:\t\t%s\n', ...
                viga2DObj.obtenerEtiqueta(), num2str(viga2DObj.L), ...
                num2str(viga2DObj.Io), num2str(viga2DObj.Eo), ...
                num2str(viga2DObj.Eo*viga2DObj.Io), num2str(viga2DObj.obtenerMasa()));
            
        end % guardarPropiedades function
        
        function guardarEsfuerzosInternos(viga2DObj, archivoSalidaHandle)
            
            fr = viga2DObj.obtenerFuerzaResistenteCoordGlobal();
            m1 = pad(num2str(fr(2), '%.04f'), 10);
            m2 = pad(num2str(fr(4), '%.04f'), 10);
            v1 = pad(num2str(fr(1), '%.04f'), 10);
            v2 = pad(num2str(fr(3), '%.04f'), 10);
            
            fprintf(archivoSalidaHandle, '\n\tViga2D %s:\n\t\tMomento:\t%s %s\n\t\tCorte:\t\t%s %s', ...
                viga2DObj.obtenerEtiqueta(), m1, m2, v1, v2);
            
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
                if length(deformadas{1}) == 3 && defElem && elementoObj.graficaDeformada
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
                            (coordy * n) * cos(tht) + (coord1(2) + ndy * p) * sin(elementoObj.theta)];
                        elementoObj.graficarLinea(coordi, coordf, tipoLinea, grosorLinea);
                        coordi = coordf;
                    end % for i
                    return;
                end
            end
            
            % Grafica en forma lineal
            elementoObj.graficarLinea(coord1, coord2, tipoLinea, grosorLinea);
            
        end % plot function
        
        function disp(viga2DObj)
            
            % Imprime propiedades de la viga 2D
            fprintf('Propiedades viga 2D:\n\t');
            disp@ComponenteModelo(viga2DObj);
            
            fprintf('\t\tLargo: %s\tI: %s\tE: %s\n', pad(num2str(viga2DObj.L), 12), ...
                pad(num2str(viga2DObj.Io), 10), pad(num2str(viga2DObj.Eo), 10));
            
            % Se imprime matriz de rigidez local
            fprintf('\tMatriz de rigidez coordenadas locales:\n');
            disp(viga2DObj.obtenerMatrizRigidezCoordLocal());
            
            % Se imprime matriz de rigidez global
            fprintf('\tMatriz de rigidez coordenadas globales:\n');
            disp(viga2DObj.obtenerMatrizRigidezCoordGlobal());
            
            dispMetodoTEFAME();
            
        end % disp function
        
    end % methods Viga2D
    
end % class Viga2D