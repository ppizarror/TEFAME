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
%| Clase Elemento                                                       |
%|                                                                      |
%| Este archivo contiene la definicion de la Clase Elemento             |
%| Elemento es una subclase de la  clase ComponenteModelo y corresponde |
%| a  la representacion  abstracta  de los elementos en  el  metodo  de |
%| elementos finitos o analisis matricial de estructuras.               |
%|                                                                      |
%| La clase Elemento se usa como una superclase para todos los tipos de |
%| elementos que hay en la plataforma. Y define los metodos minimos que |
%| tiene que ser implementados en cada subclase.                        |
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
%       obj = Elemento(etiquetaElemento)
%       numeroNodos = obtenerNumeroNodos(obj)
%       nodosElemento = obtenerNodos(obj)
%       numeroGDL = obtenerNumeroGDL(obj)
%       gdlID = obtenerGDL(obj)
%       k_global = obtenerMatrizRigidezCoordGlobal(obj)
%       k_local = obtenerMatrizRigidezCoordLocal(obj)
%       fr_global = obtenerFuerzaResistenteCoordGlobal(obj)
%       fr_local = obtenerFuerzaResistenteCoordLocal(obj)
%       inicializar(obj)
%       definirGDLID(obj)
%       agregarFuerzaResistenteAReacciones(obj)
%       actualizar(obj)
%       guardarPropiedades(obj,archivoSalidaHandle)
%       guardarEsfuerzosInternos(obj,archivoSalidaHandle)
%       activarGraficoDeformada(obj)
%       desactivarGraficoDeformada(obj)
%       graficaDeformada(obj)
%       disp(obj)
%  Methods SuperClass (ComponenteModelo):
%       etiqueta = obtenerEtiqueta(obj)
%       e = equals(obj,obj)
%       objID = obtenerIDObjeto(obj)

