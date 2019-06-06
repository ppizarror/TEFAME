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
%| Clase CargaSinusoidal                                                |
%|                                                                      |
%| Este archivo contiene la definicion de la Clase CargaSinusoidal      |
%| CargaSinusoidal es una subclase de la clase CargaDinamica y          |
%| corresponde a la representacion de una carga sinusoidal en el metodo |
%| de elementos finitos o analisis matricial de estructuras.            |
%| La clase CargaSinusoidal es una clase que contiene el nodo al que se |
%| le va aplicar la carga y el valor de esta carga.                     |
%|                                                                      |
%| Programado: Pablo Pizarro @ppizarror                                 |
%| Fecha: 10/04/2019                                                    |
%|______________________________________________________________________|
%
%  Properties (Access=private):
%       amplitud
%       direccion
%       nodo
%       registro
%       tOscilacion
%       w
%  Methods:
%       CargaSinusoidal(etiquetaCargaSinusoidal,registro,direccion,dt,tAnalisis)
%       aplicarCarga(CargaSinusoidalObj,factorDeCarga)
%       disp(CargaSinusoidalObj)
%  Methods SuperClass (CargaDinamica):
%       cargaDinamicaObj = Carga(etiquetaCarga)
%       desactivarCarga(cargaDinamicaObj)
%       p = calcularCarga(cargaDinamicaObj,factor,m,r,dispinfo)
%       disp(cargaDinamicaObj)
%       y = cargaActivada(cargaDinamicaObj)
%       guardarCarga(cargaDinamicaObj,p)
%       guardarDesplazamiento(cargaDinamicaObj,u)
%       guardarVelocidad(cargaDinamicaObj,v)
%       guardarAceleracion(cargaDinamicaObj,a)
%       amortiguamientoRayleigh(cargaDinamicaObj,rayleigh)
%       usoDisipadores(cargaDinamicaObj,disipador)
%       descomposicionModal(cargaDinamicaObj,desmodal)
%       c = cargaSumaMasa(cargaDinamicaObj)
%       t = obtenerVectorTiempo(cargaDinamicaObj)
%       p = obtenerCarga(cargaDinamicaObj)
%       u = obtenerDesplazamiento(cargaDinamicaObj)
%       u = obtenerDesplazamientoTiempo(cargaDinamicaObj,gdl,tiempo)
%       v = obtenerVelocidad(cargaDinamicaObj)
%       a = obtenerAceleracion(cargaDinamicaObj)
%       r = usoAmortiguamientoRayleigh(cargaDinamicaObj)
%       dm = usoDescomposicionModal(cargaDinamicaObj)
%       disipador = usoDeDisipadores(cargaDinamicaObj)
%       masa = obtenerMasa(cargaDinamicaObj)
%       definirFactorUnidadMasa(cargaDinamicaObj,factor)
%       definirFactorCargaMasa(cargaDinamicaObj,factor)
%       nodos = obtenerNodos(cargaDinamicaObj)
%       activarCarga(cargaDinamicaObj)
%       establecerCargaCalculada(cargaDinamicaObj)
%       c = cargaCalculada(cargaDinamicaObj)
%       bloquearCargaMasa(cargaDinamicaObj)
%  Methods SuperClass (ComponenteModelo):
%       etiqueta = obtenerEtiqueta(obj)
%       e = equals(obj,obj)
%       objID = obtenerIDObjeto(obj)

