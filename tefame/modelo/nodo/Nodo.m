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
%| Clase Nodo                                                           |
%|                                                                      |
%| Este archivo contiene la definicion de la Clase Nodo                 |
%| Nodo es una subclase de la clase ComponenteModelo y corresponde a la |
%| representacion  abstracta  de los  nodos en  el metodo  de elementos |
%| finitos o analisis matricial de estructuras.                         |
%| La clase nodo  guarda la  informacion de  las coordenadas  del nodo, |
%| , los ID de grados de libertad y los resultados de desplazamiento.   |
%|                                                                      |
%| Programado: FR                                                       |
%| Fecha: 05/08/2015                                                    |
%|                                                                      |
%| Modificado por: FR - 24/10/2016                                      |
%|______________________________________________________________________|
%
%  Properties (Access=private):
%       nGDL
%       coords
%       gdlID
%       despl
%       cargas
%       reacciones
%
%  Methods:
%       nodoObj = Nodo(etiquetaNodo,nGDLNodo,coordenadasNodo)
%       nGDLNodo = obtenerNumeroGDL(nodoObj)
%       coordenadasNodo = obtenerCoordenadas(nodoObj)
%       gdlIDNodo = obtenerGDLID(nodoObj)
%       cargasResultantesNodo = obtenerCargasResultantes(nodoObj)
%       desplazmientosNodo = obtenerDesplazamientos(nodoObj)
%       reaccionesNodo = obtenerReacciones(nodoObj)
%       definirGDLID(nodoObj,gdlIDNodo)
%       definirDesplazamientos(nodoObj,desplazamientosNodo)
%       agregarCarga(nodoObj,cargaNodo)
%       agregarEsfuerzosElementoAReaccion(nodoObj,esfuerzosElemento)
%       inicializar(nodoObj)
%       guardarPropiedades(nodoObj,archivoSalidaHandle)
%       guardarDesplazamientos(nodoObj,archivoSalidaHandle)
%       guardarReacciones(nodoObj,archivoSalidaHandle)
%       Disp(nodoObj)
%       agregarElementos(nodoObj, elemObj)
%       obtenerElementos(nodoObj)
%       tipoApoyoRestringido(nodoObj)
%  Methods Suplerclass (ComponenteModelo):
%       etiqueta = obtenerEtiqueta(componenteModeloObj)

