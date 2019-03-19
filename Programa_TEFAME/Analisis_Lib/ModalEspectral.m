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
%|       Pablo Pizarro                                                  |
%|       Estudiante de Magíster, Ingeniero Civil Estructural            |
%|       Universidad de Chile                                           |
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
%
%  Methods:
%       analisisObj = ModalEspectral(modeloObjeto)
%       definirNumeracionGDL(analisisObj)
%       analizar(analisisObj)
%       ensamblarMatrizRigidez(analisisObj)
%       ensamblarMatrizMasa(analisisObj)
%       ensamblarVectorFuerzas(analisisObj)
%       numeroEquaciones = obtenerNumeroEquaciones(analisisObj)
%       K_Modelo = obtenerMatrizRigidez(analisisObj)
%       M_Modelo = obtenerMatrizMasa(analisisObj)
%       F_Modelo = obtenerVectorFuerzas(analisisObj)
%       u_Modelo = obtenerDesplazamientos(analisisObj)
%       plot(analisisObj)
%       disp(analisisObj)

classdef ModalEspectral < handle
    
    properties(Access = private)
        modeloObj % Guarda el objeto que contiene el modelo
        numeroGDL % Guarda el numero de grados de libertad totales del modelo
        Kt % Matriz de Rigidez del modelo
        Mt % Matriz de Masa del modelo
        F % Vector de Fuerzas aplicadas sobre el modelo
        u % Vector con los desplazamientos de los grados de libertad del modelo
        wn % Frecuencias del sistema
        Tn % Periodos del sistema
        phin % Vectores propios del sistema
        Mm % Matriz masa modal
        Km % Matriz rigidez modal
        r % Vector influencia
        Lm % Factor de participacion modal
        Mmeff % Masa modal efectiva
        Mmeffacum % Masa modal efectiva acumulada
        Mmeffacump % Masa modal efectiva acumulada porcentaje
    end % properties ModalEspectral
    
    methods
        
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
            
        end % ModalEspectral constructor
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Metodos para definir y analizar el modelo
        
        function definirNumeracionGDL(analisisObj)
            % definirNumeracionGDL: es un metodo de la clase ModalEspectral que
            % se usa para definir como se enumeran los GDL en el modelo
            %
            % definirNumeracionGDL(analisisObj)
            % Define y asigna la enumeracion de los GDL en el modelo
            
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
            % analizar: es un metodo de la clase ModalEspectral que se usa para
            % realizar el analisis estatico
            %
            % analizar(analisisObj)
            % Analiza estaticamente el modelo lineal y elastico sometido a un
            % set de cargas.
            
            % Se definen los grados de libertad por nodo -> elementos
            analisisObj.definirNumeracionGDL();
            
            % Se aplica patron de carga
            analisisObj.modeloObj.aplicarPatronesDeCargas();
            
            % Se calcula la matriz de rigidez
            analisisObj.ensamblarMatrizRigidez();
            
            % Se calcula la matriz de masa
            analisisObj.ensamblarMatrizMasa();
            
            % Se ensambla el vector de fuerzas
            analisisObj.ensamblarVectorFuerzas();
            
            % Test
            % analisisObj.Mt = diag([122.5, 122.5, 122.5, 122.5]);
            % analisisObj.Kt = 5597.67 .* [1, -1, 0, 0; -1, 2, -1, 0; 0,-1, 2, -1; 0, 0, -1, 2];
            
            % Calcula las frecuencias del sistema
            modalWn = sqrt(eig(analisisObj.Mt^-1*analisisObj.Kt));
            
            % Calcula los periodos
            modalTn = (modalWn.^-1) .* 2 * pi;
            
            % Calcula los vectores propios
            [~, ~, modalPhin] = eig(analisisObj.Mt^-1*analisisObj.Kt);
            
            % Calcula la matriz de masa
            ngdl = length(analisisObj.Mt);
            modalMm = modalPhin' * analisisObj.Mt * modalPhin;
            modalPhin = modalPhin * diag(diag(modalMm).^-0.5);
            modalMm = eye(ngdl);
            % modalMm = diag(diag(modalPhin' * analisisObj.Mt * modalPhin));
            modalKm = diag(diag(modalPhin'*analisisObj.Kt*modalPhin));
            
            % Reordena los periodos
            Torder = zeros(ngdl, 1);
            Tpos = 1;
            for i = 1:ngdl
                maxt = 0; % Periodo
                maxi = 0; % Indice
                for j = 1:ngdl % Se busca el elemento para etiquetar
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
            
            % Asigna valores
            analisisObj.Tn = zeros(ngdl, 1);
            analisisObj.wn = zeros(ngdl, 1);
            analisisObj.phin = zeros(ngdl, ngdl);
            analisisObj.Mm = modalMm;
            analisisObj.Km = modalKm;
            for i = 1:ngdl
                analisisObj.Tn(Torder(i)) = modalTn(i);
                analisisObj.wn(Torder(i)) = modalWn(i);
                analisisObj.phin(:, Torder(i)) = modalPhin(:, i);
            end
            
            % Crea vector influencia
            analisisObj.r = ones(ngdl, 1);
            analisisObj.Lm = analisisObj.phin' * analisisObj.Mt * analisisObj.r;
            analisisObj.Mmeff = analisisObj.Lm.^2 ./ diag(analisisObj.Mm);
            
            Mtotal = sum(analisisObj.Mmeff);
            analisisObj.Mmeffacum = zeros(ngdl, 1);
            analisisObj.Mmeffacum(1) = analisisObj.Mmeff(1);
            for i = 2:ngdl
                analisisObj.Mmeffacum(i) = analisisObj.Mmeffacum(i-1) + analisisObj.Mmeff(i);
            end
            
            % Calcula porcentaje por edificio
            analisisObj.Mmeffacump = analisisObj.Mmeffacum ./ Mtotal;
            analisisObj.Mmeffacump
            
            % Se resuelve la ecuacion
            analisisObj.u = zeros(length(analisisObj.F), 1);
            
            % Actualiza el modelo
            analisisObj.modeloObj.actualizar(analisisObj.u);
            
        end % analizar function
        
        function ensamblarMatrizRigidez(analisisObj)
            % ensamblarMatrizRigidez: es un metodo de la clase ModalEspectral que se usa para
            % realizar el armado de la matriz de rigidez del modelo analizado
            %
            % ensamblarMatrizRigidez(analisisObj)
            % Ensambla la matriz de rigidez del modelo analizado usando el metodo
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
        
        function ensamblarMatrizMasa(analisisObj)
            % ensamblarMatrizMasa: es un metodo de la clase ModalEspectral que se usa para
            % realizar el armado de la matriz de masa del modelo
            %
            % ensamblarMatrizMasa(analisisObj)
            % Ensambla la matriz de masa del modelo analizado usando el metodo
            % indicial
            
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
                if analisisObj.Mt(i, i) <= 0
                    error('La matriz de masa esta mal definida, Mt(%d,%d)<=0', i, i);
                end
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
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Metodos para obtener la informacion del analisis
        
        function numeroEquaciones = obtenerNumeroEquaciones(analisisObj)
            % obtenerNumeroEquaciones: es un metodo de la clase ModalEspectral
            % que se usa para obtener el numero total de GDL, es decir, ecuaciones
            % del modelo
            %
            % numeroEquaciones = obtenerNumeroEquaciones(analisisObj)
            % Obtiene el numero total de GDL (numeroEquaciones) que esta guardado
            % en el Analisis (analisisObj)
            
            numeroEquaciones = analisisObj.numeroGDL;
            
        end % obtenerNumeroEquaciones function
        
        function K_Modelo = obtenerMatrizRigidez(analisisObj)
            % obtenerMatrizRigidez: es un metodo de la clase ModalEspectral
            % que se usa para obtener la matriz de rigidez del modelo
            %
            % K_Modelo = obtenerMatrizRigidez(analisisObj)
            % Obtiene la matriz de rigidez (K_Modelo) del modelo que se genero
            % en el Analisis (analisisObj)
            
            K_Modelo = analisisObj.Kt;
            
        end % obtenerMatrizRigidez function
        
        function M_Modelo = obtenerMatrizMasa(analisisObj)
            % obtenerMatrizMasa: es un metodo de la clase ModalEspectral
            % que se usa para obtener la matriz de masa del modelo
            %
            % M_Modelo = obtenerMatrizRigidez(analisisObj)
            % Obtiene la matriz de masa (M_Modelo) del modelo que se genero
            % en el Analisis (analisisObj)
            
            M_Modelo = analisisObj.Mt;
            
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
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Metodos para mostar la informacion del Analisis Modal Espectral en pantalla
        
        function disp(analisisObj)
            % disp: es un metodo de la clase ModalEspectral que se usa para imprimir en
            % command Window la informacion del analisis espectral realizado
            %
            % disp(modeloObj)
            % Imprime la informacion guardada en el ModalEspectral (analisisObj) en
            % pantalla
            
            fprintf('Propiedades Analisis Modal:\n');
            
            fprintf('\tMatriz de Rigidez:\n');
            fprintf('\t\tDeterminante: %f\n', det(analisisObj.Kt));
            
            fprintf('\tMatriz de Masa:\n');
            fprintf('\t\tDeterminante: %f\n', det(analisisObj.Mt));
            
            fprintf('\tPeriodos:\n');
            fprintf('\t\tN°\t|\tT (s)\t\t|\tw (s^-1)\n');
            fprintf('\t\t---------------------------------\n');
            for i=1:10
                fprintf('\t\t%d\t|\t%f\t|\t%f\n', i, analisisObj.Tn(i), analisisObj.wn(i));
            end
            fprintf('\n');
            
            fprintf('-------------------------------------------------\n');
            fprintf('\n');
            
        end % disp function
        
    end % methods ModalEspectral
    
end % class ModalEspectral