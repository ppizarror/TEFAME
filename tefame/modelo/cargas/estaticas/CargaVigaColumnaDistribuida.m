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
%| Clase CargaVigaColumnaDistribuida                                    |
%|                                                                      |
%| Este archivo contiene la definicion de la Clase CargaVigaColumnaDist |
%| ribuida, CargaVigaDistribuida es una subclase de la clase Carga y    |
%| corresponde a la representacion de una carga distribuida en un       |
%| elemento tipo Viga. La clase CargaVigaDistribuida es una clase que   |
%| contiene el elemento, al que se le va a aplicar la carga, las cargas |
%| en cada punto, las distancias de las dos cargas y el angulo con      |
%| respecto a la normal.                                                |
%|                                                                      |
%| Programado: Pablo Pizarro @ppizarror.com                             |
%| Fecha: 11/06/2018                                                    |
%|______________________________________________________________________|
%
%  Properties (Access=private):
%       carga1
%       carga2
%       dist1
%       dist2
%       elemObj
%       theta
%  Methods:
%       obj = CargaVigaColumnaDistribuida(etiquetaCarga,elemObjeto,carga1,
%                                        distancia1,carga2,distancia2,theta)
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

classdef CargaVigaColumnaDistribuida < CargaEstatica
    
    properties(Access = private)
        carga1 % Valor de la carga 1
        carga2 % Valor de la carga 2
        dist1 % Distancia de la carga 1 al primer nodo del elemento (porcentaje del largo)
        dist2 % Distancia de la carga 2 al primer nodo del elemento (porcentaje del largo)
        elemObj % Variable que guarda el elemento que se le va a aplicar la carga
        theta % Angulo de la carga
    end % private properties CargaVigaColumnaDistribuida
    
    methods(Access = public)
        
        function obj = CargaVigaColumnaDistribuida(etiquetaCarga, ...
                elemObjeto, carga1, distancia1, carga2, distancia2, theta)
            % CargaVigaColumnaDistribuida: es el constructor de la clase CargaVigaColumnaDistribuida
            %
            % Crea un objeto de la clase Carga, en donde toma como atributo
            % el objeto a aplicar la carga, las cargas, las distancias de
            % aplicacion y el angulo de la carga con respecto a la normal
            % (0=Completamente normal, pi/2=Carga axial a la viga)
            
            % Si no se pasan argumentos se crea una carga vacia
            if nargin == 0
                carga1 = 0;
                carga2 = 0;
                distancia1 = 0;
                distancia2 = 0;
                elemObjeto = [];
                etiquetaCarga = '';
                theta = 0;
            end
            
            % Llamamos al constructor de la SuperClass que es la clase
            % CargaEstatica
            obj = obj@CargaEstatica(etiquetaCarga);
            
            % Aplica limites al minimo y maximo
            if (distancia1 < 0 || distancia1 > 1 || distancia2 > 1 || distancia2 < 0)
                warning('Distancias deben estar dentro del rango [0, 1] @CargaVigaColumnaDistribuida %s', etiquetaCarga);
            end
            if (distancia1 == distancia2)
                warning('Distancias son iguales @CargaVigaColumnaDistribuida %s', etiquetaCarga);
            end
            distancia1 = max(0, min(distancia1, 1));
            distancia2 = min(1, max(distancia2, 0));
            
            % Guarda los valores
            obj.carga1 = carga1;
            obj.carga2 = carga2;
            obj.dist1 = distancia1 * elemObjeto.obtenerLargo();
            obj.dist2 = distancia2 * elemObjeto.obtenerLargo();
            obj.elemObj = elemObjeto;
            obj.nodosCarga = elemObjeto.obtenerNodos();
            obj.theta = theta;
            
        end % CargaVigaColumnaDistribuida constructor
        
        function [u1, u2, v1, v2, theta1, theta2] = calcularCarga(obj)
            % calcularCarga: Calcula la carga
            
            % Largo de la viga
            L = obj.elemObj.obtenerLargo();
            
            % Limites de las cargas
            d1 = obj.dist1;
            d2 = obj.dist2;
            
            % Angulo de la carga
            ang = obj.theta;
            
            % Cargas normales
            P1 = obj.carga1 * cos(ang);
            P2 = obj.carga2 * cos(ang);
            
            % Cargas axiales
            H1 = obj.carga1 * sin(ang);
            H2 = obj.carga2 * sin(ang);
            
            % Crea funcion de carga distribuida normal y axial
            rhoV = @(x) P1 + (x - d1) * ((P2 - P1) / d2);
            rhoH = @(x) H1 + (x - d1) * ((H2 - H1) / d2);
            
            % Funciones de interpolacion
            Nu1 = @(x) - (1 - x / L);
            Nu2 = @(x) - x / L;
            Nv1 = @(x) 1 - 3 * (x / L).^2 + 2 * (x / L).^3;
            Nv2 = @(x) x .* (1 - x / L).^2;
            Nv3 = @(x) 3 * (x / L).^2 - 2 * (x / L).^3;
            Nv4 = @(x) ((x.^2) / L) .* (x / L - 1);
            
            % Calcula cada valor
            u1 = integral(@(x) rhoH(x).*Nu1(x), d1, d2);
            u2 = integral(@(x) rhoH(x).*Nu2(x), d1, d2);
            v1 = integral(@(x) rhoV(x).*Nv1(x), d1, d2);
            v2 = integral(@(x) rhoV(x).*Nv3(x), d1, d2);
            theta1 = integral(@(x) rhoV(x).*Nv2(x), d1, d2);
            theta2 = integral(@(x) rhoV(x).*Nv4(x), d1, d2);
            
        end % calcularCarga function
        
        function masa = obtenerMasa(obj)
            % obtenerMasa: Obtiene la masa asociada a la carga
            
            [u1, u2, v1, v2, ~, ~] = obj.calcularCarga();
            masa = abs(u1+u2+v1+v2) .* (obj.factorCargaMasa * obj.factorUnidadMasa);
            
        end % obtenerMasa function
        
        function aplicarCarga(obj, factorDeCarga)
            % aplicarCarga: es un metodo de la clase obj
            % que se usa para aplicar la carga sobre los dos nodos del elemento
            
            % Calcula la carga
            [u1, u2, v1, v2, theta1, theta2] = obj.calcularCarga();
            vectorCarga = factorDeCarga * [u1, v1, theta1, u2, v2, theta2]';
            obj.elemObj.sumarFuerzaEquivalente(vectorCarga);
            
            % Aplica vectores de carga en coordenadas globales
            vectorCarga = obj.elemObj.obtenerMatrizTransformacion()' * vectorCarga;
            nodos = obj.elemObj.obtenerNodos();
            nodos{1}.agregarCarga([vectorCarga(1), vectorCarga(2), vectorCarga(3)]');
            nodos{2}.agregarCarga([vectorCarga(4), vectorCarga(5), vectorCarga(6)]');
            
        end % aplicarCarga function
        
        function disp(obj)
            % disp: es un metodo de la clase Carga que se usa para imprimir en
            % command Window la informacion de la carga aplicada sobre el
            % elemento
            %
            % Imprime la informacion guardada en la carga viga-columna distribuida
            % (obj) en pantalla
            
            fprintf('Propiedades carga viga-columna distribuida:\n');
            disp@CargaEstatica(obj);
            
            % Obtiene la etiqueta del elemento
            etiqueta = obj.elemObj.obtenerEtiqueta();
            
            % Obtiene la etiqueta del primer nodo
            nodosetiqueta = obj.elemObj.obtenerNodos();
            nodo1etiqueta = nodosetiqueta{1}.obtenerEtiqueta();
            nodo2etiqueta = nodosetiqueta{2}.obtenerEtiqueta();
            
            % Obtiene cargas horizontales y verticales
            ang = obj.theta;
            P1 = obj.carga1 * cos(ang);
            P2 = obj.carga2 * cos(ang);
            H1 = obj.carga1 * sin(ang);
            H2 = obj.carga2 * sin(ang);
            a = obj.dist1;
            b = obj.dist2;
            
            fprintf('\tCarga distribuida entre los Nodos: %s y %s del Elemento: %s\n', ...
                nodo1etiqueta, nodo2etiqueta, etiqueta);
            fprintf('\t\tComponente NORMAL:\t%.3f en %.3f hasta %.3f en %.3f\n', P1, a, P2, b);
            fprintf('\t\tComponente AXIAL:\t%.3f en %.3f hasta %.3f en %.3f\n', H1, a, H2, b);
            dispMetodoTEFAME();
            
        end % disp function
        
    end % public methods CargaVigaColumnaDistribuida
    
end % class CargaVigaColumnaDistribuida