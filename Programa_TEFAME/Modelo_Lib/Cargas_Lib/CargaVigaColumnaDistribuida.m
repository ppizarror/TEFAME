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
%| Este archivo contiene la definicion de la Clase CargaVigaColumnaDist |
%| ribuida, CargaVigaDistribuida es una subclase de la clase Carga y    |
%| corresponde a la representación de una carga distribuida en un       |
%| elemento tipo Viga. La clase CargaVigaDistribuida es una clase que   |
%| contiene el elemento, al que se le va a aplicar la carga, las cargas |
%| en cada punto y las distancias de las dos cargas.                    |
%|                                                                      |
%| Programado: PABLO PIZARRO @ppizarror.com                             |
%| Fecha: 11/06/2018                                                    |
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
%       cargaVigaColumnaDistribuidaObj = CargaVigaColumnaDistribuida(etiquetaCarga,elemObjeto,carga1,
%                                        distancia1,carga2,distancia2,theta)
%       aplicarCarga(cargaNodoObj,factorDeCarga)
%       disp(cargaNodoObj)
%  Methods Suplerclass (Carga):
%  Methods Suplerclass (ComponenteModelo):
%       etiqueta = obtenerEtiqueta(componenteModeloObj)

classdef CargaVigaColumnaDistribuida < Carga
    
    properties(Access = private)
        elemObj % Variable que guarda el elemento que se le va a aplicar la carga
        carga1 % Valor de la carga 1
        carga2 % Valor de la carga 2
        theta % Ángulo de la carga
        dist1 % Distancia de la carga 1 al primer nodo del elemento
        dist2 % Distancia de la carga 2 al primer nodo del elemento
    end % properties CargaVigaDistribuida
    
    methods
        
        function cargaVigaColumnaDistribuidaObj = CargaVigaColumnaDistribuida(etiquetaCarga, ...
                elemObjeto, carga1, distancia1, carga2, distancia2, theta)
            % Elemento: es el constructor de la clase CargaVigaColumnaDistribuida
            %
            % cargaVigaColumnaDistribuidaObj=CargaVigaColumnaDistribuida(etiquetaCarga,
            %   elemObjeto,carga1,distancia1,carga2,distancia2,theta)
            % Crea un objeto de la clase Carga, en donde toma como atributo
            % el objeto a aplicar la carga, las cargas, las distancias de
            % aplicación y el ángulo de la carga con respecto a la normal
            % (0=Completamente normal, pi/2=Carga axial a la viga)
            
            if nargin == 0
                etiquetaCarga = '';
                elemObjeto = [];
                carga1 = 0;
                distancia1 = 0;
                carga2 = 0;
                distancia2 = 0;
                theta = 0;
            end % if
            
            % Llamamos al constructor de la SuperClass que es la clase Carga
            cargaVigaColumnaDistribuidaObj = cargaVigaColumnaDistribuidaObj@Carga(etiquetaCarga);
            
            % Guarda los valores
            cargaVigaColumnaDistribuidaObj.elemObj = elemObjeto;
            cargaVigaColumnaDistribuidaObj.carga1 = carga1;
            cargaVigaColumnaDistribuidaObj.dist1 = distancia1 * elemObjeto.obtenerLargo();
            cargaVigaColumnaDistribuidaObj.carga2 = carga2;
            cargaVigaColumnaDistribuidaObj.dist2 = distancia2 * elemObjeto.obtenerLargo();
            cargaVigaColumnaDistribuidaObj.theta = theta;
            
        end % CargaVigaColumnaDistribuida constructor
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Métodos para aplicar la Carga Viga-Columna Distribuída durante el análisis
        
        function aplicarCarga(cargaVigaColumnaDistribuidaObj, factorDeCarga)
            % aplicarCarga: es un metodo de la clase cargaVigaColumnaDistribuidaObj que se usa para aplicar
            % la carga sobre los dos nodos del elemento.
            %
            % aplicarCarga(cargaVigaDistribuidaObj, factorDeCarga)
            
            % Largo de la viga
            L = cargaVigaColumnaDistribuidaObj.elemObj.obtenerLargo();
            
            % Límites de las cargas
            d1 = cargaVigaColumnaDistribuidaObj.dist1;
            d2 = cargaVigaColumnaDistribuidaObj.dist2;
            
            % Ángulo de la carga
            ang = cargaVigaColumnaDistribuidaObj.theta;
            
            % Cargas normales
            P1 = cargaVigaColumnaDistribuidaObj.carga1 * cos(ang);
            P2 = cargaVigaColumnaDistribuidaObj.carga2 * cos(ang);
            
            % Cargas axiales
            H1 = cargaVigaColumnaDistribuidaObj.carga1 * sin(ang);
            H2 = cargaVigaColumnaDistribuidaObj.carga2 * sin(ang);
            
            % Crea función de carga distribuída normal y axial
            rhoV = @(x) P1 + (x - d1) * ((P2 - P1) / d2);
            rhoH = @(x) H1 + (x - d1) * ((H2 - H1) / d2);
            
            % Funciones de interpolación
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
            
            vectorCarga = -[u1, v1, theta1, u2, v2, theta2]';
            cargaVigaColumnaDistribuidaObj.elemObj.sumarFuerzaEquivalente(vectorCarga);
            
            % Aplica vectores de carga en coordenadas globales
            vectorCarga = cargaVigaColumnaDistribuidaObj.elemObj.obtenerMatrizTransformacion()' * vectorCarga;
            nodos = cargaVigaColumnaDistribuidaObj.elemObj.obtenerNodos();
            nodos{1}.agregarCarga(factorDeCarga*[vectorCarga(1), vectorCarga(2), vectorCarga(3)]');
            nodos{2}.agregarCarga(factorDeCarga*[vectorCarga(4), vectorCarga(5), vectorCarga(6)]');
            
        end % aplicarCarga function
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Métodos para mostar la informacién de la Carga Viga Distribuída en pantalla
        
        function disp(cargaVigaColumnaDistribuidaObj)
            % disp: es un metodo de la clase Carga que se usa para imprimir en
            % command Window la informacion de la carga aplicada sobre el
            % elemento
            %
            % disp(cargaVigaColumnaDistribuidaObj)
            % Imprime la informacion guardada en la Carga Viga-Columna Distribuída
            % (cargaVigaColumnaDistribuidaObj) en pantalla
            
            fprintf('Propiedades Carga Viga-Columna Distribuida:\n');
            
            disp@Carga(cargaVigaColumnaDistribuidaObj);
            
            % Obtiene la etiqueta del elemento
            etiqueta = cargaVigaColumnaDistribuidaObj.elemObj.obtenerEtiqueta();
            
            % Obtiene la etiqueta del primer nodo
            nodosetiqueta = cargaVigaColumnaDistribuidaObj.elemObj.obtenerNodos();
            nodo1etiqueta = nodosetiqueta{1}.obtenerEtiqueta();
            nodo2etiqueta = nodosetiqueta{2}.obtenerEtiqueta();
            
            % Obtiene cargas horizontales y verticales
            ang = cargaVigaColumnaDistribuidaObj.theta;
            P1 = cargaVigaColumnaDistribuidaObj.carga1 * cos(ang);
            P2 = cargaVigaColumnaDistribuidaObj.carga2 * cos(ang);
            H1 = cargaVigaColumnaDistribuidaObj.carga1 * sin(ang);
            H2 = cargaVigaColumnaDistribuidaObj.carga2 * sin(ang);
            a = cargaVigaColumnaDistribuidaObj.dist1;
            b = cargaVigaColumnaDistribuidaObj.dist2;
            
            fprintf('\tCarga distribuída entre los Nodos: %s y %s del Elemento: %s\n', nodo1etiqueta, nodo2etiqueta, etiqueta);
            fprintf('\t\tComponente NORMAL:\t%.3f en %.3f hasta %.3f en %.3f\n', P1, a, P2, b);
            fprintf('\t\tComponente AXIAL:\t%.3f en %.3f hasta %.3f en %.3f\n', H1, a, H2, b);
            
        end % disp function
        
    end % methods CargaVigaColumnaDistribuida
    
end % class CargaVigaColumnaDistribuida