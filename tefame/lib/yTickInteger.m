function yTickInteger()
% yTickInteger: Modifica el ytick de un grafico dejando solo aquellos
% valores enteros

y = get(gca, 'YTick');
ytick = cell(1, length(y));

% Crea el xticks
for i = 1:length(y)
    if floor(y(i)) == y(i)
        ytick{i} = num2str(y(i));
    else
        ytick{i} = '';
    end
end % for i
set(gca, 'YTick', y, 'yticklabel', ytick);

end