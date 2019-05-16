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
%| Clase CargaEstatica                                                  |
%|                                                                      |
%| Este archivo contiene la definicion de la Clase Carga Estatica       |
%| Carga  es una  subclase  de la  clase ComponenteModelo y corresponde |
%| a la representacion  de una carga en el metodo de elementos  finitos |
%| o analisis matricial de estructuras.                                 |
%| La clase  Carga se usa  como una superclase  para todos los tipos de |
%| cargas estaticas a aplicar.                                          |
%|                                                                      |
%| Programado: FR                                                       |
%| Fecha: 05/08/2015                                                    |
%|                                                                      |
%| Modificado por: FR - 24/10/2016                                      |
%|                 Pablo Pizarro @ppizarror - 10/04/2019                |
%|______________________________________________________________________|
%
%  Properties (Access=private):
%       cargaSumoMasa
%  Properties (Access=protected)
%       factorCargaMasa
%       factorUnidadMasa
%       nodosCarga
%  Methods:
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
        cargaSumoMasa % Indica que la carga ya sumo masa
    end % properties CargaEstatica
    
    properties(Access = protected)
        factorCargaMasa % Factor de masa de la carga
        factorUnidadMasa % Factor unidad de la masa
        nodosCarga % Nodos que comparten la carga
    end
    
    methods
        
        function obj = CargaEstatica(etiquetaCarga)
            % CargaEstatica: es el constructor de la clase CargaEstatica
            %
            % Crea un objeto de la clase CargaEstatica, con un identificador unico
            % (etiquetaCarga)
            
            if nargin == 0
                etiquetaCarga = '';
            end % if
            
            % Llamamos al constructor de la SuperClass que es la clase ComponenteModelo
            obj = obj@ComponenteModelo(etiquetaCarga);
            obj.factorCargaMasa = 0;
            obj.factorUnidadMasa = 1;
            obj.cargaSumoMasa = false;
            
        end % Carga constructor
        
        function bloquearCargaMasa(obj)
            % bloquearCargaMasa: La carga deja de sumar masa
           
            obj.cargaSumoMasa = true;
            
        end % bloquearCargaMasa function
        
        function c = cargaSumaMasa(obj)
            % cargaSumaMasa: Indica que la carga suma masa al sistema
            
            c = ~obj.cargaSumoMasa;
            
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
        
    end % methods CargaEstatica
    
end % class CargaEstatica