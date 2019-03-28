analisisObj.desactivaCargaAnimacion();
for i = 1:10
    analisisObj.plot('modo', i, 'factor', 25, 'numcuadros', 25, ...
        'gif', sprintf('test/modal/Modelo_DinamicaAvanzada_%d.gif', i));
    pause(0.1);
end
analisisObj.activaCargaAnimacion();