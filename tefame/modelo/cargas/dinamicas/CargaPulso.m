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
%| Clase CargaPulso                                                     |
%|                                                                      |
%| Este archivo contiene la definicion de la Clase CargaPulso           |
%| CargaPulso es una subclase de la clase CargaDinamica y corresponde a |
%| la representacion de una carga nodal en el metodo de elementos       |
%| finitos o analisis matricial de estructuras.                         |
%| La clase CargaPulso es una clase que contiene el nodo al que se le   |
%| va aplicar la carga y el valor de esta carga.                        |
%|                                                                      |
%| Programado: Pablo Pizarro @ppizarror                                 |
%| Fecha: 10/04/2019                                                    |
%|______________________________________________________________________|
%
%  Properties (Access=private):
%  Methods:
%       CargaPulso(etiquetaCargaPulso,registro,direccion,dt,tAnalisis)
%       aplicarCarga(CargaPulsoObj,factorDeCarga)
%       disp(CargaPulsoObj)
%  Methods SuperClass (Carga):
%  Methods SuperClass (ComponenteModelo):
%       etiqueta = obtenerEtiqueta(componenteModeloObj)
%       e = equals(componenteModeloObj,obj)

classdef CargaPulso < CargaDinamica
    
    properties(Access = private)
        registro % Matriz del registro
        direccion % Vector de direcciones
        tpulso % Tiempo de aplicacion del pulso
        intervalos % Intervalos
        nodo % Nodo al que se aplica la carga
        amplitud % Ampitud de la carga
    end % properties CargaPulso
    
    methods
        
        function CargaPulsoObj = CargaPulso(etiquetaCargaPulso, nodo, direccion, amplitud, tpulso, dt, tAnalisis)
            % CargaPulso: es el constructor de la clase CargaPulso
            %
            % CargaPulsoObj=CargaPulso(etiquetaCargaPulso,nodo,direccion,amplitud,tpulso,dt,tAnalisis)
            %
            % Crea una carga tipo pulso
            
            if nargin == 0
                etiquetaCargaPulso = '';
            end % if
            
            % Llamamos al constructor de la SuperClass que es la clase Carga
            CargaPulsoObj = CargaPulsoObj@CargaDinamica(etiquetaCargaPulso);
            
            % Verifica que tenga sentido la direccion
            if ~verificarVectorDireccion(direccion, nodo.obtenerNumeroGDL())
                error('Vector direccion mal definido');
            end
            
            % Guarda el registro
            CargaPulsoObj.tpulso = tpulso;
            CargaPulsoObj.amplitud = amplitud;
            CargaPulsoObj.direccion = direccion;
            CargaPulsoObj.tAnalisis = tAnalisis;
            CargaPulsoObj.dt = dt;
            CargaPulsoObj.nodo = nodo; % Objeto del nodo donde se aplica la carga
            
        end % CargaPulso constructor
        
        function p = calcularCarga(CargaPulsoObj, factor, m, r) %#ok<INUSD,INUSL>
            % calcularCarga: es un metodo de la clase Carga que se usa para
            % calcular la carga a aplicar
            %
            % calcularCarga(cargaObj,factor,m,r)
            
            % Crea la matriz de carga
            ng = length(m);
            nt = CargaPulsoObj.tAnalisis / CargaPulsoObj.dt;
            p = zeros(ng, nt);
            fprintf('\t\t\t\tAplicando carga a nodo %s\n', CargaPulsoObj.nodo.obtenerEtiqueta());
            
            % Crea el vector de influencia
            rf = zeros(ng, 1);
            nodoGDL = CargaPulsoObj.nodo.obtenerGDLIDCondensado();
            
            % Verifica que la direccion no sea mayor que el numero de nodos
            if length(nodoGDL) < length(CargaPulsoObj.direccion)
                error('Las direcciones de analisis superan el numero de direcciones del nodo %s', ...
                    CargaPulsoObj.nodo.obtenerEtiqueta());
            end
            
            gdl = 0;
            for i = 1:length(CargaPulsoObj.direccion)
                if CargaPulsoObj.direccion(i) ~= 0
                    gdl = nodoGDL(i); % Obtiene el GDL asociado
                    if gdl > 0
                        rf(gdl) = 1;
                        fprintf('\t\t\t\tSe aplica la carga en el grado condensado %d\n', gdl);
                    end
                end
            end
            
            % Verifica que el grado sea valido
            if gdl == 0
                error('No es posible aplicar la carga en un grado condensado del nodo %s', ...
                    CargaPulsoObj.nodo.obtenerEtiqueta());
            end
            
            % Carga pulso
            t = linspace(0, CargaPulsoObj.tAnalisis, nt);
            for i = 1:nt
                if t(i) <= CargaPulsoObj.tpulso
                    p(:, i) = rf .* CargaPulsoObj.amplitud;
                else
                    break;
                end
            end
            
            fprintf('\t\t\t\tLa carga es aplicada en %d/%d (%.2f%%) de la matriz de cargas totales\n', ...
                i, nt, (i / nt)*100);
            
        end % calcularCarga function
        
        function disp(CargaPulsoObj)
            % disp: es un metodo de la clase CargaPulso que se usa para imprimir en
            % command Window la informacion de la carga del tipo registro
            % sismico
            %
            % disp(CargaPulsoObj)
            % Imprime la informacion guardada en la carga (CargaPulsoObj) en pantalla
            
            fprintf('Propiedades Carga Pulso:\n');
            disp@CargaDinamica(CargaPulsoObj);
            
            fprintf('-------------------------------------------------\n');
            fprintf('\n');
            
        end % disp function
        
    end % methods CargaPulso
    
end % class CargaPulso