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
%| Clase CargaNodo                                                      |
%|                                                                      |
%| Este archivo contiene la definicion de la Clase CargaNodo            |
%| CargaNodo  es  una subclase  de la  clase  Nodo  y corresponde  a la |
%| representacion de una carga nodal en el metodo de elementos  finitos |
%| o analisis matricial de estructuras.                                 |
%| La clase CargaNodo es una clase que contiene el nodo al que se le va |
%| aplicar la carga y el valor de esta carga.                           |
%|                                                                      |
%| Programado: Pablo Pizarro @ppizarror                                 |
%| Fecha: 10/04/2019                                                    |
%|______________________________________________________________________|
%
%  Properties (Access=private):
%  Methods:
%       CargaRegistroSismico(etiquetaCargaRegistroSismico,registro,direccion,dt,tAnalisis)
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

classdef CargaRegistroSismico < CargaDinamica
    
    properties(Access = private)
        registro % Cell con matrices de registro
        direccion % Vector de direcciones
        rf % Vector de influencia
        dispinfo % Indica si se despliega la informacion
    end % properties CargaNodo
    
    methods
        
        function obj = CargaRegistroSismico(etiquetaCargaRegistroSismico, registro, direccion, tInicio, tAnalisis)
            % CargaRegistroSismico: es el constructor de la clase CargaNodo
            %
            % Crea una carga del tipo registro de aceleracion, requiere un
            % vector registro [Nxr], una direccion [1xr] y un tiempo maximo
            % de analisis, dt lo obtiene del registro
            
            if nargin == 0
                etiquetaCargaRegistroSismico = '';
            end % if
            
            if length(registro) ~= length(direccion)
                error('Cell registro no tiene igual dimension a las direcciones de analisis');
            end
            if ~verificarVectorDireccion(direccion, length(direccion))
                error('Vector direccion mal definido');
            end
            
            % Llamamos al constructor de la SuperClass que es la clase Carga
            obj = obj@CargaDinamica(etiquetaCargaRegistroSismico);
            
            % Chequea que el registro en cada direccion no sea nulo
            for k = 1:length(direccion)
                reg = registro{k};
                if direccion(k) ~= 0 && isempty(reg)
                    error('Registro asociado a direccion %d no puede ser nulo', k);
                end
            end % for k
            
            % Calcula el dt
            for k = 1:length(direccion)
                if direccion(k) ~= 0
                    reg = registro{k};
                    dt = reg(2, 1) - reg(1, 1);
                    break;
                end
            end % for k
            
            % Chequea que los tiempos esten bien definidos
            if tAnalisis < 0 || tInicio < 0 || dt <= 0
                error('Tiempo de carga mal definido');
            end
            
            % Guarda el registro
            obj.registro = registro;
            obj.direccion = direccion;
            obj.tAnalisis = tAnalisis;
            obj.tInicio = tInicio;
            obj.dt = dt;
            obj.nodosCarga = {};
            
        end % CargaRegistroSismico constructor
        
        function p = calcularCarga(cargaRegistroSismicoObj, ~, m, r, dispinfo)
            % calcularCarga: es un metodo de la clase Carga que se usa para
            % calcular la carga a aplicar
            
            % Guarda datos
            cargaRegistroSismicoObj.rf = r;
            cargaRegistroSismicoObj.dispinfo = dispinfo;
            
            % Crea la matriz de carga
            ng = length(m);
            nt = cargaRegistroSismicoObj.tAnalisis / cargaRegistroSismicoObj.dt;
            nd = length(cargaRegistroSismicoObj.direccion);
            p = zeros(ng, nt);
            
            % Para cada aceleracion calcula la carga como -m*a
            for k = 1:nd % Recorre direccion
                if cargaRegistroSismicoObj.direccion(k) == 0 % Salta direcciones nulas
                    continue;
                end
                reg = cargaRegistroSismicoObj.registro{k}; % Registro direccion de estudio
                nct = min(length(reg), nt); % Numero de tiempos en los que se aplica la carga
                for i = 1:nct
                    p(:, i) = p(:, i) - m * r(:, k) .* reg(i, 2);
                end % for i
                if dispinfo
                    fprintf('\t\t\t\tLa carga de la direccion %d es aplicada en %d/%d (%.2f%%) de la matriz de cargas totales\n', ...
                        k, i, nct, (i / nct)*100);
                end
            end % for k
            
        end % calcularCarga function
        
        function guardarAceleracion(cargaRegistroSismicoObj, a, Newmark)
            % guardarAceleracion: Guarda la aceleracion de la carga
            
            % Registro sismico suma la aceleracion del registro para cada
            % tiempo en cada columna de <a>
            if Newmark
                if cargaRegistroSismicoObj.dispinfo
                fprintf('\n\t\t\tSumando aceleracion del registro a la calculada por Newmark');
                end
            else
                if cargaRegistroSismicoObj.dispinfo
                fprintf('\n\t\t\tSumando aceleracion del registro a la calculada por Espacio Estado');
                end
            end
            
           
%             if cargaRegistroSismicoObj.dispinfo
%                 fprintf('\n\t\t\tSumando aceleracion del registro a la calculada por', );
%             end
            nt = cargaRegistroSismicoObj.tAnalisis / cargaRegistroSismicoObj.dt;
            nd = length(cargaRegistroSismicoObj.direccion);
            
            for k = 1:nd % Recorre direccion
                if cargaRegistroSismicoObj.direccion(k) == 0 % Salta direcciones nulas
                    continue;
                end
                reg = cargaRegistroSismicoObj.registro{k}; % Registro direccion de estudio
                nct = min(length(reg), nt); % Numero de tiempos en los que se aplica la carga
                for i = 1:nct
                    a(:, i) = a(:, i) + cargaRegistroSismicoObj.rf(:, k) .* reg(i, 2);
                end % for i
            end % for k
            cargaRegistroSismicoObj.sol_a = a;
            
        end % guardarAceleracion function
        
        function disp(cargaRegistroSismicoObj)
            % disp: es un metodo de la clase CargaRegistroSismico que se usa para imprimir en
            % command Window la informacion de la carga del tipo registro
            % sismico
            %
            % Imprime la informacion guardada en la carga (cargaRegistroSismicoObj) en pantalla
            
            fprintf('Propiedades carga registro sismico:\n');
            disp@CargaDinamica(cargaRegistroSismicoObj);
            dispMetodoTEFAME();
            
        end % disp function
        
    end % methods CargaRegistroSismico
    
end % class CargaRegistroSismico