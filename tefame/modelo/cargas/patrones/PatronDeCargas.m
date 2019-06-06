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
%|                 Pablo Pizarro @ppizarror - 10/04/2019                |
%|______________________________________________________________________|
%
%  Properties (Access=private):
%
%  Methods:
%       obj = PatronDeCargas(etiquetaPatronDeCargas,arregloCargas)
%       aplicarCargas(obj)
%       patronDinamico(obj)
%       disp(obj)
%       cargas = obtenerCargas(obj)
%  Methods Suplerclass (ComponenteModelo):
%       etiqueta = obtenerEtiqueta(obj)
%       e = equals(obj,obj)
%       objID = obtenerIDObjeto(obj)

classdef PatronDeCargas < ComponenteModelo
    
    properties (Access = private)
    end % private properties PatronDeCargas
    
    properties (Access = protected)
        cargas % Variable que guarda en un arreglo de celdas todas las cargas aplicadas en el patron de cargas
    end % protected properties PatronDeCargas
    
    properties (Access = public)
        patronEsDinamico
    end % public properties PatronDeCargas
    
    methods (Access = public)
        
        function obj = PatronDeCargas(etiquetaPatronDeCargas)
            % PatronDeCargas: es el constructor de la clase PatronDeCargas
            %
            % Crea un objeto de la clase PatronDeCargas, con un identificador unico
            % (etiquetaPatronDeCargas)
            
            if nargin == 0
                etiquetaPatronDeCargas = '';
            end % if
            
            % Llamamos al constructor de la SuperClass que es la clase ComponenteModelo
            obj = obj@ComponenteModelo(etiquetaPatronDeCargas);
            obj.cargas = {};
            
        end % PatronDeCargas constructor
        
        function aplicarCargas(obj) %#ok<MANU>
            % aplicarCargas: es un metodo de la clase PatronDeCargas que se usa
            % para aplicar las cargas guardadas en el Patron de Cargas
            %
            % Aplica las cargas que estan guardadas en el PatronDeCargas (obj),
            % es decir, se aplican las cargas sobre los nodos y elementos
            
        end % aplicarCargas function
        
        function y = patronDinamico(obj)
            % patronDinamico: Indica si el patron es dinamico o no
            
            y = obj.patronEsDinamico;
            
        end % patronDinamico function
        
        function disp(obj)
            % disp: es un metodo de la clase PatronDeCargas que se usa para imprimir en
            % command Window la informacion del Patron de Cargas
            %
            % Imprime la informacion guardada en el Patron de Cargas (obj)
            % en pantalla
            
            disp@ComponenteModelo(obj);
            % No usar dispMetodoTEFAME()
            
        end % disp function
        
        function cargas = obtenerCargas(obj)
            % obtenerCargas: Obtiene las cargas del patron
            
            cargas = obj.cargas;
            
        end % obtenerCargas function
        
    end % public methods PatronDeCargas
    
end % class PatronDeCargas