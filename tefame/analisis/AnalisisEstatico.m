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
%| Clase AnalisisEstatico                                               |
%|                                                                      |
%| Este archivo contiene la definicion de la Clase AnalisisEstatico     |
%| AnalisisEstatico es una clase que se usa para resolver estaticamente |
%| una  estructura  lineal y  elastica, sometida  a un  set de  cargas, |
%| usando  el  metodo de  elementos finitos  y  analisis matricial  de  |
%| estructuras.                                                         |
%|                                                                      |
%| Programado: FR                                                       |
%| Fecha: 05/08/2015                                                    |
%|                                                                      |
%| Modificado por: FR - 24/10/2016                                      |
%|                 Pablo Pizarro @ppizarror - 10/04/2019                |
%|______________________________________________________________________|
%
%  Properties (Access=private):
%       numeroGDL
%       Kt
%       F
%       u
%  Methods:
%       obj = AnalisisEstatico(modeloObjeto)
%       analizar(obj)
%       Cd = ensamblarMatrizAmortiguamientoDisipadores(obj)
%       Cdv_Modelo = obtenerMatrizAmortiguamientoDisipadores(obj)
%       definirNumeracionGDL(obj)
%       disp(obj)
%       ensamblarMatrizRigidez(obj)
%       ensamblarVectorFuerzas(obj)
%       F_Modelo = obtenerVectorFuerzas(obj)
%       K_Modelo = obtenerMatrizRigidez(obj)
%       numeroEcuaciones = obtenerNumeroEcuaciones(obj)
%       plot(obj)
%       u_Modelo = obtenerDesplazamientos(obj)

