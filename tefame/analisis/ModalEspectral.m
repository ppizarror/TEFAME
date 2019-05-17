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
%| Clase ModalEspectral                                                 |
%|                                                                      |
%| Este archivo contiene la definicion de la Clase ModalEspectral       |
%| ModalEspectral es una clase que se usa para resolver la estructura   |
%| aplicando el metodo modal espectral. Para ello se calcula la matriz  |
%| de masa y de rigidez.                                                |
%|                                                                      |
%| Programado: Pablo Pizarro @ppizarror                                 |
%| Fecha: 18/03/2019                                                    |
%|______________________________________________________________________|
%
%  Properties (Access=private):
%       analisisFinalizado
%       cargarAnimacion
%       condMatRot
%       condMatT
%       cPenzien
%       cRayleigh
%       F
%       gdlCond
%       Km
%       Kt
%       Lm
%       Mm
%       Mmeff
%       Mmeffacum
%       modeloObj
%       mostrarDeformada
%       Mt
%       Mtotal
%       numDG
%       numDGReal
%       numeroGDL
%       numModos
%       phiExt
%       phin
%       rm
%       Tn
%       u
%       wn
%  Methods:
%       obj = ModalEspectral(modeloObjeto)
%       [esfmax,esf,maxp,dirk] = calcularEsfuerzosElemento(obj,carga,elemento,direccion)
%       activarCargaAnimacion(obj)
%       activarPlotDeformadaInicial(obj)
%       analizar(obj,varargin)
%       c = obtenerCargaEstatica(obj,varargin)
%       C_Modelo = obtenerMatrizAmortiguamiento(obj,rayleigh)
%       calcularCurvasEnergia(obj,carga)
%       calcularDesplazamientoDrift(obj,xanalisis)
%       calcularMomentoCorteBasal(obj,carga)
%       Cdv_Modelo = obtenerMatrizAmortiguamientoDisipadores(obj)
%       definirNumeracionGDL(obj)
%       desactivarCargaAnimacion(obj)
%       desactivarPlotDeformadaInicial(obj)
%       disp(obj)
%       F_Modelo = obtenerVectorFuerzas(obj)
%       K_Modelo = obtenerMatrizRigidez(obj)
%       Kdv_Modelo = obtenerMatrizRigidezDisipadores(obj)
%       M_Modelo = obtenerMatrizMasa(obj)
%       numeroEcuaciones = obtenerNumeroEcuaciones(obj)
%       phi_Modelo = obtenerMatrizPhi(obj)
%       plot(obj,varargin)
%       plotEsfuerzosElemento(obj,carga)
%       plotTrayectoriaNodo(obj,carga,nodo,direccion)
%       r_Modelo = obtenerVectorInfluencia(obj)
%       u_Modelo = obtenerDesplazamientos(obj)
%       wn_Modelo = obtenerValoresPropios(obj)

