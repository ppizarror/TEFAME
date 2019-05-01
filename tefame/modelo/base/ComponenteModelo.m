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
%| Clase ComponenteModelo                                               |
%|                                                                      |
%| Este archivo contiene la definicion de la Clase ComponenteModelo     |
%| ComponenteModelo es  clase  abstracta  que es usada  como base  para |
%| todos los objetos que son una componente del Modelo                  |
%|                                                                      |
%| Programado: FR                                                       |
%| Fecha: 05/08/2015                                                    |
%|                                                                      |
%| Modificado por: FR - 24/10/2016                                      |
%|                 Pablo Pizarro @ppizarror - 10/04/2019                |
%|______________________________________________________________________|
%
%  Properties (Access=private):
%       etiquetaID
%  Methods:
%       componenteModeloObj = ComponenteModelo(etiqueta)
%       etiqueta = obtenerEtiqueta(componenteModeloObj)
%       disp(componenteModeloObj)
%       e = equals(componenteModeloObj,obj)

classdef ComponenteModelo < handle
    
    properties(Access = private)
        etiquetaID % Variable que guarda el valor de la etiqueta usada para identificar el componente del modelo
    end % properties ComponenteModelo
    
    properties(Access = protected)
        objectID % ID del objeto
    end % properties ComponenteModelo
    
    methods
        
        function componenteModeloObj = ComponenteModelo(etiqueta)
            % ComponenteModelo: es el constructor de la clase ComponenteModelo
            %
            % componenteModeloObj = ComponenteModelo(etiqueta)
            % Crea un objeto de la clase ComponenteModelo, con un identificador
            % unico (etiqueta)
            
            % Verificamos si no se ingreso etiqueta
            if nargin == 0
                etiqueta = -1;
            end
            
            % Se guarda la etiqueta
            componenteModeloObj.etiquetaID = etiqueta;
            
            % Crea el ID
            componenteModeloObj.objectID = char(java.util.UUID.randomUUID);
            
        end % ComponenteModelo constructor
        
        function etiqueta = obtenerEtiqueta(componenteModeloObj)
            % obtenerEtiqueta: es un metodo de la clase ComponenteModelo que se
            % usa para obtener la etiqueta que identifica el componente del
            % modelo
            %
            % etiqueta = obtenerEtiqueta(componenteModeloObj)
            % Entrega la etiqueta o identificar (etiqueta) que tiene el
            % ComponenteModelo (componenteModeloObj)
            
            etiqueta = componenteModeloObj.etiquetaID;
            
        end % obtenerEtiqueta function
        
        function disp(componenteModeloObj)
            % disp: es un metodo de la clase ComponenteModelo que se usa para
            % imprimir en command Window la informacion del ComponenteModelo
            %
            % disp(nodoObj)
            % Imprime la informacion de la etiqueta de identificacion del componente
            % del modelo
            
            % Se procede a imprimir en pantalla la etiqueta
            etiquetaStr = componenteModeloObj.etiquetaID;
            if (isnumeric(componenteModeloObj.etiquetaID) == 1)
                etiquetaStr = num2str(etiquetaStr);
            end
            fprintf('\tEtiqueta: %s\n', etiquetaStr);
            
        end % disp function
        
        function e = equals(componenteModeloObj, obj)
            % equals: Verifica si dos objetos son iguales
            %
            % equals(componenteModeloObj,obj)
            
            e = strcmp(componenteModeloObj.objectID, obj.objectID);
            
        end % equals function
        
    end % methods ComponenteModelo
    
end % classdef ComponenteModelo