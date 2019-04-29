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
%| Clase DisipadorViscoso2D                                                  |
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
%       Keq
%       Ao
%       Ceq
%       dx
%       dy
%       L
%       Feq
%  Methods:
%       DisipadorViscoso2DObj = DisipadorViscoso2D(etiquetaViga,nodo1Obj,nodo2Obj,Imaterial,Ematerial)
%       numeroNodos = obtenerNumeroNodos(DisipadorViscoso2DObj)
%       nodosBiela = obtenerNodos(DisipadorViscoso2DObj)
%       numeroGDL = obtenerNumeroGDL(DisipadorViscoso2DObj)
%       gdlIDBiela = obtenerGDLID(DisipadorViscoso2DObj)
%       k_global = obtenerMatrizRigidezCoordGlobal(DisipadorViscoso2DObj)
%       k_local = obtenerMatrizRigidezCoordLocal(DisipadorViscoso2DObj)
%       fr_global = obtenerFuerzaResistenteCoordGlobal(DisipadorViscoso2DObj)
%       fr_local = obtenerFuerzaResistenteCoordLocal(DisipadorViscoso2DObj)
%       l = obtenerLargo(DisipadorViscoso2DObj)
%       T = obtenerMatrizTransformacion(DisipadorViscoso2DObj)
%       theta = obtenerAngulo(DisipadorViscoso2DObj)
%       definirGDLID(DisipadorViscoso2DObj)
%       agregarFuerzaResistenteAReacciones(DisipadorViscoso2DObj)
%       guardarPropiedades(DisipadorViscoso2DObj,archivoSalidaHandle)
%       guardarEsfuerzosInternos(DisipadorViscoso2DObj,archivoSalidaHandle)
%       disp(DisipadorViscoso2DObj)
%  Methods SuperClass (ComponenteModelo):
%       etiqueta = obtenerEtiqueta(componenteModeloObj)

