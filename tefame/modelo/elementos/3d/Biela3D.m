%|______________________________________________________________________|
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
%| Repositorio: https://github.com/ppizarror/TEFAME                     |
%|______________________________________________________________________|
%|                                                                      |
%| Clase Biela3D                                                        |
%|                                                                      |
%| Este archivo contiene la definicion de la Clase Biela3D              |
%| Biela3D  es una  subclase de la  clase Elemento y  corresponde a  la |
%| representacion del elemento  biela o  barra que solo tiene  esfuerzo |
%| Axiales en un sistema de tres coordenadas.                           |
%|______________________________________________________________________|
%|                                                                      |
%| MIT License                                                          |
%| Copyright (c) 2018-2020 Pablo Pizarro R @ppizarror.com.              |
%|                                                                      |
%| Permission is hereby granted, free of charge, to any person obtai-   |
%| ning a copy of this software and associated documentation files (the |
%| "Software"), to deal in the Software without restriction, including  |
%| without limitation the rights to use, copy, modify, merge, publish,  |
%| distribute, sublicense, and/or sell copies of the Software, and to   |
%| permit persons to whom the Software is furnished to do so, subject   |
%| to the following conditions:                                         |
%|                                                                      |
%| The above copyright notice and this permission notice shall be       |
%| included in all copies or substantial portions of the Software.      |
%|                                                                      |
%| THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,      |
%| EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF   |
%| MERCHANTABILITY,FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.|
%| IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY |
%| CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, |
%| TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE    |
%| SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.               |
%|______________________________________________________________________|
%
%  Methods(Access=public):
%       obj = Biela3D(etiquetaBiela,nodo1Obj,nodo2Obj,AreaSeccion,Ematerial,densidad)
%       ae = obtenerAE(obj)
%       fr_global = obtenerFuerzaResistenteCoordGlobal(obj)
%       fr_local = obtenerFuerzaResistenteCoordLocal(obj)
%       gdlIDBiela = obtenerGDLID(obj)
%       k_global = obtenerMatrizRigidezCoordGlobal(obj)
%       k_local = obtenerMatrizRigidezCoordLocal(obj)
%       l = obtenerLargo(obj)
%       nodosBiela = obtenerNodos(obj)
%       numeroGDL = obtenerNumeroGDL(obj)
%       numeroNodos = obtenerNumeroNodos(obj)
%       T = obtenerMatrizTransformacion(obj)
%       agregarFuerzaResistenteAReacciones(obj)
%       definirGDLID(obj)
%       disp(obj)
%       guardarEsfuerzosInternos(obj,archivoSalidaHandle)
%       guardarPropiedades(obj,archivoSalidaHandle)
%  Methods SuperClass (ComponenteModelo):
%       etiqueta = obtenerEtiqueta(obj)
%       e = equals(obj,obj)
%       objID = obtenerIDObjeto(obj)

