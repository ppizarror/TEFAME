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
%| Clase ComponenteModelo                                               |
%|                                                                      |
%| Este archivo contiene la definicion de la Clase ComponenteModelo     |
%| ComponenteModelo es  clase  abstracta  que es usada  como base  para |
%| todos los objetos que son una componente del Modelo.                 |
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
%       obj = ComponenteModelo(etiqueta)
%       etiqueta = obtenerEtiqueta(obj)
%       objID = obtenerIDObjeto(obj)
%       disp(obj)
%       e = equals(obj,obj)

classdef ComponenteModelo < handle
    
    properties(Access = private)
        etiquetaID % Variable que guarda el valor de la etiqueta usada para identificar el componente del modelo
    end % private properties ComponenteModelo
    
    properties(Access = protected)
        objectID % ID del objeto
    end % protected properties ComponenteModelo
    
    methods(Access = public)
        
        function obj = ComponenteModelo(etiqueta)
            % ComponenteModelo: es el constructor de la clase ComponenteModelo
            %
            % Crea un objeto de la clase ComponenteModelo, con un identificador
            % unico (etiqueta)
            
            % Verificamos si no se ingreso etiqueta
            if nargin == 0
                etiqueta = -1;
            end
            
            % Se guarda la etiqueta
            obj.etiquetaID = etiqueta;
            
            % Crea el ID
            obj.objectID = char(java.util.UUID.randomUUID);
            
        end % ComponenteModelo constructor
        
        function etiqueta = obtenerEtiqueta(obj)
            % obtenerEtiqueta: es un metodo de la clase ComponenteModelo que se
            % usa para obtener la etiqueta que identifica el componente del
            % modelo
            %
            % Entrega la etiqueta o identificar (etiqueta) que tiene el
            % ComponenteModelo (obj)
            
            etiqueta = obj.etiquetaID;
            
        end % obtenerEtiqueta function
        
        function disp(obj)
            % disp: es un metodo de la clase ComponenteModelo que se usa para
            % imprimir en command Window la informacion del ComponenteModelo
            %
            % Imprime la informacion de la etiqueta de identificacion del componente
            % del modelo
            
            % Se procede a imprimir en pantalla la etiqueta
            etiquetaStr = obj.etiquetaID;
            if (isnumeric(obj.etiquetaID) == 1)
                etiquetaStr = num2str(etiquetaStr);
            end
            fprintf('\tEtiqueta: %s\n', etiquetaStr);
            % No usar dispMetodoTEFAME()
            
        end % disp function
        
        function e = equals(obj, obj1)
            % equals: Verifica si dos objetos son iguales
            
            e = strcmp(obj.objectID, obj1.objectID);
            
        end % equals function
        
        function objID = obtenerIDObjeto(obj)
            % obtenerIDObjeto: Retorna el ID del objeto
            
            objID = obj.objectID;
            
        end % obtenerIDObjeto function
        
    end % public methods ComponenteModelo
    
end % classdef ComponenteModelo