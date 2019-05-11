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
%| Clase PatronDeCargasDinamico                                         |
%|                                                                      |
%| Este archivo contiene la definicion de la Clase                      |
%| PatronDeCargasDinamico.                                              |
%| PatronDeCargasDinamico es una subclase de la clase PatronDeCargas y  |
%| corresponde  a la  representacion de un  patron de  cargas dinamico  |
%| en  el   metodo  de   elementos  finitos  o  analisis  matricial  de |
%| estructuras.                                                         |
%| La clase PatronDeCargasDinamico  es una clase contenedor que guarda  |
%| y controla las cargas que son de caracter dinamico, los que se calcu |
%| lan usando el metodo de newmark.                                     |
%|                                                                      |
%| Programado: Pablo Pizarro @ppizarror.com                             |
%| Fecha: 10/04/2019                                                    |
%|______________________________________________________________________|
%
%  Properties (Access=private):
%       cargas
%       analisisObj
%       desModal
%  Methods:
%       patronDeCargasObj = PatronDeCargasDinamico(etiquetaPatronDeCargas,arregloCargas,analisisObj)
%       aplicarCargas(patronDeCargasObj,cpenzien,disipadores,cargaDisipador,betaObjetivo,
%           arregloDisipadores,iterDisipador,tolIterDisipador,betaGrafico)
%       disp(patronDeCargasObj)
%  Methods SuperClass (PatronDeCargas):
%  Methods SuperClass (ComponenteModelo):
%       etiqueta = obtenerEtiqueta(componenteModeloObj)
%       e = equals(componenteModeloObj,obj)
%       objID = obtenerIDObjeto(componenteModeloObj)

