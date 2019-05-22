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
%| Clase Modelo                                                         |
%|                                                                      |
%| Este archivo contiene la definicion de la Clase Modelo               |
%| Modelo es  una clase  contenedor  que se usa  para guardar y proveer |
%| acceso a los diferentes componentes (Nodos, Elementos, Restricciones |
%| y Patrones de Carga) en el modelo.                                   |
%|                                                                      |
%| Programado: FR                                                       |
%| Fecha: 05/08/2015                                                    |
%|                                                                      |
%| Modificado por: FR - 24/10/2016                                      |
%|                 Pablo Pizarro @ppizarror - 10/04/2019                |
%|______________________________________________________________________|
%
%  Properties (Access=private):
%       elementos
%       nDimensiones
%       nGDL
%       nodos
%       patronesDeCargas
%       restricciones
%  Methods:
%       actualizar(obj,u)
%       agregarDisipadores(obj,arregloDisipadores)
%       agregarElementos(obj,arregloElementos)
%       agregarNodos(obj,arregloNodos)
%       agregarRestricciones(obj,arregloRestricciones)
%       aplicarPatronesDeCargasDinamico(obj,cpenzien,cargaDisipador,betaDisipador,arregloDisipadores)
%       aplicarPatronesDeCargasEstatico(obj)
%       aplicarRestricciones(obj)
%       definirNombre(obj,nombre)
%       disp(obj)
%       elementosModelo = obtenerElementos(obj)
%       guardarResultados(obj,nombreArchivo)
%       inicializar(obj)
%       obj = Modelo(numeroDimensiones,numerosGDL)
%       nodosModelo = obtenerNodos(obj)
%       nombre = obtenerNombre(obj)
%       numDimensiones = obtenerNumeroDimensiones(obj)
%       numGDL = obtenerNumerosGDL(obj)
%       patronesDeCargasModelo = obtenerPatronesDeCargas(obj)
%       restriccionesModelo = obtenerRestricciones(obj)

