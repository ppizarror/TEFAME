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
%  Methods:
%       CargaRegistroSismico(etiquetaCargaRegistroSismico,registro,direccion,dt,tAnalisis)
%       aplicarCarga(cargaRegistroObj,factorDeCarga)
%       disp(cargaRegistroObj)
%  Methods SuperClass (Carga):
%  Methods SuperClass (ComponenteModelo):
%       etiqueta = obtenerEtiqueta(componenteModeloObj)

classdef CargaRegistroSismico < CargaDinamica
    
    properties(Access = private)
        registro % Cell con matrices de registro
        direccion % Vector de direcciones
    end % properties CargaNodo
    
    methods
        
        function cargaRegistroObj = CargaRegistroSismico(etiquetaCargaRegistroSismico, registro, direccion, tAnalisis)
            % CargaRegistroSismico: es el constructor de la clase CargaNodo
            %
            % cargaRegistroObj = CargaRegistroSismico(etiquetaCargaRegistroSismico,registro,direccion,tAnalisis)
            %
            % Crea una carga del tipo registro de aceleracion, requiere un
            % vector registro [Nxr], una direccion [1xr] y un tiempo maximo
            % de analisis, dt lo obtiene del registro
            
            if nargin == 0
                etiquetaCargaRegistroSismico = '';
            end % if
            
            if length(registro) ~= length(direccion)
                error('Cell registro no tiene igual dimension a las direcciones de analisis');
            end
            if ~verificarVectorDireccion(direccion, length(direccion))
                error('Vector direccion mal definido');
            end
            
            % Llamamos al constructor de la SuperClass que es la clase Carga
            cargaRegistroObj = cargaRegistroObj@CargaDinamica(etiquetaCargaRegistroSismico);
            
            % Chequea que el registro en cada direccion no sea nulo
            for k = 1:length(direccion)
                reg = registro{k};
                if direccion(k) ~= 0 && isempty(reg)
                    error('Registro asociado a direccion %d no puede ser nulo', k);
                end
            end
            
            % Calcula el dt
            for k = 1:length(direccion)
                if direccion(k) ~= 0
                    reg = registro{k};
                    dt = reg(2, 1) - reg(1, 1);
                    break;
                end
            end
            
            % Guarda el registro
            cargaRegistroObj.registro = registro;
            cargaRegistroObj.direccion = direccion;
            cargaRegistroObj.tAnalisis = tAnalisis;
            cargaRegistroObj.dt = dt;
            
        end % CargaRegistroSismico constructor
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Metodos para calcular la carga
        
        function p = calcularCarga(cargaRegistroObj, factor, m, r) %#ok<INUSL>
            % calcularCarga: es un metodo de la clase Carga que se usa para
            % calcular la carga a aplicar
            %
            % calcularCarga(cargaObj,factor,m,r)
            
            % Crea la matriz de carga
            ng = length(m);
            nt = cargaRegistroObj.tAnalisis / cargaRegistroObj.dt;
            nd = length(cargaRegistroObj.direccion);
            p = zeros(ng, nt);
            
            % Para cada aceleracion calcula la carga como -m*a
            for k = 1:nd % Recorre direccion
                if cargaRegistroObj.direccion(k) == 0 % Salta direcciones nulas
                    continue;
                end
                reg = cargaRegistroObj.registro{k}; % Registro direccion de estudio
                nct = min(length(reg), nt); % Numero de tiempos en los que se aplica la carga
                for i = 1:nct
                    p(:, i) = p(:, i) + m * r(:, k) .* reg(i, 2);
                end
                fprintf('\t\t\t\tLa carga de la direccion %d es aplicada en %d/%d (%.2f%%) de la matriz de cargas totales\n', ...
                    k, i, nct, (i / nct)*100);
            end
            
        end % calcularCarga function
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Metodos para mostrar la informacion de la carga en pantalla
        
        function disp(cargaRegistroSismicoObj)
            % disp: es un metodo de la clase CargaRegistroSismico que se usa para imprimir en
            % command Window la informacion de la carga del tipo registro
            % sismico
            %
            % disp(cargaRegistroSismicoObj)
            % Imprime la informacion guardada en la carga (cargaRegistroSismicoObj) en pantalla
            
            fprintf('Propiedades Carga Registro Sismico:\n');
            disp@CargaDinamica(cargaRegistroSismicoObj);
            
            fprintf('-------------------------------------------------\n');
            fprintf('\n');
            
        end % disp function
        
    end % methods CargaRegistroSismico
    
end % class CargaRegistroSismico