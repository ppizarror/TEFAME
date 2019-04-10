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
%|______________________________________________________________________|
%
%  Properties (Access=private):
%       etiquetaID
%
%  Methods:
%       componenteModeloObj = ComponenteModelo(etiqueta)
%       etiqueta = obtenerEtiqueta(componenteModeloObj)
%       disp(componenteModeloObj)

classdef ComponenteModelo < handle
    
    properties(Access = private)
        etiquetaID % Variable que guarda el valor de la etiqueta usada para identificar el componente del modelo
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
            
        end % ComponenteModelo constructor
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Metodos para obtener informacion del ComponenteModelo
        
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
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Metodos para mostrar la informacion del ComponenteModelo en pantalla
        
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
        
    end % methods ComponenteModelo
    
end % classdef ComponenteModelo