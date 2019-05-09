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
%       combinacionCargaObj = CombinacionCargas(etiquetaCombinacion,cargas)
%       t = obtenerVectorTiempo(combinacionCargaObj)
%       p = obtenerCarga(combinacionCargaObj)
%       u = obtenerDesplazamiento(combinacionCargaObj)
%       u = obtenerDesplazamientoTiempo(combinacionCargaObj,gdl,tiempo)
%       v = obtenerVelocidad(combinacionCargaObj)
%       a = obtenerAceleracion(combinacionCargaObj)
%       disp(combinacionCargaObj)
%  Methods SuperClass (ComponenteModelo):
%       etiqueta = obtenerEtiqueta(componenteModeloObj)
%       e = equals(componenteModeloObj,obj)

classdef CombinacionCargas < ComponenteModelo
    
    properties(Access = private)
        cargas % Arreglo de cargas
    end % properties CombinacionCargas
    
    methods(Access = public)
        
        function combinacionCargaObj = CombinacionCargas(etiquetaCombinacion, cargas)
            % CombinacionCargas: Es el constructor de la clase, requiere el
            % nombre de la combinacion y un cell de cargas
            %
            % combinacionCargaObj = CombinacionCargas(etiquetaCombinacion,cargas)
            
            if nargin == 0
                etiquetaCombinacion = '';
            end % if
            
            % Llamamos al constructor de la SuperClass que es la clase ComponenteModelo
            combinacionCargaObj = combinacionCargaObj@ComponenteModelo(etiquetaCombinacion);
            
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
            combinacionCargaObj.cargas = cargas;
            
        end % CombinacionCargas constructor
        
        function t = obtenerVectorTiempo(combinacionCargaObj)
            % obtenerVectorTiempo: Retorna el vector de tiempo
            %
            % t = obtenerVectorTiempo(combinacionCargaObj)
            
            [~, t] = obtenerDtMinimo(combinacionCargaObj);
            
        end % obtenerVectorTiempo function
        
        function p = obtenerCarga(combinacionCargaObj)
            % obtenerCarga: Obtiene la carga de la combinacion de cargas
            %
            % obtenerCarga(combinacionCargaObj)
            
            % Genera el arreglo de tiempo de interpolacion
            [dt, t] = obtenerDtMinimo(combinacionCargaObj);
            [ngdlf, ~] = size(combinacionCargaObj.cargas{1}.obtenerCarga());
            
            % Genera el vector final
            p = zeros(ngdlf, length(t));
            
            % Interpola cada carga
            for i = 1:length(combinacionCargaObj.cargas)
                
                [ndg, ~] = size(combinacionCargaObj.cargas{i}.obtenerCarga());
                if ndg ~= ngdlf
                    error('Grado de libertad de la carga no corresponde con la combinacion de cargas');
                end
                
                x = combinacionCargaObj.reshapeMatrix(combinacionCargaObj.cargas{i}.obtenerCarga(), ...
                    combinacionCargaObj.cargas{i}.tInicio, combinacionCargaObj.cargas{i}.dt, ...
                    combinacionCargaObj.cargas{i}.tAnalisis, dt, t);
                size(x)
                size(t)
                [~, lx] = size(x);
                
                % Suma el vector
                j = 1;
                for k = 1:length(t)
                    if t(k) >= combinacionCargaObj.cargas{i}.tInicio
                        p(:, k) = p(:, k) + x(:, j);
                        j = j + 1;
                    end
                    if j > lx
                        break;
                    end
                end % for k
                
            end
            
        end % obtenerCarga function
        
        function u = obtenerDesplazamiento(combinacionCargaObj)
            % obtenerDesplazamiento: Obtiene el desplazamiento de la
            % combinacion de cargas
            %
            % obtenerDesplazamiento(combinacionCargaObj)
            
            % Genera el arreglo de tiempo de interpolacion
            [dt, t] = obtenerDtMinimo(combinacionCargaObj);
            [ngdlf, ~] = size(combinacionCargaObj.cargas{1}.obtenerDesplazamiento());
            
            % Genera el vector final
            u = zeros(ngdlf, length(t));
            
            % Interpola cada desplazamiento
            for i = 1:length(combinacionCargaObj.cargas)
                
                [ndg, ~] = size(combinacionCargaObj.cargas{i}.obtenerDesplazamiento());
                if ndg ~= ngdlf
                    error('Grado de libertad de la carga no corresponde con la combinacion de cargas');
                end
                
                x = combinacionCargaObj.reshapeMatrix(combinacionCargaObj.cargas{i}.obtenerDesplazamiento(), ...
                    combinacionCargaObj.cargas{i}.tInicio, combinacionCargaObj.cargas{i}.dt, ...
                    combinacionCargaObj.cargas{i}.tAnalisis, dt, t);
                [~, lx] = size(x);
                
                % Suma el vector
                j = 1;
                for k = 1:length(t)
                    if t(k) >= combinacionCargaObj.cargas{i}.tInicio
                        u(:, k) = u(:, k) + x(:, j);
                        j = j + 1;
                    end
                    if j > lx
                        break;
                    end
                end % for k
                
            end
            
        end % obtenerDesplazamiento function
        
        function u = obtenerDesplazamientoTiempo(combinacionCargaObj, gdl, tiempo)
            % obtenerDesplazamientoTiempo obtiene el desplazamiento de un
            % grado de libertad en un determinado tiempo
            %
            % u = obtenerDesplazamientoTiempo(combinacionCargaObj,gdl,tiempo)
            
            uf = combinacionCargaObj.obtenerDesplazamiento();
            
            if tiempo < 0 % Retorna el maximo
                u = max(uf(gdl, :));
            else
                u = uf(gdl, tiempo);
            end
            
        end % obtenerDesplazamientoTiempo function
        
        function v = obtenerVelocidad(combinacionCargaObj)
            % obtenerVelocidad: Obtiene la velocidad de la combinacion de
            % cargas
            %
            % obtenerVelocidad(combinacionCargaObj)
            
            % Genera el arreglo de tiempo de interpolacion
            [dt, t] = obtenerDtMinimo(combinacionCargaObj);
            [ngdlf, ~] = size(combinacionCargaObj.cargas{1}.obtenerDesplazamiento());
            
            % Genera el vector final
            v = zeros(ngdlf, length(t));
            
            % Interpola cada desplazamiento
            for i = 1:length(combinacionCargaObj.cargas)
                
                [ndg, ~] = size(combinacionCargaObj.cargas{i}.obtenerVelocidad());
                if ndg ~= ngdlf
                    error('Grado de libertad de la carga no corresponde con la combinacion de cargas');
                end
                
                x = combinacionCargaObj.reshapeMatrix(combinacionCargaObj.cargas{i}.obtenerVelocidad(), ...
                    combinacionCargaObj.cargas{i}.tInicio, combinacionCargaObj.cargas{i}.dt, ...
                    combinacionCargaObj.cargas{i}.tAnalisis, dt, t);
                [~, lx] = size(x);
                
                % Suma el vector
                j = 1;
                for k = 1:length(t)
                    if t(k) >= combinacionCargaObj.cargas{i}.tInicio
                        v(:, k) = v(:, k) + x(:, j);
                        j = j + 1;
                    end
                    if j > lx
                        break;
                    end
                end % for k
                
            end
            
        end % obtenerVelocidad function
        
        function a = obtenerAceleracion(combinacionCargaObj)
            % obtenerAceleracion: Obtiene la aceleracion de la combinacion
            % de cargas
            %
            % obtenerAceleracion(combinacionCargaObj)
            
            % Genera el arreglo de tiempo de interpolacion
            [dt, t] = obtenerDtMinimo(combinacionCargaObj);
            [ngdlf, ~] = size(combinacionCargaObj.cargas{1}.obtenerDesplazamiento());
            
            % Genera el vector final
            a = zeros(ngdlf, length(t));
            
            % Interpola cada desplazamiento
            for i = 1:length(combinacionCargaObj.cargas)
                
                [ndg, ~] = size(combinacionCargaObj.cargas{i}.obtenerAceleracion());
                if ndg ~= ngdlf
                    error('Grado de libertad de la carga no corresponde con la combinacion de cargas');
                end
                
                x = combinacionCargaObj.reshapeMatrix(combinacionCargaObj.cargas{i}.obtenerAceleracion(), ...
                    combinacionCargaObj.cargas{i}.tInicio, combinacionCargaObj.cargas{i}.dt, ...
                    combinacionCargaObj.cargas{i}.tAnalisis, dt, t);
                [~, lx] = size(x);
                
                % Suma el vector
                j = 1;
                for k = 1:length(t)
                    if t(k) >= combinacionCargaObj.cargas{i}.tInicio
                        a(:, k) = a(:, k) + x(:, j);
                        j = j + 1;
                    end
                    if j > lx
                        break;
                    end
                end % for k
                
            end
            
        end % obtenerAceleracion function
        
        function r = usoAmortiguamientoRayleigh(combinacionCargaObj)
            % usoAmortiguamientoRayleigh: Indica que las cargas se
            % calcularon con rayleigh
            %
            % t = usoAmortiguamientoRayleigh(combinacionCargaObj)
            
            r = false;
            for i=1:length(combinacionCargaObj.cargas)
                r = r || combinacionCargaObj.cargas{i}.usoAmortiguamientoRayleigh();
            end % for i
            
        end % usoAmortiguamientoRayleigh function
        
        function m = usoDescomposicionModal(combinacionCargaObj)
            % usoDescomposicionModal: Indica que las cargas se
            % calcularon con descomposicion modal
            %
            % m = usoDescomposicionModal(combinacionCargaObj)
            
            m = false;
            for i=1:length(combinacionCargaObj.cargas)
                m = m || combinacionCargaObj.cargas{i}.usoDescomposicionModal();
            end % for i
            
        end % usoDescomposicionModal function
        
        function d = usoDeDisipadores(combinacionCargaObj)
            % usoDescomposicionModal: Indica que las cargas se
            % calcularon con disipadores
            %
            % m = usoDeDisipadores(combinacionCargaObj)
            
            d = false;
            for i=1:length(combinacionCargaObj.cargas)
                d = d || combinacionCargaObj.cargas{i}.usoDeDisipadores();
            end % for i
            
        end % usoDeDisipadores function
        
        function disp(combinacionCargaObj)
            % disp: es un metodo de la clase CombinacionCarga que se usa
            % para imprimir en command Window la informacion de la
            % combinacion de cargas
            %
            % disp(combinacionCargaObj)
            
            fprintf('Propiedades combinacion cargas:\n');
            disp@ComponenteModelo(combinacionCargaObj);
            
            fprintf('Cargas del modelo:');
            for i = 1:length(combinacionCargaObj.cargas)
                fprintf('\t%s', combinacionCargaObj.cargas.obtenerEtiqueta());
            end % for i
            
            fprintf('-------------------------------------------------\n');
            fprintf('\n');
            
        end % disp function
        
    end % methods CombinacionCargas public
    
    methods(Access = private)
        
        function [dt, t] = obtenerDtMinimo(combinacionCargaObj)
            % combinacionCargaObj: Obtiene el arreglo de tiempo comun a
            % todas las cargas de la combinacion
            %
            % [dt, t] = obtenerDtMinimo(combinacionCargaObj)
            
            dt = Inf;
            tFin = 0;
            tInicio = Inf;
            for i = 1:length(combinacionCargaObj.cargas)
                
                dt = min(dt, combinacionCargaObj.cargas{i}.dt);
                tFin = max(tFin, combinacionCargaObj.cargas{i}.tAnalisis+combinacionCargaObj.cargas{i}.tInicio);
                tInicio = min(tInicio, combinacionCargaObj.cargas{i}.tInicio);
                
            end % for i
            
            t = floor(tInicio):dt:ceil(tFin);
            % t = t(:, 1:end-1); % Elimina la ultima columna
            
        end % obtenerDtMinimo function
        
        function a = reshapeMatrix(combinacionCargaObj, m, tini, dtm, tanalisis, dt, t) %#ok<INUSL>
            % reshapeMatrix: reshapeMatrix reajusta una matriz dado un tiempo
            %
            % a = reshapeMatrix(combinacionCargaObj, m, tini, dtm, tanalisis, dt, t)
            
            % Si la carga no es calculada retorna error
            if isempty(m)
                error('Carga no ha sido calculada');
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
        
    end % methods CombinacionCargas private
    
end % class CombinacionCargas