classdef Elemento < ComponenteModelo
    
    properties(Access = private)
        graficaDeformadaElem % Grafica la deformada del elemento
    end % private properties Elemento
    
    properties(Access = protected)
        factorMasa % Indica el factor en que convierte densidad en masa
    end % protected properties Elemento
    
    methods(Access = public)
        
        function obj = Elemento(etiquetaElemento)
            % Elemento: es el constructor de la clase Elemento
            %
            % Crea un objeto de la clase Elemento, con un identificador unico
            % (etiquetaElemento)
            
            % Si no se pasan argumentos se crean vacios
            if nargin == 0
                etiquetaElemento = '';
            end
            
            % Llamamos al constructor de la SuperClass que es la clase ComponenteModelo
            obj = obj@ComponenteModelo(etiquetaElemento);
            obj.graficaDeformadaElem = true;
            
        end % Elemento constructor
        
        function numeroNodos = obtenerNumeroNodos(obj) %#ok<MANU>
            % obtenerNumeroNodos: es un metodo de la clase Elemento que se usa para
            % obtener el numero de nodos que tiene el Elemento
            %
            % Entrega el numero de nodos (numeroNodos) que tiene el Elemento
            % (obj)
            
            numeroNodos = 0;
            
        end % obtenerNumeroNodos function
        
        function nodosElemento = obtenerNodos(obj) %#ok<MANU>
            % obtenerNodos: es un metodo de la clase Elemento que se usa para
            % obtener un arreglo con los nodos que tiene el Elemento
            %
            % Entrega un arreglo con los Nodos (nodosElemento) que tiene el Elemento
            % (obj)
            
            nodosElemento = [];
            
        end % obtenerNodos function
        
        function numeroGDL = obtenerNumeroGDL(obj) %#ok<MANU>
            % obtenerNumeroGDL: es un metodo de la clase Elemento que se usa para
            % obtener el numero total de grados de libertad que tiene el Elemento
            %
            % Entrega el numero de GDL (numeroGDL) que tiene el Elemento (obj)
            
            numeroGDL = [];
            
        end % obtenerNumeroGDL function
        
        function gdlID = obtenerGDL(obj) %#ok<MANU>
            % obtenerGDL: es un metodo de la clase Elemento que se usa para
            % obtener un arreglo con los ID de los grados de libertad que estan
            % asociados al Elemento
            %
            % Entrega un arreglo con los ID de los GDL (gdlID) que tiene el Elemento
            % (obj)
            
            gdlID = [];
            
        end % obtenerGDL function
        
        function k_global = obtenerMatrizRigidezCoordGlobal(obj) %#ok<MANU>
            % obtenerMatrizRigidezCoordGlobal: es un metodo de la clase Elemento
            % que se usa para obtener la matriz de rigidez para el Elemento en el
            % sistema de coordenadas globales del sistema estructural o Modelo
            %
            % Entrega la matriz de rigidez (k_global) que tiene el Elemento (obj)
            %  en el sistema de coordenadas globales
            
            k_global = [];
            
        end % obtenerMatrizRigidezGlobal function
        
        function k_local = obtenerMatrizRigidezCoordLocal(obj) %#ok<MANU>
            % obtenerMatrizRigidezCoordLocal: es un metodo de la clase Elemento
            % que se usa para obtener la matriz de rigidez para el Elemento en el
            % sistema de coordenadas locales del elemento
            %
            % Entrega la matriz de rigidez (k_local)  en el sistema de coordenadas
            % local que tiene el Elemento (obj)
            
            k_local = [];
            
        end % obtenerMatrizRigidezLocal function
        
        function fr_global = obtenerFuerzaResistenteCoordGlobal(obj) %#ok<MANU>
            % obtenerFuerzaResistenteCoordGlobal: es un metodo de la clase Elemento
            % que se usa para obtener el vector de fuerzas resitente del Elemento
            % en el sistema de coordenadas globales del modelo o sistema
            % estructural
            %
            % Entrega el vector con las fuerzas resistentes (fr_global) que tiene
            % elemento (obj) en el sistema de coordenadas globales la
            % estructura
            
            fr_global = [];
            
        end % obtenerFuerzaResistenteCoordGlobal function
        
        function fr_local = obtenerFuerzaResistenteCoordLocal(obj) %#ok<MANU>
            % obtenerFuerzaResistenteCoordLocal: es un metodo de la clase Elemento
            % que se usa para obtener el vector de fuerzas resitente del Elemento
            % en el sistema de coordenadas locales del elemento
            %
            % Entrega el vector con las fuerzas resistentes (fr_local) que tiene
            % elemento (obj) en el sistema de coordenadas locales del
            % elemento
            
            fr_local = [];
            
        end % obtenerFuerzaResistenteCoordLocal function
        
        function inicializar(obj) %#ok<MANU>
            % inicializar: es un metodo de la clase Elemento que se usa para
            % inicializar las diferentes componentes que sean necesario en los
            % elementos para realizar posteriormente el analisis
            %
            % Inicializa los diferentes componetes del Elemento (obj),
            % para poder preparar estos para realizar el analisis
            
        end % inicializar function
        
        function definirGDLID(obj) %#ok<MANU>
            % definirGDLID: es un metodo de la clase Elemento que se usa para
            % definir el vector con los ID de los GDL del elemento
            %
            % Define los ID de los grados de libertad del Elemento (obj)
            
        end % definirGDLID function
        
        function agregarFuerzaResistenteAReacciones(obj) %#ok<MANU>
            % agregarEsfuerzosElementoAReaccion: es un metodo de la clase Nodo
            % que se usa para agregar el vector de fuerzas resistentes de un
            % elemento al nodo
            %
            % agregarEsfuerzosElementoAReaccion(nodoObj,esfuerzosElemento)
            %
            % Agrega al vector de reacciones del Nodo (nodoObj), el vector de
            % fuerzas resistente de un elemento entregados (cargaNodo)
            
        end % agregarFuerzaResistenteAReacciones function
        
        function actualizar(obj) %#ok<MANU>
            % actualizar: es un metodo de la clase Elemento que se usa para
            % actualizar las diferentes componentes que sean necesario en los
            % elementos posterior a realizar el analisis
            %
            % Actualizar los diferentes componetes del Elemento (obj),
            % despues de realizar el analisis
            
        end % actualizar function
        
        function guardarPropiedades(obj, archivoSalidaHandle) %#ok<INUSD>
            % guardarPropiedades: es un metodo de la clase Elemento que se usa
            % para guardar en un archivo de salida las propiedades del Elemento
            %
            % Guarda las propiedades de los Elemento (obj), en un archivo
            % de salida (archivoSalidaHandle)
            
        end % guardarPropiedades function
        
        function guardarEsfuerzosInternos(obj, archivoSalidaHandle) %#ok<INUSD>
            % guardarEsfuerzosInternos: es un metodo de la clase Elemento que se
            % usa para guardar en un archivo de salida los esfuerzos internos del
            % Elemento
            %
            % Guarda los esfuerzos internos de los Elemento (obj), en un
            % archivo de salida (archivoSalidaHandle)
            
        end % guardarEsfuerzosInternos function
        
        function plot(obj, deformadas, tipoLinea, grosorLinea, gdl) %#ok<INUSD>
            % plot: Grafica un elemento
            
        end % plot function
        
        function activarGraficoDeformada(obj)
            % activarGraficoDeformada: Activa el grafico de la
            % deformada del elemento
            
            obj.graficaDeformadaElem = true;
            
        end % activarGraficoDeformada function
        
        function desactivarGraficoDeformada(obj)
            % desactivarGraficoDeformada: Desactiva el grafico de la
            % deformada del elemento
            
            obj.graficaDeformadaElem = false;
            
        end % desactivarGraficoDeformada function
        
        function def = graficaDeformada(obj)
            % graficaDeformada: Indica si el objeto grafica su deformada o
            % no
            
            def = obj.graficaDeformadaElem;
            
        end % graficaDeformada function
        
        function graficarLinea(obj, coord1, coord2, tipoLinea, grosorLinea) %#ok<INUSL>
            % graficarLinea: Grafica una linea para un elemento
            
            if length(coord1) == 2
                plot([coord1(1), coord2(1)], [coord1(2), coord2(2)], tipoLinea, ...
                    'LineWidth', grosorLinea);
            else
                plot3([coord1(1), coord2(1)], [coord1(2), coord2(2)], [coord1(3), coord2(3)], ...
                    tipoLinea, 'LineWidth', grosorLinea);
            end
            
        end % graficarLinea function
        
        function disp(obj)
            % disp: es un metodo de la clase Elemento que se usa para impimir en
            % command Window la informacion del Elemento
            %
            % Imprime la informacion guardada en el Elemento (obj) en
            % pantalla
            
            disp@ComponenteModelo(obj);
            % No usar dispMetodoTEFAME()
            
        end % disp function
        
        function definirFactorUnidadMasa(obj, factor)
            % definirFactorUnidadMasa: Funcion que define el cambio de
            % unidad para pasar masa carga a masa real
            
            obj.factorMasa = factor;
            
        end % definirFactorUnidadMasa function
        
    end % public methods Elemento
    
end % class Elemento