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
%| Clase CombinacionCargas                                              |
%|                                                                      |
%| Este archivo contiene la definicion de la Clase CombinacionCargas    |
%| CombinacionCargas es una subclase  de la clase ComponenteModelo y    |
%| corresponde a la representacion de una combinacion de cargas en el   |
%| metodo de elementos  finitos o analisis matricial de estructuras.    |
%|                                                                      |
%| Programado: Pablo Pizarro @ppizarror                                 |
%| Fecha: 08/05/2019                                                    |
%|______________________________________________________________________|
%
%  Properties (Access=private):
%       cargas
%  Methods:
%       a = obtenerAceleracion(obj)
%       obj = CombinacionCargas(etiquetaCombinacion,cargas)
%       disp(obj)
%       p = obtenerCarga(obj)
%       t = dt(obj)
%       t = obtenerVectorTiempo(obj)
%       t = tAnalisis(obj)
%       u = obtenerDesplazamiento(obj)
%       u = obtenerDesplazamientoTiempo(obj,gdl,tiempo)
%       v = obtenerVelocidad(obj)
%  Methods SuperClass (ComponenteModelo):
%       etiqueta = obtenerEtiqueta(obj)
%       e = equals(obj,obj)
%       objID = obtenerIDObjeto(obj)

classdef CombinacionCargas < ComponenteModelo
    
    properties(Access = private)
        cargas % Arreglo de cargas
        uGuardado % Guarda el arreglo
    end % private properties CombinacionCargas
    
    methods(Access = public)
        
        function obj = CombinacionCargas(etiquetaCombinacion, cargas)
            % CombinacionCargas: Es el constructor de la clase, requiere el
            % nombre de la combinacion y un cell de cargas
            
            if nargin == 0
                etiquetaCombinacion = '';
            end
            
            % Llamamos al constructor de la SuperClass que es la clase ComponenteModelo
            obj = obj@ComponenteModelo(etiquetaCombinacion);
            
            % Chequea que todas las cargas sean dinamicas
            for i = 1:length(cargas)
                if ~isa(cargas{i}, 'CargaDinamica')
                    error('Carga %s debe ser dinamica', cargas{i}.obtenerEtiqueta());
                end
                if ~cargas{i}.cargaActivada()
                    error('Carga %s esta desactivada', cargas{i}.obtenerEtiqueta());
                end
            end % for i
            
            % Guarda datos
            obj.cargas = cargas;
            obj.uGuardado = [];
            
        end % CombinacionCargas constructor
        
        function t = obtenerVectorTiempo(obj)
            % obtenerVectorTiempo: Retorna el vector de tiempo
            
            [~, t] = obtenerDtMinimo(obj);
            
        end % obtenerVectorTiempo function
        
        function p = obtenerCarga(obj)
            % obtenerCarga: Obtiene la carga de la combinacion de cargas
            
            % Genera el arreglo de tiempo de interpolacion
            [dt, t] = obtenerDtMinimo(obj);
            [ngdlf, ~] = size(obj.cargas{1}.obtenerCarga());
            
            % Genera el vector final
            p = zeros(ngdlf, length(t));
            
            % Interpola cada carga
            for i = 1:length(obj.cargas)
                
                [ndg, ~] = size(obj.cargas{i}.obtenerCarga());
                if ndg ~= ngdlf
                    error('Grado de libertad de la carga no corresponde con la combinacion de cargas');
                end
                
                x = obj.reshapeMatrix(obj.cargas{i}.obtenerCarga(), ...
                    obj.cargas{i}.tInicio, obj.cargas{i}.dt, ...
                    obj.cargas{i}.tAnalisis, dt, t, ...
                    obj.cargas{i}.obtenerEtiqueta());
                [~, lx] = size(x);
                
                % Suma el vector
                j = 1;
                for k = 1:length(t)
                    if t(k) >= obj.cargas{i}.tInicio
                        p(:, k) = p(:, k) + x(:, j);
                        j = j + 1;
                    end
                    if j > lx
                        break;
                    end
                end % for k
                
            end % for i
            
        end % obtenerCarga function
        
        function u = obtenerDesplazamiento(obj)
            % obtenerDesplazamiento: Obtiene el desplazamiento de la
            % combinacion de cargas
            
            % Genera el arreglo de tiempo de interpolacion
            [dt, t] = obtenerDtMinimo(obj);
            [ngdlf, ~] = size(obj.cargas{1}.obtenerDesplazamiento());
            
            % Genera el vector final
            u = zeros(ngdlf, length(t));
            
            % Interpola cada desplazamiento
            for i = 1:length(obj.cargas)
                
                [ndg, ~] = size(obj.cargas{i}.obtenerDesplazamiento());
                if ndg ~= ngdlf
                    error('Grado de libertad de la carga no corresponde con la combinacion de cargas');
                end
                
                x = obj.reshapeMatrix(obj.cargas{i}.obtenerDesplazamiento(), ...
                    obj.cargas{i}.tInicio, obj.cargas{i}.dt, ...
                    obj.cargas{i}.tAnalisis, dt, t, ...
                    obj.cargas{i}.obtenerEtiqueta());
                [~, lx] = size(x);
                
                % Suma el vector
                j = 1;
                for k = 1:length(t)
                    if t(k) >= obj.cargas{i}.tInicio
                        u(:, k) = u(:, k) + x(:, j);
                        j = j + 1;
                    end
                    if j > lx
                        break;
                    end
                end % for k
                
            end % for i
            
        end % obtenerDesplazamiento function
        
        function u = obtenerDesplazamientoTiempo(obj, gdl, tiempo)
            % obtenerDesplazamientoTiempo obtiene el desplazamiento de un
            % grado de libertad en un determinado tiempo
            
            if isempty(obj.uGuardado)
                obj.uGuardado = obj.obtenerDesplazamiento();
            end
            
            if tiempo < 0 % Retorna el maximo
                u = max(obj.uGuardado(gdl, :));
            else
                u = obj.uGuardado(gdl, tiempo);
            end
            
        end % obtenerDesplazamientoTiempo function
        
        function v = obtenerVelocidad(obj)
            % obtenerVelocidad: Obtiene la velocidad de la combinacion de
            % cargas
            
            % Genera el arreglo de tiempo de interpolacion
            [dt, t] = obtenerDtMinimo(obj);
            [ngdlf, ~] = size(obj.cargas{1}.obtenerDesplazamiento());
            
            % Genera el vector final
            v = zeros(ngdlf, length(t));
            
            % Interpola cada desplazamiento
            for i = 1:length(obj.cargas)
                
                [ndg, ~] = size(obj.cargas{i}.obtenerVelocidad());
                if ndg ~= ngdlf
                    error('Grado de libertad de la carga no corresponde con la combinacion de cargas');
                end
                
                x = obj.reshapeMatrix(obj.cargas{i}.obtenerVelocidad(), ...
                    obj.cargas{i}.tInicio, obj.cargas{i}.dt, ...
                    obj.cargas{i}.tAnalisis, dt, t, ...
                    obj.cargas{i}.obtenerEtiqueta());
                [~, lx] = size(x);
                
                % Suma el vector
                j = 1;
                for k = 1:length(t)
                    if t(k) >= obj.cargas{i}.tInicio
                        v(:, k) = v(:, k) + x(:, j);
                        j = j + 1;
                    end
                    if j > lx
                        break;
                    end
                end % for k
                
            end % for i
            
        end % obtenerVelocidad function
        
        function a = obtenerAceleracion(obj)
            % obtenerAceleracion: Obtiene la aceleracion de la combinacion
            % de cargas
            
            % Genera el arreglo de tiempo de interpolacion
            [dt, t] = obtenerDtMinimo(obj);
            [ngdlf, ~] = size(obj.cargas{1}.obtenerDesplazamiento());
            
            % Genera el vector final
            a = zeros(ngdlf, length(t));
            
            % Interpola cada desplazamiento
            for i = 1:length(obj.cargas)
                
                [ndg, ~] = size(obj.cargas{i}.obtenerAceleracion());
                if ndg ~= ngdlf
                    error('Grado de libertad de la carga no corresponde con la combinacion de cargas');
                end
                
                x = obj.reshapeMatrix(obj.cargas{i}.obtenerAceleracion(), ...
                    obj.cargas{i}.tInicio, obj.cargas{i}.dt, ...
                    obj.cargas{i}.tAnalisis, dt, t, ...
                    obj.cargas{i}.obtenerEtiqueta());
                [~, lx] = size(x);
                
                % Suma el vector
                j = 1;
                for k = 1:length(t)
                    if t(k) >= obj.cargas{i}.tInicio
                        a(:, k) = a(:, k) + x(:, j);
                        j = j + 1;
                    end
                    if j > lx
                        break;
                    end
                end % for k
                
            end % for i
            
        end % obtenerAceleracion function
        
        function r = usoAmortiguamientoRayleigh(obj)
            % usoAmortiguamientoRayleigh: Indica que las cargas se
            % calcularon con rayleigh
            
            r = false;
            for i = 1:length(obj.cargas)
                r = r || obj.cargas{i}.usoAmortiguamientoRayleigh();
            end % for i
            
        end % usoAmortiguamientoRayleigh function
        
        function m = usoDescomposicionModal(obj)
            % usoDescomposicionModal: Indica que las cargas se
            % calcularon con descomposicion modal
            
            m = false;
            for i = 1:length(obj.cargas)
                m = m || obj.cargas{i}.usoDescomposicionModal();
            end % for i
            
        end % usoDescomposicionModal function
        
        function d = usoDeDisipadores(obj)
            % usoDescomposicionModal: Indica que las cargas se
            % calcularon con disipadores
            
            d = false;
            for i = 1:length(obj.cargas)
                d = d || obj.cargas{i}.usoDeDisipadores();
            end % for i
            
        end % usoDeDisipadores function
        
        function t = tAnalisis(obj)
            % tAnalisis: Retorna el tiempo de analisis de la combinacion de
            % cargas
            
            [~, t] = obtenerDtMinimo(obj);
            t = max(t) - min(t);
            
        end % tAnalisis function
        
        function t = dt(obj)
            % dt: Obtiene el dt de la combinacion de cargas
            
            [t, ~] = obtenerDtMinimo(obj);
            
        end % dt function
        
        function disp(obj)
            % disp: es un metodo de la clase CombinacionCarga que se usa
            % para imprimir en command Window la informacion de la
            % combinacion de cargas
            
            fprintf('Propiedades combinacion cargas:\n');
            disp@ComponenteModelo(obj);
            
            fprintf('Cargas del modelo:');
            for i = 1:length(obj.cargas)
                fprintf('\t%s', obj.cargas.obtenerEtiqueta());
            end % for i
            
            dispMetodoTEFAME();
            
        end % disp function
        
    end % public methods CombinacionCargas
    
    methods(Access = private)
        
        function [dt, t] = obtenerDtMinimo(obj)
            % obj: Obtiene el arreglo de tiempo comun a
            % todas las cargas de la combinacion
            
            dt = Inf;
            tFin = 0;
            tInicio = Inf;
            for i = 1:length(obj.cargas)
                
                dt = min(dt, obj.cargas{i}.dt);
                tFin = max(tFin, obj.cargas{i}.tAnalisis+obj.cargas{i}.tInicio);
                tInicio = min(tInicio, obj.cargas{i}.tInicio);
                
            end % for i
            
            t = floor(tInicio):dt:ceil(tFin);
            % t = t(:, 1:end-1); % Elimina la ultima columna
            
        end % obtenerDtMinimo function
        
        function a = reshapeMatrix(obj, m, tini, dtm, tanalisis, dt, t, cargaEtiqueta) %#ok<INUSL>
            % reshapeMatrix: reshapeMatrix reajusta una matriz dado un tiempo
            
            % Si la carga no es calculada retorna error
            if isempty(m)
                error('Carga %s no ha sido calculada', cargaEtiqueta);
            end
            
            % Si m es una columna la extiende
            [r, c] = size(m);
            if c == 1
                k = length(t);
                mn = zeros(r, k);
                for j = 1:k
                    mn(:, j) = m(:);
                end % for j
                a = mn;
                return;
            end
            [r, c] = size(m);
            
            % Si es la misma matriz retorna
            if dtm == dt
                a = m;
                return;
            end
            
            % Tiempo de m
            tm = linspace(tini, tini+tanalisis, c);
            
            % Nuevo tiempo
            tf = linspace(tini, tini+tanalisis, tanalisis/dt);
            
            % Crea nueva matriz
            a = zeros(r, length(tf));
            
            for k1 = 1:size(m, 1)
                a(k1, :) = interp1(tm, m(k1, :), tf, 'linear');
            end % for k1
            
        end % reshapeMatrix function
        
    end % private methods CombinacionCargas
    
end % class CombinacionCargas