classdef Nodo < ComponenteModelo
    
    properties(Access = private)
        nGDL % Numbero de grados de libertad (GDL)
        coords % Coordenadas del nodo
        gdlID % Vector que guarda el ID de los grados de libertad
        despl % Vector que guarda los desplazamientos del nodo
        cargas % Vector que guarda las cargas aplicadas sobre el nodo
        reacciones % Vector que guarda las reacciones del nodo
        elementos % Cell que guarda los elementos que conectan el nodo
    end % properties Nodo
    
    methods
        
        function nodoObj = Nodo(etiquetaNodo, nGDLNodo, coordenadasNodo)
            % Nodo: es el constructor de la clase Nodo
            %
            % nodoObj = Nodo(etiquetaNodo,nGDLNodo,coordenadasNodo)
            % Crea un objeto de la clase Nodo, con un identificador unico (etiquetaNodo),
            % con el el numero de GDL (nGDLNodo) y un vector que contine las
            % coordenadas globales del nodo (coordenadasNodo)
            
            % Si no hay argumentos completa con ceros
            if nargin == 0
                etiquetaNodo = '';
                nGDLNodo = 0;
                coordenadasNodo = [];
            end % if
            
            %Llamamos al constructor de la SuperClass que es la clase ComponenteModelo
            nodoObj = nodoObj@ComponenteModelo(etiquetaNodo);
            
            % Guardamos el numero de grados de libertad (GDL) que tiene el nodo
            nodoObj.nGDL = nGDLNodo;
            
            % Revisamos la orientacion del vector de coordenadas, para dejarlo como columna
            if size(coordenadasNodo, 1) == 1
                nodoObj.coords = coordenadasNodo';
            else
                nodoObj.coords = coordenadasNodo;
            end % if
            
            % Creamos el vector que guardara los ID para los diferentes
            % GDL, que se usara en el analisis del modelo
            nodoObj.gdlID = -ones(nGDLNodo, 1);
            
            % Definimos en zero todos los componentes guardados en el Nodo
            nodoObj.despl = zeros(nodoObj.nGDL, 1);
            nodoObj.reacciones = zeros(nodoObj.nGDL, 1);
            nodoObj.cargas = zeros(nodoObj.nGDL, 1);
            
            % Crea el vector de eleentos
            nodoObj.elementos = {};
            
        end % Nodo constructor
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Metodos para obtener informacion del Nodo
        
        function nGDLNodo = obtenerNumeroGDL(nodoObj)
            % obtenerNumeroGDL: es un metodo de la clase Nodo que se usa para
            % obtener el numero de GDL que tiene el Nodo
            %
            % nGDLNodo = obtenerNumeroGDL(nodoObj)
            % Entrega el numero de grados de libertad (nGDLNodo) que tiene el
            % Nodo (nodoObj)
            
            nGDLNodo = nodoObj.nGDL;
            
        end % obtenerNumeroGDL function
        
        function coordenadasNodo = obtenerCoordenadas(nodoObj)
            % obtenerCoordenadas: es un metodo de la clase Nodo que se usa para
            % obtener las coordenadas que tiene el Nodo en esl sistema de
            % coordenadas global
            %
            % coordenadasNodo = obtenerCoordenadas(nodoObj)
            % Entrega el vector con las coordenadas (coordenadasNodo) que tiene
            % el Nodo (nodoObj) en el sistema de coordenadas global
            
            coordenadasNodo = nodoObj.coords;
            
        end % obtenerCoordenadas function
        
        function gdlIDNodo = obtenerGDLID(nodoObj)
            % obtenerGDLID: es un metodo de la clase Nodo que se usa para
            % obtener los ID de los GDL que tiene el Nodo
            %
            % gdlIDNodo = obtenerGDLID(nodoObj)
            % Entrega el vector con los ID de los GDL (gdlIDNodo) que tiene el
            % Nodo (nodoObj)
            
            gdlIDNodo = nodoObj.gdlID;
            
        end % obtenerGDLID function
        
        function cargasResultantesNodo = obtenerCargasResultantes(nodoObj)
            % obtenerCargasResultantes: es un metodo de la clase Nodo que se usa
            % para obtener las cargas resultantes que son aplicadas finalmente en
            % el Nodo despues de aplicar todos los patrones de carga.
            %
            % cargasResultantesNodo = obtenerCargasResultantes(nodoObj)
            % Entrega el vector con las cargas resultantes (cargasResultantesNodo)
            % que son finalmente aplicads sobre cada Nodo (nodoObj)
            
            cargasResultantesNodo = nodoObj.cargas;
            
        end % obtenerCargasResultantes function
        
        function desplazmientosNodo = obtenerDesplazamientos(nodoObj)
            % obtenerDesplazamientos: es un metodo de la clase Nodo que se usa para
            % obtener los desplazamientos que son obtenidos en el Nodo despues
            % de realizar el analisis
            %
            % desplazmientosNodo = obtenerDesplazamientos(nodoObj)
            % Entrega el vector con los desplazamientos o rotaciones (desplazmientosNodo)
            % que sufrio el Nodo (nodoObj) debido a la aplicacion de los patrones
            % de carga.
            
            desplazmientosNodo = nodoObj.despl;
            
        end % obtenerDesplazamientos function
        
        function reaccionesNodo = obtenerReacciones(nodoObj)
            % obtenerReacciones: es un metodo de la clase Nodo que se usa para
            % obtener las reacciones que son obtenidos en el Nodo despues de
            % realizar el analisis
            %
            % reaccionesNodo = obtenerReacciones(nodoObj)
            % Entrega el vector con las reacciones (reaccionesNodo), fuerzas o
            % momentos, que se obtinen el Nodo (nodoObj) debido a las
            % restricciones del Modelo
            
            reaccionesNodo = nodoObj.reacciones;
            
        end % obtenerReacciones function
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Metodos para definir la informacion del Nodo usada en el analisis
        
        function definirGDLID(nodoObj, gdlIDNodo)
            % definirGDLID: es un metodo de la clase Nodo que se usa para definir
            % los ID de los GDL que tiene el Nodo asignados durante el proceso
            % de enumeracion de estos
            %
            % definirGDLID(nodoObj,gdlIDNodo)
            % Guarda el ID que se fueron asignados a los grados de libertad (gdlIDNodo)
            % que tiene el Nodo (nodoObj)
            
            nodoObj.gdlID = gdlIDNodo;
            
        end % definirGDLID function
        
        function y = tipoApoyoRestringido(nodoObj)
            % tipoApoyoRestringido: el nodo esta completamente restringido
            % al movimiento
            
            y = isArrayEqual(nodoObj.gdlID, 0) || isArrayEqual(nodoObj.gdlID, -1);
            
        end % tipoApoyoRestringido function
        
        function definirDesplazamientos(nodoObj, desplazamientosNodo)
            % definirDesplazamientos: es un metodo de la clase Nodo que se usa
            % para informar sobre los desplazamientos que fueron obtenidos para
            % el Nodo durante el analisis de sistema
            %
            % definirDesplazamientos(nodoObj,desplazamientosNodo)
            % Guarda el vector con los desplazamientos (desplazamientosNodo) que
            % fueron obtenidos para el Nodo (nodoObj)
            
            nodoObj.despl = desplazamientosNodo;
            
        end % definirDesplazamiento function
        
        function agregarCarga(nodoObj, cargaNodo)
            % agregarCarga: es un metodo de la clase Nodo que se usa para agregar
            % un vector de fuerzas al nodo al aplicar el patron de cargas
            %
            % agregarCarga(nodoObj,cargaNodo)
            % Agrega al vector de fuerzas del Nodo (nodoObj), el vector de fuerzas
            % entregado (cargaNodo)
            
            % Se procede a sumar la carga entregada al vector de cargas del nodo
            %             nodoObj.cargas = nodoObj.cargas + cargaNodo;
            
            % Se resta la carga entregada al vector de reacciones para
            % obtener las reacciones posterior al analisis
            
            nodoObj.reacciones = nodoObj.reacciones - cargaNodo;
            
        end % agregarCarga function
        
        function agregarElementos(nodoObj, elemObj)
            
            n = length(nodoObj.elementos);
            nodoObj.elementos{n+1} = elemObj;
            
        end % agregarElementos function
        
        function elem_nodos = obtenerElementos(nodoObj)
            
            elem_nodos = nodoObj.elementos;
            
        end % obtenerElementos function
        
        function agregarEsfuerzosElementoAReaccion(nodoObj, esfuerzosElemento)
            % agregarEsfuerzosElementoAReaccion: es un metodo de la clase Nodo
            % que se usa para agregar el vector de fuerzas resistentes de un
            % elemento al nodo.
            %
            % agregarEsfuerzosElementoAReaccion(nodoObj,esfuerzosElemento)
            % Agrega al vector de reacciones del Nodo (nodoObj), el vector de
            % fuerzas resistente de un elemento entregados (cargaNodo)
            
            % Se procede a sumar el vector con las fuerzas resistente entregada
            % de un elemento al vector de reacciones del nodo
            nodoObj.reacciones = nodoObj.reacciones + esfuerzosElemento;
            
        end % agregarEsfuerzoAReaccion function
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Metodos para inicializar la informacion del Nodo usada en el analisis
        
        function inicializar(nodoObj)
            % inicializar: es un metodo de la clase Nodo que se usa para inicializar
            % las diferentes vectores que contienne los Desplazamientos, cargas
            % y reacciones en el Nodo
            %
            % inicializar(nodoObj)
            % Inicializa los diferentes vectores del Nodo que estan guardados en
            % este (nodoObj), para poder preparar estos para realizar el analisis
            
            % Se inicializan en zero los vectores del tamano de los numero de GDL
            nodoObj.despl = zeros(nodoObj.nGDL, 1);
            nodoObj.reacciones = zeros(nodoObj.nGDL, 1);
            nodoObj.cargas = zeros(nodoObj.nGDL, 1);
            
        end % reiniciar function
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Metodos para guardar la informacion del Nodo en un archivo de salida
        
        function guardarPropiedades(nodoObj, archivoSalidaHandle)
            % guardarPropiedades: es un metodo de la clase Nodo que se usa para
            % guardar en un archivo de salida las propiedades del Nodo
            % (Coordenadas)
            %
            % guardarPropiedades(nodoObj,archivoSalidaHandle)
            % Guarda las propiedades de los Nodos (nodoObj), en un archivo de
            % salida (archivoSalidaHandle)
            
            % Se procede a imprimir en el archivo
            fprintf(archivoSalidaHandle, ['\tNodo ', nodoObj.obtenerEtiqueta(), ': ']);
            Crds = arrayNum2str(nodoObj.coords, length(nodoObj.coords));
            fprintf(archivoSalidaHandle, '%s\n', [Crds{2:end-1}]);
            
        end % guardarPropiedades function
        
        function guardarDesplazamientos(nodoObj, archivoSalidaHandle)
            % guardarDesplazamientos: es un metodo de la clase Nodo que se usa
            % para guardar en un archivo de salida el vector de desplazamientos
            % del Nodo obtenido en el analisis
            %
            % guardarDesplazamientos(nodoObj,archivoSalidaHandle)
            % Guarda el vector de desplazamientos del Nodo (nodoObj), en un archivo
            % de salida (archivoSalidaHandle)
            
            % Se procede a imprimir en el archivo
            fprintf(archivoSalidaHandle, ['\tNodo ', nodoObj.obtenerEtiqueta(), ': ']);
            desplazamientos = arrayNum2str(round(nodoObj.despl, 5), length(nodoObj.despl));
            fprintf(archivoSalidaHandle, '%s\n', [desplazamientos{2:end-1}]);
            
        end % guardarDesplazamientos function
        
        function guardarReacciones(nodoObj, archivoSalidaHandle)
            % guardarReacciones: es un metodo de la clase Nodo que se usa para
            % guardar en un archivo de salida el vector de reacciones del Nodo
            % obtenido en el analisis
            %
            % guardarReacciones(nodoObj,archivoSalidaHandle)
            % Guarda el vector de reacciones del Nodo (nodoObj), en un archivo
            % de salida (archivoSalidaHandle)
            
            % Se procede a imprimir en el archivo
            fprintf(archivoSalidaHandle, ['\tNodo ', nodoObj.obtenerEtiqueta(), ': ']);
            reacc = arrayNum2str(nodoObj.reacciones, length(nodoObj.despl));
            fprintf(archivoSalidaHandle, '%s\n', [reacc{2:end-1}]);
            
        end % guardarReacciones function
        
        function plot(nodoObj, deformada, color, escala)
            %plot: Grafica el nodo
            %
            % plot(nodoObj,deformada,estilo)
            
            if ~exist('escala', 'var')
                escala = 20;
            end
            
            coord = nodoObj.obtenerCoordenadas();
            if ~length(deformada) == 0
                coord = coord + deformada;
            end
            
            % Determina el tipo de apoyo
            if nodoObj.tipoApoyoRestringido()
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
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Metodos para mostrar la informacion del Nodo en pantalla
        
        function disp(nodoObj)
            % disp: es un metodo de la clase Nodo que se usa para imprimir en
            % command Window la informacion del Nodo
            %
            % disp(nodoObj)
            % Imprime la informacion guardada en el Nodo (nodoObj) en pantalla
            
            fprintf('Propiedades Nodo :\n');
            
            disp@ComponenteModelo(nodoObj);
            
            numCrds = length(nodoObj.coords);
            Crds = arrayNum2str(nodoObj.coords, numCrds);
            fprintf('Coordenadas : %s\n', [Crds{:}]);
            
            nGDLNodo = nodoObj.nGDL;
            fprintf('Numero de grados de libertad : %s\n', num2str(nGDLNodo));
            
            GdlID = arrayNum2str(nodoObj.gdlID, nGDLNodo);
            fprintf('ID Global de los grados de libertad : %s\n', [GdlID{:}]);
            desplazamientoNodo = arrayNum2str(nodoObj.despl, nGDLNodo);
            fprintf('Desplazamientos : %s\n', [desplazamientoNodo{:}]);
            reaccionesNodo = arrayNum2str(nodoObj.reacciones, nGDLNodo);
            fprintf('Reacciones : %s\n', [reaccionesNodo{:}]);
            
        end % disp function
        
    end % methods Nodo
    
end % class Nodo