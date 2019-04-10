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
%       cargaNodoObj = Carga(etiquetaCarga,nodoObjeto,cargaNodo)
%       aplicarCarga(cargaNodoObj,factorDeCarga)
%       disp(cargaNodoObj)
%  Methods SuperClass (Carga):
%  Methods SuperClass (ComponenteModelo):
%       etiqueta = obtenerEtiqueta(componenteModeloObj)

classdef CargaRegistroSismico < Carga
    
    properties(Access = private)
        nodoObj     % Variable que guarda el Nodo que se le va a aplicar la carga
        vectorCarga % Variable que guarda el vector de cargas a aplicar
    end % properties CargaNodo
    
    methods
        
        function cargaNodoObj = CargaRegistroSismico(etiquetaCargaRegistroSismico, archivoRegistro, nCol, header, dt, tAnalisis)
            % CargaRegistroSismico: es el constructor de la clase CargaNodo
            %
            % cargaNodoObj = CargaNodo(etiquetaCargaNodo,nodoObjeto,cargaNodo)
            % Crea un objeto de la clase CargaNodo, con un identificador unico
            % (etiquetaCargaNodo), guarda el nodo que sera cargado y el vector
            % con los valores de la carga a aplicar.
            
            if nargin == 0
                etiquetaCargaNodo = '';
                nodoObjeto = [];
                cargaNodo = [];
            end % if
            
            % Llamamos al cosntructor de la SuperClass que es la clase Carga
            cargaNodoObj = cargaNodoObj@Carga(etiquetaCargaNodo);
            
            cargaNodoObj.nodoObj = nodoObjeto;
            
            if size(cargaNodo, 1) == 1
                cargaNodoObj.vectorCarga = cargaNodo';
            else
                cargaNodoObj.vectorCarga = cargaNodo;
            end % if
            
        end % Carga constructor
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Metodos para aplicar la Carga Nodal durante el analisis
        
        function aplicarCarga(cargaNodoObj, factorDeCarga)
            % aplicarCarga: es un metodo de la clase CargaNodo que se usa para aplicar
            % la carga sobre un nodo.
            %
            % aplicarCarga(cargaNodoObj,factorDeCarga)
            % Aplica el vector de carga que esta guardada en el nodo que corresponde
            % amplificada por el factor (factorDeCarga).
            
            cargaNodoObj.nodoObj.agregarCarga(factorDeCarga*cargaNodoObj.vectorCarga);
            
        end % aplicarCarga function
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Metodos para mostrar la informacion de la Carga Nodal en pantalla
        
        function disp(cargaNodoObj)
            % disp: es un metodo de la clase Carga que se usa para imprimir en
            % command Window la informacion de la carga aplicada sobre el nodo.
            %
            % disp(cargaNodoObj)
            % Imprime la informacion guardada en la Carga Nodal (cargaObj) en pantalla.
            
            fprintf('Propiedades Carga Nodo:\n');
            disp@Carga(cargaNodoObj);
            
            numGDL = length(cargaNodoObj.cargas);
            cargaNodo = arrayNum2str(cargaNodoObj.cargas, numGDL);
            fprintf('Cargas: %s\n', [cargaNodo{:}]);
            
            fprintf('-------------------------------------------------\n');
            fprintf('\n');
            
        end % disp function
        
    end % methods CargaNodo
    
end % class CargaNodo