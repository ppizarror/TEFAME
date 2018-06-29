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
%| Clase Elemento                                                       |
%|                                                                      |
%| Este archivo contiene la definicion de la Clase Elemento             |
%| Elemento es una subclase de la  clase ComponenteModelo y corresponde |
%| a  la representacion  abstracta  de los elementos en  el  metodo  de |
%| elementos finitos o analisis matricial de estructuras.               |
%| La clase Elemento se usa como una superclase para todos los tipos de |
%| elementos que hay en la plataforma. Y define los metodos minimos que |
%| tiene que ser implementados en cada subclase                         |
%|                                                                      |
%| Programado: FR                                                       |
%| Fecha: 05/08/2015                                                    |
%|                                                                      |
%| Modificado por: FR - 24/10/2016                                      |
%|______________________________________________________________________|
%
%  Properties (Access=private):
%
%  Methods:
%       elementoObj = Elemento(etiquetaElemento)
%       numeroNodos = obtenerNumeroNodos(elementoObj)
%       nodosElemento = obtenerNodos(elementoObj)
%       numeroGDL = obtenerNumeroGDL(elementoObj)
%       gdlID = obtenerGDL(elementoObj)
%       k_global = obtenerMatrizRigidezCoordGlobal(elementoObj)
%       k_local = obtenerMatrizRigidezCoordLocal(elementoObj)
%       fr_global = obtenerFuerzaResistenteCoordGlobal(elementoObj)
%       fr_local = obtenerFuerzaResistenteCoordLocal(elementoObj)
%       inicializar(elementoObj)
%       definirGDLID(elementoObj)
%       agregarFuerzaResistenteAReacciones(elementoObj)
%       actualizar(elementoObj)
%       guardarPropiedades(elementoObj,archivoSalidaHandle)
%       guardarEsfuerzosInternos(elementoObj,archivoSalidaHandle)
%       disp(elementoObj)
%
%  Methods SuperClass (ComponenteModelo):
%       etiqueta = obtenerEtiqueta(componenteModeloObj)

