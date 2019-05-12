% Agrega m2html al path, esta libreria debe estar instalada en el path de
% usuario
% https://www.artefact.tk/software/matlab/m2html
addpath(sprintf('%s/m2html', userpath));
addpath('C:/Program Files (x86)/Graphviz2.38/bin');

% Genera la documentacion
m2html('mfiles', 'tefame', 'htmldir', 'docs', 'recursive', 'on', ...
    'global', 'on', 'template', 'frame', 'index', 'menu', 'graph', 'on', ...
    'download', 'off');