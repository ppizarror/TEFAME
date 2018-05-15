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
%|                                                                      |
%| Desarrollado por:                                                    |
%|       Fabian Rojas, PhD (frojas@ing.uchile.cl)                       |
%|       Prof. Asistente, Departamento de Ingenieria Civil              |
%|       Universidad de Chile                                           |
%|______________________________________________________________________|
% ______________________________________________________________________
%|                                                                      |
%| Clase CargaVigaDistribuida                                           |
%|                                                                      |
%| Este archivo contiene la definicion de la Clase CargaVigaDistribuida |
%| CargaVigaDistribuida es una subclase de la clase Carga y corresponde |
%| a la representacion de una carga distribuida en un elemento tipo Viga|
%| La clase CargaVigaDistribuida es una clase que contiene el elemento  |
%| al que se le va a aplicar la carga, las cargas en cada punto y las   |
%| distancias de las dos cargas.                                        |
%|                                                                      |
%| Programado: PABLO PIZARRO @ppizarror.com                             |
%| Fecha: 14/05/2018                                                    |
%|______________________________________________________________________|
%
%  Properties (Access=private):
%       elemObj
%       carga1
%       dist1
%       carga2
%       dist2
%
%  Methods:
%       cargaNodoObj = Carga(etiquetaCarga,nodoObjeto,cargaNodo)
%       aplicarCarga(cargaNodoObj,factorDeCarga)
%       disp(cargaNodoObj)
%  Methods Suplerclass (Carga):
%  Methods Suplerclass (ComponenteModelo):
%       etiqueta = obtenerEtiqueta(componenteModeloObj)

classdef CargaVigaDistribuida < Carga
    
    properties(Access = private)
        elemObj % Variable que guarda el elemento que se le va a aplicar la carga
        carga1 % Valor de la carga 1
        carga2 % Valor de la carga 2
        dist1 % Distancia de la carga 1 al primer nodo del elemento
        dist2 % Distancia de la carga 2 al primer nodo del elemento
    end % properties CargaVigaDistribuida
    
    methods
        
        function cargaVigaDistribuidaObj = CargaVigaDistribuida(etiquetaCarga, elemObjeto, carga1, distancia1, carga2, distancia2)
            % Elemento: es el constructor de la clase CargaVigaDistribuida
            %
            % cargaVigaDistribuidaObj=CargaVigaDistribuida(etiquetaCarga,elemObjeto,carga1,distancia1,carga2,distancia2)
            % Crea un objeto de la clase Carga, en donde toma como atributo
            % el objeto a aplicar la carga, las cargas y las distancias de
            % aplicación.
            
            if nargin == 0
                etiquetaCarga = '';
                elemObjeto = [];
                carga1 = 0;
                distancia1 = 0;
                carga2 = 0;
                distancia2 = 0;
            end % if
            
            % Llamamos al constructor de la SuperClass que es la clase Carga
            cargaVigaDistribuidaObj = cargaVigaDistribuidaObj@Carga(etiquetaCarga);
            
            % Guarda los valores
            cargaVigaDistribuidaObj.elemObj = elemObjeto;
            cargaVigaDistribuidaObj.carga1 = carga1;
            cargaVigaDistribuidaObj.dist1 = distancia1 * elemObjeto.obtenerLargo();
            cargaVigaDistribuidaObj.carga2 = carga2;
            cargaVigaDistribuidaObj.dist2 = distancia2 * elemObjeto.obtenerLargo();
            
        end % CargaVigaDistribuida constructor
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Métodos para aplicar la Carga Viga Distribuída durante el análisis
        
        function aplicarCarga(cargaVigaDistribuidaObj, factorDeCarga)
            % aplicarCarga: es un metodo de la clase cargaVigaDistribuidaObj que se usa para aplicar
            % la carga sobre los dos nodos del elemento.
            %
            % aplicarCarga(cargaVigaDistribuidaObj, factorDeCarga)
            
            % Largo de la viga
            L = cargaVigaDistribuidaObj.elemObj.obtenerLargo();
            
            % Límites de las cargas
            d1 = cargaVigaDistribuidaObj.dist1;
            d2 = cargaVigaDistribuidaObj.dist2;
            
            % Cargas
            P1 = cargaVigaDistribuidaObj.carga1;
            P2 = cargaVigaDistribuidaObj.carga2;
            
            % Crea función de carga distribuída
            rho = @(x) P1 + (x - d1) * ((P2 - P1) / d2);
            
            % Funciones de interpolación
            N1 = @(x) 1 - 3 * (x / L).^2 + 2 * (x / L).^3;
            N2 = @(x) x .* (1 - x / L).^2;
            N3 = @(x) 3 * (x / L).^2 - 2 * (x / L).^3;
            N4 = @(x) ((x.^2) / L) .* (x / L - 1);
            
            % Calcula cada valor
            v1 = integral(@(x) rho(x).*N1(x), d1, d2);
            theta1 = integral(@(x) rho(x).*N2(x), d1, d2);
            v2 = integral(@(x) rho(x).*N3(x), d1, d2);
            theta2 = integral(@(x) rho(x).*N4(x), d1, d2);
            
            vectorCarga1 = [0, -v1, -theta1]';
            vectorCarga2 = [0, -v2, -theta2]';
            cargaVigaDistribuidaObj.elemObj.sumarFuerzaEquivalente([-v1, -theta1, -v2, -theta2]');
            
            % Aplica vectores de carga
            nodos = cargaVigaDistribuidaObj.elemObj.obtenerNodos();
            nodos{1}.agregarCarga(factorDeCarga*vectorCarga1);
            nodos{2}.agregarCarga(factorDeCarga*vectorCarga2);
            
        end % aplicarCarga function
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Métodos para mostar la informacién de la Carga Viga Distribuída en pantalla
        
        function disp(cargaVigaDistribuidaObj)
            % disp: es un metodo de la clase Carga que se usa para imprimir en
            % command Window la informacion de la carga aplicada sobre el
            % elemento
            %
            % disp(cargaVigaPuntualObj)
            % Imprime la informacion guardada en la Carga Puntual de la
            % Viga (cargaVigaPuntualObj) en pantalla
            
            fprintf('Propiedades Carga Viga Distribuida:\n');
            
            disp@Carga(cargaVigaDistribuidaObj);
            
            % Obtiene la etiqueta del elemento
            etiqueta = cargaVigaDistribuidaObj.elemObj.obtenerEtiqueta();
            
            % Obtiene la etiqueta del primer nodo
            nodosetiqueta = cargaVigaDistribuidaObj.elemObj.obtenerNodos();
            nodo1etiqueta = nodosetiqueta{1}.obtenerEtiqueta();
            nodo2etiqueta = nodosetiqueta{2}.obtenerEtiqueta();
            
            fprintf('\tCarga distribuída:%.3f en %.3f hasta %.3f en %.3f entre los Nodos:%s y %s del Elemento:%s', ...
                cargaVigaDistribuidaObj.carga1, cargaVigaDistribuidaObj.dist1, cargaVigaDistribuidaObj.carga2, ...
                cargaVigaDistribuidaObj.dist2, nodo1etiqueta, nodo2etiqueta, etiqueta);
            
        end % disp function
        
    end % methods CargaVigaDistribuida
    
end % class CargaVigaDistribuida