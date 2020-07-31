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
%| Clase ModalEspectral                                                 |
%|                                                                      |
%| Este archivo contiene la definicion de la Clase ModalEspectral       |
%| ModalEspectral es una clase que se usa para resolver la estructura   |
%| aplicando el metodo modal espectral. Para ello se calcula la matriz  |
%| de masa y de rigidez.                                                |
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
%       obj = ModalEspectral(modeloObjeto)
%       [esfmax,esf,maxp,dirk] = calcularEsfuerzosElemento(obj,carga,elemento,direccion)
%       activarCargaAnimacion(obj)
%       activarPlotDeformadaInicial(obj)
%       analizar(obj,varargin)
%       beta = calcularAmortiguamientoModo(modo,rayleigh)
%       c = obtenerCargaEstatica(obj,varargin)
%       C_Modelo = obtenerMatrizAmortiguamiento(obj,rayleigh)
%       calcularCurvasEnergia(obj,carga)
%       calcularDesplazamientoDrift(obj,xanalisis)
%       calcularIdentificacionNL(obj,carga,nodo,direccionCarga,varargin)
%       calcularMomentoCorteBasal(obj,carga)
%       calcularPSDCarga(obj,carga,nodos,direccionCarga,direccionFormaModal,varargin)
%       Cdv_Modelo = obtenerMatrizAmortiguamientoDisipadores(obj)
%       definirNumeracionGDL(obj)
%       desactivarCargaAnimacion(obj)
%       desactivarPlotDeformadaInicial(obj)
%       disp(obj)
%       F_Modelo = obtenerVectorFuerzas(obj)
%       K_Modelo = obtenerMatrizRigidez(obj)
%       Kdv_Modelo = obtenerMatrizRigidezDisipadores(obj)
%       M_Modelo = obtenerMatrizMasa(obj)
%       Mmeff = obtenerVectorParticipacionMasa(obj)
%       numeroEcuaciones = obtenerNumeroEcuaciones(obj)
%       phi_Modelo = obtenerMatrizPhi(obj)
%       plot(obj,varargin)
%       plotEsfuerzosElemento(obj,carga)
%       plotEspectrogramaNormalizado(obj,carga,nodos,direccionCarga,varargin)
%       plotTrayectoriaNodo(obj,carga,nodo,direccion)
%       plotTrayectoriaNodos(obj,carga,nodos,direccion,varargin)
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
    end % private properties ModalEspectral
    
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
            end
            
            obj = obj@Analisis(modeloObjeto);
            
            % Guarda valores iniciales
            obj.cargarAnimacion = true;
            obj.F = [];
            obj.Kt = [];
            obj.mostrarDeformada = true;
            obj.Mt = [];
            obj.u = [];
            
        end % ModalEspectral constructor
        
        function analizar(obj, varargin)
            % analizar: es un metodo de la clase ModalEspectral que se usa para
            % realizar el analisis estatico
            % Analiza estaticamente el modelo lineal y elastico sometido a un
            % set de cargas, requiere el numero de modos para realizar el
            % analisis y de los modos conocidos con sus beta
            %
            % Parametros opcionales:
            %   amortiguamiento     Algoritmo, all,rayleigh,cpenzien
            %   condensar           Aplica condensacion (true por defecto)
            %   cpenzienBeta        Vector amortiguamiento Cpenzien
            %   factorCargaE        Factor de cargas estaticas
            %   nModos              Numero de modos de analisis (obligatorio)
            %   rayleighBeta        Vector amortiguamientos de Rayleigh
            %   rayleighDir         Direccion amortiguamiento Rayleigh
            %   rayleighModo        Vector modos de Rayleigh
            %   toleranciaMasa      Tolerancia de la masa para la condensacion
            %   valvecAlgoritmo     eigs,itDir,matBarr,itInvDesp,itSubEsp,ritz
            %   valvecTolerancia    Tolerancia calculo valores y vectores propios
            
            % Define parametros
            p = inputParser;
            p.KeepUnmatched = true;
            addOptional(p, 'amortiguamiento', 'all');
            addOptional(p, 'condensar', true);
            addOptional(p, 'cpenzienBeta', []);
            addOptional(p, 'factorCargaE', 1);
            addOptional(p, 'muIterDespl', []);
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
            
            % Mensaje inicial
            fprintf('Ejecutando analisis modal espectral:\n');
            fprintf('\tModelo %s:\n', obj.modeloObj.obtenerNombre());
            
            % Verifica que parametros obligatorios sean proporcionados
            if r.nModos <= 0
                error('Numero de modos invalido');
            end
            r.nModos = ceil(r.nModos);
            
            % Tipo de amortiguamiento
            betaAlgoritmo = lower(r.amortiguamiento());
            betaAlg = 0;
            if strcmp(betaAlgoritmo, 'all')
                fprintf('\tSe calcularan todos los tipos de amortiguamientos\n');
            elseif strcmp(betaAlgoritmo, 'rayleigh')
                betaAlg = 1;
                fprintf('\tSe calculara amortiguamiento de Rayleigh\n');
            elseif strcmp(betaAlgoritmo, 'cpenzien')
                betaAlg = 2;
                fprintf('\tSe calculara amortiguamiento de Cpenzien\n');
            else
                error('Tipo de amortiguamiento desconocido, valores posibles: all,rayleigh,cpenzien');
            end
            
            % Amortiguamiento Rayleigh
            if (betaAlg == 0 || betaAlg == 1)
                if isempty(r.rayleighBeta)
                    error('Vector amortiguamiento de Rayleigh no puede ser nulo');
                end
                
                for i = 1:length(r.rayleighBeta)
                    if r.rayleighBeta(i) <= 0
                        error('No pueden haber amortiguamientos de Rayleigh negativos o cero');
                    end
                end % for i
                
                if isempty(r.rayleighModo)
                    error('Vector modo Rayleigh no puede ser nulo');
                end
                
                for i = 1:length(r.rayleighModo)
                    r.rayleighModo(i) = ceil(r.rayleighModo(i));
                    if r.rayleighModo(i) <= 0
                        error('Vector Rayleigh modo mal definido, no pueden ser modos negativos o ceros');
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
            end
            
            % Amortiguamiento Cpenzien
            if (betaAlg == 0 || betaAlg == 2)
                if isempty(r.cpenzienBeta)
                    error('Vector amortiguamiento cpenzien no puede ser nulo');
                end
                
                for i = 1:length(r.cpenzienBeta)
                    if r.cpenzienBeta(i) < 0
                        error('No pueden haber amortiguamientos de cpenzien negativos');
                    end
                end % for i
            end
            
            if r.valvecTolerancia <= 0
                error('Tolerancia calculo valores y vectores propios no puede ser inferior o igual a cero');
            end
            
            if length(r.nRitz) > 1
                error('Numero de Ritz no puede ser un vector');
            end
            
            r.nRitz = ceil(r.nRitz);
            if r.nRitz <= 0
                error('El numero de vectores Ritz no puede ser inferior o igual a cero');
            end
            
            if strcmp(r.valvecAlgoritmo, 'itInvDesp')
                if isempty(r.muIterDespl)
                    error('El vector muIterDespl no puede ser nulo si se usa el algoritmo de iteracion inversa por desplazamiento');
                end
                [muc, muk] = size(r.muIterDespl);
                if ~(muc == 1 || muk == 1)
                    error('muIterDespl debe ser un vector');
                else
                    if muc == 1 % Convierte en vector columna
                        r.muIterDespl = r.muIterDespl';
                    end
                end
                for i = 1:length(r.muIterDespl)
                    if r.muIterDespl(i) <= 0
                        error('No puede haber un elemento cero o negativo en el vector de desplazamientos');
                    end
                end % for i
            end
            
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
                r.muIterDespl, r.nRitz, betaAlg);
            
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
            addOptional(p, 'disipadores', false);
            addOptional(p, 'factorCargasD', 1);
            addOptional(p, 'iterDisipador', 10);
            addOptional(p, 'tolIterDisipador', 0.001);
            parse(p, varargin{:});
            r = p.Results;
            
            % Chequea inconsistencias
            if ~r.activado
                error('El analisis no se ha activado');
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
            
            if ~obj.analisisFinalizado
                warning('El analisis no ha sido realizado aun');
            end
            M_Modelo = obj.Mteq;
            
        end % obtenerMatrizMasa function
        
        function C_Modelo = obtenerMatrizAmortiguamiento(obj, rayleigh)
            % obtenerMatrizAmortiguamiento: es un metodo de la clase ModalEspectral
            % que se usa para obtener la matriz de amortiguamiento del modelo
            %
            % Obtiene la matriz de amortiguamiento (C_Modelo) del modelo que se genero
            % en el Analisis (obj)
            
            if ~obj.analisisFinalizado
                warning('El analisis no ha sido realizado aun');
            end
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
            
            if ~obj.analisisFinalizado
                warning('El analisis no ha sido realizado aun');
            end
            K_Modelo = obj.Kteq;
            
        end % obtenerMatrizRigidez function
        
        function Cdv_Modelo = obtenerMatrizAmortiguamientoDisipadores(obj)
            % obtenerMatrizRigidez: es un metodo de la clase ModalEspectral
            % que se usa para obtener la matriz de amortiguamiento del modelo
            % producto de los disipadores incorporados
            %
            % Obtiene la matriz de amortiguamiento del modelo
            
            if ~obj.analisisFinalizado
                warning('El analisis no ha sido realizado aun');
            end
            Cdv_Modelo = obj.ensamblarMatrizAmortiguamientoDisipadores();
            
        end % obtenerMatrizAmortiguamientoDisipadores function
        
        function Kdv_Modelo = obtenerMatrizRigidezDisipadores(obj)
            % obtenerMatrizRigidezDisipadores: es un metodo de la clase ModalEspectral
            % que se usa para obtener la matriz de rigidez de los
            % disipadores
            
            if ~obj.analisisFinalizado
                warning('El analisis no ha sido realizado aun');
            end
            Kdv_Modelo = obj.ensamblarMatrizRigidezDisipadores();
            
        end % obtenerMatrizRigidezDisipadores function
        
        function r_Modelo = obtenerVectorInfluencia(obj)
            % obtenerVectorInfluencia: es un metodo de la clase ModalEspectral
            % que se usa para obtener el vector de influencia del modelo
            %
            % Obtiene el vector de influencia (r) del modelo que se genero
            % en el Analisis (obj)
            
            if ~obj.analisisFinalizado
                warning('El analisis no ha sido realizado aun');
            end
            r_Modelo = obj.rm;
            
        end % obtenerVectorInfluencia function
        
        function F_Modelo = obtenerVectorFuerzas(obj)
            % obtenerMatrizRigidez: es un metodo de la clase ModalEspectral
            % que se usa para obtener el vector de fuerza del modelo
            %
            % Obtiene el vector de fuerza (F_Modelo) del modelo que se genero
            % en el Analisis (obj)
            
            if ~obj.analisisFinalizado
                warning('El analisis no ha sido realizado aun');
            end
            F_Modelo = obj.F;
            
        end % obtenerVectorFuerzas function
        
        function u_Modelo = obtenerDesplazamientos(obj)
            % obtenerDesplazamientos: es un metodo de la clase ModalEspectral
            % que se usa para obtener el vector de desplazamiento del modelo
            % obtenido del analisis
            %
            % Obtiene el vector de desplazamiento (u_Modelo) del modelo que se
            % genero como resultado del Analisis (obj)
            
            if ~obj.analisisFinalizado
                warning('El analisis no ha sido realizado aun');
            end
            u_Modelo = obj.u;
            
        end % obtenerDesplazamientos function
        
        function wn_Modelo = obtenerValoresPropios(obj)
            % obtenerValoresPropios: es un metodo de la clase ModalEspectral
            % que se usa para obtener los valores propios del modelo
            % obtenido del analisis
            %
            % Obtiene los valores propios (wn_Modelo) del modelo que se
            % genero como resultado del Analisis (obj)
            
            if ~obj.analisisFinalizado
                warning('El analisis no ha sido realizado aun');
            end
            wn_Modelo = obj.wn;
            
        end % obtenerValoresPropios function
        
        function Mmeff = obtenerVectorParticipacionMasa(obj)
            % obtenerVectorParticipacion: Obtiene el vector de
            % participacion modal de las masas
            
            if ~obj.analisisFinalizado
                warning('El analisis no ha sido realizado aun');
            end
            Mmeff = obj.Mmeff(1:obj.numModos, :);
            
        end % obtenerVectorParticipacion function
        
        function phi_Modelo = obtenerMatrizPhi(obj)
            % obtenerMatrizPhi: es un metodo de la clase ModalEspectral
            % que se usa para obtener los vectores propios del modelo
            % obtenido del analisis
            %
            % Obtiene los vectores propios (phi_Modelo) del modelo que se
            % genero como resultado del Analisis (obj)
            
            if ~obj.analisisFinalizado
                warning('El analisis no ha sido realizado aun');
            end
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
            tinicial = clock;
            
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
            
            if mostrarEstatico
                fprintf('\tSe graficara el caso estatico del modelo\n');
            else
                fprintf('\tNo se graficara el caso estatico del modelo\n');
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
            else
                fprintf('\tNo se graficara la deformada de los elementos\n');
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
                fprintf('\tProceso finalizado en %.2f segundos\n', etime(clock, tinicial));
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
                fprintf('\tProceso finalizado en %.2f segundos\n', etime(clock, tinicial));
                
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
            tinicial = clock;
            
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
            acel = carga.obtenerAceleracion();
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
                if yNodo > habs(j)
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
            acelx = zeros(nndrift, s);
            driftx = zeros(nndrift-1, s);
            
            % Calculo de drift y desplazamiento en linea de analisis
            for i = 2:nndrift
                nodosup = ndrift(i);
                gdls = nodos{nodosup}.obtenerGDLIDCondensado();
                gdlx = gdls(1);
                despx(i, :) = desp(gdlx, :);
                acelx(i, :) = acel(gdlx, :);
                driftx(i-1, :) = abs(despx(i, :)-despx(i-1, :)) ./ (habs(i) - habs(i-1));
                
            end % for i
            
            % Determinacion de envolvente maxima de desplazamiento y drift
            despxmax = max(abs(despx'))';
            acelxmax = max(abs(acelx'))';
            driftxmax = max(abs(driftx'))';
            VecDesp = flipud(despxmax);
            VecAcel = flipud(acelxmax);
            VecDrift = flipud(driftxmax);
            hgen = flipud(habs);
            hplot = zeros(2*length(hgen), 1);
            Despplot = zeros(2*length(hgen)-1, 1);
            Acelplot = zeros(2*length(hgen)-1, 1);
            Driftplot = zeros(2*length(hgen)-1, 1);
            aux1 = 1;
            aux2 = 2;
            for i = 1:length(hgen)
                hplot(aux1, 1) = hgen(i);
                hplot(aux1+1, 1) = hgen(i);
                if aux2 <= 2 * length(hgen) - 1
                    Driftplot(aux2, 1) = VecDrift(i);
                    Driftplot(aux2+1, 1) = VecDrift(i);
                    Acelplot(aux2, 1) = VecAcel(i);
                    Acelplot(aux2+1, 1) = VecAcel(i);
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
            title({fig_title, ''});
            
            fig_title = sprintf('Envolvente de Desplazamiento - %s %s', ctitle, carga.obtenerEtiqueta());
            plt = figure('Name', fig_title, 'NumberTitle', 'off');
            movegui(plt, 'center');
            plot(Despplot, hplot, '*-', 'LineWidth', 1, 'Color', 'black');
            grid on;
            grid minor;
            xlabel(sprintf('Desplazamiento (%s)', r.unidad));
            ylabel(sprintf('Altura (%s)', r.unidad));
            title({fig_title, ''});
            
            fig_title = sprintf('Envolvente de Aceleracion - %s %s', ctitle, carga.obtenerEtiqueta());
            plt = figure('Name', fig_title, 'NumberTitle', 'off');
            movegui(plt, 'center');
            plot(Acelplot, hplot, '*-', 'LineWidth', 1, 'Color', 'black');
            grid on;
            grid minor;
            xlabel(sprintf('Aceleracion (%s/s^2)', r.unidad));
            ylabel(sprintf('Altura (%s)', r.unidad));
            title({fig_title, ''});
            
            % Finaliza proceso
            drawnow();
            fprintf('\tProceso finalizado en %.2f segundos\n', etime(clock, tinicial));
            dispMetodoTEFAME();
            
        end % calcularDesplazamientoDrift function
        
        function [x, y] = calcularMomentoCorteBasal(obj, carga, varargin)
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
            tinicial = clock;
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
                x = t;
                y = Cortante(end, :);
                plot(x, y, 'k-', 'LineWidth', 1);
                grid on;
                grid minor;
                xlabel('Tiempo (s)');
                ylabel(sprintf('Corte (%s)', r.unidadC));
                title({fig_title, ''});
                dplot = true;
            end % corte
            
            if strcmp(tipoplot, 'all') || strcmp(tipoplot, 'momento')
                fig_title = sprintf('Historial de Momento Basal - %s %s', ctitle, carga.obtenerEtiqueta());
                plt = figure('Name', fig_title, 'NumberTitle', 'off');
                movegui(plt, 'center');
                x = t;
                y = Momento(end, :);
                plot(x, y, 'k-', 'LineWidth', 1);
                grid on;
                grid minor;
                xlabel('Tiempo (s)');
                ylabel(sprintf('Momento (%s)', r.unidadM));
                title({fig_title, ''});
                dplot = true;
            end % momento
            
            if strcmp(tipoplot, 'all') || strcmp(tipoplot, 'envcorte')
                fig_title = sprintf('Envolvente de Cortante Basal - %s %s', ctitle, carga.obtenerEtiqueta());
                plt = figure('Name', fig_title, 'NumberTitle', 'off');
                movegui(plt, 'center');
                x = CBplot;
                y = hplot;
                plot(x, y, '*-', 'LineWidth', 1, 'Color', 'black');
                hold on;
                grid on;
                grid minor;
                xlabel(sprintf('Corte (%s)', r.unidadC));
                ylabel('Altura (m)');
                title({fig_title, ''});
                
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
            end % envcorte
            
            if strcmp(tipoplot, 'all') || strcmp(tipoplot, 'envmomento')
                fig_title = sprintf('Envolvente de Momento Basal - %s %s', ctitle, carga.obtenerEtiqueta());
                plt = figure('Name', fig_title, 'NumberTitle', 'off');
                movegui(plt, 'center');
                x = MBplot;
                y = hplot;
                plot(x, y, '*-', 'LineWidth', 1, 'Color', 'black');
                grid on;
                grid minor;
                xlabel(sprintf('Momento (%s)', r.unidadM));
                ylabel('Altura (m)');
                title({fig_title, ''});
                dplot = true;
            end % envmomento
            
            % Si no se realizo ningun grafico
            if ~dplot
                error('Tipo de grafico %s incorrecto, valores aceptados: %s', tipoplot, ...
                    'corte, momento, envcorte, envmomento');
            end
            
            % Finaliza proceso
            drawnow();
            fprintf('\tProceso finalizado en %.2f segundos\n', etime(clock, tinicial));
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
            tinicial = clock;
            
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
                title({fig_title, ''});
                ylims = get(gca, 'YLim');
                ylim([0, max(ylims)]);
                
                if plotcarga % Grafica la carga
                    axes('Position', [.59, .65, .29, .20]);
                    box on;
                    plot(t, c_p, 'k-', 'Linewidth', 0.8);
                    grid on;
                end
                dplot = true;
                
            end % ek
            
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
                title({fig_title, ''});
                ylims = get(gca, 'YLim');
                ylim([0, max(ylims)]);
                
                if plotcarga % Grafica la carga
                    axes('Position', [.59, .65, .29, .20]);
                    box on;
                    plot(t, c_p, 'k-', 'Linewidth', 0.8);
                    grid on;
                end
                dplot = true;
                
            end % ev
            
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
                title({fig_title, ''});
                ylims = get(gca, 'YLim');
                ylim([0, max(ylims)]);
                
                if plotcarga % Grafica la carga
                    axes('Position', [.59, .66, .29, .20]);
                    box on;
                    plot(t, c_p, 'k-', 'Linewidth', 0.8);
                    grid on;
                end
                dplot = true;
                
            end % ebe
            
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
                title({fig_title, ''});
                ylims = get(gca, 'YLim');
                ylim([0, max(ylims)]);
                
                if plotcarga % Grafica la carga
                    axes('Position', [.59, .53, .29, .20]);
                    box on;
                    plot(t, c_p, 'k-', 'Linewidth', 0.8);
                    grid on;
                end
                dplot = true;
                
            end % evek
            
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
                title({fig_title, ''});
                ylims = get(gca, 'YLim');
                ylim([0, max(ylims)]);
                
                if plotcarga % Grafica la carga
                    axes('Position', [.17, .66, .29, .20]);
                    box on;
                    plot(t, c_p, 'k-', 'Linewidth', 0.8);
                    grid on;
                end
                dplot = true;
                
            end % et
            
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
                title({fig_title, ''});
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
                    title({fig_title, ''});
                    ylims = get(gca, 'YLim');
                    ylim([0, max(ylims)]);
                    if plotcarga % Grafica la carga
                        axes('Position', [.59, .63, .29, .20]);
                        box on;
                        plot(t, c_p, 'k-', 'Linewidth', 0.8);
                        grid on;
                    end
                end
                
            end % ed
            
            % Si no se realizo ningun grafico
            if ~dplot
                error('Tipo de grafico %s incorrecto, valores aceptados: %s', tipoplot, ...
                    'ek, ev, ekev, ebe, et, ed');
            end
            
            % Finaliza proceso
            drawnow();
            fprintf('\tProceso finalizado en %.2f segundos\n', etime(clock, tinicial));
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
                modoJ = phi(:, j);
                e_vsum = 0; % Suma la energia asociada a un modo para todo el tiempo
                kj = modoJ' * k;
                for i = 1:s % Recorre el tiempo
                    vv = c_u(:, i); % Obtiene el vector de desplazamiento para el tiempo i
                    e_vsum = e_vsum + 0.5 * vv' * modoJ * kj * vv;
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
            tinicial = clock;
            
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
            title({fig_title, ''});
            
            legend({sprintf('Esfuerzo elemento: %s', carga.obtenerEtiqueta()), ...
                sprintf('Esfuerzo maximo: %.2f (%s)', esf(dirk, maxp), diru)}, ...
                'location', 'southeast');
            
            % Finaliza proceso
            fprintf('\tProceso finalizado en %.2f segundos\n', etime(clock, tinicial));
            dispMetodoTEFAME();
            
        end % plotEsfuerzosElemento function
        
        function beta = calcularAmortiguamientoModo(obj, modo, rayleigh)
            % calcularAmortiguamientoModo: Calcula el amortiguamiento de un
            % modo
            
            modo = floor(modo);
            if modo <= 0 || modo > obj.numModos
                error('El modo no puede ser cero o superior al numero de modos del sistema');
            end
            
            c = obj.obtenerMatrizAmortiguamiento(rayleigh);
            cd = obj.obtenerMatrizAmortiguamientoDisipadores();
            phi1 = obj.phin(:, modo);
            w1 = obj.wn(modo);
            
            beta = (phi1' * (c + cd) * phi1) / (2 * w1 * phi1' * obj.Mteq * phi1);
            
        end % calcularAmortiguamientoModo function
        
        function plotEspectrogramaNormalizado(obj, carga, nodos, direccionCarga, varargin)
            % plotEspectrogramaNormalizado: Grafica el espectrograma
            % normalizado de un registro de aceleracion de varios nodos
            %
            % Parametros opcionales:
            %   maxFreq             Frecuencia maxima de analisis
            %   normalize           Normaliza el calculo
            %   windowTime          Tiempo de cada ventana, si no se define se usa todo el registro
            %   windowTimeMovement  Movimiento de la ventana
            
            % Inicia proceso
            tinicial = clock;
            
            % Verifica que el vector de nodos sea un cell
            if ~iscell(nodos)
                error('Nodos debe ser un cell de nodos');
            end
            for k = 1:length(nodos)
                if ~isa(nodos{k}, 'Nodo')
                    error('Elemento %d del cell de nodos no es de clase Nodo', k);
                end
            end % for k
            
            % Verifica que la direccion sea correcta
            if sum(direccionCarga) ~= 1
                error('Direccion carga invalida');
            end
            if ~verificarVectorDireccion(direccionCarga, nodos{1}.obtenerNumeroGDL())
                error('Vector direccion carga mal definido');
            end
            
            % Recorre parametros opcionales
            p = inputParser;
            p.KeepUnmatched = true;
            addOptional(p, 'contour', []);
            addOptional(p, 'maxFreq', 10);
            addOptional(p, 'normalize', true);
            addOptional(p, 'windowTime', 0);
            addOptional(p, 'windowTimeMovement', 2.5); % s
            parse(p, varargin{:});
            r = p.Results;
            
            % Obtiene las variables
            a_c = carga.obtenerAceleracion();
            
            % Otros
            r.contour = sort(r.contour);
            
            % Verifica que la carga se haya calculado
            if ~(isa(carga, 'CargaDinamica') || isa(carga, 'CombinacionCargas'))
                error('Solo se pueden graficar cargas dinamicas o combinaciones de cargas');
            end
            if ~carga.cargaCalculada()
                error('La carga %s no se ha calculado', carga.obtenerEtiqueta());
            end
            
            % Crea el titulo de la carga
            ctitle = obj.imprimirPropiedadesAnalisisCarga(carga);
            ng = length(nodos);
            [nr, ~] = size(a_c);
            
            % Verifica que la direccion sea correcta
            gdl = zeros(1, ng);
            for k = 1:ng
                % Elige al nodo
                ngd = nodos{k}.obtenerGDLIDCondensado();
                for i = 1:length(direccionCarga)
                    if direccionCarga(i) == 1
                        gdl(k) = ngd(i);
                    end
                end % for i
                if gdl(k) == 0
                    error('No se ha obtenido el GDLID del nodo, es posible que corresponda a un apoyo o bien que el grado de libertad fue condensado');
                end
                if gdl(k) > nr
                    error('El GDLID excede al soporte del sistema');
                end
            end % for k
            
            % Crea la leyenda de los nodos
            legnodos = cell(1, ng);
            for k = 1:ng
                legnodos{k} = nodos{k}.obtenerEtiqueta();
            end % for k
            
            % Verifica frecuencia de analisis
            if r.maxFreq <= 0
                error('El limite de frecuencia no puede ser negativo o nulo');
            end
            
            % Verifica que el tiempo de analisis sea adecuado
            if r.windowTimeMovement <= 0
                error('El tiempo de movimiento de la ventana no puede ser inferior o igual a cero');
            end
            if r.windowTime <= 0
                r.windowTime = carga.tAnalisis - r.windowTimeMovement;
            else
                if r.windowTime > carga.tAnalisis - r.windowTimeMovement
                    error('El tamano de la ventana no puede superar el tiempo de la carga + el tiempo de movimiento de la ventana (%.1fs)', ...
                        carga.tAnalisis-r.windowTimeMovement);
                end
            end
            fprintf('\tTiempo de la ventana: %.1fs\n', r.windowTime);
            fprintf('\tTiempo de movimiento de la ventana: %.1fs\n', r.windowTimeMovement);
            
            % Crea vector temporal
            lt = length(a_c(1, :));
            t = linspace(0, carga.tAnalisis, lt);
            
            % Recorre cada grado de libertad
            m_prev = false; % Ya se sumo
            for i = 1:ng
                [m, mt, mf] = norm_spectrogram(t, a_c(gdl(i), :), r.maxFreq, r.normalize, ...
                    r.windowTime, r.windowTimeMovement);
                if ~m_prev % No se ha ejecutado el analisis
                    mSum = m;
                    m_prev = true;
                else
                    mSum = mSum + m;
                end
            end % for i
            mSum = mSum ./ ng;
            
            fig_title = sprintf('%s %s - Espectrograma normalizado', ...
                ctitle, carga.obtenerEtiqueta());
            plt = figure('Name', fig_title, 'NumberTitle', 'off');
            movegui(plt, 'center');
            hold on;
            
            % Dibuja el fondo
            % pcolor(mt, mf, mSum);
            surf(mt, mf, mSum); % Usamos surf mejor ya que es en 3D
            shading flat; % flat, interp
            colorbar;
            
            % Agrega contorno
            if ~isempty(r.contour)
                [~, h] = contour(mt, mf, mSum, r.contour);
                h.LineWidth = 0.5;
                h.LineColor = 'red';
            end
            
            hold off;
            ylabel('Frecuencia (Hz)');
            xlabel('Tiempo (s)');
            xlim([0, mt(end)]);
            ylim([0, mf(end)]);
            title({fig_title, ''});
            
            % Finaliza proceso
            fprintf('\tProceso finalizado en %.2f segundos\n', etime(clock, tinicial));
            dispMetodoTEFAME();
            
        end % plotEspectrogramaNormalizado function
        
        function calcularIdentificacionNL(obj, carga, nodo, direccionCarga, varargin)
            % calcularIdentificacionNL: calcula identificacion no lineal
            %
            % Parametros opcionales:
            %   betalim                 Limite inferior/superior amortiguamiento (2x1)
            %   betaRayleigh            Los amortiguamientos los calcula con Rayleigh
            %   functionTolerance       Tolerancia maxima (lsqnonlin)
            %   maxFunctionEvaluations  Numero maximo de evaluaciones (lsqnonlin)
            %   nmodos                  Numero de modos de analisis
            %   rholim                  Limite inferior/superior amplitud modo (2x1)
            %   thetalim                Limite inferior/superior fase (2x1)
            %   unidadL                 Unidad longitud
            %   wlim                    Limite inferior/superior frecuencia (2x1)
            
            % Inicia proceso
            tinicial = clock;
            fprintf('Identificacion no lineal:\n');
            
            % Verifica que el vector de nodos sea un cell
            if ~isa(nodo, 'Nodo')
                error('El objeto nodo no es de clase Nodo');
            end
            
            % Verifica que la direccion sea correcta
            if sum(direccionCarga) ~= 1
                error('Direccion carga invalida');
            end
            if ~verificarVectorDireccion(direccionCarga, nodo.obtenerNumeroGDL())
                error('Vector direccion carga mal definido');
            end
            
            % Recorre parametros opcionales
            p = inputParser;
            p.KeepUnmatched = true;
            addOptional(p, 'betalim', [0, Inf]);
            addOptional(p, 'betaRayleigh', true);
            addOptional(p, 'functionTolerance', 1e-9);
            addOptional(p, 'maxFunctionEvaluations', 3000);
            addOptional(p, 'nmodos', 4);
            addOptional(p, 'rholim', [-Inf, Inf]);
            addOptional(p, 'thetalim', [-Inf, Inf]);
            addOptional(p, 'unidadL', 'm');
            addOptional(p, 'wlim', [0, Inf]);
            parse(p, varargin{:});
            r = p.Results;
            
            % Verifica variables
            r.nmodos = floor(r.nmodos);
            if r.nmodos > obj.numModos
                error('Numero modos excede el analisis');
            end
            if length(r.rholim) ~= 2 || length(r.thetalim) ~= 2 || ...
                    length(r.betalim) ~= 2 || length(r.wlim) ~= 2
                error('Parametros opcionales deben ser vectores de dos componentes');
            end
            
            % Ordena los limites
            r.rholim = sort(r.rholim);
            r.thetalim = sort(r.thetalim);
            r.betalim = sort(r.betalim);
            r.wlim = sort(r.wlim);
            
            % Obtiene desplazamiento de la carga
            despl = carga.obtenerDesplazamiento();
            [nr, ~] = size(despl);
            
            % Obtiene el gdl de analisis del nodo
            ngd = nodo.obtenerGDLIDCondensado();
            gdl = 0;
            for i = 1:length(direccionCarga)
                if direccionCarga(i) == 1
                    gdl = ngd(i);
                end
            end % for i
            if gdl == 0
                error('No se ha obtenido el GDLID del nodo, es posible que corresponda a un apoyo o bien que el grado de libertad fue condensado');
            end
            if gdl > nr
                error('El GDLID excede al soporte del sistema');
            end
            
            % Obtiene el desplazamiento de grado de libertad obtenido
            despl = despl(gdl, :)';
            t = linspace(0, carga.tAnalisis, length(despl))';
            
            % Obtengo el amortiguamiento y las frecuencias de los modos requeridos
            beta = zeros(r.nmodos, 1);
            omega = obj.wn(1:r.nmodos);
            
            for i = 1:r.nmodos
                beta(i) = obj.calcularAmortiguamientoModo(i, r.betaRayleigh);
            end % for i
            
            % Llamamos a la funcion
            fprintf('\tOptimizando funcion\n');
            [xo, xf, dfit, J] = NLFIT(despl, t, omega, beta, r.nmodos, r.rholim, r.thetalim, ...
                r.betalim, r.wlim, 'maxFunctionEvaluations', r.maxFunctionEvaluations, ...
                'functionTolerance', r.functionTolerance);
            
            % Tabula los valores iniciales y finales de las iteraciones
            fprintf('\tValores iniciales de la optimizacion:\n');
            obj.tabularAnalisisIdentificacionNL(xo);
            
            fprintf('\tValores finales de la optimizacion:\n');
            obj.tabularAnalisisIdentificacionNL(xf);
            
            % Genera graficos
            fig_title = 'Respuesta de Desplazamiento Real';
            plt = figure('Name', fig_title, 'NumberTitle', 'off');
            movegui(plt, 'center');
            hold on;
            plot(t, despl, 'b');
            title({fig_title, ''});
            xlabel('Tiempo (s)');
            ylabel(sprintf('Desplazamiento (%s)', r.unidadL));
            grid on;
            grid minor;
            
            fig_title = 'Respuesta de Desplazamiento Ajustada';
            plt = figure('Name', fig_title, 'NumberTitle', 'off');
            movegui(plt, 'center');
            hold on;
            plot(t, dfit, 'r');
            title({fig_title, ''});
            xlabel('Tiempo (s)');
            ylabel(sprintf('Desplazamiento (%s)', r.unidadL));
            grid on;
            grid minor;
            
            fig_title = 'Respuesta de Desplazamiento';
            plt = figure('Name', fig_title, 'NumberTitle', 'off');
            movegui(plt, 'center');
            hold on;
            plot(t, despl, 'b');
            plot(t, dfit, 'r--');
            title({fig_title, ''});
            xlabel('Tiempo (s)');
            ylabel(sprintf('Desplazamiento (%s)', r.unidadL));
            legend('Real', 'Ajustada');
            grid on;
            grid minor;
            
            fig_title = 'Historial de Error';
            plt = figure('Name', fig_title, 'NumberTitle', 'off');
            movegui(plt, 'center');
            hold on;
            plot(t, J, 'b');
            title({fig_title, ''});
            xlabel('Tiempo (s)');
            ylabel(sprintf('Funcion de error J (%s)', r.unidadL));
            grid on;
            grid minor;
            
            % Finaliza proceso
            fprintf('\tProceso finalizado en %.2f segundos\n', etime(clock, tinicial));
            dispMetodoTEFAME();
            
        end % calcularIdentificacionNL function
        
        function calcularPSDCarga(obj, carga, nodos, direccionCarga, varargin)
            % calcularPSDCarga: permite el calculo del PSD de la
            % aceleracion, obteniendo los periodos de la estructura. El
            % metodo se entiende como una aproximacion al calculo
            % experimental y no pretende reemplazar a los periodos
            % obtenidos del calculo modal espectral
            %
            % Si se desea obtener los periodos a partir del analisis de
            % senales de un registro de aceleracion para distintos grados
            % de libertad se recomienda seguir la metodologia planteada por
            % este metodo para el caso FFT
            %
            % Parametros opcionales:
            %   betaFFT         El amortiguamiento se calcula con FFT en vez de PSD
            %   betaLineWidth   Ancho de linea de los graficos de amortiguamiento
            %   betaPlot        Grafica el calculo del amortiguamiento de cada modo
            %   betaPlotComp    Grafico amortiguamiento modal comparado con el real
            %   betaRayleigh    Los amortiguamientos los calcula con Rayleigh
            %   closeAll        Cierra todos los graficos antes del analisis
            %   fase            Realiza analisis de fases
            %   faseNodos       Nodos en los que se realiza la fase
            %   faseTlim        Limites periodo grafico fase
            %   fftLim          Limite de frecuencia en grafico FFT
            %   fftMeanStd      Grafica el promedio y desviacion estandar para FFT
            %   fftPlot         Muestra el grafico de la FFT simple
            %   filtMod         Realiza analisis de filtros
            %   filtNodo        Nodos de analisis de filtros
            %   filtRange       Rango de cada peak considerado en el analisis del filtro
            %   filtTlim        Limite periodo grafico filtros
            %   formaModal      Vector con periodos a graficar de las formas modales
            %   formaModalComp  Comparacion formas modales con las teoricas
            %   formaModalDir   Vector direccion de analisis formas modales (x,y,z)
            %   formaModalError Grafico error forma modal con la teorica
            %   formaModalLeg   Muestra la leyenda de las formas modales
            %   formaModalLw    Ancho de linea formas modales
            %   formaModalMark  Muestra un marcador en cada nodo de las formas modales
            %   formaModalMz    Tamano marcador nodo en formas modales
            %   formaModalPlot  Grafico de las formas modales
            %   legend          Muestra la leyenda
            %   legendloc       Ubicacion de la leyenda
            %   maxPeaks        Numero de peaks maximos calculados
            %   peakMinDistance Distancia minima entre peaks requerida
            %   peaksFFT        El calculo de peaks de periodos es con FFT en vez de PSD
            %   peaksT          Grafica los peaks
            %   peaksTComp      Grafico comparacion peaks teorico y FFT
            %   peaksTError     Error peaks periodos con respecto al teorico
            %   psdMeanStd      Grafica el promedio y desviacion estandar para PSD
            %   psdPlot         Grafica el PSD por cada frecuencia
            %   tmax            Tiempo maximo de analisis
            %   tmin            Tiempo minimo de analisis
            %   tukeywinr       Factor de la ventana de tukey
            %   unidadL         Unidad longitud
            %   zeroFill        Indica relleno de ceros para FFT
            
            % Inicia proceso
            tinicial = clock;
            
            % Verifica que el vector de nodos sea un cell
            if ~iscell(nodos)
                error('Nodos debe ser un cell de nodos');
            end
            for k = 1:length(nodos)
                if ~isa(nodos{k}, 'Nodo')
                    error('Elemento %d del cell de nodos no es de clase Nodo', k);
                end
            end % for k
            
            % Verifica que la direccion sea correcta
            if sum(direccionCarga) ~= 1
                error('Direccion carga invalida');
            end
            if ~verificarVectorDireccion(direccionCarga, nodos{1}.obtenerNumeroGDL())
                error('Vector direccion carga mal definido');
            end
            
            % Recorre parametros opcionales
            p = inputParser;
            p.KeepUnmatched = true;
            addOptional(p, 'betaFFT', true);
            addOptional(p, 'betaLineWidth', 1.75);
            addOptional(p, 'betaPlot', false);
            addOptional(p, 'betaPlotComp', false);
            addOptional(p, 'betaRayleigh', true);
            addOptional(p, 'closeAll', false);
            addOptional(p, 'fase', false);
            addOptional(p, 'faseNodos', []);
            addOptional(p, 'faseTlim', [0, 1]);
            addOptional(p, 'fftLim', 0);
            addOptional(p, 'fftMeanStd', false);
            addOptional(p, 'fftPlot', false);
            addOptional(p, 'filtMod', []);
            addOptional(p, 'filtNodo', {});
            addOptional(p, 'filtRange', 0.2);
            addOptional(p, 'filtTlim', [0, 1]);
            addOptional(p, 'formaModal', []);
            addOptional(p, 'formaModalColorFactor', 2.5);
            addOptional(p, 'formaModalComp', false);
            addOptional(p, 'formaModalDir', [0, 0, 0]); % Puede ser [0, 1, 0] (y)
            addOptional(p, 'formaModalError', false);
            addOptional(p, 'formaModalErrorLegPos', 'best');
            addOptional(p, 'formaModalErrorStdLegPos', 'best');
            addOptional(p, 'formaModalLeg', true);
            addOptional(p, 'formaModalLegPos', 'best');
            addOptional(p, 'formaModalLw', 1.5);
            addOptional(p, 'formaModalMark', true);
            addOptional(p, 'formaModalMz', 5);
            addOptional(p, 'formaModalPlot', true);
            addOptional(p, 'legend', false);
            addOptional(p, 'legendloc', 'best');
            addOptional(p, 'maxPeaks', -1); % El maximo se ajusta al dato
            addOptional(p, 'peakMinDistance', 0.5); % Requerido para el calculo
            addOptional(p, 'peaksFFT', false); % El calculo de peaks es con FFT o PSD
            addOptional(p, 'peaksT', false);
            addOptional(p, 'peaksTComp', false);
            addOptional(p, 'peaksTCompErrorBar', true); % Nucleo, no se busca que se use en produccion
            addOptional(p, 'peaksTError', false);
            addOptional(p, 'psdMeanStd', false);
            addOptional(p, 'psdPlot', false);
            addOptional(p, 'tmax', -1);
            addOptional(p, 'tmin', 0);
            addOptional(p, 'tukeywinr', 0.01);
            addOptional(p, 'unidadL', 'm');
            addOptional(p, 'zeroFill', 0);
            parse(p, varargin{:});
            r = p.Results;
            
            % Cierra los graficos
            if r.closeAll
                close all;
            end
            
            % Obtiene las variables
            a_c = carga.obtenerAceleracion();
            
            % Verifica que la carga se haya calculado
            if ~(isa(carga, 'CargaDinamica') || isa(carga, 'CombinacionCargas'))
                error('Solo se pueden graficar cargas dinamicas o combinaciones de cargas');
            end
            if ~carga.cargaCalculada()
                error('La carga %s no se ha calculado', carga.obtenerEtiqueta());
            end
            cargaFS = floor(1/carga.dt);
            
            fprintf('Calculando trayectoria nodos:\n');
            % fprintf('\tNodos: ');
            
            % Imprime en consola los principales valores del analisis
            if ~isempty(direccionCarga)
                s = arrayIntNum2str(direccionCarga);
                fprintf('\tDireccion carga:\t\t%s\n', [s{:}]);
            end
            if ~isempty(r.formaModalDir)
                s = arrayIntNum2str(r.formaModalDir);
                fprintf('\tDireccion forma modal:\t%s\n', [s{:}]);
            end
            if ~isempty(r.formaModal)
                s = arrayIntNum2str(r.formaModal);
                if length(s) <= 10
                    fprintf('\tFormas modales:\t\t\t%s\n', [s{:}]);
                end
            else
                fprintf('\tNo se graficaran formas modales\n');
            end
            if r.maxPeaks ~= -1
                fprintf('\tMaximos peaks a mostrar: %d\n', r.maxPeaks');
            end
            
            s = '';
            ng = length(nodos);
            for k = 1:ng
                s = strcat(s, strcat(' ', nodos{k}.obtenerEtiqueta()));
                if k < ng
                    s = strcat(s, ', ');
                end
            end % for k
            ctitle = obj.imprimirPropiedadesAnalisisCarga(carga);
            [nr, ~] = size(a_c);
            
            % Verifica que la direccion sea correcta
            gdl = zeros(1, ng);
            for k = 1:ng
                % Elige al nodo
                ngd = nodos{k}.obtenerGDLIDCondensado();
                for i = 1:length(direccionCarga)
                    if direccionCarga(i) == 1
                        gdl(k) = ngd(i);
                    end
                end % for i
                if gdl(k) == 0
                    error('No se ha obtenido el GDLID del nodo, es posible que corresponda a un apoyo o bien que el grado de libertad fue condensado');
                end
                if gdl(k) > nr
                    error('El GDLID excede al soporte del sistema');
                end
            end % for k
            
            % Crea la leyenda de los nodos
            legnodos = cell(1, ng);
            for k = 1:ng
                legnodos{k} = nodos{k}.obtenerEtiqueta();
            end % for k
            
            % Verifica frecuencia de analisis
            if r.fftLim <= 0
                error('El limite de frecuencia no puede ser negativo o nulo');
            end
            
            % Verifica que el numero de peaks sea adecuado
            if r.maxPeaks == 0
                error('No puede haber un numero de peaks negativo o nulo');
            end
            r.maxPeaks = floor(r.maxPeaks);
            if r.peakMinDistance <= 0
                error('Distancia no puede ser menor o igual a cero');
            end
            
            % Verifica que el tiempo de analisis sea adecuado
            if r.tmax < 0
                r.tmax = carga.tAnalisis;
            end
            if r.tmax > carga.tAnalisis
                error('El tiempo de analisis no puede exceder el tiempo de la carga (%.1f)', carga.tAnalisis);
            elseif r.tmax < carga.tAnalisis
                fprintf('\tEl analisis se realizara con un tiempo menor al de la carga (%.1f%% menor)\n', ...
                    100*(carga.tAnalisis - r.tmax)/carga.tAnalisis);
            end
            
            % Calcula el PSD del registro, ello incluye la FFT, los peaks
            % asociados a cada periodo y las formas modales y los amortiguamientos
            fprintf('\tCalculando PSD del registro\n');
            [f, psd, fft, fftcomp, envFormaModal, tlocMean, tlocStd, locMean, ...
                ~, ~, maxlocs, pks, beta, betaFreq, fftmean, fftstd, psdmean, psdstd] = ...
                PSD(a_c, cargaFS, gdl, 'peakMinDistance', r.peakMinDistance, ...
                'tukeywinr', r.tukeywinr, 'zeroFill', r.zeroFill, ...
                'betaFFTMax', true, 'tmax', r.tmax, 'tmin', r.tmin, ...
                'peakFFT', r.peaksFFT, 'betaFFT', r.betaFFT);
            
            % Actualiza por el numero de modos del sistema
            maxlocs = min(maxlocs, obj.numModos);
            
            % Tabla de periodos
            maxlocsDisp = maxlocs; % Puntos a mostrar
            if r.maxPeaks > 0
                maxlocsDisp = min(maxlocs, r.maxPeaks);
            end
            
            % Grafica la fft de cada nodo
            if r.fftPlot
                
                fig_title = sprintf('%s %s - Analisis FFT', ...
                    ctitle, carga.obtenerEtiqueta());
                plt = figure('Name', fig_title, 'NumberTitle', 'off');
                movegui(plt, 'center');
                hold on;
                for i = 1:ng
                    plot(f, fft{i}, '-');
                end % for i
                
                % Grafica el promedio y desviacion estandar
                if r.fftMeanStd
                    plot(f, fftmean, 'k-', 'lineWidth', 2);
                    plot(f, fftmean+fftstd, 'k--', 'lineWidth', 1);
                    plot(f, fftmean-fftstd, 'k--', 'lineWidth', 1);
                end
                
                ylabel('FFT');
                xlabel('Frecuencia (Hz)');
                title({fig_title, ''});
                if r.fftLim == 0
                    xlim([0, max(f)]);
                else
                    xlim([0, r.fftLim]);
                end
                ylim([0, max(get(gca, 'ylim'))]);
                grid on;
                if r.legend
                    legend(legnodos, 'location', r.legendloc);
                end
                
            end % fftPlot
            
            % Grafica el PSD por cada nodo
            if r.psdPlot
                
                fig_title = sprintf('%s %s - Analisis PSD', ...
                    ctitle, carga.obtenerEtiqueta());
                plt = figure('Name', fig_title, 'NumberTitle', 'off');
                movegui(plt, 'center');
                hold on;
                for i = 1:ng
                    plot(f, psd{i}, '-');
                end % for i
                
                % Grafica el promedio y desviacion estandar
                if r.psdMeanStd
                    plot(f, psdmean, 'k-', 'lineWidth', 3);
                    plot(f, psdmean+psdstd, 'k--', 'lineWidth', 1.5);
                    plot(f, psdmean-psdstd, 'k--', 'lineWidth', 1.5);
                end
                
                ylabel('PSD');
                xlabel('Frecuencia (Hz)');
                title({fig_title, ''});
                if r.fftLim == 0
                    xlim([0, max(f)]);
                else
                    xlim([0, r.fftLim]);
                end
                ylim([0, max(get(gca, 'ylim'))]);
                grid on;
                if r.legend
                    legend(legnodos, 'location', r.legendloc);
                end
                
            end % psdPlot
            
            % Imprime en consola la tabla de los peaks
            peakMethod = 'FFT';
            if ~r.peaksFFT
                peakMethod = 'PSD';
            end
            fprintf('\tAnalisis de peaks (%s), periodos formas modales:\n', peakMethod);
            fprintf('\t\t|\tN\t|\tT peak\t\t\t|\tT modal\t|\t%%Error\t|\n');
            fprintf('\t\t-----------------------------------------------------\n');
            errorPeriodoPeaks = zeros(1, maxlocsDisp);
            for i = 1:maxlocsDisp
                err = 100 * (tlocMean(i) - obj.Tn(i)) / obj.Tn(i);
                if err > 0
                    s = '+';
                else
                    s = '';
                end
                fprintf('\t\t|\t%d\t|\t%.3f +- %.3f\t|\t%.3f\t|\t%s%.2f\t|\n', ...
                    i, tlocMean(i), tlocStd(i), obj.Tn(i), s, err);
                errorPeriodoPeaks(i) = err;
            end % for i
            fprintf('\t\t-----------------------------------------------------\n');
            
            % Grafica periodo obtenido con analisis modal y analisis de
            % peaks de la FFT
            if r.peaksTComp
                
                fig_title = sprintf('%s %s - Comparacion periodo %s y analisis modal espectral', ...
                    ctitle, carga.obtenerEtiqueta(), peakMethod);
                plt = figure('Name', fig_title, 'NumberTitle', 'off');
                movegui(plt, 'center');
                hold on;
                
                % Grafica periodos PSD
                gc = plot(1:maxlocsDisp, tlocMean(1:maxlocsDisp), '-', 'lineWidth', 1.5);
                c = get(gc, 'Color');
                if r.peaksTCompErrorBar
                    pl = errorbar(1:maxlocsDisp, tlocMean(1:maxlocsDisp), ...
                        tlocStd(1:maxlocsDisp).*3, '-', 'color', c);
                    set(get(get(pl, 'Annotation'), 'LegendInformation'), 'IconDisplayStyle', 'off');
                else
                    pl = plot(1:maxlocsDisp, tlocMean(1:maxlocsDisp)+tlocStd(1:maxlocsDisp).*3, ...
                        '--', 'color', c, 'lineWidth', 1);
                    set(get(get(pl, 'Annotation'), 'LegendInformation'), 'IconDisplayStyle', 'off');
                    pl = plot(1:maxlocsDisp, tlocMean(1:maxlocsDisp)-tlocStd(1:maxlocsDisp).*3, ...
                        '--', 'color', c, 'lineWidth', 1);
                    set(get(get(pl, 'Annotation'), 'LegendInformation'), 'IconDisplayStyle', 'off');
                end
                pl = plot(1:maxlocsDisp, tlocMean(1:maxlocsDisp), '^', 'markerSize', 2.5, ...
                    'color', c, 'markerfacecolor', c);
                set(get(get(pl, 'Annotation'), 'LegendInformation'), 'IconDisplayStyle', 'off');
                
                % Grafica periodos modal espectral
                gc = plot(1:maxlocsDisp, obj.Tn(1:maxlocsDisp), '-', 'lineWidth', 1.5);
                c = get(gc, 'Color');
                pl = plot(1:maxlocsDisp, obj.Tn(1:maxlocsDisp), '^', 'markerSize', 2.5, ...
                    'color', c, 'markerfacecolor', c);
                set(get(get(pl, 'Annotation'), 'LegendInformation'), 'IconDisplayStyle', 'off');
                
                xlabel('Modo');
                ylabel('Periodo (s)');
                title({sprintf('Comparacion periodo peaks %s y analisis modal espectral', peakMethod), ''});
                xlim([1, maxlocsDisp]);
                legend({sprintf('Periodo analisis %s (\\pm3\\sigma)', peakMethod), 'Periodo modal espectral'}, ...
                    'location', 'northeast');
                grid on;
                grid minor;
                
            end % peaksTComp
            
            % Grafica la diferencia de los peaks con el modelo teorico
            if r.peaksTError
                
                fig_title = sprintf('%s %s - Error periodos %s por cada modo', ...
                    ctitle, carga.obtenerEtiqueta(), peakMethod);
                plt = figure('Name', fig_title, 'NumberTitle', 'off');
                movegui(plt, 'center');
                hold on;
                gc = plot(1:maxlocsDisp, errorPeriodoPeaks, '-', 'lineWidth', 1.5);
                c = get(gc, 'Color');
                pl = plot(1:maxlocsDisp, errorPeriodoPeaks, '^', 'markerSize', 4, ...
                    'color', c, 'markerfacecolor', c);
                set(get(get(pl, 'Annotation'), 'LegendInformation'), 'IconDisplayStyle', 'off');
                drawVyLine(0, 'k--', 0.5);
                grid on;
                grid minor;
                xlim([1, maxlocsDisp]);
                title({'Error periodos FFT por cada modo', ''});
                xlabel('Modo');
                ylabel('Error entre periodos (%)');
                
            end % peaksTError
            
            % Grafica los peaks
            if r.peaksT
                
                % Grafico de peaks
                fig_title = sprintf('%s %s - Analisis %s peaks', ...
                    ctitle, carga.obtenerEtiqueta(), peakMethod);
                plt = figure('Name', fig_title, 'NumberTitle', 'off');
                movegui(plt, 'center');
                hold on;
                
                for i = 1:ng % Recorre cada nodo
                    if r.peaksFFT
                        plot(f, fft{i}, '-');
                    else
                        plot(f, psd{i}, '-');
                    end
                end % for i
                
                % Limita los peaks
                locMeanL = locMean(1:maxlocsDisp);
                pksL = pks(1:maxlocsDisp);
                text(locMeanL.*1.05, pksL.*1.0, num2str((1:numel(pksL))'));
                plot(locMeanL, pksL, 'r^', 'markerfacecolor', [1, 0, 0]);
                ylabel(peakMethod);
                xlabel('Frecuencia (Hz)');
                title({fig_title, ''});
                if r.fftLim == 0
                    xlim([0, max(f)]);
                else
                    xlim([0, r.fftLim]);
                end
                ylim([0, max(get(gca, 'ylim'))]);
                grid on;
                
            end % peaksT
            
            % Calcula el amortiguamiento del modo
            lbeta = min(min(length(beta), obj.numModos), maxlocsDisp);
            betaModo = zeros(1, lbeta);
            betaError = zeros(1, lbeta);
            for i = 1:lbeta
                betaModo(i) = obj.calcularAmortiguamientoModo(i, r.betaRayleigh);
                betaError(i) = 100 * (betaModo(i) - beta(i)) / betaModo(i);
            end
            
            % Amortiguamientos
            betaMethod = 'FFT';
            if ~r.betaFFT
                betaMethod = 'PSD';
            end
            fprintf('\tAmortiguamiento por periodos (%s):\n', betaMethod);
            fprintf('\t\t|\tN\t|\tBeta\t|\tBeta modal\t|\t%% Error\t\t|\n');
            fprintf('\t\t-----------------------------------------------------\n');
            for i = 1:maxlocsDisp
                if isempty(betaFreq{i}) % Si no se encontro el modo retorna
                    continue;
                end
                if betaError(i) > 0
                    s = '+';
                else
                    s = '';
                end
                fprintf('\t\t|\t%d\t|\t%.3f\t|\t%.3f\t\t|\t%s%.2f\t\t|\n', ...
                    i, beta(i), betaModo(i), s, betaError(i));
            end % for i
            fprintf('\t\t-----------------------------------------------------\n');
            
            % Grafica los limites de las frecuencias
            if r.betaPlot
                
                % Crea la figura del amortiguamiento en cada FFT
                fig_title = sprintf('%s %s - Calculo de amortiguamientos %s', ...
                    ctitle, carga.obtenerEtiqueta(), betaMethod);
                plt = figure('Name', fig_title, 'NumberTitle', 'off');
                movegui(plt, 'center');
                hold on;
                
                for i = 1:ng % Recorre cada nodo
                    if r.betaFFT
                        plot(f, fft{i}, '-');
                    else
                        plot(f, psd{i}, '-');
                    end
                end % for i
                
                for i = 1:maxlocsDisp
                    if isempty(betaFreq{i})
                        continue;
                    end
                    gc = plot([betaFreq{i}(1), betaFreq{i}(1)], [0, betaFreq{i}(4)], ...
                        '-', 'lineWidth', r.betaLineWidth);
                    c = get(gc, 'Color');
                    plot([betaFreq{i}(2), betaFreq{i}(2)], [0, betaFreq{i}(4)], ...
                        '-', 'lineWidth', r.betaLineWidth, 'color', c);
                    plot([betaFreq{i}(1), betaFreq{i}(2)], [betaFreq{i}(4), betaFreq{i}(4)], ...
                        '-', 'lineWidth', r.betaLineWidth, 'color', c);
                    plot(betaFreq{i}(3), betaFreq{i}(4), '^', 'markerSize', 5, ...
                        'markerfacecolor', c, 'color', c);
                    text(betaFreq{i}(3).*1.05, betaFreq{i}(4).*1.0, num2str(i));
                end % for i
                
                ylabel(betaMethod);
                xlabel('Frecuencia (Hz)');
                title({fig_title, ''});
                if r.fftLim == 0
                    xlim([0, max(f)]);
                else
                    xlim([0, r.fftLim]);
                end
                ylim([0, max(get(gca, 'ylim'))]);
                grid on;
                grid minor;
                
            end % betaPlot
            
            % Crea la curva de variacion del amortiguamiento por cada modo
            if r.betaPlotComp
                
                % Grafico error amortiguamiento modal
                fig_title = sprintf('%s %s - Error en amortiguamiento modal', ...
                    ctitle, carga.obtenerEtiqueta());
                plt = figure('Name', fig_title, 'NumberTitle', 'off');
                movegui(plt, 'center');
                hold on;
                gc = plot(1:lbeta, betaError(1:lbeta), '-', 'lineWidth', 1.5);
                c = get(gc, 'Color');
                pl = plot(1:lbeta, betaError(1:lbeta), '^', 'markerSize', 4, ...
                    'color', c, 'markerfacecolor', c);
                set(get(get(pl, 'Annotation'), 'LegendInformation'), 'IconDisplayStyle', 'off');
                xlabel('Modo');
                ylabel('Error amortiguamiento (%)');
                title({'Error amortiguamiento \beta modal', ''});
                if min(betaError) < 0
                    drawVyLine(0, 'k--', 0.5);
                end
                % set(gca, 'XTick', 1:lbeta);
                xlim([1, lbeta]);
                grid on;
                grid minor;
                xTickInteger();
                
                % Grafico amortiguamiento por cada modo, compara tanto el
                % teorico como el obtenido con psd
                fig_title = sprintf('%s %s - Grafico de amortiguamiento modal', ...
                    ctitle, carga.obtenerEtiqueta());
                plt = figure('Name', fig_title, 'NumberTitle', 'off');
                movegui(plt, 'center');
                hold on;
                
                % Grafico obtenido por el metodo psd
                gc = plot(1:lbeta, beta(1:lbeta), '-', 'lineWidth', 1.5);
                c = get(gc, 'Color');
                pl = plot(1:lbeta, beta(1:lbeta), '^', 'markerSize', 4, ...
                    'color', c, 'markerfacecolor', c);
                set(get(get(pl, 'Annotation'), 'LegendInformation'), 'IconDisplayStyle', 'off');
                
                % Grafico real del modelo teorico
                gc = plot(1:lbeta, betaModo(1:lbeta), '-', 'lineWidth', 1.5);
                c = get(gc, 'Color');
                pl = plot(1:lbeta, betaModo(1:lbeta), '^', 'markerSize', 2, ...
                    'color', c, 'markerfacecolor', c);
                set(get(get(pl, 'Annotation'), 'LegendInformation'), 'IconDisplayStyle', 'off');
                
                xlabel('Modo');
                ylabel('Amortiguamiento (%)');
                title({'Amortiguamiento \beta modal', ''});
                legend({'\beta Teorico', sprintf('\\beta %s', betaMethod)}, 'location', 'northwest');
                % set(gca, 'XTick', 1:lbeta);
                xlim([1, lbeta]);
                grid on;
                grid minor;
                xTickInteger();
                
            end % betaPlotComp
            
            % Vector de modos a graficar
            r.formaModal = sort(r.formaModal);
            formaModalLeg = cell(1, length(r.formaModal)); % Contiene las leyendas de los modos elegidos
            for i = 1:length(r.formaModal)
                r.formaModal(i) = floor(r.formaModal(i));
                if r.formaModal(i) <= 0
                    error('Forma modal %d no puede ser inferior o igual a cero', r.formaModal(i));
                end
                if r.formaModal(i) > maxlocs
                    error('Forma modal %d excede las obtenidas del analisis (%d)', r.formaModal(i), maxlocs);
                end
                formaModalLeg{i} = sprintf('Modo %d', r.formaModal(i));
            end % for i
            plotFormaModal = ~isempty(r.formaModal);
            
            % Grafica la envolvente de la forma modal
            if plotFormaModal
                
                % Verifica que la direccion sea correcta
                if sum(r.formaModalDir) ~= 1
                    error('Direccion forma modal invalida');
                end
                if ~verificarVectorDireccion(r.formaModalDir, nodos{1}.obtenerNumeroGDL())
                    error('Vector direccion carga mal definido');
                end
                
                % Verifica que la direccion sea correcta, crea tambien el
                % vector de la direccion de la forma modal
                xModal = zeros(1, ng);
                for k = 1:ng
                    for i = 1:length(r.formaModalDir)
                        if r.formaModalDir(i) == 1
                            coords = nodos{k}.obtenerCoordenadas();
                            xModal(k) = coords(i);
                        end
                    end % for i
                end % for k
                if r.formaModalDir(1) == 1
                    dirForma = 'X';
                elseif r.formaModalDir(2) == 1
                    dirForma = 'Y';
                else
                    dirForma = 'Z';
                end
                dirForma = sprintf('%s (%s)', dirForma, r.unidadL);
                
                % Si hay elementos repetidos
                if length(xModal) ~= length(unique(xModal))
                    error('El vector de distancias modal posee elementos repetidos, es posible que la direccion de analisis no sea la apropiada');
                end
                
                % Crea las formas modales teoricas si aplica
                envFormaModalTeorica = cell(1, length(r.formaModal));
                formaModalLegComp = cell(1, 2*length(r.formaModal));
                formaModalLegError = cell(1, length(r.formaModal));
                envFormaModalError = cell(1, length(r.formaModal));
                formaModalMaxError = 0;
                
                if r.formaModalComp
                    for i = 1:length(r.formaModal)
                        envFormaModalTeorica{i} = obj.phin(:, r.formaModal(i));
                        
                        % Filtra los gdl de analisis
                        envFormaModalTeorica{i} = abs(envFormaModalTeorica{i}(gdl));
                        
                        % Normaliza
                        envTMax = max(envFormaModalTeorica{i});
                        envFormaModalTeorica{i} = envFormaModalTeorica{i} ./ envTMax;
                        
                        % Calcula el error
                        envFormaModalError{i} = zeros(1, ng);
                        for j = 1:ng
                            envFormaModalError{i}(j) = envFormaModalTeorica{i}(j) - envFormaModal{i}(j);
                            
                            % Calcula el largo de la forma modal, que es el
                            % la distancia maxima entre 0 y 1
                            formaModalLargo = max(envFormaModal{i}(j), 1-envFormaModal{i}(j));
                            envFormaModalError{i}(j) = 100 * envFormaModalError{i}(j) / formaModalLargo;
                        end % for j
                        formaModalLegError{i} = sprintf('Error forma modal %d', r.formaModal(i));
                        formaModalMaxError = max(formaModalMaxError, max(abs(envFormaModalError{i})));
                        
                        % Crea la leyenda para el modo i
                        formaModalLegComp{2*i-1} = formaModalLeg{i};
                        formaModalLegComp{2*i} = sprintf('Forma modal %d teorica', r.formaModal(i));
                    end
                    formaModalLeg = formaModalLegComp; % Cambia la leyenda
                end
                
                % Calcula el error estadistico por todos los modos
                formaModalErrorMean = zeros(1, ng);
                formaModalErrorStd = zeros(1, ng);
                for i = 1:ng
                    ngdata = zeros(1, length(r.formaModal));
                    for j = 1:length(r.formaModal)
                        ngdata(j) = envFormaModalError{j}(i); % Error del modo j en el gdl i
                    end
                    formaModalErrorMean(i) = mean(ngdata);
                    formaModalErrorStd(i) = std(ngdata);
                end
                
                % Calcula el error por cada modo
                formaModalErrorModoMean = zeros(1, length(r.formaModal));
                formaModalErrorModoStd = zeros(1, length(r.formaModal));
                for i = 1:length(r.formaModal)
                    formaModalErrorModoMean(i) = mean(envFormaModalError{i});
                    formaModalErrorModoStd(i) = std(envFormaModalError{i});
                end
                
                if r.formaModalMz <= 0
                    r.formaModalMark = false;
                end
                
                % Grafica cada una de las formas modales
                if r.formaModalPlot
                    fig_title = sprintf('%s %s - Formas modales FFT', ...
                        ctitle, carga.obtenerEtiqueta());
                    plt = figure('Name', fig_title, 'NumberTitle', 'off');
                    movegui(plt, 'center');
                    hold on;
                    for j = 1:length(r.formaModal)
                        
                        i = r.formaModal(j);
                        if strcmp(dirForma, 'X')
                            x = xModal;
                            xt = xModal;
                            y = envFormaModal{i};
                            yt = envFormaModalTeorica{i};
                        else
                            x = envFormaModal{i};
                            xt = envFormaModalTeorica{i};
                            y = xModal;
                            yt = xModal;
                        end
                        
                        % Grafica la forma modal calculada
                        gc = plot(x, y, '-', 'lineWidth', r.formaModalLw);
                        c = get(gc, 'Color');
                        if r.formaModalMark
                            pl = plot(x, y, '^', 'color', c, ...
                                'markerfacecolor', c, 'markerSize', r.formaModalMz);
                            set(get(get(pl, 'Annotation'), ...
                                'LegendInformation'), 'IconDisplayStyle', 'off');
                        end
                        
                        % Grafica la forma modal teorica si corresponde
                        if r.formaModalComp
                            ct = colorFactor(c, r.formaModalColorFactor);
                            plot(xt, yt, '--', 'color', ct, 'lineWidth', 0.5*r.formaModalLw);
                            if r.formaModalMark
                                pl = plot(xt, yt, '^', 'color', ct, ...
                                    'markerfacecolor', c, 'markerSize', 0.5*r.formaModalMz);
                                set(get(get(pl, 'Annotation'), 'LegendInformation'), ...
                                    'IconDisplayStyle', 'off');
                            end
                        end
                        
                    end % for j
                    
                    title({fig_title, ''});
                    xlim([0, 1]);
                    ylim([0, max(get(gca, 'ylim'))]);
                    grid on;
                    grid minor;
                    ylabel(dirForma);
                    xlabel('Forma modal normalizada');
                    
                    if r.formaModalLeg
                        legend(formaModalLeg, 'location', r.formaModalLegPos, 'FontSize', 6);
                    end
                end % formaModalPlot
                
                % Grafica los errores entre las formas modales
                if r.formaModalError
                    fig_title = sprintf('%s %s - Error porcentual formas modales FFT', ...
                        ctitle, carga.obtenerEtiqueta());
                    plt = figure('Name', fig_title, 'NumberTitle', 'off');
                    movegui(plt, 'center');
                    hold on;
                    
                    for j = 1:length(r.formaModal)
                        
                        i = r.formaModal(j);
                        x = xModal;
                        y = envFormaModalError{i};
                        
                        % Grafica la forma modal calculada
                        gc = plot(x, y, '-', 'lineWidth', r.formaModalLw);
                        c = get(gc, 'Color');
                        if r.formaModalMark
                            pl = plot(x, y, '^', 'color', c, 'markerfacecolor', c, ...
                                'markerSize', r.formaModalMz);
                            set(get(get(pl, 'Annotation'), 'LegendInformation'), 'IconDisplayStyle', 'off');
                        end
                        
                    end % for j
                    
                    % Agrega un eje en cero
                    drawVyLine(0, 'k--', 0.5);
                    
                    title({'Error porcentual formas modales FFT', ''});
                    xlim([min(xModal), max(xModal)]);
                    % ylim([-formaModalMaxError, formaModalMaxError]);
                    grid on;
                    grid minor;
                    xlabel(dirForma);
                    ylabel('Error forma modal (%)');
                    xTickInteger();
                    
                    if r.formaModalLeg
                        legend(formaModalLegError, 'location', r.formaModalErrorLegPos, 'fontSize', 8);
                    end
                    
                    % Genera grafico con promedio y desviacion estandar en
                    % funcion del largo
                    fig_title = sprintf('%s %s - Error porcentual formas modales FFT', ...
                        ctitle, carga.obtenerEtiqueta());
                    plt = figure('Name', fig_title, 'NumberTitle', 'off');
                    movegui(plt, 'center');
                    hold on;
                    
                    gc = plot(xModal, formaModalErrorMean, '-', 'lineWidth', 2);
                    c = get(gc, 'Color');
                    pl = drawVyLine(0, 'k--', 0.5);
                    set(get(get(pl, 'Annotation'), 'LegendInformation'), 'IconDisplayStyle', 'off');
                    plot(xModal, formaModalErrorMean+formaModalErrorStd, ...
                        'k--', 'lineWidth', 1, 'color', c);
                    pl = plot(xModal, formaModalErrorMean-formaModalErrorStd, ...
                        'k--', 'lineWidth', 1, 'color', c);
                    set(get(get(pl, 'Annotation'), 'LegendInformation'), 'IconDisplayStyle', 'off');
                    
                    xlim([min(xModal), max(xModal)]);
                    % ylim([-formaModalMaxError, formaModalMaxError]);
                    grid on;
                    grid minor;
                    xlabel(dirForma);
                    ylabel('Error forma modal (%)');
                    legend({'\mu', '\mu+\sigma'}, 'location', r.formaModalErrorLegPos);
                    title({'Error porcentual formas modales FFT', ''});
                    
                    % Grafico del error promedio en funcion del modo
                    fig_title = sprintf('%s %s - Error porcentual formas modales FFT', ...
                        ctitle, carga.obtenerEtiqueta());
                    plt = figure('Name', fig_title, 'NumberTitle', 'off');
                    movegui(plt, 'center');
                    hold on;
                    
                    gc = plot(r.formaModal, formaModalErrorModoMean, '-', ...
                        'lineWidth', 2);
                    c = get(gc, 'Color');
                    pl = drawVyLine(0, 'k--', 0.5);
                    set(get(get(pl, 'Annotation'), 'LegendInformation'), 'IconDisplayStyle', 'off');
                    plot(r.formaModal, formaModalErrorModoMean+formaModalErrorModoStd, ...
                        '--', 'lineWidth', 1, 'color', c);
                    pl = plot(r.formaModal, formaModalErrorModoMean-formaModalErrorModoStd, ...
                        'k--', 'lineWidth', 1, 'color', c);
                    set(get(get(pl, 'Annotation'), 'LegendInformation'), 'IconDisplayStyle', 'off');
                    xlim([min(r.formaModal), max(r.formaModal)]);
                    
                    % ax = gca;
                    % ax.YGrid = true;
                    % ax.YMinorGrid = true;
                    grid on;
                    grid minor;
                    xlabel('Modo');
                    ylabel('Error forma modal (%)');
                    legend({'\mu', '\mu+\sigma'}, 'location', r.formaModalErrorStdLegPos);
                    title({fig_title, ''});
                    xTickInteger();
                    
                end % formaModalError
                
            end % plotFormaModal
            
            % Realiza el filtrado de modos de la respuesta de aceleracion
            if ~isempty(r.filtMod)
                
                % Imprime en consola la tabla
                fprintf('\tRealiza filtrado de modos\n');
                l_ac = length(a_c);
                
                if r.filtRange <= 0
                    error('Rango del filtro no puede ser nulo o menor a cero');
                end
                
                if ~iscell(r.filtNodo)
                    r.filtNodo = {r.filtNodo};
                end
                for k = 1:length(r.filtNodo)
                    if ~isa(r.filtNodo{k}, 'Nodo')
                        error('Elemento %d del cell de filtNodo no es de clase Nodo', k);
                    end
                end % for k
                
                % Vector de aceleracion del nodo i
                for k = 1:length(r.filtNodo)
                    ngd = r.filtNodo{k}.obtenerGDLIDCondensado();
                    ng = 0; % Numero grado analisis
                    for i = 1:length(direccionCarga)
                        if direccionCarga(i) == 1
                            ng = ngd(i);
                        end
                    end % for i
                    accresp(:, k) = a_c(ng, :)'; %#ok<AGROW>
                end % for k
                
                tuck = tukeywin(length(accresp), r.tukeywinr);
                acc = accresp .* tuck;
                dt = cargaFS^-1;
                t = 0:dt:dt * (length(acc) - 1);
                
                % Crea la figura
                fig_title = sprintf('%s %s - Filtro de modos', ...
                    ctitle, carga.obtenerEtiqueta());
                plt = figure('Name', fig_title, 'NumberTitle', 'off');
                movegui(plt, 'center');
                hold on;
                plot(t, acc(1:l_ac, 1), '-', 'lineWidth', 1.5);
                sumFiltmod = zeros(l_ac, 1);
                legmod{1} = 'Todos los modos';
                
                % Aplica el filtro
                for i = 1:length(r.filtMod)
                    
                    % Rango en frecuencias
                    rangeinf = locMean(i) - r.filtRange;
                    rangesup = locMean(i) + r.filtRange;
                    if i == 1
                        Wn = rangesup(i) / (cargaFS / 2);
                    elseif i > 1
                        Wn = [rangeinf, rangesup] ./ (cargaFS / 2);
                    end
                    
                    [B, A] = butter(4, Wn);
                    Filtmod(:, i) = filtfilt(B, A, acc(1:l_ac, 1)); %#ok<AGROW>
                    sumFiltmod = sumFiltmod + Filtmod(:, i);
                    legmod{i + 1} = sprintf('Modo %s ', num2str(i)); %#ok<AGROW>
                    plot(t, Filtmod(:, i), '-', 'lineWidth', 1);
                    
                end % for i
                legmod{end+1} = 'Suma modos';
                
                % Plot respuesta filtrada
                ylabel(sprintf('Aceleracion (%s/s^2)', r.unidadL));
                xlabel('Periodo (s)');
                title({fig_title, ''});
                plot(t, sumFiltmod, 'k--', 'lineWidth', 1.5);
                xlim(r.filtTlim);
                ylim([-max(get(gca, 'ylim')), max(get(gca, 'ylim'))]);
                grid on;
                grid minor;
                zoom on;
                legend(legmod);
                
            end % filtMod
            
            % Grafica la fase
            if r.fase
                
                % Extrae los fft de los nodos
                faseNodos = sort(r.faseNodos);
                for k = 1:length(faseNodos)
                    if r.faseNodos(k) > length(fftcomp)
                        error('faseNodos %d excede el numero de nodos analizados por la funcion', k);
                    end
                end
                if length(r.faseNodos) ~= 2
                    error('faseNodos debe contener dos elementos');
                end
                for i = 1:length(fftcomp) - 1
                    division(:, i) = fftcomp{i} ./ fftcomp{end}; %#ok<AGROW>
                end % for i
                
                Fftcomp(:, 1) = fftcomp{faseNodos(1)};
                Fftcomp(:, 2) = fftcomp{faseNodos(2)};
                
                % Crea la figura
                fig_title = sprintf('%s %s - Fase de la Transformada', ...
                    ctitle, carga.obtenerEtiqueta());
                plt = figure('Name', fig_title, 'NumberTitle', 'off');
                movegui(plt, 'center');
                hold on;
                subplot(311);
                plot(f, abs(division(:, faseNodos(1))), 'lineWidth', 1.5);
                title('Division FFT - Parte Real');
                xlabel('Frecuencia (Hz)');
                ylabel('FFT');
                grid on;
                grid minor;
                xlim(r.faseTlim);
                
                subplot(312);
                plot(f, angle(division(:, faseNodos(1)))./pi, 'lineWidth', 1.5);
                title('Fase');
                xlabel('Frecuencia (Hz)');
                ylabel('Angulo');
                grid on;
                grid minor;
                xlim(r.faseTlim);
                
                % Modifica los ticks del grafico del angulo
                yTickInteger();
                ytickp = get(gca, 'YTick');
                if length(ytickp) == 3
                    ytick = {'-\pi', '', '\pi'};
                    set(gca, 'YTick', ytickp, 'yticklabel', ytick);
                end
                
                subplot(313);
                plot(f, abs(Fftcomp'));
                xlabel('Frecuencia (Hz)');
                ylabel('FFT');
                grid on;
                grid minor;
                zoom on;
                title('FFT Nodos');
                legend({sprintf('Nodo %s', num2str(faseNodos(1))), ...
                    sprintf('Nodo %s', num2str(faseNodos(2)))});
                xlim(r.faseTlim);
                
            end % fase
            
            % Finaliza proceso
            fprintf('\tProceso finalizado en %.2f segundos\n', etime(clock, tinicial));
            dispMetodoTEFAME();
            
        end % calcularPSDCarga function
        
        function plotTrayectoriaNodos(obj, carga, nodos, direccion, varargin)
            % plotTrayectoriaNodos: Grafica la trayectoria de varios nodos
            % (carga, desplazamiento, velocidad y aceleracion) para todo el
            % tiempo
            %
            % Parametros opcionales:
            %   legend          Muestra la leyenda
            %   legendloc       Ubicacion de la leyenda
            %   plot            'all','carga','despl','vel','acel'
            %   tlim            Tiempo de analisis limite
            %   unidadC         Unidad carga
            %   unidadL         Unidad longitud
            
            % Inicia proceso
            tinicial = clock;
            
            % Verifica que el vector de nodos sea un cell
            if ~iscell(nodos)
                error('Nodos debe ser un cell de nodos');
            end
            if length(nodos) == 1
                warning('Para un solo nodo se recomienda plotTrayectoriaNodo(carga,nodo,direccion,varargin)');
            end
            
            % Verifica que la direccion sea correcta
            if sum(direccion) ~= 1
                error('Direccion invalida');
            end
            if ~verificarVectorDireccion(direccion, nodos{1}.obtenerNumeroGDL())
                error('Vector direccion mal definido');
            end
            
            % Recorre parametros opcionales
            p = inputParser;
            p.KeepUnmatched = true;
            addOptional(p, 'legend', false);
            addOptional(p, 'legendloc', 'best');
            addOptional(p, 'plot', 'all');
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
            
            fprintf('Calculando trayectoria nodos:\n');
            % fprintf('\tNodos: ');
            s = '';
            for k = 1:length(nodos)
                s = strcat(s, strcat(' ', nodos{k}.obtenerEtiqueta()));
                if k < length(nodos)
                    s = strcat(s, ', ');
                end
            end % for k
            % s = strcat(s, '\n');
            % fprintf(s);
            ctitle = obj.imprimirPropiedadesAnalisisCarga(carga);
            
            % Genera el vector de tiempo
            t = carga.obtenerVectorTiempo(); % Vector de tiempo
            if tlim == 0
                tlim = [min(t), max(t)];
            else
                tlim = [max(min(tlim), min(t)), min(max(tlim), max(t))];
            end
            [nr, ~] = size(a_c);
            
            % Verifica que la direccion sea correcta
            for k = 1:length(nodos)
                
                % Elige al nodo
                ngd = nodos{k}.obtenerGDLIDCondensado();
                ng = 0; % Numero grado analisis
                for i = 1:length(direccion)
                    if direccion(i) == 1
                        ng = ngd(i);
                    end
                end % for i
                
                if ng == 0
                    error('No se ha obtenido el GDLID del nodo, es posible que corresponda a un apoyo o bien que el grado de libertad fue condensado');
                end
                if ng > nr
                    error('El GDLID excede al soporte del sistema');
                end
                
            end % for k
            
            % Crea la leyenda de los nodos
            legnodos = cell(length(nodos), 1);
            for k = 1:length(nodos)
                legnodos{k} = nodos{k}.obtenerEtiqueta();
            end % for k
            
            % Indica si el grafico se realizo o no
            doPlot = false;
            
            % Grafico de carga
            if strcmp(r.plot, 'all') || strcmp(r.plot, 'carga')
                
                doPlot = true;
                fig_title = sprintf('%s %s - Carga', ...
                    ctitle, carga.obtenerEtiqueta());
                plt = figure('Name', fig_title, 'NumberTitle', 'off');
                movegui(plt, 'center');
                hold on;
                
                % Grafica los nodos
                for k = 1:length(nodos)
                    ngd = nodos{k}.obtenerGDLIDCondensado();
                    ng = 0; % Numero grado analisis
                    for i = 1:length(direccion)
                        if direccion(i) == 1
                            ng = ngd(i);
                        end
                    end % for i
                    plot(t, p_c(ng, :), '-', 'LineWidth', 1);
                end % for k
                
                ylabel(sprintf('Carga (%s)', r.unidadC));
                xlabel('t (s)');
                xlim(tlim);
                grid on;
                if r.legend
                    legend(legnodos, 'location', r.legendloc);
                end
                title(fig_title);
                
            end % carga
            
            % Grafico de desplazamiento
            if strcmp(r.plot, 'all') || strcmp(r.plot, 'despl')
                
                doPlot = true;
                fig_title = sprintf('%s %s - Desplazamiento', ...
                    ctitle, carga.obtenerEtiqueta());
                plt = figure('Name', fig_title, 'NumberTitle', 'off');
                movegui(plt, 'center');
                hold on;
                
                % Grafica los nodos
                for k = 1:length(nodos)
                    ngd = nodos{k}.obtenerGDLIDCondensado();
                    ng = 0; % Numero grado analisis
                    for i = 1:length(direccion)
                        if direccion(i) == 1
                            ng = ngd(i);
                        end
                    end % for i
                    plot(t, u_c(ng, :), '-', 'LineWidth', 1);
                end % for k
                
                ylabel(sprintf('u (%s)', r.unidadL));
                xlabel('t (s)');
                xlim(tlim);
                grid on;
                if r.legend
                    legend(legnodos, 'location', r.legendloc);
                end
                title(fig_title);
                
            end % despl
            
            % Grafico de velocidad
            if strcmp(r.plot, 'all') || strcmp(r.plot, 'vel')
                
                doPlot = true;
                fig_title = sprintf('%s %s - Velocidad', ...
                    ctitle, carga.obtenerEtiqueta());
                plt = figure('Name', fig_title, 'NumberTitle', 'off');
                movegui(plt, 'center');
                hold on;
                
                % Grafica los nodos
                for k = 1:length(nodos)
                    ngd = nodos{k}.obtenerGDLIDCondensado();
                    ng = 0; % Numero grado analisis
                    for i = 1:length(direccion)
                        if direccion(i) == 1
                            ng = ngd(i);
                        end
                    end % for i
                    plot(t, v_c(ng, :), '-', 'LineWidth', 1);
                end % for k
                
                ylabel(sprintf('v (%s/s)', r.unidadL));
                xlabel('t (s)');
                xlim(tlim);
                grid on;
                if r.legend
                    legend(legnodos, 'location', r.legendloc);
                end
                title(fig_title);
                
            end % vel
            
            % Grafico de aceleracion
            if strcmp(r.plot, 'all') || strcmp(r.plot, 'acel')
                
                doPlot = true;
                fig_title = sprintf('%s %s - Aceleracion', ...
                    ctitle, carga.obtenerEtiqueta());
                plt = figure('Name', fig_title, 'NumberTitle', 'off');
                movegui(plt, 'center');
                hold on;
                
                % Grafica los nodos
                for k = 1:length(nodos)
                    ngd = nodos{k}.obtenerGDLIDCondensado();
                    ng = 0; % Numero grado analisis
                    for i = 1:length(direccion)
                        if direccion(i) == 1
                            ng = ngd(i);
                        end
                    end % for i
                    plot(t, a_c(ng, :), '-', 'LineWidth', 1);
                end % for k
                
                ylabel(sprintf('a (%s/s^s)', r.unidadL));
                xlabel('t (s)');
                title(fig_title);
                xlim(tlim);
                grid on;
                if r.legend
                    legend(legnodos, 'location', r.legendloc);
                end
                
            end % acel
            
            % Si el grafico no se realizo
            if ~doPlot
                error('Tipo de grafico incorrecto, valores posibles: all,carga,despl,vel,acel,fft');
            end
            
            % Finaliza proceso
            fprintf('\tProceso finalizado en %.2f segundos\n', etime(clock, tinicial));
            dispMetodoTEFAME();
            
        end % plotTrayectoriaNodos function
        
        function plotTrayectoriaNodo(obj, carga, nodo, direccion, varargin)
            % plotTrayectoriaNodo: Grafica la trayectoria de un nodo
            % (desplazamiento, velocidad y aceleracion) para todo el tiempo
            %
            % Parametros opcionales:
            %   tlim        Tiempo de analisis limite
            %   unidadC     Unidad carga
            %   unidadL     Unidad longitud
            
            % Inicia proceso
            tinicial = clock;
            
            % Verifica que no sea un cell de nodos
            if iscell(nodo)
                error('Nodo no puede ser un cell, se recomienda plotTrayectoriaNodos(carga,nodos,direccion,varargin)');
            end
            
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
            [nr, ~] = size(a_c);
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
            if ng > nr
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
            ylabel(sprintf('Carga (%s)', r.unidadC));
            xlabel('t (s)');
            xlim(tlim);
            grid on;
            title({fig_title, ''});
            
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
            fprintf('\tProceso finalizado en %.2f segundos\n', etime(clock, tinicial));
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
            fprintf('\tModelo: %s\n', obj.modeloObj.obtenerNombre());
            
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
                fprintf('\t\t|\tN\t|\tT (s)\t| w (rad/s)\t|\tU1\t\t|\tU2\t\t|\tSum U1\t|\tSum U2\t|\n');
                fprintf('\t\t---------------------------------------------------------------------------------\n');
            elseif obj.numDG == 3
                fprintf('\t\t|\tN\t|\tT (s)\t| w (rad/s)\t|\tU1\t\t|\tU2\t\t|\tU3\t\t|\tSum U1\t|\tSum U2\t|\tSum U3\t|\n');
                fprintf('\t\t--------------------------------------------------------------------------------------------------------\n');
            end
            
            for i = 1:obj.numModos
                if obj.numDG == 2
                    fprintf('\t\t|\t%d\t|\t%.3f\t|\t%.3f\t|\t%.3f\t|\t%.3f\t|\t%.3f\t|\t%.3f\t|\t%.3f\n', i, obj.Tn(i), ...
                        obj.wn(i), obj.Mmeff(i, 1), obj.Mmeff(i, 2), ...
                        obj.Mmeffacum(i, 1), obj.Mmeffacum(i, 2));
                elseif obj.numDG == 3
                    fprintf('\t\t|\t%d\t|\t%.3f\t|\t%.3f\t|\t%.3f\t|\t%.3f\t|\t%.3f\t|\t%.3f\t|\t%.3f\t|\t%.3f\t|\t%.3f\n', i, obj.Tn(i), ...
                        obj.wn(i), obj.Mmeff(i, 1), obj.Mmeff(i, 2), obj.Mmeff(i, 3), ...
                        obj.Mmeffacum(i, 1), obj.Mmeffacum(i, 2), obj.Mmeffacum(i, 3));
                end
                fprintf('\n');
            end % for i
            
            if obj.numDG == 2
                fprintf('\t\t---------------------------------------------------------------------------------\n');
            elseif obj.numDG == 3
                fprintf('\t\t--------------------------------------------------------------------------------------------------------\n');
            end
            
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
        
    end % public methods ModalEspectral
    
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
                    end
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
                muIterDesplazamiento, nRitz, betaAlg)
            % calcularModalEspectral: Calcula el metodo modal espectral
            
            % Calcula tiempo inicio
            fprintf('\tCalculando metodo modal espectral:\n');
            tInicio = clock;
            
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
            if nModos > ngdl
                warning('El numero de modos de analisis excede los grados de libertad del sistema');
            end
            nModos = min(nModos, ngdl);
            
            %------------- CALCULO VALORES Y VECTORES PROPIOS ---------------
            eigCalcT = clock;
            
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
            elseif strcmp(valvecAlgoritmo, 'itInvDesp')
                fprintf('\t\tCalculo valores y vectores propios con metodo iteracion inversa con desplazamientos\n');
                fprintf('\t\t\tTolerancia: %.4f\n', valvecTolerancia);
                
                % Recorre cada mu y obtiene la forma modal
                if length(muIterDesplazamiento) > ngdl
                    warning('El largo del vector muIterDespl excede el numero de grados de libertad del sistema');
                end
                nModos = min(length(muIterDesplazamiento), ngdl);
                
                % Comienza con matrices vacias que luego se extienden para
                % cada modo calculado
                modalPhin = zeros(ngdl, nModos);
                modalWn = zeros(ngdl, 1);
                for i = 1:nModos
                    [modalPhini, modalWni] = calculoEigIterInvDesplazamiento(Meq, Keq, muIterDesplazamiento(i), valvecTolerancia);
                    modalPhin(:, i) = modalPhini(:, end);
                    modalWn(i) = modalWni(end);
                end % for i
            elseif strcmp(valvecAlgoritmo, 'itSubEsp')
                fprintf('\t\tCalculo valores y vectores propios con metodo iteracion del subespacio\n');
                fprintf('\t\t\tTolerancia: %.4f\n', valvecTolerancia);
                [modalPhin, modalWn] = calculoEigItSubespacio(Meq, Keq, nModos, valvecTolerancia);
            elseif strcmp(valvecAlgoritmo, 'ritz')
                fprintf('\t\tCalculo valores y vectores propios con vectores ritz\n');
                Fritz = diag(eye(length(Keq)));
                if nRitz > ngdl
                    warning('El numero de Ritz excede el numero de grados de libertad del sistema');
                end
                nRitz = min(nRitz, ngdl);
                fprintf('\t\t\tNumero de vectores Ritz: %d\n', nRitz);
                [modalPhin, modalWn] = calculoLDV(Meq, Keq, Fritz, nRitz);
                nModos = length(modalWn);
            else
                error('Algoritmo valvec:%s incorrecto, valores posibles: eigs,itDir,matBarr,itInvDesp,itSubEsp,ritz', ...
                    valvecAlgoritmo);
            end
            fprintf('\t\t\tFinalizado en %.3f segundos\n', etime(clock, eigCalcT));
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
            if (betaAlg == 0 || betaAlg == 1)
                
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
                
            else
                obj.cRayleigh = [];
            end
            
            % ------ CALCULO DE AMORTIGUAMIENTO DE WILSON-PENZIEN ----------
            if (betaAlg == 0 || betaAlg == 2)
                
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
                
            else
                obj.cPenzien = [];
            end
            
            % Termina el analisis
            obj.analisisFinalizado = true;
            obj.numDG = ndg;
            obj.numDGReal = obj.modeloObj.obtenerNumerosGDL();
            fprintf('\tSe completo el analisis en %.3f segundos\n', etime(clock, tInicio));
            
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
            
            fprintf('\tEnsamblando matriz de masa:\n');
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
                    
                    % Si la carga esta desactivada
                    if ~cargas{j}.cargaActivada()
                        continue;
                    end
                    
                    % Si la carga ya sumo masa se bloquea
                    if ~cargas{j}.cargaSumaMasa()
                        continue;
                    end
                    
                    nodoCarga = cargas{j}.obtenerNodos();
                    m = cargas{j}.obtenerMasa();
                    if length(m) ~= 1
                        continue;
                    end
                    
                    % Recorre los nodos
                    for k = 1:length(nodoCarga)
                        
                        n = nodoCarga{k}.obtenerGDLID();
                        if length(n) >= 2
                            obj.Mt(n(1), n(1)) = obj.Mt(n(1), n(1)) + 0.5 * m;
                        end
                        if length(n) >= 2
                            obj.Mt(n(2), n(2)) = obj.Mt(n(2), n(2)) + 0.5 * m;
                        end
                        if length(n) >= 3
                            obj.Mt(n(3), n(3)) = obj.Mt(n(3), n(3)) + 1e-6;
                        end
                        
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
            fprintf('\tDistribucion de masa:\n');
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
                    title(obj.modeloObj.obtenerNombre());
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
                    coordi = coord;
                    if (obj.analisisFinalizado && modo > 0) || defcarga
                        def = obj.obtenerDeformadaNodo(nodoElemento{j}, modo, gdl, defcarga, carga, -1);
                        for k=1:length(coord)
                            coordi(k) = coord(k) + def(k) .* factor;
                        end
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
                
                if yNodo > habs(j)
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
                if gdlx ~= 0
                    acelx(i-ini+1, :) = acel(gdlx, :);
                    m(i-ini+1, 1) = M(gdlx, gdlx);
                    Fnodos(i-ini+1, :) = M(gdlx, gdlx) .* acel(gdlx, :);
                else
                    Fnodos(i-ini+1, :) = 0;
                end
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
            fprintf('\t%s %s:\n', ctitle, carga.obtenerEtiqueta());
            
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
        
        function tabularAnalisisIdentificacionNL(obj, tabla) %#ok<INUSL>
            % tabularAnalisisIdentificacionNL: Imprime en consola la
            % tabla de resultados de la identificacion no lineal
            
            % Obtiene numero de modos
            [n, ~] = size(tabla);
            fprintf('\t\t|\tN\t|\tOmega\t|\tBeta\t|\tTheta\t|\tRho\t\t|\n');
            fprintf('\t\t---------------------------------------------------------\n');
            for i = 1:n
                fprintf('\t\t|\t%d\t|\t%.4f\t|\t%.4f\t|\t%.4f\t|\t%.4f\t|\n', ...
                    i, tabla(i, 1), tabla(i, 2), tabla(i, 3), tabla(i, 4));
            end % for i
            fprintf('\t\t---------------------------------------------------------\n');
            
        end % tabularAnalisisIdentificacionNL function
        
    end % private methods ModalEspectral
    
end % class ModalEspectral