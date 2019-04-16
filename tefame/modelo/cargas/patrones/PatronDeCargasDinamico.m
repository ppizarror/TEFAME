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
%  Methods:
%       patronDeCargasObj = PatronDeCargasDinamico(etiquetaPatronDeCargas,arregloCargas,analisisObj)
%       aplicarCargas(patronDeCargasObj)
%       disp(patronDeCargasObj)
%  Methods SuperClass (PatronDeCargas):
%  Methods SuperClass (ComponenteModelo):
%       etiqueta = obtenerEtiqueta(componenteModeloObj)

classdef PatronDeCargasDinamico < PatronDeCargas
    
    properties(Access = private)
        cargas % Variable que guarda en un arreglo de celdas todas las cargas aplicadas en el patron de cargas
        analisisObj % Guarda el objeto de analisis con tal de obtener M, K, C y el vector de influencia
    end % properties PatronDeCargasDinamico
    
    methods
        
        function patronDeCargasObj = PatronDeCargasDinamico(etiquetaPatronDeCargas, arregloCargas, analisisObj)
            % PatronDeCargasDinamico: es el constructor de la clase PatronDeCargas
            %
            % patronDeCargasObj = PatronDeCargasDinamico(etiquetaPatronDeCargas,arregloCargas,analisisObj)
            % Crea un objeto de la clase PatronDeCargas, con un identificador unico
            % (etiquetaPatronDeCargas) y guarda el arreglo con las cargas (arregloCargas)
            % a aplicar en el modelo
            
            % Si no se pasan argumentos se crean vacios
            if nargin == 0
                etiquetaPatronDeCargas = '';
            end % if
            
            % Llamamos al constructor de la SuperClass que es la clase ComponenteModelo
            patronDeCargasObj = patronDeCargasObj@PatronDeCargas(etiquetaPatronDeCargas);
            
            % Se guarda el arreglo con las cargas
            patronDeCargasObj.cargas = arregloCargas;
            
            % Define propiedades
            patronDeCargasObj.patronEsDinamico = true;
            
            % Guarda el analisis
            patronDeCargasObj.analisisObj = analisisObj;
            
        end % PatronDeCargasDinamico constructor
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Metodos para aplicar las cargas guardadas en el patron de cargas durante el analisis
        
        function aplicarCargas(patronDeCargasObj, cpenzien)
            % aplicarCargas: es un metodo de la clase PatronDeCargasDinamico que
            % se usa para aplicar las cargas guardadas en el Patron de Cargas
            %
            % aplicarCargas(patronDeCargasObj,cpenzien)
            % Aplica las cargas que estan guardadas en el PatronDeCargasDinamico
            % (patronDeCargasObj), es decir, se aplican las cargas sobre los nodos
            % y elementos.
            
            % Obtiene los parametros de la estructura
            k = patronDeCargasObj.analisisObj.obtenerMatrizRigidez();
            m = patronDeCargasObj.analisisObj.obtenerMatrizMasa();
            c = patronDeCargasObj.analisisObj.obtenerMatrizAmortiguamiento(~cpenzien); % false: cPenzien
            r = patronDeCargasObj.analisisObj.obtenerVectorInfluencia();
            
            % Chequea que las dimensiones sean apropiadas
            if ~equalMatrixSize(k, m) || ~equalMatrixSize(m, c) || length(r) ~= length(m)
                error('Tamaño incorrecto de matrices K, M, C o r');
            end
            tInicioProceso = cputime;
            
            % Se calcula carga una de las cargas dinamicas
            for i = 1:length(patronDeCargasObj.cargas)
                
                % Obtiene la carga
                tInicio = cputime;
                p = patronDeCargasObj.cargas{i}.calcularCarga(1, m, r);
                fprintf('\t\tAplicando carga %s\n', patronDeCargasObj.cargas{i}.obtenerEtiqueta());
                
                % Resuelve newmark
                [u, du, ddu] = patronDeCargasObj.newmark(k, m, c, p, patronDeCargasObj.cargas{i}.dt, 0, 0);
            
                % Guarda los resultados
                patronDeCargasObj.cargas{i}.guardarDesplazamiento(u);
                patronDeCargasObj.cargas{i}.guardarVelocidad(du);
                patronDeCargasObj.cargas{i}.guardarAceleracion(ddu);
                fprintf('\n\t\t\tSe completo calculo en %.3f segundos\n', cputime-tInicio);
                
            end
            
            fprintf('\tProceso finalizado en %.3f segundos\n', cputime-tInicioProceso);
            
        end % aplicarCargas function
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Algoritmos de resolucion

        function [x, v, z] = newmark(patronDeCargasObj, k, m, c, p, dt, xo, vo) %#ok<*INUSL>
            % Newmark: es un metodo de la clase ModalEspectral que se
            % usa para obtener los valores de aceleracion, velociadad y desplazamiento
            % de los grados de libertad a partir del metodo de Newmark
            %
            % Newmark(patronDeCargasObj, p, dt, xo, vo)
            
            % Define coeficientes
            gamma = 1 / 2;
            beta = 1 / 6;
            alpha = 0;
            
            % Obtiene parametros del modelo
            KT = patronDeCargasObj.analisisObj.obtenerMatrizRigidez();
            MT = patronDeCargasObj.analisisObj.obtenerMatrizMasa();
            CT = patronDeCargasObj.analisisObj.obtenerMatrizAmortiguamiento(true); % false: cPenzien
            
            n = length(p);
            % tmax = dt * (n - 1);
            % t = linspace(0, tmax, n)';
            ngl = length(k);
            x = zeros(ngl, length(p));
            v = zeros(ngl, length(p));
            z = zeros(ngl, length(p));
            x(:, 1) = xo;
            v(:, 1) = vo;
            z(:, 1) = m^(-1) * (p(:, 1) - c * v(:, 1) - k * x(:, 1));
            a1 = 1 / (beta * dt^2) * MT + gamma / (beta * dt) * CT;
            a2 = 1 / (beta * dt) * MT + (gamma / beta-1) * CT;
            a3 = (1 / (2 * beta) - 1) * MT + dt * (gamma / (2 * beta) - 1) * CT;
            ks = KT + a1;
