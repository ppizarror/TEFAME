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
%  Methods:
%       cargaEstaticaObj = Carga(etiquetaCarga)
%       aplicarCarga(cargaEstaticaObj)
%       disp(cargaEstaticaObj)
%       masa = obtenerMasa(cargaEstaticaObj)
%       definirFactorUnidadMasa(cargaEstaticaObj,factor)
%       definirFactorCargaMasa(cargaEstaticaObj,factor)
%       nodos = obtenerNodos(cargaEstaticaObj)
%  Methods SuperClass (ComponenteModelo):
%       etiqueta = obtenerEtiqueta(componenteModeloObj)
%       e = equals(componenteModeloObj,obj)
%       objID = obtenerIDObjeto(componenteModeloObj)

classdef CargaEstatica < ComponenteModelo
    
    properties(Access = private)
    end % properties CargaEstatica
    
    properties(Access = protected)
        factorCargaMasa % Factor de masa de la carga
        factorUnidadMasa % Factor unidad de la masa
        nodosCarga % Nodos que comparten la carga
    end
    
    methods
        
        function cargaEstaticaObj = CargaEstatica(etiquetaCarga)
            % CargaEstatica: es el constructor de la clase CargaEstatica
            %
            % cargaEstaticaObj = CargaEstatica(etiquetaCarga)
            %
            % Crea un objeto de la clase CargaEstatica, con un identificador unico
            % (etiquetaCarga)
            
            if nargin == 0
                etiquetaCarga = '';
            end % if
            
            % Llamamos al constructor de la SuperClass que es la clase ComponenteModelo
            cargaEstaticaObj = cargaEstaticaObj@ComponenteModelo(etiquetaCarga);
            cargaEstaticaObj.factorCargaMasa = 0;
            cargaEstaticaObj.factorUnidadMasa = 1;
            
        end % Carga constructor
        
        function aplicarCarga(cargaEstaticaObj, varargin) %#ok<*VANUS,INUSD>
            % aplicarCarga: es un metodo de la clase CargaEstatica que se usa
            % para aplicar la carga
            %
            % aplicarCarga(cargaEstaticaObj)
            %
            % Aplica el carga que estan guardada en el componente que corresponda
            
        end % aplicarCarga function
        
        function disp(cargaEstaticaObj)
            % disp: es un metodo de la clase CargaEstatica que se usa para imprimir en
            % command Window la informacion de la carga aplicada sobre el
            % componente que corresponda
            %
            % disp(cargaEstaticaObj)
            %
            % Imprime la informacion guardada en la carga (cargaEstaticaObj) en pantalla
            
            disp@ComponenteModelo(cargaEstaticaObj);
            % No usar dispMetodoTEFAME()
            
        end % disp function
        
        function masa = obtenerMasa(cargaEstaticaObj)
            % obtenerMasa: Obtiene la masa de la carga
            %
            % masa = obtenerMasa(cargaEstaticaObj)
            
            masa = [] .* (cargaEstaticaObj.factorCargaMasa * cargaEstaticaObj.factorUnidadMasa);
            
        end % obtenerMasa function
        
        function definirFactorUnidadMasa(cargaEstaticaObj, factor)
            % definirFactorUnidadMasa: Define el factor de conversion de
            % unidades de la carga a unidades de masa
            
            cargaEstaticaObj.factorUnidadMasa = factor;
            
        end % definirFactorUnidadMasa function
        
        function definirFactorCargaMasa(cargaEstaticaObj, factor)
            % definirFactorCargaMasa: Define cuanto porcentaje de la carga
            % se convierte en masa
            
            cargaEstaticaObj.factorCargaMasa = factor;
            
        end % definirFactorCargaMasa function
        
        function nodos = obtenerNodos(cargaEstaticaObj)
            % obtenerNodos: Retorna los nodos de la carga
            %
            % nodos = obtenerNodos(cargaEstaticaObj)
            
            nodos = cargaEstaticaObj.nodosCarga;
            
        end % obtenerNodos function
        
    end % methods CargaEstatica
    
end % class CargaEstatica