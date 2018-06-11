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
%|       Fabian Rojas, PhD (frojas@ing.uchile.cl)                       |
%|       Prof. Asistente, Departamento de Ingenieria Civil              |
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
%       bielaObj = Biela2D(etiquetaBiela,nodo1Obj,nodo2Obj,AreaSeccion,Ematerial)
%       numeroNodos = obtenerNumeroNodos(biela2DObj)
%       nodosBiela = obtenerNodos(biela2DObj)
%       numeroGDL = obtenerNumeroGDL(biela2DObj)
%       gdlIDBiela = obtenerGDLID(biela2DObj)
%       k_global = obtenerMatrizRigidezCoordGlobal(biela2DObj)
%       k_local = obtenerMatrizRigidezCoordLocal(biela2DObj)
%       fr_global = obtenerFuerzaResistenteCoordGlobal(biela2DObj)
%       fr_local = obtenerFuerzaResistenteCoordLocal(biela2DObj)
%       definirGDLID(biela2DObj)
%       agregarFuerzaResistenteAReacciones(biela2DObj)
%       guardarPropiedades(biela2DObj,archivoSalidaHandle)
%       guardarEsfuerzosInternos(biela2DObj,archivoSalidaHandle)
%       disp(biela2DObj)
%  Methods Suplerclass (ComponenteModelo):
%       etiqueta = obtenerEtiqueta(componenteModeloObj)

classdef Biela2D < Elemento
    
    properties(Access = private)
        nodosObj
        gdlID
        Eo
        Ao
        dx
        dy
        L
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
            
            biela2DObj.L = sqrt(biela2DObj.dx^2+biela2DObj.dy^2);
            
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
            
        end % obtenerNumeroGDL function
        
        function k_global = obtenerMatrizRigidezCoordGlobal(biela2DObj)
            
            % Obtiene la matriz de coordenadas locales
            k_local = biela2DObj.obtenerMatrizRigidezCoordLocal();
            
            % Calcula el ángulo
            theta = atan(biela2DObj.dy/biela2DObj.dx);
            
            % Se crea matriz de transformación
            t_theta = [cos(theta), sin(theta), 0, 0; ...
                -sin(theta), cos(theta), 0, 0; ...
                0, 0, cos(theta), sin(theta); ...
                0, 0, -sin(theta), cos(theta);];
            
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
            
            % Calcula matriz transformación
            theta = atan(biela2DObj.dy/biela2DObj.dx);
            t_theta = [cos(theta), sin(theta), 0, 0; ...
                -sin(theta), cos(theta), 0, 0; ...
                0, 0, cos(theta), sin(theta); ...
                0, 0, -sin(theta), cos(theta);];
            
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
            
            % Calcula matriz de transformación
            theta = atan(biela2DObj.dy/biela2DObj.dx);
            t_theta = [cos(theta), sin(theta), 0, 0; ...
                -sin(theta), cos(theta), 0, 0; ...
                0, 0, cos(theta), sin(theta); ...
                0, 0, -sin(theta), cos(theta);];
            
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
        
        function agregarFuerzaResistenteAReacciones(biela2DObj)
            
            % Se calcula la fuerza resistente
            fr_global = biela2DObj.obtenerFuerzaResistenteCoordGlobal();
            
            % Carga los nodos
            nodo1 = biela2DObj.nodosObj{1};
            nodo2 = biela2DObj.nodosObj{2};
            
            % Agrega fuerzas resistentes como cargas
            nodo1.agregarCarga([-fr_global(1); -fr_global(2)]);
            nodo2.agregarCarga([-fr_global(3); -fr_global(4)]);
            
        end % agregarFuerzaResistenteAReacciones function
        
        function guardarPropiedades(biela2DObj, archivoSalidaHandle)
            
            fprintf(archivoSalidaHandle, '\tBiela2D %s:\n\t\tLargo:\t%s\n\t\tArea:\t%s\n\t\tEo:\t\t%s\n', ...
                biela2DObj.obtenerEtiqueta(), num2str(biela2DObj.L), ...
                num2str(biela2DObj.Ao), num2str(biela2DObj.Eo));
            
        end % guardarPropiedades function
        
        function guardarEsfuerzosInternos(biela2DObj, archivoSalidaHandle)
            
            esf_int = biela2DObj.obtenerFuerzaResistenteCoordLocal();
            f = esf_int(1);
            
            % Determina si es tracción o compresión
            t = 'TRACCION';
            if f > 0
                t = 'COMPRESION';
            end
            
            fprintf(archivoSalidaHandle, '\n\tBiela 2D %s:\t%s%s', biela2DObj.obtenerEtiqueta(), ...
                pad(num2str(f), 15), t);
            
        end % guardarEsfuerzosInternos function
        
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