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
%       modeloObj
%       numeroGDL
%       Kt
%       F
%       u
%  Methods:
%       analisisObj = AnalisisEstatico(modeloObjeto)
%       definirNumeracionGDL(analisisObj)
%       analizar(analisisObj)
%       ensamblarMatrizRigidez(analisisObj)
%       ensamblarVectorFuerzas(analisisObj)
%       numeroEcuaciones = obtenerNumeroEcuaciones(analisisObj)
%       K_Modelo = obtenerMatrizRigidez(analisisObj)
%       F_Modelo = obtenerVectorFuerzas(analisisObj)
%       u_Modelo = obtenerDesplazamientos(analisisObj)
%       plot(analisisObj)
%       disp(analisisObj)

classdef AnalisisEstatico < handle
    
    properties(Access = private)
        modeloObj % Guarda el objeto que contiene el modelo
        numeroGDL % Guarda el numero de grados de libertad totales del modelo
        Kt % Matriz de Rigidez del modelo
        F % Vector de Fuerzas aplicadas sobre el modelo
        u % Vector con los desplazamientos de los grados de libertad del modelo
    end % properties AnalisisEstatico
    
    methods
        
        function analisisObj = AnalisisEstatico(modeloObjeto)
            % AnalisisEstatico: es el constructor de la clase AnalisisEstatico
            %
            % analisisObj = AnalisisEstatico(modeloObjeto)
            % Crea un objeto de la clase AnalisisEstatico, y guarda el modelo,
            % que necesita ser analizado
            
            if nargin == 0
                modeloObjeto = [];
            end % if
            
            analisisObj.modeloObj = modeloObjeto;
            analisisObj.numeroGDL = 0;
            analisisObj.Kt = [];
            analisisObj.u = [];
            analisisObj.F = [];
            
        end % AnalisisEstatico constructor
        
        function definirNumeracionGDL(analisisObj)
            % definirNumeracionGDL: es un metodo de la clase AnalisisEstatico que
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
        
        function analizar(analisisObj)
            % analizar: es un metodo de la clase AnalisisEstatico que se usa para
            % realizar el analisis estatico
            %
            % analizar(analisisObj)
            % Analiza estaticamente el modelo lineal y elastico sometido a un
            % set de cargas
            
            fprintf('Ejecuntando analisis estatico\n');
            
            % Se definen los grados de libertad por nodo -> elementos
            analisisObj.definirNumeracionGDL();
            
            % Se aplica patron de carga
            analisisObj.modeloObj.aplicarPatronesDeCargasEstatico();
            
            % Se calcula la matriz de rigidez
            analisisObj.ensamblarMatrizRigidez();
            
            % Guarda el resultado para las cargas estaticas
            fprintf('\tCalculando resultado carga estatica\n');
            analisisObj.ensamblarVectorFuerzas();
            analisisObj.u = (analisisObj.Kt^-1) * analisisObj.F;
            analisisObj.modeloObj.actualizar(analisisObj.u);
            
        end % analizar function
        
        function ensamblarMatrizRigidez(analisisObj)
            % ensamblarMatrizRigidez: es un metodo de la clase AnalisisEstatico que se usa para
            % realizar el armado de la matriz de rigidez del modelo analizado
            %
            % ensamblarMatrizRigidez(analisisObj)
            % Ensambla la matriz de Rigidez del modelo analizado usando el metodo
            % indicial
            
            fprintf('\tEnsamblando matriz de rigidez\n');
            analisisObj.Kt = zeros(analisisObj.numeroGDL, analisisObj.numeroGDL);
            
            % Extraemos los Elementos y Disipadores
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
        
        function ensamblarMatrizDisipadores(analisisObj)
            % ensamblarMatrizRigidez: es un metodo de la clase AnalisisEstatico que se usa para
            % realizar el armado de la matriz de rigidez del modelo analizado
            %
            % ensamblarMatrizRigidez(analisisObj)
            % Ensambla la matriz de Rigidez del modelo analizado usando el metodo
            % indicial
            
            fprintf('\tEnsamblando matriz de rigidez\n');
            analisisObj.Kt = zeros(analisisObj.numeroGDL, analisisObj.numeroGDL);
            
            % Extraemos los Elementos y Disipadores
            DisipadoresObjetos = analisisObj.modeloObj.obtenerDisipadores();
            numeroDisipadores = length(DisipadoresObjetos);
            
            % Definimos los GDLID en los elementos
            for i = 1:numeroDisipadores
                
                % Se obienen los gdl del elemento metodo indicial
                gdl = DisipadoresObjetos{i}.obtenerGDLID();
                ngdl = DisipadoresObjetos{i}.obtenerNumeroGDL;
                
                % Se obtiene la matriz de rigidez global del elemento-i
                c_globl_elem = DisipadoresObjetos{i}.obtenerMatrizAmortiguamientoCoordGlobal(); %#ok<NASGU>
                
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
            
        end % ensamblarMatrizDisipadores function
        
        function ensamblarVectorFuerzas(analisisObj)
            % ensamblarVectorFuerzas: es un metodo de la clase AnalisisEstatico que se usa para
            % realizar el armado del vector de fuerzas del modelo analizado
            %
            % ensamblarMatrizRigidez(analisisObj)
            % Ensambla el vector de fuerzas del modelo analizado usando el metodo
            % indicial
            
            % En esta funcion se tiene que ensamblar el vector de fuerzas
            analisisObj.F = zeros(analisisObj.numeroGDL, 1);
            
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
        
        function numeroEcuaciones = obtenerNumeroEcuaciones(analisisObj)
            % obtenerNumeroEcuaciones: es un metodo de la clase AnalisisEstatico
            % que se usa para obtener el numero total de GDL, es decir, ecuaciones
            % del modelo
            %
            % numeroEcuaciones = obtenerNumeroEcuaciones(analisisObj)
            % Obtiene el numero total de GDL (numeroEcuaciones) que esta guardado
            % en el Analisis (analisisObj)
            
            numeroEcuaciones = analisisObj.numeroGDL;
            
        end % obtenerNumeroEcuaciones function
        
        function K_Modelo = obtenerMatrizRigidez(analisisObj)
            % obtenerMatrizRigidez: es un metodo de la clase AnalisisEstatico
            % que se usa para obtener la matriz de rigidez del modelo
            %
            % K_Modelo = obtenerMatrizRigidez(analisisObj)
            % Obtiene la matriz de rigidez (K_Modelo) del modelo que se genero
            % en el Analisis (analisisObj)
            
            K_Modelo = analisisObj.Kt;
            
        end % obtenerMatrizRigidez function
        
        function F_Modelo = obtenerVectorFuerzas(analisisObj)
            % obtenerMatrizRigidez: es un metodo de la clase AnalisisEstatico
            % que se usa para obtener el vector de fuerza del modelo
            %
            % F_Modelo = obtenerVectorFuerzas(analisisObj)
            % Obtiene el vector de fuerza (F_Modelo) del modelo que se genero
            % en el Analisis (analisisObj)
            
            F_Modelo = analisisObj.F;
            
        end % obtenerVectorFuerzas function
        
        function u_Modelo = obtenerDesplazamientos(analisisObj)
            % obtenerDesplazamientos: es un metodo de la clase AnalisisEstatico
            % que se usa para obtener el vector de desplazamiento del modelo
            % obtenido del analisis
            %
            % u_Modelo = obtenerDesplazamientos(analisisObj)
            % Obtiene el vector de desplazamiento (u_Modelo) del modelo que se
            % genero como resultado del Analisis (analisisObj)
            
            u_Modelo = analisisObj.u;
            
        end % obtenerDesplazamientos function
        
        function [limx, limy, limz] = obtenerLimitesDeformada(analisisObj, factor)
            % Obtiene los limites de deformacion
            
            factor = 1.25 * factor;
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
                    def = nodoElemento{j}.obtenerDesplazamientos();
                    coordi = coord + def .* factor;
                    limx(1) = min(limx(1), coordi(1));
                    limy(1) = min(limy(1), coordi(2));
                    limx(2) = max(limx(2), coordi(1));
                    limy(2) = max(limy(2), coordi(2));
                    if gdl == 3
                        limz(1) = min(limz(1), coordi(3));
                        limz(2) = max(limz(2), coordi(3));
                    end
                    coordf = coord - def .* factor;
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
        
        function plt = plot(analisisObj, varargin)
            %PLOTMODELO Grafica un modelo
            %
            % plt = plot(varargin)
            %
            % Parametros opcionales:
            %   'deformada'     Dibuja la deformada del problema
            %   'factor'        Factor de la deformada
            %   'defElem'       Dibuja la deformada de cada elemento
            
            p = inputParser;
            p.KeepUnmatched = true;
            addOptional(p, 'deformada', false);
            addOptional(p, 'factor', 10);
            addOptional(p, 'defElem', true);
            parse(p, varargin{:});
            r = p.Results;
            
            % Obtiene valores
            deformada = r.deformada;
            factor = r.factor;
            defElem = r.defElem;
            
            % Grafica la estructura
            nodoObjetos = analisisObj.modeloObj.obtenerNodos();
            numeroNodos = length(nodoObjetos);
            
            % Calcula los limites
            [limx, limy, limz] = analisisObj.obtenerLimitesDeformada(factor);
            
            plt = figure('Name', sprintf('Plot %s', analisisObj.modeloObj.obtenerNombre()), ...
                'NumberTitle', 'off');
            if ~deformada
                title('Analisis Estatico');
            else
                title(sprintf('Analisis Estatico / Escala deformacion: %.2f', factor));
            end
            
            hold on;
            grid on;
            
            % Obtiene cuantos GDL tiene el modelo
            gdl = 2;
            ngdl = analisisObj.modeloObj.obtenerNumeroDimensiones();
            
            for i = 1:numeroNodos
                coords = nodoObjetos{i}.obtenerCoordenadas();
                ngdlid = length(coords);
                gdl = max(gdl, ngdlid);
                if ~deformada
                    nodoObjetos{i}.plot([], 'b', 5);
                end
            end
            
            % Grafica los elementos
            elementoObjetos = analisisObj.modeloObj.obtenerElementos();
            numeroElementos = length(elementoObjetos);
            
            % Definimos los GDLID en los elementos
            for i = 1:numeroElementos
                
                % Se obienen los gdl del elemento metodo indicial
                nodoElemento = elementoObjetos{i}.obtenerNodos();
                numNodo = length(nodoElemento);
                elementoObjetos{i}.plot({}, 'b-', 0.5);
                
                if deformada
                    def = cell(numNodo, 1);
                    for j = 1:numNodo
                        def{j} = factor * nodoElemento{j}.obtenerDesplazamientos();
                    end
                    elementoObjetos{i}.plot(def, 'k-', 1.25, defElem);
                end
                
            end
            
            % Grafica los nodos deformados
            if deformada
                for i = 1:numeroNodos
                    coords = nodoObjetos{i}.obtenerCoordenadas();
                    def = nodoObjetos{i}.obtenerDesplazamientos();
                    for j = 1:length(def)
                        if isnan(def(j))
                            def(j) = 0;
                        end
                    end
                    coords = coords + def .* factor;
                    ngdlid = length(coords);
                    gdl = max(gdl, ngdlid);
                    nodoObjetos{i}.plot(def.*factor, 'k', 10);
                end
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
                xlabel('X');
                ylabel('Y');
            else
                xlabel('X');
                ylabel('Y');
                zlabel('Z');
                view(45, 45);
            end
            
        end % plot function
        
        function disp(analisisObj)
            % disp: es un metodo de la clase AnalisisEstatico que se usa para imprimir en
            % command Window la informacion del Analisis Estatico realizado
            %
            % disp(analisisObj)
            % Imprime la informacion guardada en el AnalisisEstatico (analisisObj) en
            % pantalla
            
            fprintf('Propiedades Analisis:\n');
            
            fprintf('\tMatriz de Rigidez:\n');
            disp(analisisObj.Kt);
            
            fprintf('\tDeterminante: %f\n\n', det(analisisObj.Kt));
            
            fprintf('\tVector de Fuerzas:\n');
            disp(analisisObj.F);
            
            fprintf('\tVector de Desplazamientos:\n');
            disp(analisisObj.u);
            
            fprintf('-------------------------------------------------\n');
            
        end % disp function
        
    end % methods AnalisisEstatico
    
end % class AnalisisEstatico