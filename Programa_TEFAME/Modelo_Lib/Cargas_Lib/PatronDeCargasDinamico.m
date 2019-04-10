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
%| Desarrollado por:                                                    |
%|       Pablo Pizarro                                                  |
%|       Estudiante de Magister en Ingenieria Civil Estructural         |
%|       Universidad de Chile                                           |
%|______________________________________________________________________|
%
%  Properties (Access=private):
%       cargas
%       analisisObj
%
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
        analisisObj % Guarda el objeto de analisis con tal de obtener M,K,C
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
        % Metodos para aplicar las Carga guardadas en el patron de cargas durante el analisis
        
        function aplicarCargas(patronDeCargasObj)
            % aplicarCargas: es un metodo de la clase PatronDeCargasDinamico que
            % se usa para aplicar las cargas guardadas en el Patron de Cargas
            %
            % aplicarCargas(patronDeCargasObj)
            % Aplica las cargas que estan guardadas en el PatronDeCargasDinamico
            % (patronDeCargasObj), es decir, se aplican las cargas sobre los nodos
            % y elementos.
            
            % Se aplica la carga con un factor de carga = 1
            for i = 1:length(patronDeCargasObj.cargas)
                patronDeCargasObj.cargas{i}.aplicarCarga(1);
            end
            
        end % aplicarCargas function
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Metodos para mostar la informacion del PatronDeCargas en pantalla
        
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