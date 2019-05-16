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
%| Clase Analisis                                                       |
%|                                                                      |
%| Clase abstracta general definicion de analisis.                      |
%|                                                                      |
%| Programado: Pablo Pizarro @ppizarror                                 |
%| Fecha: 12/05/2019                                                    |
%|______________________________________________________________________|
%
%  Properties (Access=private):
%  Properties (Access=protected):
%       analisisFinalizado
%       modeloObj
%       numeroGDL
%  Methods:
%       analisisObj = Analisis(modeloObjeto)
%       activarCargaAnimacion(analisisObj)
%       activarPlotDeformadaInicial(analisisObj)
%       analizar(analisisObj,varargin)
%       c = obtenerCargaEstatica(analisisObj,varargin)
%       C_Modelo = obtenerMatrizAmortiguamiento(analisisObj,rayleigh)
%       calcularCurvasEnergia(analisisObj,carga)
%       calcularDesplazamientoDrift(analisisObj,xanalisis)
%       calcularMomentoCorteBasal(analisisObj,carga)
%       Cdv_Modelo = obtenerMatrizAmortiguamientoDisipadores(analisisObj)
%       definirNumeracionGDL(analisisObj)
%       desactivarCargaAnimacion(analisisObj)
%       desactivarPlotDeformadaInicial(analisisObj)
%       disp(analisisObj)
%       F_Modelo = obtenerVectorFuerzas(analisisObj)
%       K_Modelo = obtenerMatrizRigidez(analisisObj)
%       M_Modelo = obtenerMatrizMasa(analisisObj)
%       numeroEcuaciones = obtenerNumeroEcuaciones(analisisObj)
%       phi_Modelo = obtenerMatrizPhi(analisisObj)
%       plot(analisisObj,varargin)
%       plotEsfuerzosElemento(analisisObj,carga)
%       plotTrayectoriaNodo(analisisObj,carga,nodo,direccion)
%       r_Modelo = obtenerVectorInfluencia(analisisObj)
%       u_Modelo = obtenerDesplazamientos(analisisObj)
%       wn_Modelo = obtenerValoresPropios(analisisObj)

classdef Analisis < handle
    
    properties(Access = protected)
        modeloObj % Objeto del modelo
        analisisFinalizado % Analisis termino
        numeroGDL % Numero GDL del sistema
    end % properties Analisis
    
    methods(Access = public)
        
        function analisisObj = Analisis(modeloObjeto)
            % Analisis: es el constructor de la clase Analisis
            %
            % analisisObj = Analisis(modeloObjeto)
            %
            % Crea un objeto de la clase Analisis, y guarda el modelo,
            % que necesita ser analizado
            
            if nargin == 0
                modeloObjeto = [];
            end % if
            
            analisisObj.modeloObj = modeloObjeto;
            analisisObj.analisisFinalizado = false;
            analisisObj.numeroGDL = 0;
            
        end % Analisis constructor
        
%         function definirNumeracionGDL(analisisObj)
%             % definirNumeracionGDL: es un metodo de la clase Analisis que
%             % se usa para definir como se enumeran los GDL en el modelo
%             %
%             % definirNumeracionGDL(analisisObj)
%             %
%             % Define y asigna la enumeracion de los GDL en el modelo
%             
%         end % definirNumeracionGDL function
        
        function analizar(analisisObj, varargin)
            % analizar: es un metodo de la clase Analisis que se usa para
            % realizar el analisis
            %
            % analizar(analisisObj,varargin)
            
        end % analizar function
        
        function M_Modelo = obtenerMatrizMasa(analisisObj) %#ok<*MANU>
            % obtenerMatrizMasa: es un metodo de la clase Analisis
            % que se usa para obtener la matriz de masa del modelo
            %
            % M_Modelo = obtenerMatrizRigidez(analisisObj)
            %
            % Obtiene la matriz de masa (M_Modelo) del modelo que se genero
            % en el Analisis (analisisObj)
            
            M_Modelo = [];
            
        end % obtenerMatrizMasa function
        
        function C_Modelo = obtenerMatrizAmortiguamiento(analisisObj, varargin)
            % obtenerMatrizAmortiguamiento: es un metodo de la clase
            % que se usa para obtener la matriz de amortiguamiento del modelo
            %
            % C_Modelo = obtenerMatrizAmortiguamiento(analisisObj,varargin)
            %
            % Obtiene la matriz de amortiguamiento (C_Modelo) del modelo que se genero
            % en el Analisis (analisisObj)
            
            C_Modelo = [];
            
        end % obtenerMatrizAmortiguamiento function
        
%         function ensamblarMatrizRigidez(analisisObj)
%             % ensamblarMatrizRigidez: es un metodo de la clase Analisis que
%             % se usa para realizar el armado de la matriz de rigidez del
%             % modelo analizado
%             %
%             % ensamblarMatrizRigidez(analisisObj)
%             %
%             % Ensambla la matriz de Rigidez del modelo analizado usando el metodo
%             % indicial
%             
%         end % ensamblarMatrizRigidez function
        
%         function Cd = ensamblarMatrizAmortiguamientoDisipadores(analisisObj) %#ok<*MANU>
%             % ensamblarMatrizAmortiguamientoDisipadores: Ensambla la matriz
%             % de amortiguamiento de los disipadores
%             %
%             % Cd = ensamblarMatrizAmortiguamientoDisipadores(analisisObj)
%             
%             Cd = [];
%             
%         end % ensamblarMatrizAmortiguamientoDisipadores function
        
