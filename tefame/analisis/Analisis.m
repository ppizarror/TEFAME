%|______________________________________________________________________|
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
%| Repositorio: https://github.com/ppizarror/TEFAME                     |
%|______________________________________________________________________|
%|                                                                      |
%| Clase Analisis                                                       |
%|                                                                      |
%| Clase abstracta general definicion de analisis.                      |
%|______________________________________________________________________|
%|                                                                      |
%| MIT License                                                          |
%| Copyright (c) 2018-2019 Pablo Pizarro R @ppizarror.com.              |
%|                                                                      |
%| Permission is hereby granted, free of charge, to any person obtai-   |
%| ning a copy of this software and associated documentation files (the |
%| "Software"), to deal in the Software without restriction, including  |
%| without limitation the rights to use, copy, modify, merge, publish,  |
%| distribute, sublicense, and/or sell copies of the Software, and to   |
%| permit persons to whom the Software is furnished to do so, subject   |
%| to the following conditions:                                         |
%|                                                                      |
%| The above copyright notice and this permission notice shall be       |
%| included in all copies or substantial portions of the Software.      |
%|                                                                      |
%| THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,      |
%| EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF   |
%| MERCHANTABILITY,FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.|
%| IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY |
%| CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, |
%| TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE    |
%| SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.               |
%|______________________________________________________________________|
%
%  Methods(Access=public):
%       obj = Analisis(modeloObjeto)
%       activarCargaAnimacion(obj)
%       activarPlotDeformadaInicial(obj)
%       analizar(obj,varargin)
%       c = obtenerCargaEstatica(obj,varargin)
%       C_Modelo = obtenerMatrizAmortiguamiento(obj,rayleigh)
%       calcularCurvasEnergia(obj,carga)
%       calcularDesplazamientoDrift(obj,xanalisis)
%       calcularMomentoCorteBasal(obj,carga)
%       Cdv_Modelo = obtenerMatrizAmortiguamientoDisipadores(obj)
%       definirNumeracionGDL(obj)
%       desactivarCargaAnimacion(obj)
%       desactivarPlotDeformadaInicial(obj)
%       disp(obj)
%       F_Modelo = obtenerVectorFuerzas(obj)
%       K_Modelo = obtenerMatrizRigidez(obj)
%       M_Modelo = obtenerMatrizMasa(obj)
%       numeroEcuaciones = obtenerNumeroEcuaciones(obj)
%       phi_Modelo = obtenerMatrizPhi(obj)
%       plot(obj,varargin)
%       plotEsfuerzosElemento(obj,carga)
%       plotTrayectoriaNodo(obj,carga,nodo,direccion)
%       r_Modelo = obtenerVectorInfluencia(obj)
%       u_Modelo = obtenerDesplazamientos(obj)
%       wn_Modelo = obtenerValoresPropios(obj)

