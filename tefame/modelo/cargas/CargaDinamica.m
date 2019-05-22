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
%       cargaActiva
%       cargaFueCalculada
%       cRayleigh
%       desModal
%       factorCargaMasa
%       factorUnidadMasa
%       nodosCarga
%       sol_a
%       sol_u
%       sol_v
%       usoDisipador
%  Properties(Access=public):
%       tAnalisis
%       tInicio
%       dt
%  Methods:
%       obj = Carga(etiquetaCarga)
%       desactivarCarga(obj)
%       p = calcularCarga(obj,factor,m,r,dispinfo)
%       disp(obj)
%       y = cargaActivada(obj)
%       guardarCarga(obj,p)
%       guardarDesplazamiento(obj,u)
%       guardarVelocidad(obj,v)
%       guardarAceleracion(obj,a)
%       amortiguamientoRayleigh(obj,rayleigh)
%       usoDisipadores(obj,disipador)
%       descomposicionModal(obj,desmodal)
%       c = cargaSumaMasa(obj)
%       t = obtenerVectorTiempo(obj)
%       p = obtenerCarga(obj)
%       u = obtenerDesplazamiento(obj)
%       u = obtenerDesplazamientoTiempo(obj,gdl,tiempo)
%       v = obtenerVelocidad(obj)
%       a = obtenerAceleracion(obj)
%       r = usoAmortiguamientoRayleigh(obj)
%       dm = usoDescomposicionModal(obj)
%       disipador = usoDeDisipadores(obj)
%       masa = obtenerMasa(obj)
%       definirFactorUnidadMasa(obj,factor)
%       definirFactorCargaMasa(obj,factor)
%       nodos = obtenerNodos(obj)
%       activarCarga(obj)
%       establecerCargaCalculada(obj)
%       c = cargaCalculada(obj)
%       bloquearCargaMasa(obj)
%  Methods SuperClass (ComponenteModelo):
%       etiqueta = obtenerEtiqueta(obj)
%       e = equals(obj,obj)
%       objID = obtenerIDObjeto(obj)

