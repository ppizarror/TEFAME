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
%       guardarCarga(cargaObj,p)
%       guardarDesplazamiento(cargaObj,u)
%       guardarVelocidad(cargaObj,v)
%       guardarAceleracion(cargaObj,a)
%       amortiguamientoRayleigh(cargaDinamicaObj,rayleigh)
%       usoDisipadores(cargaDinamicaObj,disipador)
%       descomposicionModal(cargaDinamicaObj,desmodal)
%       p = obtenerCarga(cargaObj)
%       u = obtenerDesplazamiento(cargaObj)
%       u = obtenerDesplazamientoTiempo(cargaObj,gdl,tiempo)
%       v = obtenerVelocidad(cargaObj)
%       a = obtenerAceleracion(cargaObj)
%       r = usoAmortiguamientoRayleigh(cargaDinamicaObj)
%       dm = usoDescomposicionModal(cargaDinamicaObj)
%       disipador = usoDeDisipadores(cargaDinamicaObj)
%  Methods SuperClass (ComponenteModelo):
%       etiqueta = obtenerEtiqueta(componenteModeloObj)
%       e = equals(componenteModeloObj,obj)

classdef CargaDinamica < ComponenteModelo
    
    properties(Access = protected)
        sol_u % Guarda la solucion de los desplazamientos
        sol_v % Guarda la solucion de las velocidades
        sol_a % Guarda la solucion de las aceleraciones
        sol_p % Guarda la carga generada
        cargaActiva % Indica si la carga esta activada o no
        cRayleigh % Indica que la carga se calculo con C de Rayleigh
        usoDisipador % Indica que se usaron disipadores
        desModal % Indica que la carga se calculo usando descomposicion modal
    end % properties CargaDinamica
    
    properties(Access = public)
        tAnalisis % Tiempo de analisis
        dt % Delta de tiempo
    end % properties CargaDinamica
    
    methods
        
        function cargaDinamicaObj = CargaDinamica(etiquetaCarga)
            % CargaDinamica: es el constructor de la clase CargaDinamica
            %
            % cargaDinamicaObj = CargaDinamica(etiquetaCarga)
            %
            % Crea un objeto de la clase CargaDinamica, con un identificador unico
            % (etiquetaCarga)
            
            if nargin == 0
                etiquetaCarga = '';
            end % if
            
            % Llamamos al cosntructor de la SuperClass que es la clase ComponenteModelo
            cargaDinamicaObj = cargaDinamicaObj@ComponenteModelo(etiquetaCarga);
            cargaDinamicaObj.cargaActiva = true;
            cargaDinamicaObj.cRayleigh = false;
            cargaDinamicaObj.usoDisipador = false;
            cargaDinamicaObj.desModal = false;
            
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
        
        function p = calcularCarga(cargaDinamicaObj, factor, m, r, dispinfo) %#ok<*STOUT,*VANUS,INUSD>
            % calcularCarga: es un metodo de la clase Carga que se usa para
            % calcular la carga a aplicar
            %
            % calcularCarga(cargaDinamicaObj,factor,m,r,dispinfo)
            
        end % calcularCarga function
        
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
        
        function amortiguamientoRayleigh(cargaDinamicaObj, rayleigh)
            % amortiguamientoRayleigh: Indica el tipo de amortiguamiento usado en el
            % calculo
            %
            % amortiguamientoRayleigh(cargaDinamicaObj,rayleigh)
            
            cargaDinamicaObj.cRayleigh = rayleigh;
            
        end % disipasionRayleigh
        
        function usoDisipadores(cargaDinamicaObj, disipador)
            % usoDisipadores: Indica que se usaron disipadores en el calculo
            %
            % usoDisipadores(cargaDinamicaObj,disipador)
            
            cargaDinamicaObj.usoDisipador = disipador;
            
        end % usoDisipadores function
        
        function descomposicionModal(cargaDinamicaObj, desmodal)
            % descomposicionModal: La carga se calculo usando
            % descomposicion modal
            %
            % descomposicionModal(cargaDinamicaObj,desmodal)
            
            cargaDinamicaObj.desModal = desmodal;
            
        end % descomposicionModal function
        
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
        
        function r = usoAmortiguamientoRayleigh(cargaDinamicaObj)
            % usoAmortiguamientoRayleighh: Indica que los resultados se
            % guardaron o no con la disipasion de Rayleigh
            %
            % r = usoAmortiguamientoRayleigh(cargaDinamicaObj)
            
            r = cargaDinamicaObj.cRayleigh;
            
        end % usoAmortiguamientoRayleigh function
        
        function disipador = usoDeDisipadores(cargaDinamicaObj)
            % usoDeDisipadores: Indica que la carga se calculo usando
            % disipadores
            %
            % disipador = usoDeDisipadores(cargaDinamicaObj)
            
            disipador = cargaDinamicaObj.usoDisipador;
            
        end % usoDeDisipadores function
        
        function dm = usoDescomposicionModal(cargaDinamicaObj)
            % usoDescomposicionModal: Indica que la carga se calculo usando
            % descomposicion modal
            %
            % dm = usoDescomposicionModal(cargaDinamicaObj)
            
            dm = cargaDinamicaObj.desModal;
            
        end % usoDescomposicionModal function
        
        function disp(cargaDinamicaObj)
            % disp: es un metodo de la clase CargaDinamica que se usa para imprimir en
            % command Window la informacion de la carga
            %
            % disp(cargaDinamicaObj)
            %
            % Imprime la informacion guardada en la carga (cargaDinamicaObj) en pantalla
            
            disp@ComponenteModelo(cargaDinamicaObj);
            
        end % disp function
        
    end % methods CargaDinamica
    
end % class CargaDinamica