classdef DisipadorViscoso2D < Elemento
    
    properties(Access = private)
        nodosObj % Cell con los nodos
        gdlID % Lista con los ID de los grados de libertad
        Ao % Area de la seccion transversal
        Keq % Modulo de elasticidad
        Ceq % Inercia de la seccion
        dx % Distancia en el eje x entre los nodos
        dy % Distancia en el eje y entre los nodos
        L % Largo del elemento
        theta % Angulo de inclinacion de la viga
        Feq % Fuerza equivalente
        T % Matriz de transformacion
        Klp % Matriz de rigidez local del elemento
        PLOTNELEM % Numero de elementos en los que se discretiza para el grafico
    end % properties DisipadorViscoso2D
    
    methods
        
        function DisipadorViscoso2DObj = DisipadorViscoso2D(etiquetaViga, nodo1Obj, nodo2Obj, Ceq, Keq, Amaterial)
            
            % Completa con ceros si no hay argumentos
            if nargin == 0
                etiquetaViga = '';
            end % if
            
            % Llamamos al constructor de la SuperClass que es la clase Elemento
            DisipadorViscoso2DObj = DisipadorViscoso2DObj@Elemento(etiquetaViga);
            
            % Guarda material
            DisipadorViscoso2DObj.nodosObj = {nodo1Obj; nodo2Obj};
            DisipadorViscoso2DObj.Ao = Amaterial;
            DisipadorViscoso2DObj.Keq = Keq;
            DisipadorViscoso2DObj.Ceq = Ceq;
            DisipadorViscoso2DObj.gdlID = [];
            
            % Calcula componentes geometricas
            coordNodo1 = nodo1Obj.obtenerCoordenadas();
            coordNodo2 = nodo2Obj.obtenerCoordenadas();
            DisipadorViscoso2DObj.dx = abs(coordNodo2(1)-coordNodo1(1));
            DisipadorViscoso2DObj.dy = abs(coordNodo2(2)-coordNodo1(2));
            DisipadorViscoso2DObj.L = sqrt(DisipadorViscoso2DObj.dx^2+DisipadorViscoso2DObj.dy^2);
            theta = atan(DisipadorViscoso2DObj.dy/DisipadorViscoso2DObj.dx);
            DisipadorViscoso2DObj.theta = theta;
            
            % Calcula matriz de transformacion dado el angulo
            T =[cosx cosy 0 0 0 0; 0 0 0 cosx cosy 0];
            DisipadorViscoso2DObj.T = T;
            
            % Calcula matriz de rigidez local
            Klp = zeros(6,6);
            DisipadorViscoso2DObj.Klp = Klp;
            
            % Fuerza equivalente de la viga
            DisipadorViscoso2DObj.Feq = [0, 0, 0, 0, 0, 0]';
            
            % Otros
            DisipadorViscoso2DObj.PLOTNELEM = 10;
            
        end % DisipadorViscoso2D constructor
        
        function l = obtenerLargo(DisipadorViscoso2DObj)
            
            l = DisipadorViscoso2DObj.L;
            
        end % obtenerLargo function
        
        function numeroNodos = obtenerNumeroNodos(DisipadorViscoso2DObj) %#ok<MANU>
            
            numeroNodos = 2;
            
        end % obtenerNumeroNodos function
        
        function nodosViga = obtenerNodos(DisipadorViscoso2DObj)
            
            nodosViga = DisipadorViscoso2DObj.nodosObj;
            
        end % obtenerNodos function
        
        function numeroGDL = obtenerNumeroGDL(DisipadorViscoso2DObj) %#ok<MANU>
            
            numeroGDL = 6;
            
        end % obtenerNumeroGDL function
        
        function gdlIDViga = obtenerGDLID(DisipadorViscoso2DObj)
            
            gdlIDViga = DisipadorViscoso2DObj.gdlID;
            
        end % obtenerNumeroGDL function
        
        function T = obtenerMatrizTransformacion(DisipadorViscoso2DObj)
            
            T = DisipadorViscoso2DObj.T;
            
        end % obtenerNumeroGDL function
        
        function theta = obtenerAngulo(DisipadorViscoso2DObj)
            
            theta = DisipadorViscoso2DObj.theta;
            
        end % obtenerAngulo function
        
        function k_global = obtenerMatrizRigidezCoordGlobal(DisipadorViscoso2DObj)
            
            % Multiplica por la matriz de transformacion
            k_local = DisipadorViscoso2DObj.obtenerMatrizRigidezCoordLocal();
            t_theta = DisipadorViscoso2DObj.T;
            k_global = t_theta' * k_local * t_theta;
            
        end % obtenerMatrizRigidezGlobal function
        
        function k_local = obtenerMatrizRigidezCoordLocal(DisipadorViscoso2DObj)
            
            % Retorna la matriz calculada en el consturctor
            k_local = DisipadorViscoso2DObj.Klp;
            
        end % obtenerMatrizRigidezLocal function
        
        function c_local = obtenerMatrizAmortiguamientoCoordLocal(DisipadorViscoso2DObj)
            
            c_local = DisipadorViscoso2DObj.Ceq .*[ 1 -1; -1 1];
                        
        end % obtenerMatrizRigidezLocal function
        
        function fr_global = obtenerFuerzaResistenteCoordGlobal(DisipadorViscoso2DObj)
            
            % Obtiene fr local
            fr_local = DisipadorViscoso2DObj.obtenerFuerzaResistenteCoordLocal();
            
            % Resta a fuerza equivalente para obtener la fuerza global
            fr_local_c = fr_local - DisipadorViscoso2DObj.Feq;
            
            % Calcula fuerza resistente global
            T_theta = DisipadorViscoso2DObj.T;
            fr_global = T_theta' * fr_local_c;
            
        end % obtenerFuerzaResistenteCoordGlobal function
        
        function fr_local = obtenerFuerzaResistenteCoordLocal(DisipadorViscoso2DObj)
            
            % Obtiene los nodos
            nodo1 = DisipadorViscoso2DObj.nodosObj{1};
            nodo2 = DisipadorViscoso2DObj.nodosObj{2};
            
            % Obtiene los desplazamientos
            u1 = nodo1.obtenerDesplazamientos();
            u2 = nodo2.obtenerDesplazamientos();
            
            % Vector desplazamientos u'
            u = [u1(1), u1(2), u1(3), u2(1), u2(2), u2(3)]';
            
            % Obtiene K local
            k_local = DisipadorViscoso2DObj.obtenerMatrizRigidezCoordLocal();
            
            % Obtiene u''
            u = DisipadorViscoso2DObj.obtenerMatrizTransformacion() * u;
            
            % Calcula F
            fr_local = k_local * u;
            
        end % obtenerFuerzaResistenteCoordLocal function
        
        function definirGDLID(DisipadorViscoso2DObj)
            
            % Se obtienen los nodos extremos
            nodo1 = DisipadorViscoso2DObj.nodosObj{1};
            nodo2 = DisipadorViscoso2DObj.nodosObj{2};
            
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
            DisipadorViscoso2DObj.gdlID = gdl;
            
        end % definirGDLID function
        
        function sumarFuerzaEquivalente(DisipadorViscoso2DObj, f)
            
            for i = 1:length(f)
                DisipadorViscoso2DObj.Feq(i) = DisipadorViscoso2DObj.Feq(i) + f(i);
            end
            
        end % guardarFuerzaEquivalente function
        
        function agregarFuerzaResistenteAReacciones(DisipadorViscoso2DObj)
            
            % Se calcula la fuerza resistente global
            fr_global = DisipadorViscoso2DObj.obtenerFuerzaResistenteCoordGlobal();
            
            % Carga los nodos
            nodo1 = DisipadorViscoso2DObj.nodosObj{1};
            nodo2 = DisipadorViscoso2DObj.nodosObj{2};
            
            % Transforma la carga equivalente como carga puntual
            F_eq = DisipadorViscoso2DObj.T' * DisipadorViscoso2DObj.Feq;
            
            % Agrega fuerzas equivalentes como cargas
            nodo1.agregarCarga([-F_eq(1), -F_eq(2), -F_eq(3)]')
            nodo2.agregarCarga([-F_eq(4), -F_eq(5), -F_eq(6)]')
            
            % Agrega fuerzas resistentes como cargas
            nodo1.agregarEsfuerzosElementoAReaccion([fr_global(1), fr_global(2), fr_global(3)]');
            nodo2.agregarEsfuerzosElementoAReaccion([fr_global(4), fr_global(5), fr_global(6)]');
            
        end % agregarFuerzaResistenteAReacciones function
        
        function guardarPropiedades(DisipadorViscoso2DObj, archivoSalidaHandle)
            
            fprintf(archivoSalidaHandle, '\tViga-Columna 2D %s:\n\t\tLargo:\t\t%s\n\t\tInercia:\t%s\n\t\tEo:\t\t\t%s\n\t\tEI:\t\t\t%s\n', ...
                DisipadorViscoso2DObj.obtenerEtiqueta(), num2str(DisipadorViscoso2DObj.L), ...
                num2str(DisipadorViscoso2DObj.Ceq), num2str(DisipadorViscoso2DObj.Keq), num2str(DisipadorViscoso2DObj.Keq*DisipadorViscoso2DObj.Ceq));
            
        end % guardarPropiedades function
        
        function guardarEsfuerzosInternos(DisipadorViscoso2DObj, archivoSalidaHandle)
            
            fr = DisipadorViscoso2DObj.obtenerFuerzaResistenteCoordGlobal();
            n1 = pad(num2str(fr(1), '%.04f'), 10);
            n2 = pad(num2str(fr(4), '%.04f'), 10);
            v1 = pad(num2str(fr(2), '%.04f'), 10);
            v2 = pad(num2str(fr(5), '%.04f'), 10);
            m1 = pad(num2str(fr(3), '%.04f'), 10);
            m2 = pad(num2str(fr(6), '%.04f'), 10);
            
            fprintf(archivoSalidaHandle, '\n\tViga-Columna 2D %s:\n\t\tAxial:\t\t%s %s\n\t\tCorte:\t\t%s %s\n\t\tMomento:\t%s %s', ...
                DisipadorViscoso2DObj.obtenerEtiqueta(), n1, n2, v1, v2, m1, m2);
            
        end % guardarEsfuerzosInternos function
        
        function plot(elementoObj, deformadas, tipoLinea, grosorLinea, ~)
            % plot: Grafica un elemento
            %
            % plot(elementoObj,deformadas,tipoLinea,grosorLinea)
            
            % Obtiene las coordenadas de los objetos
            coord1 = elementoObj.nodosObj{1}.obtenerCoordenadas();
            coord2 = elementoObj.nodosObj{2}.obtenerCoordenadas();
            
            % Si hay deformacion
            if ~isempty(deformadas)
                coord1 = coord1 + deformadas{1}(1:2);
                coord2 = coord2 + deformadas{2}(1:2);
            end
            
            % Grafica en forma lineal
            elementoObj.graficarLinea(coord1, coord2, tipoLinea, grosorLinea);
            
        end % plot function
        
        function disp(DisipadorViscoso2DObj)
            
            % Imprime propiedades de la Viga-Columna 2D
            fprintf('Propiedades Viga-Columna 2D:\n\t');
            disp@ComponenteModelo(DisipadorViscoso2DObj);
            fprintf('\t\tLargo: %s\tArea: %s\tI: %s\tE: %s\n', pad(num2str(DisipadorViscoso2DObj.L), 12), ...
                pad(num2str(DisipadorViscoso2DObj.Ao), 10), pad(num2str(DisipadorViscoso2DObj.Ceq), 10), ...
                pad(num2str(DisipadorViscoso2DObj.Keq), 10));
            
            % Se imprime matriz de rigidez local
            fprintf('\tMatriz de rigidez coordenadas locales:\n');
            disp(DisipadorViscoso2DObj.obtenerMatrizRigidezCoordLocal());
            
            % Se imprime matriz de rigidez global
            fprintf('\tMatriz de rigidez coordenadas globales:\n');
            disp(DisipadorViscoso2DObj.obtenerMatrizRigidezCoordGlobal());
            
            fprintf('-------------------------------------------------\n');
            fprintf('\n');
            
        end % disp function
        
    end % methods DisipadorViscoso2D
    
end % class DisipadorViscoso2D