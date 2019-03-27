function graficarElemento(coord1, coord2, tipoLinea, grosorLinea)
%GRAFICARELEMENTO Summary of this function goes here
%   Detailed explanation goes here
if length(coord1) == 2
    plot([coord1(1), coord2(1)], [coord1(2), coord2(2)], tipoLinea, 'LineWidth', grosorLinea);
else
    plot3([coord1(1), coord2(1)], [coord1(2), coord2(2)], [coord1(3), coord2(3)], tipoLinea, 'LineWidth', grosorLinea);
end
end