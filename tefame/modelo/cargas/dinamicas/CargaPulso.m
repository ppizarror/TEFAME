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
%       CargaPulso(etiquetaCargaPulso,registro,direccion,dt,tAnalisis)
%       aplicarCarga(CargaPulsoObj,factorDeCarga)
%       disp(CargaPulsoObj)
%       Methods SuperClass (Carga):
%       Methods SuperClass (ComponenteModelo):
%       etiqueta = obtenerEtiqueta(componenteModeloObj)

classdef CargaPulso < CargaDinamica
    
    properties(Access = private)
        registro % Matriz del registro
        direccion % Vector de direcciones
        tpulso
        intervalos
        Nodo
        amplitud
        Carga
    end % properties CargaPulso
    
    methods
        
        function CargaPulsoObj = CargaPulso(etiquetaCargaPulso, amplitud, tpulso, direccion, intervalos, Nodo, tAnalisis)
            % CargaPulso: es el constructor de la clase CargaPulso
            %
            % CargaPulsoObj = CargaPulso(etiquetaCargaPulso, amplitud, tpulso, direccion, intervalos, Nodo)
            %
            % Crea una carga tipo pulso.
            
            if nargin == 0
                etiquetaCargaPulso = '';
            end % if
            
            % Llamamos al constructor de la SuperClass que es la clase Carga
            CargaPulsoObj = CargaPulsoObj@CargaDinamica(etiquetaCargaPulso);
            
            % Guarda el registro
            CargaPulsoObj.tpulso = tpulso;
            CargaPulsoObj.amplitud = amplitud;
            CargaPulsoObj.direccion = direccion;
            CargaPulsoObj.intervalos = intervalos;
            CargaPulsoObj.tAnalisis = tAnalisis;
            CargaPulsoObj.dt = tpulso / intervalos;
            CargaPulsoObj.Nodo = Nodo; %Numero de nodo donde es aplicada la carga
            
        end % CargaPulso constructor
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Metodos para calcular la carga
        
        function p = calcularCarga(CargaPulsoObj, factor, m, r) %#ok<INUSD,INUSL>
            % calcularCarga: es un metodo de la clase Carga que se usa para
            % calcular la carga a aplicar.
            %
            % calcularCarga(cargaObj,factor,m,r)
            
            % Crea la matriz de carga
            ng = length(m);
            nt = CargaPulsoObj.tAnalisis / CargaPulsoObj.dt;
            p = zeros(ng, nt);

            % Crea el vector de influencia
            
            rf = zeros(ng, 1);
            
            if CargaPulsoObj.direccion(1) == 1
                rf(2 * CargaPulsoObj.Nodo - 1) = 1;
            elseif CargaPulsoObj.direccion(2) == 1
                rf(2 * CargaPulsoObj.Nodo) = 1;
            end
            
            % Carga Pulso
            
            t = linspace(0,pi,CargaPulsoObj.intervalos);
            w = pi / CargaPulsoObj.tpulso;
            
            for i = 1:length(t)         
                CargaPulsoObj.Carga(i) = CargaPulsoObj.amplitud * sin(w * t(i));
            end
            
            % Carga       
            for i = 1:nt
                if i < length(t)
%                 k =jjj
                p(:, i) = rf .* CargaPulsoObj.Carga(i);
                else 
                    break
                end
            end
            
        end % calcularCarga function
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Metodos para mostrar la informacion de la carga en pantalla
        
        function disp(CargaPulsoObj)
            % disp: es un metodo de la clase CargaPulso que se usa para imprimir en
            % command Window la informacion de la carga del tipo registro
            % sismico.
            %
            % disp(CargaPulsoObj)
            % Imprime la informacion guardada en la carga (CargaPulsoObj) en pantalla.
            
            fprintf('Propiedades Carga Pulso:\n');
            disp@CargaDinamica(CargaPulsoObj);
            
            fprintf('-------------------------------------------------\n');

            fprintf('\n');
            
        end % disp function
        
    end % methods CargaPulso
    
end % class CargaPulso