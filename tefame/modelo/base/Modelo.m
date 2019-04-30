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
%       nDimensiones
%       nGDL
%       nodos
%       elementos
%       restricciones
%       patronesDeCargas
%  Methods:
%       modeloObj = Modelo(numeroDimensiones,numerosGDL)
%       agregarNodos(modeloObj,arregloNodos)
%       agregarElementos(modeloObj,arregloElementos)
%       agregarRestricciones(modeloObj,arregloRestricciones)
%       agregarPatronesDeCargas(modeloObj,arregloPatronesDeCargas)
%       agregarDisipadores(modeloObj,arregloDisipadores)
%       nodosModelo = obtenerNodos(modeloObj)
%       elementosModelo = obtenerElementos(modeloObj)
%       restriccionesModelo = obtenerRestricciones(modeloObj)
%       patronesDeCargasModelo = obtenerPatronesDeCargas(modeloObj)
%       numDimensiones = obtenerNumeroDimensiones(modeloObj)
%       numGDL = obtenerNumerosGDL(modeloObj)
%       inicializar(modeloObj)
%       aplicarRestricciones(modeloObj)
%       aplicarPatronesDeCargas(modeloObj)
%       actualizar(modeloObj,u)
%       guardarResultados(modeloObj,nombreArchivo)
%       disp(modeloObj)

