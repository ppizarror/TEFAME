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
%| Clase CombinacionCargas                                              |
%|                                                                      |
%| Este archivo contiene la definicion de la Clase CombinacionCargas    |
%| CombinacionCargas es una subclase  de la clase ComponenteModelo y    |
%| corresponde a la representacion de una combinacion de cargas en el   |
%| metodo de elementos  finitos o analisis matricial de estructuras.    |
%|                                                                      |
%| Programado: Pablo Pizarro @ppizarror                                 |
%| Fecha: 08/05/2019                                                    |
%|______________________________________________________________________|
%
%  Properties (Access=private):
%       cargas
%  Methods:
%       combinacionCargaObj = CombinacionCargas(etiquetaCombinacion,cargas)
%       aplicarCarga(cargaObj)
%       disp(cargaObj)
%  Methods SuperClass (ComponenteModelo):
%       etiqueta = obtenerEtiqueta(componenteModeloObj)
%       e = equals(componenteModeloObj,obj)

classdef CombinacionCargas < ComponenteModelo
    
    properties(Access = private)
        cargas % Arreglo de cargas
    end % properties CombinacionCargas
    
    methods
        
        function combinacionCargaObj = CombinacionCargas(etiquetaCombinacion, cargas)
            % CombinacionCargas: Es el constructor de la clase, requiere el
            % nombre de la combinacion y un cell de cargas
            %
            % combinacionCargaObj = CombinacionCargas(etiquetaCombinacion,cargas)
            
            if nargin == 0
                etiquetaCombinacion = '';
            end % if
            
            % Llamamos al constructor de la SuperClass que es la clase ComponenteModelo
            combinacionCargaObj = combinacionCargaObj@ComponenteModelo(etiquetaCombinacion);
            
            % Guarda datos
            combinacionCargaObj.cargas = cargas;
            
        end % CombinacionCargas constructor
        
        function p = obtenerCarga(combinacionCargaObj)
            % obtenerCarga: Obtiene la carga generada
            %
            % obtenerCarga(combinacionCargaObj)
            
            p = combinacionCargaObj.sol_p;
            
        end % obtenerCarga function
        
        function u = obtenerDesplazamiento(combinacionCargaObj)
            % obtenerDesplazamiento: Obtiene el desplazamiento de la carga
            %
            % obtenerDesplazamiento(combinacionCargaObj)
            
            u = combinacionCargaObj.sol_u;
            
        end % obtenerDesplazamiento function
        
        function u = obtenerDesplazamientoTiempo(combinacionCargaObj, gdl, tiempo)
            % obtenerDesplazamientoTiempo obtiene el desplazamiento de un
            % grado de libertad en un determinado tiempo
            %
            % u = obtenerDesplazamientoTiempo(combinacionCargaObj,gdl,tiempo)
            
            if tiempo < 0 % Retorna el maximo
                u = max(combinacionCargaObj.sol_u(gdl, :));
            else
                u = combinacionCargaObj.sol_u(gdl, tiempo);
            end
            
        end % obtenerDesplazamientoTiempo function
        
        function v = obtenerVelocidad(combinacionCargaObj)
            % obtenerVelocidad: Obtiene la velocidad de la carga
            %
            % obtenerVelocidad(combinacionCargaObj)
            
            v = combinacionCargaObj.sol_v;
            
        end % obtenerVelocidad function
        
        function a = obtenerAceleracion(combinacionCargaObj)
            % obtenerAceleracion: Obtiene la aceleracion de la carga
            %
            % obtenerAceleracion(combinacionCargaObj)
            
            a = combinacionCargaObj.sol_a;
            
        end % obtenerAceleracion function
        
        function disp(combinacionCargaObj)
            % disp: es un metodo de la clase CombinacionCarga que se usa
            % para imprimir en command Window la informacion de la
            % combinacion de cargas
            %
            % disp(combinacionCargaObj)
            
            fprintf('Propiedades combinacion cargas:\n');
            disp@ComponenteModelo(combinacionCargaObj);
            
            fprintf('Cargas del modelo:');
            for i=1:length(combinacionCargaObj.cargas)
                fprintf('\t%s', combinacionCargaObj.cargas.obtenerEtiqueta());
            end
            
            fprintf('-------------------------------------------------\n');
            fprintf('\n');
            
        end % disp function
        
    end % methods Carga
    
end % class Carga