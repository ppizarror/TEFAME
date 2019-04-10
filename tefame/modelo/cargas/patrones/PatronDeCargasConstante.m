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
%| Clase PatronDeCargasConstante                                        |
%|                                                                      |
%| Este archivo contiene la definicion de la Clase                      |
%| PatronDeCargasConstante.                                             |
%| PatronDeCargasConstante es una subclase de la clase PatronDeCargas y |
%| corresponde  a la  representacion de un  patron de  cargas constante |
%| en  el   metodo  de   elementos  finitos  o  analisis  matricial  de |
%| estructuras.                                                         |
%| La clase PatronDeCargasConstante  es una clase contenedor que guarda |
%| y controla se  aplica en forma  constante las cargas  en los nodos y |
%| elementos, en este caso se mantiene constante.                       |
%|                                                                      |
%| Programado: FR                                                       |
%| Fecha: 05/08/2015                                                    |
%|                                                                      |
%| Modificado por: FR - 24/10/2016                                      |
%|                 Pablo Pizarro @ppizarror - 10/04/2019                |
%|______________________________________________________________________|
%
%  Properties (Access=private):
%       cargas
%  Methods:
%       patronDeCargasObj = PatronDeCargasConstante(etiquetaPatronDeCargas,arregloCargas)
%       aplicarCargas(patronDeCargasObj)
%       disp(patronDeCargasObj)
%  Methods SuperClass (PatronDeCargas):
%  Methods SuperClass (ComponenteModelo):
%       etiqueta = obtenerEtiqueta(componenteModeloObj)

classdef PatronDeCargasConstante < PatronDeCargas
    
    properties(Access = private)
        cargas % Variable que guarda en un arreglo de celdas todas las cargas aplicadas en el patron de cargas
    end % properties PatronDeCargasConstante
    
    methods
        
        function patronDeCargasObj = PatronDeCargasConstante(etiquetaPatronDeCargas, arregloCargas)
            % PatronDeCargasConstante: es el constructor de la clase PatronDeCargas
            %
            % patronDeCargasObj = PatronDeCargasConstante(etiquetaPatronDeCargas,arregloCargas)
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
            patronDeCargasObj.patronEsDinamico = false;
            
        end % PatronDeCargasConstante constructor
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Metodos para aplicar las cargas guardadas en el patron de cargas durante el analisis
        
        function aplicarCargas(patronDeCargasObj)
            % aplicarCargas: es un metodo de la clase PatronDeCargasConstante que
            % se usa para aplicar las cargas guardadas en el Patron de Cargas
            %
            % aplicarCargas(patronDeCargasObj)
            % Aplica las cargas que estan guardadas en el PatronDeCargasConstante
            % (patronDeCargasObj), es decir, se aplican las cargas sobre los nodos
            % y elementos.
            
            % Se aplica la carga con un factor de carga = 1
            for i = 1:length(patronDeCargasObj.cargas)
                patronDeCargasObj.cargas{i}.aplicarCarga(1);
            end
            
        end % aplicarCargas function
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Metodos para mostrar la informacion del PatronDeCargas en pantalla
        
        function disp(patronDeCargasObj)
            % disp: es un metodo de la clase PatronDeCargasConstante que se usa para imprimir en
            % command Window la informacion del Patron de Cargas
            %
            % disp(patronDeCargasObj)
            % Imprime la informacion guardada en el Patron de Cargas Constante (patronDeCargasObj)
            % en pantalla
            
            fprintf('Propiedades Patron de Cargas Constante :\n');
            disp@ComponenteModelo(patronDeCargasObj);
            
        end % disp function
        
    end % methods PatronDeCargasConstante
    
end % class PatronDeCargasConstante