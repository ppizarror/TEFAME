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
%|       Estudiante de Magister en Ingeniería Civil Estructural         |
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
    
    properties(Access = public)
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
        rm % Vector influencia
        Lm % Factor de participacion modal
        Mmeff % Masa modal efectiva
        Mmeffacum % Masa modal efectiva acumulada
        Mmeffacump % Masa modal efectiva acumulada porcentaje
        Mtotal % Masa total del modelo
        analisisFinalizado % Indica que el analisis ha sido realizado
        numModos % Numero de modos del analisis
        numDG % Numero de grados de libertad por modo despues del analisis
        cRayleigh % Matriz de amortiguamiento de Rayleigh
        cPenzien % Matriz de amortiguamiento de Wilson-Penzien
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
            analisisObj.analisisFinalizado = false;
            
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
        
        function analizar(analisisObj, nModos, beta)
            % analizar: es un metodo de la clase ModalEspectral que se usa para
            % realizar el analisis estatico
            %
            % analizar(analisisObj,nModos,beta)
            % Analiza estaticamente el modelo lineal y elastico sometido a un
            % set de cargas, requiere el numero de modos para realizar el
            % analisis y de los modos conocidos con sus beta
            
            % Ajusta variables de entrada
            if ~exist('nModos', 'var')
                nModos = 20;
            end
            betasz = size(beta);
            if betasz(1) ~= 1
                if betasz(2) == 1
                    beta = beta';
                else
                    error('Vector beta incorrecto, debe ser de tamaño 1x2');
                end
            end
            
            % Se definen los grados de libertad por nodo -> elementos
            analisisObj.definirNumeracionGDL();
            
            % Se aplica patron de carga
            analisisObj.modeloObj.aplicarPatronesDeCargas();
            
            % Se calcula la matriz de rigidez
            analisisObj.ensamblarMatrizRigidez();
            
            % Se calcula la matriz de masa
            analisisObj.ensamblarMatrizMasa();
            analisisObj.Mtotal = sum(diag(analisisObj.Mt));
            
            % Se ensambla el vector de fuerzas
            analisisObj.ensamblarVectorFuerzas();
            
            % Obtiene los grados de libertad
            ngdl = length(analisisObj.Mt); % Numero de grados de libertad
            ndg = analisisObj.modeloObj.obtenerNumerosGDL(); % Grados de libertad por nodo
            nModos = min(nModos, ngdl);
            analisisObj.numModos = nModos;
            
            % Resuelve la ecuacion del sistema, para ello crea la matriz
            % inversa de la masa y calcula los valores propios
            invMt = zeros(ngdl, ngdl);
            for i = 1:ngdl
                invMt(i, i) = 1 / analisisObj.Mt(i, i);
            end
            sysMat = invMt * analisisObj.Kt;
            
            [modalPhin, syseig] = eigs(sysMat, nModos, 'smallestabs');
            syseig = diag(syseig);
            modalPhi = modalPhin;
            
            % Calcula las frecuencias del sistema
            modalWn = sqrt(syseig);
            modalTn = (modalWn.^-1) .* 2 * pi; % Calcula los periodos
            
            % Calcula las matrices
            modalMmt = modalPhin' * analisisObj.Mt * modalPhin;
            modalPhin = modalPhin * diag(diag(modalMmt).^-0.5);
            modalMm = diag(diag(modalPhin'*analisisObj.Mt*modalPhin));
            modalKm = diag(diag(modalPhin'*analisisObj.Kt*modalPhin));
            
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
            
            % Asigna valores
            analisisObj.Tn = zeros(nModos, 1);
            analisisObj.wn = zeros(nModos, 1);
            analisisObj.phin = zeros(ngdl, nModos);
            analisisObj.Mm = modalMm;
            analisisObj.Km = modalKm;
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
            analisisObj.Mmeff = zeros(nModos, ndg);
            analisisObj.Mmeffacum = zeros(nModos, ndg);
            analisisObj.Mmeffacump = zeros(nModos, ndg);
            
            % Recorre cada grado de libertad (horizontal, vertical, giro)
            for j = 1:ndg
                analisisObj.Lm(:, j) = analisisObj.phin' * analisisObj.Mt * analisisObj.rm(:, j);
                analisisObj.Mmeff(:, j) = analisisObj.Lm(:, j).^2 ./ diag(modalMmt);
                
                mtot = sum(analisisObj.Mmeff(:, j));
                analisisObj.Mmeff(:, j) = analisisObj.Mmeff(:, j) ./ mtot;
                analisisObj.Mmeffacum(1, j) = analisisObj.Mmeff(1, j);
                for i = 2:nModos
                    analisisObj.Mmeffacum(i, j) = analisisObj.Mmeffacum(i-1, j) + analisisObj.Mmeff(i, j);
                end
                
                analisisObj.Mmeffacump(:, j) = analisisObj.Mmeffacum(:, j);
            end
            
            % CALCULO DE AMORTIGUAMIENTO DE RAYLEIGH
            
            % Se declaran dos amortiguamientos críticos asociados a dos modos
            % diferentes indicando si es horizontal o vertical (h o v)

            modocR= [1 , 3];
            direcR = ['h' , 'h'];
            betacR = [2 / 100 , 5/100];
            countcR = [0 , 0];
            m = 0;
            n = 0;
            analisisObj.Mmeff
            for i = 1:nModos
               if analisisObj.Mmeff(i, 1) > max(analisisObj.Mmeff(i, 2),analisisObj.Mmeff(i, 3))
                   countcR(1) = countcR(1) + 1;
                   if direcR(1) == 'h' && modocR(1) == countcR(1)
                       m = i;
                   elseif direcR(2) == 'h' && modocR(2) == countcR(1)
                       n = i;
                   end
               elseif analisisObj.Mmeff(i, 2) > max(analisisObj.Mmeff(i, 1),analisisObj.Mmeff(i, 3))  
                   countcR(2) = countcR(2) + 1;
                   if direcR(1) == 'v' && modocR(1) == countcR(2)
                       m = i;
                   elseif direcR(2) == 'h' && modocR(2) == countcR(2)
                       n = i;
                   end
               end 
            end
            Calcular_cRayleigh = 1;
            if m == 0 || n == 0
                Calcular_cRayleigh = 0;
                disp('Se requiere aumentar el numero de modos para determinar matriz de amortiguamiento de Rayleigh')
            end
            if Calcular_cRayleigh == 1
                w = analisisObj.wn;
                a = (2 * w(m) * w(n)) / (w(n)^2 - w(m)^2) .* [w(n), -w(m); ...
                    -1 / w(n), 1 / w(m)] * betacR';
                analisisObj.cRayleigh = a(1) .* analisisObj.Mt + a(2) .* analisisObj.Kt;
            end
            % CALCULO DE AMORTIGUAMIENTO DE WILSON-PENZIEN
            
            % Se declaran todos los amortiguamientos críticos del sistema,
            % (horizontal, vertical y traslacional)
            
            betacP = [5 / 100 , 2 / 100 , 0 / 100];
            d = zeros(nModos,nModos);
            w = analisisObj.wn;
            Mn = modalMmt;
            for i = 1:nModos
               if analisisObj.Mmeff(i, 1) > max(analisisObj.Mmeff(i, 2),analisisObj.Mmeff(i, 3))
                   d(i,i) = 2 * betacP(1) * w(i) / Mn(i,i); 
               elseif analisisObj.Mmeff(i, 2) > max(analisisObj.Mmeff(i, 1),analisisObj.Mmeff(i, 3))  
                   d(i,i) = 2 * betacP(2) * w(i) / Mn(i,i); 
               else
                   d(i,i) = 2 * betacP(3) * w(i) / Mn(i,i); 
               end 
            end
            analisisObj.cPenzien = analisisObj.Mt*modalPhi*d*modalPhi'*analisisObj.Mt;
                       
            % Se resuelve la ecuacion
            analisisObj.u = (analisisObj.Kt^-1) * analisisObj.F;
            
            % Actualiza el modelo
            analisisObj.modeloObj.actualizar(analisisObj.u);
            
            % Termina el analisis
            analisisObj.analisisFinalizado = true;
            analisisObj.numDG = ndg;
            
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
        
        
        function plt = plot(analisisObj, modo, factor, numCuadros, guardaGif)
            %PLOTMODELO Grafica un modelo
            %
            % plt = plot(modo,factor,velocidad)
            
            deformada = false;
            if exist('modo', 'var')
                deformada = true;
            end
            
            if ~exist('factor', 'var')
                factor = 2;
            end
            
            if ~exist('numCuadros', 'var')
                numCuadros = 0;
            end
            
            guardarGif = false;
            if exist('guardaGif', 'var')
                guardarGif = true;
            end
            
            % Calcula los limites
            [limx, limy, limz] = analisisObj.obtenerLimitesDeformada(modo, factor);
            
            % Grafica la estructura
            plt = figure();
            fig_num = get(gcf, 'Number');
            hold on;
            grid on;
            
            plotAnimado(analisisObj, deformada, modo, factor, 1, limx, limy, limz);
            hold off;
            fprintf('Generando animacion analisis modal espectral:\n');
            if numCuadros ~= 0
                
                % Obtiene el numero de cuadros
                t = 0;
                dt = 2 * pi / numCuadros;
                reverse_porcent = '';
                for i = 1:numCuadros
                    
                    % Si el usuario cierra el plot termina de graficar
                    if ~ishandle(plt) || ~ishghandle(plt)
                        delete(plt);
                        close; % Cierra el grafico
                        return;
                    end
                    
                    t = t + dt;
                    figure(fig_num); % Atrapa el foco
                    plotAnimado(analisisObj, deformada, modo, factor, sin(t), limx, limy, limz);
                    if guardarGif
                        frame = getframe(fig_num);
                        im = frame2im(frame);
                        [imind, cm] = rgb2ind(im, 256);
                        if i == 1
                            imwrite(imind, cm, guardaGif, 'gif', 'Loopcount', inf, 'DelayTime', 0.1);
                        else
                            imwrite(imind, cm, guardaGif, 'gif', 'WriteMode', 'append', 'DelayTime', 0.1);
                        end
                    end
                    hold off;
                    
                    msg = sprintf('\tCalculando... %.1f/100', i/numCuadros*100);
                    fprintf([reverse_porcent, msg]);
                    reverse_porcent = repmat(sprintf('\b'), 1, length(msg));
                    
                end
                if guardarGif
                    fprintf('\n\tGuardando animacion gif en: %s\n', guardaGif);
                end
                
            end
            
        end % plot function
        
        function [limx, limy, limz] = obtenerLimitesDeformada(analisisObj, modo, factor)
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
                coord1i = nodoElemento{1}.obtenerCoordenadas();
                coord2i = nodoElemento{2}.obtenerCoordenadas();
                def1 = analisisObj.obtenerDeformadaNodo(nodoElemento{1}, modo, gdl);
                def2 = analisisObj.obtenerDeformadaNodo(nodoElemento{2}, modo, gdl);
                coord1 = coord1i + def1 .* factor;
                coord2 = coord2i + def2 .* factor;
                limx(1) = min([limx(1), coord1(1), coord2(1)]);
                limy(1) = min([limy(1), coord1(2), coord2(2)]);
                limx(2) = max([limx(2), coord1(1), coord2(1)]);
                limy(2) = max([limy(2), coord1(2), coord2(2)]);
                if gdl == 3
                    limz(1) = min([limz(1), coord1(3), coord2(3)]);
                    limz(2) = max([limz(2), coord1(3), coord2(3)]);
                end
                coord1 = coord1i - def1 .* factor;
                coord2 = coord2i - def2 .* factor;
                limx(1) = min([limx(1), coord1(1), coord2(1)]);
                limy(1) = min([limy(1), coord1(2), coord2(2)]);
                limx(2) = max([limx(2), coord1(1), coord2(1)]);
                limy(2) = max([limy(2), coord1(2), coord2(2)]);
                if gdl == 3
                    limz(1) = min([limz(1), coord1(3), coord2(3)]);
                    limz(2) = max([limz(2), coord1(3), coord2(3)]);
                end
            end
            
        end % obtenerLimitesDeformada function
        
        function plotAnimado(analisisObj, deformada, modo, factor, phif, limx, limy, limz)
            % Anima el grafico en funcion del numero del modo
            
            % Carga objetos
            nodoObjetos = analisisObj.modeloObj.obtenerNodos();
            numeroNodos = length(nodoObjetos);
            
            % Obtiene cuantos GDL tiene el modelo
            gdl = 2;
            j = 1;
            for i = 1:numeroNodos
                coords = nodoObjetos{i}.obtenerCoordenadas();
                ngdlid = length(coords);
                gdl = max(gdl, ngdlid);
                
                if ~nodoObjetos{i}.tipoApoyoRestringido() && ~deformada
                    if ngdlid == 2
                        plot(coords(1), coords(2), 'b.', 'MarkerSize', 10);
                    else
                        plot3(coords(1), coords(2), coords(3), 'b.', 'MarkerSize', 10);
                    end
                    if j == 1
                        hold on;
                    end
                    j = j + 1;
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
                
                if ~deformada
                    
                    if gdl == 2
                        plot([coord1(1), coord2(1)], [coord1(2), coord2(2)], 'b-', 'LineWidth', 0.5);
                    else
                        plot3([coord1(1), coord2(1)], [coord1(2), coord2(2)], [coord1(3), coord2(3)], ...
                            'b-', 'LineWidth', 0.5);
                    end
                
                else
                    
                    def1 = analisisObj.obtenerDeformadaNodo(nodoElemento{1}, modo, gdl);
                    def2 = analisisObj.obtenerDeformadaNodo(nodoElemento{2}, modo, gdl);
                    
                    % Suma las deformaciones
                    coord1 = coord1 + def1 .* factor * phif;
                    coord2 = coord2 + def2 .* factor * phif;
                    
                    % Grafica
                    if gdl == 2
                        plot([coord1(1), coord2(1)], [coord1(2), coord2(2)], 'k-', 'LineWidth', 1.25);
                    else
                        plot3([coord1(1), coord2(1)], [coord1(2), coord2(2)], [coord1(3), coord2(3)], ...
                            'k-', 'LineWidth', 1.25);
                    end
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
                    def = analisisObj.obtenerDeformadaNodo(nodoObjetos{i}, modo, gdl);
                    coords = coords + def .* factor * phif;
                    
                    if ~nodoObjetos{i}.tipoApoyoRestringido()
                        if ngdlid == 2
                            plot(coords(1), coords(2), 'k.', 'MarkerSize', 20);
                        else
                            plot3(coords(1), coords(2), coords(3), 'k.', 'MarkerSize', 20);
                        end
                    end
                    
                end
                
            end
            
            % Setea el titulo
            if ~deformada
                title('Analisis modal espectral');
            else
                a = sprintf('Analisis modal espectral - modo %d', modo);
                b = sprintf('Escala deformacion x%d', factor);
                title({a; b});
            end
            grid on;
            
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
            
        end % plotAnimado function
        
        function def = obtenerDeformadaNodo(analisisObj, nodo, modo, gdl)
            % Obtiene la deformada de un nodo
            
            ngdl = nodo.obtenerGDLID();
            def = zeros(gdl, 1);
            gdl = min(gdl, length(ngdl));
            for i = 1:gdl
                if ngdl(i) ~= 0
                    def(i) = analisisObj.phin(ngdl(i), modo);
                end
            end
            
        end % obtenerDeformadaNodo function
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Metodos para mostar la informacion del Analisis Modal Espectral en pantalla
        
        function disp(analisisObj)
            % disp: es un metodo de la clase ModalEspectral que se usa para imprimir en
            % command Window la informacion del analisis espectral realizado
            %
            % disp(modeloObj)
            % Imprime la informacion guardada en el ModalEspectral (analisisObj) en
            % pantalla
            
            if ~analisisObj.analisisFinalizado
                fprintf('El analisis modal aun no ha sido calculado');
            end
            
            fprintf('Propiedades analisis modal espectral:\n');
            
            % Muestra los grados de libertad
            fprintf('\tNumero de grados de libertad: %d\n', analisisObj.numeroGDL);
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
            
            fprintf('\tPeriodos y participacion modal:\n');
            analisisObj.numDG = 2;
            if analisisObj.numDG == 2
                fprintf('\t\tN°\t|\tT (s)\t|\tUx\t\t|\tUy\t\t|\tSum Ux\t|\tSum Uy\t|\n');
                fprintf('\t\t------------------------------------------------------------------\n');
            elseif analisisObj.numDG == 3
                fprintf('\t\tN°\t|\tT (s)\t|\tUx\t\t|\tUy\t\t|\tUz\t\t|\tSum Ux\t|\tSum Uy\t|\tSum Uz\t|\n');
                fprintf('\t\t-----------------------------------------------------------------------------------------\n');
            end
            
            for i = 1:analisisObj.numModos
                if analisisObj.numDG == 2
                    fprintf('\t\t%d\t|\t%.3f\t|\t%.3f\t|\t%.3f\t|\t%.3f\t|\t%.3f\t|\t%.3f\n', i, analisisObj.Tn(i), ...
                        analisisObj.Mmeff(i, 1), analisisObj.Mmeff(i, 2), ...
                        analisisObj.Mmeffacump(i, 1), analisisObj.Mmeffacump(i, 2));
                elseif analisisObj.numDG == 3
                    fprintf('\t\t%d\t|\t%.3f\t|\t%.3f\t|\t%.3f\t|\t%.3f\t|\t%.3f\t|\t%.3f\t|\t%.3f\t|\t%.3f\n', i, analisisObj.Tn(i), ...
                        analisisObj.Mmeff(i, 1), analisisObj.Mmeff(i, 2), analisisObj.Mmeff(i, 3), ...
                        analisisObj.Mmeffacump(i, 1), analisisObj.Mmeffacump(i, 2), analisisObj.Mmeffacump(i, 3));
                end
                fprintf('\n');
            end
            
            fprintf('\tMasa total de la estructura: %.3f\n', analisisObj.Mtotal);
            fprintf('-------------------------------------------------\n');
            fprintf('\n');
           
        end % disp function
        
    end % methods ModalEspectral
    
end % class ModalEspectral