classdef CargaSinusoidal < CargaDinamica
    
    properties(Access = private)
        amplitud % Amplitud de la carga
        direccion % Vector de direcciones
        nodo % Nodo al que se aplica la carga
        registro % Matriz del registro
        tOscilacion % Tiempo de oscilacion
        w % Frecuencia de la carga
    end % private properties CargaSinusoidal
    
    methods(Access = public)
        
        function obj = CargaSinusoidal(etiquetaCargaSinusoidal, nodo, direccion, amplitud, w, tOscilacion, dt, tInicio, tAnalisis)
            % CargaSinusoidal: es el constructor de la clase CargaSinusoidal
            %
            % Crea una carga del tipo sinusoidal
            
            if nargin == 0
                etiquetaCargaSinusoidal = '';
            end % if
            
            % Llamamos al constructor de la SuperClass que es la clase Carga
            obj = obj@CargaDinamica(etiquetaCargaSinusoidal);
            
            % Verifica que tenga sentido la direccion
            if ~verificarVectorDireccion(direccion, nodo.obtenerNumeroGDL())
                error('Vector direccion mal definido');
            end
            
            % Chequea que los tiempos esten bien definidos
            if tAnalisis < 0 || tInicio < 0 || dt <= 0
                error('Tiempo de carga mal definido');
            end
            
            % Guarda los parametros de la carga
            obj.w = w;
            obj.amplitud = amplitud;
            obj.direccion = direccion;
            obj.tOscilacion = tOscilacion;
            obj.tAnalisis = tAnalisis;
            obj.tInicio = tInicio;
            obj.dt = dt;
            obj.nodo = nodo; % Nodo al que se le aplica la carga
            obj.nodosCarga = {nodo};
            
        end % CargaSinusoidal constructor
        
        function p = calcularCarga(CargaSinusoidalObj, ~, m, ~, dispinfo)
            % calcularCarga: es un metodo de la clase Carga que se usa para
            % calcular la carga a aplicar
            
            % Crea la matriz de carga
            ng = length(m);
            nint = CargaSinusoidalObj.tOscilacion / CargaSinusoidalObj.dt;
            nt = CargaSinusoidalObj.tAnalisis / CargaSinusoidalObj.dt; % Nro de intervalos
            p = zeros(ng, nt);
            if dispinfo
                fprintf('\t\t\t\tAplicando carga a nodo %s\n', CargaSinusoidalObj.nodo.obtenerEtiqueta());
            end
            
            % Crea el vector de influencia
            rf = zeros(ng, 1);
            nodoGDL = CargaSinusoidalObj.nodo.obtenerGDLIDCondensado();
            
            % Verifica que la direccion no sea mayor que el numero de nodos
            if length(nodoGDL) < length(CargaSinusoidalObj.direccion)
                error('Las direcciones de analisis superan el numero de direcciones del nodo %s', ...
                    CargaSinusoidalObj.nodo.obtenerEtiqueta());
            end
            
            gdl = 0;
            for i = 1:length(CargaSinusoidalObj.direccion)
                if CargaSinusoidalObj.direccion(i) > 0
                    gdl = nodoGDL(i); % Obtiene el GDL asociado
                    if gdl > 0
                        rf(gdl) = 1;
                        if dispinfo
                            fprintf('\t\t\t\tSe aplica la carga en el grado condensado %d\n', gdl);
                        end
                    end
                end
            end % for i
            
            % Verifica que el grado sea valido
            if gdl == 0
                error('No es posible aplicar la carga en un grado condensado del nodo %s', ...
                    CargaPulsoObj.nodo.obtenerEtiqueta());
            end
            
            % Carga sinusoidal
            t = linspace(0, CargaSinusoidalObj.tOscilacion, nint);
            carga = zeros(1, length(t));
            for i = 1:length(t)
                carga(i) = CargaSinusoidalObj.amplitud * sin(CargaSinusoidalObj.w*t(i));
            end % for i
            for i = 1:nt
                if i < length(t)
                    p(:, i) = rf .* carga(i);
                else
                    break;
                end
            end % for i
            
            if dispinfo
                fprintf('\t\t\t\tLa carga es aplicada en %d/%d (%.2f%%) de la matriz de cargas totales\n', ...
                    i, nt, (i / nt)*100);
            end
            
        end % calcularCarga function
        
        function disp(CargaSinusoidalObj)
            % disp: es un metodo de la clase CargaDinamica que se usa para imprimir en
            % command Window la informacion de la carga del tipo sinusoidal
            %
            % Imprime la informacion guardada en la carga (CargaSinusoidalObj) en pantalla
            
            fprintf('Propiedades carga sinusoidal:\n');
            disp@CargaDinamica(CargaSinusoidalObj);
            dispMetodoTEFAME();
            
        end % disp function
        
    end % public methods CargaSinusoidal
    
end % class CargaSinusoidal