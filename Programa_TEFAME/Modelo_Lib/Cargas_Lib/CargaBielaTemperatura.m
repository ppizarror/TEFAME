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
%| Clase CargaBielaTemperatura                                          |
%|                                                                      |
%| Este archivo contiene la definición de la Clase CargaBielaTemperatura|
%| CargaBielaTemperatura es una subclase de la clase Carga y corresponde|
%| a la representacion de una carga producto de un incremento de la     |
%| temperatura en una biela, que genera esfuerzos axiales dependiendo de|
%| dT.                                                                  |
%| La clase CargaBielaTemperatura es una clase que contiene el elemento |
%| al que se le va a aplicar la diferencia de temperatura y el coefici- |
%| ente de dilatación del material alpha.                               |
%|                                                                      |
%| Programado: PABLO PIZARRO @ppizarror.com                             |
%| Fecha: 12/06/2018                                                    |
%|______________________________________________________________________|
%
%  Properties (Access=private):
%       elemObj
%       deltaTemepratura
%       alpha
%
%  Methods:
%       cargaBielaTemperaturaObj = CargaBielaTemperatura(etiquetaCarga,elemObjeto,deltaTemperatura,alpha)
%       aplicarCarga(cargaBielaTemperaturaObj,factorDeCarga)
%       disp(cargaBielaTemperaturaObj)
%
%  Methods SuperClass (Carga):
%  Methods SuperClass (ComponenteModelo):
%       etiqueta = obtenerEtiqueta(componenteModeloObj)

classdef CargaBielaTemperatura < Carga
    
    properties(Access = private)
        elemObj % Variable que guarda el elemento que se le va a aplicar la carga
        deltaTemperatura % Diferencia de temperatura aplicada al material
        alpha % Coeficiente de dilatación térmica de la biela
        carga % Carga generada por la temperatura
    end % properties CargaBielaTemperatura
    
    methods
        
        function cargaBielaTemperaturaObj = CargaBielaTemperatura(etiquetaCarga, elemObjeto, deltaTemperatura, alpha)
            % Elemento: es el constructor de la clase CargaBielaTemperatura
            %
            % cargaBielaTemperaturaObj=CargaBielaTemperatura(etiquetaCarga,elemObjeto,deltaTemperatura,alpha)
            % Crea un objeto de la clase CargaBielaTemperatura, en donde toma como atributo
            % el objeto a aplicar la carga, la diferencia de temperatura y
            % el coeficiente de dilatación térmica del material (alpha).
            
            if nargin == 0
                etiquetaCarga = '';
                deltaTemperatura = 0;
                alpha = 0;
            end % if
            
            % Llamamos al constructor de la SuperClass que es la clase Carga
            cargaBielaTemperaturaObj = cargaBielaTemperaturaObj@Carga(etiquetaCarga);
            
            % Guarda los valores
            cargaBielaTemperaturaObj.deltaTemperatura = deltaTemperatura;
            cargaBielaTemperaturaObj.alpha = alpha;
            cargaBielaTemperaturaObj.elemObj = elemObjeto;
            
            % Crea la carga
            cargaBielaTemperaturaObj.carga = elemObjeto.obtenerAE() * deltaTemperatura * alpha;
            
        end % CargaBielaTemperatura constructor
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Metodos para aplicar la Carga durante el análisis
        
        function aplicarCarga(cargaBielaTemperaturaObj, factorDeCarga)
            % aplicarCarga: es un metodo de la clase CargaBielaTemperatura
            % que se usa para aplicar la carga en los nodos.
            %
            % aplicarCarga(cargaVigaPuntualObj,factorDeCarga)
            
            % Obtiene el ángulo de la Biela
            theta = cargaBielaTemperaturaObj.elemObj.obtenerAngulo();
            
            % Carga sin cambiar el ángulo
            c = cargaBielaTemperaturaObj.carga;
            
            % Genera las cargas nodales
            vectorCarga1 = [-c * cos(theta), -c * sin(theta)]';
            vectorCarga2 = [c * cos(theta), c * sin(theta)]';
            cargaBielaTemperaturaObj.elemObj.sumarCargaTemperaturaReaccion([-c * cos(theta), ...
                -c * sin(theta), c * cos(theta), c * sin(theta)]');
            
            % Aplica vectores de carga
            nodos = cargaBielaTemperaturaObj.elemObj.obtenerNodos();
            nodos{1}.agregarCarga(factorDeCarga*vectorCarga1);
            nodos{2}.agregarCarga(factorDeCarga*vectorCarga2);
            
        end % aplicarCarga function
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Métodos para mostar la información de la Carga Biela Temperatura en pantalla
        
        function disp(cargaBielaTemperaturaObj)
            % disp: es un metodo de la clase CargaBielaTemperatura que se usa para imprimir en
            % command Window la información de la carga generada en los
            % nodos fruto de la diferencia de temperatura y el coeficiente
            % del material.
            %
            % disp(cargaBielaTemperaturaObj)
            % Imprime la información guardada en la Carga fruto de la
            % diferencia de temperatura de la Biela (cargaBielaTemperaturaObj)
            % en pantalla
            
            fprintf('Propiedades Carga Biela Temperatura:\n');
            disp@Carga(cargaBielaTemperaturaObj);
            
            % Obtiene la etiqueta del elemento
            etiqueta = cargaBielaTemperaturaObj.elemObj.obtenerEtiqueta();
            
            fprintf('\tCarga: %.3f aplicada en Elemento: %s producto de una diferencia de temperatura: %.3f\n', ...
                cargaBielaTemperaturaObj.carga, etiqueta, cargaBielaTemperaturaObj.deltaTemperatura);
            
            fprintf('-------------------------------------------------\n');
            fprintf('\n');
            
        end % disp function
        
    end % methods CargaBielaTemperatura
    
end % class CargaBielaTemperatura