classdef Modelo < handle
    
    properties(Access = private)
        disipadores % Variable que guarda en un arreglo de celdas todos los disipadores del modelo
        elementos % Variable que guarda en un arreglo de celdas todos los elementos del modelo
        nDimensiones % Variable que guarda las dimensiones del sistema de coordenadas del modelo
        nGDL % Variable que guarda el numero de grados de libertad de cada nodo (GDL)
        nodos % Variable que guarda en un arreglo de celdas todos los nodos del modelo
        nombreModelo % Nombre del modelo
        patronesDeCargas % Variable que guarda en un arreglo de celdas todos los patrones de cargas aplicadas sobre el modelo
        restricciones % Variable que guarda en un arreglo de celdas todos las restricciones del modelo
    end % properties Modelo
    
    methods
        
        function obj = Modelo(numeroDimensiones, numerosGDL)
            % Modelo: es el constructor de la clase Modelo
            %
            % Crea un objeto de la clase Modelo, con el numero de dimensiones
            % que tiene el sistema de coordenadas del modelo (nDimensiones) y
            % el numero de grados de libertad por nodo
            
            % Definimos las propiedades de entrada si, no se ingresa ningun valor
            if nargin == 0
                numeroDimensiones = 0;
                numerosGDL = 0;
            end % if
            
            % Definimos las propiedades en el modelo
            obj.nDimensiones = numeroDimensiones;
            obj.nGDL = numerosGDL;
            
            % Generamos el modelo con todos las variables que guardan las
            % componentes del modelo vacio
            obj.nodos = [];
            obj.elementos = [];
            obj.disipadores = [];
            obj.restricciones = [];
            obj.patronesDeCargas = [];
            
            % Nombre del modelo
            obj.nombreModelo = 'Sin nombre';
            
        end % Modelo constructor
        
        function definirNombre(obj, nombre)
            % definirNombre: Define el nombre del modelo
            
            obj.nombreModelo = nombre;
            
        end % definirNombre function
        
        function nombre = obtenerNombre(obj)
            % obtenerNombre: Obtiene el nombre del modelo
            
            nombre = obj.nombreModelo;
            
        end % obtenerNombre function
        
        function agregarNodos(obj, arregloNodos)
            % agregarNodos: es un metodo de la clase Modelo que se usa para
            % entregarle el arreglo con los nodos al Modelo
            %
            % Agrega el arreglo con los nodos (arregloNodos) al Modelo (obj)
            % para que esto lo guarde y tenga acceso a los nodos
            
            for i = 1:length(arregloNodos)
                if ~isa(arregloNodos{i}, 'Nodo')
                    error('Elemento %d del arreglo de nodos no es un nodo', i);
                end
            end % for i
            obj.nodos = arregloNodos;
            
        end % agregarNodos function
        
        function agregarElementos(obj, arregloElementos)
            % agregarElementos: es un metodo de la clase Modelo que se usa para
            % entregarle el arreglo con los elementos al Modelo
            %
            % Agrega el arreglo con los elementos (arregloElementos) al Modelo
            % (obj) para que esto lo guarde y tenga acceso a los elementos
            
            for i = 1:length(arregloElementos)
                if ~isa(arregloElementos{i}, 'Elemento')
                    error('Elemento %d del arreglo de elementos no es un elemento', i);
                end
            end % for i
            obj.elementos = arregloElementos;
            
        end % agregarElementos function
        
        function agregarDisipadores(obj, arregloDisipadores)
            % agregarDisipadores: es un metodo de la clase Modelo que se usa
            % para entregarle el arreglo con los disipadores al modelo
            %
            % Agrega el arreglo con los elementos (arregloDisipadores) al modelo
            % (obj) para que esto lo guarde y tenga acceso a los
            % disipadores
            
            for i = 1:length(arregloDisipadores)
                if ~isa(arregloDisipadores{i}, 'Disipador')
                    error('Elemento %d del arreglo de disipadores no es un disipador', i);
                end
            end % for i
            obj.disipadores = arregloDisipadores;
            
        end % agregarDisipadores function
        
        function agregarRestricciones(obj, arregloRestricciones)
            % agregarRestricciones: es un metodo de la clase Modelo que se usa
            % para entregarle el arreglo con los restricciones al Modelo
            %
            % Agrega el arreglo con los restricciones (arregloRestricciones)
            % al Modelo (obj) para que esto lo guarde y tenga acceso a
            % los restricciones
            
            for i = 1:length(arregloRestricciones)
                if ~isa(arregloRestricciones{i}, 'RestriccionNodo')
                    error('Elemento %d del arreglo de restricciones no es una restriccion', i);
                end
            end % for i
            obj.restricciones = arregloRestricciones;
            
        end % agregarRestricciones function
        
        function agregarPatronesDeCargas(obj, arregloPatronDeCargas)
            % agregarPatronesDeCargas: es un metodo de la clase Modelo que se usa
            % para entregarle el arreglo con los patrones de carga al Modelo
            %
            % Agrega el arreglo con los patrones de carga (arregloPatronDeCargas)
            % al Modelo (obj) para que esto lo guarde y tenga acceso a los
            % patrones de carga
            % Los patrones de cargas contienen las cargas que se aplican en los
            % nodos y elementos
            
            for i = 1:length(arregloPatronDeCargas)
                if ~isa(arregloPatronDeCargas{i}, 'PatronDeCargas')
                    error('Elemento %d del arreglo de patrones de cargas no es un patron de carga', i);
                end
            end % for i
            obj.patronesDeCargas = arregloPatronDeCargas;
            
        end % agregarPatronesDeCargas function
        
        function nodosModelo = obtenerNodos(obj)
            % obtenerNodos: es un metodo de la clase Modelo que se usa para
            % obtener el arreglo con los nodos guardados en el Modelo
            %
            % Obtiene el arreglo con los nodos (nodosModelo) que esta guardado
            % en el Modelo (obj)
            
            nodosModelo = obj.nodos;
            
        end % obtenerNodos function
        
        function elementosModelo = obtenerElementos(obj)
            % obtenerElementos: es un metodo de la clase Modelo que se usa para
            % obtener el arreglo con los elementos guardados en el Modelo
            %
            % Obtiene el arreglo con los elementos (elementosModelo) que esta
            % guardado en el Modelo (obj)
            
            elementosModelo = obj.elementos;
            
        end % obtenerElementos function
        
        function disipadoresModelo = obtenerDisipadores(obj)
            % obtenerDisipadores: es un metodo de la clase Modelo que se usa para
            % obtener el arreglo con los disipadores guardados del modelo
            %
            % Obtiene el arreglo con los disipadores (DisipadoresModelo) que esta
            % guardado en el Modelo (obj)
            
            disipadoresModelo = obj.disipadores;
            
        end % obtenerDisipadores function
        
        function restriccionesModelo = obtenerRestricciones(obj)
            % obtenerPatronDeCargas: es un metodo de la clase Modelo que se usa para
            % obtener el arreglo con los patrones de carga guardados en el Modelo
            %
            % Obtiene el arreglo con los patrones de carga (patronDeCargasModelo)
            % que esta guardado en el Modelo (obj)
            
            restriccionesModelo = obj.restricciones;
            
        end % obtenerRestricciones function
        
        function patronesDeCargasModelo = obtenerPatronesDeCargas(obj)
            % obtenerPatronesDeCargas: es un metodo de la clase Modelo que se usa para
            % obtener el arreglo con los patrones de carga guardados en el Modelo
            %
            % Obtiene el arreglo con los patrones de carga (patronesDeCargasModelo)
            % que esta guardado en el Modelo (obj)
            
            patronesDeCargasModelo = obj.patronesDeCargas;
            
        end % obtenerPatronesDeCargas function
        
        function numDimensiones = obtenerNumeroDimensiones(obj)
            % obtenerNumeroDimensiones: es un metodo de la clase Modelo que
            % se usa para obtener el numero de dimensiones del modelo
            
            numDimensiones = obj.nDimensiones;
            
        end % obtenerNumeroDimensiones function
        
        function numGDL = obtenerNumerosGDL(obj)
            % obtenerNumerosGDL: es un metodo de la clase Modelo que
            % se usa para obtener el numero de grados de libertad por nodo
            % del modelo
            
            numGDL = obj.nGDL;
            
        end % obtenerNumerosGDL function
        
        function inicializar(obj)
            % inicializar: es un metodo de la clase Modelo que se usa para
            % inicializar las diferentes componentes en el Modelo
            %
            % Inicializa los diferentes componentes del modelo que estan guardados
            % en el Modelo (obj), para poder preparar estos para realizar
            % el analisis
            
            for i = 1:length(obj.nodos)
                obj.nodos{i}.inicializar()
            end % for i
            
            for i = 1:length(obj.elementos)
                obj.elementos{i}.inicializar()
            end % for i
            
            for i = 1:length(obj.disipadores)
                obj.disipadores{i}.inicializar()
            end % for i
            
        end % inicializar function
        
        function aplicarRestricciones(obj)
            % aplicarRestricciones: es un metodo de la clase Modelo que se usa para
            % aplicar las restricciones en el Modelo
            %
            % Aplica las restricciones que estan guardadas en el Modelo (obj)
            
            for i = 1:length(obj.restricciones)
                obj.restricciones{i}.aplicarRestriccion()
            end % for i
            
        end % aplicarRestricciones function
        
        function aplicarPatronesDeCargasEstatico(obj, factor)
            % aplicarPatronesDeCargas: es un metodo de la clase Modelo que se usa
            % para aplicar las patrones de cargas en el Modelo
            %
            % Aplica los patrones de cargas que estan guardados en el Modelo
            % (obj), es decir, aplica las cargas sobre los nodos y
            % elementos
            
            fprintf('\tAplica patron de cargas estatico:\n');
            fprintf('\t\tFactor: %f\n', factor);
            for i = 1:length(obj.patronesDeCargas)
                if ~obj.patronesDeCargas{i}.patronDinamico()
                    obj.patronesDeCargas{i}.aplicarCargas(factor);
                end
            end % for i
            
        end % aplicarPatronesDeCargasEstatico function
        
        function aplicarPatronesDeCargasDinamico(obj, cpenzien, disipadores, cargaDisipador, ...
                betaObjetivo, arregloDisipadores, iterDisipador, tolIterDisipador, ...
                betaGrafico, factor)
            % aplicarPatronesDeCargasDinamico: es un metodo de la clase Modelo que se usa
            % para aplicar las patrones de cargas en el Modelo
            %
            % Aplica los patrones de cargas que estan guardados en el Modelo
            % (obj), es decir, aplica las cargas sobre los nodos y
            % elementos. Requiere ademas si se usa la matriz de
            % amortiguamiento de penzien, por defecto es falso, o sea usa
            % Rayleigh y si se usan disipadores o no en el calculo
            
            fprintf('\tAplica patron de cargas dinamico:\n');
            fprintf('\t\tFactor: %f\n', factor);
            for i = 1:length(obj.patronesDeCargas)
                if obj.patronesDeCargas{i}.patronDinamico()
                    obj.patronesDeCargas{i}.aplicarCargas(cpenzien, ...
                        disipadores, cargaDisipador, betaObjetivo, ...
                        arregloDisipadores, iterDisipador, tolIterDisipador, ...
                        betaGrafico, factor);
                end
            end % for i
            
        end % aplicarPatronesDeCargasDinamico function
        
        function actualizar(obj, u)
            % actualizar: es un metodo de la clase Modelo que se usa para actualizar
            % las componentes en el Modelo
            %
            % Actualiza o informa de los desplazamientos (u), entregados por el
            % analisis al resolver el sistema de ecuaciones, a las componentes
            % guardadas en el Modelo (obj)
            
            % Se definen e informan los desplazmientos a cada nodo
            numeroNodos = length(obj.nodos);
            for i = 1:numeroNodos
                
                % Nodo
                nodo = obj.nodos{i};
                gdlnodo = nodo.obtenerGDLID();
                
                % Se buscan desplazamientos en el vector u
                ngrados = nodo.obtenerNumeroGDL();
                d = zeros(ngrados, 1);
                for j = 1:ngrados
                    if (gdlnodo(j) ~= 0)
                        d(j) = u(gdlnodo(j));
                    end
                end % for j
                
                % Guarda los desplazamientos
                obj.nodos{i}.definirDesplazamientos(d');
                
            end % for i
            
            % Agregamos las fuerzas resistentes a las reacciones
            numeroElementos = length(obj.elementos);
            for i = 1:numeroElementos
                obj.elementos{i}.agregarFuerzaResistenteAReacciones();
            end % for i
            
        end % actualizar function
        
        function guardarResultados(obj, nombreArchivo)
            % guardarResultados: es un metodo de la clase Modelo que se usa para
            % guardar o imprimir en un archivo las propiedades de las componentes
            % del Modelo y los resultados del analisis
            %
            % Guarda las propiedades de las componentes del Modelo (obj) y
            % los resultados del analisis que tienen guardados los diferentes
            % componentes en un archivo (nombreArchivo)
            
            % Abre el archivo donde se guardara la informacion
            try
                archivoSalida = fopen(nombreArchivo, 'w');
                fprintf(archivoSalida, 'TEFAME - Toolbox para Elementos Finitos y Analisis\n');
            catch %#ok<CTCH>
                error('No se puede abrir el archivo %s', nombreArchivo);
            end
            fprintf(archivoSalida, '         Matricial de Estructuras en MATLAB\n');
            fprintf(archivoSalida, '\n');
            fprintf(archivoSalida, '-------------------------------------------------------------------------------\n');
            fprintf(archivoSalida, 'Propiedades de entrada modelo\n');
            fprintf(archivoSalida, '-------------------------------------------------------------------------------\n');
            fprintf(archivoSalida, '\n');
            
            % Se procede a guardar las propiedades de los nodos
            fprintf(archivoSalida, 'Nombre modelo: %s\n', obj.nombreModelo);
            fprintf(archivoSalida, 'Nodos:\n');
            nNodos = length(obj.nodos);
            fprintf(archivoSalida, '\tNumero de nodos: %d\n', nNodos);
            for iNodo = 1:nNodos
                obj.nodos{iNodo}.guardarPropiedades(archivoSalida);
            end % for i
            fprintf(archivoSalida, '\n');
            
            % Se procede a guardar las propiedades de los elementos
            fprintf(archivoSalida, 'Elementos:\n');
            nElementos = length(obj.elementos);
            fprintf(archivoSalida, '\tNumero de elementos: %d\n', nElementos);
            for iElem = 1:nElementos
                obj.elementos{iElem}.guardarPropiedades(archivoSalida);
            end % for iElem
            
            fprintf(archivoSalida, '\n');
            fprintf(archivoSalida, '-------------------------------------------------------------------------------\n');
            fprintf(archivoSalida, 'Resultados del analisis estatico\n');
            fprintf(archivoSalida, '-------------------------------------------------------------------------------\n');
            fprintf(archivoSalida, '\n');
            
            % Se procede a guardar los desplazamientos en cada nodo
            fprintf(archivoSalida, 'Desplazamientos nodos:\n');
            for iNodo = 1:nNodos
                obj.nodos{iNodo}.guardarDesplazamientos(archivoSalida);
            end % for iNodo
            fprintf(archivoSalida, '\n');
            
            % Se procede a guardar las reacciones
            fprintf(archivoSalida, 'Reacciones:\n');
            for iNodo = 1:nNodos
                obj.nodos{iNodo}.guardarReacciones(archivoSalida);
            end % for iNodo
            fprintf(archivoSalida, '\n');
            
            % Se procede a guardar los esfuerzos en los elementos
            fprintf(archivoSalida, 'Esfuerzos Elementos:');
            for i = 1:length(obj.elementos)
                obj.elementos{i}.guardarEsfuerzosInternos(archivoSalida);
            end % for i
            fprintf(archivoSalida, '\n');
            
            % Cierra el archivo
            fclose(archivoSalida);
            
        end % guardarResultados function
        
        function disp(obj)
            % disp: es un metodo de la clase Modelo que se usa para imprimir en
            % command Window la informacion del Modelo
            %
            % Imprime la informacion guardada en el Modelo (obj) en
            % pantalla
            
            fprintf('Propiedades modelo:\n');
            fprintf('\tDimensiones modelo: %iD\n', obj.nDimensiones);
            fprintf('\tNumero de GDL del modelo: %i\n', obj.nGDL);
            dispMetodoTEFAME();
            
        end % disp function
        
    end % methods Modelo
    
end % class Modelo