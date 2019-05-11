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
%| Clase CargaBielaTemperatura                                          |
%|                                                                      |
%| Este archivo contiene la definicion de la Clase CargaBielaTemperatura|
%| CargaBielaTemperatura es una subclase de la clase Carga y corresponde|
%| a la representacion de una carga producto de un incremento de la     |
%| temperatura en una biela, que genera esfuerzos axiales dependiendo de|
%| dT.                                                                  |
%| La clase CargaBielaTemperatura es una clase que contiene el elemento |
%| al que se le va a aplicar la diferencia de temperatura y el coefici- |
%| ente de dilatacion del material alpha.                               |
%|                                                                      |
%| Programado: Pablo Pizarro @ppizarror.com                             |
%| Fecha: 12/06/2018                                                    |
%|______________________________________________________________________|
%
%  Properties (Access=private):
%       elemObj
%       deltaTemepratura
%       alpha
%       carga
%  Methods:
%       cargaBielaTemperaturaObj = CargaBielaTemperatura(etiquetaCarga,elemObjeto,deltaTemperatura,alpha)
%       aplicarCarga(cargaBielaTemperaturaObj,factorDeCarga)
%       disp(cargaBielaTemperaturaObj)
%  Methods SuperClass (CargaEstatica):
%       masa = obtenerMasa(cargaObj)
%  Methods SuperClass (ComponenteModelo):
%       etiqueta = obtenerEtiqueta(componenteModeloObj)
%       e = equals(componenteModeloObj,obj)

classdef CargaBielaTemperatura < CargaEstatica
    
    properties(Access = private)
        elemObj % Variable que guarda el elemento que se le va a aplicar la carga
        deltaTemperatura % Diferencia de temperatura aplicada al material
        alpha % Coeficiente de dilatacion termica de la biela
        carga % Carga generada por la temperatura
    end % properties CargaBielaTemperatura
    
    methods
        
        function cargaBielaTemperaturaObj = CargaBielaTemperatura(etiquetaCarga, elemObjeto, deltaTemperatura, alpha)
            % CargaBielaTemperatura: es el constructor de la clase CargaBielaTemperatura
            %
            % cargaBielaTemperaturaObj=CargaBielaTemperatura(etiquetaCarga,elemObjeto,deltaTemperatura,alpha)
            %
            % Crea un objeto de la clase CargaBielaTemperatura, en donde toma como atributo
            % el objeto a aplicar la carga, la diferencia de temperatura y
            % el coeficiente de dilatacion termica del material (alpha)
            
            if nargin == 0
                etiquetaCarga = '';
                deltaTemperatura = 0;
                alpha = 0;
            end % if
            
            % Llamamos al constructor de la SuperClass que es la clase
            % CargaEstatica
            cargaBielaTemperaturaObj = cargaBielaTemperaturaObj@CargaEstatica(etiquetaCarga);
            
            % Guarda los valores
            cargaBielaTemperaturaObj.deltaTemperatura = deltaTemperatura;
            cargaBielaTemperaturaObj.alpha = alpha;
            cargaBielaTemperaturaObj.elemObj = elemObjeto;
            
            % Crea la carga
            cargaBielaTemperaturaObj.carga = elemObjeto.obtenerAE() * deltaTemperatura * alpha;
            
        end % CargaBielaTemperatura constructor
        
        function aplicarCarga(cargaBielaTemperaturaObj, factorDeCarga)
            % aplicarCarga: es un metodo de la clase CargaBielaTemperatura
            % que se usa para aplicar la carga en los nodos
            %
            % aplicarCarga(cargaVigaPuntualObj,factorDeCarga)
            
            % Obtiene el angulo de la Biela
            theta = cargaBielaTemperaturaObj.elemObj.obtenerAngulo();
            
            % Carga sin cambiar el angulo
            c = cargaBielaTemperaturaObj.carga;
            
            % Genera las cargas nodales
            vectorCarga1 = factorDeCarga * [-c * cos(theta), -c * sin(theta)]';
            vectorCarga2 = factorDeCarga * [c * cos(theta), c * sin(theta)]';
            cargaBielaTemperaturaObj.elemObj.sumarCargaTemperaturaReaccion( ...
                factorDeCarga*[vectorCarga1(1), vectorCarga1(2), vectorCarga2(1), vectorCarga2(2)]');
            
            % Aplica vectores de carga
            nodos = cargaBielaTemperaturaObj.elemObj.obtenerNodos();
            nodos{1}.agregarCarga(vectorCarga1);
            nodos{2}.agregarCarga(vectorCarga2);
            
        end % aplicarCarga function
        
        function disp(cargaBielaTemperaturaObj)
            % disp: es un metodo de la clase CargaBielaTemperatura que se usa para imprimir en
            % command Window la informacion de la carga generada en los
            % nodos fruto de la diferencia de temperatura y el coeficiente
            % del material
            %
            % disp(cargaBielaTemperaturaObj)
            %
            % Imprime la informacion guardada en la carga fruto de la
            % diferencia de temperatura de la Biela (cargaBielaTemperaturaObj)
            % en pantalla
            
            fprintf('Propiedades carga biela temperatura:\n');
            disp@Carga(cargaBielaTemperaturaObj);
            
            % Obtiene la etiqueta del elemento
            etiqueta = cargaBielaTemperaturaObj.elemObj.obtenerEtiqueta();
            
            fprintf('\tCarga: %.3f aplicada en Elemento: %s producto de una diferencia de temperatura: %.3f\n', ...
                cargaBielaTemperaturaObj.carga, etiqueta, cargaBielaTemperaturaObj.deltaTemperatura);           
            dispMetodoTEFAME();
            
        end % disp function
        
    end % methods CargaBielaTemperatura
    
end % class CargaBielaTemperatura