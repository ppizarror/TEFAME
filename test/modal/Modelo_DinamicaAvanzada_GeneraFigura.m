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

%% Guarda las figuras
for i = 1:6
    cd('C:\Users\JaimeR\Documents\MATLAB\TEFAME')
    aux = get(gca, 'title');
    title = get(aux, 'string');
    % Detalles del analisis
    caso = {'/EspacioEstado', '/Newmark'};
    carpeta = 'test/modal/out';
    Ubicacion = strcat(carpeta, caso{2});
    Nombre = strrep(title, ' ', '');
    format = 'fig';
    cd(Ubicacion)
    saveas(gca, Nombre, format)
    cd('C:\Users\JaimeR\Documents\MATLAB\TEFAME')
    close
    i = i + 1;
end

%% Unir Figuras
for i = 1:6
    close all
    cd('C:/Users/JaimeR/Documents/MATLAB/TEFAME')
    caso = {'EspacioEstado', 'Newmark'};
    carpeta = 'test/modal/out';
    Ubicacion = strcat(carpeta);
    cd(Ubicacion)
    listing = dir(caso{1});
    name = listing(i+2).name;
    cd(strcat('C:/Users/JaimeR/Documents/MATLAB/TEFAME/test/modal/out/', caso{1}))
    h1 = openfig(name, 'invisible'); % open figure
    ax1 = gca; % get handle to axes of figure
    t1 = get(gca, 'title');
    Titre = get(t1, 'string');
    t1 = get(gca, 'xlabel');
    xlab = get(t1, 'string');
    t1 = get(gca, 'ylabel');
    ylab = get(t1, 'string');
    x1 = findobj(ax1, '-property', 'XData');
    %      y1 = findobj(ax1,'-property','XData');
    cd(strcat('C:/Users/JaimeR/Documents/MATLAB/TEFAME/test/modal/out/', caso{2}))
    h2 = openfig(name, 'invisible');
    ax2 = gcf;
    x2 = findobj(ax2, '-property', 'XData');
    %      y2 = findobj(ax2,'-property','XData');
    clear title xlabel ylabel
    cd('C:/Users/JaimeR/Documents/MATLAB/TEFAME')
    
    figure
    plot(x1.XData, x1.YData)
    hold on
    if i == 2 && i == 3
        plot(x2.XData, x2.YData, '*-')
    else
        plot(x2.XData, x2.YData, '--')
    end
    legend({caso{1}, caso{2}})
    title(Titre)
    xlabel(xlab)
    ylabel(ylab)
    cd(strcat('C:/Users/JaimeR/Documents/MATLAB/TEFAME/test/modal/out/Comparacion'))
    nombre = strsplit(Titre, '-');
    Nombre = strrep(nombre{1}, ' ', '');
    saveas(gca, Nombre, 'epsc2')
    saveas(gca, Nombre, 'fig')
    i = i + 1;
end