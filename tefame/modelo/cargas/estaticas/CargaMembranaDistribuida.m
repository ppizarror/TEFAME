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
%  Properties (Access=private):
%       elemObj
%       carga1
%       carga2
%       dist1
%       dist2
%       nodo1
%       nodo2
%       L
%       theta
%
%  Methods:
%       cargaMembranaDistribuidaObj = CargaMembranaDistribuida(etiquetaCarga,elemObjeto,nodo1,nodo2,carga1,distancia1,carga2,distancia2)
%       aplicarCarga(cargaMembranaDistribuidaObj,factorDeCarga)
%       disp(cargaMembranaDistribuidaObj)
%
%  Methods SuperClass (Carga):
%  Methods SuperClass (ComponenteModelo):
%       etiqueta = obtenerEtiqueta(componenteModeloObj)
%       e = equals(componenteModeloObj,obj)

classdef CargaMembranaDistribuida < Carga
    
    properties(Access = private)
        elemObj % Variable que guarda el elemento que se le va a aplicar la carga
        carga1 % Valor de la carga 1
        carga2 % Valor de la carga 2
        dist1 % Distancia de la carga 1 al primer nodo del elemento
        dist2 % Distancia de la carga 2 al primer nodo del elemento
        nodo1 % Nodo 1 de aplicacion
        nodo2 % Nodo 2 de aplicacion
        L % Largo de aplicacion de las cargas
        theta % Angulo de aplicacion
    end % properties CargaMembranaDistribuida
    
    methods
        
        function cargaMembranaDistribuidaObj = CargaMembranaDistribuida(etiquetaCarga, elemObjeto, ...
                nodo1, nodo2, carga1, distancia1, carga2, distancia2)
            % CargaMembranaDistribuida: es el constructor de la clase CargaMembranaDistribuida
            %
            % cargaMembranaDistribuidaObj=CargaMembranaDistribuida(etiquetaCarga,elemObjeto,nodo1,nodo2,carga1,distancia1,carga2,distancia2)
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
                etiquetaCarga = '';
                elemObjeto = [];
                carga1 = 0;
                distancia1 = 0;
                carga2 = 0;
                distancia2 = 0;
            end % if
            
            % Llamamos al constructor de la SuperClass que es la clase Carga
            cargaMembranaDistribuidaObj = cargaMembranaDistribuidaObj@Carga(etiquetaCarga);
            
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
            cargaMembranaDistribuidaObj.theta = atan(dy/dx);
            
            % Guarda los valores
            cargaMembranaDistribuidaObj.elemObj = elemObjeto;
            cargaMembranaDistribuidaObj.L = largo;
            
            cargaMembranaDistribuidaObj.carga1 = carga1;
            cargaMembranaDistribuidaObj.dist1 = distancia1 * largo;
            cargaMembranaDistribuidaObj.nodo1 = nodo1;
            
            cargaMembranaDistribuidaObj.carga2 = carga2;
            cargaMembranaDistribuidaObj.dist2 = distancia2 * largo;
            cargaMembranaDistribuidaObj.nodo2 = nodo2;
            
        end % CargaMembranaDistribuida constructor
        
        function aplicarCarga(cargaMembranaDistribuidaObj, factorDeCarga)
            % aplicarCarga: es un metodo de la clase cargaMembranaDistribuidaObj
            % que se usa para aplicar la carga sobre los dos nodos correspondientes del elemento
            %
            % aplicarCarga(cargaMembranaDistribuidaObj, factorDeCarga)
            
            % Limites de las cargas
            d1 = cargaMembranaDistribuidaObj.dist1;
            d2 = cargaMembranaDistribuidaObj.dist2;
            
            % Cargas
            P1 = cargaMembranaDistribuidaObj.carga1;
            P2 = cargaMembranaDistribuidaObj.carga2;
            
            % Crea funcion de carga distribuida
            rho = @(x) P1 + (x - d1) * ((P2 - P1) / d2);
            
            % Funciones de interpolacion
            N1 = @(x) 1 - 3 * (x / cargaMembranaDistribuidaObj.L).^2 + 2 * (x / cargaMembranaDistribuidaObj.L).^3;
            N3 = @(x) 3 * (x / cargaMembranaDistribuidaObj.L).^2 - 2 * (x / cargaMembranaDistribuidaObj.L).^3;
            
            % Calcula cada valor
            v1 = integral(@(x) rho(x).*N1(x), d1, d2);
            v2 = integral(@(x) rho(x).*N3(x), d1, d2);
            
            % Aplica el angulo
            v1x = v1 * sin(cargaMembranaDistribuidaObj.theta);
            v1y = v1 * cos(cargaMembranaDistribuidaObj.theta);
            v2x = v2 * sin(cargaMembranaDistribuidaObj.theta);
            v2y = v2 * cos(cargaMembranaDistribuidaObj.theta);
            
            vectorCarga1 = factorDeCarga * [v1x, v1y]';
            vectorCarga2 = factorDeCarga * [v2x, v2y]';
            
            % Aplica fuerzas equivalentes;
            cargaMembranaDistribuidaObj.elemObj.sumarFuerzaEquivalente(cargaMembranaDistribuidaObj.nodo1, vectorCarga1');
            cargaMembranaDistribuidaObj.elemObj.sumarFuerzaEquivalente(cargaMembranaDistribuidaObj.nodo2, vectorCarga2');
            
            % Aplica vectores de carga
            nodos = cargaMembranaDistribuidaObj.elemObj.obtenerNodos();
            nodos{cargaMembranaDistribuidaObj.nodo1}.agregarCarga(vectorCarga1);
            nodos{cargaMembranaDistribuidaObj.nodo2}.agregarCarga(vectorCarga2);
            
        end % aplicarCarga function
        
        function disp(cargaMembranaDistribuidaObj)
            % disp: es un metodo de la clase Carga que se usa para imprimir en
            % command Window la informacion de la carga aplicada sobre el
            % elemento membrana
            %
            % disp(cargaMembranaDistribuidaObj)
            % Imprime la informacion guardada en la carga distribuida de la
            % membrana (cargaMembranaDistribuidaObj) en pantalla
            
            fprintf('Propiedades carga membrana distribuida:\n');
            disp@Carga(cargaMembranaDistribuidaObj);
            
            % Obtiene la etiqueta del elemento
            etiqueta = cargaMembranaDistribuidaObj.elemObj.obtenerEtiqueta();
            
            % Obtiene la etiqueta del primer nodo
            nodosetiqueta = cargaMembranaDistribuidaObj.elemObj.obtenerNodos();
            nodo1etiqueta = nodosetiqueta{cargaMembranaDistribuidaObj.nodo1}.obtenerEtiqueta();
            nodo2etiqueta = nodosetiqueta{cargaMembranaDistribuidaObj.nodo2}.obtenerEtiqueta();
            
            % Obtiene si la carga es horizontal o vertical
            if (cargaMembranaDistribuidaObj.theta == 0)
                dirc = 'Horizontal';
            elseif (cargaMembranaDistribuidaObj.theta == pi / 2)
                dirc = 'Vertical';
            else
                dirc = sprintf('Diagonal theta=%.3f', cargaMembranaDistribuidaObj.theta);
            end
            
            fprintf('\tCarga distribuida: %.3f en %.3f hasta %.3f en %.3f (%s)\n', ...
                cargaMembranaDistribuidaObj.carga1, cargaMembranaDistribuidaObj.dist1, cargaMembranaDistribuidaObj.carga2, ...
                cargaMembranaDistribuidaObj.dist2, dirc);
            fprintf('\t                   entre los Nodos: %s (%d) y %s (%d) del Elemento: %s\n', ...
                nodo1etiqueta, cargaMembranaDistribuidaObj.nodo1, nodo2etiqueta, cargaMembranaDistribuidaObj.nodo2, etiqueta);
            
            fprintf('-------------------------------------------------\n');
            fprintf('\n');
            
        end % disp function
        
    end % methods CargaMembranaDistribuida
    
end % class CargaMembranaDistribuida