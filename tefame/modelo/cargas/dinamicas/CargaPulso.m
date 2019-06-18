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
%| Clase CargaPulso                                                     |
%|                                                                      |
%| Este archivo contiene la definicion de la Clase CargaPulso           |
%| CargaPulso es una subclase de la clase CargaDinamica y corresponde a |
%| la representacion de una carga nodal en el metodo de elementos       |
%| finitos o analisis matricial de estructuras.                         |
%| La clase CargaPulso es una clase que contiene el nodo al que se le   |
%| va aplicar la carga y el valor de esta carga.                        |
%|                                                                      |
%| Programado: Pablo Pizarro @ppizarror                                 |
%| Fecha: 10/04/2019                                                    |
%|______________________________________________________________________|
%
%  Methods(Access=public):
%       CargaPulso(etiquetaCargaPulso,nodos,direccion,amplitud,tpulso,dt,tInicio,tAnalisis)
%       aplicarCarga(obj,factorDeCarga)
%       disp(obj)
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

classdef CargaPulso < CargaDinamica
    
    properties(Access = private)
        amplitud % Ampitud de la carga
        direccion % Vector de direcciones
        intervalos % Intervalos
        nodos % Nodo al que se aplica la carga
        tpulso % Tiempo de aplicacion del pulso
    end % private properties CargaPulso
    
    methods(Access = public)
        
        function obj = CargaPulso(etiquetaCargaPulso, nodos, direccion, amplitud, tpulso, dt, tInicio, tAnalisis)
            % CargaPulso: es el constructor de la clase CargaPulso
            %
            % Crea una carga tipo pulso
            
            if nargin == 0
                etiquetaCargaPulso = '';
            end
            
            % Llamamos al constructor de la SuperClass que es la clase Carga
            obj = obj@CargaDinamica(etiquetaCargaPulso);
            
            % Verifica que nodos sea un cell
            if ~iscell(nodos)
                nodos = {nodos};
            end
            
            % Verifica que tenga sentido la direccion
            if ~verificarVectorDireccion(direccion, nodos{1}.obtenerNumeroGDL())
                error('Vector direccion mal definido');
            end
            
            % Chequea que los tiempos esten bien definidos
            if tAnalisis < 0 || tInicio < 0 || dt <= 0
                error('Tiempo de carga mal definido');
            end
            
            % Guarda el registro
            obj.amplitud = amplitud;
            obj.direccion = direccion;
            obj.dt = dt;
            obj.nodos = nodos; % Objeto del nodo donde se aplica la carga
            obj.tAnalisis = tAnalisis;
            obj.tpulso = tpulso;
            
        end % CargaPulso constructor
        
        function p = calcularCarga(obj, ~, m, ~, dispinfo)
            % calcularCarga: es un metodo de la clase Carga que se usa para
            % calcular la carga a aplicar
            
            % Crea la matriz de carga
            ng = length(m);
            nt = obj.tAnalisis / obj.dt;
            p = zeros(ng, nt);
            
            % Crea el vector de influencia
            rf = zeros(ng, 1);
            
            % Recorre cada carga
            for k = 1:length(obj.nodos)
                
                nodo = obj.nodos{k};
                if dispinfo
                    fprintf('\t\t\t\tAplicando carga a nodo %s\n', nodo.obtenerEtiqueta());
                end
                
                nodoGDL = nodo.obtenerGDLIDCondensado();
                
                % Verifica que la direccion no sea mayor que el numero de nodos
                if length(nodoGDL) < length(obj.direccion)
                    error('Las direcciones de analisis superan el numero de direcciones del nodo %s', ...
                        nodo.obtenerEtiqueta());
                end
                
                gdl = 0;
                for i = 1:length(obj.direccion)
                    if obj.direccion(i) ~= 0
                        gdl = nodoGDL(i); % Obtiene el GDL asociado
                        if gdl > 0
                            rf(gdl) = 1;
                            if dispinfo
                                fprintf('\t\t\t\t\tSe aplica la carga en el grado condensado %d\n', gdl);
                            end
                        end
                    end
                end % for i
                
                % Verifica que el grado sea valido
                if gdl == 0
                    error('No es posible aplicar la carga en un grado condensado del nodo %s', ...
                        nodo.obtenerEtiqueta());
                end
                
            end % for k
            
            % Carga pulso
            t = linspace(0, obj.tAnalisis, nt);
            for i = 1:nt
                if t(i) <= obj.tpulso
                    p(:, i) = rf .* obj.amplitud;
                else
                    break;
                end
            end % for i
            
            if dispinfo
                fprintf('\t\t\t\tLa carga es aplicada en %d/%d (%.2f%%) de la matriz de cargas totales\n', ...
                    i-1, nt, ((i - 1) / nt)*100);
            end
            
        end % calcularCarga function
        
        function disp(obj)
            % disp: es un metodo de la clase CargaPulso que se usa para imprimir en
            % command Window la informacion de la carga del tipo registro
            % sismico
            %
            % Imprime la informacion guardada en la carga (obj) en pantalla
            
            fprintf('Propiedades carga pulso:\n');
            disp@CargaDinamica(obj);
            dispMetodoTEFAME();
            
        end % disp function
        
    end % public methods CargaPulso
    
end % class CargaPulso