classdef CargaDinamica < ComponenteModelo
    
    properties(Access = private)
        cargaSumoMasa % Indica que la carga ya sumo masa
    end % properties CargaDinamica
    
    properties(Access = protected)
        cargaActiva % Indica si la carga esta activada o no
        cargaFueCalculada % La carga fue calculada o no
        cRayleigh % Indica que la carga se calculo con C de Rayleigh
        desModal % Indica que la carga se calculo usando descomposicion modal
        factorCargaMasa % Factor de masa de la carga
        factorUnidadMasa % Factor unidad de la masa
        nodosCarga % Nodos que participan en la carga
        sol_a % Guarda la solucion de las aceleraciones
        sol_p % Guarda la carga generada
        sol_u % Guarda la solucion de los desplazamientos
        sol_v % Guarda la solucion de las velocidades
        usoDisipador % Indica que se usaron disipadores
    end % properties CargaDinamica
    
    properties(Access = public)
        tAnalisis % Tiempo de analisis
        tInicio % Tiempo de inicio
        dt % Delta de tiempo
    end % properties CargaDinamica
    
    methods
        
        function obj = CargaDinamica(etiquetaCarga)
            % CargaDinamica: es el constructor de la clase CargaDinamica
            %
            % Crea un objeto de la clase CargaDinamica, con un identificador unico
            % (etiquetaCarga)
            
            if nargin == 0
                etiquetaCarga = '';
            end % if
            
            % Llamamos al constructor de la SuperClass que es la clase ComponenteModelo
            obj = obj@ComponenteModelo(etiquetaCarga);
            obj.cargaActiva = true;
            obj.cRayleigh = false;
            obj.usoDisipador = false;
            obj.desModal = false;
            obj.factorUnidadMasa = 1;
            obj.factorCargaMasa = 0;
            obj.cargaFueCalculada = false;
            
            % Define algunos parametros iniciales
            obj.tInicio = 0;
            obj.dt = 1;
            obj.tAnalisis = 0;
            obj.cargaSumoMasa = false;
            
        end % CargaDinamica constructor
        
        function bloquearCargaMasa(obj)
            % bloquearCargaMasa: La carga deja de sumar masa
            
            obj.cargaSumoMasa = true;
            
        end % bloquearCargaMasa function
        
        function c = cargaSumaMasa(obj)
            % cargaSumaMasa: Indica que la carga suma masa al sistema
            
            c = ~obj.cargaSumoMasa;
            
        end % cargaSumaMasa function
        
        function t = obtenerVectorTiempo(obj)
            % obtenerVectorTiempo: Obtiene el vector de tiempo que define
            % la carga
            
            nt = obj.tAnalisis / obj.dt;
            t = linspace(obj.tInicio, obj.tInicio+obj.tAnalisis, nt);
            
        end % obtenerVectorTiempo function
        
        function activarCarga(obj)
            % activarCarga: Activa la carga para el analisis
            
            obj.cargaActiva = true;
            
        end % activarCarga function
        
        function desactivarCarga(obj)
            % desactivarCarga: Desactiva la carga para el analisis
            
            obj.cargaActiva = false;
            
        end % desactivarCarga function
        
        function y = cargaActivada(obj)
            % cargaActivada: Indica si la carga esta activada para el
            % analisis
            
            y = obj.cargaActiva;
            
        end % cargaActivada function
        
        function p = calcularCarga(obj, factor, m, r, dispinfo) %#ok<*STOUT,*VANUS,INUSD>
            % calcularCarga: es un metodo de la clase CargaDinamica que se usa para
            % calcular la carga a aplicar
            
        end % calcularCarga function
        
        function guardarCarga(obj, p)
            % guardarCarga: Guarda la carga generada
            
            obj.sol_p = p;
            
        end % guardarCarga function
        
        function guardarDesplazamiento(obj, u)
            % guardarDesplazamiento: Guarda el desplazamiento de la carga
            
            obj.sol_u = u;
            
        end % guardarDesplazamiento function
        
        function guardarVelocidad(obj, v)
            % guardarVelocidad: Guarda la velocidad de la carga
            
            obj.sol_v = v;
            
        end % guardarVelocidad function
        
        function guardarAceleracion(obj, a)
            % guardarAceleracion: Guarda la aceleracion de la carga
            
            obj.sol_a = a;
            
        end % guardarAceleracion function
        
        function amortiguamientoRayleigh(obj, rayleigh)
            % amortiguamientoRayleigh: Indica el tipo de amortiguamiento usado en el
            % calculo
            
            obj.cRayleigh = rayleigh;
            
        end % disipasionRayleigh
        
        function usoDisipadores(obj, disipador)
            % usoDisipadores: Indica que se usaron disipadores en el calculo
            
            obj.usoDisipador = disipador;
            
        end % usoDisipadores function
        
        function descomposicionModal(obj, desmodal)
            % descomposicionModal: La carga se calculo usando
            % descomposicion modal
            
            obj.desModal = desmodal;
            
        end % descomposicionModal function
        
        function p = obtenerCarga(obj)
            % obtenerCarga: Obtiene la carga generada
            
            p = obj.sol_p;
            
        end % obtenerCarga function
        
        function u = obtenerDesplazamiento(obj)
            % obtenerDesplazamiento: Obtiene el desplazamiento de la carga
            
            u = obj.sol_u;
            
        end % obtenerDesplazamiento function
        
        function u = obtenerDesplazamientoTiempo(obj, gdl, tiempo)
            % obtenerDesplazamientoTiempo obtiene el desplazamiento de un
            % grado de libertad en un determinado tiempo
            
            if tiempo < 0 % Retorna el maximo
                u = max(obj.sol_u(gdl, :));
            else
                u = obj.sol_u(gdl, tiempo);
            end
            
        end % obtenerDesplazamientoTiempo function
        
        function v = obtenerVelocidad(obj)
            % obtenerVelocidad: Obtiene la velocidad de la carga
            
            v = obj.sol_v;
            
        end % obtenerVelocidad function
        
        function a = obtenerAceleracion(obj)
            % obtenerAceleracion: Obtiene la aceleracion de la carga
            
            a = obj.sol_a;
            
        end % obtenerAceleracion function
        
        function r = usoAmortiguamientoRayleigh(obj)
            % usoAmortiguamientoRayleighh: Indica que los resultados se
            % guardaron o no con la disipasion de Rayleigh
            
            r = obj.cRayleigh;
            
        end % usoAmortiguamientoRayleigh function
        
        function disipador = usoDeDisipadores(obj)
            % usoDeDisipadores: Indica que la carga se calculo usando
            % disipadores
            
            disipador = obj.usoDisipador;
            
        end % usoDeDisipadores function
        
        function dm = usoDescomposicionModal(obj)
            % usoDescomposicionModal: Indica que la carga se calculo usando
            % descomposicion modal
            
            dm = obj.desModal;
            
        end % usoDescomposicionModal function
        
        function disp(obj)
            % disp: es un metodo de la clase CargaDinamica que se usa para imprimir en
            % command Window la informacion de la carga
            %
            % Imprime la informacion guardada en la carga (obj) en pantalla
            
            disp@ComponenteModelo(obj);
            % No usar dispMetodoTEFAME()
            
        end % disp function
        
        function masa = obtenerMasa(obj) %#ok<MANU>
            % obtenerMasa: Obtiene la masa de la carga
            
            masa = 0;
            
        end % obtenerMasa function
        
        function definirFactorUnidadMasa(obj, factor)
            % definirFactorUnidadMasa: Define el factor de conversion de
            % unidades de la carga a unidades de masa
            
            obj.factorUnidadMasa = factor;
            
        end % definirFactorUnidadMasa function
        
        function definirFactorCargaMasa(obj, factor)
            % definirFactorCargaMasa: Define cuanto porcentaje de la carga
            % se convierte en masa
            
            obj.factorCargaMasa = factor;
            
        end % definirFactorCargaMasa function
        
        function nodos = obtenerNodos(obj)
            % obtenerNodos: Retorna los nodos de la carga
            
            nodos = obj.nodosCarga;
            
        end % obtenerNodos function
        
        function establecerCargaCalculada(obj)
            % establecerCargaCalculada: Establece la carga como calculada
            
            obj.cargaFueCalculada = true;
            
        end % establecerCargaCalculada function
        
        function c = cargaCalculada(obj)
            % cargaCalculada: Indica si la carga fue calculada o no
            
            c = obj.cargaFueCalculada && obj.cargaActiva;
            
        end % cargaCalculada function
        
    end % methods CargaDinamica
    
end % class CargaDinamica