classdef PatronDeCargasDinamico < PatronDeCargas
    
    properties(Access = private)
        cargas % Variable que guarda en un arreglo de celdas todas las cargas aplicadas en el patron de cargas
        analisisObj % Guarda el objeto de analisis con tal de obtener M, K, C y el vector de influencia
        desModal % Realiza descomposicion modal
    end % properties PatronDeCargasDinamico
    
    methods(Access = public)
        
        function patronDeCargasObj = PatronDeCargasDinamico(etiquetaPatronDeCargas, ...
                arregloCargas, analisisObj, varargin)
            % PatronDeCargasDinamico: es el constructor de la clase PatronDeCargas
            %
            % patronDeCargasObj = PatronDeCargasDinamico(etiquetaPatronDeCargas,arregloCargas,analisisObj,varargin)
            %
            % Parametros opcionales:
            %   'desmodal'  Ejecuta la condensacion modal
            %
            % Crea un objeto de la clase PatronDeCargas, con un identificador unico
            % (etiquetaPatronDeCargas) y guarda el arreglo con las cargas (arregloCargas)
            % a aplicar en el modelo
            
            % Si no se pasan argumentos se crean vacios
            if nargin == 0
                etiquetaPatronDeCargas = '';
            end % if
            
            % Llamamos al constructor de la SuperClass que es la clase ComponenteModelo
            patronDeCargasObj = patronDeCargasObj@PatronDeCargas(etiquetaPatronDeCargas);
            
            % Obtiene parametros opcionales
            p = inputParser;
            p.KeepUnmatched = true;
            addOptional(p, 'desmodal', true);
            parse(p, varargin{:});
            r = p.Results;
            
            % Se guarda el arreglo con las cargas
            patronDeCargasObj.cargas = arregloCargas;
            
            % Define propiedades
            patronDeCargasObj.patronEsDinamico = true;
            
            % Guarda el analisis
            patronDeCargasObj.analisisObj = analisisObj;
            
            % Descomposicion modal
            patronDeCargasObj.desModal = r.desmodal;
            
        end % PatronDeCargasDinamico constructor
        
        function aplicarCargas(patronDeCargasObj, cpenzien, disipadores, cargaDisipador, ...
                betaObjetivo, arregloDisipadores, iterDisipador, tolIterDisipador, ...
                betaGrafico, factor)
            % aplicarCargas: es un metodo de la clase PatronDeCargasDinamico que
            % se usa para aplicar las cargas guardadas en el Patron de Cargas
            %
            % aplicarCargas(patronDeCargasObj,cpenzien,disipadores,cargaDisipador,betaObjetivo,
            %   arregloDisipadores,iterDisipador,tolIterDisipador,betaGrafico,factor)
            %
            % Aplica las cargas que estan guardadas en el PatronDeCargasDinamico
            % (patronDeCargasObj), es decir, se aplican las cargas sobre los nodos
            % y elementos
            
            if disipadores
                
                % Inicio del proceso de iteracion
                tinicio = cputime;
                tcalculo = 0;
                
                % Genera lista de disipadores del modelo
                disipadorNombres = getClassnameCell(arregloDisipadores);
                disipadorNombresK = disipadorNombres.keys();
                disipadorNombresC = disipadorNombres.values();
                totalDisipador = length(arregloDisipadores);
                fprintf('\tDisipadores del modelo: %d\n', totalDisipador);
                for i = 1:length(disipadorNombresK)
                    fprintf('\t\t%d %s\n', disipadorNombresC{i}, disipadorNombresK{i});
                end % for i
                
                % Se busca el indice de la carga objetivo
                totalCargas = length(patronDeCargasObj.cargas);
                indiceCargaObjetivo = 0; % Indica si se usa una carga especifica para el calculo de v0 del disipador
                for i = 1:totalCargas
                    if cargaDisipador.equals(patronDeCargasObj.cargas{i})
                        if ~patronDeCargasObj.cargas{i}.cargaActivada()
                            error('La carga objetivo del disipador esta desactivada');
                        end
                        cargaDisipadorObj = patronDeCargasObj.cargas{i};
                        fprintf('\tSe calculan los disipadores usando la carga %s\n', cargaDisipadorObj.obtenerEtiqueta);
                        indiceCargaObjetivo = i;
                        break;
                    end
                end % for i
                if indiceCargaObjetivo == 0
                    error('La carga objetivo del disipador no existe en el patron de cargas');
                end
                
                % Calcula beta inicial del modelo
                fprintf('\t\tCalculando amortiguamiento inicial del modelo sin los disipadores actualizados\n');
                
                % Al realizar esto el nuevo desplazamiento se guarda en la
                % carga
                patronDeCargasObj.calcularCargaGenerica(cpenzien, ...
                    false, indiceCargaObjetivo, true, 0, ...
                    factor); % No uso disipadores
                
                % Calcula w asociado al modo que mueve mas energia
                w = patronDeCargasObj.analisisObj.calcularModosEnergia(cargaDisipadorObj, false);
                w1 = w(1, 2);
                nmodo1 = w(1, 1);
                fprintf('\t\tPara la carga objetivo el modo que mueve mas energia (%.1f%%) es el %d, w: %.2frad/s\n', ...
                    w(1, 5)*100, w(1, 1), w(1, 2));
                
                % Se realiza iteracion
                iterDisipador = floor(iterDisipador);
                if iterDisipador > 0
                    
                    % Output
                    fprintf('\tParametros iteracion:\n\t\titerDisipador: %d\n\t\ttolIterDisipador: %.3f\n\t\tbetaObjetivo: %.3f\n', ...
                        iterDisipador, tolIterDisipador, betaObjetivo);
                    fprintf('\tIniciando iteraciones\n');
                    
                    % Variables que guardan los estados de beta
                    vo_i = zeros(1, length(arregloDisipadores));
                    vo_ii = zeros(1, length(arregloDisipadores));
                    
                    % Beta del grafico
                    betagr_b = [];
                    betagr_i = 0;
                    
                    % Calcula beta sin actualizar disipadores
                    beta = patronDeCargasObj.calcularBetaModelo(cpenzien, nmodo1, w1);
                    betagr_i = betagr_i + 1; % Guarda en el arreglo
                    betagr_b(betagr_i) = beta;
                    fprintf('\t\tAmortiguamiento inicial: %.4f\n', beta);
                    
                    % Actualiza el disipador
                    fprintf('\t\tIteracion 1:\n');
                    fprintf('\t\t\tActualizando disipadores\n');
                    for i = 1:totalDisipador
                        arregloDisipadores{i}.actualizarDisipador(w1, cargaDisipadorObj);
                        nodos = arregloDisipadores{i}.obtenerNodos();
                        vo_i(i) = arregloDisipadores{i}.calcularv0(nodos, cargaDisipadorObj);
                    end % for i
                    beta = patronDeCargasObj.calcularBetaModelo(cpenzien, nmodo1, w1);
                    fprintf('\t\t\tbeta: %.4f\n', beta);
                    betagr_i = betagr_i + 1; % Guarda en el arreglo
                    betagr_b(betagr_i) = beta;
                    % betaAnt = beta; % Guarda el beta anterior
                    pause(0.1);
                    
                    % Realiza las iteraciones
                    for j = 2:(iterDisipador - 1)
                        
                        % Calcula la carga
                        fprintf('\t\tIteracion %d:\n', j);
                        patronDeCargasObj.calcularCargaGenerica(cpenzien, ...
                            true, indiceCargaObjetivo, true, 0, factor);
                        
                        % Actualiza los disipadores
                        fprintf('\t\t\tActualizando disipadores\n');
                        for i = 1:totalDisipador
                            arregloDisipadores{i}.actualizarDisipador(w1, cargaDisipadorObj);
                            nodos = arregloDisipadores{i}.obtenerNodos();
                            vo_ii(i) = arregloDisipadores{i}.calcularv0(nodos, cargaDisipadorObj);
                        end % for i
                        
                        % Calcula beta
                        beta = patronDeCargasObj.calcularBetaModelo(cpenzien, nmodo1, w1);
                        fprintf('\t\t\tbeta: %.4f\n', beta);
                        betagr_i = betagr_i + 1; % Guarda en el arreglo
                        betagr_b(betagr_i) = beta;
                        
                        delta_vo = abs(vo_i-vo_ii);
                        tol_i = max(delta_vo);
                        fprintf('\t\t\tdelta: %.4f\n', tol_i);
                        if tol_i <= tolIterDisipador
                            fprintf('\t\t\tSe ha logrado la convergencia del modelo con disipadores\n');
                            if betaObjetivo > 0
                                betaSign = '';
                                if beta >= betaObjetivo
                                    fprintf('\t\t\tSe ha logrado el amortiguamiento objetivo\n');
                                    betaSign = '+';
                                else
                                    fprintf('\t\t\tNo se ha logrado el amortiguamiento objetivo\n');
                                end
                                fprintf('\t\t\t\tDiferencia: %s%.1f%%\n', ...
                                    betaSign, (beta - betaObjetivo)/betaObjetivo*100);
                            end
                            break;
                        elseif j == iterDisipador && tol_i > tolIterDisipador
                            fprintf('\t\t\tNo se ha logrado la convergencia del modelo con disipadores\n');
                            fprintf('\t\t\tSe debe aumentar el numero de iteraciones\n');
                        end
                        vo_i = vo_ii;
                        
                        % Guarda el beta anterior
                        % betaAnt = beta;
                        
                    end % for j
                    tcalculo = cputime - tinicio;
                    fprintf('\t\tProceso calculo disipador finalizado en %.3f segundos\n', tcalculo);
                    
                    % Con los disipadores calcula todas las cargas
                    fprintf('\tAmortiguamiento del modelo: %.3f\n', beta);
                    fprintf('\tInicio calculo de cargas con los disipadores actualizados\n');
                    
                    % Grafica si aplica
                    if betaGrafico
                        fig_title = 'Variacion amortiguamiento iteraciones';
                        plt = figure('Name', fig_title, 'NumberTitle', 'off');
                        movegui(plt, 'center');
                        betaxticks = 0:1:(betagr_i - 1);
                        plot(betaxticks, betagr_b, '-', 'LineWidth', 1.4, 'Color', 'black');
                        % grid on;
                        xlabel('Numero iteracion');
                        ylabel('Amortiguamiento');
                        title(fig_title);
                        set(gca, 'XTick', betaxticks);
                        if betaObjetivo > 0
                            hold on;
                            drawVyLine(betaObjetivo, 'b--', 1.2);
                            legend({'Variacion amortiguamiento', sprintf('Amortiguamiento objetivo: %.3f', ...
                                betaObjetivo)}, 'location', 'southeast');
                        end
                        drawnow();
                        pause(0.1);
                    end
                    
                else
                    
                    % No se iteran los disipadores
                    beta = patronDeCargasObj.calcularBetaModelo(cpenzien, nmodo1, w1);
                    fprintf('\tNo se realizo el proceso de iteracion de los disipadores\n');
                    fprintf('\tAmortiguamiento del modelo: %.3f\n', beta);
                    fprintf('\tInicio calculo de cargas con los disipadores sin actualizar\n');
                    
                end
                
                % Calcula todas las cargas con los disipadores actualizados
                patronDeCargasObj.calcularCargaGenerica(cpenzien, true, 0, ...
                    false, tcalculo, factor);
                
            else
                
                % Calcula todas las cargas sin usar disipadores
                patronDeCargasObj.calcularCargaGenerica(cpenzien, false, 0, ...
                    false, 0, factor);
                
            end
            
        end % aplicarCargas function
        
        function disp(patronDeCargasObj)
            % disp: es un metodo de la clase PatronDeCargasDinamico que se usa
            % para imprimir en el command Window la informacion del Patron de Cargas
            %
            % disp(patronDeCargasObj)
            %
            % Imprime la informacion guardada en el Patron de Cargas Dinamico
            % (patronDeCargasObj) en pantalla
            
            fprintf('Propiedades patron de cargas dinamico:\n');
            disp@ComponenteModelo(patronDeCargasObj);
            dispMetodoTEFAME();
            
        end % disp function
        
    end % methods PatronDeCargasDinamico
    
    methods(Access = private)
        
        function beta = calcularBetaModelo(patronDeCargasObj, cpenzien, phi1, w1)
            % calcularBetaModelo: Calcula el amortiguamiento considerando
            % disipadores
            %
            % calcularBetaModelo(patronDeCargasObj, phi1, w1)
            
            m = patronDeCargasObj.analisisObj.obtenerMatrizMasa();
            c = patronDeCargasObj.analisisObj.obtenerMatrizAmortiguamiento(~cpenzien);
            cd = patronDeCargasObj.analisisObj.obtenerMatrizAmortiguamientoDisipadores();
            phi = patronDeCargasObj.analisisObj.obtenerMatrizPhi();
            phi1 = phi(:, phi1);
            
            beta = (phi1' * (c + cd) * phi1) / (2 * w1 * phi1' * m * phi1);
            
        end % calcularBetaModelo function
        
        function calcularCargaGenerica(patronDeCargasObj, cpenzien, disipadores, ...
                cargaIndiceDisipador, calculaDisipadores, tcalculoAnterior, factor)
            % calcularCargaGenerica: Funcion que calcula el tema de las
            % cargas, es generica en cuanto al calculo. Esta puede
            % funcionar tanto si hay o no hay disipadores
            %
            % calcularCargaGenerica(patronDeCargasObj,cpenzien,disipadores,
            %   cargaIndiceDisipador,calculaDisipadores,tcalculoAnterior,
            %   factor)
            
            % Obtiene los parametros de la estructura
            k = patronDeCargasObj.analisisObj.obtenerMatrizRigidez();
            m = patronDeCargasObj.analisisObj.obtenerMatrizMasa();
            c = patronDeCargasObj.analisisObj.obtenerMatrizAmortiguamiento(~cpenzien);
            cd = patronDeCargasObj.analisisObj.obtenerMatrizAmortiguamientoDisipadores();
            r = patronDeCargasObj.analisisObj.obtenerVectorInfluencia();
            phi = patronDeCargasObj.analisisObj.obtenerMatrizPhi();
            
            % Chequea que las dimensiones sean apropiadas
            if ~equalMatrixSize(k, m) || ~equalMatrixSize(m, c) || length(r) ~= length(m)
                error('Tamano incorrecto de matrices K, M, C, r');
            end
            
            % Agrega o no disipadores
            if disipadores
                if ~calculaDisipadores
                    fprintf('\tPatron de cargas dinamico considera el uso de disipadores\n');
                end
                c = c + cd;
            else
                if ~calculaDisipadores
                    fprintf('\tPatron de cargas dinamico no considera el uso de disipadores\n');
                end
            end
            
            % Descomposicion modal
            if patronDeCargasObj.desModal
                k = phi' * k * phi;
                mmodal = phi' * m * phi;
                c = phi' * c * phi;
                if ~calculaDisipadores
                    fprintf('\tPatron de cargas usa descomposicion modal\n');
                end
            else
                if ~calculaDisipadores
                    fprintf('\tPatron de cargas no usa descomposicion modal\n');
                end
                mmodal = m;
            end
            
            if cpenzien
                if ~calculaDisipadores
                    fprintf('\tPatron de cargas dinamico usa amortiguamiento de Wilson-Penzien\n');
                end
            else
                if ~calculaDisipadores
                    fprintf('\tPatron de cargas dinamico usa amortiguamiento de Rayleigh\n');
                end
            end
            
            % Calcula las inversas
            minv = mmodal^(-1);
            
            % Se calcula carga una de las cargas dinamicas
            tInicioProceso = cputime;
            totalCargas = length(patronDeCargasObj.cargas);
            usaCargaIndice = false; % Indica si se usa una carga especifica para el calculo de v0 del disipador
            for i = 1:totalCargas
                
                % Si se quiere calcular un disipador se genera el codigo
                % con una sola carga
                if cargaIndiceDisipador ~= 0
                    i = cargaIndiceDisipador; %#ok<FXSET>
                    usaCargaIndice = true;
                end
                
                % Chequea que la carga sea dinamica
                if ~isa(patronDeCargasObj.cargas{i}, 'CargaDinamica')
                    error('PatronDeCargasDinamico solo puede resolver cargas dinamicas');
                end
                
                % Obtiene la carga
                tInicio = cputime;
                if ~calculaDisipadores
                    fprintf('\t\tAplicando carga %s (%d/%d)\n', ...
                        patronDeCargasObj.cargas{i}.obtenerEtiqueta(), i, totalCargas);
                end
                
                % Chequea que la carga este activa
                if ~patronDeCargasObj.cargas{i}.cargaActivada()
                    fprintf('\t\t\tLa carga %s esta desactivada\n', ...
                        patronDeCargasObj.cargas{i}.obtenerEtiqueta());
                    continue;
                end
                
                % Genera las cargas
                if ~calculaDisipadores
                    fprintf('\t\t\tGenerando la matriz de cargas\n');
                end
                p = patronDeCargasObj.cargas{i}.calcularCarga(factor, m, r, ~calculaDisipadores);
                
                % Descomposicion modal
                if patronDeCargasObj.desModal
                    pmodal = phi' * p;
                else
                    pmodal = p;
                end
                
                % Resuelve newmark
                [u, du, ddu] = patronDeCargasObj.newmark(k, mmodal, minv, ...
                    c, pmodal, patronDeCargasObj.cargas{i}.dt, 0, 0);
                
                % Aplica descomposicion si aplica
                if patronDeCargasObj.desModal
                    u = phi * u;
                    du = phi * du;
                    ddu = phi * ddu;
                end
                
                % Guarda los resultados
                patronDeCargasObj.cargas{i}.guardarCarga(p);
                patronDeCargasObj.cargas{i}.guardarDesplazamiento(u);
                patronDeCargasObj.cargas{i}.guardarVelocidad(du);
                patronDeCargasObj.cargas{i}.guardarAceleracion(ddu);
                patronDeCargasObj.cargas{i}.amortiguamientoRayleigh(~cpenzien);
                patronDeCargasObj.cargas{i}.usoDisipadores(disipadores);
                patronDeCargasObj.cargas{i}.descomposicionModal(patronDeCargasObj.desModal);
                if ~calculaDisipadores
                    fprintf('\n\t\t\tSe completo calculo en %.3f segundos\n', cputime-tInicio);
                end
                
                % Si ya se calculo la carga objetivo para el disipador
                % retorna
                if usaCargaIndice
                    fprintf('\n');
                    break;
                end
                
            end % for i
            
            if ~calculaDisipadores
                fprintf('\tProceso finalizado en %.3f segundos\n', cputime-tInicioProceso+tcalculoAnterior);
                dispMetodoTEFAME();
            end
            
        end % calcularCargaGenerica function
        
        function [x, v, z] = newmark(patronDeCargasObj, k, m, minv, c, p, dt, xo, vo) %#ok<*INUSL>
            % Newmark: es un metodo de la clase ModalEspectral que se
            % usa para obtener los valores de aceleracion, velociadad y desplazamiento
            % de los grados de libertad a partir del metodo de Newmark
            %
            % [x,v,z]=newmark(patronDeCargasObj,k,m,minv,c,p,dt,xo,vo)
            
            % Define coeficientes
            alpha = 0;
            gamma = 1 / 2 - alpha;
            beta = 1 / 4 * (1 - alpha)^2;
            
            n = length(p);
            ngl = length(k);
            x = zeros(ngl, length(p));
            v = zeros(ngl, length(p));
            z = zeros(ngl, length(p));
            x(:, 1) = xo;
            v(:, 1) = vo;
            z(:, 1) = minv * (p(:, 1) - c * v(:, 1) - k * x(:, 1));
            c1 = 1 / (dt^2 * beta);
            c2 = 1 / (dt * beta);
            c3 = gamma / (dt * beta);
            c4 = 1 - gamma / beta;
            c5 = 1 - gamma / (2 * beta);
            c6 = 1 / (2 * beta) - 1;
            ks = c1 * m + (1 + alpha) * c3 * c + (1 + alpha) * k; %hht
            ks_inv = ks^(-1);
            ps = zeros(ngl, length(p));
            reverse_porcent = '';
            
            for i = 1:1:(n - 1)
                
                % Calcula
                ps(:, i+1) = p(:, i+1) + k * alpha * x(:, i) + m * (c1 * x(:, i) + c2 * v(:, i) + c6 * z(:, i)) ...
                    +c * ((1 + alpha) * c3 * x(:, i) + (alpha - (1 + alpha) * c4) * v(:, i) - (1 + alpha) * c5 * dt * z(:, i));% HHT
                x(:, i+1) = ks_inv * ps(:, i+1);
                v(:, i+1) = (gamma / (beta * dt)) * (x(:, i+1) - x(:, i)) + (1 - gamma / beta) * v(:, i) + dt * (1 - gamma / (2 * beta)) * z(:, i);
                z(:, i+1) = (1 / (beta * dt^2)) * (x(:, i+1) - x(:, i)) - (1 / (beta * dt)) * v(:, i) - (1 / (2 * beta) - 1) * z(:, i);
                
                % Imprime estado
                msg = sprintf('\t\t\tCalculando ... %.1f/100', i/(n - 1)*100);
                fprintf([reverse_porcent, msg]);
                reverse_porcent = repmat(sprintf('\b'), 1, length(msg));
                
            end % for i
            
        end % newmark function
        
    end % methods PatronDeCargasDinamico
    
end % class PatronDeCargasDinamico