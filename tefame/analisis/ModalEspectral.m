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
%       modeloObj
%       numeroGDL
%       Kt
%       F
%       u
%       wn
%       Tn
%       phin
%       Mm
%       Km
%       r
%       Lm
%       Mmeff
%       Mmeffacum
%       Mmeffacump
%  Methods:
%       analisisObj = ModalEspectral(modeloObjeto)
%       definirNumeracionGDL(analisisObj)
%       analizar(analisisObj)
%       numeroEcuaciones = obtenerNumeroEcuaciones(analisisObj)
%       M_Modelo = obtenerMatrizMasa(analisisObj)
%       C_Modelo = obtenerMatrizAmortiguamiento(analisisObj,rayleigh)
%       K_Modelo = obtenerMatrizRigidez(analisisObj)
%       r_Modelo = obtenerVectorInfluencia(analisisObj)
%       F_Modelo = obtenerVectorFuerzas(analisisObj)
%       u_Modelo = obtenerDesplazamientos(analisisObj)
%       activarPlotDeformadaInicial(analisisObj)
%       desactivarPlotDeformadaInicial(analisisObj)
%       activarCargaAnimacion(analisisObj)
%       desactivarCargaAnimacion(analisisObj)
%       calcularMomentoCorteBasal(analisisObj,carga)
%       plotTrayectoriaNodo(analisisObj,carga,nodo,direccion)
%       plot(analisisObj,varargin)
%       disp(analisisObj)

