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
%| Clase CargaMembranaDistribuida                                       |
%|                                                                      |
%| Este archivo contiene la definicion de la Clase CargaMembranaDistribuida |
%| CargaMembranaDistribuida es una subclase de la clase Carga y corresponde |
%| a la representacion de una carga distribuida en un elemento tipo     |
%| Membrana.                                                            |
%| La clase CargaMembranaDistribuida es una clase que contiene el       |
%| elemento al que se le va a aplicar la carga, los nodos al que se     |
%| aplica las cargas y las distancias de las dos cargas.                |
%|                                                                      |
%| Programado: Pablo Pizarro @ppizarror.com                             |
%| Fecha: 28/08/2018                                                    |
%|______________________________________________________________________|
%
%  Methods(Access=public):
%       obj = CargaMembranaDistribuida(etiquetaCarga,elemObjeto,nodo1,nodo2,carga1,distancia1,carga2,distancia2)
%       aplicarCarga(obj,factorDeCarga)
%       disp(obj)
%  Methods SuperClass (CargaEstatica):
%       masa = obtenerMasa(obj)
%       definirFactorUnidadMasa(obj,factor)
%       definirFactorCargaMasa(obj,factor)
%       nodos = obtenerNodos(obj)
%  Methods SuperClass (ComponenteModelo):
%       etiqueta = obtenerEtiqueta(obj)
%       e = equals(obj,obj)
%       objID = obtenerIDObjeto(obj)