classdef Biela3D < Elemento
    
    properties(Access = private)
        Ao % Area de la seccion transversal
        dx % Distancia en el eje x entre los nodos
        dy % Distancia en el eje y entre los nodos
        dz % Distancia en el eje z entre los nodos
        Eo % Modulo de elasticidad
        gdlID % Lista con los ID de los grados de libertad
        L % Largo del elemento
        nodosObj % Cell con los nodos
        rho % Densidad de la biela
        T % Matriz de transformacion
        TcargaReacc % Reaccion de la biela guardada como un vector
    end % private properties Biela3D
    
    methods(Access = public)
        
        function obj = Biela3D(etiquetaBiela, nodo1Obj, nodo2Obj, AreaSeccion, Ematerial, densidad)
            % Biela3D: Constructor de clase, genera una biela en tres dimensiones
            
            % Si no hay argumentos completa con ceros
            if nargin == 0
                etiquetaBiela = '';
            end
            if ~exist('densidad', 'var')
                densidad = 0;
            end
            
            % Llamamos al constructor de la SuperClass que es la clase Elemento
            obj = obj@Elemento(etiquetaBiela);
            
            obj.nodosObj = {nodo1Obj; nodo2Obj};
            obj.Eo = Ematerial;
            obj.Ao = AreaSeccion;
            obj.gdlID = [];
            
            coordNodo1 = nodo1Obj.obtenerCoordenadas();
            coordNodo2 = nodo2Obj.obtenerCoordenadas();
            
            % Calcula propiedades geometricas
            obj.dx = coordNodo2(1) - coordNodo1(1);
            obj.dy = coordNodo2(2) - coordNodo1(2);
            obj.dz = coordNodo2(3) - coordNodo1(3);
            obj.rho = densidad;
            
            % Largo de la biela
            obj.L = sqrt(obj.dx^2+obj.dy^2+obj.dz^2);
            
            % Calcula matriz de transformacion
            cosx = obj.dx / obj.L;
            cosy = obj.dy / obj.L;
            cosz = obj.dz / obj.L;
            obj.T = [cosx, cosy, cosz, 0, 0, 0; 0, 0, 0, cosx, cosy, cosz];
            
            obj.TcargaReacc = [0, 0, 0, 0, 0, 0]';
            
        end % Biela2D constructor
        
        function numeroNodos = obtenerNumeroNodos(obj) %#ok<MANU>
            % obtenerNumeroNodos: Retorna el numero de nodos de la biela
            
            numeroNodos = 2;
            
        end % obtenerNumeroNodos function
        
        function nodosBiela = obtenerNodos(obj)
            % obtenerNodos: Retorna el cell de nodos de la biela
            
            nodosBiela = obj.nodosObj;
            
        end % obtenerNodos function
        
        function numeroGDL = obtenerNumeroGDL(obj) %#ok<MANU>
            % obtenerNumeroGDL: Retorna el numero de grados de libertad de
            % la biela
            
            numeroGDL = 6;
            
        end % obtenerNumeroGDL function
        
        function gdlIDBiela = obtenerGDLID(obj)
            % obtenerGDLID: Retorna los ID de los grados de libertad de la
            % biela
            
            gdlIDBiela = obj.gdlID;
            
        end % gdlIDBiela function
        
        function ae = obtenerAE(obj)
            % obtenerAE: Retorna A*E de la biela
            
            ae = obj.Ao * obj.Eo;
            
        end % obtenerAE function
        
        function m = obtenerMasa(obj)
            % obtenerMasa: Retorna la masa total del elemento
            
            m = obj.rho * obj.L * obj.Ao;
            
        end % obtenerMasa function
        
        function m_masa = obtenerVectorMasa(obj)
            % obtenerVectorMasa: Obtiene el vector de masa del elemento
            
            m_masa = zeros(6, 1);
            m = obj.obtenerMasa();
            m_masa(1) = m * 0.5;
            m_masa(2) = m * 0.5;
            m_masa(3) = 1e-6;
            m_masa(4) = m * 0.5;
            m_masa(5) = m * 0.5;
            m_masa(6) = 1e-6;
            
        end % obtenerMatrizMasa function
        
        function k_global = obtenerMatrizRigidezCoordGlobal(obj)
            % obtenerMatrizRigidezCoordGlobal: Retorna la matriz de rigidez
            % en coordenadas globales
            
            % Obtiene la matriz de coordenadas locales
            k_local = obj.obtenerMatrizRigidezCoordLocal();
            
            % Premultiplica y multiplica por [T]
            k_global = obj.T' * k_local * obj.T;
            
        end % obtenerMatrizRigidezCoordGlobal function
        
        function k_local = obtenerMatrizRigidezCoordLocal(obj)
            % obtenerMatrizRigidezCoordLocal: Retorna la matriz de rigidez
            % en coordenadas locales
            
            % Genera matriz
            k_local = [1, -1; -1, 1];
            
            % Multiplica por AoEo/L
            k_local = k_local .* (obj.Eo * obj.Ao / obj.L);
            
        end % obtenerMatrizRigidezCoordLocal function
        
        function sumarCargaTemperaturaReaccion(obj, f)
            % sumarCargaTemperaturaReaccion: Suma temperatura a reacciones
            
            for i = 1:length(f)
                if (obj.gdlID(i) == 0)
                    obj.TcargaReacc(i) = obj.TcargaReacc(i) + f(i);
                end
            end % for i
            
        end % sumarCargaTemperaturaReaccion function
        
        function fr_global = obtenerFuerzaResistenteCoordGlobal(obj)
            % obtenerFuerzaResistenteCoordGlobal: Retorna la fuerza
            % resistente en coordenadas globales
            
            % Obtiene fr local
            fr_local = obj.obtenerFuerzaResistenteCoordLocal();
            
            % Calcula fuerza resistente global
            fr_global = obj.T' * fr_local;
            
        end % obtenerFuerzaResistenteCoordGlobal function
        
        function fr_local = obtenerFuerzaResistenteCoordLocal(obj)
            % obtenerFuerzaResistenteCoordLocal: Retorna la fuerza
            % resistente en coordenadas locales
            
            % Obtiene los nodos
            nodo1 = obj.nodosObj{1};
            nodo2 = obj.nodosObj{2};
            
            % Obtiene los desplazamientos
            u1 = nodo1.obtenerDesplazamientos();
            u2 = nodo2.obtenerDesplazamientos();
            
            % Vector desplazamientos u'
            u = [u1(1); u1(2); u1(3); u2(1); u2(2); u2(3)];
            
            % Calcula u''
            f = obj.T * u;
            
            % Obtiene K local
            k_local = obj.obtenerMatrizRigidezCoordLocal();
            
            % Calcula F
            fr_local = k_local * f;
            
        end % obtenerFuerzaResistenteCoordLocal function
        
        function definirGDLID(obj)
            % definirGDLID: Define los ID de los grados de libertad
            
            % Se obtienen los nodos extremos
            nodo1 = obj.nodosObj{1};
            nodo2 = obj.nodosObj{2};
            
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
            obj.gdlID = gdl;
            
        end % definirGDLID function
        
        function agregarFuerzaResistenteAReacciones(obj)
            % agregarFuerzaResistenteAReacciones: Agrega las fuerzas
            % resistentes de la biela a las reacciones de los nodos que
            % conecta
            
            % Se calcula la fuerza resistente
            fr_global = obj.obtenerFuerzaResistenteCoordGlobal();
            
            % Carga los nodos
            nodo1 = obj.nodosObj{1};
            nodo2 = obj.nodosObj{2};
            
            % Suma fuerza de temperatura en reacciones
            nodo1.agregarEsfuerzosElementoAReaccion(-[obj.TcargaReacc(1); obj.TcargaReacc(2); obj.TcargaReacc(3)]);
            nodo2.agregarEsfuerzosElementoAReaccion(-[obj.TcargaReacc(4); obj.TcargaReacc(5); obj.TcargaReacc(6)]);
            
            % Agrega fuerzas resistentes como cargas
            nodo1.agregarEsfuerzosElementoAReaccion([fr_global(1); fr_global(2); fr_global(3)]);
            nodo2.agregarEsfuerzosElementoAReaccion([fr_global(4); fr_global(5); fr_global(6)]);
            
        end % agregarFuerzaResistenteAReacciones function
        
        function guardarPropiedades(obj, archivoSalidaHandle)
            % guardarPropiedades: Guarda las propiedades de la biela en un
            % archivo
            
            fprintf(archivoSalidaHandle, '\tBiela3D %s:\n\t\tLargo:\t%s\n\t\tArea:\t%s\n\t\tEo:\t\t%s\n\t\tMasa:\t%s\n', ...
                obj.obtenerEtiqueta(), num2str(obj.L), ...
                num2str(obj.Ao), num2str(obj.Eo), ...
                num2str(obj.obtenerMasa()));
            
        end % guardarPropiedades function
        
        function T = obtenerMatrizTransformacion(obj)
            % obtenerMatrizTransformacion: Obtiene la matriz de
            % transformacion del elemento
            
            T = obj.T;
            
        end % obtenerMatrizTransformacion function
        
        function l = obtenerLargo(obj)
            % obtenerLargo: Retorna el largo del elemento
            
            l = obj.L;
            
        end % obtenerLargo function
        
        function guardarEsfuerzosInternos(obj, archivoSalidaHandle)
            % guardarEsfuerzosInternos: Guarda los esfuerzos internos de la
            % biela
            
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
            
            fprintf(archivoSalidaHandle, '\n\tBiela 3D %s:\t%s%s', obj.obtenerEtiqueta(), ...
                pad(num2str(f), 15), t);
            
        end % guardarEsfuerzosInternos function
        
        function plot(obj, deformadas, tipoLinea, grosorLinea, ~)
            % plot: Grafica un elemento
            
            % Obtiene las coordenadas de los objetos
            coord1 = obj.nodosObj{1}.obtenerCoordenadas();
            coord2 = obj.nodosObj{2}.obtenerCoordenadas();
            
            % Si hay deformadas
            if ~isempty(deformadas)
                for i = 1:length(coord1)
                    coord1(i) = coord1(i) + deformadas{1}(i);
                    coord2(i) = coord2(i) + deformadas{2}(i);
                end
            end
            
            % Grafica el elemento
            obj.graficarLinea(coord1, coord2, tipoLinea, grosorLinea);
            
        end % plot function
        
        function disp(obj)
            % disp: Imprime la informacion de la biela en consola
            
            % Imprime propiedades
            fprintf('Propiedades biela 3D:\n');
            disp@ComponenteModelo(obj);
            fprintf('\tLargo: %s\tArea: %s\tE: %s\n', pad(num2str(obj.L), 12), ...
                pad(num2str(obj.Ao), 10), pad(num2str(obj.Eo), 10));
            
            % Se imprime matriz de rigidez local
            fprintf('\tMatriz de rigidez coordenadas locales:\n');
            disp(obj.obtenerMatrizRigidezCoordLocal());
            
            % Se imprime matriz de rigidez global
            fprintf('\tMatriz de rigidez coordenadas globales:\n');
            disp(obj.obtenerMatrizRigidezCoordGlobal());
            
            % Imprime matriz de transformacion
            fprintf('\tMatriz de transformacion geometrica:\n');
            disp(obj.obtenerMatrizTransformacion());
            
            dispMetodoTEFAME();
            
        end % disp function
        
    end % public methods Biela3D
    
end % class Biela3D