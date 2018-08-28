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
%| Clase Membrana                                                       |
%|                                                                      |
%| Este archivo contiene la definicion de la Clase Membrana             |
%| Membrana es una subclase de la clase Elemento y  corresponde a  la   |
%| representacion del elemento membrana bidimensional sencilla de secc- |
%| ión rectangular de cuatro nodos sometida a un estado de fuerzas.     |
%|                                                                      |
%| Programado: PABLO PIZARRO @ppizarror.com                             |
%| Fecha: 27/08/2018                                                    |
%|______________________________________________________________________|
%
%  Properties (Access=private):
%       nodosObj
%       gdlID
%       E
%       nu
%       dx
%       dy
%       L
%       Feq
%
%  Methods:
%       membranaObj = Viga2D(etiquetaViga,nodo1Obj,nodo2Obj,E,nu)
%       numeroNodos = obtenerNumeroNodos(membranaObj)
%       nodosMembrana = obtenerNodos(membranaObj)
%       numeroGDL = obtenerNumeroGDL(membranaObj)
%       gdlIDBiela = obtenerGDLID(membranaObj)
%       k_global = obtenerMatrizRigidezCoordGlobal(membranaObj)
%       k_local = obtenerMatrizRigidezCoordLocal(membranaObj)
%       fr_global = obtenerFuerzaResistenteCoordGlobal(membranaObj)
%       fr_local = obtenerFuerzaResistenteCoordLocal(membranaObj)
%       b = obtenerAncho(membranaObj)
%       h = obtenerAlto(membranaObj)
%       definirGDLID(membranaObj)
%       agregarFuerzaResistenteAReacciones(membranaObj)
%       guardarPropiedades(membranaObj,archivoSalidaHandle)
%       guardarEsfuerzosInternos(membranaObj,archivoSalidaHandle)
%       disp(membranaObj)
%
%  Methods SuperClass (ComponenteModelo):
%       etiqueta = obtenerEtiqueta(componenteModeloObj)