classdef CargaMembranaDistribuida < CargaEstatica
    
    properties(Access = private)
        carga1 % Valor de la carga 1
        carga2 % Valor de la carga 2
        dist1 % Distancia de la carga 1 al primer nodo del elemento
        dist2 % Distancia de la carga 2 al primer nodo del elemento
        elemObj % Variable que guarda el elemento que se le va a aplicar la carga
        L % Largo de aplicacion de las cargas
        nodo1 % Nodo 1 de aplicacion
        nodo2 % Nodo 2 de aplicacion
        theta % Angulo de aplicacion
    end % private properties CargaMembranaDistribuida
    
    methods(Access = public)
        
        function obj = CargaMembranaDistribuida(etiquetaCarga, elemObjeto, ...
                nodo1, nodo2, carga1, distancia1, carga2, distancia2)
            % CargaMembranaDistribuida: es el constructor de la clase
            % CargaMembranaDistribuida
            %
            % Crea un objeto de la clase Carga, en donde toma como atributo
            % el objeto a aplicar la carga, las cargas y las distancias de
            % aplicacion
            % La enumeracion de los nodos de la membrana corresponde a:
            %
            %       4 ------------- 3
            %       |               |
            %       |               |
            %       |               |
            %       1 ------------- 2
            %
            % No se pueden aplicar cargas cruzadas, ie solo se permiten las
            % combinaciones 1-2, 2-3, 3-4 o 1-4
            
            if nargin == 0
                carga1 = 0;
                carga2 = 0;
                distancia1 = 0;
                distancia2 = 0;
                elemObjeto = [];
                etiquetaCarga = '';
            end
            
            % Llamamos al constructor de la SuperClass que es la clase
            % CargaEstatica
            obj = obj@CargaEstatica(etiquetaCarga);
            
            % Verifica que se cumplan los nodos
            if abs(nodo1-nodo2) == 2
                error('Nodo no puede ser cruzado @CargaMembranaDistribuida %s', etiquetaCarga);
            end
            if (nodo1 < 1 || nodo1 > 4 || nodo2 < 1 || nodo2 > 4)
                error('Etiqueta nodo invalido, debe ser entre 1 y 4 @CargaMembranaDistribuida %s', etiquetaCarga);
            end
            
            % Aplica limites al minimo y maximo
            if (distancia1 < 0 || distancia1 > 1 || distancia2 > 1 || distancia2 < 0)
                warning('Distancias deben estar dentro del rango [0, 1] @CargaVigaColumnaDistribuida %s', etiquetaCarga);
            end
            if (distancia1 == distancia2)
                warning('Distancias son iguales @CargaVigaColumnaDistribuida %s', etiquetaCarga);
            end
            distancia1 = max(0, min(distancia1, 1));
            distancia2 = min(1, max(distancia2, 0));
            
            % Obtiene el largo entre los nodos
            nodoMembrana = elemObjeto.obtenerNodos();
            membranaNodo1 = nodoMembrana{nodo1}.obtenerCoordenadas();
            membranaNodo2 = nodoMembrana{nodo2}.obtenerCoordenadas();
            largo = sqrt((membranaNodo1(1) - membranaNodo2(1))^2+(membranaNodo1(2) - membranaNodo2(2))^2);
            
            % Calcula el angulo de aplicacion, puede ser 0 (en eje y) o 90 (eje x)
            dx = (membranaNodo2(1) - membranaNodo1(1));
            dy = (membranaNodo2(2) - membranaNodo1(2));
            obj.theta = atan(dy/dx);
            
            % Guarda los valores
            obj.elemObj = elemObjeto;
            obj.L = largo;
            
            obj.carga1 = carga1;
            obj.dist1 = distancia1 * largo;
            obj.nodo1 = nodo1;
            
            obj.carga2 = carga2;
            obj.dist2 = distancia2 * largo;
            obj.nodo2 = nodo2;
            
            obj.nodosCarga = {nodo1, nodo2};
            
        end % CargaMembranaDistribuida constructor
        
        function [v1, v2] = calcularCarga(obj)
            % calcularCarga: Calcula la carga
            
            % Limites de las cargas
            d1 = obj.dist1;
            d2 = obj.dist2;
            
            % Cargas
            P1 = obj.carga1;
            P2 = obj.carga2;
            
            % Crea funcion de carga distribuida
            rho = @(x) P1 + (x - d1) * ((P2 - P1) / d2);
            
            % Funciones de interpolacion
            N1 = @(x) 1 - 3 * (x / obj.L).^2 + 2 * (x / obj.L).^3;
            N3 = @(x) 3 * (x / obj.L).^2 - 2 * (x / obj.L).^3;
            
            % Calcula cada valor
            v1 = integral(@(x) rho(x).*N1(x), d1, d2);
            v2 = integral(@(x) rho(x).*N3(x), d1, d2);
            
        end % calcularCarga function
        
        function masa = obtenerMasa(obj)
            % obtenerMasa: Obtiene la masa asociada a la carga
            
            [v1, v2] = obj.calcularCarga();
            masa = abs(v1+v2) .* (obj.factorCargaMasa * obj.factorUnidadMasa);
            
        end % obtenerMasa function
        
        function aplicarCarga(obj, factorDeCarga)
            % aplicarCarga: es un metodo de la clase obj
            % que se usa para aplicar la carga sobre los dos nodos
            % correspondientes del elemento
            
            % Calcula la carga
            [v1, v2] = obj.calcularCarga();
            
            % Aplica el angulo
            v1x = v1 * sin(obj.theta);
            v1y = v1 * cos(obj.theta);
            v2x = v2 * sin(obj.theta);
            v2y = v2 * cos(obj.theta);
            
            vectorCarga1 = factorDeCarga * [v1x, v1y]';
            vectorCarga2 = factorDeCarga * [v2x, v2y]';
            
            % Aplica fuerzas equivalentes;
            obj.elemObj.sumarFuerzaEquivalente(obj.nodo1, vectorCarga1');
            obj.elemObj.sumarFuerzaEquivalente(obj.nodo2, vectorCarga2');
            
            % Aplica vectores de carga
            nodos = obj.elemObj.obtenerNodos();
            nodos{obj.nodo1}.agregarCarga(vectorCarga1);
            nodos{obj.nodo2}.agregarCarga(vectorCarga2);
            
        end % aplicarCarga function
        
        function disp(obj)
            % disp: es un metodo de la clase Carga que se usa para imprimir en
            % command Window la informacion de la carga aplicada sobre el
            % elemento membrana
            %
            % Imprime la informacion guardada en la carga distribuida de la
            % membrana (obj) en pantalla
            
            fprintf('Propiedades carga membrana distribuida:\n');
            disp@CargaEstatica(obj);
            
            % Obtiene la etiqueta del elemento
            etiqueta = obj.elemObj.obtenerEtiqueta();
            
            % Obtiene la etiqueta del primer nodo
            nodosetiqueta = obj.elemObj.obtenerNodos();
            nodo1etiqueta = nodosetiqueta{obj.nodo1}.obtenerEtiqueta();
            nodo2etiqueta = nodosetiqueta{obj.nodo2}.obtenerEtiqueta();
            
            % Obtiene si la carga es horizontal o vertical
            if (obj.theta == 0)
                dirc = 'Horizontal';
            elseif (obj.theta == pi / 2)
                dirc = 'Vertical';
            else
                dirc = sprintf('Diagonal theta=%.3f', obj.theta);
            end
            
            fprintf('\tCarga distribuida: %.3f en %.3f hasta %.3f en %.3f (%s)\n', ...
                obj.carga1, obj.dist1, obj.carga2, ...
                obj.dist2, dirc);
            fprintf('\t                   entre los Nodos: %s (%d) y %s (%d) del Elemento: %s\n', ...
                nodo1etiqueta, obj.nodo1, nodo2etiqueta, obj.nodo2, etiqueta);
            dispMetodoTEFAME();
            
        end % disp function
        
    end % public methods CargaMembranaDistribuida
    
end % class CargaMembranaDistribuida