classdef ModalEspectral < Analisis
    
    properties(Access = private)
        cargarAnimacion % Carga la animacion del grafico una vez renderizado
        condMatRot % Matriz de condensacion rotacion
        condMatT % Matriz de condensacion T
        cPenzien % Matriz de amortiguamiento de Wilson-Penzien
        cRayleigh % Matriz de amortiguamiento de Rayleigh
        F % Vector de fuerzas aplicadas sobre el modelo
        gdlCond % Grados de libertad condensados
        Km % Matriz rigidez modal
        Kt % Matriz de rigidez del modelo
        Kteq % Matriz rigidez equivalente
        Lm % Factor de participacion modal
        Mm % Matriz masa modal
        Mmeff % Masa modal efectiva
        Mmeffacum % Masa modal efectiva acumulada
        mostrarDeformada % Muestra la posicion no deformada en los graficos
        Mt % Matriz de masa del modelo
        Mteq % Matriz masa equivalente
        Mtotal % Masa total del modelo
        numDG % Numero de ejes de analisis despues de condensar
        numDGReal % Numero de ejes de analisis antes de condensar
        numModos % Numero de modos del analisis
        phin % Vectores propios del sistema
        phinExt % Vector propio del sistema extendido considerando grados condensados
        rm % Vector influencia
        Tn % Periodos del sistema
        u % Vector con los desplazamientos de los grados de libertad del modelo
        wn % Frecuencias del sistema
    end % properties ModalEspectral
    
    methods(Access = public)
        
        function obj = ModalEspectral(modeloObjeto)
            % ModalEspectral: es el constructor de la clase ModalEspectral
            %
            % obj = ModalEspectral(modeloObjeto)
            %
            % Crea un objeto de la clase ModalEspectral, y guarda el modelo,
            % que necesita ser analizado
            
            if nargin == 0
                modeloObjeto = [];
            end % if
            
            obj = obj@Analisis(modeloObjeto);
            obj.Kt = [];
            obj.Mt = [];
            obj.u = [];
            obj.F = [];
            obj.mostrarDeformada = false;
            obj.cargarAnimacion = true;
            
        end % ModalEspectral constructor
        
        function analizar(obj, varargin)
            % analizar: es un metodo de la clase ModalEspectral que se usa para
            % realizar el analisis estatico
            % Analiza estaticamente el modelo lineal y elastico sometido a un
            % set de cargas, requiere el numero de modos para realizar el
            % analisis y de los modos conocidos con sus beta
            %
            % Parametros opcionales:
            %   condensar           Aplica condensacion (true por defecto)
            %   cpenzienBeta        Vector amortiguamiento Cpenzien
            %   factorCargaE        Factor de cargas estaticas
            %   nModos              Numero de modos de analisis (obligatorio)
            %   rayleighBeta        Vector amortiguamientos de Rayleigh
            %   rayleighDir         Direccion amortiguamiento Rayleigh
            %   rayleighModo        Vector modos de Rayleigh
            %   toleranciaMasa      Tolerancia de la masa para la condensacion
            %   valvecAlgoritmo     'eigvc','itDir','matBarr','itInvDesp','itSubesp'
            %   valvecTolerancia    Tolerancia calculo valores y vectores propios
            
            % Define parametros
            p = inputParser;
            p.KeepUnmatched = true;
            addOptional(p, 'condensar', true);
            addOptional(p, 'cpenzienBeta', []);
            addOptional(p, 'factorCargaE', 1);
            addOptional(p, 'muIterDespl', 0.5);
            addOptional(p, 'nModos', 0);
            addOptional(p, 'nRitz', 1);
            addOptional(p, 'rayleighBeta', []);
            addOptional(p, 'rayleighDir', []);
            addOptional(p, 'rayleighModo', []);
            addOptional(p, 'toleranciamasa', 0.001);
            addOptional(p, 'valvecAlgoritmo', 'eigs');
            addOptional(p, 'valvecTolerancia', 0.001);
            parse(p, varargin{:});
            r = p.Results;
            
            maxcond = r.toleranciamasa;
            if ~r.condensar
                maxcond = -1;
            end
            
            % Verifica que parametros obligatorios sean proporcionados
            if r.nModos <= 0
                error('Numero de modos invalido');
            end
            r.nModos = floor(r.nModos);
            
            if isempty(r.rayleighBeta)
                error('Vector amortiguamiento de Rayleigh no puede ser nulo');
            end
            
            if isempty(r.rayleighModo)
                error('Vector modo Rayleigh no puede ser nulo');
            end
            
            for i = 1:length(r.rayleighModo)
                if r.rayleighModo(i) <= 0
                    error('Vector Rayleigh modo mal definido');
                end
            end % for i
            
            if length(r.rayleighBeta) ~= length(r.rayleighModo) || ...
                    length(r.rayleighBeta) ~= length(r.rayleighDir)
                error('Vectores parametros Rayleigh deben tener igual dimension');
            end
            
            for i = 1:length(r.rayleighDir)
                if ~(r.rayleighDir(i) == 'h' || r.rayleighDir(i) == 'v')
                    error('Direccion amortiguamiento Rayleigh solo puede ser (h) horizonal o (v) vertical');
                end
            end % for i
            
            if isempty(r.cpenzienBeta)
                error('Vector amortiguamiento cpenzien no puede ser nulo');
            end
            
            if r.valvecTolerancia <= 0
                error('Tolerancia calculo valores y vectores propios no puede ser inferior o igual a cero');
            end
            
            if length(r.nRitz) > 1
                error('Numero de Ritz no puede ser un vector');
            end
            
            fprintf('Ejecutando analisis modal espectral:\n');
            fprintf('\tParametros analisis:\n');
            fprintf('\t\tNumero de modos: %d\n', r.nModos);
            
            fprintf('\t\tAmortiguamiento Rayleigh:\n');
            s = arrayIntNum2str(r.rayleighModo);
            fprintf('\t\t\tModos:\t\t%s\n', [s{:}]);
            s = arrayNum2str(r.rayleighBeta);
            fprintf('\t\t\tBeta:\t\t%s\n', [s{:}]);
            s = arrayStr2str(r.rayleighDir);
            fprintf('\t\t\tDireccion:\t%s\n', [s{:}]);
            
            fprintf('\t\tAmortiguamiento cpenzien:\n');
            s = arrayNum2str(r.cpenzienBeta);
            fprintf('\t\t\tBeta:\t\t%s\n', [s{:}]);
            
            % Se definen los grados de libertad por nodo -> elementos
            obj.definirNumeracionGDL();
            
            % Se aplica patron de carga
            obj.modeloObj.aplicarPatronesDeCargasEstatico(r.factorCargaE);
            
            % Se calcula la matriz de rigidez
            obj.ensamblarMatrizRigidez();
            
            % Se calcula la matriz de masa
            obj.ensamblarMatrizMasa();
            
            % Guarda el resultado para las cargas estaticas
            fprintf('\tCalculando resultado carga estatica\n');
            obj.ensamblarVectorFuerzas();
            obj.u = (obj.Kt^-1) * obj.F;
            obj.modeloObj.actualizar(obj.u);
            
            % Calcula el metodo modal espectral
            obj.calcularModalEspectral(r.nModos, r.rayleighBeta, ...
                r.rayleighModo, r.rayleighDir, r.cpenzienBeta, ...
                maxcond, r.valvecAlgoritmo, r.valvecTolerancia, ...
                r.muIterDespl, r.nRitz);
            
            % Termina el analisis
            dispMetodoTEFAME();
            
        end % analizar function
        
        function resolverCargasDinamicas(obj, varargin)
            % resolverCargasDinamicas: Resuelve las cargas dinamicas del
            % sistema
            %
            % Parametros opcionales:
            %   activado            Indica que se realiza el analisis
            %   betaGrafico         Indica si se grafica la variacion del amortiguamiento en cada iteracion
            %   betaObjetivo        Beta objetivo para el calculo de disipadores
            %   cargaDisipador      Carga objetivo disipador para el calculo de v0
            %   cpenzien            Usa el amortiguamiento de cpenzien (false por defecto)
            %   disipadores         Usa los disipadores en el calculo (false por defecto)
            %   factorCargasD       Factor de cargas dinamico
            %   iterDisipador       Numero de iteraciones para el calculo de disipadores
            %   tolIterDisipador    Tolerancia usada para las iteraciones del calculo de disipadores
            
            if ~obj.analisisFinalizado
                error('No se puede resolver las cargas dinamicas sin haber analizado la estructura');
            end
            
            p = inputParser;
            p.KeepUnmatched = true;
            addOptional(p, 'activado', true);
            addOptional(p, 'betaGrafico', false);
            addOptional(p, 'betaObjetivo', 0);
            addOptional(p, 'cargaDisipador', false);
            addOptional(p, 'cpenzien', false);
            addOptional(p, 'disipadores', true);
            addOptional(p, 'factorCargasD', 1);
            addOptional(p, 'iterDisipador', 10);
            addOptional(p, 'tolIterDisipador', 0.001);
            parse(p, varargin{:});
            r = p.Results;
            
            % Chequea inconsistencias
            if ~r.activado
                return;
            end
            if r.disipadores
                if ~isa(r.cargaDisipador, 'CargaDinamica')
                    error('No se ha definido cargaDisipador');
                end
                if r.iterDisipador < 0
                    error('El numero de iteraciones no puede ser menor a cero');
                end
                if r.tolIterDisipador <= 0
                    error('Tolerancia iteracion disipador invalida');
                end
            end
            
            fprintf('Metodo modal espectral:\n');
            obj.modeloObj.aplicarPatronesDeCargasDinamico(r.cpenzien, r.disipadores, ...
                r.cargaDisipador, r.betaObjetivo, obj.modeloObj.obtenerDisipadores(), ...
                r.iterDisipador, r.tolIterDisipador, r.betaGrafico, ...
                r.factorCargasD);
            
        end % resolverCargasDinamicas function
        
        function numeroEcuaciones = obtenerNumeroEcuaciones(obj)
            % obtenerNumeroEcuaciones: es un metodo de la clase ModalEspectral
            % que se usa para obtener el numero total de GDL, es decir, ecuaciones
            % del modelo
            %
            % Obtiene el numero total de GDL (numeroEcuaciones) que esta guardado
            % en el Analisis (obj)
            
            numeroEcuaciones = obj.numeroGDL;
            
        end % obtenerNumeroEcuaciones function
        
        function M_Modelo = obtenerMatrizMasa(obj)
            % obtenerMatrizMasa: es un metodo de la clase ModalEspectral
            % que se usa para obtener la matriz de masa del modelo
            %
            % Obtiene la matriz de masa (M_Modelo) del modelo que se genero
            % en el Analisis (obj)
            
            M_Modelo = obj.Mteq;
            
        end % obtenerMatrizMasa function
        
        function C_Modelo = obtenerMatrizAmortiguamiento(obj, rayleigh)
            % obtenerMatrizAmortiguamiento: es un metodo de la clase ModalEspectral
            % que se usa para obtener la matriz de amortiguamiento del modelo
            %
            % Obtiene la matriz de amortiguamiento (C_Modelo) del modelo que se genero
            % en el Analisis (obj)
            
            if rayleigh
                C_Modelo = obj.cRayleigh;
            else
                C_Modelo = obj.cPenzien;
            end
            
        end % obtenerMatrizAmortiguamiento function
        
        function K_Modelo = obtenerMatrizRigidez(obj)
            % obtenerMatrizRigidez: es un metodo de la clase ModalEspectral
            % que se usa para obtener la matriz de rigidez del modelo
            %
            % Obtiene la matriz de rigidez (K_Modelo) del modelo que se genero
            % en el Analisis (obj)
            
            K_Modelo = obj.Kteq;
            
        end % obtenerMatrizRigidez function
        
        function Cdv_Modelo = obtenerMatrizAmortiguamientoDisipadores(obj)
            % obtenerMatrizRigidez: es un metodo de la clase ModalEspectral
            % que se usa para obtener la matriz de amortiguamiento del modelo
            % producto de los disipadores incorporados
            %
            % Obtiene la matriz de amortiguamiento del modelo
            
            Cdv_Modelo = obj.ensamblarMatrizAmortiguamientoDisipadores();
            
        end % obtenerMatrizAmortiguamientoDisipadores function
        
        function Kdv_Modelo = obtenerMatrizRigidezDisipadores(obj)
            % obtenerMatrizRigidezDisipadores: es un metodo de la clase ModalEspectral
            % que se usa para obtener la matriz de rigidez de los
            % disipadores
            
            Kdv_Modelo = obj.ensamblarMatrizRigidezDisipadores();
            
        end % obtenerMatrizRigidezDisipadores function
        
        function r_Modelo = obtenerVectorInfluencia(obj)
            % obtenerVectorInfluencia: es un metodo de la clase ModalEspectral
            % que se usa para obtener el vector de influencia del modelo
            %
            % Obtiene el vector de influencia (r) del modelo que se genero
            % en el Analisis (obj)
            
            r_Modelo = obj.rm;
            
        end % obtenerVectorInfluencia function
        
        function F_Modelo = obtenerVectorFuerzas(obj)
            % obtenerMatrizRigidez: es un metodo de la clase ModalEspectral
            % que se usa para obtener el vector de fuerza del modelo
            %
            % Obtiene el vector de fuerza (F_Modelo) del modelo que se genero
            % en el Analisis (obj)
            
            F_Modelo = obj.F;
            
        end % obtenerVectorFuerzas function
        
        function u_Modelo = obtenerDesplazamientos(obj)
            % obtenerDesplazamientos: es un metodo de la clase ModalEspectral
            % que se usa para obtener el vector de desplazamiento del modelo
            % obtenido del analisis
            %
            % Obtiene el vector de desplazamiento (u_Modelo) del modelo que se
            % genero como resultado del Analisis (obj)
            
            u_Modelo = obj.u;
            
        end % obtenerDesplazamientos function
        
        function wn_Modelo = obtenerValoresPropios(obj)
            % obtenerValoresPropios: es un metodo de la clase ModalEspectral
            % que se usa para obtener los valores propios del modelo
            % obtenido del analisis
            %
            % Obtiene los valores propios (wn_Modelo) del modelo que se
            % genero como resultado del Analisis (obj)
            
            wn_Modelo = obj.wn;
            
        end % obtenerValoresPropios function
        
        function phi_Modelo = obtenerMatrizPhi(obj)
            % obtenerMatrizPhi: es un metodo de la clase ModalEspectral
            % que se usa para obtener los vectores propios del modelo
            % obtenido del analisis
            %
            % Obtiene los vectores propios (phi_Modelo) del modelo que se
            % genero como resultado del Analisis (obj)
            
            phi_Modelo = obj.phin;
            
        end % obtenerMatrizPhi function
        
        function plt = plot(obj, varargin)
            % plot: Grafica el modelo
            %
            % Parametros opcionales:
            %   3dAngAzh            Angulo azimutal grafico 3D
            %   3dAngPol            Angulo polar grafico 3D
            %   colorDisipador      Color del disipador
            %   cuadros             Numero de cuadros de la animacion
            %   defElem             Dibuja la deformada de cada elemento
            %   disipador           Dibuja los disipadores
            %   factor              Escala de la deformacion
            %   gif                 Archivo en el que se guarda la animacion
            %   lwDisipador         Ancho linea disipador
            %   lwElemD             Ancho linea elemento dinamico
            %   lwElemE             Ancho linea elemento estatico
            %   modo                Numero de modo a graficar
            %   mostrarEstatico     Dibuja la estructura estatica al animar
            %   sizeNodoD           Porte nodo dinamico
            %   sizeNodoE           Porte nodo estatico
            %   styleDisipador      Estilo linea disipador
            %   styleElemD          Estilo elemento dinamico
            %   styleElemE          Estilo elemento estatico
            %   styleNodoD          Estilo nodo dinamico
            %   styleNodoE          Estilo nodo estatico
            %   tmax                Tiempo maximo al graficar cargas
            %   tmin                Tiempo minimo al graficar cargas
            %   unidad              Unidad de longitud
            
            % Establece variables iniciales
            fprintf('Generando animacion analisis modal espectral:\n');
            p = inputParser;
            p.KeepUnmatched = true;
            addOptional(p, 'angAzh', 45);
            addOptional(p, 'angPol', 45);
            addOptional(p, 'carga', false);
            addOptional(p, 'colorDisipador', 'r');
            addOptional(p, 'cuadros', 0);
            addOptional(p, 'defElem', false);
            addOptional(p, 'disipadores', true);
            addOptional(p, 'factor', 1);
            addOptional(p, 'gif', '');
            addOptional(p, 'lwDisipador', 1.3);
            addOptional(p, 'lwElemD', 1.2);
            addOptional(p, 'lwElemE', 0.5);
            addOptional(p, 'modo', 0);
            addOptional(p, 'mostrarEstatico', obj.mostrarDeformada);
            addOptional(p, 'sizeNodoD', 10);
            addOptional(p, 'sizeNodoE', 5);
            addOptional(p, 'styleDisipador', '--');
            addOptional(p, 'styleElemD', 'k-');
            addOptional(p, 'styleElemE', 'b-');
            addOptional(p, 'styleNodoD', 'k');
            addOptional(p, 'styleNodoE', 'b');
            addOptional(p, 'tmax', -1);
            addOptional(p, 'tmin', 0);
            addOptional(p, 'unidad', 'm');
            parse(p, varargin{:});
            r = p.Results;
            modo = floor(r.modo);
            factor = r.factor;
            numCuadros = floor(r.cuadros);
            guardaGif = r.gif;
            defElem = r.defElem;
            carga = r.carga;
            defCarga = false; % Indica que la deformada se obtiene a partir de la carga
            mostrarEstatico = r.mostrarEstatico;
            disipadores = r.disipadores;
            
            % Tiempos
            tmin = max(0, r.tmin);
            tmax = r.tmax;
            tinicial = cputime;
            
            % Verificaciones si se grafica una carga
            if carga ~= false
                
                if ~(isa(carga, 'CargaDinamica') || isa(carga, 'CombinacionCargas'))
                    error('Solo se pueden graficar cargas dinamicas o combinaciones de cargas');
                end
                if isempty(carga.obtenerDesplazamiento())
                    error('No se ha resuelto la carga, no es posible graficar');
                end
                if modo ~= 0
                    error('No se puede graficar un modo y una carga de manera simultanea');
                end
                if numCuadros <= 0
                    error('Se debe especificar el numero de cuadros');
                end
                if tmax > carga.tAnalisis
                    fprintf('\tSe ha limitado el tiempo maximo de la carga a %.2fs\n', carga.tAnalisis);
                    tmax = carga.tAnalisis;
                elseif tmax < carga.tAnalisis
                    fprintf('\tLa carga se graficara a un tiempo menor que el computado originalmente\n');
                end
                if tmax <= 0
                    tmax = carga.tAnalisis;
                end
                if tmin >= tmax
                    error('El tiempo de analisis minimo no puede exceder al maximo');
                end
                
                % Compara los dt
                dt_plot = (tmax - tmin) / numCuadros;
                dt_real = carga.dt;
                
                % Si el dt del grafico es menor se reajustan los cuadros
                if dt_plot < dt_real
                    warning('El numero de cuadros genera un dt=%.3f inferior al dt=%.3f de la carga %s', ...
                        dt_plot, dt_real, carga.obtenerEtiqueta());
                    
                    % Se limitan los cuadros
                    numCuadros = floor((tmax - tmin)/dt_real);
                    fprintf('\tSe ha limitado el numero de cuadros a %d\n', numCuadros);
                elseif dt_plot == dt_real
                    fprintf('\tEl numero de cuadros genera un dt igual al de la carga\n');
                else
                    fprintf('\tEl numero de cuadros genera un dt=%.3f superior al de la carga, superior en %.1f veces\n', ...
                        dt_plot, dt_plot/dt_real);
                    dt_plot_max_factor = 10; % Factor maximo de los cuadros
                    if dt_plot / dt_real > dt_plot_max_factor
                        fprintf('\t\tNo se recomienda que este factor exceda de %d, usar numero de cuadros igual a %d\n', ...
                            dt_plot_max_factor, floor((tmax - tmin)/(dt_plot_max_factor * dt_real)));
                    end
                end
                
                % Crea el vector de tiempos de analisis
                tCargaEq = linspace(tmin, tmax, numCuadros);
                
                % Busca las posiciones asociadas a la carga
                cargaTArr = linspace(0, carga.tAnalisis, carga.tAnalisis/carga.dt);
                tCargaPos = zeros(1, numCuadros); % Guarda los tiempos de 'snapshot' de la carga
                
                i = 1;
                for j = 1:length(cargaTArr)
                    if cargaTArr(j) >= tCargaEq(i)
                        tCargaPos(i) = j;
                        i = i + 1;
                    end
                    if i > numCuadros
                        break;
                    end
                end % for j
                
                % Activa la deformada por carga
                defCarga = true;
                fprintf('\tSe graficara la carga %s desde ti=%.3f a tf=%.3f con dt=%.3f\n', ...
                    carga.obtenerEtiqueta(), tmin, tmax, dt_plot);
                
            else
                
                % No se grafican cargas
                tCargaPos = zeros(1, numCuadros);
                tCargaEq = zeros(1, numCuadros);
                
            end
            
            % Chequea deformada
            deformada = false;
            modo = ceil(modo);
            if exist('modo', 'var') && modo > 0
                deformada = true;
            end
            deformada = deformada || defCarga;
            
            % Grafica la estructura si no se ha ejecutado el analisis
            if (~obj.analisisFinalizado || modo <= 0) && ~defCarga
                plt = figure('Name', sprintf('Plot %s', obj.modeloObj.obtenerNombre()), ...
                    'NumberTitle', 'off');
                movegui('center');
                hold on;
                grid on;
                [limx, limy, limz] = obj.obtenerLimitesDeformada(0, factor, defCarga, carga);
                plotAnimado(obj, false, 0, factor, 0, limx, limy, limz, ...
                    0, 1, 1, defElem, defCarga, carga, 1, tCargaEq, mostrarEstatico, disipadores, ...
                    r.styleNodoE, r.sizeNodoE, r.styleNodoD, r.sizeNodoD, r.styleElemE, r.lwElemE, ...
                    r.styleElemD, r.lwElemD, r.styleDisipador, r.colorDisipador, r.lwDisipador, ...
                    r.unidad, r.angAzh, r.angPol);
                figure(plt);
                return;
            end
            
            % Guarda gif
            guardarGif = false;
            if exist('guardaGif', 'var') && ~strcmp(guardaGif, '')
                guardarGif = true;
                guardaGif = sprintf(guardaGif, modo);
            else
                guardaGif = tempname;
            end
            
            if (modo > obj.numModos || modo <= 0) && ~defCarga
                error('El modo a graficar %d excede la cantidad de modos del sistema (%d)', ...
                    modo, obj.numModos);
            end
            
            % Obtiene el periodo
            if ~defCarga
                tn = obj.Tn(modo);
            else
                tn = 0;
            end
            
            % Calcula los limites
            [limx, limy, limz] = obj.obtenerLimitesDeformada(modo, factor, defCarga, carga);
            
            % Grafica la estructura
            if modo ~= 0
                fig_nom = sprintf('Plot %s - Modo %d', obj.modeloObj.obtenerNombre(), ...
                    modo);
            else
                fig_nom = sprintf('Plot %s - Carga %s', obj.modeloObj.obtenerNombre(), ...
                    carga.obtenerEtiqueta());
            end
            plt = figure('Name', fig_nom, 'NumberTitle', 'off');
            fig_num = get(gcf, 'Number');
            movegui('center');
            hold on;
            grid on;
            % axis tight manual;
            % set(gca, 'nextplot', 'replacechildren');
            
            % Imprime mensajes en consola
            if defElem
                fprintf('\tSe ha activado la deformada de los elementos\n');
            end
            if guardarGif && numCuadros ~= 0
                fprintf('\tEl proceso generara un archivo gif\n');
            end
            
            % Grafica el sistema
            if numCuadros <= 0
                fprintf('\tSe grafica el caso con la deformacion maxima\n');
                plotAnimado(obj, deformada, modo, factor, 1, ...
                    limx, limy, limz, tn, 1, 1, defElem, defCarga, carga, ...
                    1, tCargaEq, mostrarEstatico, disipadores, r.styleNodoE, ...
                    r.sizeNodoE, r.styleNodoD, r.sizeNodoD, r.styleElemE, ...
                    r.lwElemE, r.styleElemD, r.lwElemD, r.styleDisipador, ...
                    r.colorDisipador, r.lwDisipador, r.unidad, ...
                    r.angAzh, r.angPol);
                fprintf('\tProceso finalizado en %.2f segundos\n', cputime-tinicial);
            else
                plotAnimado(obj, deformada, modo, factor, 0, ...
                    limx, limy, limz, tn, 1, 1, defElem, defCarga, ...
                    carga, tCargaPos(1), tCargaEq, mostrarEstatico, disipadores, ...
                    r.styleNodoE, r.sizeNodoE, r.styleNodoD, r.sizeNodoD, ...
                    r.styleElemE, r.lwElemE, r.styleElemD, r.lwElemD, ...
                    r.styleDisipador, r.colorDisipador, r.lwDisipador, ...
                    r.unidad, r.angAzh, r.angPol);
                hold off;
                
                % Obtiene el numero de cuadros
                t = 0;
                dt = 2 * pi() / numCuadros;
                reverse_porcent = '';
                
                % Crea la estructura de cuadros
                Fr(numCuadros) = struct('cdata', [], 'colormap', []);
                
                for i = 1:numCuadros
                    
                    % Si el usuario cierra el plot termina de graficar
                    if ~ishandle(plt) || ~ishghandle(plt)
                        delete(plt);
                        close(fig_num); % Cierra el grafico
                        fprintf('\n\tSe ha cancelado el proceso del grafico\n');
                        return;
                    end
                    
                    t = t + dt;
                    try
                        % figure(fig_num); % Atrapa el foco
                        plotAnimado(obj, deformada, modo, factor, sin(t), ...
                            limx, limy, limz, tn, i, numCuadros, defElem, defCarga, ...
                            carga, tCargaPos(i), tCargaEq, mostrarEstatico, disipadores, ...
                            r.styleNodoE, r.sizeNodoE, r.styleNodoD, r.sizeNodoD, ...
                            r.styleElemE, r.lwElemE, r.styleElemD, r.lwElemD, ...
                            r.styleDisipador, r.colorDisipador, r.lwDisipador, ...
                            r.unidad, r.angAzh, r.angPol);
                        drawnow;
                        Fr(i) = getframe(plt);
                        im = frame2im(Fr(i));
                        [imind, cm] = rgb2ind(im, 256);
                        if i == 1
                            imwrite(imind, cm, guardaGif, 'gif', 'Loopcount', inf, 'DelayTime', 0.1);
                        else
                            imwrite(imind, cm, guardaGif, 'gif', 'WriteMode', 'append', 'DelayTime', 0.1);
                        end
                    catch %#ok<*CTCH>
                        fprintf('\n\tSe ha cancelado el proceso del grafico\n');
                        return;
                    end
                    hold off;
                    
                    msg = sprintf('\tGraficando ... %.1f/100', i/numCuadros*100);
                    fprintf([reverse_porcent, msg]);
                    reverse_porcent = repmat(sprintf('\b'), 1, length(msg));
                    
                end % for i
                
                if guardarGif
                    fprintf('\n\tGuardando animacion gif en: %s\n', guardaGif);
                end
                
                % Imprime en consola el tiempo que se demoro el proceso
                fprintf('\tProceso finalizado en %.2f segundos\n', cputime-tinicial);
                
                % Reproduce la pelicula y cierra el grafico anterior
                close(fig_num);
                if obj.cargarAnimacion
                    fprintf('\n\tAbriendo animacion\n');
                    try
                        gifPlayerGUI(guardaGif, 1/min(numCuadros, 60));
                    catch
                        error('Ha ocurrido un error al abrir el gif generado');
                    end
                else
                    fprintf('\n');
                end
                
                % Cierra la linea
                dispMetodoTEFAME();
                
            end
            
        end % plot function
        
        function guardarResultados(obj, nombreArchivo, cargas)
            % guardarResultados: Guarda resultados adicionales del analisis
            
            % Abre el archivo donde se guardara la informacion
            try
                archivoSalida = fopen(nombreArchivo, 'a');
            catch
                error('No se puede abrir el archivo %s', nombreArchivo);
            end
            
            % Chequea que cargas sea un cell de cargas dinamicas
            if ~exist('cargas', 'var') || isempty(cargas)
                error('Cargas debe ser un cell de cargas dinamicas no nulo');
            end
            
            % Chequea que cada elemento de cargas dinamicas sea una carga
            % dinamica
            for i = 1:length(cargas)
                if ~isa(cargas{i}, 'CargaDinamica')
                    error('Elemento %d del cell de cargas no es un objeto de CargaDinamica', i);
                end
            end % for i
            
            fprintf('Calculando resultados analisis dinamico\n');
            fprintf(archivoSalida, '\n');
            fprintf(archivoSalida, '-------------------------------------------------------------------------------\n');
            fprintf(archivoSalida, 'Resultados del analisis dinamico\n');
            fprintf(archivoSalida, '-------------------------------------------------------------------------------\n');
            fprintf(archivoSalida, '\n');
            
            % Guarda las cargas maximas de los elementos
            elementos = obj.modeloObj.obtenerElementos();
            
            % Estado
            totproc = length(elementos) * length(cargas);
            reverse_porcent = '';
            k = 1; % Contador total
            
            for i = 1:length(elementos)
                
                fprintf(archivoSalida, 'Elemento: %s\n', elementos{i}.obtenerEtiqueta());
                % Recorre cada carga dinamica
                for j = 1:length(cargas)
                    
                    if ~cargas{j}.cargaCalculada()
                        fprintf(archivoSalida, '\tCarga %s no fue calculada\n', ...
                            cargas{j}.obtenerEtiqueta());
                        continue;
                    end
                    
                    if ~cargas{j}.cargaCalculada()
                        fprintf(archivoSalida, '\tCarga %s no fue calculada\n', ...
                            cargas{j}.obtenerEtiqueta());
                        continue;
                    end
                    
                    fprintf(archivoSalida, '\tCarga: %s\n', cargas{j}.obtenerEtiqueta());
                    elmEsf = obj.calcularEsfuerzosElemento(cargas{j}, elementos{i}, 0);
                    elmEsf = arrayNum2str(elmEsf);
                    fprintf(archivoSalida, '\t\tEsfuerzos: %s\n', [elmEsf{:}]);
                    
                    % Imprime estado
                    msg = sprintf('\tCalculando ... %.1f/100', k/totproc*100);
                    fprintf([reverse_porcent, msg]);
                    reverse_porcent = repmat(sprintf('\b'), 1, length(msg));
                    k = k + 1;
                    
                end % for j
                
            end % for i
            fprintf('\n');
            dispMetodoTEFAME();
            
            % Cierra el archivo
            fclose(archivoSalida);
            
        end % guardarResultados function
        
        function calcularDesplazamientoDrift(obj, carga, xanalisis, varargin)
            % calcularDesplazamientoDrift: Funcion que calcula el desplazamiento y
            % drift a partir de una carga
            %
            % Parametros opcionales:
            %   unidad          Unidad de largo
            
            % Inicia proceso
            tinicial = cputime;
            
            % Define variables opcionales
            p = inputParser;
            p.KeepUnmatched = true;
            addOptional(p, 'unidad', 'm');
            parse(p, varargin{:});
            r = p.Results;
            
            % Verifica que la carga se haya calculado
            if ~(isa(carga, 'CargaDinamica') || isa(carga, 'CombinacionCargas'))
                error('Solo se pueden graficar cargas dinamicas o combinaciones de cargas');
            end
            desp = carga.obtenerDesplazamiento();
            if ~carga.cargaCalculada()
                error('La carga %s no se ha calculado', carga.obtenerEtiqueta());
            end
            
            fprintf('Calculando desplazamiento y drift:\n');
            ctitle = obj.imprimirPropiedadesAnalisisCarga(carga);
            
            % Se genera vector en que las filas contienen nodos en un mismo piso,
            % rellenando con ceros la matriz en caso de diferencia de nodos por piso.
            % Tambien se genera vector que contiene alturas de piso
            nodos = obj.modeloObj.obtenerNodos();
            nnodos = length(nodos);
            habs = zeros(1, 1);
            hNodos = zeros(1, 1);
            
            j = 1;
            k = 1;
            l = 1;
            ini = 1;
            ndrift = [];
            for i = 1:nnodos
                CoordNodo = nodos{i}.obtenerCoordenadas;
                xNodo = CoordNodo(1);
                yNodo = CoordNodo(2);
                if yNodo ~= habs(j)
                    k = 1;
                    j = j + 1;
                    habs(j, 1) = yNodo;
                    hNodos(j, k) = i;
                elseif i == 1
                    hNodos(j, k) = i;
                else
                    k = k + 1;
                    hNodos(j, k) = i;
                end
                if yNodo == 0
                    ini = ini + 1;
                end
                if xNodo == xanalisis
                    ndrift(l) = i; %#ok<AGROW>
                    l = l + 1;
                end
            end % for i
            
            [~, s] = size(desp);
            nndrift = length(ndrift);
            
            if isempty(ndrift)
                error('Posicion direccion analisis %.2f invalida', xanalisis);
            end
            
            despx = zeros(nndrift, s);
            driftx = zeros(nndrift-1, s);
            
            % Calculo de drift y desplazamiento en linea de analisis
            for i = 2:nndrift
                nodosup = ndrift(i);
                gdls = nodos{nodosup}.obtenerGDLIDCondensado();
                gdlx = gdls(1);
                despx(i, :) = desp(gdlx, :);
                driftx(i-1, :) = abs(despx(i, :)-despx(i-1, :)) ./ (habs(i) - habs(i-1));
                
            end % for i
            
            % Determinacion de envolvente maxima de desplazamiento y drift
            despxmax = max(abs(despx'))';
            driftxmax = max(abs(driftx'))';
            VecDesp = flipud(despxmax);
            VecDrift = flipud(driftxmax);
            hgen = flipud(habs);
            hplot = zeros(2*length(hgen), 1);
            Despplot = zeros(2*length(hgen)-1, 1);
            Driftplot = zeros(2*length(hgen)-1, 1);
            aux1 = 1;
            aux2 = 2;
            for i = 1:length(hgen)
                hplot(aux1, 1) = hgen(i);
                hplot(aux1+1, 1) = hgen(i);
                if aux2 <= 2 * length(hgen) - 1
                    Driftplot(aux2, 1) = VecDrift(i);
                    Driftplot(aux2+1, 1) = VecDrift(i);
                    Despplot(aux2, 1) = VecDesp(i);
                    Despplot(aux2+1, 1) = VecDesp(i);
                end
                aux1 = aux1 + 2;
                aux2 = aux2 + 2;
            end % for i
            hplot(length(hplot)) = [];
            
            % Crea las figuras
            fig_title = sprintf('Envolvente de Deriva Entre Piso - %s %s', ctitle, carga.obtenerEtiqueta());
            plt = figure('Name', fig_title, 'NumberTitle', 'off');
            movegui(plt, 'center');
            plot(Driftplot.*100, hplot, '*-', 'LineWidth', 1, 'Color', 'black');
            grid on;
            grid minor;
            xlabel('Drift (%)');
            ylabel(sprintf('Altura (%s)', r.unidad));
            title(fig_title);
            
            fig_title = sprintf('Envolvente de Desplazamiento - %s %s', ctitle, carga.obtenerEtiqueta());
            plt = figure('Name', fig_title, 'NumberTitle', 'off');
            movegui(plt, 'center');
            plot(Despplot, hplot, '*-', 'LineWidth', 1, 'Color', 'black');
            grid on;
            grid minor;
            xlabel(sprintf('Desplazamiento (%s)', r.unidad));
            ylabel(sprintf('Altura (%s)', r.unidad));
            title(fig_title);
            
            % Finaliza proceso
            drawnow();
            fprintf('\tProceso finalizado en %.2f segundos\n', cputime-tinicial);
            dispMetodoTEFAME();
            
        end % calcularDesplazamientoDrift function
        
        function calcularMomentoCorteBasal(obj, carga, varargin)
            % calcularMomentoCorteBasal: Funcion que calcula el momento y
            % corte basal a partir de una carga
            %
            % Parametros opcionales:
            %   closeall    Cierra todos los graficos
            %   modo        Vector con graficos de modos
            %   plot        'all','momento','corte','envmomento','envcorte'
            %   unidadC     Unidad corte del modelo
            %   unidadM     Unidad momento del modelo
            
            % Inicia proceso
            tinicial = cputime;
            fprintf('Calculando grafico momento corte basal:\n');
            
            % Rescata parametros
            p = inputParser;
            p.KeepUnmatched = true;
            addOptional(p, 'closeall', false);
            addOptional(p, 'modo', []);
            addOptional(p, 'plot', 'all');
            addOptional(p, 'unidadC', 'tonf');
            addOptional(p, 'unidadM', 'tonf-m');
            parse(p, varargin{:});
            r = p.Results;
            tipoplot = r.plot;
            envmodo = r.modo;
            
            if r.closeall
                close all;
            end
            
            % Verifica que la carga se haya calculado
            if ~(isa(carga, 'CargaDinamica') || isa(carga, 'CombinacionCargas'))
                error('Solo se pueden graficar cargas dinamicas o combinaciones de cargas');
            end
            acel = carga.obtenerAceleracion();
            if ~carga.cargaCalculada()
                error('La carga %s no se ha calculado', carga.obtenerEtiqueta());
            end
            ctitle = obj.imprimirPropiedadesAnalisisCarga(carga);
            
            % Verifica que envmodo sea correcto
            [~, lphi] = size(obj.phin);
            lenvmodo = length(envmodo);
            envmodo = sort(envmodo);
            for i = 1:lenvmodo
                envmodo(i) = floor(envmodo(i));
                if envmodo(i) < 0 || envmodo(i) > lphi
                    error('Analisis modo %d invalido', envmodo(i));
                end
            end % for i
            
            % Calcula el momento
            [Cortante, Momento, CBplot, MBplot, hplot] = obj.calcularMomentoCorteBasalAcel(acel);
            
            % Graficos
            t = carga.obtenerVectorTiempo(); % Vector de tiempo
            dplot = false; % Indica si se realizo algun grafico
            
            if strcmp(tipoplot, 'all') || strcmp(tipoplot, 'corte')
                fig_title = sprintf('Historial de Cortante Basal - %s %s', ctitle, carga.obtenerEtiqueta());
                plt = figure('Name', fig_title, 'NumberTitle', 'off');
                movegui(plt, 'center');
                plot(t, Cortante(end, :), 'k-', 'LineWidth', 1);
                grid on;
                grid minor;
                xlabel('Tiempo (s)');
                ylabel(sprintf('Corte (%s)', r.unidadC));
                title(fig_title);
                dplot = true;
            end
            
            if strcmp(tipoplot, 'all') || strcmp(tipoplot, 'momento')
                fig_title = sprintf('Historial de Momento Basal - %s %s', ctitle, carga.obtenerEtiqueta());
                plt = figure('Name', fig_title, 'NumberTitle', 'off');
                movegui(plt, 'center');
                plot(t, Momento(end, :), 'k-', 'LineWidth', 1);
                grid on;
                grid minor;
                xlabel('Tiempo (s)');
                ylabel(sprintf('Momento (%s)', r.unidadM));
                title(fig_title);
                dplot = true;
            end
            
            if strcmp(tipoplot, 'all') || strcmp(tipoplot, 'envcorte')
                fig_title = sprintf('Envolvente de Cortante Basal - %s %s', ctitle, carga.obtenerEtiqueta());
                plt = figure('Name', fig_title, 'NumberTitle', 'off');
                movegui(plt, 'center');
                plot(CBplot, hplot, '*-', 'LineWidth', 1, 'Color', 'black');
                hold on;
                grid on;
                grid minor;
                xlabel(sprintf('Corte (%s)', r.unidadC));
                ylabel('Altura (m)');
                title(fig_title);
                
                % Realiza los analisis por modo
                CBLegend = cell(1, 1+lenvmodo);
                CBplotModoAnt = false;
                CBLegend{1} = 'Envolvente';
                phiac = obj.phin' * acel;
                for i = 1:lenvmodo
                    [~, ~, CBplotModo, ~, ~] = obj.calcularMomentoCorteBasalAcel(obj.phin(:, envmodo(i))*phiac(envmodo(i), :));
                    if i > 1
                        CBplotModo = CBplotModo + CBplotModoAnt;
                    end
                    CBplotModoAnt = CBplotModo;
                    plot(CBplotModo, hplot, '-', 'LineWidth', 1);
                    CBLegend{i+1} = sprintf('Modo %d', envmodo(i));
                end % for i
                if lenvmodo > 0
                    legend(CBLegend);
                end
                dplot = true;
            end
            
            if strcmp(tipoplot, 'all') || strcmp(tipoplot, 'envmomento')
                fig_title = sprintf('Envolvente de Momento Basal - %s %s', ctitle, carga.obtenerEtiqueta());
                plt = figure('Name', fig_title, 'NumberTitle', 'off');
                movegui(plt, 'center');
                plot(MBplot, hplot, '*-', 'LineWidth', 1, 'Color', 'black');
                grid on;
                grid minor;
                xlabel(sprintf('Momento (%s)', r.unidadM));
                ylabel('Altura (m)');
                title(fig_title);
                dplot = true;
            end
            
            % Si no se realizo ningun grafico
            if ~dplot
                error('Tipo de grafico %s incorrecto, valores aceptados: %s', tipoplot, ...
                    'corte, momento, envcorte, envmomento');
            end
            
            % Finaliza proceso
            drawnow();
            fprintf('\tProceso finalizado en %.2f segundos\n', cputime-tinicial);
            dispMetodoTEFAME();
            
        end % calcularMomentoCorteBasal function
        
        function calcularCurvasEnergia(obj, carga, varargin)
            % calcularCurvasEnergia: Genera las curvas de energia a partir
            % de una carga
            %
            % Parametros opcionales:
            %   carga           Booleano que indica si se grafica la carga o no
            %   closeall        Cierra todos los graficos
            %   linewidth       Ancho de linea de los graficos
            %   mfilt           Porcentaje de filtrado por numero de datos
            %   norm1           Normaliza con respecto al primer valor
            %   plot            'all','ek','ev','ekev','ebe','et','ed'
            
            % Inicia el proceso
            tinicial = cputime;
            
            % Recorre parametros opcionales
            p = inputParser;
            p.KeepUnmatched = true;
            addOptional(p, 'closeall', false);
            addOptional(p, 'linewidth', 1.2);
            addOptional(p, 'mfilt', 0.005);
            addOptional(p, 'norm1', false);
            addOptional(p, 'plot', 'all');
            addOptional(p, 'plotcarga', false);
            parse(p, varargin{:});
            r = p.Results;
            
            if r.closeall
                close all;
            end
            
            % Obtiene variables
            tipoplot = r.plot;
            plotcarga = r.plotcarga;
            
            % Verifica que la carga se haya calculado
            if ~(isa(carga, 'CargaDinamica') || isa(carga, 'CombinacionCargas'))
                error('Solo se pueden graficar cargas dinamicas o una combinacion de cargas');
            end
            c_u = carga.obtenerDesplazamiento();
            c_v = carga.obtenerVelocidad();
            c_p = carga.obtenerCarga();
            
            if ~carga.cargaCalculada()
                error('La carga %s no se ha calculado', carga.obtenerEtiqueta());
            end
            
            % Realiza calculos de energia
            fprintf('Calculando curvas de energia:\n');
            ctitle = obj.imprimirPropiedadesAnalisisCarga(carga);
            
            % Obtiene las matrices
            k = obj.obtenerMatrizRigidez();
            m = obj.obtenerMatrizMasa();
            c = obj.obtenerMatrizAmortiguamiento(carga.usoAmortiguamientoRayleigh());
            
            % Si se usaron disipadores
            if carga.usoDeDisipadores()
                cdv = obj.obtenerMatrizAmortiguamientoDisipadores();
                kdv = obj.obtenerMatrizRigidezDisipadores();
                fprintf('\t\tLa %s se calculo con disipadores\n', lower(ctitle));
            else
                fprintf('\t\tLa %s se calculo sin disipadores\n', lower(ctitle));
            end
            
            % Graficos
            [~, s] = size(c_u);
            t = carga.obtenerVectorTiempo(); % Vector de tiempo
            
            % Energia cinetica
            e_k = zeros(1, s);
            ek1 = 0;
            fprintf('\tCalculando energia cinetica\n');
            for i = 1:s
                vv = c_v(:, i); % Obtiene el vector de velocidad para el tiempo i
                e_k(i) = 0.5 * vv' * m * vv;
                if i == 1
                    ek1 = e_k(i);
                end
                if r.norm1
                    e_k(i) = e_k(i) - ek1;
                end
            end % for i
            
            % Energia elastica
            e_v = zeros(1, s);
            fprintf('\tCalculando energia elastica\n');
            ev1 = 0;
            for i = 1:s
                vv = c_u(:, i); % Obtiene el vector de desplazamiento para el tiempo i
                e_v(i) = 0.5 * vv' * k * vv;
                if i == 1
                    ev1 = e_v(1);
                end
                if r.norm1
                    e_v(i) = e_v(i) - ev1; % Normaliza restando el valor inicial
                end
            end % for i
            
            % Energia elastica disipadores
            e_vamori = zeros(1, s); % Parcial
            e_vamor = zeros(1, s); % Integral
            ev1a = 0;
            
            if carga.usoDeDisipadores()
                fprintf('\tCalculando energia elastica de los amortiguadores\n');
                for i = 1:s
                    uu = c_u(:, i); % Obtiene el vector de desplazamiento para el tiempo i
                    e_vamori(i) = uu' * kdv * uu;
                    if i == 1
                        ev1a = e_vamori(1);
                    end
                    if r.norm1 % Normaliza con el primer valor
                        e_vamori(i) = e_vamori(i) - ev1a;
                    end
                    if i > 1
                        dt = t(i) - t(i - 1);
                        e_vamor(i) = e_vamor(i - 1) + 0.5 * (e_vamori(i) + e_vamori(i - 1)) * dt;
                    end
                end % for i
            end
            
            % Energia disipada
            e_di = zeros(1, s); % Parcial
            e_d = zeros(1, s); % Integral
            ed1 = 0;
            
            fprintf('\tCalculando energia disipada por la estructura\n');
            for i = 1:s
                vv = c_v(:, i); % Obtiene el vector de velocidad para el tiempo i
                e_di(i) = vv' * c * vv;
                if i == 1
                    ed1 = e_di(1);
                end
                if r.norm1 % Normaliza con el primer valor
                    e_di(i) = e_di(i) - ed1;
                end
                if i > 1
                    dt = t(i) - t(i-1);
                    e_d(i) = e_d(i-1) + 0.5 * (e_di(i) + e_di(i-1)) * dt;
                end
            end % for i
            
            % Energia disipada amortiguadores
            e_damori = zeros(1, s); % Parcial
            e_damor = zeros(1, s); % Integral
            eda1 = 0;
            
            if carga.usoDeDisipadores()
                fprintf('\tCalculando energia disipada por los amortiguadores\n');
                for i = 1:s
                    vv = c_v(:, i); % Obtiene el vector de velocidad para el tiempo i
                    e_damori(i) = vv' * cdv * vv;
                    if i == 1
                        eda1 = e_damori(1);
                    end
                    if r.norm1 % Normaliza con el primer valor
                        e_damori(i) = e_damori(i) - eda1;
                    end
                    if i > 1
                        dt = t(i) - t(i - 1);
                        e_damor(i) = e_damor(i - 1) + 0.5 * (e_damori(i) + e_damori(i - 1)) * dt;
                    end
                end % for i
            end
            
            % Trabajo externo
            w_ei = zeros(1, s); % Parcial
            w_e = zeros(1, s); % Integral
            fprintf('\tCalculando trabajo externo\n');
            for i = 1:s
                w_ei(i) = c_p(:, i)' * c_v(:, i);
                if i > 1
                    dt = t(i) - t(i-1);
                    w_e(i) = w_e(i-1) + 0.5 * (w_ei(i) + w_ei(i-1)) * dt;
                end
            end % for i
            
            % Energia total
            e_t = zeros(1, s);
            fprintf('\tCalculando energia total\n');
            for i = 1:s
                e_t(i) = e_k(1) + (e_v(1) + e_vamor(1)) + w_e(i) - (e_d(i) + e_damor(i));
            end % for i
            
            % Balance energetico normalizado
            ebe = zeros(1, s);
            fprintf('\tCalculando balance energetico\n');
            for i = 1:s
                ebe(i) = abs(w_e(i)-e_k(i)-(e_d(i) + e_damor(i))) / abs(w_e(i)) * 100;
            end % for i
            
            % Graficos
            fprintf('\tGenerando graficos\n');
            lw = r.linewidth; % Linewidth de los graficos
            dplot = false; % Indica que un grafico se realizo
            
            if strcmp(tipoplot, 'all') || strcmp(tipoplot, 'ek')
                fig_title = sprintf('E_K Energia Cinetica - %s %s', ctitle, carga.obtenerEtiqueta());
                plt = figure('Name', fig_title, 'NumberTitle', 'off');
                movegui(plt, 'center');
                plot(t, e_k, '-', 'LineWidth', lw);
                grid on;
                grid minor;
                xlabel('Tiempo (s)');
                ylabel('Energia cinetica');
                title(fig_title);
                ylims = get(gca, 'YLim');
                ylim([0, max(ylims)]);
                if plotcarga % Grafica la carga
                    axes('Position', [.59, .70, .29, .20]);
                    box on;
                    plot(t, c_p, 'k-', 'Linewidth', 0.8);
                    grid on;
                end
                dplot = true;
            end
            
            if strcmp(tipoplot, 'all') || strcmp(tipoplot, 'ev')
                fig_title = sprintf('E_V Energia Elastica - %s %s', ...
                    ctitle, carga.obtenerEtiqueta());
                plt = figure('Name', fig_title, 'NumberTitle', 'off');
                movegui(plt, 'center');
                plot(t, e_v+e_vamor, '-', 'LineWidth', lw);
                grid on;
                grid minor;
                xlabel('Tiempo (s)');
                ylabel('Energia elastica');
                title(fig_title);
                ylims = get(gca, 'YLim');
                ylim([0, max(ylims)]);
                if plotcarga % Grafica la carga
                    axes('Position', [.59, .70, .29, .20]);
                    box on;
                    plot(t, c_p, 'k-', 'Linewidth', 0.8);
                    grid on;
                end
                dplot = true;
            end
            
            if strcmp(tipoplot, 'all') || strcmp(tipoplot, 'ebe')
                fig_title = sprintf('Balance Energetico Normalizado - %s %s', ...
                    ctitle, carga.obtenerEtiqueta());
                plt = figure('Name', fig_title, 'NumberTitle', 'off');
                movegui(plt, 'center');
                plot(t, ebe, '-', 'LineWidth', lw);
                grid on;
                grid minor;
                xlabel('Tiempo (s)');
                ylabel('EBE (%)');
                title(fig_title);
                ylims = get(gca, 'YLim');
                ylim([0, max(ylims)]);
                if plotcarga % Grafica la carga
                    axes('Position', [.59, .70, .29, .20]);
                    box on;
                    plot(t, c_p, 'k-', 'Linewidth', 0.8);
                    grid on;
                end
                dplot = true;
            end
            
            if strcmp(tipoplot, 'all') || strcmp(tipoplot, 'evek') || strcmp(tipoplot, 'ekev')
                fig_title = sprintf('Energia Potencial - Cinetica - %s %s', ...
                    ctitle, carga.obtenerEtiqueta());
                plt = figure('Name', fig_title, 'NumberTitle', 'off');
                movegui(plt, 'center');
                plot(t, e_k, '-', 'LineWidth', lw);
                hold on;
                plot(t, e_v+e_vamor, '-', 'LineWidth', lw);
                grid on;
                grid minor;
                xlabel('Tiempo (s)');
                ylabel('Energia');
                legend({'E_K Energia cinetica', 'E_V Energia elastica'}, ...
                    'location', 'northeast');
                title(fig_title);
                ylims = get(gca, 'YLim');
                ylim([0, max(ylims)]);
                if plotcarga % Grafica la carga
                    axes('Position', [.59, .55, .29, .20]);
                    box on;
                    plot(t, c_p, 'k-', 'Linewidth', 0.8);
                    grid on;
                end
                dplot = true;
            end
            
            if strcmp(tipoplot, 'all') || strcmp(tipoplot, 'et')
                fig_title = sprintf('Energia Total - Disipada - Ingresada - %s %s', ...
                    ctitle, carga.obtenerEtiqueta());
                plt = figure('Name', fig_title, 'NumberTitle', 'off');
                movegui(plt, 'center');
                plot(t, e_t, '-', 'LineWidth', lw);
                hold on;
                plot(t, e_d+e_damor, '-', 'LineWidth', lw);
                plot(t, w_e, '-', 'LineWidth', lw);
                grid on;
                grid minor;
                xlabel('Tiempo (s)');
                ylabel('Energia');
                legend({'E_t Energia total', 'E_D Energia disipada total', ...
                    'W_E Trabajo externo'}, 'location', 'southeast');
                title(fig_title);
                ylims = get(gca, 'YLim');
                ylim([0, max(ylims)]);
                if plotcarga % Grafica la carga
                    axes('Position', [.59, .36, .29, .20]);
                    box on;
                    plot(t, c_p, 'k-', 'Linewidth', 0.8);
                    grid on;
                end
                dplot = true;
            end
            
            if strcmp(tipoplot, 'all') || strcmp(tipoplot, 'ed')
                
                % Graficos energia disipada
                fig_title = sprintf('Energia Disipada - %s %s', ...
                    ctitle, carga.obtenerEtiqueta());
                plt = figure('Name', fig_title, 'NumberTitle', 'off');
                movegui(plt, 'center');
                if carga.usoDeDisipadores()
                    plot(t, e_d+e_damor, '-', 'LineWidth', lw);
                    hold on;
                    plot(t, e_d, '-', 'LineWidth', lw);
                    plot(t, e_damor, '-', 'LineWidth', lw);
                    legend({'Energia disipada total', 'Energia disipada por la estructura', ...
                        'Energia disipada por disipadores'}, 'location', 'Best');
                else
                    plot(t, e_d, '-', 'LineWidth', lw);
                    % legend({'Energia disipada por la estructura'}, 'location', 'Best');
                end
                grid on;
                grid minor;
                xlabel('Tiempo (s)');
                ylabel('Energia');
                title(fig_title);
                ylims = get(gca, 'YLim');
                ylim([0, max(ylims)]);
                % if plotcarga % Grafica la carga
                %     axes('Position', [.59, .36, .29, .20]);
                %     box on;
                %     plot(t, c_p, 'k-', 'Linewidth', 0.8);
                %     grid on;
                % end
                dplot = true;
                
                % Comparacion energia estructura y disipador
                if carga.usoDeDisipadores()
                    fig_title = {'Razon energia estructura - disipador', ...
                        sprintf('%s %s', ctitle, carga.obtenerEtiqueta())};
                    plt = figure('Name', fig_title{1}, 'NumberTitle', 'off');
                    movegui(plt, 'center');
                    plot(t, medfilt1(e_d./e_damor, floor(r.mfilt*length(e_d))), ...
                        '-', 'LineWidth', lw);
                    grid on;
                    grid minor;
                    xlabel('Tiempo (s)');
                    ylabel('Razon estructura/disipador');
                    title(fig_title);
                    ylims = get(gca, 'YLim');
                    ylim([0, max(ylims)]);
                    if plotcarga % Grafica la carga
                        axes('Position', [.59, .68, .29, .20]);
                        box on;
                        plot(t, c_p, 'k-', 'Linewidth', 0.8);
                        grid on;
                    end
                end
                
            end
            
            % Si no se realizo ningun grafico
            if ~dplot
                error('Tipo de grafico %s incorrecto, valores aceptados: %s', tipoplot, ...
                    'ek, ev, ekev, ebe, et, ed');
            end
            
            % Finaliza proceso
            drawnow();
            fprintf('\tProceso finalizado en %.2f segundos\n', cputime-tinicial);
            dispMetodoTEFAME();
            
        end % calcularCurvasEnergia function
        
        function e_v = calcularModosEnergia(obj, carga, dispinfo)
            % calcularModosEnergia: Metodo que calcula las energias
            % elasticas asociadas a una carga por cada modo y retorna una
            % matriz ordenada por energia y numero de modos
            
            if ~exist('dispinfo', 'var')
                dispinfo = true;
            end
            
            % Verifica que la carga se haya calculado
            if ~isa(carga, 'CargaDinamica')
                error('Solo se pueden graficar cargas dinamicas');
            end
            c_u = carga.obtenerDesplazamiento();
            
            % No usar carga.cargaCalculada() dado que este metodo es usado
            % por Newmark al iterar sobre los disipadores
            if isempty(c_u)
                error('La carga %s no se ha calculado', carga.obtenerEtiqueta());
            end
            
            if dispinfo
                fprintf('\tCalculando energia elastica por cada modo:\n');
                obj.imprimirPropiedadesAnalisisCarga(carga);
            end
            
            % Obtiene las matrices
            k = obj.obtenerMatrizRigidez();
            phi = obj.obtenerMatrizPhi();
            
            % Realiza calculos de energia elastica
            [~, s] = size(c_u);
            
            % Energia elastica total
            e_v = zeros(obj.numModos, 5);
            for j = 1:obj.numModos % Recorre cada modo
                e_vsum = 0; % Suma la energia asociada a un modo para todo el tiempo
                kj = phi(:, j)' * k;
                for i = 1:s % Recorre el tiempo
                    vv = c_u(:, i); % Obtiene el vector de desplazamiento para el tiempo i
                    e_vsum = e_vsum + 0.5 * vv' * phi(:, j) * kj * vv;
                end % for i
                e_v(j, 1) = j;
                e_v(j, 2) = obj.wn(j);
                e_v(j, 3) = 2 * pi() / obj.wn(j);
                e_v(j, 4) = abs(e_vsum);
            end % for j
            
            % Normaliza por el maximo
            e_vmax = max(e_v(:, 4));
            for j = 1:obj.numModos
                e_v(j, 4) = e_v(j, 4) / e_vmax;
            end % for j
            
            % Suma
            e_vsum = sum(e_v(:, 4));
            for j = 1:obj.numModos
                e_v(j, 5) = e_v(j, 4) / e_vsum;
            end % for j
            
            % Ordena la matriz
            e_v = sortrows(e_v, -4);
            
        end % calcularModosEnergia function
        
        function [esfmax, esf, maxp, dirk] = calcularEsfuerzosElemento(obj, carga, elemento, direccion)
            % calcularEsfuerzosElemento: Calcula los esfuerzos maximos de
            % un elemento a partir de una carga dinamica
            
            % Obtiene resultados de la carga
            u_c = carga.obtenerDesplazamiento();
            
            % Verifica que la carga se haya calculado
            if ~(isa(carga, 'CargaDinamica') || isa(carga, 'CombinacionCargas'))
                error('Solo se pueden graficar cargas dinamicas o combinaciones de cargas');
            end
            if ~carga.cargaCalculada()
                error('La carga %s no se ha calculado', carga.obtenerEtiqueta());
            end
            
            % Verifica que el elemento este bien definido
            if ~isa(elemento, 'Elemento')
                error('El elemento no pertenece a la clase Elemento');
            end
            
            % Genera el esfuerzo por el tiempo
            t = carga.obtenerVectorTiempo(); % Vector de tiempo
            esf = zeros(obj.modeloObj.obtenerNumerosGDL(), length(t));
            esfmax = zeros(obj.modeloObj.obtenerNumerosGDL(), 1);
            
            % Obtiene desplazamientos originales de los nodos del elemento
            nodos = elemento.obtenerNodos();
            despl = {};
            for i = 1:length(nodos)
                despl{i} = nodos{i}.obtenerDesplazamientos(); %#ok<AGROW>
            end
            ngdl = nodos{1}.obtenerNumeroGDL();
            
            % Verifica la direccion
            dirk = 1; % Direccion de analisis de cada elemento
            if direccion ~= 0
                if ~(verificarVectorDireccion(direccion, nodos{1}.obtenerNumeroGDL())) || sum(direccion) ~= 1
                    error('Direccion de analisis del elemento mal definido');
                end
                for i = 1:length(direccion)
                    if direccion(i) == 1
                        dirk = i;
                        break;
                    end
                end % for i
            end
            
            % Posicion del maximo
            maxp = 1;
            maxv = 0;
            
            % Por cada tiempo obtiene la fuerza resistente local
            for i = 1:length(t)
                
                % Define los desplazamientos del nodo
                for j = 1:length(nodos)
                    k = nodos{j}.obtenerGDLIDCondensado();
                    unodo = zeros(1, ngdl);
                    for n = 1:ngdl % Recorre cada desplazamiento de ese grado para el tiempo i
                        if k(n) > 0
                            unodo(n) = u_c(k(n), i);
                        end
                    end % for n
                    nodos{j}.definirDesplazamientos(unodo);
                end % for j
                
                % Obtiene la fuerza resistente
                fr = elemento.obtenerFuerzaResistenteCoordLocal();
                for j = 1:length(fr) / 2
                    esf(j, i) = fr(j);
                end % for j
                
                % Actualiza el maximo
                if abs(esf(dirk, i)) > maxv
                    maxv = abs(esf(dirk, i));
                    maxp = i;
                end
                
                for j = 1:length(esfmax)
                    if abs(esf(j, i)) > abs(esfmax(j))
                        esfmax(j) = esf(j, i);
                    end
                end % for j
                
            end % for i
            
            % Resetea los desplazamientos originales
            for i = 1:length(nodos)
                nodos{i}.definirDesplazamientos(despl{i});
            end % for i
            
        end % calcularEsfuerzosElemento function
        
        function plotEsfuerzosElemento(obj, carga, elemento, direccion, varargin)
            % plotEsfuerzosElemento: Grafica los esfuerzos de un elemento
            %
            % Parametros opcionales:
            %   tlim        Tiempo de analisis limite
            %   unidadC     Unidad corte
            %   unidadM     Unidad momento
            
            % Inicia el proceso
            tinicial = cputime;
            
            % Recorre parametros opcionales
            p = inputParser;
            p.KeepUnmatched = true;
            addOptional(p, 'tlim', 0);
            addOptional(p, 'unidadC', 'tonf');
            addOptional(p, 'unidadM', 'tonf-m');
            parse(p, varargin{:});
            r = p.Results;
            
            % Obtiene las variables
            tlim = r.tlim;
            
            % Verifica que el elemento este bien definido
            if ~isa(elemento, 'Elemento')
                error('El elemento no pertenece a la clase Elemento');
            end
            
            % Realiza calculos de esfuerzo
            fprintf('Calculando esfuerzos elemento:\n');
            fprintf('\tElemento %s\n', elemento.obtenerEtiqueta());
            ctitle = obj.imprimirPropiedadesAnalisisCarga(carga);
            [~, esf, maxp, dirk] = obj.calcularEsfuerzosElemento(carga, elemento, direccion);
            
            % Genera el vector de tiempo
            t = carga.obtenerVectorTiempo(); % Vector de tiempo
            if tlim == 0
                tlim = [min(t), max(t)];
            else
                tlim = [max(min(tlim), min(t)), min(max(tlim), max(t))];
            end
            
            dirn = '';
            diru = '';
            if dirk == 1
                dirn = 'Axial';
                diru = r.unidadC;
            elseif dirk == 2
                dirn = 'Corte';
                diru = r.unidadC;
            elseif dirk == 3
                dirn = 'Giro';
                diru = r.unidadM;
            end
            
            % Crea el grafico
            fig_title = sprintf('%s %s - Elemento %s - Direccion %s', ...
                ctitle, carga.obtenerEtiqueta(), elemento.obtenerEtiqueta(), dirn);
            plt = figure('Name', fig_title, 'NumberTitle', 'off');
            movegui(plt, 'center');
            
            plot(t, esf(dirk, :), '-', 'LineWidth', 1);
            ylabel(sprintf('Esfuerzo (%s)', diru));
            xlabel('t (s)');
            hold on;
            
            % Grafica el maximo
            drawVyLine(esf(dirk, maxp), 'k--', 1.25);
            xlim(tlim);
            grid on;
            title(fig_title);
            
            legend({sprintf('Esfuerzo elemento: %s', carga.obtenerEtiqueta()), ...
                sprintf('Esfuerzo maximo: %.2f (%s)', esf(dirk, maxp), diru)}, ...
                'location', 'southeast');
            
            % Finaliza proceso
            fprintf('\tProceso finalizado en %.2f segundos\n', cputime-tinicial);
            dispMetodoTEFAME();
            
        end % plotEsfuerzosElemento function
        
        function plotTrayectoriaNodo(obj, carga, nodo, direccion, varargin)
            % plotTrayectoriaNodo: Grafica la trayectoria de un nodo
            % (desplazamiento, velocidad y aceleracion) para todo el tiempo
            %
            % Parametros opcionales:
            %   tlim        Tiempo de analisis limite
            %   unidadC     Unidad carga
            %   unidadL     Unidad longitud
            
            % Inicia proceso
            tinicial = cputime;
            
            % Verifica que la direccion sea correcta
            if sum(direccion) ~= 1
                error('Direccion invalida');
            end
            if ~verificarVectorDireccion(direccion, nodo.obtenerNumeroGDL())
                error('Vector direccion mal definido');
            end
            
            % Recorre parametros opcionales
            p = inputParser;
            p.KeepUnmatched = true;
            addOptional(p, 'tlim', 0);
            addOptional(p, 'unidadC', 'tonf');
            addOptional(p, 'unidadL', 'm');
            parse(p, varargin{:});
            r = p.Results;
            
            % Obtiene las variables
            tlim = r.tlim;
            
            % Obtiene resultados de la carga
            p_c = carga.obtenerCarga();
            u_c = carga.obtenerDesplazamiento();
            v_c = carga.obtenerVelocidad();
            a_c = carga.obtenerAceleracion();
            
            % Verifica que la carga se haya calculado
            if ~(isa(carga, 'CargaDinamica') || isa(carga, 'CombinacionCargas'))
                error('Solo se pueden graficar cargas dinamicas o combinaciones de cargas');
            end
            if ~carga.cargaCalculada()
                error('La carga %s no se ha calculado', carga.obtenerEtiqueta());
            end
            
            fprintf('Calculando trayectoria nodo:\n');
            fprintf('\tNodo %s\n', nodo.obtenerEtiqueta());
            ctitle = obj.imprimirPropiedadesAnalisisCarga(carga);
            
            % Elige al nodo
            [r, ~] = size(a_c);
            ngd = nodo.obtenerGDLIDCondensado();
            ng = 0; % Numero grado analisis
            nd = 0; % Numero direccion analisis
            for i = 1:length(direccion)
                if direccion(i) == 1
                    ng = ngd(i);
                    nd = i;
                end
            end % for i
            if ng == 0
                error('No se ha obtenido el GDLID del nodo, es posible que corresponda a un apoyo o bien que el grado de libertad fue condensado');
            end
            if ng > r
                error('El GDLID excede al soporte del sistema');
            end
            
            % Genera el vector de tiempo
            t = carga.obtenerVectorTiempo(); % Vector de tiempo
            if tlim == 0
                tlim = [min(t), max(t)];
            else
                tlim = [max(min(tlim), min(t)), min(max(tlim), max(t))];
            end
            
            % Crea el grafico
            fig_title = sprintf('%s %s - Nodo %s - GDLID condensado %d - Direccion %d', ...
                ctitle, carga.obtenerEtiqueta(), nodo.obtenerEtiqueta(), ng, nd);
            plt = figure('Name', fig_title, 'NumberTitle', 'off');
            movegui(plt, 'center');
            
            subplot(4, 1, 1);
            plot(t, p_c(ng, :), 'k-', 'LineWidth', 1);
            ylabel(sprintf('carga (%s)', r.unidadC));
            xlabel('t (s)');
            xlim(tlim);
            grid on;
            title(fig_title);
            
            subplot(4, 1, 2);
            plot(t, u_c(ng, :), 'k-', 'LineWidth', 1);
            title('Desplazamiento');
            ylabel(sprintf('u (%s)', r.unidadL));
            xlabel('t (s)');
            xlim(tlim);
            grid on;
            
            subplot(4, 1, 3);
            plot(t, v_c(ng, :), 'k-', 'LineWidth', 1);
            title('Velocidad');
            ylabel(sprintf('v (%s/s)', r.unidadL));
            xlabel('t (s)');
            xlim(tlim);
            grid on;
            
            subplot(4, 1, 4);
            plot(t, a_c(ng, :), 'k-', 'LineWidth', 1);
            title('Aceleracion');
            ylabel(sprintf('a (%s/s^s)', r.unidadL));
            xlabel('t (s)');
            xlim(tlim);
            grid on;
            
            % Finaliza proceso
            fprintf('\tProceso finalizado en %.2f segundos\n', cputime-tinicial);
            dispMetodoTEFAME();
            
        end % plotTrayectoriaNodo function
        
        function activarCargaAnimacion(obj)
            % activarCargaAnimacion: Carga la animacion  una vez calculada
            
            obj.cargarAnimacion = true;
            
        end % activarCargaAnimacion funcion
        
        function desactivarCargaAnimacion(obj)
            % desactivarCargaAnimacion: Desactiva la animacion una vez calculada
            
            obj.cargarAnimacion = false;
            
        end % desactivarCargaAnimacion funcion
        
        function activarPlotDeformadaInicial(obj)
            % activarPlotDeformadaInicial: Activa el grafico de la deformada inicial
            
            obj.mostrarDeformada = true;
            
        end % activarPlotDeformadaInicial function
        
        function desactivarPlotDeformadaInicial(obj)
            % desactivarPlotDeformadaInicial: Desactiva el grafico de la
            % deformada inicial
            
            obj.mostrarDeformada = false;
            
        end % desactivarPlotDeformadaInicial function
        
        function disp(obj)
            % disp: es un metodo de la clase ModalEspectral que se usa para imprimir en
            % command Window la informacion del analisis espectral realizado
            %
            % Imprime la informacion guardada en el ModalEspectral (obj) en
            % pantalla
            
            if ~obj.analisisFinalizado
                error('El analisis modal aun no ha sido calculado');
            end
            
            fprintf('Propiedades analisis modal espectral:\n');
            
            % Muestra los grados de libertad
            fprintf('\tNumero de grados de libertad: %d\n', ...
                obj.numeroGDL-obj.gdlCond);
            fprintf('\tNumero de grados condensados: %d\n', obj.gdlCond);
            fprintf('\tNumero de direcciones por grado: %d\n', obj.numDG);
            fprintf('\tNumero de modos en el analisis: %d\n', obj.numModos);
            
            % Propiedades de las matrices
            detKt = det(obj.Kt);
            detMt = det(obj.Mt);
            if detKt ~= Inf
                fprintf('\tMatriz de rigidez:\n');
                fprintf('\t\tDeterminante: %f\n', detKt);
            end
            if abs(detMt) >= 1e-20
                fprintf('\tMatriz de Masa:\n');
                fprintf('\t\tDeterminante: %f\n', detMt);
            end
            fprintf('\tMasa total de la estructura: %.3f\n', obj.Mtotal);
            
            fprintf('\tPeriodos y participacion modal:\n');
            if obj.numDG == 2
                fprintf('\t\tN\t|\tT (s)\t| w (rad/s)\t|\tU1\t\t|\tU2\t\t|\tSum U1\t|\tSum U2\t|\n');
                fprintf('\t\t-----------------------------------------------------------------------------\n');
            elseif obj.numDG == 3
                fprintf('\t\tN\t|\tT (s)\t| w (rad/s)\t|\tU1\t\t|\tU2\t\t|\tU3\t\t|\tSum U1\t|\tSum U2\t|\tSum U3\t|\n');
                fprintf('\t\t----------------------------------------------------------------------------------------------------\n');
            end
            
            for i = 1:obj.numModos
                if obj.numDG == 2
                    fprintf('\t\t%d\t|\t%.3f\t|\t%.3f\t|\t%.3f\t|\t%.3f\t|\t%.3f\t|\t%.3f\t|\t%.3f\n', i, obj.Tn(i), ...
                        obj.wn(i), obj.Mmeff(i, 1), obj.Mmeff(i, 2), ...
                        obj.Mmeffacum(i, 1), obj.Mmeffacum(i, 2));
                elseif obj.numDG == 3
                    fprintf('\t\t%d\t|\t%.3f\t|\t%.3f\t|\t%.3f\t|\t%.3f\t|\t%.3f\t|\t%.3f\t|\t%.3f\t|\t%.3f\t|\t%.3f\n', i, obj.Tn(i), ...
                        obj.wn(i), obj.Mmeff(i, 1), obj.Mmeff(i, 2), obj.Mmeff(i, 3), ...
                        obj.Mmeffacum(i, 1), obj.Mmeffacum(i, 2), obj.Mmeffacum(i, 3));
                end
                fprintf('\n');
            end % for i
            
            % Busca los periodos para los cuales se logra el 90%
            mt90p = zeros(obj.numDG, 1);
            for i = 1:obj.numDG
                fprintf('\t\tN periodo en U%d para el 90%% de la masa: ', i);
                for j = 1:obj.numModos
                    if obj.Mmeffacum(j, i) >= 0.90
                        mt90p(i) = j;
                        break;
                    end
                end % for j
                if mt90p(i) > 0
                    fprintf('%d\n', mt90p(i));
                else
                    fprintf('Incrementar modos de analisis\n');
                end
            end % for i
            
            dispMetodoTEFAME();
            
        end % disp function
        
        function c = obtenerCargaEstatica(obj, varargin)
            % obtenerCargaEstatica: Obtiene la carga estatica del modelo
            % como una carga dinamica para ser incluida en las
            % combinaciones de cargas
            %
            % Parametros opcionales:
            %   etiqueta        Nombre de la carga
            
            % Recorre parametros opcionales
            p = inputParser;
            p.KeepUnmatched = true;
            addOptional(p, 'etiqueta', 'Carga Estatica');
            parse(p, varargin{:});
            r = p.Results;
            
            c = CargaDinamica(r.etiqueta);
            c.dt = 1;
            c.tAnalisis = 1;
            
            % Crea vector de velocidad y aceleracion ceros
            v = zeros(length(obj.u), 1);
            a = zeros(length(obj.u), 1);
            
            c.guardarCarga(obj.F);
            c.guardarDesplazamiento(obj.u);
            c.guardarVelocidad(v);
            c.guardarAceleracion(a);
            
        end % obtenerCargaEstatica function
        
    end % methods(public) ModalEspectral
    
    methods(Access = private)
        
        function definirNumeracionGDL(obj)
            % definirNumeracionGDL: es un metodo de la clase ModalEspectral que
            % se usa para definir como se enumeran los GDL en el modelo
            %
            % Define y asigna la enumeracion de los GDL en el modelo
            
            fprintf('\tDefiniendo numeracion GDL\n');
            
            % Primero se aplican las restricciones al modelo
            obj.modeloObj.aplicarRestricciones();
            
            % Extraemos los nodos para que sean enumerados
            nodoObjetos = obj.modeloObj.obtenerNodos();
            numeroNodos = length(nodoObjetos);
            
            % Inicializamos en cero el contador de GDL
            contadorGDL = 0;
            for i = 1:numeroNodos
                
                gdlidNodo = nodoObjetos{i}.obtenerGDLID;
                
                % Si no es reaccion entonces se agrega como GDL
                for j = 1:length(gdlidNodo)
                    if (gdlidNodo(j) == -1)
                        contadorGDL = contadorGDL + 1;
                        gdlidNodo(j) = contadorGDL;
                    end % if
                end % for j
                nodoObjetos{i}.definirGDLID(gdlidNodo);
                
            end % for i
            
            % Guardamos el numero de GDL, es decir el numero de ecuaciones
            % del sistema
            obj.numeroGDL = contadorGDL;
            
            % Extraemos los Elementos del modelo
            objetos = obj.modeloObj.obtenerElementos();
            disipadorObjetos = obj.modeloObj.obtenerDisipadores();
            numeroElementos = length(objetos);
            numeroDisipadores = length(disipadorObjetos);
            % Definimos los GDLID en los elementos para poder formar la matriz de rigidez
            for i = 1:numeroElementos
                objetos{i}.definirGDLID();
            end % for i
            
            for i = 1:numeroDisipadores
                disipadorObjetos{i}.definirGDLID();
            end % for i
            
        end % definirNumeracionGDL function
        
        function calcularModalEspectral(obj, nModos, betacR, modocR, ...
                direcR, betacP, maxcond, valvecAlgoritmo, valvecTolerancia, ...
                muIterDesplazamiento , nRitz)
            % calcularModalEspectral: Calcula el metodo modal espectral
            
            % Calcula tiempo inicio
            fprintf('\tCalculando metodo modal espectral:\n');
            tInicio = cputime;
            
            % Obtiene matriz de masa
            diagMt = diag(obj.Mt);
            obj.Mtotal = sum(diagMt) / 2;
            
            % Obtiene los grados de libertad
            ngdl = length(obj.Mt); % Numero de grados de libertad
            ndg = obj.modeloObj.obtenerNumerosGDL(); % Grados de libertad por nodo
            
            % ---------------- CONDENSACION ESTATICA DE GUYAN ---------------
            % Primero se genera matriz para reordenar elementos (rot)
            vz = []; % Vector que identifica indices a condensar
            j = 1;
            if maxcond >= 0
                for i = 1:length(diagMt)
                    if diagMt(i) <= maxcond
                        vz(j) = i; %#ok<AGROW>
                        j = j + 1;
                    end
                end % for i
            end
            
            % Si condensa grados
            obj.gdlCond = length(vz);
            realizaCond = false;
            if obj.gdlCond > 0
                
                realizaCond = true;
                % Chequea cuantos grados quedan
                nndg = ndg;
                if ndg > 2
                    for i = 2:ndg
                        % Si todos los grados se dividen por 3, entonces se borra
                        % el tercer grado de libertad (giro por ejemplo)
                        if allDivMod(vz, i)
                            nndg = nndg - 1;
                        end
                    end % for i
                end
                ndg = nndg;
                
                lpasivos = length(vz);
                lactivos = length(diagMt) - lpasivos;
                rot = zeros(length(diagMt), length(diagMt));
                aux0 = 1;
                aux1 = 1;
                aux2 = length(diagMt) - lpasivos + 1;
                for i = 1:1:length(rot)
                    if aux0 <= length(vz) && i == vz(aux0)
                        rot(i, aux2) = 1;
                        aux2 = aux2 + 1;
                        aux0 = aux0 + 1;
                    else
                        rot(i, aux1) = 1;
                        aux1 = aux1 + 1;
                    end
                end % for i
                
                % Se realiza rotacion de matriz de rigidez
                Krot = rot' * obj.Kt * rot;
                
                % Se determina matriz de rigidez condensada (Keq)
                Kaa = Krot(1:lactivos, 1:lactivos);
                Kap = Krot(1:lactivos, lactivos+1:end);
                Kpa = Krot(lactivos+1:end, 1:lactivos);
                Kpp = Krot(lactivos+1:end, lactivos+1:end);
                Keq = Kaa - Kap * Kpp^(-1) * Kpa;
                
                % Generacion de matriz T de condensacion
                If = size(Kaa, 1);
                T1 = eye(If);
                T2 = -(Kpp)^(-1) * (Kpa);
                T = vertcat(T1, T2);
                
                % Se determina matriz de masa condensada (Meq)
                Mrot = rot' * obj.Mt * rot;
                Meq = T' * Mrot * T;
                
                % Condensa la fuerza estatica
                obj.F = rot' * obj.F;
                obj.F = T' * obj.F;
                
                % Condensa los desplazamientos estaticos
                obj.u = rot' * obj.u;
                obj.u = T' * obj.u;
                
                % Actualiza los grados
                cngdl = length(Meq);
                if cngdl < ngdl
                    fprintf('\t\tSe han condensado %d grados de libertad\n', ngdl-cngdl);
                    ngdl = cngdl;
                end
                
                % Actualiza los nodos
                nodos = obj.modeloObj.obtenerNodos();
                nnodos = length(nodos);
                for i = 1:nnodos
                    gdl = nodos{i}.obtenerGDLID();
                    gdlaux = gdl;
                    for j = 1:length(gdl)
                        for k = 1:length(vz) % Recorre los grados condensados
                            if vz(k) == gdl(j)
                                gdlaux(j) = 0; % gdl condensado
                            elseif vz(k) < gdl(j)
                                gdlaux(j) = gdlaux(j) - 1;
                            else
                                gdlaux(j) = gdlaux(j);
                            end
                        end % for k
                    end % for j
                    nodos{i}.definirGDLIDCondensado(gdlaux);
                end % for i
                
                MtotalRed = sum(diag(Meq)) / 2;
                fprintf('\t\tTras la condensacion la masa se redujo en %.2f (%.2f%%)\n', ...
                    obj.Mtotal-MtotalRed, 100*(obj.Mtotal - MtotalRed)/obj.Mtotal);
                
            else % No condensa grados
                
                Meq = obj.Mt;
                Keq = obj.Kt;
                fprintf('\t\tNo se han condensado grados de libertad\n');
                
            end
            
            % Una vez pasado este punto no deberian haber masas nulas o
            % incorrectas
            for i = 1:ngdl
                if Meq(i, i) <= 0
                    error('La matriz de masa esta mal definida, M(%d,%d)<=0', i, i);
                end
            end % for i
            
            fprintf('\t\tGrados de libertad totales: %d\n', ngdl);
            fprintf('\t\tNumero de direcciones de analisis: %d\n', ndg);
            nModos = min(nModos, ngdl);
            
            %------------- CALCULO VALORES Y VECTORES PROPIOS ---------------
            eigCalcT = cputime;
            
            if strcmp(valvecAlgoritmo, 'eigs')
                fprintf('\t\tCalculo valores y vectores propios con metodo eigs\n');
                [modalPhin, modalWn] = calculoEigEigs(Meq, Keq, nModos);
            elseif strcmp(valvecAlgoritmo, 'itDir')
                fprintf('\t\tCalculo valores y vectores con algoritmo iteracion directa\n');
                fprintf('\t\t\tTolerancia: %.4f\n', valvecTolerancia);
                [modalPhin, modalWn] = calculoEigIterDirecta(Meq, Keq, valvecTolerancia);
                nModos = length(modalWn);
            elseif strcmp(valvecAlgoritmo, 'matBarr')
                fprintf('\t\tCalculo valores y vectores propios con algoritmo matriz de barrido\n');
                fprintf('\t\t\tTolerancia: %.4f\n', valvecTolerancia);
                [modalPhin, modalWn] = calculoEigDirectaBarrido(Meq, Keq, nModos, valvecTolerancia);
                % elseif strcmp(valvecAlgoritmo, 'itInv')
                %     fprintf('\t\tCalculo valores y vectores propios con metodo iteracion inversa\n');
            elseif strcmp(valvecAlgoritmo, 'itInvDesp')
                fprintf('\t\tCalculo valores y vectores propios con metodo iteracion inversa con desplazamientos\n');
                fprintf('\t\t\tTolerancia: %.4f\n', valvecTolerancia);
                fprintf('\t\t\tMu: %.4f\n', muIterDesplazamiento);
                [modalPhin, modalWn] = calculoEigIterInvDesplazamiento(Meq, Keq, muIterDesplazamiento, valvecTolerancia);
                nModos = length(modalWn);
            elseif strcmp(valvecAlgoritmo, 'itSubesp')
                fprintf('\t\tCalculo valores y vectores propios con metodo iteracion del subespacio\n');
                fprintf('\t\t\tTolerancia: %.4f\n', valvecTolerancia);
                [modalPhin, modalWn] = calculoEigItSubespacio(Meq, Keq, nModos, valvecTolerancia);
            elseif strcmp(valvecAlgoritmo, 'ritz')
                fprintf('\t\tCalculo valores y vectores propios con Vectores Ritz\n');
                % Fritz = analisisObj.obtenerVectorInfluencia;
                Fritz = diag(eye(length(Keq)));
                [modalPhin, modalWn] = calculoLDV(Meq, Keq, Fritz, nRitz);
                nModos = length(modalWn);
            else
                error('Algoritmo valvec:%s incorrecto, valores posibles: eigvc,itDir,matBarr,itInvDesp,itSubesp,ritz', ...
                    valvecAlgoritmo);
            end
            fprintf('\t\t\tFinalizado en %.3f segundos\n', cputime-eigCalcT);
            obj.numModos = nModos;
            
            % Se recuperan los grados de libertad condensados y se
            % ordenan de acuerdo a la configuracion original
            if realizaCond
                modalPhinFull = T * modalPhin;
                rot_inv = rot^(-1);
                modalPhinFull = rot_inv' * modalPhinFull;
                obj.condMatT = T;
                obj.condMatRot = rot_inv;
            else
                modalPhinFull = modalPhin;
                obj.condMatT = eye(length(modalPhin));
                obj.condMatRot = eye(length(modalPhin));
            end
            
            % Calcula las frecuencias del sistema
            modalTn = (modalWn.^-1) .* 2 * pi(); % Calcula los periodos
            
            % Calcula las matrices
            modalMmt = modalPhin' * Meq * modalPhin;
            modalPhin = modalPhin * diag(diag(modalMmt).^-0.5);
            modalMm = diag(diag(modalPhin'*Meq*modalPhin));
            modalKm = diag(diag(modalPhin'*Keq*modalPhin));
            
            % Reordena los periodos
            Torder = zeros(nModos, 1);
            Tpos = 1;
            for i = 1:nModos
                maxt = 0; % Periodo
                maxi = 0; % Indice
                for j = 1:nModos % Se busca el elemento para etiquetar
                    if Torder(j) == 0 % Si aun no se ha etiquetado
                        if modalTn(j) > maxt
                            maxt = modalTn(j);                           
                            maxi = j;
                        end
                    end
                end % for j
                Torder(maxi) = Tpos;
                Tpos = Tpos + 1;
            end % for i
            % ngdl = length(Meq); % Numero de grados de libertad
            
            % Asigna valores
            obj.phinExt = modalPhinFull;
            obj.Tn = zeros(nModos, 1);
            obj.wn = zeros(nModos, 1);
            obj.phin = zeros(ngdl, nModos);
            obj.Mm = modalMm;
            obj.Km = modalKm;
            obj.Mteq = Meq;
            obj.Kteq = Keq;
            for i = 1:nModos
                obj.Tn(Torder(i)) = modalTn(i);
                obj.wn(Torder(i)) = modalWn(i);
                obj.phin(:, Torder(i)) = modalPhin(:, i);
            end % for i
            
            % Crea vector influencia
            obj.rm = zeros(ngdl, ndg);
            for j = 1:ndg
                for i = 1:ngdl
                    if mod(i, ndg) == j || (mod(i, ndg) == 0 && j == ndg)
                        obj.rm(i, j) = 1;
                    end
                end % for i
            end % for j
            
            % Realiza el calculo de las participaciones modales
            obj.Lm = zeros(nModos, ndg);
            obj.Mmeff = zeros(ngdl, ndg);
            obj.Mmeffacum = zeros(ngdl, ndg);
            Mtotr = zeros(ndg, 1);
            
            % Recorre cada grado de libertad (horizontal, vertical, giro)
            for j = 1:ndg
                Mtotr(j) = sum(Meq*obj.rm(:, j));
                for k = 1:nModos
                    obj.Lm(k, j) = obj.phin(:, k)' * Meq * obj.rm(:, j);
                    obj.Mmeff(k, j) = obj.Lm(k, j).^2 ./ modalMm(k, k);
                end % for k
                
                obj.Mmeff(:, j) = obj.Mmeff(:, j) ./ Mtotr(j);
                obj.Mmeffacum(1, j) = obj.Mmeff(1, j);
                for i = 2:nModos
                    obj.Mmeffacum(i, j) = obj.Mmeffacum(i-1, j) + obj.Mmeff(i, j);
                end % for i
            end % for j
            
            % -------- CALCULO DE AMORTIGUAMIENTO DE RAYLEIGH -------------
            
            % Se recorren los numero de modos, si alguno es mayor a los
            % modos de analisis se reajusta y lanza warning
            for i = 1:length(modocR)
                if modocR(i) > nModos
                    warning('Modo de Rayleigh %d excede al numero de modos de analisis %d, se ha reajustado este ultimo', ...
                        modocR(i), nModos);
                    modocR(i) = nModos;
                end
            end % for i
            
            countcR = [0, 0];
            m = 0;
            n = 0;
            for i = 1:min(length(obj.Mmeff), nModos)
                if obj.Mmeff(i, 1) > max(obj.Mmeff(i, 2:ndg))
                    countcR(1) = countcR(1) + 1;
                    if direcR(1) == 'h' && modocR(1) == countcR(1)
                        m = i;
                    elseif direcR(2) == 'h' && modocR(2) == countcR(1)
                        n = i;
                    end
                elseif obj.Mmeff(i, 2) > ...
                        max(obj.Mmeff(i, 1), obj.Mmeff(i, max(1, ndg)))
                    countcR(2) = countcR(2) + 1;
                    if direcR(1) == 'v' && modocR(1) == countcR(2)
                        m = i;
                    elseif direcR(2) == 'h' && modocR(2) == countcR(2)
                        n = i;
                    end
                end
            end % for i
            
            if m == 0 || n == 0
                warning('Se requiere aumentar el numero de modos para determinar matriz de amortiguamiento de Rayleigh');
                m = 1;
                n = 1;
            end
            w = obj.wn;
            a = (2 * w(m) * w(n)) / (w(n)^2 - w(m)^2) .* [w(n), -w(m); ...
                -1 / w(n), 1 / w(m)] * betacR';
            obj.cRayleigh = a(1) .* Meq + a(2) .* Keq;
            
            % ------ CALCULO DE AMORTIGUAMIENTO DE WILSON-PENZIEN ----------
            % Se declaran todos los amortiguamientos criticos del sistema,
            % (horizontal, vertical y rotacional)
            d = zeros(length(obj.Mmeff), length(obj.Mmeff));
            w = obj.wn;
            Mn = modalMmt;
            obj.cPenzien = 0;
            
            for i = 1:length(Mn)
                if obj.Mmeff(i, 1) > max(obj.Mmeff(i, 2:ndg))
                    d(i, i) = 2 * betacP(1) * w(i) / Mn(i, i);
                elseif obj.Mmeff(i, 2) > ...
                        max(obj.Mmeff(i, 1), obj.Mmeff(i, max(1, ndg)))
                    d(i, i) = 2 * betacP(2) * w(i) / Mn(i, i);
                else
                    d(i, i) = 2 * betacP(3) * w(i) / Mn(i, i);
                end
                obj.cPenzien = obj.cPenzien + ...
                    Meq * (d(i, i) * modalPhin(:, i) * modalPhin(:, i)') * Meq;
            end % for i
            
            % Termina el analisis
            obj.analisisFinalizado = true;
            obj.numDG = ndg;
            obj.numDGReal = obj.modeloObj.obtenerNumerosGDL();
            fprintf('\tSe completo el analisis en %.3f segundos\n', cputime-tInicio);
            
        end % calcularModalEspectral function
        
        function ensamblarMatrizRigidez(obj)
            % ensamblarMatrizRigidez: es un metodo de la clase ModalEspectral que se usa para
            % realizar el armado de la matriz de rigidez del modelo analizado
            %
            % ensamblarMatrizRigidez(obj)
            %
            % Ensambla la matriz de rigidez del modelo analizado usando el metodo
            % indicial
            
            fprintf('\tEnsamblando matriz de rigidez\n');
            obj.Kt = zeros(obj.numeroGDL, obj.numeroGDL);
            
            % Extraemos los Elementos
            objetos = obj.modeloObj.obtenerElementos();
            numeroElementos = length(objetos);
            
            % Definimos los GDLID en los elementos
            for i = 1:numeroElementos
                
                % Se obienen los gdl del elemento metodo indicial
                gdl = objetos{i}.obtenerGDLID();
                ngdl = objetos{i}.obtenerNumeroGDL();
                
                % Se obtiene la matriz de rigidez global del elemento-i
                k_globl_elem = objetos{i}.obtenerMatrizRigidezCoordGlobal();
                
                % Se calcula el metodo indicial
                for r = 1:ngdl
                    for s = 1:ngdl
                        i_ = gdl(r);
                        j_ = gdl(s);
                        
                        % Si corresponden a grados de libertad -> puntos en (i,j)
                        % se suma contribucion metodo indicial
                        if (i_ ~= 0 && j_ ~= 0)
                            obj.Kt(i_, j_) = obj.Kt(i_, j_) + k_globl_elem(r, s);
                        end
                        
                    end % for s
                end % for r
                
            end % for i
            
        end % ensamblarMatrizRigidez function
        
        function ensamblarMatrizMasa(obj)
            % ensamblarMatrizMasa: es un metodo de la clase ModalEspectral que se usa para
            % realizar el armado de la matriz de masa del modelo
            %
            % Ensambla la matriz de masa del modelo analizado usando el metodo
            % indicial
            
            fprintf('\tEnsamblando matriz de masa\n');
            obj.Mt = zeros(obj.numeroGDL, obj.numeroGDL);
            
            % Extraemos los Elementos
            fprintf('\t\tAgrega masa de elementos\n');
            objetos = obj.modeloObj.obtenerElementos();
            numeroElementos = length(objetos);
            
            % Definimos los GDLID en los elementos
            for i = 1:numeroElementos
                
                % Se obienen los gdl del elemento metodo indicial
                gdl = objetos{i}.obtenerGDLID();
                ngdl = objetos{i}.obtenerNumeroGDL();
                
                % Se obtiene la matriz de masa
                m_elem = objetos{i}.obtenerVectorMasa();
                
                % Se calcula el metodo indicial
                for r = 1:ngdl
                    for s = 1:ngdl
                        i_ = gdl(r);
                        j_ = gdl(s);
                        
                        % Si corresponden a grados de libertad -> puntos en (i,j)
                        % se suma contribucion metodo indicial
                        if (i_ ~= 0 && j_ ~= 0 && r == s)
                            obj.Mt(i_, j_) = obj.Mt(i_, j_) + m_elem(r);
                        end
                        
                    end % for s
                end % for r
                
            end % for i
            
            % Masa de los elementos
            mElementos = sum(diag(obj.Mt)) / 2;
            
            % Agrega las cargas
            fprintf('\t\tAgrega masa de cargas\n');
            pat = obj.modeloObj.obtenerPatronesDeCargas();
            for i = 1:length(pat)
                
                cargas = pat{i}.obtenerCargas();
                for j = 1:length(cargas)
                    
                    % Si la carga ya sumo masa se bloquea
                    if ~cargas{j}.cargaSumaMasa()
                        continue;
                    end
                    
                    nodoCarga = cargas{j}.obtenerNodos();
                    m = cargas{j}.obtenerMasa();
                    
                    % Recorre los nodos
                    for k = 1:length(nodoCarga)
                        
                        n = nodoCarga{i}.obtenerGDLID();
                        obj.Mt(n(1), n(1)) = obj.Mt(n(1), n(1)) + 0.5 * m;
                        obj.Mt(n(2), n(2)) = obj.Mt(n(2), n(2)) + 0.5 * m;
                        if length(n) == 3
                            obj.Mt(n(3), n(3)) = obj.Mt(n(3), n(3)) + 1e-6;
                        end
                        % u(3) no se agrega dado que es el giro
                        
                    end % for k
                    
                    % Bloquea la suma de masa de esta carga
                    cargas{j}.bloquearCargaMasa();
                    
                end % for j
                
            end % for i
            
            % Masa total
            mTotal = sum(diag(obj.Mt)) / 2;
            
            % Masa de las cargas
            mCargas = mTotal - mElementos;
            
            % Despliega informacion
            fprintf('\tDistribucion de masa\n');
            fprintf('\t\tMasa de elementos: %.1f (%.2f%%)\n', mElementos, ...
                mElementos/mTotal*100);
            fprintf('\t\tMasa de cargas: %.1f (%.2f%%)\n', mCargas, ...
                mCargas/mTotal*100);
            fprintf('\t\tMasa total: %.1f\n', mTotal);
            
        end % ensamblarMatrizMasa function
        
        function Cdv = ensamblarMatrizAmortiguamientoDisipadores(obj)
            % ensamblarMatrizRigidez: es un metodo de la clase ModalEspectral
            % que se usa para realizar el armado de la matriz de
            % amortiguamiento de los disipadores del modelo
            %
            % Ensambla la matriz de rigidez del modelo analizado usando el metodo
            % indicial
            
            % fprintf('\tEnsamblando matriz de amortiguamiento disipadores\n');
            ndglc = obj.numeroGDL - obj.gdlCond; % Numero de grados de libertad condensados
            Cdv = zeros(ndglc, ndglc);
            
            % Extraemos los Elementos
            disipadorObjetos = obj.modeloObj.obtenerDisipadores();
            numeroDisipadores = length(disipadorObjetos);
            
            % Definimos los GDLID en los elementos
            for i = 1:numeroDisipadores
                
                % Se obienen los gdl del elemento metodo indicial
                gdl = disipadorObjetos{i}.obtenerGDLIDCondensado();
                ngdl = disipadorObjetos{i}.obtenerNumeroGDL();
                
                % Se obtiene la matriz de amortiguamiento global del elemento-i
                c_globl_elem = disipadorObjetos{i}.obtenerMatrizAmortiguamientoCoordGlobal();
                
                % Se calcula el metodo indicial
                for r = 1:ngdl
                    for s = 1:ngdl
                        i_ = gdl(r);
                        j_ = gdl(s);
                        
                        % Si corresponden a grados de libertad -> puntos en (i,j)
                        % se suma contribucion metodo indicial
                        if (i_ ~= 0 && j_ ~= 0)
                            Cdv(i_, j_) = Cdv(i_, j_) + c_globl_elem(r, s);
                        end
                        
                    end % for s
                end % for r
                
            end % for i
            
        end % ensamblarMatrizAmortiguamientoDisipadores function
        
        function Kdv = ensamblarMatrizRigidezDisipadores(obj)
            % ensamblarMatrizRigidezDisipadores: es un metodo de la clase
            % ModalEspectral que se usa para realizar el armado de la matriz
            % de rigidez del modelo analizado
            %
            % Ensambla la matriz de rigidez de los disipadores del modelo
            % analizado usando el metodo indicial
            
            % fprintf('\tEnsamblando matriz de rigidez disipadores\n');
            ndglc = obj.numeroGDL - obj.gdlCond; % Numero de grados de libertad condensados
            Kdv = zeros(ndglc, ndglc);
            
            % Extraemos los elementos
            disipadorObj = obj.modeloObj.obtenerDisipadores();
            numeroDisipadores = length(disipadorObj);
            
            % Definimos los GDLID en los elementos
            for i = 1:numeroDisipadores
                
                % Se obienen los gdl del elemento metodo indicial
                gdl = disipadorObj{i}.obtenerGDLIDCondensado();
                ngdl = disipadorObj{i}.obtenerNumeroGDL();
                
                % Se obtiene la matriz de amortiguamiento global del elemento-i
                k_globl_elem = disipadorObj{i}.obtenerMatrizRigidezCoordGlobal();
                
                % Se calcula el metodo indicial
                for r = 1:ngdl
                    for s = 1:ngdl
                        i_ = gdl(r);
                        j_ = gdl(s);
                        
                        % Si corresponden a grados de libertad -> puntos en (i,j)
                        % se suma contribucion metodo indicial
                        if (i_ ~= 0 && j_ ~= 0)
                            Kdv(i_, j_) = Kdv(i_, j_) + k_globl_elem(r, s);
                        end
                        
                    end % for s
                end % for r
                
            end % for i
            
        end % ensamblarMatrizAmortiguamientoDisipadores function
        
        function ensamblarVectorFuerzas(obj)
            % ensamblarVectorFuerzas: es un metodo de la clase ModalEspectral que se usa para
            % realizar el armado del vector de fuerzas del modelo analizado
            %
            % Ensambla el vector de fuerzas del modelo analizado usando el metodo
            % indicial
            
            obj.F = zeros(obj.numeroGDL, 1);
            
            % En esta funcion se tiene que ensamblar el vector de fuerzas
            % Extraemos los nodos
            nodoObjetos = obj.modeloObj.obtenerNodos();
            numeroNodos = length(nodoObjetos);
            
            % Definimos los GDLID en los nodos
            for i = 1:numeroNodos
                
                ngdlid = nodoObjetos{i}.obtenerNumeroGDL(); % Numero grados de libertad del nodo
                gdl = nodoObjetos{i}.obtenerGDLID(); % Grados de libertad del nodo
                reacc = nodoObjetos{i}.obtenerReacciones(); % Reacciones del nodo
                
                % Recorre cada grado de libertad, si no es cero entonces
                % hay una carga aplicada en ese grado de libertad para
                % lograr el equilibrio
                for j = 1:ngdlid
                    if (gdl(j) ~= 0)
                        obj.F(gdl(j)) = -reacc(j);
                    end
                end % for j
                
            end % for i
            
        end % ensamblarVectorFuerzas function
        
        function plotAnimado(obj, deformada, modo, factor, phif, limx, limy, limz, ...
                per, cuadro, totCuadros, defElem, defCarga, carga, tcarga, tcargaEq, ...
                mostrarEstatico, mostrarDisipadores, styleNodoE, sizeNodoE, ...
                styleNodoD, sizeNodoD, styleElemE, lwElemE, styleElemD, lwElemD, ...
                styleDisipador, colorDisipador, lwDisipador, unidad, ...
                angAzh, angPol)
            % plotAnimado: Anima el grafico en funcion del numero del modo
            
            % Si se grafica la carga no se aplica el factor sin(wt)
            if defCarga
                phif = 1;
            end
            
            % Carga objetos
            nodoObjetos = obj.modeloObj.obtenerNodos();
            numeroNodos = length(nodoObjetos);
            
            % Obtiene cuantos GDL tiene el modelo
            gdl = 2;
            ngdl = obj.modeloObj.obtenerNumeroDimensiones();
            j = 1;
            for i = 1:numeroNodos
                coords = nodoObjetos{i}.obtenerCoordenadas();
                ngdlid = length(coords);
                gdl = max(gdl, ngdlid);
                if ~deformada && mostrarEstatico
                    if modo ~= 0 || defCarga
                        nodoObjetos{i}.plot([], styleNodoE, sizeNodoE);
                    else
                        nodoObjetos{i}.plot([], styleNodoD, sizeNodoD);
                    end
                    if j == 1
                        hold on;
                    end
                    j = j + 1;
                end
            end % for i
            
            % Grafica los elementos
            objetos = obj.modeloObj.obtenerElementos();
            numeroElementos = length(objetos);
            for i = 1:numeroElementos
                
                % Se obienen los gdl del elemento metodo indicial
                nodoElemento = objetos{i}.obtenerNodos();
                numNodo = length(nodoElemento);
                
                if (~deformada || obj.mostrarDeformada) && mostrarEstatico
                    if modo ~= 0 || defCarga
                        objetos{i}.plot({}, styleElemE, lwElemE, false);
                    else
                        objetos{i}.plot({}, styleElemD, lwElemD, false);
                    end
                end
                
                if deformada
                    def = cell(numNodo, 1);
                    for j = 1:numNodo
                        def{j} = factor * phif * obj.obtenerDeformadaNodo(nodoElemento{j}, ...
                            modo, obj.numDGReal, defCarga, carga, tcarga);
                    end % for j
                    objetos{i}.plot(def, styleElemD, lwElemD, defElem);
                    if i == 1
                        hold on;
                    end
                end
                
            end % for i
            
            % Grafica los nodos deformados
            if deformada
                for i = 1:numeroNodos
                    coords = nodoObjetos{i}.obtenerCoordenadas();
                    ngdlid = length(coords);
                    gdl = max(gdl, ngdlid);
                    def = obj.obtenerDeformadaNodo(nodoObjetos{i}, modo, ...
                        gdl, defCarga, carga, tcarga);
                    nodoObjetos{i}.plot(def.*factor*phif, styleNodoD, sizeNodoD);
                end % for i
            end
            
            % Grafica los disipadores
            if mostrarDisipadores
                disipadores = obj.modeloObj.obtenerDisipadores();
                for i = 1:length(disipadores)
                    nodoDisipador = disipadores{i}.obtenerNodos();
                    numnodoDisipador = disipadores{i}.obtenerNumeroNodos();
                    def = cell(numnodoDisipador, 1);
                    for j = 1:numnodoDisipador
                        def{j} = factor * phif * obj.obtenerDeformadaNodo(nodoDisipador{j}, ...
                            modo, obj.numDGReal, defCarga, carga, tcarga);
                    end % for j
                    disipadores{i}.plot(def, styleDisipador, lwDisipador, colorDisipador);
                end % for i
            end
            
            % Setea el titulo
            if ~defCarga % Se grafica los modos
                if ~deformada
                    title('Analisis modal espectral');
                else
                    a = sprintf('Analisis modal espectral - Modo %d (T: %.3fs)', modo, per);
                    if totCuadros > 1
                        b = sprintf('Escala deformacion x%d - Cuadro %s/%d', ...
                            factor, padFillNum(cuadro, totCuadros), totCuadros);
                    else
                        b = sprintf('Escala deformacion x%d', factor);
                    end
                    title({a; b});
                end
            else % Grafica una carga
                a = sprintf('Analisis modal espectral - Carga %s', carga.obtenerEtiqueta());
                b = sprintf('Escala deformacion x%d - Cuadro %s/%d - t:%.3fs', ...
                    factor, padFillNum(cuadro, totCuadros), totCuadros, tcargaEq(cuadro));
                title({a; b});
            end
            grid on;
            
            % Limita en los ejes
            if deformada || modo == 0
                if limx(1) < limx(2)
                    xlim(limx);
                end
                if limy(1) < limy(2)
                    ylim(limy);
                end
                if gdl == 3 && limz(1) < limz(2)
                    zlim(limz);
                end
            end
            
            if ngdl == 2
                xlabel(sprintf('X (%s)', unidad));
                ylabel(sprintf('Y (%s)', unidad));
            else
                xlabel(sprintf('X (%s)', unidad));
                ylabel(sprintf('Y (%s)', unidad));
                zlabel(sprintf('Z (%s)', unidad));
                view(angAzh, angPol);
            end
            
        end % plotAnimado function
        
        function [limx, limy, limz] = obtenerLimitesDeformada(obj, modo, factor, defcarga, carga)
            % obtenerLimitesDeformada: Obtiene los limites de deformacion
            
            fprintf('\tCalculando los limites del grafico\n');
            factor = 2.5 * factor;
            limx = [inf, -inf];
            limy = [inf, -inf];
            limz = [inf, -inf];
            
            % Carga objetos
            nodoObjetos = obj.modeloObj.obtenerNodos();
            numeroNodos = length(nodoObjetos);
            gdl = 2;
            for i = 1:numeroNodos
                coords = nodoObjetos{i}.obtenerCoordenadas();
                ngdlid = length(coords);
                gdl = max(gdl, ngdlid);
            end % for i
            
            objetos = obj.modeloObj.obtenerElementos();
            numeroElementos = length(objetos);
            for i = 1:numeroElementos
                nodoElemento = objetos{i}.obtenerNodos();
                numNodo = length(nodoElemento);
                for j = 1:numNodo
                    coord = nodoElemento{j}.obtenerCoordenadas();
                    if (obj.analisisFinalizado && modo > 0) || defcarga
                        def = obj.obtenerDeformadaNodo(nodoElemento{j}, modo, gdl, defcarga, carga, -1);
                        coordi = coord + def .* factor;
                    else
                        coordi = coord;
                    end
                    limx(1) = min(limx(1), coordi(1));
                    limy(1) = min(limy(1), coordi(2));
                    limx(2) = max(limx(2), coordi(1));
                    limy(2) = max(limy(2), coordi(2));
                    if gdl == 3
                        limz(1) = min(limz(1), coordi(3));
                        limz(2) = max(limz(2), coordi(3));
                    end
                    if (obj.analisisFinalizado && modo > 0) || defcarga
                        coordf = coord - def .* factor;
                    else
                        coordf = coord;
                    end
                    limx(1) = min(limx(1), coordf(1));
                    limy(1) = min(limy(1), coordf(2));
                    limx(2) = max(limx(2), coordf(1));
                    limy(2) = max(limy(2), coordf(2));
                    if gdl == 3
                        limz(1) = min(limz(1), coordf(3));
                        limz(2) = max(limz(2), coordf(3));
                    end
                end % for j
            end % for i
            
        end % obtenerLimitesDeformada function
        
        function def = obtenerDeformadaNodo(obj, nodo, modo, gdl, defcarga, carga, tcarga)
            % obtenerDeformadaNodo: Obtiene la deformada de un nodo
            
            ngdl = nodo.obtenerGDLIDCondensado();
            def = zeros(gdl, 1);
            gdl = min(gdl, length(ngdl));
            for i = 1:gdl
                if ngdl(i) > 0
                    if ~defcarga % La deformada la saca a partir del modo
                        if modo > 0
                            def(i) = obj.phin(ngdl(i), modo);
                        else
                            def(i) = 0;
                        end
                    else
                        def(i) = carga.obtenerDesplazamientoTiempo(ngdl(i), tcarga);
                    end
                else
                    def(i) = 0;
                end
            end % for i
            
        end % obtenerDeformadaNodo function
        
        function [Cortante, Momento, CBplot, MBplot, hplot] = calcularMomentoCorteBasalAcel(obj, acel)
            % calcularMomentoCorteBasalAcel: Calcula el momento y corte
            % basal en funcion de una aceleracion
            %
            % Se genera vector en que las filas contienen nodos en un mismo piso,
            % rellenando con ceros la matriz en caso de diferencia de nodos por piso.
            % Tambien se genera vector que contiene alturas de piso
            
            % Iniciando el proceso
            nodos = obj.modeloObj.obtenerNodos();
            nnodos = length(nodos);
            
            habs = zeros(1, 1);
            hNodos = zeros(1, 1);
            j = 1;
            k = 1;
            ini = 1;
            for i = 1:nnodos
                CoordNodo = nodos{i}.obtenerCoordenadas;
                yNodo = CoordNodo(2);
                if yNodo ~= habs(j)
                    k = 1;
                    j = j + 1;
                    habs(j, 1) = yNodo;
                    hNodos(j, k) = i;
                elseif i == 1
                    hNodos(j, k) = i;
                else
                    k = k + 1;
                    hNodos(j, k) = i;
                end
                if yNodo == 0
                    ini = ini + 1;
                end
            end % for i
            
            [~, s] = size(acel);
            M = obj.obtenerMatrizMasa();
            m = zeros(nnodos-ini+1, 1);
            acelx = zeros(nnodos-ini+1, s);
            Fnodos = zeros(nnodos-ini+1, s);
            Fpisos = zeros(length(habs)-1, s);
            
            % Calculo de fuerzas inerciales nodales que generan corte, fuerzas nodales
            % y fuerzas por piso
            for i = ini:nnodos
                gdls = nodos{i}.obtenerGDLIDCondensado();
                gdlx = gdls(1);
                acelx(i-ini+1, :) = acel(gdlx, :);
                m(i-ini+1, 1) = M(gdlx, gdlx);
                Fnodos(i-ini+1, :) = M(gdlx, gdlx) .* acel(gdlx, :);
                [fil, ~] = find(hNodos == i);
                Fpisos(fil-1, :) = Fpisos(fil-1, :) + Fnodos(i-ini+1, :);
            end % for i
            
            % Calculo de cortante y momento acumulado por piso
            Fpisos_ud = flipud(Fpisos);
            habs_ud = flipud(habs);
            Cortante = zeros(length(habs)-1, s);
            Momento = zeros(length(habs)-1, s);
            for i = 1:length(habs) - 1
                hcero = habs_ud(i+1);
                for j = 1:i
                    Cortante(i, :) = Cortante(i, :) + Fpisos_ud(j, :);
                    Momento(i, :) = Momento(i, :) + Fpisos_ud(j, :) .* (habs_ud(j) - hcero);
                end % for j
            end % for i
            
            % Determinacion de envolvente maxima de cortante y momento basal
            icor = 1;
            imom = 1;
            CorB_max = 1;
            MomB_max = 1;
            [nfil, ~] = size(Cortante);
            for i = 1:s
                if abs(Cortante(nfil, i)) > abs(CorB_max)
                    icor = i;
                    CorB_max = Cortante(nfil, i);
                end
                if abs(Momento(nfil, i)) > abs(MomB_max)
                    imom = i;
                    MomB_max = Momento(nfil, i);
                end
            end % for i
            
            % Calcula las envolventes, aplica valor absoluto
            VecCB = abs(Cortante(:, icor));
            VecMB = abs(Momento(:, imom));
            hgen = habs_ud;
            hplot = zeros(2*length(hgen), 1);
            CBplot = zeros(2*length(hgen)-1, 1);
            MBplot = zeros(2*length(hgen)-1, 1);
            aux1 = 1;
            aux2 = 2;
            for i = 1:length(hgen)
                hplot(aux1, 1) = hgen(i);
                hplot(aux1+1, 1) = hgen(i);
                if aux2 <= 2 * length(hgen) - 1
                    CBplot(aux2, 1) = VecCB(i);
                    CBplot(aux2+1, 1) = VecCB(i);
                    MBplot(aux2, 1) = VecMB(i);
                    MBplot(aux2+1, 1) = VecMB(i);
                end
                aux1 = aux1 + 2;
                aux2 = aux2 + 2;
            end % for i
            hplot(length(hplot)) = [];
            
        end % calcularMomentoCorteBasalAcel function
        
        function ctitle = imprimirPropiedadesAnalisisCarga(obj, carga) %#ok<INUSL>
            % imprimirPropiedadesAnalisisCarga: Imprime propiedades de
            % analisis de la carga o combinacion de cargas
            
            ctitle = 'Carga';
            if isa(carga, 'CombinacionCargas')
                ctitle = 'Combinacion';
            end
            fprintf('\t%s %s\n', ctitle, carga.obtenerEtiqueta());
            
            if carga.usoAmortiguamientoRayleigh()
                fprintf('\t\tLa %s se calculo con amortiguamiento Rayleigh\n', lower(ctitle));
            else
                fprintf('\t\tLa %s se calculo con amortiguamiento de Wilson-Penzien\n', lower(ctitle));
            end
            
            if carga.usoDescomposicionModal()
                fprintf('\t\tLa %s se calculo usando descomposicion modal\n', lower(ctitle));
            else
                fprintf('\t\tLa %s se calculo sin usar descomposicion modal\n', lower(ctitle));
            end
            
        end % imprimirPropiedadesAnalisisCarga function
        
    end % methods(private) ModalEspectral
    
end % class ModalEspectral