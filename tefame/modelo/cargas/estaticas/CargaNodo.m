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
%| Clase CargaNodo                                                      |
%|                                                                      |
%| Este archivo contiene la definicion de la Clase CargaNodo            |
%| CargaNodo  es  una subclase  de la  clase  Nodo  y corresponde  a la |
%| representacion de una carga nodal en el metodo de elementos  finitos |
%| o analisis matricial de estructuras.                                 |
%|                                                                      |
%| La clase CargaNodo es una clase que contiene el nodo al que se le va |
%| aplicar la carga y el valor de esta carga.                           |
%|______________________________________________________________________|
%|                                                                      |
%| MIT License                                                          |
%| Copyright (c) 2018-2019 Pablo Pizarro R @ppizarror.com.              |
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
    
    properties(Access = private)
        nodoObj % Variable que guarda el Nodo que se le va a aplicar la carga
        vectorCarga % Variable que guarda el vector de cargas a aplicar
    end % private properties CargaNodo
    
    methods(Access = public)
        
        function obj = CargaNodo(etiquetaCargaNodo, nodoObjeto, cargaNodo)
            % CargaNodo: es el constructor de la clase CargaNodo
            %
            % Crea un objeto de la clase CargaNodo, con un identificador unico
            % (etiquetaCargaNodo), guarda el nodo que sera cargado y el vector
            % con los valores de la carga a aplicar
            
            if nargin == 0
                cargaNodo = [];
                etiquetaCargaNodo = '';
                nodoObjeto = [];
            end
            
            if ~isa(nodoObjeto, 'Nodo')
                error('Objeto de la carga no es un Nodo @CargaNodo %s', etiquetaCarga);
            end
            
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
            end
            
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
            
            numGDL = length(obj.vectorCarga);
            cargaNodo = arrayNum2str(obj.vectorCarga, numGDL);
            fprintf('Cargas: %s\n', [cargaNodo{:}]);
            dispMetodoTEFAME();
            
        end % disp function
        
    end % public methods CargaNodo
    
end % class CargaNodo