classdef Membrana < Elemento
    
    properties(Access = private)
        nodosObj
        gdlID
        E
        nu
        D
        t
        h
        b
        Feq
    end % properties Membrana
    
    methods
        
        function membranaObj = Membrana(etiquetaMembrana, nodo1Obj, nodo2Obj, nodo3Obj, nodo4Obj, E, nu, t)
            
            % Si no se pasan argumentos se crean vacios
            if nargin == 0
                etiquetaMembrana = '';
            end % if
            
            % Llamamos al constructor de la SuperClass que es la clase Elemento
            membranaObj = membranaObj@Elemento(etiquetaMembrana);
            
            % Guarda material
            membranaObj.nodosObj = {nodo1Obj; nodo2Obj; nodo3Obj; nodo4Obj};
            membranaObj.E = E;
            membranaObj.nu = nu;
            
            % ID de los grados de libertad (4 aristas)
            membranaObj.gdlID = [];
            
            % Calcula matriz D de constantes elasticas (constitutiva)
            membranaObj.D = E * [ ...
                1 / (1 - nu^2), nu / (1 - nu^2), 0; ...
                nu / (1 - nu^2), 1 / (1 - nu^2), 0; ...
                0, 0, 1 / (2 + 2 * nu)];
            
            % Calcula largo (2b) y alto (2h), se usa el siguiente orden:
            %
            %           4 ------------- 3
            %           |       y       |
            %        2h |       #x      |
            %           |               |
            %           1 ------------- 2
            %                  2b
            coordNodo1 = nodo1Obj.obtenerCoordenadas();
            coordNodo2 = nodo2Obj.obtenerCoordenadas();
            coordNodo3 = nodo3Obj.obtenerCoordenadas();
            coordNodo4 = nodo4Obj.obtenerCoordenadas();
            
            db1 = abs(coordNodo1(1)-coordNodo2(1)) / 2;
            db2 = abs(coordNodo3(1)-coordNodo4(1)) / 2;
            dh1 = abs(coordNodo1(2)-coordNodo4(2)) / 2;
            dh2 = abs(coordNodo2(2)-coordNodo3(2)) / 2;
            if (db1 ~= db2)
                error('Dimensiones no correctas en @x Membrana ID %s', etiquetaMembrana);
            end
            if (dh1 ~= dh2)
                error('Dimensiones no correctas en @y Membrana ID %s', etiquetaMembrana);
            end
            
            membranaObj.b = db1;
            membranaObj.h = dh1;
            membranaObj.t = t;
            
            % Fuerza equivalente de la membrana
            membranaObj.Feq = [0, 0, 0, 0, 0, 0, 0, 0]'; % 8x1
            
        end % Membrana constructor
        
        function b = obtenerAncho(membranaObj)
            
            b = 2 * membranaObj.b;
            
        end % obtenerLargo function
        
        function h = obtenerAlto(membranaObj)
            
            h = 2 * membranaObj.h;
            
        end % obtenerLargo function
        
        function numeroNodos = obtenerNumeroNodos(membranaObj) %#ok<MANU>
            
            numeroNodos = 2;
            
        end % obtenerNumeroNodos function
        
        function nodosMembrana = obtenerNodos(membranaObj)
            
            nodosMembrana = membranaObj.nodosObj;
            
        end % obtenerNodos function
        
        function numeroGDL = obtenerNumeroGDL(membranaObj) %#ok<MANU>
            
            numeroGDL = 8;
            
        end % obtenerNumeroGDL function
        
        function gdlIDViga = obtenerGDLID(membranaObj)
            
            gdlIDViga = membranaObj.gdlID;
            
        end % obtenerNumeroGDL function
        
        function k_global = obtenerMatrizRigidezCoordGlobal(membranaObj)
            
            % Matriz global igual a la local, no hay rotación
            k_global = membranaObj.obtenerMatrizRigidezCoordLocal();
            
        end % obtenerMatrizRigidezGlobal function
        
        function k_local = obtenerMatrizRigidezCoordLocal(membranaObj)
            
            % Crea la matriz vacía de 8x8
            k_local = zeros(8, 8);
            
            % Calcula valores iniciales
            a1 = (membranaObj.t * membranaObj.h * membranaObj.D(1, 1)) / (6 * membranaObj.b);
            a2 = (membranaObj.t * membranaObj.b * membranaObj.D(2, 2)) / (6 * membranaObj.h);
            a3 = (membranaObj.t * membranaObj.D(1, 2)) / (4);
            a4 = (membranaObj.t * membranaObj.b * membranaObj.D(3, 3)) / (6 * membranaObj.h);
            a5 = (membranaObj.t * membranaObj.h * membranaObj.D(3, 3)) / (6 * membranaObj.b);
            a6 = (membranaObj.t * membranaObj.D(3, 3)) / (4);
            A = [a1; a2; a3; a4; a5; a6];
            
            % Crea las funciones
            aij = @(i, j) (A(i) + A(j));
            bij = @(i, j) (A(i) - A(j));
            cij = @(i, j) (A(i) - 2 * A(j));
            
            % Aplica valores T supr
            k_local(1, 1) = 2 * aij(1, 4);
            k_local(1, 2) = aij(3, 6);
            k_local(1, 3) = cij(4, 1);
            k_local(1, 4) = bij(3, 6);
            k_local(1, 5) = -aij(1, 4);
            k_local(1, 6) = -aij(3, 6);
            k_local(1, 7) = cij(1, 4);
            k_local(1, 8) = bij(6, 3);
            
            k_local(2, 2) = 2 * aij(2, 4);
            k_local(2, 3) = bij(6, 3);
            k_local(2, 4) = cij(2, 5);
            k_local(2, 5) = -aij(3, 6);
            k_local(2, 6) = -aij(2, 5);
            k_local(2, 7) = bij(3, 6);
            k_local(2, 8) = cij(5, 2);
            
            k_local(3, 3) = 2 * aij(1, 4);
            k_local(3, 4) = -aij(3, 6);
            k_local(3, 5) = cij(1, 4);
            k_local(3, 6) = bij(3, 6);
            k_local(3, 7) = -aij(1, 4);
            k_local(3, 8) = aij(6, 3);
            
            k_local(4, 4) = 2 * aij(2, 4);
            k_local(4, 5) = bij(6, 3);
            k_local(4, 6) = cij(5, 2);
            k_local(4, 7) = aij(3, 6);
            k_local(4, 8) = -aij(5, 2);
            
            k_local(5, 5) = 2 * aij(1, 4);
            k_local(5, 6) = aij(3, 6);
            k_local(5, 7) = cij(4, 1);
            k_local(5, 8) = -bij(6, 3);
            
            k_local(6, 6) = 2 * aij(2, 4);
            k_local(6, 7) = bij(6, 3);
            k_local(6, 8) = cij(2, 5);
            
            k_local(7, 7) = 2 * aij(1, 4);
            k_local(7, 8) = -aij(3, 6);
            
            k_local(8, 8) = 2 * aij(2, 4);
            
            % Aplica traspuesta
            for i = 2:8 % fila
                for j = 1:8 % columna
                    if (j < i)
                        k_local(i, j) = k_local(j, i);
                    end
                end
            end
            
        end % obtenerMatrizRigidezLocal function
        
        function fr_global = obtenerFuerzaResistenteCoordGlobal(membranaObj)
            
            % Obtiene fr local
            fr_local = membranaObj.obtenerFuerzaResistenteCoordLocal();
            
            % Resta a fuerza equivalente para obtener la fuerza global
            fr_global = fr_local - membranaObj.Feq;
            
        end % obtenerFuerzaResistenteCoordGlobal function
        
        function fr_local = obtenerFuerzaResistenteCoordLocal(membranaObj)
            
            % Obtiene los nodos
            nodo1 = membranaObj.nodosObj{1};
            nodo2 = membranaObj.nodosObj{2};
            nodo3 = membranaObj.nodosObj{3};
            nodo4 = membranaObj.nodosObj{4};
            
            % Obtiene los desplazamientos
            u1 = nodo1.obtenerDesplazamientos();
            u2 = nodo2.obtenerDesplazamientos();
            u3 = nodo3.obtenerDesplazamientos();
            u4 = nodo4.obtenerDesplazamientos();
            
            % Vector desplazamientos u'
            u = [u1(1), u1(2), u2(1), u2(2), u3(1), u3(2), u4(1), u4(2)]';
            
            % Obtiene K local
            k_local = membranaObj.obtenerMatrizRigidezCoordLocal();
            
            % Calcula F
            fr_local = k_local * u;
            
        end % obtenerFuerzaResistenteCoordLocal function
        
        function definirGDLID(membranaObj)
            
            % Se obtienen los nodos extremos
            nodo1 = membranaObj.nodosObj{1};
            nodo2 = membranaObj.nodosObj{2};
            nodo3 = membranaObj.nodosObj{3};
            nodo4 = membranaObj.nodosObj{4};
            
            % Se obtienen los gdl de los nodos
            gdlnodo1 = nodo1.obtenerGDLID();
            gdlnodo2 = nodo2.obtenerGDLID();
            gdlnodo3 = nodo3.obtenerGDLID();
            gdlnodo4 = nodo4.obtenerGDLID();
            
            % Se establecen gdl
            gdl = [0, 0, 0, 0, 0, 0, 0, 0];
            gdl(1) = gdlnodo1(1);
            gdl(2) = gdlnodo1(2);
            gdl(3) = gdlnodo2(1);
            gdl(4) = gdlnodo2(2);
            gdl(5) = gdlnodo3(1);
            gdl(6) = gdlnodo3(2);
            gdl(7) = gdlnodo4(1);
            gdl(8) = gdlnodo4(2);
            membranaObj.gdlID = gdl;
            
        end % definirGDLID function
        
        function sumarFuerzaEquivalente(membranaObj, f)
            
            for i = 1:length(f)
                membranaObj.Feq(i) = membranaObj.Feq(i) + f(i);
            end
            
        end % sumarFuerzaEquivalente function
        
        function agregarFuerzaResistenteAReacciones(membranaObj)
            
            % Se calcula la fuerza resistente global
            fr_global = membranaObj.obtenerFuerzaResistenteCoordGlobal();
            
            % Carga los nodos
            nodo1 = membranaObj.nodosObj{1};
            nodo2 = membranaObj.nodosObj{2};
            nodo3 = membranaObj.nodosObj{3};
            nodo4 = membranaObj.nodosObj{4};
            
            % Agrega fuerzas equivalentes como cargas
            nodo1.agregarCarga([-membranaObj.Feq(1), -membranaObj.Feq(2)]');
            nodo2.agregarCarga([-membranaObj.Feq(3), -membranaObj.Feq(4)]');
            nodo3.agregarCarga([-membranaObj.Feq(5), -membranaObj.Feq(6)]');
            nodo4.agregarCarga([-membranaObj.Feq(7), -membranaObj.Feq(8)]');
            
            % Agrega fuerzas resistentes como cargas
            nodo1.agregarEsfuerzosElementoAReaccion([fr_global(1), fr_global(2)]');
            nodo2.agregarEsfuerzosElementoAReaccion([fr_global(3), fr_global(4)]');
            nodo3.agregarEsfuerzosElementoAReaccion([fr_global(5), fr_global(6)]');
            nodo4.agregarEsfuerzosElementoAReaccion([fr_global(7), fr_global(8)]');
            
        end % agregarFuerzaResistenteAReacciones function
        
        function guardarPropiedades(membranaObj, archivoSalidaHandle)
            
            fprintf(archivoSalidaHandle, '\tMembrana %s:\n\t\tAncho (2b):\t\t%s\n\t\tAlto (2h):\t\t%s\n\t\tEspesor (t):\t%s\n\t\tE:\t\t\t\t%s\n\t\tv:\t\t\t\t%s\n', ...
                membranaObj.obtenerEtiqueta(), num2str(2*membranaObj.b), num2str(2*membranaObj.h), ...
                num2str(membranaObj.t), num2str(membranaObj.E), num2str(membranaObj.nu));
            
        end % guardarPropiedades function
        
        function guardarEsfuerzosInternos(membranaObj, archivoSalidaHandle)
            
            fr = membranaObj.obtenerFuerzaResistenteCoordGlobal();
            
            % Obtiene las fuerzas para cada elemento
            n1x = pad(num2str(fr(1), '%.04f'), 10);
            n1y = pad(num2str(fr(2), '%.04f'), 10);
            n2x = pad(num2str(fr(3), '%.04f'), 10);
            n2y = pad(num2str(fr(4), '%.04f'), 10);
            n3x = pad(num2str(fr(5), '%.04f'), 10);
            n3y = pad(num2str(fr(6), '%.04f'), 10);
            n4x = pad(num2str(fr(7), '%.04f'), 10);
            n4y = pad(num2str(fr(8), '%.04f'), 10);
            
            fprintf(archivoSalidaHandle, '\n\tMembrana %s:\n\t\tNodo 1 (-b, -h): %s\t%s\n\t\tNodo 2 (+b, -h): %s\t%s\n\t\tNodo 3 (+b, +h): %s\t%s\n\t\tNodo 4 (-b, +h): %s\t%s', ...
                membranaObj.obtenerEtiqueta(), n1x, n1y, n2x, n2y, n3x, n3y, n4x, n4y);
            
        end % guardarEsfuerzosInternos function
        
        function disp(membranaObj)
            
            % Imprime propiedades de la membrana
            fprintf('Propiedades Membrana:\n\t');
            disp@ComponenteModelo(membranaObj);
            
            fprintf('\t\tAncho (2b): %s\tAlto (2h): %s\tE: %s\tv: %s\n', pad(num2str(2*membranaObj.b), 10), ...
                pad(num2str(2*membranaObj.h), 10), pad(num2str(membranaObj.E), 10), pad(num2str(membranaObj.nu), 10));
            
            % Se imprime matriz de rigidez local
            fprintf('\tMatriz de rigidez coordenadas locales:\n');
            disp(membranaObj.obtenerMatrizRigidezCoordLocal());
            
            % Se imprime matriz de rigidez global
            fprintf('\tMatriz de rigidez coordenadas globales:\n');
            disp(membranaObj.obtenerMatrizRigidezCoordGlobal());
            
            fprintf('-------------------------------------------------\n');
            fprintf('\n');
            
        end % disp function
        
    end % methods Membrana
    
end % class Membrana