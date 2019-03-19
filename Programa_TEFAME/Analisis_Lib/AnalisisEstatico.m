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
%|                                                                      |
%| Desarrollado por:                                                    |
%|       Fabian Rojas, PhD (frojas@ing.uchile.cl)                       |
%|       Prof. Asistente, Departamento de Ingenieria Civil              |
%|       Universidad de Chile                                           |
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
%|                 PABLO PIZARRO @ppizarror - 14/05/2018                |
%|______________________________________________________________________|
%
%  Properties (Access=private):
%       modeloObj
%       numeroGDL
%       Kt
%       F
%       u
%
%  Methods:
%       analisisObj = AnalisisEstatico(modeloObjeto)
%       definirNumeracionGDL(analisisObj)
%       analizar(analisisObj)
%       ensamblarMatrizRigidez(analisisObj)
%       ensamblarVectorFuerzas(analisisObj)
%       numeroEquaciones = obtenerNumeroEquaciones(analisisObj)
%       K_Modelo = obtenerMatrizRigidez(analisisObj)
%       F_Modelo = obtenerVectorFuerzas(analisisObj)
%       u_Modelo = obtenerDesplazamientos(analisisObj)
%       plot(analisisObj)
%       disp(analisisObj)

classdef AnalisisEstatico < handle
    
    properties(Access = private)
        modeloObj % Guarda el objeto que contiene el Modelo
        numeroGDL % Guarda el numero de grados de libertad totales del modelo
        Kt % Matriz de Rigidez del Modelo
        F % Vector de Fuerzas aplicadas sobre el modelo
        u % Vector con los desplazamientos de los grados de libertad del modelo
    end % properties AnalisisEstatico
    
    methods
        
        function analisisObj = AnalisisEstatico(modeloObjeto)
            % AnalisisEstatico: es el constructor de la clase AnalisisEstatico
            %
            % analisisObj = AnalisisEstatico(modeloObjeto)
            % Crea un objeto de la clase AnalisisEstatico, y guarda el Modelo,
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
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Metodos para definir y analizar el modelo
        
        function definirNumeracionGDL(analisisObj)
            % definirNumeracionGDL: es un metodo de la clase AnalisisEstatico que
            % se usa para definir como se enumeran los GDL en el Modelo
            %
            % definirNumeracionGDL(analisisObj)
            % Define y asigna la enumeracion de los GDL en el Modelo
            
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
            % Analiza estaticamente el Modelo lineal y elastico sometido a un
            % set de cargas.
            
            % Se definen los grados de libertad por nodo -> elementos
            analisisObj.definirNumeracionGDL();
            
            % Se aplica patron de carga
            analisisObj.modeloObj.aplicarPatronesDeCargas();
            
            % Se calcula la matriz de rigidez
            analisisObj.ensamblarMatrizRigidez();
            
            % Se ensambla el vector de fuerzas
            analisisObj.ensamblarVectorFuerzas();
            
            % Se resuelve la ecuacion
            analisisObj.u = (analisisObj.Kt^-1) * analisisObj.F;
            
            % Actualiza el modelo
            analisisObj.modeloObj.actualizar(analisisObj.u);
            
        end % analizar function
        
        function ensamblarMatrizRigidez(analisisObj)
            % ensamblarMatrizRigidez: es un metodo de la clase AnalisisEstatico que se usa para
            % realizar el armado de la matriz de rigidez del modelo analizado
            %
            % ensamblarMatrizRigidez(analisisObj)
            % Ensambla la matriz de Rigidez del modelo analizado usando el metodo
            % indicial
            
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
        
        function ensamblarVectorFuerzas(analisisObj)
            % ensamblarVectorFuerzas: es un metodo de la clase AnalisisEstatico que se usa para
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
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Metodos para obtener la informacion del analisis
        
        function numeroEquaciones = obtenerNumeroEquaciones(analisisObj)
            % obtenerNumeroEquaciones: es un metodo de la clase AnalisisEstatico
            % que se usa para obtener el numero total de GDL, es decir, ecuaciones
            % del Modelo
            %
            % numeroEquaciones = obtenerNumeroEquaciones(analisisObj)
            % Obtiene el numero total de GDL (numeroEquaciones) que esta guardado
            % en el Analisis (analisisObj)
            
            numeroEquaciones = analisisObj.numeroGDL;
            
        end % obtenerNumeroEquaciones function
        
        function K_Modelo = obtenerMatrizRigidez(analisisObj)
            % obtenerMatrizRigidez: es un metodo de la clase AnalisisEstatico
            % que se usa para obtener la matriz de rigidez del Modelo
            %
            % K_Modelo = obtenerMatrizRigidez(analisisObj)
            % Obtiene la matriz de rigidez (K_Modelo) del Modelo que se genero
            % en el Analisis (analisisObj)
            
            K_Modelo = analisisObj.Kt;
            
        end % obtenerMatrizRigidez function
        
        function F_Modelo = obtenerVectorFuerzas(analisisObj)
            % obtenerMatrizRigidez: es un metodo de la clase AnalisisEstatico
            % que se usa para obtener el vector de fuerza del Modelo
            %
            % F_Modelo = obtenerVectorFuerzas(analisisObj)
            % Obtiene el vector de fuerza (F_Modelo) del Modelo que se genero
            % en el Analisis (analisisObj)
            
            F_Modelo = analisisObj.F;
            
        end % obtenerVectorFuerzas function
        
        function u_Modelo = obtenerDesplazamientos(analisisObj)
            % obtenerDesplazamientos: es un metodo de la clase AnalisisEstatico
            % que se usa para obtener el vector de desplazamiento del Modelo
            % obtenido del analisis
            %
            % u_Modelo = obtenerDesplazamientos(analisisObj)
            % Obtiene el vector de desplazamiento (u_Modelo) del Modelo que se
            % genero como resultado del Analisis (analisisObj)
            
            u_Modelo = analisisObj.u;
            
        end % obtenerDesplazamientos function
        
        function plt = plot(analisisObj, deformada, factor)
            %PLOTMODELO Grafica un modelo
            %
            % plt = plot(factor, deformada)
            
            if ~exist('deformada', 'var')
                deformada = false;
            end
            
            if ~exist('factor', 'var')
                factor = 2;
            end
            
            % Grafica la estructura
            nodoObjetos = analisisObj.modeloObj.obtenerNodos();
            numeroNodos = length(nodoObjetos);
            
            plt = figure();
            if ~deformada
                title('Analisis Estatico');
            else
                title(sprintf('Analisis Estatico / Escala deformacion: %d%%', factor*100));
            end
            
            hold on;
            grid on;
            
            % Obtiene cuantos GDL tiene el modelo
            gdl = 2;
            limx = [inf, -inf];
            limy = [inf, -inf];
            limz = [inf, -inf];
            for i = 1:numeroNodos
                coords = nodoObjetos{i}.obtenerCoordenadas();
                ngdlid = length(coords);
                gdl = max(gdl, ngdlid);
                
                if ~nodoObjetos{i}.tipoApoyoRestringido()
                    if ngdlid == 2
                        plot(coords(1), coords(2), 'b.', 'MarkerSize', 20);
                    else
                        plot3(coords(1), coords(2), coords(3), 'b.', 'MarkerSize', 20);
                    end
                end
                
                % Actualiza los limites
                limx(1) = min([limx(1), coords(1)]);
                limy(1) = min([limy(1), coords(2)]);
                limx(2) = max([limx(2), coords(1)]);
                limy(2) = max([limy(2), coords(2)]);
                if gdl == 3
                    limz(1) = min([limz(1), coords(3)]);
                    limz(2) = max([limz(2), coords(3)]);
                end
            end
            
            if gdl == 2
                xlabel('X');
                ylabel('Y');
            else
                xlabel('X');
                ylabel('Y');
                zlabel('Z');
                view(45, 45);
            end
            
            % Grafica los elementos
            elementoObjetos = analisisObj.modeloObj.obtenerElementos();
            numeroElementos = length(elementoObjetos);
            
            % Definimos los GDLID en los elementos
            for i = 1:numeroElementos
                
                % Se obienen los gdl del elemento metodo indicial
                nodoElemento = elementoObjetos{i}.obtenerNodos();
                coord1 = nodoElemento{1}.obtenerCoordenadas();
                coord2 = nodoElemento{2}.obtenerCoordenadas();
                
                if gdl == 2
                    plot([coord1(1), coord2(1)], [coord1(2), coord2(2)], 'b-', 'LineWidth', 1.25);
                else
                    plot3([coord1(1), coord2(1)], [coord1(2), coord2(2)], [coord1(3), coord2(3)], ...
                        'b-', 'LineWidth', 1.25);
                end
                
                if deformada
                    def1 = nodoElemento{1}.obtenerDesplazamientos();
                    def2 = nodoElemento{2}.obtenerDesplazamientos();
                    
                    % Suma las deformaciones
                    coord1 = coord1 + def1 .* factor;
                    coord2 = coord2 + def2 .* factor;
                    
                    % Grafica
                    if gdl == 2
                        plot([coord1(1), coord2(1)], [coord1(2), coord2(2)], 'k--', 'LineWidth', 0.7);
                    else
                        plot3([coord1(1), coord2(1)], [coord1(2), coord2(2)], [coord1(3), coord2(3)], ...
                            'k--', 'LineWidth', 0.7);
                    end
                    
                    % Actualiza los limites
                    limx(1) = min([limx(1), coord1(1), coord2(1)]);
                    limy(1) = min([limy(1), coord1(2), coord2(2)]);
                    limx(2) = max([limx(2), coord1(1), coord1(1)]);
                    limy(2) = max([limy(2), coord1(2), coord2(2)]);
                    if gdl == 3
                        limz(1) = min([limz(1), coord1(3), coord2(3)]);
                        limz(2) = max([limz(2), coord1(3), coord2(3)]);
                    end
                end
                
            end
            
            % Grafica los nodos deformados
            if deformada
                for i = 1:numeroNodos
                    coords = nodoObjetos{i}.obtenerCoordenadas();
                    def = nodoObjetos{i}.obtenerDesplazamientos();
                    coords = coords + def .* factor;
                    ngdlid = length(coords);
                    gdl = max(gdl, ngdlid);
                    
                    if ~nodoObjetos{i}.tipoApoyoRestringido()
                        if ngdlid == 2
                            plot(coords(1), coords(2), 'k*', 'MarkerSize', 10);
                        else
                            plot3(coords(1), coords(2), coords(3), 'k*', 'MarkerSize', 10);
                        end
                    end
                    
                end
            end
            
            % Limita en los ejes
            xlim(limx);
            ylim(limy);
            if gdl == 3
                zlim(limz);
            end
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Metodos para mostar la informacion del Analisis Estatico en pantalla
        
        function disp(analisisObj)
            % disp: es un metodo de la clase AnalisisEstatico que se usa para imprimir en
            % command Window la informacion del Analisis Estatico realizado
            %
            % disp(modeloObj)
            % Imprime la informacion guardada en el AnalisisEstatico (analisisObj) en
            % pantalla
            
            fprintf('Propiedades Analisis:\n');
            
            fprintf('\tMatriz de Rigidez:\n');
            disp(analisisObj.Kt);
            
            fprintf('\tDeterminante: %f\n\n', det(analisisObj.Kt));
            
            fprintf('\tSimetrica: %s\n\n', bool2str(analisisObj.Kt == analisisObj.Kt'));
            
            fprintf('\tVector de Fuerzas:\n');
            disp(analisisObj.F);
            
            fprintf('\tVector de Desplazamientos:\n');
            disp(analisisObj.u);
            
            fprintf('-------------------------------------------------\n');
            fprintf('\n');
            
        end % disp function
        
    end % methods AnalisisEstatico
    
end % class AnalisisEstatico