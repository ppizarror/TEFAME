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
%| Clase CargaGenerica                                                  |
%|                                                                      |
%| Este archivo contiene la definicion de la Clase CargaGenerica        |
%| CargaGenerica es una subclase de la clase CargaDinamica  y permite   |
%| definir una carga general en un vector que se puede aplicar a varios |
%| nodos simultaneamente en algun grado de libertad.                    |
%|______________________________________________________________________|
%|                                                                      |
%| MIT License                                                          |
%| Copyright (c) 2018-2019 Pablo Pizarro R @ppizarror.com.              |
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
%       CargaGenerica(etiquetaCargaGenerica,nodos,direccion,amplitud,w,tOscilacion,dt,tInicio,tAnalisis)
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

classdef CargaGenerica < CargaDinamica
    
    properties(Access = private)
        carga % Vector de la carga generica
        direccion % Vector de direcciones
        nodos % Nodo al que se aplica la carga
    end % private properties CargaGenerica
    
    methods(Access = public)
        
        function obj = CargaGenerica(etiquetaCargaGenerica, nodos, direccion, carga, dt)
            % CargaGenerica: es el constructor de la clase CargaGenerica
            %
            % Crea una carga generica
            
            if nargin == 0
                etiquetaCargaGenerica = '';
            end
            
            % Llamamos al constructor de la SuperClass que es la clase Carga
            obj = obj@CargaDinamica(etiquetaCargaGenerica);
            
            % Verifica que nodos sea un cell
            if ~iscell(nodos)
                nodos = {nodos};
            end
            for k = 1:length(nodos)
                if ~isa(nodos{k}, 'Nodo')
                    error('Elemento %d del cell de nodos no es de clase Nodo', k);
                end
            end % for k
            
            % Verifica que tenga sentido la direccion
            if ~verificarVectorDireccion(direccion, nodos{1}.obtenerNumeroGDL())
                error('Vector direccion mal definido');
            end
            
            % Verifica que la carga no sea nula
            nc = length(carga);
            if nc == 0
                error('La carga no puede ser nula');
            end
            
            % Chequea que los tiempos esten bien definidos
            if dt <= 0
                error('dt de carga mal definido');
            end
            tInicio = 0;
            tAnalisis = nc * dt;
            
            % Guarda los parametros de la carga
            obj.carga = carga; % Guarda la carga
            obj.direccion = direccion;
            obj.dt = dt;
            obj.nodos = nodos; % Nodo al que se le aplica la carga
            obj.tAnalisis = tAnalisis;
            obj.tInicio = tInicio;
            
        end % CargaGenerica constructor
        
        function p = calcularCarga(obj, ~, m, ~, dispinfo)
            % calcularCarga: es un metodo de la clase Carga que se usa para
            % calcular la carga a aplicar
            
            % Crea la matriz de carga
            ng = length(m);
            nt = length(obj.carga); % Nro de intervalos
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
            
            % Carga generica
            for i = 1:nt
                p(:, i) = rf .* obj.carga(i);
            end % for i
            
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
        
    end % public methods CargaGenerica
    
end % class CargaGenerica