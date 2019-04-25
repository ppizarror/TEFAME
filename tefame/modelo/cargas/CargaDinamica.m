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
%  Properties(Access=private):
%       sol_u
%       sol_v
%       sol_a
%       cargaActiva
%  Properties(Access=public):
%       tAnalisis
%       dt
%  Methods:
%       cargaObj = Carga(etiquetaCarga)
%       aplicarCarga(cargaObj)
%       disp(cargaObj)
%       guardarDesplazamiento(cargaObj,u)
%       guardarVelocidad(cargaObj,v)
%       guardarAceleracion(cargaObj,a)
%       guardarCarga(cargaObj,p)
%       p = obtenerCarga(cargaObj)
%       u = obtenerDesplazamiento(cargaObj)
%       u = obtenerDesplazamientoTiempo(cargaObj,gdl,tiempo)
%       v = obtenerVelocidad(cargaObj)
%       a = obtenerAceleracion(cargaObj)
%  Methods SuperClass (ComponenteModelo):
%       etiqueta = obtenerEtiqueta(componenteModeloObj)

classdef CargaDinamica < ComponenteModelo
    
    properties(Access = private)
        sol_u % Guarda la solucion de los desplazamientos
        sol_v % Guarda la solucion de las velocidades
        sol_a % Guarda la solucion de las aceleraciones
        sol_p % Guarda la carga generada
        cargaActiva % Indica si la carga esta activada o no
        c_rayleigh % Indica que la carga se calculo con C de Rayleigh
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
            
            % Llamamos al cosntructor de la SuperClass que es la clase ComponenteModelo
            cargaDinamicaObj = cargaDinamicaObj@ComponenteModelo(etiquetaCarga);
            cargaDinamicaObj.cargaActiva = true;
            cargaDinamicaObj.c_rayleigh = false;
            
        end % CargaDinamica constructor
        
        function activarCarga(cargaDinamicaObj)
            % activarCarga: Activa la carga para el analisis
            
            cargaDinamicaObj.cargaActiva = true;
            
        end % activarCarga function
        
        function desactivarCarga(cargaDinamicaObj)
            % desactivarCarga: Desactiva la carga para el analisis
            
            cargaDinamicaObj.cargaActiva = false;
            
        end % desactivarCarga function
        
        function y = cargaActivada(cargaDinamicaObj)
            % cargaActivada: Indica si la carga esta activada para el
            % analisis
            %
            % y = cargaActivada(cargaDinamicaObj)
            
            y = cargaDinamicaObj.cargaActiva;
            
        end % cargaActivada function
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Metodos para calcular la carga
        
        function p = calcularCarga(cargaDinamicaObj, varargin) %#ok<*STOUT,*VANUS,INUSD>
            % calcularCarga: es un metodo de la clase Carga que se usa para
            % calcular la carga a aplicar
            %
            % calcularCarga(cargaDinamicaObj,'var1',var,'var2',var)
            
        end % calcularCarga function
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Metodos para guardar los resultados
        
        function guardarCarga(cargaDinamicaObj, p)
            % guardarCarga: Guarda la carga generada
            %
            % guardarCarga(cargaDinamicaObj,u)
            
            cargaDinamicaObj.sol_p = p;
            
        end % guardarCarga function
        
        function guardarDesplazamiento(cargaDinamicaObj, u)
            % guardarDesplazamiento: Guarda el desplazamiento de la carga
            %
            % guardarDesplazamiento(cargaDinamicaObj,u)
            
            cargaDinamicaObj.sol_u = u;
            
        end % guardarDesplazamiento function
        
        function guardarVelocidad(cargaDinamicaObj, v)
            % guardarVelocidad: Guarda la velocidad de la carga
            %
            % guardarVelocidad(cargaDinamicaObj,v)
            
            cargaDinamicaObj.sol_v = v;
            
        end % guardarVelocidad function
        
        function guardarAceleracion(cargaDinamicaObj, a)
            % guardarAceleracion: Guarda la aceleracion de la carga
            %
            % guardarAceleracion(cargaDinamicaObj,a)
            
            cargaDinamicaObj.sol_a = a;
            
        end % guardarAceleracion function
        
        function disipasionRayleigh(cargaDinamicaObj, rayleigh)
            % disipasionRayleigh: Indica el tipo de disipasion usado en el
            % calculo
            %
            % disipasionRayleigh(cargaDinamicaObj,rayleigh)
            
            cargaDinamicaObj.c_rayleigh = rayleigh;
            
        end % disipasionRayleigh
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Metodos para obtener los resultados
        
        function p = obtenerCarga(cargaDinamicaObj)
            % obtenerCarga: Obtiene la carga generada
            %
            % obtenerCarga(cargaDinamicaObj)
            
            p = cargaDinamicaObj.sol_p;
            
        end % obtenerCarga function
        
        function u = obtenerDesplazamiento(cargaDinamicaObj)
            % obtenerDesplazamiento: Obtiene el desplazamiento de la carga
            %
            % obtenerDesplazamiento(cargaDinamicaObj)
            
            u = cargaDinamicaObj.sol_u;
            
        end % obtenerDesplazamiento function
        
        function u = obtenerDesplazamientoTiempo(cargaDinamicaObj, gdl, tiempo)
            % obtenerDesplazamientoTiempo obtiene el desplazamiento de un
            % grado de libertad en un determinado tiempo
            %
            % u = obtenerDesplazamientoTiempo(cargaDinamicaObj,gdl,tiempo)
            
            if tiempo < 0 % Retorna el maximo
                u = max(cargaDinamicaObj.sol_u(gdl, :));
            else
                u = cargaDinamicaObj.sol_u(gdl, tiempo);
            end
            
        end % obtenerDesplazamientoTiempo function
        
        function v = obtenerVelocidad(cargaDinamicaObj)
            % obtenerVelocidad: Obtiene la velocidad de la carga
            %
            % obtenerVelocidad(cargaDinamicaObj)
            
            v = cargaDinamicaObj.sol_v;
            
        end % obtenerVelocidad function
        
        function a = obtenerAceleracion(cargaDinamicaObj)
            % obtenerAceleracion: Obtiene la aceleracion de la carga
            %
            % obtenerAceleracion(cargaDinamicaObj)
            
            a = cargaDinamicaObj.sol_a;
            
        end % obtenerAceleracion function
        
        function r = metodoDisipasionRayleigh(cargaDinamicaObj)
            % metodoDisipasionRayleigh: Indica que los resultados se
            % guardaron o no con la disipasion de Rayleigh
            
            r = cargaDinamicaObj.c_rayleigh;
            
        end % metodoDisipasionRayleigh function
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Metodos para mostrar la informacion de la carga en pantalla
        
        function disp(cargaDinamicaObj)
            % disp: es un metodo de la clase CargaDinamica que se usa para imprimir en
            % command Window la informacion de la carga
            %
            % disp(cargaDinamicaObj)
            % Imprime la informacion guardada en la carga (cargaDinamicaObj) en pantalla
            
            disp@ComponenteModelo(cargaDinamicaObj);
            
        end % disp function
        
    end % methods CargaDinamica
    
end % class CargaDinamica