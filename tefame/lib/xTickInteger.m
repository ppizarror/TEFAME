function xTickInteger()
% xTickInteger: Modifica el xtick de un grafico dejando solo aquellos
% valores enteros

x = get(gca, 'XTick');
xtick = cell(1, length(x));

% Crea el xticks
for i = 1:length(x)
    if floor(x(i)) == x(i)
        xtick{i} = num2str(x(i));
    else
        xtick{i} = '';
    end
end % for i
set(gca, 'XTick', x, 'xticklabel', xtick);

end