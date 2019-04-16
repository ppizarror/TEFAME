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
%| Clase CargaDinamica                                                  |
%|                                                                      |
%| Este archivo contiene la definicion de la Clase CargaDinamica        |
%| Carga  es una  subclase  de la  clase ComponenteModelo y corresponde |
%| a la representacion  de una carga dinamica, la cual se ejecuta y     |
%| guarda los resultados del analisis en la carga misma.                |
%| La clase  Carga se usa  como una superclase  para todos los tipos de |
%| cargas dinamicas a aplicar                                           |
%|                                                                      |
%| Programado: Pablo Pizarro @ppizarror                                 |
%| Fecha: 10/04/2019                                                    |
%|______________________________________________________________________|
%
%  Properties (Access=private):
%       sol_u
%       sol_v
%       sol_a
%  Methods:
%       cargaObj = Carga(etiquetaCarga)
%       aplicarCarga(cargaObj)
%       disp(cargaObj)
%       guardarDesplazamiento(cargaObj,u)
%       guardarVelocidad(cargaObj,v)
%       guardarAceleracion(cargaObj,a)
%       u = obtenerDesplazamiento(cargaObj)
%       v = obtenerVelocidad(cargaObj)
%       a = obtenerAceleracion(cargaObj)
%  Methods SuperClass (ComponenteModelo):
%       etiqueta = obtenerEtiqueta(componenteModeloObj)

classdef CargaDinamica < ComponenteModelo
    
    properties(Access = private)
        sol_u % Guarda la solucion de los desplazamientos
        sol_v % Guarda la solucion de las velocidades
        sol_a % Guarda la solucion de las aceleraciones
    end % properties CargaDinamica
    
    properties(Access = public)
        tAnalisis % Tiempo de analisis
        dt % Delta de tiempo
    end % properties CargaDinamica
    
    methods
        
        function cargaDinamicaObj = CargaDinamica(etiquetaCarga)
            % CargaDinamica: es el constructor de la clase CargaDinamica
            %
            % cargaObj = Carga(etiquetaCarga)
            % Crea un objeto de la clase CargaDinamica, con un identificador unico
            % (etiquetaCarga)
            
            if nargin == 0
                etiquetaCarga = '';
            end % if
            
            %Llamamos al cosntructor de la SuperClass que es la clase ComponenteModelo
            cargaDinamicaObj = cargaDinamicaObj@ComponenteModelo(etiquetaCarga);
            
        end % CargaDinamica constructor
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Metodos para calcular la carga
        
        function p = calcularCarga(cargaObj, varargin) %#ok<*STOUT,*VANUS,INUSD>
            % calcularCarga: es un metodo de la clase Carga que se usa para
            % calcular la carga a aplicar
            %
            % calcularCarga(cargaObj)
            
        end % calcularCarga function
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Metodos para guardar los resultados
        
        function guardarDesplazamiento(cargaObj, u)
            % guardarDesplazamiento: Guarda el desplazamiento de la carga
            %
            % guardarDesplazamiento(cargaObj,u)
            
            cargaObj.sol_u = u;
            
        end % guardarDesplazamiento function
        
        function guardarVelocidad(cargaObj, v)
            % guardarVelocidad: Guarda la velocidad de la carga
            %
            % guardarVelocidad(cargaObj,v)
            
            cargaObj.sol_v = v;
            
        end % guardarVelocidad function
        
        function guardarAceleracion(cargaObj, a)
            % guardarAceleracion: Guarda el desplazamiento de la carga
            %
            % guardarAceleracion(cargaObj,a)
            
            cargaObj.sol_a = a;
            
        end % guardarAceleracion function
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Metodos para obtener los resultados
        
        function u = obtenerDesplazamiento(cargaObj)
            % obtenerDesplazamiento: Obtiene el desplazamiento de la carga
            %
            % obtenerDesplazamiento(cargaObj)
            
            u = cargaObj.sol_u;
            
        end % obtenerDesplazamiento function
        
        function v = obtenerVelocidad(cargaObj)
            % obtenerVelocidad: Obtiene la velocidad de la carga
            %
            % obtenerVelocidad(cargaObj)
            
            v = cargaObj.sol_v;
            
        end % obtenerVelocidad function
        
        function a = obtenerAceleracion(cargaObj)
            % obtenerAceleracion: Obtiene la aceleracion de la carga
            %
            % obtenerAceleracion(cargaObj)
            
            a = cargaObj.sol_a;
            
        end % obtenerAceleracion function
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Metodos para mostrar la informacion de la carga en pantalla
        
        function disp(cargaObj)
            % disp: es un metodo de la clase CargaDinamica que se usa para imprimir en
            % command Window la informacion de la carga
            %
            % disp(cargaObj)
            % Imprime la informacion guardada en la carga (cargaObj) en pantalla
            
            disp@ComponenteModelo(cargaObj);
            
        end % disp function
        
    end % methods CargaDinamica
    
end % class CargaDinamica