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
%| Clase Fundacion2D                                                    |
%|                                                                      |
%| Este archivo contiene la definicion de la Clase Fundacion 2D         |
%| Fundacion2D es una  subclase de la clase Elemento y  corresponde a   |
%| la representacion del elemento fundacion.                            |
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
%       fundacion2DObj = Fundacion2D(etiquetaViga,nodo1Obj,nodo2Obj,Imaterial,Ematerial,densidad)
%       numeroNodos = obtenerNumeroNodos(fundacion2DObj)
%       nodosBiela = obtenerNodos(fundacion2DObj)
%       numeroGDL = obtenerNumeroGDL(fundacion2DObj)
%       gdlIDBiela = obtenerGDLID(fundacion2DObj)
%       k_global = obtenerMatrizRigidezCoordGlobal(fundacion2DObj)
%       k_local = obtenerMatrizRigidezCoordLocal(fundacion2DObj)
%       m_masa = obtenerVectorMasa(fundacion2DObj)
%       m = obtenerMasa(fundacion2DObj)
%       fr_global = obtenerFuerzaResistenteCoordGlobal(fundacion2DObj)
%       fr_local = obtenerFuerzaResistenteCoordLocal(fundacion2DObj)
%       l = obtenerLargo(fundacion2DObj)
%       T = obtenerMatrizTransformacion(fundacion2DObj)
%       theta = obtenerAngulo(fundacion2DObj)
%       definirGDLID(fundacion2DObj)
%       agregarFuerzaResistenteAReacciones(fundacion2DObj)
%       guardarPropiedades(fundacion2DObj,archivoSalidaHandle)
%       guardarEsfuerzosInternos(fundacion2DObj,archivoSalidaHandle)
%       disp(fundacion2DObj)
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
        theta % Angulo de inclinacion de la fundacion
        Feq % Fuerza equivalente
        T % Matriz de transformacion
        Klp % Matriz de rigidez local del elemento
    end % properties Fundacion2D
    
    methods
        
        function fundacion2DObj = Fundacion2D(etiquetaViga, nodo1Obj, nodo2Obj, Masaelemento, Kelemento)
            
            % Completa con ceros si no hay argumentos
            if nargin == 0
                etiquetaViga = '';
            end % if
            
            % Llamamos al constructor de la SuperClass que es la clase Elemento
            fundacion2DObj = fundacion2DObj@Elemento(etiquetaViga);
            
            % Guarda material
            fundacion2DObj.nodosObj = {nodo1Obj; nodo2Obj};
            fundacion2DObj.meq = Masaelemento;
            fundacion2DObj.keq = Kelemento;
            fundacion2DObj.gdlID = [];           
            
            % Calcula componentes geometricas
            coordNodo1 = nodo1Obj.obtenerCoordenadas();
            coordNodo2 = nodo2Obj.obtenerCoordenadas();
            fundacion2DObj.dx = abs(coordNodo2(1)-coordNodo1(1));
            fundacion2DObj.dy = abs(coordNodo2(2)-coordNodo1(2));
            fundacion2DObj.L = sqrt(fundacion2DObj.dx^2+fundacion2DObj.dy^2);
            theta = atan(fundacion2DObj.dy/fundacion2DObj.dx);
            fundacion2DObj.theta = theta;
            
            T = [cos(theta), sin(theta), 0, 0, 0, 0; ...
                -sin(theta), cos(theta), 0, 0, 0, 0; ...
                0, 0, 1, 0, 0, 0; ...
                0, 0, 0, cos(theta), sin(theta), 0; ...
                0, 0, 0, -sin(theta), cos(theta), 0; ...
                0, 0, 0, 0, 0, 1];
            fundacion2DObj.T = T;
            
            % Fuerza equivalente de la fundacion
            fundacion2DObj.Feq = [0, 0, 0, 0, 0, 0]';
            
            % Agrega el elemento a los nodos
            for i = 1:2
                fundacion2DObj.nodosObj{i}.agregarElementos(fundacion2DObj);
            end % for i
            
        end % Fundacion2D constructor
        
        function l = obtenerLargo(fundacion2DObj)
            % obtenerLargo: Retorna el largo del elemento
            %
            % l = obtenerLargo(fundacion2DObj)
            
            l = fundacion2DObj.L;
            
        end % obtenerLargo function
        
        function numeroNodos = obtenerNumeroNodos(fundacion2DObj) %#ok<MANU>
            % obtenerNumeroNodos: Retorna el numero de nodos del elemento
            %
            % numeroNodos = obtenerNumeroNodos(fundacion2DObj)
            
            numeroNodos = 2;
            
        end % obtenerNumeroNodos function
        
        function nodosViga = obtenerNodos(fundacion2DObj)
            % obtenerNodos: Retorna los nodos del elemento
            %
            % nodosViga = obtenerNodos(fundacion2DObj)
            
            nodosViga = fundacion2DObj.nodosObj;
            
        end % obtenerNodos function
        
        function numeroGDL = obtenerNumeroGDL(fundacion2DObj) %#ok<MANU>
            % obtenerNumeroGDL: Obtiene el numero de grados de libertad del
            % elemento
            %
            % numeroGDL = obtenerNumeroGDL(fundacion2DObj)
            
            numeroGDL = 6;
            
        end % obtenerNumeroGDL function
        
        function gdlIDViga = obtenerGDLID(fundacion2DObj)
            % obtenerGDLID: Obtiene los ID de los grados de libertad del
            % elemento
            %
            % gdlIDViga = obtenerGDLID(fundacion2DObj)
            
            gdlIDViga = fundacion2DObj.gdlID;
            
        end % obtenerGDLID function
        
        function T = obtenerMatrizTransformacion(fundacion2DObj)
            % obtenerMatrizTransformacion: Obtiene la matriz de
            % transformacion del elemento
            %
            % T = obtenerMatrizTransformacion(fundacion2DObj)
            
            T = fundacion2DObj.T;
            
        end % obtenerMatrizTransformacion function
           
        function k_global = obtenerMatrizRigidezCoordGlobal(fundacion2DObj)
            % obtenerMatrizRigidezCoordGlobal: Retorna la matriz de rigidez
            % en coordenadas globales
            %
            % k_global = obtenerMatrizRigidezCoordGlobal(fundacion2DObj)
            
            % Multiplica por la matriz de transformacion
            k_local = fundacion2DObj.obtenerMatrizRigidezCoordLocal();
            t_theta = fundacion2DObj.T;
            k_global = t_theta' * k_local * t_theta;
            
        end % obtenerMatrizRigidezCoordGlobal function
        
        function k_local = obtenerMatrizRigidezCoordLocal(fundacion2DObj)
            % obtenerMatrizRigidezCoordLocal: Retorna la matriz de rigidez
            % en coordenadas locales
            %
            % k_local = obtenerMatrizRigidezCoordLocal(fundacion2DObj)
            
            k_local = fundacion2DObj.keq .* [1, 0, 0, -1, 0, 0; ...
                0, 1, 1, 0, -1, 1; ...
                0, 1, 1, 0, - 1, 1; ...
                -1, 0, 0, 1, 0, 0; ...
                0, -1, - 1, 0, 1, -1; ...
                0, 1, 1, 0, - 1, 1];
            
        end % obtenerMatrizRigidezCoordLocal function
        
        function m = obtenerMasa(fundacion2DObj)
            % obtenerMasa: Retorna la masa total del elemento
            %
            % m = obtenerMasa(fundacion2DObj)
            
            m = fundacion2DObj.meq;
            
        end % obtenerMasa function
        
        function m_masa = obtenerVectorMasa(fundacion2DObj)
            % obtenerVectorMasa: Obtiene el vector de masa del elemento
            %
            % m_masa = obtenerVectorMasa(vigaColumna2DObj)
            
            m_masa = zeros(6, 1);
            m = fundacion2DObj.obtenerMasa();
            m_masa(1) = m * 0.5;
            m_masa(2) = m * 0.5;
            m_masa(3) = 1e-6;
            m_masa(4) = m * 0.5;
            m_masa(5) = m * 0.5;
            m_masa(6) = 1e-6;
            
        end % obtenerMatrizMasa function
        
        function fr_global = obtenerFuerzaResistenteCoordGlobal(fundacion2DObj)
            % obtenerFuerzaResistenteCoordGlobal: Retorna la fuerza
            % resistente en coordenadas globales
            %
            % fr_global = obtenerFuerzaResistenteCoordGlobal(fundacion2DObj)
            
            % Obtiene fr local
            fr_local = fundacion2DObj.obtenerFuerzaResistenteCoordLocal();
            
            % Resta a fuerza equivalente para obtener la fuerza global
            fr_global = fundacion2DObj.T' * (fr_local - fundacion2DObj.Feq);
            
        end % obtenerFuerzaResistenteCoordGlobal function
        
        function fr_local = obtenerFuerzaResistenteCoordLocal(fundacion2DObj)
            % obtenerFuerzaResistenteCoordLocal: Retorna la fuerza
            % resistente en coordenadas locales
            %
            % fr_local = obtenerFuerzaResistenteCoordLocal(fundacion2DObj)
            
            % Obtiene los nodos
            nodo1 = fundacion2DObj.nodosObj{1};
            nodo2 = fundacion2DObj.nodosObj{2};
            
            % Obtiene los desplazamientos
            u1 = nodo1.obtenerDesplazamientos();
            u2 = nodo2.obtenerDesplazamientos();
            
            % Vector desplazamientos u'
            u = [u1(1), u1(2), u1(3), u2(1), u2(2), u2(3)]';
            
            % Obtiene K local
            k_local = fundacion2DObj.obtenerMatrizRigidezCoordLocal();
            
            % Obtiene u''
            u = fundacion2DObj.obtenerMatrizTransformacion() * u;
            
            % Calcula F
            fr_local = k_local * u;
            
        end % obtenerFuerzaResistenteCoordLocal function
        
        function definirGDLID(fundacion2DObj)
            % definirGDLID: Define los ID de los grados de libertad de la
            % viga columna
            %
            % definirGDLID(fundacion2DObj)
            
            % Se obtienen los nodos extremos
            nodo1 = fundacion2DObj.nodosObj{1};
            nodo2 = fundacion2DObj.nodosObj{2};
            
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
            fundacion2DObj.gdlID = gdl;
            
        end % definirGDLID function
        
        function sumarFuerzaEquivalente(fundacion2DObj, f)
            % sumarFuerzaEquivalente: Suma fuerza equivalente a vigas
            %
            % sumarFuerzaEquivalente(fundacion2DObj,f)
            
            for i = 1:length(f)
                fundacion2DObj.Feq(i) = fundacion2DObj.Feq(i) + f(i);
            end % for i
            
        end % sumarFuerzaEquivalente function
        
        function f = obtenerFuerzaEquivalente(fundacion2DObj)
            % obtenerFuerzaEquivalente: Obtiene la fuerza equivalente de la
            % fundacion
            %
            % f = obtenerFuerzaEquivalente(fundacion2DObj)
            
            f = fundacion2DObj.Feq;
            
        end % obtenerFuerzaEquivalente function
        
        function agregarFuerzaResistenteAReacciones(fundacion2DObj)
            % agregarFuerzaResistenteAReacciones: Agrega fuerza resistente
            % de la fundacion a las reacciones
            %
            % agregarFuerzaResistenteAReacciones(fundacion2DObj)
            
            % Se calcula la fuerza resistente global
            fr_global = fundacion2DObj.obtenerFuerzaResistenteCoordGlobal();
            
            % Carga los nodos
            nodo1 = fundacion2DObj.nodosObj{1};
            nodo2 = fundacion2DObj.nodosObj{2};
            
            % Transforma la carga equivalente como carga puntual
            F_eq = fundacion2DObj.T' * fundacion2DObj.Feq;
            
            % Agrega fuerzas equivalentes como cargas
            nodo1.agregarCarga([-F_eq(1), -F_eq(2), -F_eq(3)]')
            nodo2.agregarCarga([-F_eq(4), -F_eq(5), -F_eq(6)]')
            
            % Agrega fuerzas resistentes como cargas
            nodo1.agregarEsfuerzosElementoAReaccion([fr_global(1), fr_global(2), fr_global(3)]');
            nodo2.agregarEsfuerzosElementoAReaccion([fr_global(4), fr_global(5), fr_global(6)]');
            
        end % agregarFuerzaResistenteAReacciones function
        
        function guardarPropiedades(fundacion2DObj, archivoSalidaHandle)
            % guardarPropiedades: Guarda las propiedades del elemento en un
            % archivo
            %
            % guardarPropiedades(fundacion2DObj,archivoSalidaHandle)
            
            fprintf(archivoSalidaHandle, '\tFundacion 2D %s:\n\tMasa:\t\t%s\n', ...
                fundacion2DObj.obtenerEtiqueta(), num2str(fundacion2DObj.obtenerMasa()));
            
        end % guardarPropiedades function
        
        function guardarEsfuerzosInternos(fundacion2DObj, archivoSalidaHandle)
            % guardarEsfuerzosInternos: Guarda los esfuerzos internos del
            % elemento
            %
            % guardarEsfuerzosInternos(fundacion2DObj,archivoSalidaHandle)
            
            fr = fundacion2DObj.obtenerFuerzaResistenteCoordGlobal();
            n1 = pad(num2str(fr(1), '%.04f'), 10);
            n2 = pad(num2str(fr(4), '%.04f'), 10);
            v1 = pad(num2str(fr(2), '%.04f'), 10);
            v2 = pad(num2str(fr(5), '%.04f'), 10);
            m1 = pad(num2str(fr(3), '%.04f'), 10);
            m2 = pad(num2str(fr(6), '%.04f'), 10);
            
            fprintf(archivoSalidaHandle, '\n\tFundacion2D %s:\n\t\tAxial:\t\t%s %s\n\t\tCorte:\t\t%s %s\n\t\tMomento:\t%s %s', ...
                fundacion2DObj.obtenerEtiqueta(), n1, n2, v1, v2, m1, m2);
            
        end % guardarEsfuerzosInternos function
        
        function plot(elementoObj, ~, tipoLinea, grosorLinea, ~)
            % plot: Grafica un elemento
            %
            % plot(elementoObj,deformadas,tipoLinea,grosorLinea,defElem)
            
            % Obtiene las coordenadas de los objetos
            coord1 = elementoObj.nodosObj{1}.obtenerCoordenadas();
            coord2 = elementoObj.nodosObj{2}.obtenerCoordenadas();
            
            % Grafica en forma lineal
            elementoObj.graficarLinea(coord1, coord2, tipoLinea, grosorLinea);
            
        end % plot function
        
        function disp(fundacion2DObj)
            % disp: Imprime propiedades en pantalla del objeto
            %
            % disp(fundacion2DObj)
            
            % Imprime propiedades de la Viga-Columna-2D
            fprintf('Propiedades fundacion 2D:\n');
            disp@ComponenteModelo(fundacion2DObj);
            fprintf('\tLargo: %s\n\tRigidez: %s\n\tMasa: %s\n', pad(num2str(fundacion2DObj.L), 12), ...
                pad(num2str(fundacion2DObj.keq), 10), pad(num2str(fundacion2DObj.obtenerMasa()), 10));
            
            % Se imprime matriz de rigidez local
            fprintf('\tMatriz de rigidez coordenadas locales:\n');
            disp(fundacion2DObj.obtenerMatrizRigidezCoordLocal());
            
            % Se imprime matriz de rigidez global
            fprintf('\tMatriz de rigidez coordenadas globales:\n');
            disp(fundacion2DObj.obtenerMatrizRigidezCoordGlobal());
            
            % Imprime vector de masa
            fprintf('\tVector de masa:\n');
            disp(fundacion2DObj.obtenerVectorMasa());
            
            dispMetodoTEFAME();
            
        end % disp function
        
    end % methods Fundacion2D
    
end % class Fundacion2D