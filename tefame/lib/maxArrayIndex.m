function i = maxArrayIndex(A)
% MAXARRAYINDEX Retorna el indice asociado al maximo valor del vector A
% (1xN)
i = find(A == max(A(:)));
end