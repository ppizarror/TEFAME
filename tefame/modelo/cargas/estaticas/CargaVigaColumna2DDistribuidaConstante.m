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
%| Clase CargaVigaColumna2DDistribuidaConstante                         |
%|                                                                      |
%| Implementacion de CargaVigaColumna2DDistribuida con carga constante  |
%|______________________________________________________________________|
%|                                                                      |
%| MIT License                                                          |
%| Copyright (c) 2018-2020 Pablo Pizarro R @ppizarror.com.              |
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
%       obj = CargaVigaColumna2DDistribuidaConstante(etiquetaCarga,elemObjeto,carga,theta)
%       aplicarCarga(obj,factorDeCarga)
%       disp(obj)
%  Methods SuperClass (CargaEstatica):
%       masa = obtenerMasa(obj)
%       definirFactorUnidadMasa(obj,factor)
%       definirFactorCargaMasa(obj,factor)
%       nodos = obtenerNodos(obj)
%  Methods SuperClass (ComponenteModelo):
%       etiqueta = obtenerEtiqueta(obj)
%       e = equals(obj,obj)
%       objID = obtenerIDObjeto(obj)

classdef CargaVigaColumna2DDistribuidaConstante < CargaVigaColumna2DDistribuida
    
    methods(Access = public)
        
        function obj = CargaVigaColumna2DDistribuidaConstante(etiquetaCarga, ...
                elemObjeto, carga, theta)
            % CargaVigaColumna2DDistribuida: es el constructor de la clase CargaVigaColumna2DDistribuida
            %
            % Crea un objeto de la clase Carga, en donde toma como atributo
            % el objeto a aplicar la carga, la carga del elemento,
            % y el angulo de la carga con respecto a la normal
            % (0=Completamente normal, pi/2=Carga axial a la viga)
            
            % Si no se pasan argumentos se crea una carga vacia
            if nargin == 0
                carga = 0;
                elemObjeto = [];
                etiquetaCarga = '';
                theta = 0;
            end
            if ~exist('theta', 'var')
                theta = 0;
            end
            
            if ~isa(elemObjeto, 'VigaColumna2D')
                error('Objeto de la carga no es una VigaColumna2D @CargaVigaColumna2DDistribuidaConstante %s', etiquetaCarga);
            end
            
            % Llamamos al constructor de la SuperClass que es la clase
            % CargaEstatica
            obj = obj@CargaVigaColumna2DDistribuida(etiquetaCarga, elemObjeto, carga, carga, theta);
            
        end % CargaVigaColumna2DDistribuidaConstante constructor
        
    end % public methods CargaVigaColumna2DDistribuidaConstante
    
end % class CargaVigaColumna2DDistribuidaConstante