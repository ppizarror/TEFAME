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
%| Clase Biela3D                                                        |
%|                                                                      |
%| Este archivo contiene la definicion de la Clase Biela3D              |
%| Biela3D  es una  subclase de la  clase Elemento y  corresponde a  la |
%| representacion del elemento  biela o  barra que solo tiene  esfuerzo |
%| Axiales en un sistema de tres coordenadas.                           |
%|                                                                      |
%| Programado por: Pablo Pizarro @ppizarror - 14/05/2018                |
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
%  Methods:
%       biela3DObj = Biela3D(etiquetaBiela,nodo1Obj,nodo2Obj,AreaSeccion,Ematerial)
%       numeroNodos = obtenerNumeroNodos(biela3DObj)
%       nodosBiela = obtenerNodos(biela3DObj)
%       numeroGDL = obtenerNumeroGDL(biela3DObj)
%       gdlIDBiela = obtenerGDLID(biela3DObj)
%       k_global = obtenerMatrizRigidezCoordGlobal(biela3DObj)
%       k_local = obtenerMatrizRigidezCoordLocal(biela3DObj)
%       fr_global = obtenerFuerzaResistenteCoordGlobal(biela3DObj)
%       fr_local = obtenerFuerzaResistenteCoordLocal(biela3DObj)
%       ae = obtenerAE(biela3DObj)
%       theta = obtenerAngulo(biela3DObj)
%       definirGDLID(biela3DObj)
%       agregarFuerzaResistenteAReacciones(biela3DObj)
%       guardarPropiedades(biela3DObj,archivoSalidaHandle)
%       guardarEsfuerzosInternos(biela3DObj,archivoSalidaHandle)
%       disp(biela3DObj)
%  Methods SuperClass (ComponenteModelo):
%       etiqueta = obtenerEtiqueta(componenteModeloObj)
%       e = equals(componenteModeloObj,obj)

