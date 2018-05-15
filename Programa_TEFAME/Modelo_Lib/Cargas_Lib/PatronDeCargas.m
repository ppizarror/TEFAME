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
%| Clase PatronDeCargas                                                 |
%|                                                                      |
%| Este archivo contiene la definicion de la Clase PatronDeCargas       |
%| PatronDeCargas es  una  subclase  de  la  clase  ComponenteModelo  y |
%| corresponde  a la  representacion  abstracta  del  patron de  cargas |
%| en  el   metodo  de   elementos  finitos  o  analisis  matricial  de |
%| estructuras.                                                         |
%| La clase  PatronDeCargas se usa  como  una superclase para todos los |
%| tipos  de PatronDeCargas que  hay  en  la plataforma. Y  define  los |
%| metodos minimos que tiene que ser implementados en cada subclase.    |
%| Adicionalmente, la  clase  PatronDeCargas  es  una  clase contenedor |
%| que  guarda y controla como varian  las cargas  que son aplicadas en |
%| los nodos y elementos                                                |
%|                                                                      |
%| Programado: FR                                                       |
%| Fecha: 05/08/2015                                                    |
%|                                                                      |
%| Modificado por: FR - 24/10/2016                                      |
%|______________________________________________________________________|
%
%  Properties (Access=private):
%
%  Methods:
%       patronDeCargasObj = PatronDeCargas(etiquetaPatronDeCargas,arreigloCargas)
%       aplicarCargas(patronDeCargasObj)
%       disp(patronDeCargasObj)
%  Methods Suplerclass (ComponenteModelo):
%       etiqueta = obtenerEtiqueta(componenteModeloObj)


classdef PatronDeCargas < ComponenteModelo
    
    properties(Access = private)
    end % properties PatronDeCargas
    
    methods
        
        function patronDeCargasObj = PatronDeCargas(etiquetaPatronDeCargas)
            % PatronDeCargas: es el constructor de la clase PatronDeCargas
            %
            % patronDeCargasObj = PatronDeCargas(etiquetaPatronDeCargas)
            % Crea un objeto de la clase PatronDeCargas, con un identificador unico
            % (etiquetaPatronDeCargas)
            
            if nargin == 0
                % If no argument input we create empty arguments
                etiquetaPatronDeCargas = '';
            end % if
            
            %Llamamos al constructor de la SuperClass que es la clase ComponenteModelo
            patronDeCargasObj = patronDeCargasObj@ComponenteModelo(etiquetaPatronDeCargas);
            
            
        end % PatronDeCargas constructor
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Metodos para aplicar las Carga guardadas en el patron de cargas durante el analisis
        
        function aplicarCargas(patronDeCargasObj) %#ok<MANU>
            % aplicarCargas: es un metodo de la clase PatronDeCargas que se usa
            % para aplicar las cargas guardadas en el Patron de Cargas
            %
            % aplicarCargas(patronDeCargasObj)
            % Aplica las cargas que estan guardadas en el PatronDeCargas (patronDeCargasObj),
            % es decir, se aplican las cargas sobre los nodos y elementos.
            
        end % aplicarCargas function
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Metodos para mostar la informacion del PatronDeCargas en pantalla
        
        function disp(patronDeCargasObj)
            % disp: es un metodo de la clase PatronDeCargas que se usa para imprimir en
            % command Window la informacion del Patron de Cargas
            %
            % disp(patronDeCargasObj)
            % Imprime la informacion guardada en el Patron de Cargas (patronDeCargasObj)
            % en pantalla
            
            disp@ComponenteModelo(patronDeCargasObj);
            
        end % disp function
        
    end % methods PatronDeCargas
    
end % class PatronDeCargas