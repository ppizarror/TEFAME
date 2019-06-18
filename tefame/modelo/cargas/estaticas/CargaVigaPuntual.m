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
%| Clase CargaVigaPuntual                                               |
%|                                                                      |
%| Este archivo contiene la definicion de la Clase CargaVigaPuntual     |
%| CargaVigaPuntual es una subclase de la clase CargaEstatica y         |
%| corresponde a la representacion de una carga puntual en un elemento  |
%| tipo Viga.                                                           |
%| La clase CargaVigaPuntual es una clase que contiene el elemento al   |
%| al que se le va a aplicar la carga, el valor de esta carga y la      |
%| distancia a uno de los nodos como porcentaje del largo.              |
%|                                                                      |
%| Programado: Pablo Pizarro @ppizarror.com                             |
%| Fecha: 14/05/2018                                                    |
%|______________________________________________________________________|
%
%  Methods(Access=public):
%       obj = CargaVigaPuntual(etiquetaCarga,elemObjeto,carga,distancia)
%       aplicarCarga(obj,factorDeCarga)
%       disp(obj)
%  Methods SuperClass (CargaEsatica):
%       masa = obtenerMasa(obj)
%       definirFactorUnidadMasa(obj,factor)
%       definirFactorCargaMasa(obj,factor)
%       nodos = obtenerNodos(obj)
%  Methods SuperClass (ComponenteModelo):
%       etiqueta = obtenerEtiqueta(obj)
%       e = equals(obj,obj)
%       objID = obtenerIDObjeto(obj)

classdef CargaVigaPuntual < CargaEstatica
    
    properties(Access = private)
        carga % Valor de la carga
        dist % Distancia de la carga al primer nodo del elemento
        elemObj % Variable que guarda el elemento que se le va a aplicar la carga
    end % private properties CargaVigaPuntual
    
    methods(Access = public)
        
        function obj = CargaVigaPuntual(etiquetaCarga, elemObjeto, carga, distancia)
            % CargaVigaPuntual: es el constructor de la clase CargaVigaPuntual
            %
            % Crea un objeto de la clase CargaVigaPuntual, en donde toma como atributo
            % el objeto a aplicar la carga, la distancia como porcentaje
            % del largo del elemento con respecto al primer nodo y el
            % elemento tipo viga
            
            if nargin == 0
                carga = 0;
                distancia = 0;
                elemObjeto = [];
                etiquetaCarga = '';
            end
            
            % Llamamos al constructor de la SuperClass que es la clase Carga
            obj = obj@CargaEstatica(etiquetaCarga);
            
            % Guarda los valores
            obj.carga = carga;
            obj.dist = distancia * elemObjeto.obtenerLargo();
            obj.elemObj = elemObjeto;
            obj.nodosCarga = elemObjeto.obtenerNodos();
            
        end % CargaVigaPuntual constructor
        
        function [v1, v2, theta1, theta2] = calcularCarga(obj)
            % calcularCarga: Calcula la carga
            
            % Largo de la viga
            L = obj.elemObj.obtenerLargo();
            
            % Posicion de la carga
            d = obj.dist;
            
            % Carga
            P = obj.carga;
            
            % Se calculan apoyos y reacciones en un caso de viga empotrada
            % sometida a una carga P aplicada a (L-d) de un apoyo y d del
            % otro. Esto se hizo al no tener la funcion dirac(x) y
            % distintos errores fruto de la evaluacion de la integral. El
            % caso con las funciones de interpolacion N1..N4 se realizo
            % correctamente para el caso de la carga distribuida
            v1 = P * ((L - d)^2 / L^2) * (3 - 2 * (L - d) / L);
            v2 = P * (d^2 / L^2) * (3 - 2 * d / L);
            theta1 = P * d * (L - d)^2 / (L^2);
            theta2 = -P * (d^2) * (L - d) / (L^2);
            
        end % calcularCarga function
        
        function masa = obtenerMasa(obj)
            % obtenerMasa: Obtiene la masa asociada a la carga
            
            [v1, v2, ~, ~] = obj.calcularCarga();
            masa = abs(v1+v2) .* (obj.factorCargaMasa * obj.factorUnidadMasa);
            
        end % obtenerMasa function
        
        function aplicarCarga(obj, factorDeCarga)
            % aplicarCarga: es un metodo de la clase CargaVigaPuntual que se usa para aplicar
            % la carga sobre los dos nodos del elemento
            
            % Calcula la carga
            [v1, v2, theta1, theta2] = obj.calcularCarga();
            vectorCarga1 = factorDeCarga * [0, v1, theta1]';
            vectorCarga2 = factorDeCarga * [0, v2, theta2]';
            obj.elemObj.sumarFuerzaEquivalente([ ...
                vectorCarga1(2), vectorCarga1(3), vectorCarga2(2), vectorCarga2(3)]');
            
            % Aplica vectores de carga
            nodos = obj.elemObj.obtenerNodos();
            nodos{1}.agregarCarga(vectorCarga1);
            nodos{2}.agregarCarga(vectorCarga2);
            
        end % aplicarCarga function
        
        function disp(obj)
            % disp: es un metodo de la clase CargaVigaPuntual que se usa para imprimir en
            % command Window la informacion de la carga aplicada sobre el
            % elemento
            %
            % Imprime la informacion guardada en la carga puntual de la
            % Viga (obj) en pantalla
            
            fprintf('Propiedades carga viga puntual:\n');
            disp@CargaEstatica(obj);
            
            % Obtiene la etiqueta del elemento
            etiqueta = obj.elemObj.obtenerEtiqueta();
            
            % Obtiene la etiqueta del primer nodo
            nodo1etiqueta = obj.elemObj.obtenerNodos();
            nodo1etiqueta = nodo1etiqueta{1}.obtenerEtiqueta();
            
            fprintf('\tCarga: %.3f aplicada en Elemento: %s a %.3f del Nodo: %s\n', ...
                obj.carga, etiqueta, obj.dist, nodo1etiqueta);
            dispMetodoTEFAME();
            
        end % disp function
        
    end % public methods CargaVigaPuntual
    
end % class CargaVigaPuntual