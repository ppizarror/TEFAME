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
%| Clase Nodo                                                           |
%|                                                                      |
%| Este archivo contiene la definicion de la Clase Nodo                 |
%| Nodo es una subclase de la clase ComponenteModelo y corresponde a la |
%| representacion  abstracta  de los  nodos en  el metodo  de elementos |
%| finitos o analisis matricial de estructuras.                         |
%|                                                                      |
%| La clase nodo  guarda la  informacion de  las coordenadas  del nodo, |
%| los ID de grados de libertad y los resultados de desplazamiento.     |
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
%       obj = Nodo(etiquetaNodo,nGDLNodo,coordenadasNodo)
%       nGDLNodo = obtenerNumeroGDL(obj)
%       coordenadasNodo = obtenerCoordenadas(obj)
%       gdlIDNodo = obtenerGDLID(obj)
%       gdlIDNodoCondensado = obtenerGDLIDCondensado(obj)
%       cargasResultantesNodo = obtenerCargasResultantes(obj)
%       desplazamientosNodo = obtenerDesplazamientos(obj)
%       reaccionesNodo = obtenerReacciones(obj)
%       definirGDLID(obj,gdlIDNodo)
%       definirGDLIDCondensado(obj,gdlIDNodoCondensado)
%       definirDesplazamientos(obj,desplazamientosNodo)
%       agregarCarga(obj,cargaNodo)
%       agregarEsfuerzosElementoAReaccion(obj,esfuerzosElemento)
%       inicializar(obj)
%       guardarPropiedades(obj,archivoSalidaHandle)
%       guardarDesplazamientos(obj,archivoSalidaHandle)
%       guardarReacciones(obj,archivoSalidaHandle)
%       disp(obj)
%       agregarElementos(obj, elemObj)
%       obtenerElementos(obj)
%       tipoApoyoRestringido(obj)
%  Methods Suplerclass (ComponenteModelo):
%       etiqueta = obtenerEtiqueta(obj)
%       e = equals(obj,obj)
%       objID = obtenerIDObjeto(obj)

