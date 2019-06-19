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
%| Clase PatronDeCargasConstante                                        |
%|                                                                      |
%| Este archivo contiene la definicion de la Clase                      |
%| PatronDeCargasConstante.                                             |
%| PatronDeCargasConstante es una subclase de la clase PatronDeCargas y |
%| corresponde  a la  representacion de un  patron de  cargas constante |
%| en  el   metodo  de   elementos  finitos  o  analisis  matricial  de |
%| estructuras.                                                         |
%|                                                                      |
%| La clase PatronDeCargasConstante  es una clase contenedor que guarda |
%| y controla se  aplica en forma  constante las cargas  en los nodos y |
%| elementos, en este caso se mantiene constante.                       |
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
%       obj = PatronDeCargasConstante(etiquetaPatronDeCargas,arregloCargas)
%       aplicarCargas(obj)
%       disp(obj)
%  Methods SuperClass (PatronDeCargas):
%       cargas = obtenerCargas(obj)
%  Methods SuperClass (ComponenteModelo):
%       etiqueta = obtenerEtiqueta(obj)
%       e = equals(obj,obj)
%       objID = obtenerIDObjeto(obj)

classdef PatronDeCargasConstante < PatronDeCargas
    
    properties(Access = private)
    end % private properties PatronDeCargasConstante
    
    methods(Access = public)
        
        function obj = PatronDeCargasConstante(etiquetaPatronDeCargas, arregloCargas)
            % PatronDeCargasConstante: es el constructor de la clase PatronDeCargas
            %
            % Crea un objeto de la clase PatronDeCargas, con un identificador unico
            % (etiquetaPatronDeCargas) y guarda el arreglo con las cargas (arregloCargas)
            % a aplicar en el modelo
            
            % Si no se pasan argumentos se crean vacios
            if nargin == 0
                etiquetaPatronDeCargas = '';
            end
            
            % Llamamos al constructor de la SuperClass que es la clase ComponenteModelo
            obj = obj@PatronDeCargas(etiquetaPatronDeCargas);
            
            % Se guarda el arreglo con las cargas
            obj.cargas = arregloCargas;
            
            % Define propiedades
            obj.patronEsDinamico = false;
            
        end % PatronDeCargasConstante constructor
        
        function aplicarCargas(obj, factor)
            % aplicarCargas: es un metodo de la clase PatronDeCargasConstante que
            % se usa para aplicar las cargas guardadas en el Patron de Cargas
            %
            % Aplica las cargas que estan guardadas en el PatronDeCargasConstante
            % (obj), es decir, se aplican las cargas sobre los nodos
            % y elementos
            
            % Se aplica la carga con un factor de carga
            for i = 1:length(obj.cargas)
                
                % Chequea que la carga sea estatica
                if ~isa(obj.cargas{i}, 'CargaEstatica')
                    error('PatronDeCargasConstante solo puede resolver cargas estaticas');
                end
                
                % Chequea que la carga este activa
                if ~obj.cargas{i}.cargaActivada()
                    continue;
                end
                
                % Aplica la carga
                obj.cargas{i}.aplicarCarga(factor);
                
            end % for i
            
        end % aplicarCargas function
        
        function disp(obj)
            % disp: es un metodo de la clase PatronDeCargasConstante que se usa para imprimir en
            % command Window la informacion del Patron de Cargas
            %
            % Imprime la informacion guardada en el Patron de Cargas Constante (obj)
            % en pantalla
            
            fprintf('Propiedades patron de cargas constante :\n');
            disp@ComponenteModelo(obj);
            dispMetodoTEFAME();
            
        end % disp function
        
    end % public methods PatronDeCargasConstante
    
end % class PatronDeCargasConstante