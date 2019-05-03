function i = minArrayIndex(A)
% MAXARRAYINDEX Retorna el indice asociado al minimo valor del vector A
% (1xN)
i = find(A == min(A(:)));
end