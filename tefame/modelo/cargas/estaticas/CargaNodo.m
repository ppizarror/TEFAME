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
%| Clase CargaNodo                                                      |
%|                                                                      |
%| Este archivo contiene la definicion de la Clase CargaNodo            |
%| CargaNodo  es  una subclase  de la  clase  Nodo  y corresponde  a la |
%| representacion de una carga nodal en el metodo de elementos  finitos |
%| o analisis matricial de estructuras.                                 |
%| La clase CargaNodo es una clase que contiene el nodo al que se le va |
%| aplicar la carga y el valor de esta carga.                           |
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
%       vectorCarga
%  Methods:
%       obj = Carga(etiquetaCarga,nodoObjeto,cargaNodo)
%       aplicarCarga(obj,factorDeCarga)
%       disp(obj)
%  Methods SuperClass (CargaEstatica):
%       masa = obtenerMasa(obj)
%       definirFactorUnidadMasa(obj,factor)
%       definirFactorCargaMasa(obj,factor)
%       nodos = obtenerNodos(obj)
%  Methods SuperClass (ComponenteModelo):
%       etiqueta = obtenerEtiqueta(obj)
%       e = equals(obj,obj)
%       objID = obtenerIDObjeto(obj)

classdef CargaNodo < CargaEstatica
    
    properties (Access = private)
        nodoObj % Variable que guarda el Nodo que se le va a aplicar la carga
        vectorCarga % Variable que guarda el vector de cargas a aplicar
    end % private properties CargaNodo
    
    methods (Access = public)
        
        function obj = CargaNodo(etiquetaCargaNodo, nodoObjeto, cargaNodo)
            % CargaNodo: es el constructor de la clase CargaNodo
            %
            % Crea un objeto de la clase CargaNodo, con un identificador unico
            % (etiquetaCargaNodo), guarda el nodo que sera cargado y el vector
            % con los valores de la carga a aplicar
            
            if nargin == 0
                etiquetaCargaNodo = '';
                nodoObjeto = [];
                cargaNodo = [];
            end % if
            
            % Llamamos al constructor de la SuperClass que es la clase
            % CargaEstatica
            obj = obj@CargaEstatica(etiquetaCargaNodo);
            
            % Guarda objetos
            obj.nodoObj = nodoObjeto;
            obj.nodosCarga = {nodoObjeto};
            
            if size(cargaNodo, 1) == 1
                obj.vectorCarga = cargaNodo';
            else
                obj.vectorCarga = cargaNodo;
            end % if
            
        end % CargaNodo constructor
        
        function masa = obtenerMasa(obj)
            % obtenerMasa: Obtiene la masa asociada a la carga
            
            masa = abs(sum(obj.vectorCarga)) .* (obj.factorCargaMasa * obj.factorUnidadMasa);
            
        end % obtenerMasa function
        
        function aplicarCarga(obj, factorDeCarga)
            % aplicarCarga: es un metodo de la clase CargaNodo que se usa para aplicar
            % la carga sobre un nodo
            %
            % Aplica el vector de carga que esta guardada en el nodo que corresponde
            % amplificada por el factor (factorDeCarga)
            
            obj.nodoObj.agregarCarga(factorDeCarga*obj.vectorCarga);
            
        end % aplicarCarga function
        
        function disp(obj)
            % disp: es un metodo de la clase Carga que se usa para imprimir en
            % command Window la informacion de la carga aplicada sobre el nodo
            %
            % Imprime la informacion guardada en la carga nodal (obj) en pantalla
            
            fprintf('Propiedades carga nodo:\n');
            disp@CargaEstatica(obj);
            
            numGDL = length(obj.cargas);
            cargaNodo = arrayNum2str(obj.cargas, numGDL);
            fprintf('Cargas: %s\n', [cargaNodo{:}]);
            dispMetodoTEFAME();
            
        end % disp function
        
    end % public methods CargaNodo
    
end % class CargaNodo