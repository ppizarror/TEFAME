tInicio = clock;
analisisObj.desactivaCargaAnimacion();
for i = 1:10
    analisisObj.plot('modo', i, 'factor', 25, 'numcuadros', 25, ...
        'gif', sprintf('test/modal/out/Modelo_DinamicaAvanzada_%d.gif', i));
    pause(0.1);
end % for i
analisisObj.activaCargaAnimacion();
fprintf('Se completo el proceso en %.3f segundos\n\n', etime(clock, tInicio));