classdef Elemento < ComponenteModelo
    
    properties(Access = private)
    end % properties Elemento
    
    methods
        
        function elementoObj = Elemento(etiquetaElemento)
            % Elemento: es el constructor de la clase Elemento
            %
            % elementoObj = Elemento(etiquetaElemento)
            % Crea un objeto de la clase Elemento, con un identificador unico
            % (etiquetaElemento)
            
            % Si no se pasan argumentos se crean vacios
            if nargin == 0
                etiquetaElemento = '';
            end % if
            
            %Llamamos al constructor de la SuperClass que es la clase ComponenteModelo
            elementoObj = elementoObj@ComponenteModelo(etiquetaElemento);
            
        end % Elemento constructor
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Metodos para obtener informacion del Elemento
        
        function numeroNodos = obtenerNumeroNodos(elementoObj) %#ok<MANU>
            % obtenerNumeroNodos: es un metodo de la clase Elemento que se usa para
            % obtener el numero de nodos que tiene el Elemento
            %
            % numeroNodos = obtenerNumeroNodos(elementoObj)
            % Entrega el numero de nodos (numeroNodos) que tiene el Elemento
            % (elementoObj)
            
            numeroNodos = 0;
            
        end % obtenerNumeroNodos function
        
        function nodosElemento = obtenerNodos(elementoObj) %#ok<MANU>
            % obtenerNodos: es un metodo de la clase Elemento que se usa para
            % obtener un arreiglo con los nodos que tiene el Elemento
            %
            % nodosElemento = obtenerNumeroNodos(elementoObj)
            % Entrega un arreiglo con los Nodos (nodosElemento) que tiene el Elemento
            % (elementoObj)
            
            nodosElemento = [];
            
        end % obtenerNodos function
        
        function numeroGDL = obtenerNumeroGDL(elementoObj) %#ok<MANU>
            % obtenerNumeroGDL: es un metodo de la clase Elemento que se usa para
            % obtener el numero total de grados de libertad que tiene el Elemento
            %
            % numeroGDL = obtenerNumeroGDL(elementoObj)
            % Entrega el numero de GDL (numeroGDL) que tiene el Elemento (elementoObj)
            
            numeroGDL = [];
            
        end % obtenerNumeroGDL function
        
        function gdlID = obtenerGDL(elementoObj) %#ok<MANU>
            % obtenerGDL: es un metodo de la clase Elemento que se usa para
            % obtener un arreiglo con los ID de los grados de libertad que estan
            % asociados al Elemento
            %
            % gdlID = obtenerGDL(elementoObj)
            % Entrega un arreiglo con los ID de los GDL (gdlID) que tiene el Elemento
            % (elementoObj)
            
            gdlID = [];
            
        end % obtenerGDL function
        
        function k_global = obtenerMatrizRigidezCoordGlobal(elementoObj) %#ok<MANU>
            % obtenerMatrizRigidezCoordGlobal: es un metodo de la clase Elemento
            % que se usa para obtener la matriz de rigidez para el Elemento en el
            % sistema de coordenadas globales del sistema estructural o Modelo
            %
            % k_global = obtenerMatrizRigidezCoordGlobal(elementoObj)
            % Entrega la matriz de rigidez (k_global) que tiene el Elemento (elementoObj)
            %  en el sistema de coordenadas globales
            
            k_global = [];
            
        end % obtenerMatrizRigidezGlobal function
        
        function k_local = obtenerMatrizRigidezCoordLocal(elementoObj) %#ok<MANU>
            % obtenerMatrizRigidezCoordLocal: es un metodo de la clase Elemento
            % que se usa para obtener la matriz de rigidez para el Elemento en el
            % sistema de coordenadas locales del elemento
            %
            % k_local = obtenerMatrizRigidezCoordLocal(elementoObj)
            % Entrega la matriz de rigidez (k_local)  en el sistema de coordenadas
            % local que tiene el Elemento (elementoObj)
            
            k_local = [];
            
        end % obtenerMatrizRigidezLocal function
        
        function fr_global = obtenerFuerzaResistenteCoordGlobal(elementoObj) %#ok<MANU>
            % obtenerFuerzaResistenteCoordGlobal: es un metodo de la clase Elemento
            % que se usa para obtener el vector de fuerzas resitente del Elemento
            % en el sistema de coordenadas globales del modelo o sistema
            % estructural
            %
            % fr_global = obtenerFuerzaResistenteCoordGlobal(elementoObj)
            % Entrega el vector con las fuerzas resistentes (fr_global) que tiene
            % elemento (elementoObj) en el sistema de coordenadas globales la
            % estructura
            
            fr_global = [];
            
        end % obtenerFuerzaResistenteCoordGlobal function
        
        function fr_local = obtenerFuerzaResistenteCoordLocal(elementoObj) %#ok<MANU>
            % obtenerFuerzaResistenteCoordLocal: es un metodo de la clase Elemento
            % que se usa para obtener el vector de fuerzas resitente del Elemento
            % en el sistema de coordenadas locales del elemento
            %
            % fr_local = obtenerFuerzaResistenteCoordLocal(elementoObj)
            % Entrega el vector con las fuerzas resistentes (fr_local) que tiene
            % elemento (elementoObj) en el sistema de coordenadas locales del
            % elemento
            
            fr_local = [];
            
        end % obtenerFuerzaResistenteCoordLocal function
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Metodos para inicializar la informacion del Elemento usada en el analisis
        
        function inicializar(elementoObj) %#ok<MANU>
            % inicializar: es un metodo de la clase Elemento que se usa para
            % inicializar las diferentes componentes que sean necesario en los
            % elementos para realizar posteriormente el analisis
            %
            % inicializar(elementoObj)
            % Inicializa los diferentes componetes del Elemento (elementoObj),
            % para poder preparar estos para realizar el analisis
            
            
        end % inicializar function
        
        function definirGDLID(elementoObj) %#ok<MANU>
            % definirGDLID: es un metodo de la clase Elemento que se usa para
            % definir el vector con los ID de los GDL del elemento
            %
            % definirGDLID(elementoObj)
            % Define los ID de los grados de libertad del Elemento (elementoObj)
            
            
        end % definirGDLID function
        
        function agregarFuerzaResistenteAReacciones(elementoObj) %#ok<MANU>
            % agregarEsfuerzosElementoAReaccion: es un metodo de la clase Nodo
            % que se usa para agregar el vector de fuerzas resistentes de un
            % elemento al nodo.
            %
            % agregarEsfuerzosElementoAReaccion(nodoObj,esfuerzosElemento)
            % Agrega al vector de reacciones del Nodo (nodoObj), el vector de
            % fuerzas resistente de un elemento entregados (cargaNodo)
            
            
        end % agregarFuerzaResistenteAReacciones function
        
        function actualizar(elementoObj) %#ok<MANU>
            % actualizar: es un metodo de la clase Elemento que se usa para
            % actualizar las diferentes componentes que sean necesario en los
            % elementos posterior a realizar el analisis
            %
            % actualizar(elementoObj)
            % Actualizar los diferentes componetes del Elemento (elementoObj),
            % despues de realizar el analisis
            
            
        end % actualizar function
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Metodos para guardar la informacion del Elemento en un archivo de salida
        
        function guardarPropiedades(elementoObj, archivoSalidaHandle) %#ok<INUSD>
            % guardarPropiedades: es un metodo de la clase Elemento que se usa
            % para guardar en un archivo de salida las propiedades del Elemento
            %
            % guardarPropiedades(elementoObj,archivoSalidaHandle)
            % Guarda las propiedades de los Elemento (elementoObj), en un archivo
            % de salida (archivoSalidaHandle)
            
            
        end % guardarPropiedades function
        
        function guardarEsfuerzosInternos(elementoObj, archivoSalidaHandle) %#ok<INUSD>
            % guardarEsfuerzosInternos: es un metodo de la clase Elemento que se
            % usa para guardar en un archivo de salida los esfuerzos internos del
            % Elemento
            %
            % guardarEsfuerzosInternos(elementoObj,archivoSalidaHandle)
            % Guarda los esfuerzos internos de los Elemento (elementoObj), en un
            % archivo de salida (archivoSalidaHandle)
            
            
        end % guardarEsfuerzosInternos function
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Metodos para mostar la informacion del Elemento en pantalla
        
        function disp(elementoObj)
            % disp: es un metodo de la clase Elemento que se usa para impimir en
            % command Window la informacion del Elemento
            %
            % disp(elementoObj)
            % Imprime la informacion guardada en el Elemento (elementoObj) en
            % pantalla
            
            disp@ComponenteModelo(elementoObj);
            
        end % disp function
        
    end % methods Elemento
    
end % class Elemento