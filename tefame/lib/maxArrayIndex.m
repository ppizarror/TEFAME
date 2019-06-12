function i = maxArrayIndex(A)
% maxArrayIndex: Retorna el indice asociado al maximo valor del vector A
% (1xN)

i = find(A == max(A(:)));

end % maxArrayIndex function