classdef Modelo < handle
    
    properties(Access = private)
        nDimensiones % Variable que guarda las dimensiones del sistema de coordenadas del modelo
        nGDL % Variable que guarda el numero de grados de libertad de cada nodo (GDL)
        nodos % Variable que guarda en un arreglo de celdas todos los nodos del modelo
        elementos % Variable que guarda en un arreglo de celdas todos los elementos del modelo.
        disipadores % Variable que guarda en un arreglo de celdas todos los disipadores del modelo.
        restricciones % Variable que guarda en un arreglo de celdas todos las restricciones del modelo
        patronesDeCargas % Variable que guarda en un arreglo de celdas todos los patrones de cargas aplicadas sobre el modelo
    end % properties Modelo
    
    methods
        
        function modeloObj = Modelo(numeroDimensiones, numerosGDL)
            % Modelo: es el constructor de la clase Modelo
            %
            % modeloObj = Modelo(numeroDimensiones,numerosGDL)
            % Crea un objeto de la clase Modelo, con el numero de dimensiones
            % que tiene el sistema de coordenadas del modelo (nDimensiones) y
            % el numero de grados de libertad por nodo
            
            % Definimos las propiedades de entrada si, no se ingresa ningun valor
            if nargin == 0
                numeroDimensiones = 0;
                numerosGDL = 0;
            end % if
            
            % Definimos las propiedades en el modelo
            modeloObj.nDimensiones = numeroDimensiones;
            modeloObj.nGDL = numerosGDL;
            
            % Generamos el modelo con todos las variables que guardan las
            % componentes del modelo vacio
            modeloObj.nodos = [];
            modeloObj.elementos = [];
            modeloObj.disipadores = [];
            modeloObj.restricciones = [];
            modeloObj.patronesDeCargas = [];
            
        end % Modelo constructor
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Metodos para agregar componentes del Modelo
        
        function agregarNodos(modeloObj, arregloNodos)
            % agregarNodos: es un metodo de la clase Modelo que se usa para
            % entregarle el arreglo con los nodos al Modelo
            %
            % agregarNodos(modeloObj,arregloNodos)
            % Agrega el arreglo con los nodos (arregloNodos) al Modelo (modeloObj)
            % para que esto lo guarde y tenga acceso a los nodos
            
            for i = 1:length(arregloNodos)
                if ~isa(arregloNodos{i}, 'Nodo')
                    error('Elemento %d del arreglo de nodos no es un nodo', i);
                end
            end
            modeloObj.nodos = arregloNodos;
            
        end % agregarNodos function
        
        function agregarElementos(modeloObj, arregloElementos)
            % agregarElementos: es un metodo de la clase Modelo que se usa para
            % entregarle el arreglo con los elementos al Modelo
            %
            % agregarElementos(modeloObj,arregloElementos)
            % Agrega el arreglo con los elementos (arregloElementos) al Modelo
            % (modeloObj) para que esto lo guarde y tenga acceso a los elementos
            
            for i = 1:length(arregloElementos)
                if ~isa(arregloElementos{i}, 'Elemento')
                    error('Elemento %d del arreglo de elementos no es un elemento', i);
                end
            end
            modeloObj.elementos = arregloElementos;
            
        end % agregarElementos function
        
        function agregarDisipadores(modeloObj, arregloDisipadores)
            % agregarDisipadores: es un metodo de la clase Modelo que se usa
            % para entregarle el arreglo con los disipadores al modelo
            %
            % agregarDisipadores(modeloObj,arregloDisipadores)
            % Agrega el arreglo con los elementos (arregloDisipadores) al modelo
            % (modeloObj) para que esto lo guarde y tenga acceso a los disipadores
            
            for i = 1:length(arregloDisipadores)
                if ~isa(arregloDisipadores{i}, 'Disipador')
                    error('Elemento %d del arreglo de disipadores no es un disipador', i);
                end
            end
            modeloObj.disipadores = arregloDisipadores;
            
        end % agregarDisipadores function
        
        function agregarRestricciones(modeloObj, arregloRestricciones)
            % agregarRestricciones: es un metodo de la clase Modelo que se usa
            % para entregarle el arreglo con los restricciones al Modelo
            %
            % agregarRestricciones(modeloObj,arregloRestricciones)
            % Agrega el arreglo con los restricciones (arregloRestricciones)
            % al Modelo (modeloObj) para que esto lo guarde y tenga acceso a
            % los restricciones
            
            for i = 1:length(arregloRestricciones)
                if ~isa(arregloRestricciones{i}, 'RestriccionNodo')
                    error('Elemento %d del arreglo de restricciones no es una restriccion', i);
                end
            end
            modeloObj.restricciones = arregloRestricciones;
            
        end % agregarRestricciones function
        
        function agregarPatronesDeCargas(modeloObj, arregloPatronDeCargas)
            % agregarPatronesDeCargas: es un metodo de la clase Modelo que se usa
            % para entregarle el arreglo con los patrones de carga al Modelo
            %
            % agregarPatronesDeCargas(modeloObj,arregloPatronDeCargas)
            % Agrega el arreglo con los patrones de carga (arregloPatronDeCargas)
            % al Modelo (modeloObj) para que esto lo guarde y tenga acceso a los
            % patrones de carga
            % Los patrones de cargas contienen las cargas que se aplican en los
            % nodos y elementos
            
            for i = 1:length(arregloPatronDeCargas)
                if ~isa(arregloPatronDeCargas{i}, 'PatronDeCargas')
                    error('Elemento %d del arreglo de patrones de cargas no es un patron de carga', i);
                end
            end
            modeloObj.patronesDeCargas = arregloPatronDeCargas;
            
        end % agregarPatronesDeCargas function
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Metodos para obtener los componentes del Modelo
        
        function nodosModelo = obtenerNodos(modeloObj)
            % obtenerNodos: es un metodo de la clase Modelo que se usa para
            % obtener el arreglo con los nodos guardados en el Modelo
            %
            % nodosModelo = obtenerNodos(modeloObj)
            % Obtiene el arreglo con los nodos (nodosModelo) que esta guardado
            % en el Modelo (modeloObj)
            
            nodosModelo = modeloObj.nodos;
            
        end % obtenerNodos function
        
        function elementosModelo = obtenerElementos(modeloObj)
            % obtenerElementos: es un metodo de la clase Modelo que se usa para
            % obtener el arreglo con los elementos guardados en el Modelo
            %
            % elementosModelo = obtenerElementos(modeloObj)
            % Obtiene el arreglo con los elementos (elementosModelo) que esta
            % guardado en el Modelo (modeloObj)
            
            elementosModelo = modeloObj.elementos;
            
        end % obtenerElementos function
        
        function disipadoresModelo = obtenerDisipadores(modeloObj)
            % obtenerDisipadores: es un metodo de la clase Modelo que se usa para
            % obtener el arreglo con los disipadores guardados del modelo
            %
            % DisipadoresModelo = obtenerDisipadores(modeloObj)
            % Obtiene el arreglo con los disipadores (DisipadoresModelo) que esta
            % guardado en el Modelo (modeloObj)
            
            disipadoresModelo = modeloObj.disipadores;
            
        end % obtenerDisipadores function
        
        function restriccionesModelo = obtenerRestricciones(modeloObj)
            % obtenerPatronDeCargas: es un metodo de la clase Modelo que se usa para
            % obtener el arreglo con los patrones de carga guardados en el Modelo
            %
            % patronDeCargasModelo = obtenerPatronDeCargas(modeloObj)
            % Obtiene el arreglo con los patrones de carga (patronDeCargasModelo)
            % que esta guardado en el Modelo (modeloObj)
            
            restriccionesModelo = modeloObj.restricciones;
            
        end % obtenerRestricciones function
        
        function patronesDeCargasModelo = obtenerPatronesDeCargas(modeloObj)
            % obtenerPatronesDeCargas: es un metodo de la clase Modelo que se usa para
            % obtener el arreglo con los patrones de carga guardados en el Modelo
            %
            % patronesDeCargasModelo = obtenerPatronesDeCargas(modeloObj)
            % Obtiene el arreglo con los patrones de carga (patronesDeCargasModelo)
            % que esta guardado en el Modelo (modeloObj)
            
            patronesDeCargasModelo = modeloObj.patronesDeCargas;
            
        end % obtenerPatronesDeCargas function
        
        function numDimensiones = obtenerNumeroDimensiones(modeloObj)
            % obtenerNumeroDimensiones: es un metodo de la clase Modelo que
            % se usa para obtener el numero de dimensiones del modelo
            %
            % numDimensiones = obtenerNumeroDimensiones(modeloObj)
            
            numDimensiones = modeloObj.nDimensiones;
            
        end % obtenerNumeroDimensiones function
        
        function numGDL = obtenerNumerosGDL(modeloObj)
            % obtenerNumerosGDL: es un metodo de la clase Modelo que
            % se usa para obtener el numero de grados de libertad por nodo
            % del modelo
            %
            % numGDL = obtenerNumerosGDL(modeloObj)
            
            numGDL = modeloObj.nGDL;
            
        end % obtenerNumerosGDL function
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Metodos para inicializar y actualizar las componentes del Modelo
        
        function inicializar(modeloObj)
            % inicializar: es un metodo de la clase Modelo que se usa para
            % inicializar las diferentes componentes en el Modelo
            %
            % inicializar(modeloObj)
            % Inicializa los diferentes componentes del modelo que estan guardados
            % en el Modelo (modeloObj), para poder preparar estos para realizar
            % el analisis
            
            for i = 1:length(modeloObj.nodos)
                modeloObj.nodos{i}.inicializar()
            end
            
            for i = 1:length(modeloObj.elementos)
                modeloObj.elementos{i}.inicializar()
            end
            
        end % inicializar function
        
        function aplicarRestricciones(modeloObj)
            % aplicarRestricciones: es un metodo de la clase Modelo que se usa para
            % aplicar las restricciones en el Modelo
            %
            % aplicarRestricciones(modeloObj)
            % Aplica las restricciones que estan guardadas en el Modelo (modeloObj)
            
            for i = 1:length(modeloObj.restricciones)
                modeloObj.restricciones{i}.aplicarRestriccion()
            end
            
        end % aplicarRestricciones function
        
        function aplicarPatronesDeCargasEstatico(modeloObj)
            % aplicarPatronesDeCargas: es un metodo de la clase Modelo que se usa
            % para aplicar las patrones de cargas en el Modelo
            %
            % aplicarPatronesDeCargasEstatico(modeloObj)
            % Aplica los patrones de cargas que estan guardados en el Modelo
            % (modeloObj), es decir, aplica las cargas sobre los nodos y
            % elementos
            
            fprintf('\tAplica patron de cargas estatico\n');
            for i = 1:length(modeloObj.patronesDeCargas)
                if ~modeloObj.patronesDeCargas{i}.patronDinamico()
                    modeloObj.patronesDeCargas{i}.aplicarCargas();
                end
            end
            
        end % aplicarPatronesDeCargasEstatico function
        
        function aplicarPatronesDeCargasDinamico(modeloObj, cpenzien)
            % aplicarPatronesDeCargasDinamico: es un metodo de la clase Modelo que se usa
            % para aplicar las patrones de cargas en el Modelo
            %
            % aplicarPatronesDeCargasDinamico(modeloObj,cpenzien)
            % Aplica los patrones de cargas que estan guardados en el Modelo
            % (modeloObj), es decir, aplica las cargas sobre los nodos y
            % elementos. Requiere ademas si se usa la matriz de
            % amortiguamiento de penzien, por defecto es falso, o sea usa
            % Rayleigh
            
            fprintf('\tAplica patron de cargas dinamico\n');
            for i = 1:length(modeloObj.patronesDeCargas)
                if modeloObj.patronesDeCargas{i}.patronDinamico()
                    modeloObj.patronesDeCargas{i}.aplicarCargas(cpenzien);
                end
            end
            
        end % aplicarPatronesDeCargasDinamico function
        
        function actualizar(modeloObj, u)
            % actualizar: es un metodo de la clase Modelo que se usa para actualizar
            % las componentes en el Modelo
            %
            % actualizar(modeloObj,u)
            % Actualiza o informa de los desplazamientos (u), entregados por el
            % analisis al resolver el sistema de ecuaciones, a las componentes
            % guardadas en el Modelo (modeloObj)
            
            % Se procede a actualizar los desplazamientos guardados
            
            % Se definen e informan los desplazmientos a cada nodo
            numeroNodos = length(modeloObj.nodos);
            for i = 1:numeroNodos
                
                % Nodo
                nodo = modeloObj.nodos{i};
                gdlnodo = nodo.obtenerGDLID();
                
                % Se buscan desplazamientos en el vector u
                ngrados = nodo.obtenerNumeroGDL();
                d = zeros(ngrados, 1);
                for j = 1:ngrados
                    if (gdlnodo(j) ~= 0)
                        d(j) = u(gdlnodo(j));
                    end
                end
                
                % Guarda los desplazamientos
                modeloObj.nodos{i}.definirDesplazamientos(d');
                
            end % for i
            
            % Agregamos las fuerzas resistentes a las reacciones
            numeroElementos = length(modeloObj.elementos);
            for i = 1:numeroElementos
                modeloObj.elementos{i}.agregarFuerzaResistenteAReacciones();
            end % for i
            
        end % actualizar function
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Metodos para guardar la informacion del Modelo y resultados del
        % analisis en un archivo de salida
        
        function guardarResultados(modeloObj, nombreArchivo)
            % guardarResultados: es un metodo de la clase Modelo que se usa para
            % guardar o imprimir en un archivo las propiedades de las componentes
            % del Modelo y los resultados del analisis
            %
            % guardarResultados(modeloObj,nombreArchivo)
            % Guarda las propiedades de las componentes del Modelo (modeloObj) y
            % los resultados del analisis que tienen guardados los diferentes
            % componentes en un archivo (nombreArchivo)
            
            % Abre el archivo donde se guardara la informacion
            try
                archivoSalida = fopen(nombreArchivo, 'w');
                fprintf(archivoSalida, 'TEFAME - Toolbox para Elemento Finitos y Analisis\n');
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
            fprintf(archivoSalida, 'Nodos:\n');
            nNodos = length(modeloObj.nodos);
            fprintf(archivoSalida, '\tNumero de nodos: %d\n', nNodos);
            for iNodo = 1:nNodos
                modeloObj.nodos{iNodo}.guardarPropiedades(archivoSalida);
            end
            fprintf(archivoSalida, '\n');
            
            % Se procede a guardar las propiedades de los elementos
            fprintf(archivoSalida, 'Elementos:\n');
            nElementos = length(modeloObj.elementos);
            fprintf(archivoSalida, '\tNumero de elementos: %d\n', nElementos);
            for iElem = 1:nElementos
                modeloObj.elementos{iElem}.guardarPropiedades(archivoSalida);
            end % for iElem
            
            fprintf(archivoSalida, '\n');
            fprintf(archivoSalida, '-------------------------------------------------------------------------------\n');
            fprintf(archivoSalida, 'Resultados del analisis\n');
            fprintf(archivoSalida, '-------------------------------------------------------------------------------\n');
            fprintf(archivoSalida, '\n');
            
            % Se procede a guardar los desplazamientos en cada nodo
            fprintf(archivoSalida, 'Desplazamientos nodos:\n');
            for iNodo = 1:nNodos
                modeloObj.nodos{iNodo}.guardarDesplazamientos(archivoSalida);
            end % for iNodo
            fprintf(archivoSalida, '\n');
            
            % Se procede a guardar las reacciones
            fprintf(archivoSalida, 'Reacciones:\n');
            for iNodo = 1:nNodos
                modeloObj.nodos{iNodo}.guardarReacciones(archivoSalida);
            end % for iNodo
            fprintf(archivoSalida, '\n');
            
            % Se procede a guardar los esfuerzos en los elementos
            fprintf(archivoSalida, 'Esfuerzos Elementos:');
            for i = 1:length(modeloObj.elementos)
                modeloObj.elementos{i}.guardarEsfuerzosInternos(archivoSalida);
            end % for i
            fclose(archivoSalida);
            
        end % guardarResultados function
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Metodos para mostrar la informacion del Modelo en pantalla
        
        function disp(modeloObj)
            % disp: es un metodo de la clase Modelo que se usa para imprimir en
            % command Window la informacion del Modelo
            %
            % disp(modeloObj)
            % Imprime la informacion guardada en el Modelo (modeloObj) en
            % pantalla
            
            fprintf('Propiedades Modelo:\n');
            fprintf('\tDimensiones Modelo: %iD\n', modeloObj.nDimensiones);
            fprintf('\tNumero de GDL del Modelo: %i\n', modeloObj.nGDL);
            
        end % disp function
        
    end % methods Modelo
    
end % class Modelo