classdef AnalisisEstatico < Analisis
    
    properties(Access = private)
        Kt % Matriz de rigidez del modelo
        F % Vector de fuerzas aplicadas sobre el modelo
        u % Vector con los desplazamientos de los grados de libertad del modelo
    end % private properties AnalisisEstatico
    
    methods(Access = public)
        
        function obj = AnalisisEstatico(modeloObjeto)
            % AnalisisEstatico: es el constructor de la clase AnalisisEstatico
            %
            % Crea un objeto de la clase AnalisisEstatico, y guarda el modelo,
            % que necesita ser analizado
            
            if nargin == 0
                modeloObjeto = [];
            end % if
            
            obj = obj@Analisis(modeloObjeto);
            obj.numeroGDL = 0;
            obj.Kt = [];
            obj.u = [];
            obj.F = [];
            
        end % AnalisisEstatico constructor
        
        function definirNumeracionGDL(obj)
            % definirNumeracionGDL: es un metodo de la clase AnalisisEstatico que
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
            numeroElementos = length(objetos);
            
            % Definimos los GDLID en los elementos para poder formar la matriz de rigidez
            for i = 1:numeroElementos
                objetos{i}.definirGDLID();
            end % for i
            
        end % definirNumeracionGDL function
        
        function analizar(obj, varargin)
            % analizar: es un metodo de la clase AnalisisEstatico que se usa para
            % realizar el analisis estatico
            % Analiza estaticamente el modelo lineal y elastico sometido a un
            % set de cargas
            %
            % Parametros opcionales:
            %   factorCargaE        Factor de cargas estaticas
            
            fprintf('Ejecutando analisis estatico\n');
            
            % Define parametros
            p = inputParser;
            p.KeepUnmatched = true;
            addOptional(p, 'factorCargaE', 1);
            parse(p, varargin{:});
            r = p.Results;
            
            % Se definen los grados de libertad por nodo -> elementos
            obj.definirNumeracionGDL();
            
            % Se aplica patron de carga
            obj.modeloObj.aplicarPatronesDeCargasEstatico(r.factorCargaE);
            
            % Se calcula la matriz de rigidez
            obj.ensamblarMatrizRigidez();
            
            % Guarda el resultado para las cargas estaticas
            fprintf('\tCalculando resultado carga estatica\n');
            obj.ensamblarVectorFuerzas();
            obj.u = (obj.Kt^-1) * obj.F;
            obj.modeloObj.actualizar(obj.u);
            
            % Termina el analisis
            obj.analisisFinalizado = true;
            dispMetodoTEFAME();
            
        end % analizar function
        
        function ensamblarMatrizRigidez(obj)
            % ensamblarMatrizRigidez: es un metodo de la clase AnalisisEstatico que se usa para
            % realizar el armado de la matriz de rigidez del modelo analizado
            %
            % Ensambla la matriz de Rigidez del modelo analizado usando el metodo
            % indicial
            
            fprintf('\tEnsamblando matriz de rigidez\n');
            obj.Kt = zeros(obj.numeroGDL, obj.numeroGDL);
            
            % Extraemos los Elementos y Disipadores
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
        
        function Cd = ensamblarMatrizAmortiguamientoDisipadores(obj)
            % ensamblarMatrizAmortiguamientoDisipadores: Analisis Estatico
            % no soporta disipadores ya que estos responden a un caracter
            % dinamico, por tal se retorna una matriz de ceros
            
            Cd = zeros(obj.numeroGDL, obj.numeroGDL);
            
        end % ensamblarMatrizAmortiguamientoDisipadores function
        
        function Kdv = ensamblarMatrizRigidezDisipadores(obj)
            % ensamblarMatrizRigidezDisipadores: Analisis Estatico
            % no soporta disipadores ya que estos responden a un caracter
            % dinamico, por tal se retorna una matriz de ceros
            %
            % Ensambla la matriz de rigidez de los disipadores del modelo
            % analizado usando el metodo indicial
            
            Kdv = zeros(obj.numeroGDL, obj.numeroGDL);
            
        end % ensamblarMatrizRigidezDisipadores function
        
        function ensamblarVectorFuerzas(obj)
            % ensamblarVectorFuerzas: es un metodo de la clase AnalisisEstatico que se usa para
            % realizar el armado del vector de fuerzas del modelo analizado
            %
            % Ensambla el vector de fuerzas del modelo analizado usando el metodo
            % indicial
            
            % En esta funcion se tiene que ensamblar el vector de fuerzas
            obj.F = zeros(obj.numeroGDL, 1);
            
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
        
        function numeroEcuaciones = obtenerNumeroEcuaciones(obj)
            % obtenerNumeroEcuaciones: es un metodo de la clase AnalisisEstatico
            % que se usa para obtener el numero total de GDL, es decir, ecuaciones
            % del modelo
            %
            % Obtiene el numero total de GDL (numeroEcuaciones) que esta guardado
            % en el Analisis (obj)
            
            numeroEcuaciones = obj.numeroGDL;
            
        end % obtenerNumeroEcuaciones function
        
        function K_Modelo = obtenerMatrizRigidez(obj)
            % obtenerMatrizRigidez: es un metodo de la clase AnalisisEstatico
            % que se usa para obtener la matriz de rigidez del modelo
            %
            % Obtiene la matriz de rigidez (K_Modelo) del modelo que se genero
            % en el Analisis (obj)
            
            if ~obj.analisisFinalizado
                warning('El analisis no ha sido realizado aun');
            end
            K_Modelo = obj.Kt;
            
        end % obtenerMatrizRigidez function
        
        function Cdv_Modelo = obtenerMatrizAmortiguamientoDisipadores(obj)
            % obtenerMatrizAmortiguamientoDisipadores: es un metodo de la
            % clase que retorna la matriz de amortiguamiento de los disipadores
            %
            % Obtiene la matriz de amortiguamiento de los disipadores del modelo
            
            Cdv_Modelo = obj.ensamblarMatrizAmortiguamientoDisipadores();
            
        end % obtenerMatrizAmortiguamientoDisipadores function
        
        function Kdv_Modelo = obtenerMatrizRigidezDisipadores(obj)
            % obtenerMatrizRigidezDisipadores: es un metodo de la clase ModalEspectral
            % que se usa para obtener la matriz de rigidez de los
            % disipadores
            
            Kdv_Modelo = obj.ensamblarMatrizRigidezDisipadores();
            
        end % obtenerMatrizRigidezDisipadores function
        
        function F_Modelo = obtenerVectorFuerzas(obj)
            % obtenerVectorFuerzas: es un metodo de la clase AnalisisEstatico
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
            % obtenerDesplazamientos: es un metodo de la clase AnalisisEstatico
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
        
        function [limx, limy, limz] = obtenerLimitesDeformada(obj, factor)
            % obtenerLimitesDeformada: Obtiene los limites de deformacion
            
            factor = 1.25 * factor;
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
                    def = nodoElemento{j}.obtenerDesplazamientos();
                    if obj.analisisFinalizado
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
                    if obj.analisisFinalizado
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
        
        function plt = plot(obj, varargin)
            % plt: Grafica el modelo
            %
            % Parametros opcionales:
            %   angAzh          Angulo grafico 3d azimutal
            %   angPol          Angulo grafico 3d polar
            %   defElem         Dibuja la deformada de cada elemento
            %   deformada       Dibuja la deformada del problema
            %   factor          Factor de la deformada
            %   lwElemD         Ancho linea elemento deformado
            %   lwElemE         Ancho linea elemento estatico
            %   sizeNodoD       Porte nodo deformado
            %   sizeNodoE       Porte nodo estatico
            %   styleElemD      Estilo elemento deformado
            %   styleElemE      Estilo elemento estatico
            %   styleNodoD      Estilo nodo deformado
            %   styleNodoE      Estilo nodos estaticos
            %   unidad          Unidad longitud
            
            p = inputParser;
            p.KeepUnmatched = true;
            addOptional(p, 'angAzh', 45);
            addOptional(p, 'angPol', 45);
            addOptional(p, 'defElem', true);
            addOptional(p, 'deformada', false);
            addOptional(p, 'factor', 1);
            addOptional(p, 'lwElemD', 1.25);
            addOptional(p, 'lwElemE', 0.5);
            addOptional(p, 'sizeNodoD', 10);
            addOptional(p, 'sizeNodoE', 5);
            addOptional(p, 'styleElemD', 'k-');
            addOptional(p, 'styleElemE', 'b-');
            addOptional(p, 'styleNodoD', 'k');
            addOptional(p, 'styleNodoE', 'b');
            addOptional(p, 'unidad', 'm');
            parse(p, varargin{:});
            r = p.Results;
            
            % Obtiene valores
            deformada = r.deformada;
            factor = r.factor;
            defElem = r.defElem;
            
            % Grafica la estructura
            nodoObjetos = obj.modeloObj.obtenerNodos();
            numeroNodos = length(nodoObjetos);
            
            % Calcula los limites
            [limx, limy, limz] = obj.obtenerLimitesDeformada(factor);
            
            plt = figure('Name', sprintf('Plot %s', obj.modeloObj.obtenerNombre()), ...
                'NumberTitle', 'off');
            if ~deformada
                title(obj.modeloObj.obtenerNombre());
                r.lwElemE = r.lwElemD;
                r.sizeNodoE = r.sizeNodoD;
                r.styleElemE = r.styleElemD;
                r.styleNodoE = r.styleNodoD;
            else
                title(sprintf('Analisis Estatico / Escala deformacion: %.2f', factor));
            end
            
            hold on;
            grid on;
            
            % Obtiene cuantos GDL tiene el modelo
            gdl = 2;
            ngdl = obj.modeloObj.obtenerNumeroDimensiones();
            
            for i = 1:numeroNodos
                coords = nodoObjetos{i}.obtenerCoordenadas();
                ngdlid = length(coords);
                gdl = max(gdl, ngdlid);
                if ~deformada
                    nodoObjetos{i}.plot([], r.styleNodoE, r.sizeNodoE);
                end
            end % for i
            
            % Grafica los elementos
            objetos = obj.modeloObj.obtenerElementos();
            numeroElementos = length(objetos);
            
            % Definimos los GDLID en los elementos
            for i = 1:numeroElementos
                
                % Se obienen los gdl del elemento metodo indicial
                nodoElemento = objetos{i}.obtenerNodos();
                numNodo = length(nodoElemento);
                objetos{i}.plot({}, r.styleElemE, r.lwElemE);
                
                if deformada && obj.analisisFinalizado
                    def = cell(numNodo, 1);
                    for j = 1:numNodo
                        def{j} = factor * nodoElemento{j}.obtenerDesplazamientos();
                    end % for j
                    objetos{i}.plot(def, r.styleElemD, r.lwElemD, defElem);
                end
                
            end % for i
            
            % Grafica los nodos deformados
            if deformada && obj.analisisFinalizado
                for i = 1:numeroNodos
                    coords = nodoObjetos{i}.obtenerCoordenadas();
                    def = nodoObjetos{i}.obtenerDesplazamientos();
                    for j = 1:length(def)
                        if isnan(def(j))
                            def(j) = 0;
                        end
                    end % for j
                    coords = coords + def .* factor;
                    ngdlid = length(coords);
                    gdl = max(gdl, ngdlid);
                    nodoObjetos{i}.plot(def.*factor, r.styleNodoD, r.sizeNodoD);
                end % for i
            end
            
            % Actualiza los ejes
            if limx(1) < limx(2)
                xlim(limx);
            end
            if limy(1) < limy(2)
                ylim(limy);
            end
            if gdl == 3 && limz(1) < limz(2)
                zlim(limz);
            end
            if ngdl == 2
                xlabel(sprintf('X (%s)', r.unidad));
                ylabel(sprintf('Y (%s)', r.unidad));
            else
                xlabel(sprintf('X (%s)', r.unidad));
                ylabel(sprintf('Y (%s)', r.unidad));
                zlabel(sprintf('Z (%s)', r.unidad));
                view(r.angAzh, r.angPol);
            end
            
        end % plot function
        
        function disp(obj)
            % disp: es un metodo de la clase AnalisisEstatico que se usa para imprimir en
            % command Window la informacion del Analisis Estatico realizado
            %
            % Imprime la informacion guardada en el AnalisisEstatico (obj) en
            % pantalla
            
            fprintf('Propiedades analisis estatico:\n');
            fprintf('\tMatriz de Rigidez:\n');
            disp(obj.Kt);
            fprintf('\tDeterminante: %f\n\n', det(obj.Kt));
            fprintf('\tVector de Fuerzas:\n');
            disp(obj.F);
            fprintf('\tVector de Desplazamientos:\n');
            disp(obj.u);
            dispMetodoTEFAME();
            
        end % disp function
        
    end % public methods AnalisisEstatico
    
end % class AnalisisEstatico