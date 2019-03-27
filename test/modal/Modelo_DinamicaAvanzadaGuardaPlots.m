analisisObj.desactivaCargaAnimacion();
for i = 1:10
    analisisObj.plot(i, 25, 25, sprintf('test/modal/Modelo_DinamicaAvanzada_%d.gif', i));
    pause(0.1);
end
analisisObj.activaCargaAnimacion();