%         function Kdv = ensamblarMatrizRigidezDisipadores(analisisObj)
%             % ensamblarMatrizRigidezDisipadores: Ensambla matriz de rigidez
%             % de los disipadores
%             %
%             % Kdv = ensamblarMatrizRigidezDisipadores(analisisObj)
%             
%             Kdv = [];
%             
%         end % ensamblarMatrizRigidezDisipadores function
        
%         function ensamblarVectorFuerzas(analisisObj)
%             % ensamblarVectorFuerzas: es un metodo de la clase Analisis que
%             % se usa para realizar el armado del vector de fuerzas del
%             % modelo analizado
%             %
%             % ensamblarMatrizRigidez(analisisObj)
%             %
%             % Ensambla el vector de fuerzas del modelo analizado usando el metodo
%             % indicial
%             
%         end % ensamblarVectorFuerzas function
        
        function numeroEcuaciones = obtenerNumeroEcuaciones(analisisObj)
            % obtenerNumeroEcuaciones: es un metodo de la clase Analisis
            % que se usa para obtener el numero total de GDL, es decir, ecuaciones
            % del modelo
            %
            % numeroEcuaciones = obtenerNumeroEcuaciones(analisisObj)
            %
            % Obtiene el numero total de GDL (numeroEcuaciones) que esta guardado
            % en el Analisis (analisisObj)
            
            numeroEcuaciones = 0;
            
        end % obtenerNumeroEcuaciones function
        
        function K_Modelo = obtenerMatrizRigidez(analisisObj)
            % obtenerMatrizRigidez: es un metodo de la clase Analisis
            % que se usa para obtener la matriz de rigidez del modelo
            %
            % K_Modelo = obtenerMatrizRigidez(analisisObj)
            %
            % Obtiene la matriz de rigidez (K_Modelo) del modelo que se genero
            % en el Analisis (analisisObj)
            
            K_Modelo = [];
            
        end % obtenerMatrizRigidez function
        
%         function ensamblarMatrizMasa(analisisObj)
%             % ensamblarMatrizMasa: es un metodo de la clase Analisis que se usa para
%             % realizar el armado de la matriz de masa del modelo
%             %
%             % ensamblarMatrizMasa(analisisObj)
%             %
%             % Ensambla la matriz de masa del modelo analizado usando el metodo
%             % indicial
%             
%         end % ensamblarMatrizMasa function
        
        function Cdv_Modelo = obtenerMatrizAmortiguamientoDisipadores(analisisObj)
            % obtenerMatrizRigidez: es un metodo de la clase que retorna la matriz
            % de amortiguamiento de los disipadores
            %
            % Cdv_Modelo = obtenerMatrizAmortiguamientoDisipadores(analisisObj)
            %
            % Obtiene la matriz de amortiguamiento de los disipadores del modelo
            
            Cdv_Modelo = [];
            
        end % obtenerMatrizAmortiguamientoDisipadores function
        
        function Kdv_Modelo = obtenerMatrizRigidezDisipadores(analisisObj)
            % obtenerMatrizRigidezDisipadores: es un metodo de la clase ModalEspectral
            % que se usa para obtener la matriz de rigidez de los
            % disipadores
            %
            % Kdv_Modelo = obtenerMatrizRigidezDisipadores(analisisObj)
            
            Kdv_Modelo = [];
            
        end % obtenerMatrizRigidezDisipadores function
        
        function F_Modelo = obtenerVectorFuerzas(analisisObj)
            % obtenerMatrizRigidez: es un metodo de la clase Analisis
            % que se usa para obtener el vector de fuerza del modelo
            %
            % F_Modelo = obtenerVectorFuerzas(analisisObj)
            %
            % Obtiene el vector de fuerza (F_Modelo) del modelo que se genero
            % en el Analisis (analisisObj)
            
            F_Modelo = [];
            
        end % obtenerVectorFuerzas function
        
        function u_Modelo = obtenerDesplazamientos(analisisObj)
            % obtenerDesplazamientos: es un metodo de la clase Analisis
            % que se usa para obtener el vector de desplazamiento del modelo
            % obtenido del analisis
            %
            % u_Modelo = obtenerDesplazamientos(analisisObj)
            %
            % Obtiene el vector de desplazamiento (u_Modelo) del modelo que se
            % genero como resultado del Analisis (analisisObj)
            
            u_Modelo = [];
            
        end % obtenerDesplazamientos function
        
%         function [limx, limy, limz] = obtenerLimitesDeformada(analisisObj, factor)
%             % obtenerLimitesDeformada: Obtiene los limites de deformacion
%             %
%             % [limx,limy,limz] = obtenerLimitesDeformada(analisisObj, factor)
%             
%             limx = 0;
%             limy = 0;
%             limz = 0;
%             
%         end % obtenerLimitesDeformada function
        
        function plt = plot(analisisObj, varargin) %#ok<*VANUS,*INUSD>
            % plt: Grafica el modelo
            %
            % plt = plot(analisisObj,'var1',val1,'var2',val2)
            
            plt = 0;
            
        end % plot function
        
        function guardarResultados(analisisObj, nombreArchivo)
            % guardarResultados: Guarda resultados adicionales del analisis
            %
            % guardarResultados(analisisObj,nombreArchivo)
            
        end % guardarResultados function
        
        function disp(analisisObj)
            % disp: es un metodo de la clase Analisis que se usa para imprimir en
            % command Window la informacion del Analisis realizado
            %
            % disp(analisisObj)
            %
            % Imprime la informacion guardada en el Analisis (analisisObj) en
            % pantalla
            
        end % disp function
        
    end % methods Analisis
    
end % class Analisis