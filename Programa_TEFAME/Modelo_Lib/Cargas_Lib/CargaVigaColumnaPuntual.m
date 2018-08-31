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
%| Clase CargaVigaColumnaPuntual                                        |
%|                                                                      |
%| Este archivo contiene la definicion de la Clase CargaVigaColumnaPuntual|
%| CargaVigaColumnaPuntual es una subclase de la clase Carga y          |
%| corresponde a la representacion de una carga puntual en un elemento  |
%| tipo Viga-Columna.                                                   |
%| La clase CargaVigaColumnaPuntual es una clase que contiene el        |
%| elemento al al que se le va a aplicar la carga, el valor de esta     |
%| carga, la distancia a uno de los nodos como porcentaje del largo y   |
%| el angulo de aplicacion.                                             |
%|                                                                      |
%| Programado: PABLO PIZARRO @ppizarror.com                             |
%| Fecha: 11/06/2018                                                    |
%|______________________________________________________________________|
%
%  Properties (Access=private):
%       elemObj
%       carga
%       dist
%       theta
%
%  Methods:
%       cargaNodoObj = CargaVigaColumnaPuntual(etiquetaCarga,elemObjeto,carga,distancia,theta)
%       aplicarCarga(cargaVigaColumnaPuntualObj,factorDeCarga)
%       disp(cargaVigaColumnaPuntualObj)
%
%  Methods SuperClass (Carga):
%  Methods SuperClass (ComponenteModelo):
%       etiqueta = obtenerEtiqueta(componenteModeloObj)

