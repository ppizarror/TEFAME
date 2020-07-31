%|______________________________________________________________________|
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
%| Repositorio: https://github.com/ppizarror/TEFAME                     |
%|______________________________________________________________________|
%|                                                                      |
%| Clase CargaSinusoidal                                                |
%|                                                                      |
%| Este archivo contiene la definicion de la Clase CargaSinusoidal      |
%| CargaSinusoidal es una subclase de la clase CargaDinamica y          |
%| corresponde a la representacion de una carga sinusoidal en el metodo |
%| de elementos finitos o analisis matricial de estructuras.            |
%| La clase CargaSinusoidal es una clase que contiene el nodo al que se |
%| le va aplicar la carga y el valor de esta carga.                     |
%|______________________________________________________________________|
%|                                                                      |
%| MIT License                                                          |
%| Copyright (c) 2018-2020 Pablo Pizarro R @ppizarror.com.              |
%|                                                                      |
%| Permission is hereby granted, free of charge, to any person obtai-   |
%| ning a copy of this software and associated documentation files (the |
%| "Software"), to deal in the Software without restriction, including  |
%| without limitation the rights to use, copy, modify, merge, publish,  |
%| distribute, sublicense, and/or sell copies of the Software, and to   |
%| permit persons to whom the Software is furnished to do so, subject   |
%| to the following conditions:                                         |
%|                                                                      |
%| The above copyright notice and this permission notice shall be       |
%| included in all copies or substantial portions of the Software.      |
%|                                                                      |
%| THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,      |
%| EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF   |
%| MERCHANTABILITY,FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.|
%| IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY |
%| CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, |
%| TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE    |
%| SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.               |
%|______________________________________________________________________|
%
%  Methods(Access=public):
%       CargaSinusoidal(etiquetaCargaSinusoidal,nodos,direccion,amplitud,w,tOscilacion,dt,tInicio,tAnalisis)
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

classdef CargaSinusoidal < CargaDinamica
    
    properties(Access = private)
        amplitud % Amplitud de la carga
        direccion % Vector de direcciones
        nodos % Nodo al que se aplica la carga
        tOscilacion % Tiempo de oscilacion
        w % Frecuencia de la carga
    end % private properties CargaSinusoidal
    
    methods(Access = public)
        
        function obj = CargaSinusoidal(etiquetaCargaSinusoidal, nodos, direccion, amplitud, w, tOscilacion, dt, tInicio, tAnalisis)
            % CargaSinusoidal: es el constructor de la clase CargaSinusoidal
            %
            % Crea una carga del tipo sinusoidal
            
            if nargin == 0
                etiquetaCargaSinusoidal = '';
            end
            
            % Llamamos al constructor de la SuperClass que es la clase Carga
            obj = obj@CargaDinamica(etiquetaCargaSinusoidal);
            
            % Verifica que nodos sea un cell
            if ~iscell(nodos)
                nodos = {nodos};
            end
            for k=1:length(nodos)
                if ~isa(nodos{k}, 'Nodo')
                    error('Elemento %d del cell de nodos no es de clase Nodo', k);
                end
            end % for k
            
            % Verifica que tenga sentido la direccion
            if ~verificarVectorDireccion(direccion, nodos{1}.obtenerNumeroGDL())
                error('Vector direccion mal definido');
            end
            
            % Chequea que los tiempos esten bien definidos
            if tAnalisis < 0 || tInicio < 0 || dt <= 0
                error('Tiempo de carga mal definido');
            end
            
            % Guarda los parametros de la carga
            obj.amplitud = amplitud;
            obj.direccion = direccion;
            obj.dt = dt;
            obj.nodos = nodos; % Nodo al que se le aplica la carga
            obj.tAnalisis = tAnalisis;
            obj.tInicio = tInicio;
            obj.tOscilacion = tOscilacion;
            obj.w = w;
            
        end % CargaSinusoidal constructor
        
        function p = calcularCarga(obj, ~, m, ~, dispinfo)
            % calcularCarga: es un metodo de la clase Carga que se usa para
            % calcular la carga a aplicar
            
            % Crea la matriz de carga
            ng = length(m);
            nint = obj.tOscilacion / obj.dt;
            nt = obj.tAnalisis / obj.dt; % Nro de intervalos
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
                        obj.nodo.obtenerEtiqueta());
                end
                
                gdl = 0;
                for i = 1:length(obj.direccion)
                    if obj.direccion(i) > 0
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
                        nodo.obtenerEtiqueta());
                end
                
            end % for k
            
            % Carga sinusoidal
            t = linspace(0, obj.tOscilacion, nint);
            carga = zeros(1, length(t));
            
            for i = 1:length(t)
                carga(i) = obj.amplitud * sin(obj.w*t(i));
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
                    i-1, nt, ((i - 1) / nt)*100);
            end
            
        end % calcularCarga function
        
        function disp(obj)
            % disp: es un metodo de la clase CargaDinamica que se usa para imprimir en
            % command Window la informacion de la carga del tipo sinusoidal
            %
            % Imprime la informacion guardada en la carga (obj) en pantalla
            
            fprintf('Propiedades carga sinusoidal:\n');
            disp@CargaDinamica(obj);
            dispMetodoTEFAME();
            
        end % disp function
        
    end % public methods CargaSinusoidal
    
end % class CargaSinusoidal