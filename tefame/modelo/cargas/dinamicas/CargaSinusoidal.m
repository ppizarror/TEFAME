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
%       CargaSinusoidal(etiquetaCargaSinusoidal,registro,direccion,dt,tAnalisis)
%       aplicarCarga(CargaSinusoidalObj,factorDeCarga)
%       disp(CargaSinusoidalObj)
%       Methods SuperClass (Carga):
%       Methods SuperClass (ComponenteModelo):
%       etiqueta = obtenerEtiqueta(componenteModeloObj)

classdef CargaSinusoidal < CargaDinamica
    
    properties(Access = private)
        registro % Matriz del registro
        direccion % Vector de direcciones
        w % Frecuencia de la carga
        Nodo % Nodo al que se aplica la carga
        amplitud % Amplitud de la carga
        tOscilacion % Tiempo de oscilacion
    end % properties CargaSinusoidal
    
    methods
        
        function CargaSinusoidalObj = CargaSinusoidal(etiquetaCargaSinusoidal, amplitud, w, direccion, dt, Nodo, tOscilacion, tAnalisis)
            % CargaSinusoidal: es el constructor de la clase CargaSinusoidal
            %
            % CargaSinusoidalObj = CargaSinusoidal(etiquetaCargaSinusoidal,amplitud,w,direccion,dt,Nodo,tOscilacion,tAnalisis)
            %
            % Crea una carga del tipo sinusoidal
            
            if nargin == 0
                etiquetaCargaSinusoidal = '';
            end % if
            
            % Llamamos al constructor de la SuperClass que es la clase Carga
            CargaSinusoidalObj = CargaSinusoidalObj@CargaDinamica(etiquetaCargaSinusoidal);
            
            % Guarda los parametros de la carga
            CargaSinusoidalObj.w = w;
            CargaSinusoidalObj.amplitud = amplitud;
            CargaSinusoidalObj.direccion = direccion;
            CargaSinusoidalObj.tOscilacion = tOscilacion;
            CargaSinusoidalObj.tAnalisis = tAnalisis;
            CargaSinusoidalObj.dt = dt;
            CargaSinusoidalObj.Nodo = Nodo; % Numero de nodo donde es aplicada la carga
            
        end % CargaSinusoidal constructor
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Metodos para calcular la carga
        
        function p = calcularCarga(CargaSinusoidalObj, factor, m, r) %#ok<*INUSD,*INUSL>
            % calcularCarga: es un metodo de la clase Carga que se usa para
            % calcular la carga a aplicar
            %
            % calcularCarga(cargaObj,factor,m,r)
            
            % Crea la matriz de carga
            ng = length(m);
            nint = CargaSinusoidalObj.tOscilacion / CargaSinusoidalObj.dt;
            nt = CargaSinusoidalObj.tAnalisis / CargaSinusoidalObj.dt; % Nro de intervalos
            p = zeros(ng, nt);
            
            % Crea el vector de influencia
            rf = zeros(ng, 1);
            if CargaSinusoidalObj.direccion(1) == 1
                rf(2*CargaSinusoidalObj.Nodo-1) = 1;
            elseif CargaSinusoidalObj.direccion(2) == 1
                rf(2*CargaSinusoidalObj.Nodo) = 1;
            end
            
            % Carga Pulso
            t = linspace(0, CargaSinusoidalObj.tOscilacion, nint);
            carga = zeros(1, length(t));
            for i = 1:length(t)
                carga(i) = CargaSinusoidalObj.amplitud * sin(CargaSinusoidalObj.w*t(i));
            end
            
            % Carga
            for i = 1:nt
                if i < length(t)
                    p(:, i) = rf .* CargaSinusoidalObj.Carga(i);
                else
                    break;
                end
            end
            
        end % calcularCarga function
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Metodos para mostrar la informacion de la carga en pantalla
        
        function disp(CargaSinusoidalObj)
            % disp: es un metodo de la clase CargaDinamica que se usa para imprimir en
            % command Window la informacion de la carga del tipo registro
            % sismico
            %
            % disp(CargaSinusoidalObj)
            % Imprime la informacion guardada en la carga (CargaSinusoidalObj) en pantalla
            
            fprintf('Propiedades Carga Registro Sismico:\n');
            disp@CargaDinamica(CargaSinusoidalObj);
            
            fprintf('-------------------------------------------------\n');
            
            fprintf('\n');
            
        end % disp function
        
    end % methods CargaSinusoidal
    
end % class CargaSinusoidal