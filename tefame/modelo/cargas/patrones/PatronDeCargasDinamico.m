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
%       aplicarCargas(patronDeCargasObj)
%       disp(patronDeCargasObj)
%  Methods SuperClass (PatronDeCargas):
%  Methods SuperClass (ComponenteModelo):
%       etiqueta = obtenerEtiqueta(componenteModeloObj)
%       e = equals(componenteModeloObj,obj)

classdef PatronDeCargasDinamico < PatronDeCargas
    
    properties(Access = private)
        cargas % Variable que guarda en un arreglo de celdas todas las cargas aplicadas en el patron de cargas
        analisisObj % Guarda el objeto de analisis con tal de obtener M, K, C y el vector de influencia
        desModal % Realiza descomposicion modal
    end % properties PatronDeCargasDinamico
    
    methods(Access = public)
        
        function patronDeCargasObj = PatronDeCargasDinamico(etiquetaPatronDeCargas, arregloCargas, analisisObj, varargin)
            % PatronDeCargasDinamico: es el constructor de la clase PatronDeCargas
            %
            % patronDeCargasObj = PatronDeCargasDinamico(etiquetaPatronDeCargas,arregloCargas,analisisObj,varargin)
            %
            % Parametros opcionales:
            %   'desmodal': Ejecuta la condensacion modal
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
            
            %Descomposicion modal
            patronDeCargasObj.desModal = r.desmodal;
            
        end % PatronDeCargasDinamico constructor
        
        function aplicarCargas(patronDeCargasObj, cpenzien, disipadores, cargaDisipador, betaDisipador)
            % aplicarCargas: es un metodo de la clase PatronDeCargasDinamico que
            % se usa para aplicar las cargas guardadas en el Patron de Cargas
            %
            % aplicarCargas(patronDeCargasObj,cpenzien,disipadores,cargaDisipador,betaDisipador)
            %
            % Aplica las cargas que estan guardadas en el PatronDeCargasDinamico
            % (patronDeCargasObj), es decir, se aplican las cargas sobre los nodos
            % y elementos
            
            % Obtiene los parametros de la estructura
            k = patronDeCargasObj.analisisObj.obtenerMatrizRigidez();
            m = patronDeCargasObj.analisisObj.obtenerMatrizMasa();
            c = patronDeCargasObj.analisisObj.obtenerMatrizAmortiguamiento(~cpenzien); % false: cPenzien
            cdv = patronDeCargasObj.analisisObj.obtenerMatrizAmortiguamientoDisipadores();
            r = patronDeCargasObj.analisisObj.obtenerVectorInfluencia();
            phi = patronDeCargasObj.analisisObj.obtenerMatrizPhi();
            
            % Chequea que las dimensiones sean apropiadas
            if ~equalMatrixSize(k, m) || ~equalMatrixSize(m, c) || length(r) ~= length(m)
                error('Tamano incorrecto de matrices K, M, C, r');
            end
            
            % Agrega o no disipadores
            if disipadores
                fprintf('\tPatron de cargas dinamico considera el uso de disipadores\n');
                c = c + cdv;
            else
                fprintf('\tPatron de cargas dinamico no considera el uso de disipadores\n');
            end
            
            % Descomposicion modal
            if patronDeCargasObj.desModal
                k = phi' * k * phi;
                mmodal = phi' * m * phi;
                c = phi' * c * phi;
                fprintf('\tPatron de cargas usa descomposicion modal\n');
            else
                fprintf('\tPatron de cargas no usa descomposicion modal\n');
                mmodal = m;
            end
            
            if cpenzien
                fprintf('\tPatron de cargas dinamico usa amortiguamiento de Wilson-Penzien\n');
            else
                fprintf('\tPatron de cargas dinamico usa amortiguamiento de Rayleigh\n');
            end
            
            % Calcula las inversas
            minv = mmodal^(-1);
            
            % Se calcula carga una de las cargas dinamicas
            tInicioProceso = cputime;
            totalCargas = length(patronDeCargasObj.cargas);
            for i = 1:totalCargas
                
                % Chequea que la carga sea dinamica
                if ~isa(patronDeCargasObj.cargas{i}, 'CargaDinamica')
                    error('PatronDeCargasDinamico solo puede resolver cargas dinamicas');
                end
                
                % Obtiene la carga
                tInicio = cputime;
                fprintf('\t\tAplicando carga %s (%d/%d)\n', ...
                    patronDeCargasObj.cargas{i}.obtenerEtiqueta(), i, totalCargas);
                
                % Chequea que la carga este activa
                if ~patronDeCargasObj.cargas{i}.cargaActivada()
                    fprintf('\t\t\tLa carga %s esta desactivada\n', ...
                        patronDeCargasObj.cargas{i}.obtenerEtiqueta());
                    continue;
                end
                
                % Genera las cargas
                fprintf('\t\t\tGenerando la matriz de cargas\n');
                p = patronDeCargasObj.cargas{i}.calcularCarga(1, m, r);
                
                % Descomposicion modal
                if patronDeCargasObj.desModal
                    pmodal = phi' * p;
                else
                    pmodal = p;
                end
                
                % Resuelve newmark
                [u, du, ddu] = patronDeCargasObj.newmark(k, mmodal, minv, c, pmodal, patronDeCargasObj.cargas{i}.dt, 0, 0);
                
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
                fprintf('\n\t\t\tSe completo calculo en %.3f segundos\n', cputime-tInicio);
                
            end
            
            fprintf('\tProceso finalizado en %.3f segundos\n\n', cputime-tInicioProceso);
            
        end % aplicarCargas function
        
        function disp(patronDeCargasObj)
            % disp: es un metodo de la clase PatronDeCargasDinamico que se usa para imprimir en
            % command Window la informacion del Patron de Cargas
            %
            % disp(patronDeCargasObj)
            %
            % Imprime la informacion guardada en el Patron de Cargas Dinamico (patronDeCargasObj)
            % en pantalla
            
            fprintf('Propiedades Patron de Cargas Dinamico:\n');
            disp@ComponenteModelo(patronDeCargasObj);
            
        end % disp function
        
    end % methods PatronDeCargasDinamico
    
    methods(Access = private)
        
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
                
            end
            
        end % newmark function
        
    end % methods PatronDeCargasDinamico
    
end % class PatronDeCargasDinamico