%             c1 = 1 / (dt^2 * beta);
%             c2 = 1 / (dt * beta);
%             c3 = gamma / (dt * beta);
%             c4 = 1 - gamma / beta;
%             c5 = 1 - gamma / (2 * beta);        
%             ks = c1 * m + (1 + alpha) * c3 * c + (1 + alpha) * k; %hht
            ps = zeros(ngl, length(p));
            reverse_porcent = '';
            
            for i = 1:1:(n - 1)
                
                % Calcula
                ps(:, i+1) = p(:, i+1) + a1 * x(:, i) + a2 * v(:, i) + a3 * z(:, i);
%                 ps(:, i+1) = p(:, i+1) + k * alpha * x(:,i) + m * (c1 * x(:,i) + c2 * v(:,i) - c5 * z(:,i)) ...
%                     + c * ((1 + alpha) * c3 * x(:,i) + (alpha - (1 + alpha) * c4) * v(:,i) - (1 + alpha) * c5 * dt * z(:,i)); %hht
                x(:, i+1) = ks^(-1) * ps(:, i+1);
                v(:, i+1) = (gamma / (beta * dt)) * (x(:, i+1) - x(:, i)) + (1 - gamma / beta) * v(:, i) + dt * (1 - gamma / (2 * beta)) * z(:, i);
                z(:, i+1) = (1 / (beta * dt^2)) * (x(:, i+1) - x(:, i)) - (1 / (beta * dt)) * v(:, i) - (1 / (2 * beta) - 1) * z(:, i);
            
                % Imprime estado
                msg = sprintf('\t\t\tCalculando... %.1f/100', i/(n-1)*100);
                fprintf([reverse_porcent, msg]);
                reverse_porcent = repmat(sprintf('\b'), 1, length(msg));
            end
            
        end % NewmarkLineal function
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Metodos para mostrar la informacion del PatronDeCargas en pantalla
        
        function disp(patronDeCargasObj)
            % disp: es un metodo de la clase PatronDeCargasDinamico que se usa para imprimir en
            % command Window la informacion del Patron de Cargas
            %
            % disp(patronDeCargasObj)
            % Imprime la informacion guardada en el Patron de Cargas Constante (patronDeCargasObj)
            % en pantalla
            
            fprintf('Propiedades Patron de Cargas Dinamico:\n');
            disp@ComponenteModelo(patronDeCargasObj);
            
        end % disp function
        
    end % methods PatronDeCargasDinamico
    
end % class PatronDeCargasDinamico