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
%| Clase Biela2D                                                        |
%|                                                                      |
%| Este archivo contiene la definicion de la Clase Biela2D              |
%| Biela2D  es una  subclase de la  clase Elemento y  corresponde a  la |
%| representacion del elemento  biela o  barra que solo tiene  esfuerzo |
%| Axiales                                                              |
%|                                                                      |
%| Programado: FR                                                       |
%| Fecha: 05/08/2015                                                    |
%|                                                                      |
%| Modificado por: FR - 24/10/2016                                      |
%|                 Pablo Pizarro @ppizarror - 14/05/2018                |
%|______________________________________________________________________|
%
%  Properties (Access=private):
%       nodosObj
%       gdlID
%       Eo
%       Ao
%       dx
%       dy
%       L
%       theta
%       T
%       TcargaReacc
%       rho
%  Methods:
%       obj = Biela2D(etiquetaBiela,nodo1Obj,nodo2Obj,AreaSeccion,Ematerial,densidad)
%       numeroNodos = obtenerNumeroNodos(obj)
%       nodosBiela = obtenerNodos(obj)
%       numeroGDL = obtenerNumeroGDL(obj)
%       gdlIDBiela = obtenerGDLID(obj)
%       k_global = obtenerMatrizRigidezCoordGlobal(obj)
%       k_local = obtenerMatrizRigidezCoordLocal(obj)
%       fr_global = obtenerFuerzaResistenteCoordGlobal(obj)
%       fr_local = obtenerFuerzaResistenteCoordLocal(obj)
%       ae = obtenerAE(obj)
%       theta = obtenerAngulo(obj)
%       definirGDLID(obj)
%       sumarCargaTemperaturaReaccion(obj,f)
%       agregarFuerzaResistenteAReacciones(obj)
%       guardarPropiedades(obj,archivoSalidaHandle)
%       guardarEsfuerzosInternos(obj,archivoSalidaHandle)
%       disp(obj)
%  Methods SuperClass (ComponenteModelo):
%       etiqueta = obtenerEtiqueta(obj)
%       e = equals(obj,obj)
%       objID = obtenerIDObjeto(obj)