classdef Biela3D < Elemento
    
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
    end % properties Biela3D
    
    methods
        
        function biela3DObj = Biela3D(etiquetaBiela, nodo1Obj, nodo2Obj, AreaSeccion, Ematerial)
            % Biela3D: Constructor de clase, genera una biela en tres dimensiones
            %
            % biela3DObj = Biela3D(etiquetaBiela,nodo1Obj,nodo2Obj,AreaSeccion,Ematerial)
            
            % Si no hay argumentos completa con ceros
            if nargin == 0
                etiquetaBiela = '';
            end % if
            
            % Llamamos al constructor de la SuperClass que es la clase Elemento
            biela3DObj = biela3DObj@Elemento(etiquetaBiela);
            
            biela3DObj.nodosObj = {nodo1Obj; nodo2Obj};
            biela3DObj.Eo = Ematerial;
            biela3DObj.Ao = AreaSeccion;
            biela3DObj.gdlID = [];
            
            coordNodo1 = nodo1Obj.obtenerCoordenadas();
            coordNodo2 = nodo2Obj.obtenerCoordenadas();
            
            % Calcula propiedades geometricas
            biela3DObj.dx = abs(coordNodo2(1)-coordNodo1(1));
            biela3DObj.dy = abs(coordNodo2(2)-coordNodo1(2));
            biela3DObj.dz = abs(coordNodo2(3)-coordNodo1(3));
            biela3DObj.theta = atan(biela3DObj.dy/biela3DObj.dx);
            
            % Largo de la biela
            biela3DObj.L = sqrt(biela3DObj.dx^2+biela3DObj.dy^2+biela3DObj.dz^2);
            
            % Calcula matriz de transformacion
            cosx = biela3DObj.dx / biela3DObj.L;
            cosy = biela3DObj.dy / biela3DObj.L;
            cosz = biela3DObj.dz / biela3DObj.L;
            biela3DObj.T = [cosx, cosy, cosz, 0, 0, 0; 0, 0, 0, cosx, cosy, cosz];
            
        end % Biela2D constructor
        
        function numeroNodos = obtenerNumeroNodos(biela3DObj) %#ok<MANU>
            
            numeroNodos = 2;
            
        end % obtenerNumeroNodos function
        
        function nodosBiela = obtenerNodos(biela3DObj)
            
            nodosBiela = biela3DObj.nodosObj;
            
        end % obtenerNodos function
        
        function numeroGDL = obtenerNumeroGDL(biela3DObj) %#ok<MANU>
            
            numeroGDL = 6;
            
        end % obtenerNumeroGDL function
        
        function gdlIDBiela = obtenerGDLID(biela3DObj)
            
            gdlIDBiela = biela3DObj.gdlID;
            
        end % gdlIDBiela function
        
        function ae = obtenerAE(biela3DObj)
            
            ae = biela3DObj.Ao * biela3DObj.Eo;
            
        end % obtenerAE function
        
        function theta = obtenerAngulo(biela3DObj)
            
            theta = biela3DObj.theta;
            
        end % obtenerAngulo function
        
        function k_global = obtenerMatrizRigidezCoordGlobal(biela3DObj)
            
            % Obtiene la matriz de coordenadas locales
            k_local = biela3DObj.obtenerMatrizRigidezCoordLocal();
            
            % Premultiplica y multiplica por [T]
            k_global = biela3DObj.T' * k_local * biela3DObj.T;
            
        end % obtenerMatrizRigidezCoordGlobal function
        
        function k_local = obtenerMatrizRigidezCoordLocal(biela3DObj)
            
            % Genera matriz
            k_local = [1, -1; -1, 1];
            
            % Multiplica por AoEo/L
            k_local = k_local .* (biela3DObj.Eo * biela3DObj.Ao / biela3DObj.L);
            
        end % obtenerMatrizRigidezCoordLocal function
        
        function fr_global = obtenerFuerzaResistenteCoordGlobal(biela3DObj)
            
            % Obtiene fr local
            fr_local = biela3DObj.obtenerFuerzaResistenteCoordLocal();
            
            % Calcula fuerza resistente global
            fr_global = biela3DObj.T' * fr_local;
            
        end % obtenerFuerzaResistenteCoordGlobal function
        
        function fr_local = obtenerFuerzaResistenteCoordLocal(biela3DObj)
            
            % Obtiene los nodos
            nodo1 = biela3DObj.nodosObj{1};
            nodo2 = biela3DObj.nodosObj{2};
            
            % Obtiene los desplazamientos
            u1 = nodo1.obtenerDesplazamientos();
            u2 = nodo2.obtenerDesplazamientos();
            
            % Vector desplazamientos u'
            u = [u1(1); u1(2); u1(3); u2(1); u2(2); u2(3)];
            
            % Calcula u''
            f = biela3DObj.T * u;
            
            % Obtiene K local
            k_local = biela3DObj.obtenerMatrizRigidezCoordLocal();
            
            % Calcula F
            fr_local = k_local * f;
            
        end % obtenerFuerzaResistenteCoordLocal function
        
        function definirGDLID(biela3DObj)
            
            % Se obtienen los nodos extremos
            nodo1 = biela3DObj.nodosObj{1};
            nodo2 = biela3DObj.nodosObj{2};
            
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
            biela3DObj.gdlID = gdl;
            
        end % definirGDLID function
        
        function agregarFuerzaResistenteAReacciones(biela3DObj)
            
            % Se calcula la fuerza resistente
            fr_global = biela3DObj.obtenerFuerzaResistenteCoordGlobal();
            
            % Carga los nodos
            nodo1 = biela3DObj.nodosObj{1};
            nodo2 = biela3DObj.nodosObj{2};
            
            % Agrega fuerzas resistentes como cargas
            nodo1.agregarCarga(-[fr_global(1); fr_global(2); fr_global(3)]);
            nodo2.agregarCarga(-[fr_global(4); fr_global(5); fr_global(6)]);
            
        end % agregarFuerzaResistenteAReacciones function
        
        function guardarPropiedades(biela3DObj, archivoSalidaHandle)
            
            fprintf(archivoSalidaHandle, '\tBiela3D %s:\n\t\tLargo:\t%s\n\t\tArea:\t%s\n\t\tEo:\t\t%s\n', ...
                biela3DObj.obtenerEtiqueta(), num2str(biela3DObj.L), ...
                num2str(biela3DObj.Ao), num2str(biela3DObj.Eo));
            
        end % guardarPropiedades function
        
        function guardarEsfuerzosInternos(biela3DObj, archivoSalidaHandle)
            
            esf_int = biela3DObj.obtenerFuerzaResistenteCoordLocal();
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
            
            fprintf(archivoSalidaHandle, '\n\tBiela 3D %s:\t%s%s', biela3DObj.obtenerEtiqueta(), ...
                pad(num2str(f), 15), t);
            
        end % guardarEsfuerzosInternos function
        
        function plot(elementoObj, deformadas, tipoLinea, grosorLinea, ~)
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
        
        function disp(biela3DObj)
            
            % Imprime propiedades
            fprintf('Propiedades biela 3D:\n');
            disp@ComponenteModelo(biela3DObj);
            fprintf('\tLargo: %s\tArea: %s\tE: %s\n', pad(num2str(biela3DObj.L), 12), ...
                pad(num2str(biela3DObj.Ao), 10), pad(num2str(biela3DObj.Eo), 10));
            
            % Imprime la matiz de transformacion
            fprintf('\tMatriz de transformacion:\n');
            disp(biela3DObj.T);
            
            % Se imprime matriz de rigidez local
            fprintf('\tMatriz de rigidez coordenadas locales:\n');
            disp(biela3DObj.obtenerMatrizRigidezCoordLocal());
            
            % Se imprime matriz de rigidez global
            fprintf('\tMatriz de rigidez coordenadas globales:\n');
            disp(biela3DObj.obtenerMatrizRigidezCoordGlobal());
            
            fprintf('-------------------------------------------------\n');
            fprintf('\n');
            
        end % disp function
        
    end % methods Biela3D
    
end % class Biela3D