classdef Nodo < ComponenteModelo
    
    properties(Access = private)
        cargas % Vector que guarda las cargas aplicadas sobre el nodo
        coords % Coordenadas del nodo
        despl % Vector que guarda los desplazamientos del nodo
        elementos % Cell que guarda los elementos que conectan el nodo
        gdlID % Vector que guarda el ID de los grados de libertad
        gdlIDCondensado % Vector que guarda el ID de los grados de libertad despues de la condensacion
        nGDL % Numbero de grados de libertad (GDL)
        reacciones % Vector que guarda las reacciones del nodo
    end % private properties Nodo
    
    methods(Access = public)
        
        function obj = Nodo(etiquetaNodo, nGDLNodo, coordenadasNodo)
            % Nodo: es el constructor de la clase Nodo
            %
            % Crea un objeto de la clase Nodo, con un identificador unico (etiquetaNodo),
            % con el el numero de GDL (nGDLNodo) y un vector que contine las
            % coordenadas globales del nodo (coordenadasNodo)
            
            % Si no hay argumentos completa con ceros
            if nargin == 0
                etiquetaNodo = '';
                nGDLNodo = 0;
                coordenadasNodo = [];
            end
            
            % Llamamos al constructor de la SuperClass que es la clase ComponenteModelo
            obj = obj@ComponenteModelo(etiquetaNodo);
            
            % Guardamos el numero de grados de libertad (GDL) que tiene el nodo
            obj.nGDL = nGDLNodo;
            
            % Revisamos la orientacion del vector de coordenadas, para dejarlo como columna
            if size(coordenadasNodo, 1) == 1
                obj.coords = coordenadasNodo';
            else
                obj.coords = coordenadasNodo;
            end
            
            % Creamos el vector que guardara los ID para los diferentes
            % GDL, que se usara en el analisis del modelo
            obj.gdlID = -ones(nGDLNodo, 1);
            obj.gdlIDCondensado = -ones(nGDLNodo, 1);
            
            % Definimos en zero todos los componentes guardados en el Nodo
            obj.despl = zeros(obj.nGDL, 1);
            obj.reacciones = zeros(obj.nGDL, 1);
            obj.cargas = zeros(obj.nGDL, 1);
            
            % Crea el vector de eleentos
            obj.elementos = {};
            
        end % Nodo constructor
        
        function nGDLNodo = obtenerNumeroGDL(obj)
            % obtenerNumeroGDL: es un metodo de la clase Nodo que se usa para
            % obtener el numero de GDL que tiene el nodo
            %
            % Entrega el numero de grados de libertad (nGDLNodo) que tiene el
            % nodo (obj)
            
            nGDLNodo = obj.nGDL;
            
        end % obtenerNumeroGDL function
        
        function coordenadasNodo = obtenerCoordenadas(obj)
            % obtenerCoordenadas: es un metodo de la clase Nodo que se usa para
            % obtener las coordenadas que tiene el Nodo en esl sistema de
            % coordenadas global
            %
            % Entrega el vector con las coordenadas (coordenadasNodo) que tiene
            % el Nodo (obj) en el sistema de coordenadas global
            
            coordenadasNodo = obj.coords;
            
        end % obtenerCoordenadas function
        
        function gdlIDNodo = obtenerGDLID(obj)
            % obtenerGDLID: es un metodo de la clase Nodo que se usa para
            % obtener los ID de los GDL que tiene el Nodo
            %
            % Entrega el vector con los ID de los GDL (gdlIDNodo) que tiene el
            % Nodo (obj)
            
            gdlIDNodo = obj.gdlID;
            
        end % obtenerGDLID function
        
        function gdlIDNodoCondensado = obtenerGDLIDCondensado(obj)
            % obtenerGDLIDCondensado: es un metodo de la clase Nodo que se usa para
            % obtener los ID de los GDL que tiene el Nodo, una vez se
            % llevo a cabo el proceso de condensacion
            %
            % Entrega el vector con los ID de los GDL (gdlIDNodo) que tiene el
            % Nodo (obj)
            
            gdlIDNodoCondensado = obj.gdlIDCondensado;
            
        end % obtenerGDLID function
        
        function cargasResultantesNodo = obtenerCargasResultantes(obj)
            % obtenerCargasResultantes: es un metodo de la clase Nodo que se usa
            % para obtener las cargas resultantes que son aplicadas finalmente en
            % el Nodo despues de aplicar todos los patrones de carga
            %
            % Entrega el vector con las cargas resultantes (cargasResultantesNodo)
            % que son finalmente aplicads sobre cada Nodo (obj)
            
            cargasResultantesNodo = obj.cargas;
            
        end % obtenerCargasResultantes function
        
        function desplazamientosNodo = obtenerDesplazamientos(obj)
            % obtenerDesplazamientos: es un metodo de la clase Nodo que se usa para
            % obtener los desplazamientos que son obtenidos en el Nodo despues
            % de realizar el analisis
            %
            % Entrega el vector con los desplazamientos o rotaciones (desplazmientosNodo)
            % que sufrio el Nodo (obj) debido a la aplicacion de los patrones
            % de carga
            
            desplazamientosNodo = obj.despl;
            
        end % obtenerDesplazamientos function
        
        function reaccionesNodo = obtenerReacciones(obj)
            % obtenerReacciones: es un metodo de la clase Nodo que se usa para
            % obtener las reacciones que son obtenidos en el Nodo despues de
            % realizar el analisis
            %
            % Entrega el vector con las reacciones (reaccionesNodo), fuerzas o
            % momentos, que se obtinen el Nodo (obj) debido a las
            % restricciones del Modelo
            
            reaccionesNodo = obj.reacciones;
            
        end % obtenerReacciones function
        
        function definirGDLID(obj, gdlIDNodo)
            % definirGDLID: es un metodo de la clase Nodo que se usa para definir
            % los ID de los GDL que tiene el Nodo asignados durante el proceso
            % de enumeracion de estos, por defecto los ID condensados
            % corresponden a los mismos que se enumeraron en un principio
            %
            % Guarda el ID que se fueron asignados a los grados de libertad (gdlIDNodo)
            % que tiene el Nodo (obj)
            
            obj.gdlID = gdlIDNodo;
            obj.gdlIDCondensado = gdlIDNodo;
            
        end % definirGDLID function
        
        function definirGDLIDCondensado(obj, gdlIDNodoCondensado)
            % definirGDLIDCondensado: es un metodo de la clase Nodo que se usa para definir
            % los ID de los GDL que tiene el Nodo asignados una vez se
            % condensa el modelo
            %
            % Guarda el ID que se fueron asignados a los grados de libertad (gdlIDNodo)
            % que tiene el Nodo (obj) una vez se aplica la condensacion
            
            obj.gdlIDCondensado = gdlIDNodoCondensado;
            
        end % definirGDLID function
        
        function y = tipoApoyoRestringido(obj)
            % tipoApoyoRestringido: el nodo esta completamente restringido
            % al movimiento
            
            y = isArrayEqual(obj.gdlID, 0) || isArrayEqual(obj.gdlID, -1);
            
        end % tipoApoyoRestringido function
        
        function definirDesplazamientos(obj, desplazamientosNodo)
            % definirDesplazamientos: es un metodo de la clase Nodo que se usa
            % para informar sobre los desplazamientos que fueron obtenidos para
            % el Nodo durante el analisis de sistema
            %
            % Guarda el vector con los desplazamientos (desplazamientosNodo) que
            % fueron obtenidos para el Nodo (obj)
            
            obj.despl = desplazamientosNodo;
            
        end % definirDesplazamiento function
        
        function agregarCarga(obj, cargaNodo)
            % agregarCarga: es un metodo de la clase Nodo que se usa para agregar
            % un vector de fuerzas al nodo al aplicar el patron de cargas
            % Agrega al vector de fuerzas del Nodo (obj), el vector de fuerzas
            % entregado (cargaNodo)
            % Se procede a sumar la carga entregada al vector de cargas del nodo
            %             obj.cargas = obj.cargas + cargaNodo;
            % Se resta la carga entregada al vector de reacciones para
            % obtener las reacciones posterior al analisis
            
            obj.reacciones = obj.reacciones - cargaNodo;
            
        end % agregarCarga function
        
        function agregarElementos(obj, elemObj)
            % agregarElementos: Agrega elementos al nodo
            
            n = length(obj.elementos);
            obj.elementos{n+1} = elemObj;
            
        end % agregarElementos function
        
        function elem_nodos = obtenerElementos(obj)
            % obtenerElementos: Obtiene los elementos que convergen en el nodo
            
            elem_nodos = obj.elementos;
            
        end % obtenerElementos function
        
        function agregarEsfuerzosElementoAReaccion(obj, esfuerzosElemento)
            % agregarEsfuerzosElementoAReaccion: es un metodo de la clase Nodo
            % que se usa para agregar el vector de fuerzas resistentes de un
            % elemento al nodo
            %
            % Agrega al vector de reacciones del Nodo (obj), el vector de
            % fuerzas resistente de un elemento entregados (cargaNodo)
            % Se procede a sumar el vector con las fuerzas resistente entregada
            % de un elemento al vector de reacciones del nodo
            
            obj.reacciones = obj.reacciones + esfuerzosElemento;
            
        end % agregarEsfuerzoAReaccion function
        
        function inicializar(obj)
            % inicializar: es un metodo de la clase Nodo que se usa para inicializar
            % las diferentes vectores que contienne los desplazamientos, cargas
            % y reacciones en el nodo
            %
            % Inicializa los diferentes vectores del Nodo que estan guardados en
            % este (obj), para poder preparar estos para realizar el analisis
            
            % Se inicializan en zero los vectores del tamano de los numero de GDL
            obj.despl = zeros(obj.nGDL, 1);
            obj.reacciones = zeros(obj.nGDL, 1);
            obj.cargas = zeros(obj.nGDL, 1);
            
        end % reiniciar function
        
        function guardarPropiedades(obj, archivoSalidaHandle)
            % guardarPropiedades: es un metodo de la clase Nodo que se usa para
            % guardar en un archivo de salida las propiedades del Nodo
            % (Coordenadas)
            %
            % Guarda las propiedades de los Nodos (obj), en un archivo de
            % salida (archivoSalidaHandle)
            
            % Se procede a imprimir en el archivo
            fprintf(archivoSalidaHandle, ['\tNodo ', obj.obtenerEtiqueta(), ': ']);
            Crds = arrayNum2str(obj.coords, length(obj.coords));
            fprintf(archivoSalidaHandle, '%s\n', [Crds{2:end-1}]);
            
        end % guardarPropiedades function
        
        function guardarDesplazamientos(obj, archivoSalidaHandle)
            % guardarDesplazamientos: es un metodo de la clase Nodo que se usa
            % para guardar en un archivo de salida el vector de desplazamientos
            % del Nodo obtenido en el analisis
            %
            % Guarda el vector de desplazamientos del Nodo (obj), en un archivo
            % de salida (archivoSalidaHandle)
            
            % Se procede a imprimir en el archivo
            fprintf(archivoSalidaHandle, ['\tNodo ', obj.obtenerEtiqueta(), ': ']);
            desplazamientos = arrayNum2str(round(obj.despl, 5), length(obj.despl));
            fprintf(archivoSalidaHandle, '%s\n', [desplazamientos{2:end-1}]);
            
        end % guardarDesplazamientos function
        
        function guardarReacciones(obj, archivoSalidaHandle)
            % guardarReacciones: es un metodo de la clase Nodo que se usa para
            % guardar en un archivo de salida el vector de reacciones del Nodo
            % obtenido en el analisis
            %
            % Guarda el vector de reacciones del Nodo (obj), en un archivo
            % de salida (archivoSalidaHandle)
            
            % Se procede a imprimir en el archivo
            fprintf(archivoSalidaHandle, ['\tNodo ', obj.obtenerEtiqueta(), ': ']);
            reacc = arrayNum2str(obj.reacciones, length(obj.despl));
            fprintf(archivoSalidaHandle, '%s\n', [reacc{2:end-1}]);
            
        end % guardarReacciones function
        
        function plot(obj, deformada, color, escala)
            % plot: Grafica el nodo
            
            if ~exist('escala', 'var')
                escala = 20;
            end
            
            coord = obj.obtenerCoordenadas();
            if ~length(deformada) == 0
                for i=1:length(coord)
                    coord(i) = coord(i) + deformada(i);
                end
            end
            
            % Determina el tipo de apoyo
            if obj.tipoApoyoRestringido()
                return
            else
                color = strcat(color, '.');
            end
            
            % Grafica el nodo
            ngdlid = length(coord);
            if ngdlid == 2
                plot(coord(1), coord(2), color, 'MarkerSize', escala);
            else
                plot3(coord(1), coord(2), coord(3), color, 'MarkerSize', escala);
            end
            
        end % plot function
        
        function disp(obj)
            % disp: es un metodo de la clase Nodo que se usa para imprimir en
            % command Window la informacion del Nodo
            %
            % Imprime la informacion guardada en el Nodo (obj) en pantalla
            
            fprintf('Propiedades nodo:\n');
            disp@ComponenteModelo(obj);
            
            numCrds = length(obj.coords);
            Crds = arrayNum2str(obj.coords, numCrds);
            fprintf('\tCoordenadas: %s\n', [Crds{:}]);
            
            nGDLNodo = obj.nGDL;
            fprintf('\tNumero de grados de libertad: %s\n', num2str(nGDLNodo));
            
            GdlID = arrayIntNum2str(obj.gdlID, nGDLNodo);
            fprintf('\tID global de los grados de libertad: %s\n', [GdlID{:}]);
            GdlID = arrayIntNum2str(obj.gdlIDCondensado, nGDLNodo);
            fprintf('\tID condensados de los grados de libertad: %s\n', [GdlID{:}]);
            desplazamientoNodo = arrayNum2str(obj.despl, nGDLNodo);
            fprintf('\tDesplazamientos: %s\n', [desplazamientoNodo{:}]);
            reaccionesNodo = arrayNum2str(obj.reacciones, nGDLNodo);
            fprintf('\tReacciones: %s\n', [reaccionesNodo{:}]);
            
            dispMetodoTEFAME();
            
        end % disp function
        
    end % public methods Nodo
    
end % class Nodo