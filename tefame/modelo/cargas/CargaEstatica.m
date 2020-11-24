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
%| Clase CargaEstatica                                                  |
%|                                                                      |
%| Este archivo contiene la definicion de la Clase Carga Estatica       |
%| Carga  es una  subclase  de la  clase ComponenteModelo y corresponde |
%| a la representacion  de una carga en el metodo de elementos  finitos |
%| o analisis matricial de estructuras.                                 |
%|                                                                      |
%| La clase  Carga se usa  como una superclase  para todos los tipos de |
%| cargas estaticas a aplicar.                                          |
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
%       aplicarCarga(obj)
%       obj = Carga(etiquetaCarga)
%       definirFactorCargaMasa(obj,factor)
%       definirFactorUnidadMasa(obj,factor)
%       disp(obj)
%       masa = obtenerMasa(obj)
%       nodos = obtenerNodos(obj)
%  Methods SuperClass (ComponenteModelo):
%       etiqueta = obtenerEtiqueta(obj)
%       e = equals(obj,obj)
%       objID = obtenerIDObjeto(obj)

classdef CargaEstatica < ComponenteModelo
    
    properties(Access = private)
        cargaActiva % La carga esta activa
        cargaSumoMasa % Indica que la carga ya sumo masa
    end % private properties CargaEstatica
    
    properties(Access = protected)
        factorCargaMasa % Factor de masa de la carga
        factorUnidadMasa % Factor unidad de la masa
        nodosCarga % Nodos que comparten la carga
    end % protected properties CargaEstatica
    
    methods(Access = public)
        
        function obj = CargaEstatica(etiquetaCarga)
            % CargaEstatica: es el constructor de la clase CargaEstatica
            %
            % Crea un objeto de la clase CargaEstatica, con un identificador unico
            % (etiquetaCarga)
            
            if nargin == 0
                etiquetaCarga = '';
            end
            
            % Llamamos al constructor de la SuperClass que es la clase ComponenteModelo
            obj = obj@ComponenteModelo(etiquetaCarga);
            obj.cargaActiva = true;
            obj.cargaSumoMasa = true;
            obj.factorCargaMasa = 0;
            obj.factorUnidadMasa = 1;
            
        end % Carga constructor
        
        function bloquearCargaMasa(obj)
            % bloquearCargaMasa: La carga deja de sumar masa
            
            obj.cargaSumoMasa = false;
            
        end % bloquearCargaMasa function
        
        function c = cargaSumaMasa(obj)
            % cargaSumaMasa: Indica que la carga suma masa al sistema
            
            c = obj.cargaSumoMasa;
            
        end % cargaSumaMasa function
        
        function aplicarCarga(obj, varargin) %#ok<*VANUS,INUSD>
            % aplicarCarga: es un metodo de la clase CargaEstatica que se usa
            % para aplicar la carga
            %
            % Aplica el carga que estan guardada en el componente que corresponda
            
        end % aplicarCarga function
        
        function disp(obj)
            % disp: es un metodo de la clase CargaEstatica que se usa para imprimir en
            % command Window la informacion de la carga aplicada sobre el
            % componente que corresponda
            %
            % Imprime la informacion guardada en la carga (obj) en pantalla
            
            disp@ComponenteModelo(obj);
            % No usar dispMetodoTEFAME()
            
        end % disp function
        
        function masa = obtenerMasa(obj)
            % obtenerMasa: Obtiene la masa de la carga
            
            masa = [] .* (obj.factorCargaMasa * obj.factorUnidadMasa);
            
        end % obtenerMasa function
        
        function definirFactorUnidadMasa(obj, factor)
            % definirFactorUnidadMasa: Define el factor de conversion de
            % unidades de la carga a unidades de masa
            
            obj.factorUnidadMasa = factor;
            
        end % definirFactorUnidadMasa function
        
        function definirFactorCargaMasa(obj, factor)
            % definirFactorCargaMasa: Define cuanto porcentaje de la carga
            % se convierte en masa
            
            obj.factorCargaMasa = factor;
            
        end % definirFactorCargaMasa function
        
        function nodos = obtenerNodos(obj)
            % obtenerNodos: Retorna los nodos de la carga
            
            nodos = obj.nodosCarga;
            
        end % obtenerNodos function
        
        function y = cargaActivada(obj)
            % cargaActivada: Indica si la carga esta activada para el
            % analisis
            
            y = obj.cargaActiva;
            
        end % cargaActivada function
        
        function desactivarCarga(obj)
            % desactivarCarga: Desactiva la carga para el analisis
            
            obj.cargaActiva = false;
            
        end % desactivarCarga function
        
    end % public methods CargaEstatica
    
end % class CargaEstatica