classdef CargaVigaColumnaPuntual < Carga
    
    properties(Access = private)
        elemObj % Variable que guarda el elemento que se le va a aplicar la carga
        carga % Valor de la carga
        dist % Distancia de la carga al primer nodo del elemento
        theta % Angulo de aplicacion de la carga
    end % properties CargaVigaColumnaPuntual
    
    methods
        
        function cargaVigaColumnaPuntualObj = CargaVigaColumnaPuntual(etiquetaCarga, elemObjeto, carga, distancia, theta)
            % Elemento: es el constructor de la clase CargaVigaColumnaPuntual
            %
            % cargaVigaColumnaPuntualObj=CargaVigaColumnaPuntual(etiquetaCarga,elemObjeto,carga,distancia,theta)
            % Crea un objeto de la clase CargaVigaColumnaPuntual, en donde toma como atributo
            % el objeto a aplicar la carga, la distancia como porcentaje
            % del largo del elemento con respecto al primer nodo, el
            % elemento tipo viga y el angulo de aplicacion de la carga con respecto a la normal.
            
            if nargin == 0
                etiquetaCarga = '';
                elemObjeto = [];
                carga = 0;
                distancia = 0;
                theta = 0;
            end % if
            
            % Llamamos al constructor de la SuperClass que es la clase Carga
            cargaVigaColumnaPuntualObj = cargaVigaColumnaPuntualObj@Carga(etiquetaCarga);
            
            % Guarda los valores
            cargaVigaColumnaPuntualObj.elemObj = elemObjeto;
            cargaVigaColumnaPuntualObj.carga = carga;
            cargaVigaColumnaPuntualObj.dist = distancia * elemObjeto.obtenerLargo();
            cargaVigaColumnaPuntualObj.theta = theta;
            
        end % CargaVigaColumnaPuntual constructor
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Metodos para aplicar la Carga Puntual de la Viga-Columna durante el analisis
        
        function aplicarCarga(cargaVigaColumnaPuntualObj, factorDeCarga)
            % aplicarCarga: es un metodo de la clase CargaVigaColumnaPuntual
            % que se usa para aplicar la carga sobre los dos nodos del elemento.
            %
            % aplicarCarga(cargaVigaColumnaPuntualObj,factorDeCarga)
            
            % Largo de la viga
            L = cargaVigaColumnaPuntualObj.elemObj.obtenerLargo();
            
            % Posicion de la carga
            d = cargaVigaColumnaPuntualObj.dist;
            
            % Carga normal
            P = cargaVigaColumnaPuntualObj.carga * cos(cargaVigaColumnaPuntualObj.theta);
            
            % Carga axial
            H = -cargaVigaColumnaPuntualObj.carga * sin(cargaVigaColumnaPuntualObj.theta);
            
            % Se calculan apoyos y reacciones en un caso de viga empotrada
            % sometida a una carga P aplicada a (L-d) de un apoyo y d del
            % otro. Esto se hizo al no tener la funcion dirac(x) y
            % distintos errores fruto de la evaluacion de la integral.
            v1 = P * ((L - d)^2 / L^2) * (3 - 2 * (L - d) / L);
            v2 = P * (d^2 / L^2) * (3 - 2 * d / L);
            theta1 = P * d * (L - d)^2 / (L^2);
            theta2 = -P * (d^2) * (L - d) / (L^2);
            
            % Para el caso de las cargas normales se usan las funciones de
            % interpolacion
            Nu1 = @(x) (1 - x / L);
            Nu2 = @(x) x / L;
            u1 = H * Nu1(d);
            u2 = H * Nu2(d);
            
            vectorCarga = factorDeCarga * [u1, v1, theta1, u2, v2, theta2]';
            cargaVigaColumnaPuntualObj.elemObj.sumarFuerzaEquivalente(vectorCarga);
            
            % Aplica vectores de carga en coordenadas globales
            vectorCarga = cargaVigaColumnaPuntualObj.elemObj.obtenerMatrizTransformacion()' * vectorCarga;
            nodos = cargaVigaColumnaPuntualObj.elemObj.obtenerNodos();
            nodos{1}.agregarCarga([vectorCarga(1), vectorCarga(2), vectorCarga(3)]');
            nodos{2}.agregarCarga([vectorCarga(4), vectorCarga(5), vectorCarga(6)]');
            
        end % aplicarCarga function
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Metodos para mostar la informacion de la Carga Viga-Columna Puntual en pantalla
        
        function disp(cargaVigaColumnaPuntualObj)
            % disp: es un metodo de la clase CargaVigaPuntual que se usa para imprimir en
            % command Window la informacion de la carga aplicada sobre el
            % elemento.
            %
            % disp(cargaVigaColumnaPuntualObj)
            % Imprime la informacion guardada en la Carga Puntual de la
            % Viga-Columna (cargaVigaColumnaPuntualObj) en pantalla.
            
            fprintf('Propiedades Carga Viga-Columna Puntual:\n');
            disp@Carga(cargaVigaColumnaPuntualObj);
            
            % Obtiene la etiqueta del elemento
            etiqueta = cargaVigaColumnaPuntualObj.elemObj.obtenerEtiqueta();
            
            % Obtiene la etiqueta del primer nodo
            nodo1etiqueta = cargaVigaColumnaPuntualObj.elemObj.obtenerNodos();
            nodo1etiqueta = nodo1etiqueta{1}.obtenerEtiqueta();
            
            % Obtiene cargas axiales y normales
            P = cargaVigaColumnaPuntualObj.carga * cos(cargaVigaColumnaPuntualObj.theta);
            H = cargaVigaColumnaPuntualObj.carga * sin(cargaVigaColumnaPuntualObj.theta);
            
            fprintf('\tCarga aplicada en Elemento: %s a %.3f del Nodo: %s\n', etiqueta, cargaVigaColumnaPuntualObj.dist, nodo1etiqueta);
            fprintf('\t\tComponente NORMAL:\t%.3f\n', P);
            fprintf('\t\tComponente AXIAL:\t%.3f\n', H);
            
            fprintf('-------------------------------------------------\n');
            fprintf('\n');
            
        end % disp function
        
    end % methods CargaVigaColumnaPuntual
    
end % class CargaVigaColumnaPuntual