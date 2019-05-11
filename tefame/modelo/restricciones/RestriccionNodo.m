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
%  Properties (Access=private):
%       nodoObj
%       gdlRestringidos
%       valoresRestriccion
%  Methods:
%       restriccionNodoObj = RestriccionNodo(etiquetaRestriccion,nodoObjeto,gdlRestringidosNodo)
%       restriccionNodoObj = RestriccionNodo(etiquetaRestriccion,nodoObjeto,gdlRestringidosNodo,valoresRestrinccionNodo)
%       aplicarRestriccion(restriccionNodoObj)
%       disp(restriccionNodoObj)
%  Methods Suplerclass (ComponenteModelo):
%       etiqueta = obtenerEtiqueta(componenteModeloObj)
%       e = equals(componenteModeloObj,obj)

classdef RestriccionNodo < ComponenteModelo
    
    properties(Access = private)
        nodoObj
        gdlRestringidos
        valoresRestriccion
    end % properties RestriccionNodo
    
    methods
        
        function restriccionNodoObj = RestriccionNodo(etiquetaRestriccion, nodoObjeto, gdlRestringidosNodo, varargin)
            % RestriccionNodo: es el constructor de la clase RestriccionNodo
            % Crea un objeto de la clase RestriccionNodo, con un identificador
            % unico (etiquetaRestriccion), indicando a que nodo restringe (nodoObjeto)
            % y cuales son los grados de libertad que se restringen (gdlRestringidosNodo)
            %
            % restriccionNodoObj = RestriccionNodo(etiquetaRestriccion,nodoObjeto,gdlRestringidosNodo,varargin)
            %
            % Crea un objeto de la clase RestriccionNodo, con un identificador
            % unico (etiquetaRestriccion), indicando a que nodo restringe (nodoObjeto)
            % , cuales son los grados de libertad que se restringen (gdlRestringidosNodo)
            
            if nargin == 0
                etiquetaRestriccion = '';
                nodoObjeto = [];
                gdlRestringidosNodo = [];
            end % if
            
            % Llamamos al constructor de la SuperClass que es la clase ComponenteModelo
            restriccionNodoObj = restriccionNodoObj@ComponenteModelo(etiquetaRestriccion);
            
            % Se guarda el nodo a restringir, y se  coloca como vector
            % columna
            restriccionNodoObj.nodoObj = nodoObjeto;
            if size(gdlRestringidosNodo, 1) == 1
                restriccionNodoObj.gdlRestringidos = gdlRestringidosNodo';
            else
                restriccionNodoObj.gdlRestringidos = gdlRestringidosNodo;
            end % if
            
        end % RestriccionNodo constructor
        
        function aplicarRestriccion(restriccionNodoObj)
            % aplicarRestriccion: es un metodo de la clase RestriccionNodo que
            % se usa para aplicar la restriccion en los nodos
            %
            % aplicarRestriccion(restriccionNodoObj)
            %
            % Aplica la restriccion especificada en RestriccionNodo (restriccionNodoObj)
            % sobre el Nodo en los GDL indicados
            
            % Se extraen los ID del GDL
            gdlID = restriccionNodoObj.nodoObj.obtenerGDLID();
            
            % Se coloca zero en los GDL que se indicaron en la restriccion
            gdlID(restriccionNodoObj.gdlRestringidos, 1) = ...
                zeros(length(restriccionNodoObj.gdlRestringidos), 1);
            
            % Se asigna el nuevo valor de GDLID al Nodo
            restriccionNodoObj.nodoObj.definirGDLID(gdlID);
            
        end % aplicarRestriccion function
        
        function disp(restriccionNodoObj)
            % disp: es un metodo de la clase RestriccionNodo que se usa para
            % imprimir en command Window la informacion del RestriccionNodo
            %
            % disp(restriccionNodoObj)
            %
            % Imprime la informacion guardada en la restriccion (restriccionNodoObj)
            % en pantalla
            
            fprintf('Propiedades restriccion nodo:\n');
            
            disp@ComponenteModelo(restriccionNodoObj);
            
            % Se extrae la etiqueta del Nodo que tiene la restriccion
            etiquetaStr = restriccionNodoObj.nodoObj.obtenerEtiqueta();
            if (isnumeric(etiquetaStr) == 1)
                etiquetaStr = num2str(etiquetaStr);
            end
            
            % Se imprime la etiqueta del Nodo que tiene la restriccion
            fprintf('Etiqueta Nodo restringido: %s\n', etiquetaStr);
            
            % Se procede a imprimir los GDL que estan restringidos
            numCrdRest = length(restriccionNodoObj.gdlRestringidos);
            gdlID = arrayNum2str(restriccionNodoObj.gdlRestringidos, numCrdRest);
            fprintf('GDL Restringidos: %s\n', [gdlID{:}]);
            dispMetodoTEFAME();
            
        end % disp function
        
    end % methods RestriccionNodo
    
end % class RestriccionNodo