classdef ModalEspectral < handle
    
    properties(Access = private)
        modeloObj % Guarda el objeto que contiene el modelo
        numeroGDL % Guarda el numero de grados de libertad totales del modelo
        Kt % Matriz de Rigidez del modelo
        Mt % Matriz de Masa del modelo
        gdlCond % Grados de libertad condensados
        F % Vector de Fuerzas aplicadas sobre el modelo
        u % Vector con los desplazamientos de los grados de libertad del modelo
        wn % Frecuencias del sistema
        Tn % Periodos del sistema
        phin % Vectores propios del sistema
        phinExt % Vector propio del sistema extendido considerando grados condensados
        condMatT % Matriz de condensacion T
        condMatRot % Matriz de condensacion rotacion
        Mteq % Matriz masa equivalente
        Kteq % Matriz rigidez equivalente
        Mm % Matriz masa modal
        Km % Matriz rigidez modal
        rm % Vector influencia
        Lm % Factor de participacion modal
        Mmeff % Masa modal efectiva
        Mmeffacum % Masa modal efectiva acumulada
        Mtotal % Masa total del modelo
        analisisFinalizado % Indica que el analisis ha sido realizado
        numModos % Numero de modos del analisis
        numDG % Numero de ejes de analisis despues de condensar
        numDGReal % Numero de ejes de analisis antes de condensar
        cRayleigh % Matriz de amortiguamiento de Rayleigh
        cPenzien % Matriz de amortiguamiento de Wilson-Penzien
        mostrarDeformada % Muestra la posicion no deformada en los graficos
        cargarAnimacion % Carga la animacion del grafico una vez renderizado
    end % properties ModalEspectral
    
    methods(Access = public)
        
        function analisisObj = ModalEspectral(modeloObjeto)
            % ModalEspectral: es el constructor de la clase ModalEspectral
            %
            % analisisObj = ModalEspectral(modeloObjeto)
            % Crea un objeto de la clase ModalEspectral, y guarda el modelo,
            % que necesita ser analizado
            
            if nargin == 0
                modeloObjeto = [];
            end % if
            
            analisisObj.modeloObj = modeloObjeto;
            analisisObj.numeroGDL = 0;
            analisisObj.Kt = [];
            analisisObj.Mt = [];
            analisisObj.u = [];
            analisisObj.F = [];
            analisisObj.analisisFinalizado = false;
            analisisObj.mostrarDeformada = false;
            analisisObj.cargarAnimacion = true;
            
        end % ModalEspectral constructor
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Metodos para definir y analizar el modelo
        
        function definirNumeracionGDL(analisisObj)
            % definirNumeracionGDL: es un metodo de la clase ModalEspectral que
            % se usa para definir como se enumeran los GDL en el modelo
            %
            % definirNumeracionGDL(analisisObj)
            % Define y asigna la enumeracion de los GDL en el modelo
            
            fprintf('\tDefiniendo numeracion GDL\n');
            
            % Primero se aplican las restricciones al modelo
            analisisObj.modeloObj.aplicarRestricciones();
            
            % Extraemos los nodos para que sean enumerados
            nodoObjetos = analisisObj.modeloObj.obtenerNodos();
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
            analisisObj.numeroGDL = contadorGDL;
            
            % Extraemos los Elementos del modelo
            elementoObjetos = analisisObj.modeloObj.obtenerElementos();
            numeroElementos = length(elementoObjetos);
            
            % Definimos los GDLID en los elementos para poder formar la matriz de rigidez
            for i = 1:numeroElementos
                elementoObjetos{i}.definirGDLID();
            end % for i
            
        end % definirNumeracionGDL function
        
        function analizar(analisisObj, nModos, betacR, betacP, maxcond)
            % analizar: es un metodo de la clase ModalEspectral que se usa para
            % realizar el analisis estatico
            %
            % analizar(analisisObj,nModos,betacR,betacP,maxcond)
            % Analiza estaticamente el modelo lineal y elastico sometido a un
            % set de cargas, requiere el numero de modos para realizar el
            % analisis y de los modos conocidos con sus beta
            
            % Ajusta variables de entrada
            if ~exist('nModos', 'var')
                nModos = 20;
            end
            if ~exist('maxcond', 'var')
                maxcond = 0.001;
            end
            fprintf('Ejecuntando analisis modal espectral:\n\tNumero de modos: %d\n', nModos);
            
            % Se definen los grados de libertad por nodo -> elementos
            analisisObj.definirNumeracionGDL();
            
            % Se aplica patron de carga
            analisisObj.modeloObj.aplicarPatronesDeCargasEstatico();
            
            % Se calcula la matriz de rigidez
            analisisObj.ensamblarMatrizRigidez();
            
            % Se calcula la matriz de masa
            analisisObj.ensamblarMatrizMasa();
            
            % Guarda el resultado para las cargas estaticas
            fprintf('\tCalculando resultado carga estatica\n');
            analisisObj.ensamblarVectorFuerzas();
            analisisObj.u = (analisisObj.Kt^-1) * analisisObj.F;
            analisisObj.modeloObj.actualizar(analisisObj.u);
            
            % Calcula el metodo modal espectral
            analisisObj.calcularModalEspectral(nModos, betacR, betacP, maxcond); % M,C,K
            
        end % analizar function
        
        function resolverCargasDinamicas(analisisObj, cpenzien)
            % resolverCargasDinamicas: Resuelve las cargas dinamicas del
            % sistema
            %
            % resolverCargasDinamicas(analisisObj,cpenzien)
            %
            % Por defecto se usa el amortiguamiento de Rayleigh
            
            if ~analisisObj.analisisFinalizado
                error('No se puede resolver las cargas dinamicas sin haber analizado la estructura');
            end
            
            if ~exist('cpenzien', 'var')
                cpenzien = false;
            end
            
            fprintf('Metodo modal espectral:\n');
            analisisObj.modeloObj.aplicarPatronesDeCargasDinamico(cpenzien);
            
        end % resolverCargasDinamicas function
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Metodos para obtener la informacion del analisis
        
        function numeroEcuaciones = obtenerNumeroEcuaciones(analisisObj)
            % obtenerNumeroEcuaciones: es un metodo de la clase ModalEspectral
            % que se usa para obtener el numero total de GDL, es decir, ecuaciones
            % del modelo
            %
            % numeroEcuaciones = obtenerNumeroEcuaciones(analisisObj)
            % Obtiene el numero total de GDL (numeroEcuaciones) que esta guardado
            % en el Analisis (analisisObj)
            
            numeroEcuaciones = analisisObj.numeroGDL;
            
        end % obtenerNumeroEcuaciones function
        
        function M_Modelo = obtenerMatrizMasa(analisisObj)
            % obtenerMatrizMasa: es un metodo de la clase ModalEspectral
            % que se usa para obtener la matriz de masa del modelo
            %
            % M_Modelo = obtenerMatrizRigidez(analisisObj)
            % Obtiene la matriz de masa (M_Modelo) del modelo que se genero
            % en el Analisis (analisisObj)
            
            M_Modelo = analisisObj.Mteq;
            
        end % obtenerMatrizMasa function
        
        function C_Modelo = obtenerMatrizAmortiguamiento(analisisObj, rayleigh)
            % obtenerMatrizAmortiguamiento: es un metodo de la clase ModalEspectral
            % que se usa para obtener la matriz de amortiguamiento del modelo
            %
            % C_Modelo = obtenerMatrizAmortiguamiento(analisisObj, rayleigh)
            % Obtiene la matriz de amortiguamiento (C_Modelo) del modelo que se genero
            % en el Analisis (analisisObj)
            
            if rayleigh
                C_Modelo = analisisObj.cRayleigh;
            else
                C_Modelo = analisisObj.cPenzien;
            end
            
        end % obtenerMatrizAmortiguamiento function
        
        function K_Modelo = obtenerMatrizRigidez(analisisObj)
            % obtenerMatrizRigidez: es un metodo de la clase ModalEspectral
            % que se usa para obtener la matriz de rigidez del modelo
            %
            % K_Modelo = obtenerMatrizRigidez(analisisObj)
            % Obtiene la matriz de rigidez (K_Modelo) del modelo que se genero
            % en el Analisis (analisisObj)
            
            K_Modelo = analisisObj.Kteq;
            
        end % obtenerMatrizRigidez function
        
        function r_Modelo = obtenerVectorInfluencia(analisisObj)
            % obtenerVectorInfluencia: es un metodo de la clase ModalEspectral
            % que se usa para obtener el vector de influencia del modelo
            %
            % r_Modelo = obtenerVectorInfluencia(analisisObj)
            % Obtiene el vector de influencia (r) del modelo que se genero
            % en el Analisis (analisisObj)
            
            r_Modelo = analisisObj.rm;
            
        end % obtenerMatrizMasa function
        
        function F_Modelo = obtenerVectorFuerzas(analisisObj)
            % obtenerMatrizRigidez: es un metodo de la clase ModalEspectral
            % que se usa para obtener el vector de fuerza del modelo
            %
            % F_Modelo = obtenerVectorFuerzas(analisisObj)
            % Obtiene el vector de fuerza (F_Modelo) del modelo que se genero
            % en el Analisis (analisisObj)
            
            F_Modelo = analisisObj.F;
            
        end % obtenerVectorFuerzas function
        
        function u_Modelo = obtenerDesplazamientos(analisisObj)
            % obtenerDesplazamientos: es un metodo de la clase ModalEspectral
            % que se usa para obtener el vector de desplazamiento del modelo
            % obtenido del analisis
            %
            % u_Modelo = obtenerDesplazamientos(analisisObj)
            % Obtiene el vector de desplazamiento (u_Modelo) del modelo que se
            % genero como resultado del Analisis (analisisObj)
            
            u_Modelo = analisisObj.u;
            
        end % obtenerDesplazamientos function
        
        function wn_Modelo = obtenerValoresPropios(analisisObj)
            % obtenerValoresPropios: es un metodo de la clase ModalEspectral
            % que se usa para obtener los valores propios del modelo
            % obtenido del analisis
            %
            % w_Modelo = obtenerValoresPropios(analisisObj)
            % Obtiene los valores propios (wn_Modelo) del modelo que se
            % genero como resultado del Analisis (analisisObj)
            
            wn_Modelo = analisisObj.wn;
            
        end % obtenerDesplazamientos function
        
        function plt = plot(analisisObj, varargin)
            % plot: Grafica un modelo
            %
            % plt = plot(analisisObj,'var1',val1,'var2',val2)
            %
            % Parametros opcionales:
            %   modo        Numero de modo a graficar
            %   factor      Escala de la deformacion
            %   numcuadros  Numero de cuadros de la animacion
            %   gif         Archivo en el que se guarda la animacion
            %   defelem     Dibuja la deformada de cada elemento
            
            % Establece variables iniciales
            fprintf('Generando animacion analisis modal espectral:\n');
            p = inputParser;
            p.KeepUnmatched = true;
            addOptional(p, 'modo', 0);
            addOptional(p, 'factor', 10);
            addOptional(p, 'cuadros', 0);
            addOptional(p, 'gif', '');
            addOptional(p, 'defelem', true);
            addOptional(p, 'carga', false);
            addOptional(p, 'tmin', 0);
            addOptional(p, 'tmax', -1);
            parse(p, varargin{:})
            r = p.Results;
            modo = floor(r.modo);
            factor = r.factor;
            numCuadros = floor(r.cuadros);
            guardaGif = r.gif;
            defElem = r.defelem;
            carga = r.carga;
            defCarga = false; % Indica que la deformada se obtiene a partir de la carga
            tmin = max(0, r.tmin);
            tmax = r.tmax;
            tinicial = cputime;
            
            % Verificaciones si se grafica una carga
            if carga ~= false
                
                if ~isa(carga, 'CargaDinamica')
                    error('Solo se pueden graficar cargas dinamicas');
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
                end
                
                % Activa la deformada por carga
                defCarga = true;
                fprintf('\tSe graficara la carga %s desde ti=%.2f a tf=%.2f con dt=%.2f\n', ...
                    carga.obtenerEtiqueta(), tmin, tmax, (tmax - tmin)/numCuadros);
                
            else % No se grafican cargas
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
            if (~analisisObj.analisisFinalizado || modo <= 0) && ~defCarga
                plt = figure();
                movegui('center');
                hold on;
                grid on;
                [limx, limy, limz] = analisisObj.obtenerLimitesDeformada(0, factor, defCarga, carga);
                plotAnimado(analisisObj, false, 0, factor, 0, limx, limy, limz, 0, 1, 1, defElem, defCarga);
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
            
            if (modo > analisisObj.numModos || modo <= 0) && ~defCarga
                error('El modo a graficar %d excede la cantidad de modos del sistema (%d)', ...
                    modo, analisisObj.numModos);
            end
            
            % Obtiene el periodo
            if ~defCarga
                tn = analisisObj.Tn(modo);
            else
                tn = 0;
            end
            
            % Calcula los limites
            [limx, limy, limz] = analisisObj.obtenerLimitesDeformada(modo, factor, defCarga, carga);
            
            % Grafica la estructura
            plt = figure();
            fig_num = get(gcf, 'Number');
            movegui('center');
            hold on;
            grid on;
            % axis tight manual;
            % set(gca, 'nextplot', 'replacechildren');
            
            % Imprime mensajes en consola
            if ~defElem
                fprintf('\tSe ha desactivado la deformada de los elementos\n');
            end
            if guardarGif && numCuadros ~= 0
                fprintf('\tEl proceso generara un archivo gif\n');
            end
            
            % Grafica el sistema
            if numCuadros <= 0
                fprintf('\tSe grafica el caso con la deformacion maxima\n');
                plotAnimado(analisisObj, deformada, modo, factor, 1, ...
                    limx, limy, limz, tn, 1, 1, defElem, defCarga, carga, 1, tCargaEq);
                fprintf('\tProceso finalizado en %.2f segundos\n', cputime-tinicial);
            else
                plotAnimado(analisisObj, deformada, modo, factor, 0, ...
                    limx, limy, limz, tn, 1, 1, defElem, defCarga, carga, tCargaPos(1), tCargaEq);
                hold off;
                
                % Obtiene el numero de cuadros
                t = 0;
                dt = 2 * pi / numCuadros;
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
                        plotAnimado(analisisObj, deformada, modo, factor, sin(t), ...
                            limx, limy, limz, tn, i, numCuadros, defElem, defCarga, carga, tCargaPos(i), tCargaEq);
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
                    
                end % i = 1:numCuadros
                
                if guardarGif
                    fprintf('\n\tGuardando animacion gif en: %s', guardaGif);
                end
                
                % Imprime en consola el tiempo que se demoro el proceso
                fprintf('\tProceso finalizado en %.2f segundos\n', cputime-tinicial);
                
                % Reproduce la pelicula y cierra el grafico anterior
                close(fig_num);
                if analisisObj.cargarAnimacion
                    fprintf('\n\tAbriendo animacion\n');
                    try
                        gifPlayerGUI(guardaGif, 1/min(numCuadros, 60));
                    catch
                        error('Ha ocurrido un error al abrir el gif generado');
                    end
                else
                    fprintf('\n');
                end
                
            end
            
        end % plot function
        
        function calcularMomentoCorteBasal(analisisObj, carga)
            % calcularMomentoCorteBasal: Funcion que calcula el momento y
            % corte basal a partir de una carga. TODO: Combinaciones de
            % cargas
            %
            % calcularMomentoCorteBasal(analisisObj,carga)
            
            % Se genera vector en que las filas contienen nodos en un mismo piso,
            % rellenando con ceros la matriz en caso de diferencia de nodos por piso.
            % Tambien se genera vector que contiene alturas de piso
            nodos = analisisObj.modeloObj.obtenerNodos();
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
            end
            
            acel = carga.obtenerAceleracion();
            [~, s] = size(acel);
            M = analisisObj.obtenerMatrizMasa;
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
            end
            
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
                end
            end
            
            % Determinacion de envolvente maxima de cortante y momento basal
            icor = 0;
            imom = 0;
            CorB_max = 0;
            MomB_max = 0;
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
            end
            
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
            end
            hplot(length(hplot)) = [];
            
            %Graficos
            t = linspace(0, carga.tAnalisis, s); % Vector de tiempo
            
            plt = figure();
            movegui(plt, 'center');
            plot(t, Cortante(end, :), 'k-', 'LineWidth', 1);
            grid on;
            grid minor;
            xlabel('Tiempo (s)');
            ylabel('Corte (tonf)');
            title('Historial de Cortante Basal');
            
            plt = figure();
            movegui(plt, 'center');
            plot(t, Momento(end, :), 'k-', 'LineWidth', 1);
            grid on;
            grid minor;
            xlabel('Tiempo (s)');
            ylabel('Momento (tonf-m)');
            title('Historial de Momento Basal');
            
            plt = figure();
            movegui(plt, 'center');
            plot(CBplot, hplot, '*-', 'LineWidth', 1, 'Color', 'black');
            grid on;
            grid minor;
            xlabel('Corte (tonf)');
            ylabel('Altura (m)');
            title('Envolvente de Cortante Basal');
            
            plt = figure();
            movegui(plt, 'center');
            plot(MBplot, hplot, '*-', 'LineWidth', 1, 'Color', 'black');
            grid on;
            grid minor;
            xlabel('Momento (tonf-m)');
            ylabel('Altura (m)');
            title('Envolvente de Momento Basal');
            
        end % calcularMomentoCorteBasal function
        
        function plotTrayectoriaNodo(analisisObj, carga, nodo, direccion, tlim) %#ok<INUSL>
            % plotTrayectoriaNodo: Grafica la trayectoria de un nodo
            % (desplazamiento, velocidad y aceleracion) para todo el tiempo
            %
            % plotTrayectoriaNodo(analisisObj,carga,nodo,direccion, tlim)
            
            % Verifica que la direccion sea correcta
            if sum(direccion) ~= 1
                error('Direccion invalida');
            end
            if ~verificarVectorDireccion(direccion, nodo.obtenerNumeroGDL())
                error('Vector direccion mal definido');
            end
            
            % Obtiene resultados de la carga
            p_c = carga.obtenerCarga();
            u_c = carga.obtenerDesplazamiento();
            v_c = carga.obtenerVelocidad();
            a_c = carga.obtenerAceleracion();
            if isempty(u_c)
                error('La carga no se ha calculado');
            end
            
            % Elige al nodo
            [r, s] = size(a_c);
            ngd = nodo.obtenerGDLIDCondensado();
            ng = 0; % Numero grado analisis
            nd = 0; % Numero direccion analisis
            for i=1:length(direccion)
                if direccion(i) == 1
                    ng = ngd(i);
                    nd = i;
                end
            end
            if ng == 0
                error('No se ha obtenido el GDLID del nodo');
            end
            if ng > r
                error('El GDLID excede al soporte del sistema');
            end
            
            % Genera el vector de tiempo
            t = linspace(0, carga.tAnalisis, s); % Vector de tiempo
            if ~exist('tlim', 'var')
                tlim = [min(t), max(t)];
            else
                tlim = [max(min(tlim), min(t)), min(max(tlim), max(t))];
            end
            
            % Crea el grafico
            plt = figure();
            movegui(plt, 'center');
            
            subplot(4, 1, 1);
            plot(t, p_c(ng, :), 'k-', 'LineWidth', 1);
            ylabel('tonf (m)');
            xlabel('t (s)');
            xlim(tlim);
            grid on;
            title(sprintf('Carga %s - Nodo %s - GDLID condensado %d - Direccion %d', ...
                carga.obtenerEtiqueta(), nodo.obtenerEtiqueta(), ng, nd));
            
            subplot(4, 1, 2);
            plot(t, u_c(ng, :), 'k-', 'LineWidth', 1);
            title('Desplazamiento');
            ylabel('u (m)');
            xlabel('t (s)');
            xlim(tlim);
            grid on;
            
            subplot(4, 1, 3);
            plot(t, v_c(ng, :), 'k-', 'LineWidth', 1);
            title('Velocidad');
            ylabel('v (m/s)');
            xlabel('t (s)');
            xlim(tlim);
            grid on;
            
            subplot(4, 1, 4);
            plot(t, a_c(ng, :), 'k-', 'LineWidth', 1);
            title('Aceleracion');
            ylabel('a (m/s^s)');
            xlabel('t (s)');
            xlim(tlim);
            grid on;
            
        end % plotTrayectoriaNodo
        
        function activarCargaAnimacion(analisisObj)
            % activarCargaAnimacion: Carga la animacion  una vez calculada
            %
            % activarCargaAnimacion(analisisObj)
            
            analisisObj.cargarAnimacion = true;
            
        end % activarCargaAnimacion funcion
        
        function desactivarCargaAnimacion(analisisObj)
            % desactivarCargaAnimacion: Desactiva la animacion una vez calculada
            %
            % desactivarCargaAnimacion(analisisObj)
            
            analisisObj.cargarAnimacion = false;
            
        end % desactivarCargaAnimacion funcion
        
        function activarPlotDeformadaInicial(analisisObj)
            % activarPlotDeformadaInicial: Activa el grafico de la deformada inicial
            %
            % activarPlotDeformadaInicial(analisisObj)
            
            analisisObj.mostrarDeformada = true;
            
        end % activarPlotDeformadaInicial function
        
        function desactivarPlotDeformadaInicial(analisisObj)
            % desactivarPlotDeformadaInicial: Desactiva el grafico de la deformada inicial
            %
            % desactivarPlotDeformadaInicial(analisisObj)
            
            analisisObj.mostrarDeformada = false;
            
        end % desactivarPlotDeformadaInicial function
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Metodos para mostrar la informacion del Analisis Modal Espectral en pantalla
        
        function disp(analisisObj)
            % disp: es un metodo de la clase ModalEspectral que se usa para imprimir en
            % command Window la informacion del analisis espectral realizado
            %
            % disp(analisisObj)
            % Imprime la informacion guardada en el ModalEspectral (analisisObj) en
            % pantalla
            
            if ~analisisObj.analisisFinalizado
                fprintf('El analisis modal aun no ha sido calculado');
            end
            
            fprintf('Propiedades analisis modal espectral:\n');
            
            % Muestra los grados de libertad
            fprintf('\tNumero de grados de libertad: %d\n', ...
                analisisObj.numeroGDL-analisisObj.gdlCond);
            fprintf('\tNumero de grados condensados: %d\n', analisisObj.gdlCond);
            fprintf('\tNumero de direcciones por grado: %d\n', analisisObj.numDG);
            fprintf('\tNumero de modos en el analisis: %d\n', analisisObj.numModos);
            
            % Propiedades de las matrices
            detKt = det(analisisObj.Kt);
            detMt = det(analisisObj.Mt);
            if detKt ~= Inf
                fprintf('\tMatriz de rigidez:\n');
                fprintf('\t\tDeterminante: %f\n', detKt);
            end
            if abs(detMt) >= 1e-20
                fprintf('\tMatriz de Masa:\n');
                fprintf('\t\tDeterminante: %f\n', detMt);
            end
            fprintf('\tMasa total de la estructura: %.3f\n', analisisObj.Mtotal);
            
            fprintf('\tPeriodos y participacion modal:\n');
            if analisisObj.numDG == 2
                fprintf('\t\tN\t|\tT (s)\t|\tw (rad/s)\t|\tU1\t\t|\tU2\t\t|\tSum U1\t|\tSum U2\t|\n');
                fprintf('\t\t-----------------------------------------------------------------------------\n');
            elseif analisisObj.numDG == 3
                fprintf('\t\tN\t|\tT (s)\t|\tw (rad/s)\t|\tU1\t\t|\tU2\t\t|\tU3\t\t|\tSum U1\t|\tSum U2\t|\tSum U3\t|\n');
                fprintf('\t\t----------------------------------------------------------------------------------------------------\n');
            end
            
            for i = 1:analisisObj.numModos
                if analisisObj.numDG == 2
                    fprintf('\t\t%d\t|\t%.3f\t|\t%.3f\t|\t%.3f\t|\t%.3f\t|\t%.3f\t|\t%.3f\t|\t%.3f\n', i, analisisObj.Tn(i), ...
                        analisisObj.wn(i), analisisObj.Mmeff(i, 1), analisisObj.Mmeff(i, 2), ...
                        analisisObj.Mmeffacum(i, 1), analisisObj.Mmeffacum(i, 2));
                elseif analisisObj.numDG == 3
                    fprintf('\t\t%d\t|\t%.3f\t|\t%.3f\t|\t%.3f\t|\t%.3f\t|\t%.3f\t|\t%.3f\t|\t%.3f\t|\t%.3f\t|\t%.3f\n', i, analisisObj.Tn(i), ...
                        analisisObj.wn(i), analisisObj.Mmeff(i, 1), analisisObj.Mmeff(i, 2), analisisObj.Mmeff(i, 3), ...
                        analisisObj.Mmeffacum(i, 1), analisisObj.Mmeffacum(i, 2), analisisObj.Mmeffacum(i, 3));
                end
                fprintf('\n');
            end
            
            % Busca los periodos para los cuales se logra el 90%
            mt90p = zeros(analisisObj.numDG, 1);
            for i = 1:analisisObj.numDG
                fprintf('\t\tN periodo en U%d para el 90%% de la masa: ', i);
                for j = 1:analisisObj.numModos
                    if analisisObj.Mmeffacum(j, i) >= 0.90
                        mt90p(i) = j;
                        break;
                    end
                end
                if mt90p(i) > 0
                    fprintf('%d\n', mt90p(i));
                else
                    fprintf('INCREMENTAR NUMERO DE MODOS DE ANALISIS\n');
                end
            end
            
            fprintf('-------------------------------------------------\n');
            fprintf('\n');
            
        end % disp function
        
    end % methods(public) ModalEspectral
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Metodos privados
    
    methods(Access = private)
        
        function calcularModalEspectral(analisisObj, nModos, betacR, betacP, maxcond)
            % calcularModalEspectral: Calcula el metodo modal espectral
            %
            % calcularModalEspectral(analisisObj,nModos,betacR,betacP,maxcond)
            
            % Calcula tiempo inicio
            fprintf('\tCalculando metodo modal espectral\n');
            tInicio = cputime;
            
            % Obtiene matriz de masa
            diagMt = diag(analisisObj.Mt);
            analisisObj.Mtotal = sum(diagMt);
            
            % Obtiene los grados de libertad
            ngdl = length(analisisObj.Mt); % Numero de grados de libertad
            ndg = analisisObj.modeloObj.obtenerNumerosGDL(); % Grados de libertad por nodo
            
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
                end
            end
            
            % Si condensa grados
            analisisObj.gdlCond = length(vz);
            realizaCond = false;
            if analisisObj.gdlCond > 0
                
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
                    end
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
                end
                
                % Se realiza rotacion de matriz de rigidez
                Krot = rot' * analisisObj.Kt * rot;
                
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
                Mrot = rot' * analisisObj.Mt * rot;
                Meq = T' * Mrot * T;
                
                % Actualiza los grados
                cngdl = length(Meq);
                if cngdl < ngdl
                    fprintf('\t\tSe han condensado %d grados de libertad\n', ngdl-cngdl);
                    ngdl = cngdl;
                end
                
                % Actualiza los nodos
                nodos = analisisObj.modeloObj.obtenerNodos();
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
                        end
                    end
                    nodos{i}.definirGDLIDCondensado(gdlaux);
                end
                
            else % No condensa grados
                Meq = analisisObj.Mt;
                Keq = analisisObj.Kt;
                fprintf('\t\tNo se han condensado grados de libertad\n');
            end
            
            % Una vez pasado este punto no deberian haber masas nulas o
            % incorrectas
            for i = 1:ngdl
                if Meq(i, i) <= 0
                    error('La matriz de masa esta mal definida, M(%d,%d)<=0', i, i);
                end
            end
            
            fprintf('\t\tGrados de libertad totales: %d\n', ngdl);
            fprintf('\t\tNumero de direcciones de analisis: %d\n', ndg);
            nModos = min(nModos, ngdl);
            analisisObj.numModos = nModos;
            
            %--------------------------------------------------------------
            
            % Resuelve la ecuacion del sistema, para ello crea la matriz
            % inversa de la masa y calcula los valores propios
            invMt = zeros(ngdl, ngdl);
            for i = 1:ngdl
                invMt(i, i) = 1 / Meq(i, i);
            end
            sysMat = invMt * Keq;
            
            [modalPhin, syseig] = eigs(sysMat, nModos, 'smallestabs');
            syseig = diag(syseig);
            
            % Se recuperan los grados de libertad condensados y se
            % ordenan de acuerdo a la configuracion original
            if realizaCond
                modalPhinFull = T * modalPhin;
                rot_inv = rot^(-1);
                modalPhinFull = rot_inv' * modalPhinFull;
                analisisObj.condMatT = T;
                analisisObj.condMatRot = rot_inv;
            else
                modalPhinFull = modalPhin;
                analisisObj.condMatT = eye(length(modalPhin));
                analisisObj.condMatRot = eye(length(modalPhin));
            end
            
            % Calcula las frecuencias del sistema
            modalWn = sqrt(syseig);
            modalTn = (modalWn.^-1) .* 2 * pi; % Calcula los periodos
            
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
                end
                Torder(maxi) = Tpos;
                Tpos = Tpos + 1;
            end
            % ngdl = length(Meq); % Numero de grados de libertad
            
            % Asigna valores
            analisisObj.phinExt = modalPhinFull;
            analisisObj.Tn = zeros(nModos, 1);
            analisisObj.wn = zeros(nModos, 1);
            analisisObj.phin = zeros(ngdl, nModos);
            analisisObj.Mm = modalMm;
            analisisObj.Km = modalKm;
            analisisObj.Mteq = Meq;
            analisisObj.Kteq = Keq;
            for i = 1:nModos
                analisisObj.Tn(Torder(i)) = modalTn(i);
                analisisObj.wn(Torder(i)) = modalWn(i);
                analisisObj.phin(:, Torder(i)) = modalPhin(:, i);
            end
            
            % Crea vector influencia
            analisisObj.rm = zeros(ngdl, ndg);
            for j = 1:ndg
                for i = 1:ngdl
                    if mod(i, ndg) == j || (mod(i, ndg) == 0 && j == ndg)
                        analisisObj.rm(i, j) = 1;
                    end
                end
            end
            
            % Realiza el calculo de las participaciones modales
            analisisObj.Lm = zeros(nModos, ndg);
            analisisObj.Mmeff = zeros(ngdl, ndg);
            analisisObj.Mmeffacum = zeros(ngdl, ndg);
            Mtotr = zeros(ndg, 1);
            
            % Recorre cada grado de libertad (horizontal, vertical, giro)
            for j = 1:ndg
                Mtotr(j) = sum(Meq*analisisObj.rm(:, j));
                for k = 1:nModos
                    analisisObj.Lm(k, j) = analisisObj.phin(:, k)' * Meq * analisisObj.rm(:, j);
                    analisisObj.Mmeff(k, j) = analisisObj.Lm(k, j).^2 ./ modalMm(k, k);
                end
                
                analisisObj.Mmeff(:, j) = analisisObj.Mmeff(:, j) ./ Mtotr(j);
                analisisObj.Mmeffacum(1, j) = analisisObj.Mmeff(1, j);
                for i = 2:nModos
                    analisisObj.Mmeffacum(i, j) = analisisObj.Mmeffacum(i-1, j) + analisisObj.Mmeff(i, j);
                end
            end
            
            % -------- CALCULO DE AMORTIGUAMIENTO DE RAYLEIGH -------------
            
            % Se declaran dos amortiguamientos criticos asociados a dos modos
            % diferentes indicando si es horizontal o vertical (h o v)
            modocR = [1, 8];
            direcR = ['h', 'h'];
            countcR = [0, 0];
            m = 0;
            n = 0;
            for i = 1:length(analisisObj.Mmeff)
                if analisisObj.Mmeff(i, 1) > max(analisisObj.Mmeff(i, 2:ndg))
                    countcR(1) = countcR(1) + 1;
                    if direcR(1) == 'h' && modocR(1) == countcR(1)
                        m = i;
                    elseif direcR(2) == 'h' && modocR(2) == countcR(1)
                        n = i;
                    end
                elseif analisisObj.Mmeff(i, 2) > ...
                        max(analisisObj.Mmeff(i, 1), analisisObj.Mmeff(i, max(1, ndg)))
                    countcR(2) = countcR(2) + 1;
                    if direcR(1) == 'v' && modocR(1) == countcR(2)
                        m = i;
                    elseif direcR(2) == 'h' && modocR(2) == countcR(2)
                        n = i;
                    end
                end
            end
            if m == 0 || n == 0
                error('\t\tSe requiere aumentar el numero de modos para determinar matriz de amortiguamiento de Rayleigh')
            end
            w = analisisObj.wn;
            a = (2 * w(m) * w(n)) / (w(n)^2 - w(m)^2) .* [w(n), -w(m); ...
                -1 / w(n), 1 / w(m)] * betacR';
            analisisObj.cRayleigh = a(1) .* Meq + a(2) .* Keq;
            
            % ------ CALCULO DE AMORTIGUAMIENTO DE WILSON-PENZIEN ----------
            
            % Se declaran todos los amortiguamientos criticos del sistema,
            % (horizontal, vertical y rotacional)
            d = zeros(length(analisisObj.Mmeff), length(analisisObj.Mmeff));
            w = analisisObj.wn;
            Mn = modalMmt;
            analisisObj.cPenzien = 0;
            for i = 1:length(Mn)
                if analisisObj.Mmeff(i, 1) > max(analisisObj.Mmeff(i, 2:ndg))
                    d(i, i) = 2 * betacP(1) * w(i) / Mn(i, i);
                elseif analisisObj.Mmeff(i, 2) > ...
                        max(analisisObj.Mmeff(i, 1), analisisObj.Mmeff(i, max(1, ndg)))
                    d(i, i) = 2 * betacP(2) * w(i) / Mn(i, i);
                else
                    d(i, i) = 2 * betacP(3) * w(i) / Mn(i, i);
                end
                analisisObj.cPenzien = analisisObj.cPenzien + ...
                    Meq * (d(i, i) * modalPhin(:, i) * modalPhin(:, i)') * Meq;
            end
            
            %--------------------------------------------------------------
            
            % Termina el analisis
            analisisObj.analisisFinalizado = true;
            analisisObj.numDG = ndg;
            analisisObj.numDGReal = analisisObj.modeloObj.obtenerNumerosGDL();
            fprintf('\tSe completo el analisis en %.3f segundos\n', cputime-tInicio);
            
        end % calcularModalEspectral function
        
        function ensamblarMatrizRigidez(analisisObj)
            % ensamblarMatrizRigidez: es un metodo de la clase ModalEspectral que se usa para
            % realizar el armado de la matriz de rigidez del modelo analizado
            %
            % ensamblarMatrizRigidez(analisisObj)
            % Ensambla la matriz de rigidez del modelo analizado usando el metodo
            % indicial
            
            fprintf('\tEnsamblando matriz de rigidez\n');
            analisisObj.Kt = zeros(analisisObj.numeroGDL, analisisObj.numeroGDL);
            
            % Extraemos los Elementos
            elementoObjetos = analisisObj.modeloObj.obtenerElementos();
            numeroElementos = length(elementoObjetos);
            
            % Definimos los GDLID en los elementos
            for i = 1:numeroElementos
                
                % Se obienen los gdl del elemento metodo indicial
                gdl = elementoObjetos{i}.obtenerGDLID();
                ngdl = elementoObjetos{i}.obtenerNumeroGDL;
                
                % Se obtiene la matriz de rigidez global del elemento-i
                k_globl_elem = elementoObjetos{i}.obtenerMatrizRigidezCoordGlobal();
                
                % Se calcula el metodo indicial
                for r = 1:ngdl
                    for s = 1:ngdl
                        i_ = gdl(r);
                        j_ = gdl(s);
                        
                        % Si corresponden a grados de libertad -> puntos en (i,j)
                        % se suma contribucion metodo indicial
                        if (i_ ~= 0 && j_ ~= 0)
                            analisisObj.Kt(i_, j_) = analisisObj.Kt(i_, j_) + k_globl_elem(r, s);
                        end
                        
                    end % for s
                end % for r
                
            end % for i
            
        end % ensamblarMatrizRigidez function
        
        function ensamblarMatrizMasa(analisisObj)
            % ensamblarMatrizMasa: es un metodo de la clase ModalEspectral que se usa para
            % realizar el armado de la matriz de masa del modelo
            %
            % ensamblarMatrizMasa(analisisObj)
            % Ensambla la matriz de masa del modelo analizado usando el metodo
            % indicial
            
            fprintf('\tEnsamblando matriz de masa\n');
            analisisObj.Mt = zeros(analisisObj.numeroGDL, analisisObj.numeroGDL);
            
            % Extraemos los Elementos
            elementoObjetos = analisisObj.modeloObj.obtenerElementos();
            numeroElementos = length(elementoObjetos);
            
            % Definimos los GDLID en los elementos
            for i = 1:numeroElementos
                
                % Se obienen los gdl del elemento metodo indicial
                gdl = elementoObjetos{i}.obtenerGDLID();
                ngdl = elementoObjetos{i}.obtenerNumeroGDL;
                
                % Se obtiene la matriz de masa
                m_elem = elementoObjetos{i}.obtenerMatrizMasa();
                
                % Se calcula el metodo indicial
                for r = 1:ngdl
                    for s = 1:ngdl
                        i_ = gdl(r);
                        j_ = gdl(s);
                        
                        % Si corresponden a grados de libertad -> puntos en (i,j)
                        % se suma contribucion metodo indicial
                        if (i_ ~= 0 && j_ ~= 0 && r == s)
                            analisisObj.Mt(i_, j_) = analisisObj.Mt(i_, j_) + m_elem(r);
                        end
                        
                    end % for s
                end % for r
                
            end % for i
            
            % Agrega las cargas de los nodos
            nodoObjetos = analisisObj.modeloObj.obtenerNodos();
            numeroNodos = length(nodoObjetos);
            
            for i = 1:numeroNodos
                gdlidNodo = nodoObjetos{i}.obtenerGDLID; % (x, y, giro)
                gly = gdlidNodo(2);
                carga = nodoObjetos{i}.obtenerReacciones(); % (x, y, giro)
                if gly == 0
                    continue;
                end
                analisisObj.Mt(gly, gly) = analisisObj.Mt(gly, gly) + carga(2);
            end
            
            % Chequea que la matriz de masa sea consistente
            for i = 1:analisisObj.numeroGDL
                analisisObj.Mt(i, i) = analisisObj.Mt(i, i) / 9.80665; % [tonf->ton]
            end
            
        end % ensamblarMatrizMasa function
        
        function ensamblarVectorFuerzas(analisisObj)
            % ensamblarVectorFuerzas: es un metodo de la clase ModalEspectral que se usa para
            % realizar el armado del vector de fuerzas del modelo analizado
            %
            % ensamblarMatrizRigidez(analisisObj)
            % Ensambla el vector de fuerzas del modelo analizado usando el metodo
            % indicial
            
            analisisObj.F = zeros(analisisObj.numeroGDL, 1);
            
            % En esta funcion se tiene que ensamblar el vector de fuerzas
            % Extraemos los nodos
            nodoObjetos = analisisObj.modeloObj.obtenerNodos();
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
                        analisisObj.F(gdl(j)) = -reacc(j);
                    end
                end % for j
                
            end % for i
            
        end % ensamblarVectorFuerzas function
        
        function plotAnimado(analisisObj, deformada, modo, factor, phif, limx, limy, limz, ...
                per, cuadro, totCuadros, defElem, defCarga, carga, tcarga, tcargaEq)
            % Anima el grafico en funcion del numero del modo
            
            % Si se grafica la carga no se aplica el factor sin(wt)
            if defCarga
                phif = 1;
            end
            
            % Carga objetos
            nodoObjetos = analisisObj.modeloObj.obtenerNodos();
            numeroNodos = length(nodoObjetos);
            
            % Obtiene cuantos GDL tiene el modelo
            gdl = 2;
            ngdl = analisisObj.modeloObj.obtenerNumeroDimensiones();
            j = 1;
            for i = 1:numeroNodos
                coords = nodoObjetos{i}.obtenerCoordenadas();
                ngdlid = length(coords);
                gdl = max(gdl, ngdlid);
                if ~deformada
                    if modo ~= 0 || defCarga
                        nodoObjetos{i}.plot([], 'b', 10);
                    else
                        nodoObjetos{i}.plot([], 'k', 15);
                    end
                    if j == 1
                        hold on;
                    end
                    j = j + 1;
                end
            end
            
            % Grafica los elementos
            elementoObjetos = analisisObj.modeloObj.obtenerElementos();
            numeroElementos = length(elementoObjetos);
            
            for i = 1:numeroElementos
                
                % Se obienen los gdl del elemento metodo indicial
                nodoElemento = elementoObjetos{i}.obtenerNodos();
                numNodo = length(nodoElemento);
                
                if (~deformada || analisisObj.mostrarDeformada)
                    if modo ~= 0 || defCarga
                        elementoObjetos{i}.plot({}, 'b-', 0.5, false);
                    else
                        elementoObjetos{i}.plot({}, 'k-', 1.25, false);
                    end
                end
                
                if deformada
                    def = cell(numNodo, 1);
                    for j = 1:numNodo
                        def{j} = factor * phif * analisisObj.obtenerDeformadaNodo(nodoElemento{j}, ...
                            modo, analisisObj.numDGReal, defCarga, carga, tcarga);
                    end
                    elementoObjetos{i}.plot(def, 'k-', 1.25, defElem);
                    if i == 1
                        hold on;
                    end
                end
                
            end
            
            % Grafica los nodos deformados
            if deformada
                for i = 1:numeroNodos
                    coords = nodoObjetos{i}.obtenerCoordenadas();
                    ngdlid = length(coords);
                    gdl = max(gdl, ngdlid);
                    def = analisisObj.obtenerDeformadaNodo(nodoObjetos{i}, modo, ...
                        gdl, defCarga, carga, tcarga);
                    nodoObjetos{i}.plot(def.*factor*phif, 'k', 15);
                end
                
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
                b = sprintf('Escala deformacion x%d - Cuadro %s/%d - t:%.2fs', ...
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
                xlabel('X');
                ylabel('Y');
            else
                xlabel('X');
                ylabel('Y');
                zlabel('Z');
                view(45, 45);
            end
            
        end % plotAnimado function
        
        function [limx, limy, limz] = obtenerLimitesDeformada(analisisObj, modo, factor, defcarga, carga)
            % Obtiene los limites de deformacion
            %
            % obtenerLimitesDeformada(analisisObj,modo,factor,defcarga,carga)
            
            fprintf('\tCalculando los limites del grafico\n');
            factor = 2.5 * factor;
            limx = [inf, -inf];
            limy = [inf, -inf];
            limz = [inf, -inf];
            
            % Carga objetos
            nodoObjetos = analisisObj.modeloObj.obtenerNodos();
            numeroNodos = length(nodoObjetos);
            gdl = 2;
            for i = 1:numeroNodos
                coords = nodoObjetos{i}.obtenerCoordenadas();
                ngdlid = length(coords);
                gdl = max(gdl, ngdlid);
            end
            
            elementoObjetos = analisisObj.modeloObj.obtenerElementos();
            numeroElementos = length(elementoObjetos);
            for i = 1:numeroElementos
                nodoElemento = elementoObjetos{i}.obtenerNodos();
                numNodo = length(nodoElemento);
                for j = 1:numNodo
                    coord = nodoElemento{j}.obtenerCoordenadas();
                    if (analisisObj.analisisFinalizado && modo > 0) || defcarga
                        def = analisisObj.obtenerDeformadaNodo(nodoElemento{j}, modo, gdl, defcarga, carga, -1);
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
                    if (analisisObj.analisisFinalizado && modo > 0) || defcarga
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
                end
            end
            
        end % obtenerLimitesDeformada function
        
        function def = obtenerDeformadaNodo(analisisObj, nodo, modo, gdl, defcarga, carga, tcarga)
            % obtenerDeformadaNodo: Obtiene la deformada de un nodo
            %
            % obtenerDeformadaNodo(analisisObj,nodo,modo,gdl,defcarga,carga,tcarga)
            
            ngdl = nodo.obtenerGDLIDCondensado();
            def = zeros(gdl, 1);
            gdl = min(gdl, length(ngdl));
            for i = 1:gdl
                if ngdl(i) > 0
                    if ~defcarga % La deformada la saca a partir del modo
                        def(i) = analisisObj.phin(ngdl(i), modo);
                    else
                        def(i) = carga.obtenerDesplazamientoTiempo(ngdl(i), tcarga);
                    end
                else
                    def(i) = 0;
                end
            end
            
        end % obtenerDeformadaNodo function
        
    end % methods(private) ModalEspectral
    
end % class ModalEspectral