classdef Biela2D < Elemento
    
    properties(Access = private)
        nodosObj % Cell con los nodos
        gdlID % Lista con los ID de los grados de libertad
        Ao % Area de la seccion transversal
        Eo % Modulo de elasticidad
        dx % Distancia en el eje x entre los nodos
        dy % Distancia en el eje y entre los nodos
        dz % Distancia en el eje z entre los nodos
        L % Largo del elemento
        theta % Angulo de inclinacion de la viga
        T % Matriz de transformacion
        TcargaReacc % Reaccion de la biela guardada como un vector
        rho % Densidad de la biela
    end % private properties Biela2D
    
    methods(Access = public)
        
        function obj = Biela2D(etiquetaBiela, nodo1Obj, nodo2Obj, AreaSeccion, Ematerial, densidad)
            % Biela2D: Constructor de clase, genera una biela en dos dimensiones
            
            % Si no hay argumentos completa con ceros
            if nargin == 0
                etiquetaBiela = '';
            end % if
            if ~exist('densidad', 'var')
                densidad = 0;
            end
            
            % Llamamos al constructor de la SuperClass que es la clase Elemento
            obj = obj@Elemento(etiquetaBiela);
            
            obj.nodosObj = {nodo1Obj; nodo2Obj};
            obj.Eo = Ematerial;
            obj.Ao = AreaSeccion;
            obj.gdlID = [];
            obj.rho = densidad;
            
            coordNodo1 = nodo1Obj.obtenerCoordenadas();
            coordNodo2 = nodo2Obj.obtenerCoordenadas();
            
            obj.dx = abs(coordNodo2(1)-coordNodo1(1));
            obj.dy = abs(coordNodo2(2)-coordNodo1(2));
            obj.theta = atan(obj.dy/obj.dx);
            
            obj.L = sqrt(obj.dx^2+obj.dy^2);
            obj.TcargaReacc = [0, 0, 0, 0]';
            
            % Agrega el elemento a los nodos
            for i = 1:2
                obj.nodosObj{i}.agregarElementos(obj);
            end
            
        end % Biela2D constructor
        
        function numeroNodos = obtenerNumeroNodos(obj) %#ok<MANU>
            % obtenerNumeroNodos: Obtiene el numero de nodos
            
            numeroNodos = 2;
            
        end % obtenerNumeroNodos function
        
        function nodosBiela = obtenerNodos(obj)
            % obtenerNodos: Obtiene los nodos de la biela
            
            nodosBiela = obj.nodosObj;
            
        end % obtenerNodos function
        
        function numeroGDL = obtenerNumeroGDL(obj) %#ok<MANU>
            % obtenerNumeroGDL: Obtiene el numero de GDL de la biela
            
            numeroGDL = 4;
            
        end % obtenerNumeroGDL function
        
        function gdlIDBiela = obtenerGDLID(obj)
            % obtenerGDLID: Obtiene los GDLID de la biela
            
            gdlIDBiela = obj.gdlID;
            
        end % gdlIDBiela function
        
        function ae = obtenerAE(obj)
            % obtenerAE: Obtiene el A*E de la biela
            
            ae = obj.Ao * obj.Eo;
            
        end % obtenerAE function
        
        function theta = obtenerAngulo(obj)
            % obtenerAngulo: Obtiene el angulo de inclinacion de la biela
            
            theta = obj.theta;
            
        end % obtenerAngulo function
        
        function m = obtenerMasa(obj)
            % obtenerMasa: Retorna la masa total del elemento
            
            m = obj.rho * obj.L * obj.Ao;
            
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
            % obtenerMatrizRigidezCoordGlobal: Obtiene la matriz de rigidez
            % en coordenadas globales de la biela
            
            % Obtiene la matriz de coordenadas locales
            k_local = obj.obtenerMatrizRigidezCoordLocal();
            
            % Obtiene el angulo
            tht = obj.obtenerAngulo();
            
            % Se crea matriz de transformacion
            t_theta = [cos(tht), sin(tht), 0, 0; ...
                -sin(tht), cos(tht), 0, 0; ...
                0, 0, cos(tht), sin(tht); ...
                0, 0, -sin(tht), cos(tht);];
            
            % Multiplica k*t_theta
            k_global = t_theta' * k_local * t_theta;
            
        end % obtenerMatrizRigidezCoordGlobal function
        
        function k_local = obtenerMatrizRigidezCoordLocal(obj)
            % obtenerMatrizRigidezCoordLocal: Obtiene la matriz de rigidez
            % en coordenadas locales
            
            % Genera matriz
            k_local = [1, 0, -1, 0; 0, 0, 0, 0; -1, 0, 1, 0; 0, 0, 0, 0];
            
            % Multiplica por AoEo/L
            k_local = k_local .* (obj.Eo * obj.Ao / obj.L);
            
        end % obtenerMatrizRigidezCoordLocal function
        
        function fr_global = obtenerFuerzaResistenteCoordGlobal(obj)
            % obtenerFuerzaResistenteCoordGlobal: Obtiene la fuerza resistente en
            % coodenadas globales
            
            % Obtiene fr local
            fr_local = obj.obtenerFuerzaResistenteCoordLocal();
            
            % Calcula matriz transformacion
            tht = obj.obtenerAngulo();
            t_theta = [cos(tht), sin(tht), 0, 0; ...
                -sin(tht), cos(tht), 0, 0; ...
                0, 0, cos(tht), sin(tht); ...
                0, 0, -sin(tht), cos(tht);];
            
            % Calcula fuerza resistente global
            fr_global = t_theta' * fr_local;
            
        end % obtenerFuerzaResistenteCoordGlobal function
        
        function fr_local = obtenerFuerzaResistenteCoordLocal(obj)
            % obtenerFuerzaResistenteCoordLocal: Obtiene la fuerza resistente
            % en coordenadas locales
            
            % Obtiene los nodos
            nodo1 = obj.nodosObj{1};
            nodo2 = obj.nodosObj{2};
            
            % Obtiene los desplazamientos
            u1 = nodo1.obtenerDesplazamientos();
            u2 = nodo2.obtenerDesplazamientos();
            
            % Vector desplazamientos u'
            u = [u1(1); u1(2); u2(1); u2(2)];
            
            % Calcula matriz de transformacion
            tht = obj.obtenerAngulo();
            t_theta = [cos(tht), sin(tht), 0, 0; ...
                -sin(tht), cos(tht), 0, 0; ...
                0, 0, cos(tht), sin(tht); ...
                0, 0, -sin(tht), cos(tht);];
            
            % Calcula u''
            f = t_theta * u;
            
            % Obtiene K local
            k_local = obj.obtenerMatrizRigidezCoordLocal();
            
            % Calcula F
            fr_local = k_local * f;
            
        end % obtenerFuerzaResistenteCoordLocal function
        
        function definirGDLID(obj)
            % definirGDLID: Define los ID de los grados de libertad de la biela
            
            % Se obtienen los nodos extremos
            nodo1 = obj.nodosObj{1};
            nodo2 = obj.nodosObj{2};
            
            % Se obtienen los gdl de los nodos
            gdlnodo1 = nodo1.obtenerGDLID();
            gdlnodo2 = nodo2.obtenerGDLID();
            
            % Se establecen gdl
            gdl = [0, 0, 0, 0];
            gdl(1) = gdlnodo1(1);
            gdl(2) = gdlnodo1(2);
            gdl(3) = gdlnodo2(1);
            gdl(4) = gdlnodo2(2);
            obj.gdlID = gdl;
            
        end % definirGDLID function
        
        function sumarCargaTemperaturaReaccion(obj, f)
            % sumarCargaTemperaturaReaccion: Suma temperatura a reacciones
            
            for i = 1:length(f)
                if (obj.gdlID(i) == 0)
                    obj.TcargaReacc(i) = obj.TcargaReacc(i) + f(i);
                end
            end % for i
            
        end % sumarCargaTemperaturaReaccion function
        
        function agregarFuerzaResistenteAReacciones(obj)
            % agregarFuerzaResistenteAReacciones: Agrega fuerza resistente a reacciones
            
            % Se calcula la fuerza resistente
            fr_global = obj.obtenerFuerzaResistenteCoordGlobal();
            
            % Carga los nodos
            nodo1 = obj.nodosObj{1};
            nodo2 = obj.nodosObj{2};
            
            % Suma fuerza de temperatura en reacciones
            nodo1.agregarCarga([obj.TcargaReacc(1); obj.TcargaReacc(2)]);
            nodo2.agregarCarga([obj.TcargaReacc(3); obj.TcargaReacc(4)]);
            
            % Agrega fuerzas resistentes como cargas
            nodo1.agregarCarga(-[fr_global(1); fr_global(2)]);
            nodo2.agregarCarga(-[fr_global(3); fr_global(4)]);
            
        end % agregarFuerzaResistenteAReacciones function
        
        function guardarPropiedades(obj, archivoSalidaHandle)
            % guardarPropiedades: Guarda las propiedades de la biela
            
            fprintf(archivoSalidaHandle, '\tBiela2D %s:\n\t\tLargo:\t%s\n\t\tArea:\t%s\n\t\tEo:\t\t%s\n\t\tMasa:\t%s\n', ...
                obj.obtenerEtiqueta(), num2str(obj.L), ...
                num2str(obj.Ao), num2str(obj.Eo), ...
                num2str(obj.obtenerMasa()));
            
        end % guardarPropiedades function
        
        function guardarEsfuerzosInternos(obj, archivoSalidaHandle)
            % guardarEsfuerzosInternos: Guarda los esfuerzos internos de la biela
            
            esf_int = obj.obtenerFuerzaResistenteCoordLocal();
            f = esf_int(1);
            
            % Determina si es traccion o compresion
            t = 'TRACCION';
            if f > 0
                t = 'COMPRESION';
            end
            if abs(f) < 1e-10
                t = '--';
                f = 0;
            end
            
            fprintf(archivoSalidaHandle, '\n\tBiela 2D %s:\t%s%s', obj.obtenerEtiqueta(), ...
                pad(num2str(f), 15), t);
            
        end % guardarEsfuerzosInternos function
        
        function plot(obj, deformadas, tipoLinea, grosorLinea, ~)
            % plot: Grafica un elemento
            
            % Obtiene las coordenadas de los objetos
            coord1 = obj.nodosObj{1}.obtenerCoordenadas();
            coord2 = obj.nodosObj{2}.obtenerCoordenadas();
            
            % Si hay deformadas
            if ~isempty(deformadas)
                coord1 = coord1 + deformadas{1};
                coord2 = coord2 + deformadas{2};
            end
            
            % Grafica el elemento
            obj.graficarLinea(coord1, coord2, tipoLinea, grosorLinea);
            
        end % plot function
        
        function disp(obj)
            % disp: Imprime propiedades en consola
            
            % Imprime propiedades
            fprintf('Propiedades biela 2D:\n\t');
            disp@ComponenteModelo(obj);
            
            fprintf('\t\tLargo: %s\tArea: %s\tE: %s\n', pad(num2str(obj.L), 12), ...
                pad(num2str(obj.Ao), 10), pad(num2str(obj.Eo), 10));
            
            % Se imprime matriz de rigidez local
            fprintf('\tMatriz de rigidez coordenadas locales:\n');
            disp(obj.obtenerMatrizRigidezCoordLocal());
            
            % Se imprime matriz de rigidez global
            fprintf('\tMatriz de rigidez coordenadas globales:\n');
            disp(obj.obtenerMatrizRigidezCoordGlobal());
            
            dispMetodoTEFAME();
            
        end % disp function
        
    end % public methods Biela2D
    
end % class Biela2D