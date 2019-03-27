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
%|                                                                      |
%| Desarrollado por:                                                    |
%|       Pablo Pizarro R. @ppizarror.com                                |
%|       Estudiante de Magister en Ingeniería Civil Estructural         |
%|       Universidad de Chile                                           |
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
%|                 PABLO PIZARRO @ppizarror - 14/05/2018                |
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
%
%  Methods:
%       biela2DObj = Biela2D(etiquetaBiela,nodo1Obj,nodo2Obj,AreaSeccion,Ematerial)
%       numeroNodos = obtenerNumeroNodos(biela2DObj)
%       nodosBiela = obtenerNodos(biela2DObj)
%       numeroGDL = obtenerNumeroGDL(biela2DObj)
%       gdlIDBiela = obtenerGDLID(biela2DObj)
%       k_global = obtenerMatrizRigidezCoordGlobal(biela2DObj)
%       k_local = obtenerMatrizRigidezCoordLocal(biela2DObj)
%       fr_global = obtenerFuerzaResistenteCoordGlobal(biela2DObj)
%       fr_local = obtenerFuerzaResistenteCoordLocal(biela2DObj)
%       ae = obtenerAE(biela2DObj)
%       theta = obtenerAngulo(biela2DObj)
%       definirGDLID(biela2DObj)
%       sumarCargaTemperaturaReaccion(biela2DObj,f)
%       agregarFuerzaResistenteAReacciones(biela2DObj)
%       guardarPropiedades(biela2DObj,archivoSalidaHandle)
%       guardarEsfuerzosInternos(biela2DObj,archivoSalidaHandle)
%       disp(biela2DObj)
%
%  Methods SuperClass (ComponenteModelo):
%       etiqueta = obtenerEtiqueta(componenteModeloObj)

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
    end % properties Biela2D
    
    methods
        
        function biela2DObj = Biela2D(etiquetaBiela, nodo1Obj, nodo2Obj, AreaSeccion, Ematerial)
            
            % Si no hay argumentos completa con ceros
            if nargin == 0
                etiquetaBiela = '';
            end % if
            
            %Llamamos al constructor de la SuperClass que es la clase Elemento
            biela2DObj = biela2DObj@Elemento(etiquetaBiela);
            
            biela2DObj.nodosObj = {nodo1Obj; nodo2Obj};
            biela2DObj.Eo = Ematerial;
            biela2DObj.Ao = AreaSeccion;
            biela2DObj.gdlID = [];
            
            coordNodo1 = nodo1Obj.obtenerCoordenadas();
            coordNodo2 = nodo2Obj.obtenerCoordenadas();
            
            biela2DObj.dx = (coordNodo2(1) - coordNodo1(1));
            biela2DObj.dy = (coordNodo2(2) - coordNodo1(2));
            biela2DObj.theta = atan(biela2DObj.dy/biela2DObj.dx);
            
            biela2DObj.L = sqrt(biela2DObj.dx^2+biela2DObj.dy^2);
            biela2DObj.TcargaReacc = [0, 0, 0, 0]';
            
        end % Biela2D constructor
        
        function numeroNodos = obtenerNumeroNodos(biela2DObj) %#ok<MANU>
            
            numeroNodos = 2;
            
        end % obtenerNumeroNodos function
        
        function nodosBiela = obtenerNodos(biela2DObj)
            
            nodosBiela = biela2DObj.nodosObj;
            
        end % obtenerNodos function
        
        function numeroGDL = obtenerNumeroGDL(biela2DObj) %#ok<MANU>
            
            numeroGDL = 4;
            
        end % obtenerNumeroGDL function
        
        function gdlIDBiela = obtenerGDLID(biela2DObj)
            
            gdlIDBiela = biela2DObj.gdlID;
            
        end % gdlIDBiela function
        
        function ae = obtenerAE(biela2DObj)
            
            ae = biela2DObj.Ao * biela2DObj.Eo;
            
        end % obtenerAE function
        
        function theta = obtenerAngulo(biela2DObj)
            
            theta = biela2DObj.theta;
            
        end % obtenerAngulo function
        
        function k_global = obtenerMatrizRigidezCoordGlobal(biela2DObj)
            
            % Obtiene la matriz de coordenadas locales
            k_local = biela2DObj.obtenerMatrizRigidezCoordLocal();
            
            % Obtiene el angulo
            tht = biela2DObj.obtenerAngulo();
            
            % Se crea matriz de transformacion
            t_theta = [cos(tht), sin(tht), 0, 0; ...
                -sin(tht), cos(tht), 0, 0; ...
                0, 0, cos(tht), sin(tht); ...
                0, 0, -sin(tht), cos(tht);];
            
            % Multiplica k*t_theta
            k_global = t_theta' * k_local * t_theta;
            
        end % obtenerMatrizRigidezGlobal function
        
        function k_local = obtenerMatrizRigidezCoordLocal(biela2DObj)
            
            % Genera matriz
            k_local = [1, 0, -1, 0; 0, 0, 0, 0; -1, 0, 1, 0; 0, 0, 0, 0];
            
            % Multiplica por AoEo/L
            k_local = k_local .* (biela2DObj.Eo * biela2DObj.Ao / biela2DObj.L);
            
        end % obtenerMatrizRigidezLocal function
        
        function fr_global = obtenerFuerzaResistenteCoordGlobal(biela2DObj)
            
            % Obtiene fr local
            fr_local = biela2DObj.obtenerFuerzaResistenteCoordLocal();
            
            % Calcula matriz transformacion
            tht = biela2DObj.obtenerAngulo();
            t_theta = [cos(tht), sin(tht), 0, 0; ...
                -sin(tht), cos(tht), 0, 0; ...
                0, 0, cos(tht), sin(tht); ...
                0, 0, -sin(tht), cos(tht);];
            
            % Calcula fuerza resistente global
            fr_global = t_theta' * fr_local;
            
        end % obtenerFuerzaResistenteCoordGlobal function
        
        function fr_local = obtenerFuerzaResistenteCoordLocal(biela2DObj)
            
            % Obtiene los nodos
            nodo1 = biela2DObj.nodosObj{1};
            nodo2 = biela2DObj.nodosObj{2};
            
            % Obtiene los desplazamientos
            u1 = nodo1.obtenerDesplazamientos();
            u2 = nodo2.obtenerDesplazamientos();
            
            % Vector desplazamientos u'
            u = [u1(1); u1(2); u2(1); u2(2)];
            
            % Calcula matriz de transformacion
            tht = biela2DObj.obtenerAngulo();
            t_theta = [cos(tht), sin(tht), 0, 0; ...
                -sin(tht), cos(tht), 0, 0; ...
                0, 0, cos(tht), sin(tht); ...
                0, 0, -sin(tht), cos(tht);];
            
            % Calcula u''
            f = t_theta * u;
            
            % Obtiene K local
            k_local = biela2DObj.obtenerMatrizRigidezCoordLocal();
            
            % Calcula F
            fr_local = k_local * f;
            
        end % obtenerFuerzaResistenteCoordLocal function
        
        function definirGDLID(biela2DObj)
            
            % Se obtienen los nodos extremos
            nodo1 = biela2DObj.nodosObj{1};
            nodo2 = biela2DObj.nodosObj{2};
            
            % Se obtienen los gdl de los nodos
            gdlnodo1 = nodo1.obtenerGDLID();
            gdlnodo2 = nodo2.obtenerGDLID();
            
            % Se establecen gdl
            gdl = [0, 0, 0, 0];
            gdl(1) = gdlnodo1(1);
            gdl(2) = gdlnodo1(2);
            gdl(3) = gdlnodo2(1);
            gdl(4) = gdlnodo2(2);
            biela2DObj.gdlID = gdl;
            
        end % definirGDLID function
        
        function sumarCargaTemperaturaReaccion(biela2DObj, f)
            
            for i = 1:length(f)
                if (biela2DObj.gdlID(i) == 0)
                    biela2DObj.TcargaReacc(i) = biela2DObj.TcargaReacc(i) + f(i);
                end
            end
            
        end % guardarFuerzaEquivalente function
        
        function agregarFuerzaResistenteAReacciones(biela2DObj)
            
            % Se calcula la fuerza resistente
            fr_global = biela2DObj.obtenerFuerzaResistenteCoordGlobal();
            
            % Carga los nodos
            nodo1 = biela2DObj.nodosObj{1};
            nodo2 = biela2DObj.nodosObj{2};
            
            % Suma fuerza de temperatura en reacciones
            nodo1.agregarCarga([biela2DObj.TcargaReacc(1); biela2DObj.TcargaReacc(2)]);
            nodo2.agregarCarga([biela2DObj.TcargaReacc(3); biela2DObj.TcargaReacc(4)]);
            
            % Agrega fuerzas resistentes como cargas
            nodo1.agregarCarga(-[fr_global(1); fr_global(2)]);
            nodo2.agregarCarga(-[fr_global(3); fr_global(4)]);
            
        end % agregarFuerzaResistenteAReacciones function
        
        function guardarPropiedades(biela2DObj, archivoSalidaHandle)
            
            fprintf(archivoSalidaHandle, '\tBiela2D %s:\n\t\tLargo:\t%s\n\t\tArea:\t%s\n\t\tEo:\t\t%s\n', ...
                biela2DObj.obtenerEtiqueta(), num2str(biela2DObj.L), ...
                num2str(biela2DObj.Ao), num2str(biela2DObj.Eo));
            
        end % guardarPropiedades function
        
        function guardarEsfuerzosInternos(biela2DObj, archivoSalidaHandle)
            
            esf_int = biela2DObj.obtenerFuerzaResistenteCoordLocal();
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
            
            fprintf(archivoSalidaHandle, '\n\tBiela 2D %s:\t%s%s', biela2DObj.obtenerEtiqueta(), ...
                pad(num2str(f), 15), t);
            
        end % guardarEsfuerzosInternos function
        
        function plot(elementoObj, deformadas, tipoLinea, grosorLinea)
            % plot: Grafica un elemento
            %
            % plot(elementoObj,deformadas,tipoLinea,grosorLinea)
            
            % Obtiene las coordenadas de los objetos
            coord1 = elementoObj.nodosObj{1}.obtenerCoordenadas();
            coord2 = elementoObj.nodosObj{2}.obtenerCoordenadas();
            
            % Si hay deformadas
            if ~isempty(deformadas)
                coord1 = coord1 + deformadas{1};
                coord2 = coord2 + deformadas{2};
            end
            
            % Grafica el elemento
            elementoObj.graficarLinea(coord1, coord2, tipoLinea, grosorLinea);
            
        end % plot function
        
        function disp(biela2DObj)
            
            % Imprime propiedades
            fprintf('Propiedades Biela 2D:\n\t');
            disp@ComponenteModelo(biela2DObj);
            fprintf('\t\tLargo: %s\tArea: %s\tE: %s\n', pad(num2str(biela2DObj.L), 12), ...
                pad(num2str(biela2DObj.Ao), 10), pad(num2str(biela2DObj.Eo), 10));
            
            % Se imprime matriz de rigidez local
            fprintf('\tMatriz de rigidez coordenadas locales:\n');
            disp(biela2DObj.obtenerMatrizRigidezCoordLocal());
            
            % Se imprime matriz de rigidez global
            fprintf('\tMatriz de rigidez coordenadas globales:\n');
            disp(biela2DObj.obtenerMatrizRigidezCoordGlobal());
            
            fprintf('-------------------------------------------------\n');
            fprintf('\n');
            
        end % disp function
        
    end % methods Biela2D
    
end % class Biela2D