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
%| Clase CargaNodo                                                      |
%|                                                                      |
%| Este archivo contiene la definicion de la Clase CargaNodo            |
%| CargaNodo  es  una subclase  de la  clase  Nodo  y corresponde  a la |
%| representacion de una carga nodal en el metodo de elementos  finitos |
%| o analisis matricial de estructuras.                                 |
%| La clase CargaNodo es una clase que contiene el nodo al que se le va |
%| aplicar la carga y el valor de esta carga.                           |
%|                                                                      |
%| Programado: Pablo Pizarro @ppizarror                                 |
%| Fecha: 10/04/2019                                                    |
%|______________________________________________________________________|
%
%  Properties (Access=private):
%       nodoObj
%       vectorCarga
%  Methods:
%       cargaRegistroObj = Carga(etiquetaCarga,nodoObjeto,cargaNodo)
%       aplicarCarga(cargaRegistroObj,factorDeCarga)
%       disp(cargaRegistroObj)
%  Methods SuperClass (Carga):
%  Methods SuperClass (ComponenteModelo):
%       etiqueta = obtenerEtiqueta(componenteModeloObj)

classdef CargaRegistroSismico < Carga
    
    properties(Access = private)
        nodoObj     % Variable que guarda el Nodo que se le va a aplicar la carga
        vectorCarga % Variable que guarda el vector de cargas a aplicar
    end % properties CargaNodo
    
    methods
        
        function cargaRegistroObj = CargaRegistroSismico(etiquetaCargaRegistroSismico, archivoRegistro, nCol, header, dt, tAnalisis)
            % CargaRegistroSismico: es el constructor de la clase CargaNodo
            %
            % cargaRegistroObj = CargaRegistroSismico(etiquetaCargaRegistroSismico, archivoRegistro, nCol, header, dt, tAnalisis)
            
            if nargin == 0
                etiquetaCargaNodo = '';
                nodoObjeto = [];
                cargaNodo = [];
            end % if
            
            % Llamamos al cosntructor de la SuperClass que es la clase Carga
            cargaRegistroObj = cargaRegistroObj@Carga(etiquetaCargaNodo);
            
            cargaRegistroObj.nodoObj = nodoObjeto;
            
            if size(cargaNodo, 1) == 1
                cargaRegistroObj.vectorCarga = cargaNodo';
            else
                cargaRegistroObj.vectorCarga = cargaNodo;
            end % if
            
        end % Carga constructor
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Metodos para aplicar la carga durante el analisis
        
        function aplicarCarga(cargaRegistroObj, factorDeCarga)
            % aplicarCarga: es un metodo de la clase CargaNodo que se usa para aplicar
            % la carga creando el vector de carga P.
            %
            % aplicarCarga(cargaRegistroObj,factorDeCarga)
            % Aplica el vector de carga que esta guardada en el nodo que corresponde
            % amplificada por el factor (factorDeCarga).
            
            cargaRegistroObj.nodoObj.agregarCarga(factorDeCarga*cargaRegistroObj.vectorCarga);
            
        end % aplicarCarga function
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Metodos para mostrar la informacion de la carga en pantalla
        
        function disp(cargaRegistroObj)
            % disp: es un metodo de la clase Carga que se usa para imprimir en
            % command Window la informacion de la carga del tipo registro
            % sismico.
            %
            % disp(cargaRegistroObj)
            % Imprime la informacion guardada en la carga (cargaRegistroObj) en pantalla.
            
            fprintf('Propiedades Carga Registro Sismico:\n');
            disp@Carga(cargaRegistroObj);
            
            fprintf('-------------------------------------------------\n');
            fprintf('\n');
            
        end % disp function
        
    end % methods CargaNodo
    
end % class CargaNodo