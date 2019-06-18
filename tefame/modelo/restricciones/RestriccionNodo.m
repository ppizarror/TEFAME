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
%| Clase RestriccionNodo                                                |
%|                                                                      |
%| Este archivo contiene la definicion de la Clase RestriccionNodo      |
%| RestriccionNodo  es  una  subclase  de la  clase  ComponenteModelo y |
%| corresponde a la representacion abstracta de los restricciones en un |
%| Nodo en elementos finitos o analisis matricial de estructuras.       |
%| La clase  RestriccionNodo  controla y guarda  los GDL restringidos y |
%| los valores de restriccion en el Nodo.                               |
%|                                                                      |
%| Programado: FR                                                       |
%| Fecha: 05/08/2015                                                    |
%|                                                                      |
%| Modificado por: FR - 24/10/2016                                      |
%|                 Pablo Pizarro @ppizarror - 10/04/2019                |
%|______________________________________________________________________|
%
%  Methods(Access=public):
%       obj = RestriccionNodo(etiquetaRestriccion,nodoObjeto,gdlRestringidosNodo)
%       obj = RestriccionNodo(etiquetaRestriccion,nodoObjeto,gdlRestringidosNodo,valoresRestrinccionNodo)
%       aplicarRestriccion(obj)
%       disp(obj)
%  Methods Suplerclass (ComponenteModelo):
%       etiqueta = obtenerEtiqueta(obj)
%       e = equals(obj,obj)
%       objID = obtenerIDObjeto(obj)

classdef RestriccionNodo < ComponenteModelo
    
    properties(Access = private)
        gdlRestringidos % Grados de libertad restringidos
        nodoObj % Nodos
        valoresRestriccion % Restriccion de los nodos
    end % private properties RestriccionNodo
    
    methods(Access = public)
        
        function obj = RestriccionNodo(etiquetaRestriccion, nodoObjeto, gdlRestringidosNodo, ~)
            % RestriccionNodo: es el constructor de la clase RestriccionNodo
            % Crea un objeto de la clase RestriccionNodo, con un identificador
            % unico (etiquetaRestriccion), indicando a que nodo restringe (nodoObjeto)
            % y cuales son los grados de libertad que se restringen (gdlRestringidosNodo)
            %
            % Crea un objeto de la clase RestriccionNodo, con un identificador
            % unico (etiquetaRestriccion), indicando a que nodo restringe (nodoObjeto)
            % , cuales son los grados de libertad que se restringen (gdlRestringidosNodo)
            
            if nargin == 0
                etiquetaRestriccion = '';
                gdlRestringidosNodo = [];
                nodoObjeto = [];
            end
            
            % Llamamos al constructor de la SuperClass que es la clase ComponenteModelo
            obj = obj@ComponenteModelo(etiquetaRestriccion);
            
            % Se guarda el nodo a restringir, y se  coloca como vector
            % columna
            obj.nodoObj = nodoObjeto;
            if size(gdlRestringidosNodo, 1) == 1
                obj.gdlRestringidos = gdlRestringidosNodo';
            else
                obj.gdlRestringidos = gdlRestringidosNodo;
            end
            
        end % RestriccionNodo constructor
        
        function aplicarRestriccion(obj)
            % aplicarRestriccion: es un metodo de la clase RestriccionNodo que
            % se usa para aplicar la restriccion en los nodos
            %
            % Aplica la restriccion especificada en RestriccionNodo (obj)
            % sobre el Nodo en los GDL indicados
            
            % Se extraen los ID del GDL
            gdlID = obj.nodoObj.obtenerGDLID();
            
            % Se coloca cero en los GDL que se indicaron en la restriccion
            for i = 1:length(obj.gdlRestringidos)
                if obj.gdlRestringidos(i) ~= 0
                    gdlID(obj.gdlRestringidos(i)) = 0;
                end
            end % for i
            
            % Se asigna el nuevo valor de GDLID al Nodo
            obj.nodoObj.definirGDLID(gdlID);
            
        end % aplicarRestriccion function
        
        function disp(obj)
            % disp: es un metodo de la clase RestriccionNodo que se usa para
            % imprimir en command Window la informacion del RestriccionNodo
            %
            % Imprime la informacion guardada en la restriccion (obj)
            % en pantalla
            
            fprintf('Propiedades restriccion nodo:\n');
            
            disp@ComponenteModelo(obj);
            
            % Se extrae la etiqueta del Nodo que tiene la restriccion
            etiquetaStr = obj.nodoObj.obtenerEtiqueta();
            if (isnumeric(etiquetaStr) == 1)
                etiquetaStr = num2str(etiquetaStr);
            end
            
            % Se imprime la etiqueta del Nodo que tiene la restriccion
            fprintf('Etiqueta nodo restringido: %s\n', etiquetaStr);
            
            % Se procede a imprimir los GDL que estan restringidos
            numCrdRest = length(obj.gdlRestringidos);
            gdlID = arrayNum2str(obj.gdlRestringidos, numCrdRest);
            fprintf('GDL Restringidos: %s\n', [gdlID{:}]);
            dispMetodoTEFAME();
            
        end % disp function
        
    end % public methods RestriccionNodo
    
end % class RestriccionNodo