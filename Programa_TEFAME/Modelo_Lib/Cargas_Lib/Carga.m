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
%| Clase Carga                                                          |
%|                                                                      |
%| Este archivo contiene la definicion de la Clase Carga                |
%| Carga  es una  subclase  de la  clase ComponenteModelo y corresponde |
%| a la representacion  de una carga en el metodo de elementos  finitos |
%| o analisis matricial de estructuras.                                 |
%| La clase  Carga se usa  como una superclase  para todos los tipos de |
%| cargas a aplicar.                                                    |
%|                                                                      |
%| Programado: FR                                                       |
%| Fecha: 05/08/2015                                                    |
%|                                                                      |
%| Modificado por: FR - 24/10/2016                                      |
%|______________________________________________________________________|
%
%  Properties (Access=private):
%
%  Methods:
%       cargaObj = Carga(etiquetaCarga)
%       aplicarCarga(cargaObj)
%       disp(cargaObj)
%
%  Methods SuperClass (ComponenteModelo):
%       etiqueta = obtenerEtiqueta(componenteModeloObj)


classdef Carga < ComponenteModelo
    
    properties(Access = private)
    end % properties Carga
    
    methods
        
        function cargaObj = Carga(etiquetaCarga)
            % Carga: es el constructor de la clase Carga
            %
            % cargaObj = Carga(etiquetaCarga)
            % Crea un objeto de la clase Carga, con un identificador unico
            % (etiquetaCarga)
            
            if nargin == 0
                % If no argument input we create empty arguments
                etiquetaCarga = '';
            end % if
            
            %Llamamos al cosntructor de la SuperClass que es la clase ComponenteModelo
            cargaObj = cargaObj@ComponenteModelo(etiquetaCarga);
            
        end % Carga constructor
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Metodos para aplicar la Carga sobre la componente que corresponda durante el analisis
        
        function aplicarCarga(cargaObj, varargin) %#ok<INUSD>
            % aplicarCarga: es un metodo de la clase Carga que se usa para aplicar
            % la carga.
            %
            % aplicarCarga(cargaObj)
            % Aplica el carga que estan guardada en el componente que corresponda
            
        end % aplicarCarga function
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Metodos para mostar la informacion de la Carga en pantalla
        
        function disp(cargaObj)
            % disp: es un metodo de la clase Carga que se usa para imprimir en
            % command Window la informacion de la carga aplicada sobre el
            % componente que corresponda
            %
            % disp(patronDeCargasObj)
            % Imprime la informacion guardada en la Carga (cargaObj) en pantalla
            
            disp@ComponenteModelo(cargaObj);
            
        end % disp function
        
    end % methods Carga
    
end % class Carga