classdef Analisis < handle
    
    properties(Access = protected)
        analisisFinalizado % Analisis termino
        modeloObj % Objeto del modelo
        numeroGDL % Numero GDL del sistema
    end % protected properties Analisis
    
    methods(Access = public)
        
        function obj = Analisis(modeloObjeto)
            % Analisis: es el constructor de la clase Analisis
            %
            % Crea un objeto de la clase Analisis, y guarda el modelo,
            % que necesita ser analizado
            
            if nargin == 0
                modeloObjeto = [];
            end
            
            obj.analisisFinalizado = false;
            obj.modeloObj = modeloObjeto;
            obj.numeroGDL = 0;
            
        end % Analisis constructor
        
        %         function definirNumeracionGDL(obj)
        %             % definirNumeracionGDL: es un metodo de la clase Analisis que
        %             % se usa para definir como se enumeran los GDL en el modelo
        %             %
        %             % Define y asigna la enumeracion de los GDL en el modelo
        %
        %         end % definirNumeracionGDL function
        
        function analizar(obj, varargin)
            % analizar: es un metodo de la clase Analisis que se usa para
            % realizar el analisis
            
        end % analizar function
        
        function M_Modelo = obtenerMatrizMasa(obj) %#ok<*MANU>
            % obtenerMatrizMasa: es un metodo de la clase Analisis
            % que se usa para obtener la matriz de masa del modelo
            %
            % Obtiene la matriz de masa (M_Modelo) del modelo que se genero
            % en el Analisis (obj)
            
            M_Modelo = [];
            
        end % obtenerMatrizMasa function
        
        function C_Modelo = obtenerMatrizAmortiguamiento(obj, varargin)
            % obtenerMatrizAmortiguamiento: es un metodo de la clase
            % que se usa para obtener la matriz de amortiguamiento del modelo
            %
            % Obtiene la matriz de amortiguamiento (C_Modelo) del modelo que se genero
            % en el Analisis (obj)
            
            C_Modelo = [];
            
        end % obtenerMatrizAmortiguamiento function
        
        %         function ensamblarMatrizRigidez(obj)
        %             % ensamblarMatrizRigidez: es un metodo de la clase Analisis que
        %             % se usa para realizar el armado de la matriz de rigidez del
        %             % modelo analizado
        %             %
        %             % Ensambla la matriz de Rigidez del modelo analizado usando el metodo
        %             % indicial
        %
        %         end % ensamblarMatrizRigidez function
        
        %         function Cd = ensamblarMatrizAmortiguamientoDisipadores(obj) %#ok<*MANU>
        %             % ensamblarMatrizAmortiguamientoDisipadores: Ensambla la matriz
        %             % de amortiguamiento de los disipadores
        %
        %             Cd = [];
        %
        %         end % ensamblarMatrizAmortiguamientoDisipadores function
        
        %         function Kdv = ensamblarMatrizRigidezDisipadores(obj)
        %             % ensamblarMatrizRigidezDisipadores: Ensambla matriz de rigidez
        %             % de los disipadores
        %
        %             Kdv = [];
        %
        %         end % ensamblarMatrizRigidezDisipadores function
        
        %         function ensamblarVectorFuerzas(obj)
        %             % ensamblarVectorFuerzas: es un metodo de la clase Analisis que
        %             % se usa para realizar el armado del vector de fuerzas del
        %             % modelo analizado
        %             %
        %             % Ensambla el vector de fuerzas del modelo analizado usando el metodo
        %             % indicial
        %
        %         end % ensamblarVectorFuerzas function
        
        function numeroEcuaciones = obtenerNumeroEcuaciones(obj)
            % obtenerNumeroEcuaciones: es un metodo de la clase Analisis
            % que se usa para obtener el numero total de GDL, es decir, ecuaciones
            % del modelo
            %
            % Obtiene el numero total de GDL (numeroEcuaciones) que esta guardado
            % en el Analisis (obj)
            
            numeroEcuaciones = 0;
            
        end % obtenerNumeroEcuaciones function
        
        function K_Modelo = obtenerMatrizRigidez(obj)
            % obtenerMatrizRigidez: es un metodo de la clase Analisis
            % que se usa para obtener la matriz de rigidez del modelo
            %
            % Obtiene la matriz de rigidez (K_Modelo) del modelo que se genero
            % en el Analisis (obj)
            
            K_Modelo = [];
            
        end % obtenerMatrizRigidez function
        
        %         function ensamblarMatrizMasa(obj)
        %             % ensamblarMatrizMasa: es un metodo de la clase Analisis que se usa para
        %             % realizar el armado de la matriz de masa del modelo
        %             %
        %             % Ensambla la matriz de masa del modelo analizado usando el metodo
        %             % indicial
        %
        %         end % ensamblarMatrizMasa function
        
        function Cdv_Modelo = obtenerMatrizAmortiguamientoDisipadores(obj)
            % obtenerMatrizRigidez: es un metodo de la clase que retorna la matriz
            % de amortiguamiento de los disipadores
            %
            % Obtiene la matriz de amortiguamiento de los disipadores del modelo
            
            Cdv_Modelo = [];
            
        end % obtenerMatrizAmortiguamientoDisipadores function
        
        function Kdv_Modelo = obtenerMatrizRigidezDisipadores(obj)
            % obtenerMatrizRigidezDisipadores: es un metodo de la clase ModalEspectral
            % que se usa para obtener la matriz de rigidez de los
            % disipadores
            
            Kdv_Modelo = [];
            
        end % obtenerMatrizRigidezDisipadores function
        
        function F_Modelo = obtenerVectorFuerzas(obj)
            % obtenerMatrizRigidez: es un metodo de la clase Analisis
            % que se usa para obtener el vector de fuerza del modelo
            %
            % Obtiene el vector de fuerza (F_Modelo) del modelo que se genero
            % en el Analisis (obj)
            
            F_Modelo = [];
            
        end % obtenerVectorFuerzas function
        
        function u_Modelo = obtenerDesplazamientos(obj)
            % obtenerDesplazamientos: es un metodo de la clase Analisis
            % que se usa para obtener el vector de desplazamiento del modelo
            % obtenido del analisis
            %
            % Obtiene el vector de desplazamiento (u_Modelo) del modelo que se
            % genero como resultado del Analisis (obj)
            
            u_Modelo = [];
            
        end % obtenerDesplazamientos function
        
        %         function [limx, limy, limz] = obtenerLimitesDeformada(obj, factor)
        %             % obtenerLimitesDeformada: Obtiene los limites de deformacion
        %
        %             limx = 0;
        %             limy = 0;
        %             limz = 0;
        %
        %         end % obtenerLimitesDeformada function
        
        function plt = plot(obj, varargin) %#ok<*VANUS,*INUSD>
            % plt: Grafica el modelo
            
            plt = 0;
            
        end % plot function
        
        function guardarResultados(obj, nombreArchivo)
            % guardarResultados: Guarda resultados adicionales del analisis
            
        end % guardarResultados function
        
        function disp(obj)
            % disp: es un metodo de la clase Analisis que se usa para imprimir en
            % command Window la informacion del Analisis realizado
            %
            % Imprime la informacion guardada en el Analisis (obj) en
            % pantalla
            
        end % disp function
        
    end % public methods Analisis
    
end % class Analisis